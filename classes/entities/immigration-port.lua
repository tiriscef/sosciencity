local EK = require("enums.entry-key")
local Type = require("enums.type")

local Buildings = require("constants.buildings")

local get_building_details = Buildings.get
local random = math.random

local function schedule_immigration_wave(entry, building_details)
    entry[EK.next_wave] =
        (entry[EK.next_wave] or game.tick) + building_details.interval + random(building_details.random_interval) - 1
end

local function create_immigration_port(entry)
    schedule_immigration_wave(entry, get_building_details(entry))
end
Register.set_entity_creation_handler(Type.immigration_port, create_immigration_port)

local function update_immigration_port(entry, _, current_tick)
    local tick_next_wave = entry[EK.next_wave]
    if current_tick >= tick_next_wave then
        local building_details = get_building_details(entry)
        if Inventories.try_remove_item_range(entry, building_details.materials) then
            Inhabitants.migration_wave(building_details)
        end

        schedule_immigration_wave(entry, building_details)
    end
end
Register.set_entity_updater(Type.immigration_port, update_immigration_port)
