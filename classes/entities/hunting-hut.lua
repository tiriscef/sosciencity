local Comb = require("enums.performance-combination")
local Dim = require("enums.performance-dimension")
local EK = require("enums.entry-key")
local PE = require("enums.performance-effect")
local PK = require("enums.performance-key")
local Type = require("enums.type")

local Buildings = require("constants.buildings")

local get_building_details = Buildings.get
local evaluate_workforce = Inhabitants.evaluate_workforce
local evaluate_worker_happiness = Inhabitants.evaluate_worker_happiness
local set_crafting_machine_performance = Entity.set_crafting_machine_performance
local Utils = Tirislib.Utils
local min = math.min

local function get_tree_count(entry, building_details)
    local cached_value = entry[EK.tree_count]
    if not cached_value or storage.last_entity_update > entry[EK.last_update] then
        local entity = entry[EK.entity]
        local position = entity.position
        local area = Utils.get_range_bounding_box(position, building_details.range)
        local trees = entity.surface.count_entities_filtered {area = area, type = "tree"}

        entry[EK.tree_count] = trees
        return trees
    else
        return cached_value
    end
end

local different_recipe_weight = 0.3

local function get_hunting_competition(entry)
    local recipe = entry[EK.entity].get_recipe()
    local recipe_name = recipe and recipe.name

    local same_count = 0
    local other_count = 0

    for _, neighbor_entry in Neighborhood.iterate_type(entry, Type.hunting_hut) do
        local neighbor_recipe = neighbor_entry[EK.entity].get_recipe()
        if neighbor_recipe then
            if recipe_name and neighbor_recipe.name == recipe_name then
                same_count = same_count + 1
            else
                other_count = other_count + 1
            end
        end
    end

    local effective_count = same_count + different_recipe_weight * other_count
    return (effective_count + 1) ^ (-0.35), same_count, other_count
end
Entity.get_hunting_competition = get_hunting_competition

local function update_hunting_hut(entry)
    local worker_performance = evaluate_workforce(entry)
    local worker_happiness = evaluate_worker_happiness(entry)

    local building_details = get_building_details(entry)
    local tree_count = get_tree_count(entry, building_details)
    entry[EK.tree_count] = tree_count
    local forest_performance = tree_count / building_details.tree_count

    local competition, same_count, other_count = get_hunting_competition(entry)

    local performance = min(worker_performance, forest_performance) * competition * worker_happiness
    set_crafting_machine_performance(entry, performance)

    entry[EK.performance_report] = {
        [PK.effects] = {
            {
                [PK.effect] = PE.workforce,
                [PK.value] = worker_performance,
                [PK.dimension] = Dim.speed,
                [PK.combination] = Comb.bottleneck
            },
            {
                [PK.effect] = PE.trees,
                [PK.value] = forest_performance,
                [PK.dimension] = Dim.speed,
                [PK.combination] = Comb.bottleneck,
                [PK.detail] = {
                    "sosciencity.value-with-unit",
                    {"sosciencity.fraction", tree_count, building_details.tree_count},
                    {"sosciencity.trees"}
                }
            },
            {
                [PK.effect] = PE.hunting_competition,
                [PK.value] = competition,
                [PK.dimension] = Dim.speed,
                [PK.combination] = Comb.multiplier,
                [PK.detail] = {"sosciencity.show-hunting-competition-count", same_count, other_count}
            },
            {
                [PK.effect] = PE.worker_happiness,
                [PK.value] = worker_happiness,
                [PK.dimension] = Dim.speed,
                [PK.combination] = Comb.multiplier
            }
        },
        [PK.results] = {
            [Dim.speed] = performance
        }
    }
end
Register.set_entity_updater(Type.hunting_hut, update_hunting_hut)

local function create_hunting_hut(entry)
    entry[EK.performance] = 1
    entry[EK.performance_report] = {[PK.effects] = {}, [PK.results] = {}}
end
Register.set_entity_creation_handler(Type.hunting_hut, create_hunting_hut)
