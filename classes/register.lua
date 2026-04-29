local DeconstructionCause = require("enums.deconstruction-cause")
local EK = require("enums.entry-key")
local Type = require("enums.type")

local Buildings = require("constants.buildings")
local TypeGroup = require("constants.type-groups")
local Types = require("constants.types")
local UpdateGroup = require("constants.update-groups")

--- Static class that stores and manages entities in hopefully performant ways.
Register = {}

--- An Entry from the Register, encapsulating a LuaEntity
--- @class Entry

--[[
    Data this class stores in storage
    --------------------------------
    storage.register: table
        [unit_number]: Entry

    storage.register_by_type: table
        [type]: unit_number-lookup-table

    storage.register_by_group: table
        [update_group]: unit_number-lookup-table

    storage.entry_counts:
        [type]: int (total number)

    storage.last_index_per_group: table
        [update_group]: int? (unit_number of the entry the last update cycle stopped on)
]]
-- local often used globals for almost non-existant performance gains

local storage
local register
local register_by_type
local register_by_group
local entry_counts
local last_index_per_group

local fire_all_workers

local add_subentities
local remove_subentities

local get_entity_type = Types.get_entity_type

local get_building_details = Buildings.get

local establish_new_neighbor
local unsubscribe_neighborhood
local remove_notifications

local update_workforce

local get_subtbl = Tirislib.Tables.get_subtbl

---------------------------------------------------------------------------------------------------
-- << lua state lifecycle stuff >>

local function set_locals()
    storage = _ENV.storage
    register = storage.register
    register_by_type = storage.register_by_type
    register_by_group = storage.register_by_group
    entry_counts = storage.entry_counts
    last_index_per_group = storage.last_index_per_group

    -- These systems are loaded after the register, so we local them during on_load
    fire_all_workers = Inhabitants.unemploy_all_workers

    add_subentities = Subentities.add_all_for
    remove_subentities = Subentities.remove_all_for

    establish_new_neighbor = Neighborhood.establish_new_neighbor
    unsubscribe_neighborhood = Neighborhood.unsubscribe_all
    remove_notifications = Communication.remove_notifications

    update_workforce = Inhabitants.update_workforce
end

function Register.init()
    storage = _ENV.storage
    storage.register = {}
    storage.register_by_type = {}
    storage.register_by_group = {}
    storage.entry_counts = {}
    storage.last_index_per_group = {}
    set_locals()

    -- find and register all the machines that need to be registered
    for _, surface in pairs(game.surfaces) do
        for _, entity in pairs(
            surface.find_entities_filtered {
                force = "player"
            }
        ) do
            if entity.unit_number then
                Register.add(entity)
            end
        end
    end
end

--- Sets local references during on_load
function Register.load()
    set_locals()
end

---------------------------------------------------------------------------------------------------
-- << custom building systems >>

--- Generic creation handler for CustomBuilding-systems that aren't specific to one type.
--- @param entry Entry
--- @param event table?
local function init_custom_building(entry, event)
    local building_details = get_building_details(entry)

    if building_details.workforce then
        entry[EK.worker_count] = 0
        entry[EK.workers] = {}
        entry[EK.target_worker_count] = building_details.workforce.count
    end

    local tags = Tirislib.Tables.get_subtbl_recursive_passive(event, "tags", "sosciencity")
    if tags and tags.target_worker_count then
        entry[EK.target_worker_count] = tags.target_worker_count
    end

    if building_details.auto_name and storage.auto_naming_enabled then
        local entity = entry[EK.entity]
        local player_index = event and (event.player_index or (entity.last_user and entity.last_user.index))
        if not player_index or settings.get_player_settings(player_index)["sosciencity-auto-naming-personal"].value then
            AutoNames.generate(building_details.auto_name, entry)
        end
    end
end

--- Generic clone handler for CustomBuilding-systems that aren't specific to one type.
--- @param source Entry
--- @param destination Entry
local function clone_custom_building(source, destination)
    destination[EK.custom_name] = source[EK.custom_name]
end

local function update_custom_building(entry)
    local building_details = get_building_details(entry)

    local workforce = building_details.workforce
    if workforce then
        update_workforce(entry, workforce)
    end
end

local function destroy_custom_building(entry)
    local building_details = get_building_details(entry)

    if building_details.workforce then
        fire_all_workers(entry)
    end
end

local function paste_custom_building_settings(source, destination)
    local source_details = get_building_details(source)
    local destination_details = get_building_details(destination)

    if source_details.workforce and destination_details.workforce then
        destination[EK.target_worker_count] =
            math.min(source[EK.target_worker_count], destination_details.workforce.count)
    end
end

local function blueprint_custom_building(entry)
    if entry[EK.target_worker_count] then
        return {
            target_worker_count = entry[EK.target_worker_count]
        }
    end
end

---------------------------------------------------------------------------------------------------
-- << entity event handlers >>

local function set_handler(lookup, _type, fn, name)
    Tirislib.Utils.desync_protection()
    if lookup[_type] then
        error("Duplicate " .. name .. " handler registration for type " .. tostring(_type))
    end
    lookup[_type] = fn
end

local on_creation_lookup = {}

--- Sets the function that gets called when an entity of the given type gets created.
--- @param _type Type
--- @param fn function
function Register.set_entity_creation_handler(_type, fn)
    set_handler(on_creation_lookup, _type, fn, "creation")
end

local function on_creation(_type, entry, event)
    local fn = on_creation_lookup[_type]

    if fn then
        fn(entry, event)
    end
end

local on_copy_lookup = {}

--- Sets the function that gets called when an entity of the given type gets copied.
--- The creation function is called before this.
--- @param _type Type
--- @param fn function
function Register.set_entity_copy_handler(_type, fn)
    set_handler(on_copy_lookup, _type, fn, "copy")
end

local function on_copy(_type, source, destination)
    local fn = on_copy_lookup[_type]

    if fn then
        fn(source, destination)
    end
end

local update_lookup = {}

--- Sets the function that gets called when an entity of the given type gets updated during an entity update cycle.
--- @param _type Type
--- @param fn function
function Register.set_entity_updater(_type, fn)
    set_handler(update_lookup, _type, fn, "updater")
end

local function on_update(entry, current_tick)
    local updater = update_lookup[entry[EK.type]]
    if updater ~= nil then
        local delta_ticks = current_tick - entry[EK.last_update]
        if delta_ticks > 0 then
            updater(entry, delta_ticks, current_tick)
        end
    end
end

local on_destroyed_lookup = {}

--- Sets the function that gets called when an entity of the given type gets destroyed.
--- @param _type Type
--- @param fn function
function Register.set_entity_destruction_handler(_type, fn)
    set_handler(on_destroyed_lookup, _type, fn, "destruction")
end

local function on_destruction(_type, entry, cause, event)
    local fn = on_destroyed_lookup[_type]

    if fn then
        fn(entry, cause, event)
    end
end

--- Data structure:\
--- [destination_type]: table of (source_type, function)-pairs
local on_settings_paste_lookup = {}

--- Sets the function that gets called when the player pastes the settings of one type of entity to another.
--- @param source_type Type
--- @param destination_type Type
--- @param fn function
function Register.set_settings_paste_handler(source_type, destination_type, fn)
    Tirislib.Utils.desync_protection()

    local tbl = get_subtbl(on_settings_paste_lookup, destination_type)
    if tbl[source_type] then
        error("Duplicate settings_paste handler registration for types " ..
            tostring(source_type) .. " -> " .. tostring(destination_type))
    end
    tbl[source_type] = fn
end

--- Calls the event handler when the player pastes the settings of one entity to another - if there is a handler.
--- Handlers receive (source, destination, event) - event is the raw Factorio event table.
--- @param source_type Type
--- @param source Entry
--- @param destination_type Type
--- @param destination Entry
--- @param event table
function Register.on_settings_pasted(source_type, source, destination_type, destination, event)
    paste_custom_building_settings(source, destination)

    local tbl = on_settings_paste_lookup[destination_type]

    if tbl then
        local fn = tbl[source_type]
        if fn then
            fn(source, destination, event)
        end
    end
end

local blueprinted_lookup = {}

--- Sets the function that gets called when the player makes a blueprint of an entry.
--- @param _type Type
--- @param fn function should return a table with the tags to store in the blueprint
function Register.set_blueprinted_handler(_type, fn)
    set_handler(blueprinted_lookup, _type, fn, "blueprinted")
end

--- Calls the event handler when a blueprint is being setup of an entry.
--- @param entry Entry
--- @param blueprint LuaRecord
--- @param index uint8
function Register.on_blueprinted(entry, blueprint, index)
    local tags = blueprint_custom_building(entry)

    local fn = blueprinted_lookup[entry[EK.type]]
    if fn then
        local type_specific_tags = fn(entry)
        if tags then
            Tirislib.Tables.set_fields(tags, type_specific_tags)
        else
            tags = type_specific_tags
        end
    end

    if tags ~= nil then
        blueprint.set_blueprint_entity_tag(index, "sosciencity", tags)
    end
end

---------------------------------------------------------------------------------------------------
-- << register system >>

local function add_entry_to_register(entry)
    local unit_number = entry[EK.unit_number]

    -- general
    register[unit_number] = entry

    -- by type
    local _type = entry[EK.type]
    if not register_by_type[_type] then
        register_by_type[_type] = {}
    end
    register_by_type[_type][unit_number] = unit_number

    -- by group
    local group = UpdateGroup.type_assignment[_type] or UpdateGroup.default
    if not register_by_group[group] then
        register_by_group[group] = {}
    end
    register_by_group[group][unit_number] = unit_number

    -- type counts
    if not entry_counts[_type] then
        entry_counts[_type] = 0
    end
    entry_counts[_type] = entry_counts[_type] + 1
end

local function remove_entry_from_register(entry)
    local _type = entry[EK.type]
    local unit_number = entry[EK.unit_number]

    -- Advance group cursor before removal so the next cycle resumes correctly.
    local group = UpdateGroup.type_assignment[_type] or UpdateGroup.default
    local group_table = register_by_group[group]
    if group_table then
        if last_index_per_group[group] == unit_number then
            last_index_per_group[group] = next(group_table, unit_number)
        end
        group_table[unit_number] = nil
    end

    -- general
    register[unit_number] = nil

    -- by type
    register_by_type[_type][unit_number] = nil

    -- type counts
    entry_counts[_type] = entry_counts[_type] - 1
end

--- Returns a new entry for the given entity with the given type.
--- @param entity LuaEntity
--- @param _type Type
--- @return Entry
local function create_new_entry(entity, _type)
    local current_tick = game.tick

    local entry = {
        [EK.type] = _type,
        [EK.entity] = entity,
        [EK.unit_number] = entity.unit_number,
        [EK.name] = entity.name,
        [EK.last_update] = current_tick,
        [EK.tick_of_creation] = current_tick
    }

    return entry
end

--- Adds the given entity to the register. Optionally the type can be specified.
--- @param entity LuaEntity
--- @param _type Type?
--- @param event table?
function Register.add(entity, _type, event)
    _type = _type or get_entity_type(entity)
    if _type == Type.null then
        return
    end

    local entry = create_new_entry(entity, _type)

    add_entry_to_register(entry)

    init_custom_building(entry, event)
    add_subentities(entry)
    establish_new_neighbor(entry)
    on_creation(_type, entry, event)

    return entry
end

local add_entity = Register.add

--- Adds the given destination entity to the register with the same type as the source entry and copies the relevant entry data.
--- @param source Entry
--- @param destination LuaEntity
--- @return Entry destination_entry
function Register.clone(source, destination)
    local _type = source[EK.type]
    local destination_entry = add_entity(destination, _type)
    destination_entry[EK.tick_of_creation] = source[EK.tick_of_creation]
    clone_custom_building(source, destination_entry)

    on_copy(_type, source, destination_entry)

    -- mod-update rebuild stashed state on the source during remove_entry; otherwise capture from
    -- the still-live source (real clone-event flow). Either way, apply to the fresh subentities.
    local subentity_state = source[EK.subentity_state_pending]
    source[EK.subentity_state_pending] = nil
    if not subentity_state then
        subentity_state = Subentities.serialize(source)
    end
    Subentities.restore(destination_entry, subentity_state)

    return destination_entry
end

local stale_entry_metatable = {
    __index = function(_, k)
        error("Accessed stale entry (key: " .. tostring(k) .. ").")
    end,
    __newindex = function(_, k)
        error("Wrote to stale entry (key: " .. tostring(k) .. ").")
    end
}

--- Invalidates an entry as a precaution to make code that still uses it fail more directly.
--- @param entry Entry
local function invalidate_entry(entry)
    for key in pairs(entry) do
        entry[key] = nil
    end
    setmetatable(entry, stale_entry_metatable)
end

--- Checks if the given entry is stale.
--- @param entry Entry
--- @return boolean is_stale
function Register.is_stale(entry)
    return getmetatable(entry) == stale_entry_metatable
end

--- Removes the given entry from the register.
--- @param entry Entry
--- @param cause DeconstructionCause
--- @param event table?
--- @param keep_valid boolean? if invalidation should be ommitted
function Register.remove_entry(entry, cause, event, keep_valid)
    local _type = entry[EK.type]

    -- preserve subentity state across mod-update rebuild; clone consumes this on the destination side
    if cause == DeconstructionCause.mod_update then
        entry[EK.subentity_state_pending] = Subentities.serialize(entry)
    end

    destroy_custom_building(entry)
    on_destruction(_type, entry, cause, event)
    remove_subentities(entry)
    unsubscribe_neighborhood(entry)
    remove_notifications(entry)

    remove_entry_from_register(entry)

    if not keep_valid then
        invalidate_entry(entry)
    end
end
local remove_entry = Register.remove_entry

--- Removes the given entity from the register.
--- @param entity LuaEntity
--- @param unit_number integer?
--- @param cause DeconstructionCause?
function Register.remove_entity(entity, unit_number, cause)
    unit_number = unit_number or entity.unit_number
    cause = cause or DeconstructionCause.unknown

    local entry = register[unit_number]
    if entry then
        remove_entry(entry, cause)
    end
end

--- Reregisters the entity with the given type.
--- @param entry Entry
--- @param new_type Type
function Register.change_type(entry, new_type)
    remove_entry(entry, DeconstructionCause.type_change, nil, true)

    -- remove the sprites explicitly, because normally they get destroyed when the entity is destroyed
    Subentities.remove_sprites(entry)

    local new_entry = add_entity(entry[EK.entity], new_type)
    new_entry[EK.tick_of_creation] = entry[EK.tick_of_creation]

    Gui.DetailsView.rebuild_for_entry(new_entry)
    invalidate_entry(entry)
    return new_entry
end

--- Tries to get the entry with the given unit_number if exists and is still valid.
--- @param unit_number integer
--- @return Entry?
function Register.try_get(unit_number)
    local entry = register[unit_number]

    if entry then
        if entry[EK.entity].valid then
            return entry
        else
            remove_entry(entry, DeconstructionCause.unknown)
        end
    end
end
local try_get = Register.try_get

--- Returns the next valid entry or nil if the loop came to an end.
local function register_next(unit_number)
    while true do
        local entry
        unit_number, entry = next(register, unit_number)

        if not entry then
            return nil
        end

        if entry[EK.entity].valid then
            return unit_number, entry
        else
            remove_entry(entry, DeconstructionCause.unknown)
        end
    end
end
Register.next = register_next

--- Updates a single entry: runs custom building logic, calls the type-specific updater,
--- and advances last_update. Use this for targeted updates in tests instead of entity_update_cycle.
--- @param entry Entry
--- @param current_tick integer
function Register.update_entry(entry, current_tick)
    update_custom_building(entry)
    on_update(entry, current_tick)
    entry[EK.last_update] = current_tick
end

local function nothing()
end

local function type_iterator(type_table, key)
    while true do
        key = next(type_table, key)

        if key == nil then
            return nil, nil
        end

        local entry = try_get(key)
        if entry then
            return key, entry
        end
    end
end

function Register.entity_update_cycle(current_tick)
    local total = storage.updates_per_cycle
    local definitions = UpdateGroup.definitions

    for i = 1, #UpdateGroup.all do
        local group = UpdateGroup.all[i]
        local group_table = register_by_group[group]

        if group_table then
            local slice = math.ceil(total * definitions[group].slice_percent)
            local index = last_index_per_group[group]
            local current_entry = try_get(index)

            if not current_entry then
                index, current_entry = type_iterator(group_table, nil)
            end

            local count = 0
            while index and count < slice do
                update_custom_building(current_entry)
                on_update(current_entry, current_tick)
                current_entry[EK.last_update] = current_tick

                index, current_entry = type_iterator(group_table, index)
                count = count + 1
            end

            last_index_per_group[group] = index
        end
    end
end

--- Iterator for all entries of a specific type
--- @param _type Type
function Register.iterate_type(_type)
    local tbl = register_by_type[_type]
    if not tbl then
        return nothing
    end

    return type_iterator, tbl
end

--- Returns the number of existing entries of the given type.
function Register.get_type_count(_type)
    return entry_counts[_type] or 0
end
local get_type_count = Register.get_type_count

local types_affected_by_clockwork = TypeGroup.affected_by_clockwork

--- Returns the number of existing entries that are affected by clockwork bonuses.
function Register.get_machine_count()
    local ret = 0

    for i = 1, #types_affected_by_clockwork do
        ret = ret + get_type_count(types_affected_by_clockwork[i])
    end

    return ret
end

return Register
