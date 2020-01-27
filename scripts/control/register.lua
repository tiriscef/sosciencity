Register = {}

local global
local register
local register_by_type

---------------------------------------------------------------------------------------------------
-- << register system >>
local function new_entry(entity, _type)
    local entry = {
        [TYPE] = _type,
        [ENTITY] = entity,
        [LAST_UPDATE] = game.tick,
        [SUBENTITIES] = {}
    }

    Subentities.add_all_for(entry)
    Neighborhood.add_neighborhood(entry, _type)
    Neighborhood.establish_new_neighbor(entry, _type)

    if Types.is_inhabited(_type) then
        Inhabitants.add_inhabitants_data(entry)
    end
    if _type == TYPE_ORANGERY then
        entry[TICK_OF_CREATION] = game.tick
    end

    return entry
end

local function add_entity_to_register(entity, _type)
    local entry = new_entry(entity, _type)
    local unit_number = entity.unit_number
    register[unit_number] = entry

    if not register_by_type[_type] then
        register_by_type[_type] = {}
    end
    register_by_type[_type][unit_number] = unit_number
end

--- Adds the given entity to the register. Optionally the type can be specified.
--- @param entity Entity
--- @param _type Type
function Register.add(entity, _type)
    _type = _type or Types(entity)

    if Types.is_relevant_to_register(_type) then
        add_entity_to_register(entity, _type)
    end

    if Types.is_affected_by_clockwork(_type) then
        global.machine_count = global.machine_count + 1
    end
    if _type == TYPE_TURRET and entity.force.name ~= "enemy" then
        global.turret_count = global.turret_count + 1
    end
end

local function remove_entry(entry, unit_number)
    register[unit_number] = nil
    register_by_type[entry[TYPE]][unit_number] = nil

    Subentities.remove_all_for(entry)
end

--- Removes the given entity from the register.
--- @param entity Entity
function Register.remove_entity(entity, unit_number)
    unit_number = unit_number or entity.unit_number
    local entry = register[unit_number]
    local entity_type = entry and entry[TYPE] or Types.get_entity_type(entity)

    if entry then
        if Types.is_inhabited(entity_type) then
            Inhabitants.remove_house(entry)
        end

        remove_entry(entry, unit_number)
    end

    if entity_type == TYPE_MINING_DRILL then
        global.machine_count = global.machine_count - 1
    end
    if Types.is_affected_by_clockwork(entity_type) then
        global.machine_count = global.machine_count - 1
    end
    if entity_type == TYPE_TURRET and entity.force.name ~= "enemy" then
        global.turret_count = global.turret_count - 1
    end
end
local remove_entity = Register.remove_entity

--- Removes the given entry from the register.
--- @param entry Entry
function Register.remove_entry(entry)
    remove_entity(entry[ENTITY])
end

--- Reregisters the entity with the given type.
--- @param entry Entry
-- -@param new_type Type
function Register.change_type(entry, new_type)
    Register.remove_entry(entry)
    Register.add(entry[ENTITY], new_type)
    Gui.rebuild_details_view_for_entry(entry)
end

--- Tries to get the entry with the given unit_number if exists and is still valid.
--- @param unit_number number
--- @return Entry|nil
function Register.try_get(unit_number)
    local entry = register[unit_number]

    if entry then
        if entry[ENTITY].valid then
            return entry
        else
            Register.remove_entity(entry[ENTITY])
        end
    end
end

local register_next
--- Returns the next valid entry or nil if the loop came to an end.
function Register.next(unit_number)
    local entry
    unit_number, entry = next(register, unit_number)

    if not entry then
        return nil
    end

    if entry[ENTITY].valid then
        return unit_number, entry
    else
        Register.remove_entity(entry[ENTITY], unit_number)
        return register_next(unit_number)
    end
end
register_next = Register.next

local function nothing()
end

--- Iterator for all entries of a specific type
--- @param _type Type
function Register.all_of_type(_type)
    if not register_by_type[_type] then
        return nothing
    end

    local index, entry

    local function _next()
        index, entry = next(register_by_type[_type], index)

        if index then
            return index, register[index]
        end
    end

    return _next, index, entry
end

local function set_locals()
    global = _ENV.global
    register = global.register
    register_by_type = global.register_by_type
end

--- Initialize the register related contents of global.
function Register.init()
    global = _ENV.global
    global.register = {}
    global.register_by_type = {}
    set_locals()

    global.machine_count = 0
    global.turret_count = 0

    -- find and register all the machines that need to be registered
    for _, surface in pairs(game.surfaces) do
        for _, entity in pairs(
            surface.find_entities_filtered {
                type = {
                    "assembling-machine",
                    "rocket-silo",
                    "furnace",
                    "turret",
                    "ammo-turret",
                    "electric-turret",
                    "fluid-turret",
                    "mining-drill"
                },
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

return Register
