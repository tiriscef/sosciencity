local Comb = require("enums.performance-combination")
local Dim = require("enums.performance-dimension")
local EK = require("enums.entry-key")
local PE = require("enums.performance-effect")
local PK = require("enums.performance-key")
local Type = require("enums.type")

local Buildings = require("constants.buildings")

local get_building_details = Buildings.get
local set_crafting_machine_performance = Entity.set_crafting_machine_performance
local get_water_tiles = Entity.get_water_tiles
local map_range = Tirislib.Utils.map_range

local function update_salt_pond(entry)
    local building_details = get_building_details(entry)
    local water_tiles = get_water_tiles(entry, building_details)
    set_crafting_machine_performance(entry, map_range(water_tiles, 0, building_details.water_tiles, 0, 1))
end
Register.set_entity_updater(Type.salt_pond, update_salt_pond)

local function build_salt_pond_report(entry)
    local building_details = get_building_details(entry)
    local water_tiles = entry[EK.water_tiles] or 0
    local water_performance = map_range(water_tiles, 0, building_details.water_tiles, 0, 1)

    return {
        [PK.effects] = {
            {
                [PK.effect] = PE.water_tiles,
                [PK.value] = water_performance,
                [PK.dimension] = Dim.speed,
                [PK.combination] = Comb.bottleneck,
                [PK.detail] = {
                    "sosciencity.value-with-unit",
                    {"sosciencity.fraction", water_tiles, building_details.water_tiles},
                    {"sosciencity.tiles"}
                }
            }
        },
        [PK.results] = {[Dim.speed] = water_performance}
    }
end
Entity.set_performance_report_builder(Type.salt_pond, build_salt_pond_report)

local function create_salt_pond(entry)
    entry[EK.performance] = 1
end
Register.set_entity_creation_handler(Type.salt_pond, create_salt_pond)
