Register = {}

local global
local register
local register_by_type
local entry_counts

local establish_house

local add_subentities

local get_entity_type = Types.get_entity_type
local is_inhabited = Types.is_inhabited

local add_neighborhood
local establish_new_neighbor

local function set_locals()
    global = _ENV.global
    register = global.register
    register_by_type = global.register_by_type
    entry_counts = global.entry_counts

    establish_house = Inhabitants.establish_house
    add_subentities = Subentities.add_all_for

    add_neighborhood = Neighborhood.add_neighborhood
    establish_new_neighbor = Neighborhood.establish_new_neighbor
end
---------------------------------------------------------------------------------------------------
-- << register system >>
local function new_entry(entity, _type, unit_number)
    local current_tick = game.tick

    local entry = {
        [EntryKey.type] = _type,
        [EntryKey.entity] = entity,
        [EntryKey.last_update] = current_tick,
        [EntryKey.subentities] = {}
    }

    add_subentities(entry)
    add_neighborhood(entry, _type)
    establish_new_neighbor(entry, _type)

    if is_inhabited(_type) then
        establish_house(_type, entry, unit_number)
    end
    if _type == Type.orangery then
        entry[EntryKey.tick_of_creation] = current_tick
    end
    if _type == Type.water_distributer then
        entry[EntryKey.water_quality] = 0
    end

    return entry
end

local function add_entry_to_register(entry, unit_number)
    register[unit_number] = entry

    local _type = entry[EntryKey.type]
    if not register_by_type[_type] then
        register_by_type[_type] = {}
    end
    register_by_type[_type][unit_number] = unit_number

    -- keeping track on the number of entries of this type
    if not entry_counts[_type] then
        entry_counts[_type] = 0
    end
    entry_counts[_type] = entry_counts[_type] + 1
end

--- Adds the given entity to the register. Optionally the type can be specified.
--- @param entity Entity
--- @param _type Type
function Register.add(entity, _type)
    _type = _type or get_entity_type(entity)
    local unit_number = entity.unit_number
    local entry = new_entry(entity, _type, unit_number)

    add_entry_to_register(entry, unit_number)

    return entry
end
local add_entity = Register.add

--- Adds the given destination entity to the register with the same type as the source entry and copies the relevant entry data.
--- @param source Entry
--- @param destination Entity
function Register.clone(source, destination)
    local _type = source[EntryKey.type]
    local destination_entry = add_entity(destination, _type)

    -- Copy special entry data for some types
    if is_inhabited(_type) then
        Inhabitants.clone_inhabitants(source, destination_entry)
    elseif _type == Type.orangery then
        destination_entry[EntryKey.tick_of_creation] = source[EntryKey.tick_of_creation]
    end
end

local function remove_entry(entry, unit_number)
    local _type = entry[EntryKey.type]
    register[unit_number] = nil
    register_by_type[_type][unit_number] = nil

    Subentities.remove_all_for(entry)

    entry_counts[_type] = entry_counts[_type] - 1
end

--- Removes the given entity from the register.
--- @param entity Entity
function Register.remove_entity(entity, unit_number)
    unit_number = unit_number or entity.unit_number
    local entry = register[unit_number]
    local entity_type = (entry and entry[EntryKey.type]) or get_entity_type(entity)

    if entry then
        if Types.is_inhabited(entity_type) then
            Inhabitants.remove_house(entry, unit_number)
        end

        remove_entry(entry, unit_number)
    end
end
local remove_entity = Register.remove_entity

--- Removes the given entry from the register.
--- @param entry Entry
function Register.remove_entry(entry)
    remove_entity(entry[EntryKey.entity])
end

--- Reregisters the entity with the given type.
--- @param entry Entry
-- -@param new_type Type
function Register.change_type(entry, new_type)
    Register.remove_entry(entry)
    Register.add(entry[EntryKey.entity], new_type)
    Gui.rebuild_details_view_for_entry(entry)
end

--- Tries to get the entry with the given unit_number if exists and is still valid.
--- @param unit_number number
--- @return Entry|nil
function Register.try_get(unit_number)
    local entry = register[unit_number]

    if entry then
        if entry[EntryKey.entity].valid then
            return entry
        else
            Register.remove_entity(entry[EntryKey.entity])
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

    if entry[EntryKey.entity].valid then
        return unit_number, entry
    else
        Register.remove_entity(entry[EntryKey.entity], unit_number)
        return register_next(unit_number)
    end
end
Register.next = register_next

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

local types_affected_by_clockwork = Types.types_affected_by_clockwork

--- Returns the number of existing entries of the given type.
function Register.get_type_count(_type)
    return entry_counts[_type] or 0
end
local get_type_count = Register.get_type_count

--- Returns the number of existing entries that are affected by clockwork bonuses.
function Register.get_machine_count()
    local ret = 0

    for i = 1, #types_affected_by_clockwork do
        ret = ret + get_type_count(types_affected_by_clockwork[i])
    end

    return ret
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
            local _type = get_entity_type(entity)

            if Types.is_relevant_to_register(_type) then
                add_entity(entity)
            end
        end
    end
end

--- Sets local references during on_load
function Register.load()
    set_locals()
end

return Register
