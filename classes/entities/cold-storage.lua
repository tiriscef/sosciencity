local EK = require("enums.entry-key")
local Type = require("enums.type")

local Buildings = require("constants.buildings")

local get_building_details = Buildings.get
local get_chest_inventory = Inventories.get_chest_inventory
local check_is_active = Entity.check_is_active

local function update_cold_storage(entry, delta_ticks)
    local definition = get_building_details(entry)
    local inventory = get_chest_inventory(entry)

    local active = check_is_active(entry)
    entry[EK.active] = active

    if not active then
        return
    end

    Entity.delay_food_spoilage(inventory, delta_ticks, definition.spoil_slowdown)
end
Register.set_entity_updater(Type.cold_storage, update_cold_storage)
