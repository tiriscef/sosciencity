local Comb = require("enums.performance-combination")
local Dim = require("enums.performance-dimension")
local EK = require("enums.entry-key")
local PE = require("enums.performance-effect")
local PK = require("enums.performance-key")
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
    return near_count ^ (-0.45), near_count - 1
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
        entry[EK.performance_report] = {[PK.effects] = {}, [PK.results] = {}}
        return
    end

    local competition, near_count = get_waterwell_competition_performance(entry)
    local maintenance = get_maintenance_performance()
    local performance = min(competition, maintenance)
    set_crafting_machine_performance(entry, performance)
    update_active_machine_status(entry)

    entry[EK.performance_report] = {
        [PK.effects] = {
            {
                [PK.effect] = PE.waterwell_competition,
                [PK.value] = competition,
                [PK.dimension] = Dim.speed,
                [PK.combination] = Comb.bottleneck,
                [PK.detail] = {"sosciencity.show-waterwell-competition-count", near_count}
            },
            {
                [PK.effect] = PE.maintenance,
                [PK.value] = maintenance,
                [PK.dimension] = Dim.speed,
                [PK.combination] = Comb.bottleneck
            }
        },
        [PK.results] = {
            [Dim.speed] = performance
        }
    }
end
Register.set_entity_updater(Type.waterwell, update_waterwell)

local function create_waterwell(entry)
    entry[EK.performance] = 1
    entry[EK.performance_report] = {[PK.effects] = {}, [PK.results] = {}}
    create_active_machine_status(entry)
end
Register.set_entity_creation_handler(Type.waterwell, create_waterwell)

Register.set_entity_destruction_handler(Type.waterwell, remove_active_machine_status)
