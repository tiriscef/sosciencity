Register = {}

---------------------------------------------------------------------------------------------------
-- << register system >>
--[[local function add_housing_data(entry)
    -- TODO
    entry.happiness = 0
    entry.healthiness = 0
    entry.healthiness_mental = 0
    entry.inhabitants = 0
    entry.trend = 0
end]]

local function new_entry(entity, _type)
    local entry = {
        entity = entity,
        type = _type,
        last_update = game.tick,
        subentities = {}
    }

    Subentities.add_all_for(entry)
    if Types.needs_neighborhood(_type) then
        Neighborhood.add_neighborhood_data(entry, _type)
    end

    return entry
end

local function add_entry(entity, _type)
    local entry = new_entry(entity, _type)
    local unit_number = entity.unit_number
    global.register[unit_number] = entry

    if not global.register_by_type[_type] then
        global.register_by_type[_type] = {}
    end
    global.register_by_type[_type][unit_number] = unit_number
end

function Register.add(entity, _type)
    _type = _type or Types(entity)

    if Types.is_relevant_to_register(_type) then
        add_entry(entity, _type)
    end

    if _type == TYPE_MINING_DRILL then
        global.machine_count = global.machine_count + 1
    end
    if Types.is_affected_by_clockwork(_type) then
        global.machine_count = global.machine_count + 1
    end
    if _type == TYPE_TURRET and entity.force.name ~= "enemy" then
        global.turret_count = global.turret_count + 1
    end
end

local function remove_entry(entry)
    local unit_number = entry.entity.unit_number
    global.register[unit_number] = nil
    global.register_by_type[entry.type][unit_number] = nil

    Subentities.remove_all_for(entry)
end

function Register.remove_entity(entity)
    local entry = global.register[entity.unit_number]
    if entry then
        remove_entry(entry)
    end

    local entity_type = Types(entity)
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

function Register.remove_entry(entry)
    Register.remove_entity(entry.entity)
end

function Register.change_type(entry, new_type)
    Register.remove_entry(entry)
    Register.add(entry.entity, new_type)
end

function Register.try_get(unit_number)
    local entry = global.register[unit_number]

    if entry then
        if entry.entity.valid then
            return entry
        else
            Register.remove_entity(entry.entity)
        end
    end
end

-- Iterator for all entries of a specific type
function Register.all_of_type(_type)
    local index, entry

    local function _next()
        index, entry = next(global.register_by_type[_type], index)

        if index then
            return index, global.register[index]
        end
    end

    return _next, index, entry
end

function Register.init()
    global.register = {}
    global.register_by_type = {}

    global.machine_count = 0
    global.turret_count = 0

    for _, surface in pairs(game.surfaces) do
        -- find and register all the machines
        for _, entity in pairs(
            surface.find_entities_filtered {
                type = {
                    "assembling-machine",
                    "rocket-silo",
                    "furnace"
                }
            }
        ) do
            global.machine_count = global.machine_count + 1
            Register.add(entity)
        end

        -- count the mining drills
        global.machine_count = global.machine_count + surface.count_entities_filtered {type = "mining-drill"}

        -- count the turrets
        global.turret_count =
            global.turret_count +
            surface.count_entities_filtered {
                type = {
                    "turret",
                    "ammo-turret",
                    "electric-turret",
                    "fluid-turret"
                },
                force = "player"
            }
    end
end

return Register
