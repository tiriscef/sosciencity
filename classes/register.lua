--- Static class that stores and manages entities in hopefully performant ways.
Register = {}

--[[
    Data this class stores in global
    --------------------------------
    global.register: table
        [unit_number]: Entry

    global.register_by_type: table
        [type]: unit_number-lookup-table

    global.entry_counts:
        [type]: int (total number)

    global.last_index: int|nil (unit_number of the entry the last update cycle stopped on)
]]
-- local often used globals for almost non-existant performance gains

local global
local register
local register_by_type
local entry_counts

local fire_all_workers

local add_subentities
local remove_subentities

local get_entity_type = Types.get_entity_type

local get_building_details = Buildings.get

local establish_new_neighbor
local unsubscribe_neighborhood

local update_workforce

local get_subtbl = Tirislib_Tables.get_subtbl

---------------------------------------------------------------------------------------------------
-- << lua state lifecycle stuff >>

local function set_locals()
    global = _ENV.global
    register = global.register
    register_by_type = global.register_by_type
    entry_counts = global.entry_counts

    -- These systems are loaded after the register, so we local them during on_load
    fire_all_workers = Inhabitants.unemploy_all_workers

    add_subentities = Subentities.add_all_for
    remove_subentities = Subentities.remove_all_for

    establish_new_neighbor = Neighborhood.establish_new_neighbor
    unsubscribe_neighborhood = Neighborhood.unsubscribe_all

    update_workforce = Inhabitants.update_workforce
end

--- Initialize the register related contents of global.
function Register.init()
    global = _ENV.global
    global.register = {}
    global.register_by_type = {}
    global.entry_counts = {}
    set_locals()

    -- find and register all the machines that need to be registered
    for _, surface in pairs(game.surfaces) do
        for _, entity in pairs(
            surface.find_entities_filtered {
                force = "player"
            }
        ) do
            Register.add(entity)
        end
    end
end

--- Sets local references during on_load
function Register.load()
    set_locals()
end

---------------------------------------------------------------------------------------------------
-- << entity event handlers >>

local on_creation_lookup = {}

--- Sets the function that gets called when an entity of the given type gets created.
--- @param _type Type
--- @param fn function
function Register.set_entity_creation_handler(_type, fn)
    Tirislib_Utils.desync_protection()
    on_creation_lookup[_type] = fn
end

local function on_creation(_type, entry)
    local fn = on_creation_lookup[_type]

    if fn then
        fn(entry)
    end
end

local on_copy_lookup = {}

--- Sets the function that gets called when an entity of the given type gets copied.
--- The creation function is called before this.
--- @param _type Type
--- @param fn function
function Register.set_entity_copy_handler(_type, fn)
    Tirislib_Utils.desync_protection()
    on_copy_lookup[_type] = fn
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
    Tirislib_Utils.desync_protection()
    update_lookup[_type] = fn
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
    Tirislib_Utils.desync_protection()
    on_destroyed_lookup[_type] = fn
end

local function on_destruction(_type, entry, cause)
    local fn = on_destroyed_lookup[_type]

    if fn then
        fn(entry, cause)
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
    Tirislib_Utils.desync_protection()

    local tbl = get_subtbl(on_settings_paste_lookup, destination_type)
    tbl[source_type] = fn
end

--- Calls the event handler when the player pastes the settings of one entity to another - if there is a handler.
--- @param source_type Type
--- @param source Entry
--- @param destination_type Type
--- @param destination Entry
function Register.on_settings_pasted(source_type, source, destination_type, destination)
    local tbl = on_settings_paste_lookup[destination_type]

    if tbl then
        local fn = tbl[source_type]
        if fn then
            fn(source, destination)
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << custom building systems >>

local function init_custom_building(entry)
    local building_details = get_building_details(entry)

    if building_details.workforce then
        entry[EK.worker_count] = 0
        entry[EK.workers] = {}
    end
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

    -- type counts
    if not entry_counts[_type] then
        entry_counts[_type] = 0
    end
    entry_counts[_type] = entry_counts[_type] + 1
end

local function remove_entry_from_register(entry)
    local _type = entry[EK.type]
    local unit_number = entry[EK.unit_number]

    -- The last update cycle stopped at this entry.
    -- We go to the next one, so the next cycle doesn't need to start from the first entry.
    if global.last_index == unit_number then
        global.last_index = next(register, unit_number)
    end

    -- general
    register[unit_number] = nil

    -- by type
    register_by_type[_type][unit_number] = nil

    -- type counts
    entry_counts[_type] = entry_counts[_type] - 1
end

--- Returns a new entry for the given entity with the given type.
--- @param entity Entity
--- @param _type Type
--- @return Entry
local function get_new_entry(entity, _type)
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
--- @param entity Entity
--- @param _type Type
function Register.add(entity, _type)
    _type = _type or get_entity_type(entity)
    if _type == Type.null then
        return
    end

    local entry = get_new_entry(entity, _type)

    add_entry_to_register(entry)

    init_custom_building(entry)
    add_subentities(entry)
    establish_new_neighbor(entry)
    on_creation(_type, entry)

    return entry
end
local add_entity = Register.add

--- Adds the given destination entity to the register with the same type as the source entry and copies the relevant entry data.
--- @param source Entry
--- @param destination Entity
function Register.clone(source, destination)
    local _type = source[EK.type]
    local destination_entry = add_entity(destination, _type)
    destination_entry[EK.tick_of_creation] = source[EK.tick_of_creation]

    on_copy(_type, source, destination)
end

--- Removes the given entry from the register.
--- @param entry Entry
function Register.remove_entry(entry, cause)
    local _type = entry[EK.type]

    destroy_custom_building(entry)
    on_destruction(_type, entry, cause)
    remove_subentities(entry)
    unsubscribe_neighborhood(entry)

    remove_entry_from_register(entry)
end
local remove_entry = Register.remove_entry

--- Removes the given entity from the register.
--- @param entity Entity
function Register.remove_entity(entity, unit_number, cause)
    unit_number = unit_number or entity.unit_number

    local entry = register[unit_number]
    if entry then
        remove_entry(entry, cause)
    end
end

--- Reregisters the entity with the given type.
--- @param entry Entry
--- @param new_type Type
function Register.change_type(entry, new_type)
    remove_entry(entry, DeconstructionCause.type_change)

    -- remove the sprites explicitly, because normally they get destroyed when the entity is destroyed
    Subentities.remove_sprites(entry)

    local new_entry = add_entity(entry[EK.entity], new_type)
    new_entry[EK.tick_of_creation] = entry[EK.tick_of_creation]

    Gui.rebuild_details_view_for_entry(entry)
end

--- Tries to get the entry with the given unit_number if exists and is still valid.
--- @param unit_number integer
--- @return Entry|nil
function Register.try_get(unit_number)
    local entry = register[unit_number]

    if entry then
        if entry[EK.entity].valid then
            return entry
        else
            remove_entry(entry)
        end
    end
end
local try_get = Register.try_get

--- Returns the next valid entry or nil if the loop came to an end.
local function register_next(unit_number)
    local entry
    unit_number, entry = next(register, unit_number)

    if not entry then
        return nil
    end

    if entry[EK.entity].valid then
        return unit_number, entry
    else
        remove_entry(entry)
        return register_next(unit_number)
    end
end
Register.next = register_next

function Register.entity_update_cycle(current_tick)
    local next_entry = Register.next
    local count = 0
    local index = global.last_index
    local current_entry = try_get(index)
    local number_of_checks = global.updates_per_cycle

    if not current_entry then
        index, current_entry = next_entry() -- begin a new loop at the start (nil as a key returns the first pair)
    end

    while index and count < number_of_checks do
        update_custom_building(current_entry)
        on_update(current_entry, current_tick)
        current_entry[EK.last_update] = current_tick

        index, current_entry = next_entry(index)
        count = count + 1
    end
    global.last_index = index
end

local function nothing()
end

local function all_of_type_iterator(type_table, key)
    key = next(type_table, key)

    if key == nil then
        return nil, nil
    end

    local entry = try_get(key)
    if entry then
        return key, entry
    else
        return all_of_type_iterator(type_table, key)
    end
end

--- Iterator for all entries of a specific type
--- @param _type Type
function Register.all_of_type(_type)
    local tbl = register_by_type[_type]
    if not tbl then
        return nothing
    end

    return all_of_type_iterator, tbl
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
