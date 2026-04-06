local EK = require("enums.entry-key")
local Type = require("enums.type")

local Buildings = require("constants.buildings")

local get_building_details = Buildings.get
local evaluate_workforce = Inhabitants.evaluate_workforce
local set_crafting_machine_performance = Entity.set_crafting_machine_performance
local Utils = Tirislib.Utils
local min = math.min

local function get_water_tiles(entry, building_details)
    local cached_value = entry[EK.water_tiles]
    if not cached_value or storage.last_tile_update > entry[EK.last_update] then
        local entity = entry[EK.entity]
        local position = entity.position
        local area = Utils.get_range_bounding_box(position, building_details.range)
        local water_tiles = entity.surface.count_tiles_filtered {area = area, collision_mask = "water_tile"}

        entry[EK.water_tiles] = water_tiles
        return water_tiles
    else
        -- nothing could possibly have changed, return the cached value
        return cached_value
    end
end
Entity.get_water_tiles = get_water_tiles

local function get_fishing_competition(entry)
    local count = Neighborhood.get_neighbor_count(entry, Type.fishery)
    return (count + 1) ^ (-0.35), count
end
Entity.get_fishing_competition = get_fishing_competition

local function get_fishery_performance(entry)
    local worker_performance = evaluate_workforce(entry)

    local building_details = get_building_details(entry)
    local water_tiles = get_water_tiles(entry, building_details)
    local water_performance = water_tiles / building_details.water_tiles

    local neighborhood_performance = get_fishing_competition(entry)

    return min(worker_performance, water_performance) * neighborhood_performance
end

local function update_fishery(entry)
    local performance = get_fishery_performance(entry)
    set_crafting_machine_performance(entry, performance)
end
Register.set_entity_updater(Type.fishery, update_fishery)

local function create_fishery(entry)
    entry[EK.performance] = 1
end
Register.set_entity_creation_handler(Type.fishery, create_fishery)
