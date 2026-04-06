local EK = require("enums.entry-key")
local Type = require("enums.type")

local Buildings = require("constants.buildings")

local get_building_details = Buildings.get
local set_crafting_machine_performance = Entity.set_crafting_machine_performance
local get_water_tiles = Entity.get_water_tiles
local map_range = Tirislib.Utils.map_range

local function update_salt_pond(entry)
    local building_details = get_building_details(entry)
    local water_tiles = get_water_tiles(entry, building_details)
    local water_performance = map_range(water_tiles, 0, building_details.water_tiles, 0, 1)
    set_crafting_machine_performance(entry, water_performance)
end
Register.set_entity_updater(Type.salt_pond, update_salt_pond)

local function create_salt_pond(entry)
    entry[EK.performance] = 1
end
Register.set_entity_creation_handler(Type.salt_pond, create_salt_pond)
