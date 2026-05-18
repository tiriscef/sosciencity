local Comb = require("enums.performance-combination")
local Dim = require("enums.performance-dimension")
local EK = require("enums.entry-key")
local PE = require("enums.performance-effect")
local PK = require("enums.performance-key")
local Type = require("enums.type")

local set_crafting_machine_performance = Entity.set_crafting_machine_performance
local create_active_machine_status = Entity.create_active_machine_status
local update_active_machine_status = Entity.update_active_machine_status
local remove_active_machine_status = Entity.remove_active_machine_status
local get_breakdown_state = Entity.get_breakdown_state
local set_active = Entity.set_active
local max = math.max

local function get_waterwell_competition_performance(entry)
    -- +1 so it counts itself too
    local near_count = Neighborhood.get_neighbor_count(entry, Type.waterwell) + 1
    return near_count ^ (-0.45), near_count - 1
end

local function get_clockwork_boost()
    return 1 + max(0, Entity.caste_bonuses[Type.clockwork]) / 100
end

local function update_waterwell(entry)
    local entity = entry[EK.entity]
    local recipe = entity.get_recipe()
    if recipe and recipe.name == "clean-water-from-ground"
        and not Inventories.assembler_has_module(entity, "water-filter") then
        set_crafting_machine_performance(entry, 0)
        return
    end

    local competition, _ = get_waterwell_competition_performance(entry)
    set_crafting_machine_performance(entry, competition * get_clockwork_boost())

    if get_breakdown_state(entry) then
        set_active(entry, false, Entity.broken_status)
    end

    update_active_machine_status(entry)
end
Register.set_entity_updater(Type.waterwell, update_waterwell)

local function build_waterwell_report(entry)
    local entity = entry[EK.entity]
    local recipe = entity.get_recipe()
    if recipe and recipe.name == "clean-water-from-ground"
        and not Inventories.assembler_has_module(entity, "water-filter") then
        return {[PK.effects] = {}, [PK.results] = {}}
    end

    local competition, near_count = get_waterwell_competition_performance(entry)
    local boost = get_clockwork_boost()

    return {
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
                [PK.value] = boost,
                [PK.dimension] = Dim.speed,
                [PK.combination] = Comb.multiplier
            }
        },
        [PK.results] = {[Dim.speed] = competition * boost}
    }
end
Entity.set_performance_report_builder(Type.waterwell, build_waterwell_report)

local function create_waterwell(entry)
    entry[EK.performance] = 1
    create_active_machine_status(entry)
end
Register.set_entity_creation_handler(Type.waterwell, create_waterwell)

Register.set_entity_destruction_handler(Type.waterwell, remove_active_machine_status)
