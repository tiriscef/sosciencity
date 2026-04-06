local EK = require("enums.entry-key")
local Type = require("enums.type")

local Buildings = require("constants.buildings")

local get_building_details = Buildings.get
local evaluate_workforce = Inhabitants.evaluate_workforce
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

local function get_hunting_competition(entry)
    local count = Neighborhood.get_neighbor_count(entry, Type.hunting_hut)
    return (count + 1) ^ (-0.35), count
end
Entity.get_hunting_competition = get_hunting_competition

local function get_hunting_hut_performance(entry)
    local worker_performance = evaluate_workforce(entry)

    local building_details = get_building_details(entry)
    local tree_count = get_tree_count(entry, building_details)
    entry[EK.tree_count] = tree_count
    local forest_performance = tree_count / building_details.tree_count

    local neighborhood_performance = get_hunting_competition(entry)

    return min(worker_performance, forest_performance) * neighborhood_performance
end

local function update_hunting_hut(entry)
    local performance = get_hunting_hut_performance(entry)
    set_crafting_machine_performance(entry, performance)
end
Register.set_entity_updater(Type.hunting_hut, update_hunting_hut)

local function create_hunting_hut(entry)
    entry[EK.performance] = 1
end
Register.set_entity_creation_handler(Type.hunting_hut, create_hunting_hut)
