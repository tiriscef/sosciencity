local EK = require("enums.entry-key")
local Type = require("enums.type")

local DrinkingWater = require("constants.drinking-water")

local water_values = DrinkingWater.values
local is_active = Entity.check_is_active

local function update_water_distributer(entry)
    local entity = entry[EK.entity]

    -- determine and save the type of water that this distributer provides
    -- this is because it's unlikely to ever change (due to the system that prevents fluids from mixing)
    -- but needs to be checked often
    if is_active(entry) then
        for fluid_name in pairs(entity.get_fluid_contents()) do
            local water_data = water_values[fluid_name]
            if water_data then
                entry[EK.water_quality] = water_data.healthiness
                entry[EK.water_name] = fluid_name
                return
            end
        end
    end

    -- no water was found
    entry[EK.water_quality] = -1000
    entry[EK.water_name] = nil
end
Register.set_entity_updater(Type.water_distributer, update_water_distributer)

Register.set_entity_creation_handler(Type.water_distributer, update_water_distributer)
