--- Things that people like (and need) to drink.
local DrinkingWater = {}

DrinkingWater.values = {
    ["clean-water"] = {
        healthiness = 2
    },
    ["drinkable-water"] = {
        healthiness = 0.5
    },
    ["water"] = {
        healthiness = -5
    },
    ["mechanically-cleaned-water"] = {
        healthiness = -3
    },
    ["biologically-cleaned-water"] = {
        healthiness = -1
    },
    ["ultra-pure-water"] = {
        healthiness = -2
    }
}

for name, data in pairs(DrinkingWater.values) do
    data.name = name
end

if Tirislib.Utils.is_control_stage() then
    for water_name, water_data in pairs(DrinkingWater.values) do
        local prototype = prototypes.fluid[water_name]

        if not prototype then
            goto continue
        end

        water_data.localised_name = prototype.localised_name
        water_data.localised_description = prototype.localised_description

        ::continue::
    end
end

return DrinkingWater
