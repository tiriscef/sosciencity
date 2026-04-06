local EK = require("enums.entry-key")
local Type = require("enums.type")

local set_crafting_machine_performance = Entity.set_crafting_machine_performance
local get_maintenance_performance = Entity.get_maintenance_performance
local create_active_machine_status = Entity.create_active_machine_status
local update_active_machine_status = Entity.update_active_machine_status
local remove_active_machine_status = Entity.remove_active_machine_status
local min = math.min

local function get_waterwell_competition_performance(entry)
    -- +1 so it counts itself too
    local near_count = Neighborhood.get_neighbor_count(entry, Type.waterwell) + 1
    return near_count ^ (-0.45)
end

Entity.get_waterwell_competition_performance = get_waterwell_competition_performance

local function update_waterwell(entry)
    local entity = entry[EK.entity]
    local recipe = entity.get_recipe()
    if
        recipe and recipe.name == "clean-water-from-ground" and
        not Inventories.assembler_has_module(entity, "water-filter")
    then
        set_crafting_machine_performance(entry, 0)
        return
    end

    local performance = min(get_waterwell_competition_performance(entry), get_maintenance_performance())
    set_crafting_machine_performance(entry, performance)
    update_active_machine_status(entry)
end
Register.set_entity_updater(Type.waterwell, update_waterwell)

local function create_waterwell(entry)
    entry[EK.performance] = 1
    create_active_machine_status(entry)
end
Register.set_entity_creation_handler(Type.waterwell, create_waterwell)

Register.set_entity_destruction_handler(Type.waterwell, remove_active_machine_status)
