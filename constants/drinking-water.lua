--- Things that people like (and need) to drink.
local DrinkingWater = {}

--- @class DrinkingWaterDefinition
--- @field name string internal fluid name
--- @field localised_name LocalisedString
--- @field localised_description LocalisedString
--- @field healthiness number health effect of drinking this water; negative values harm health
--- @field contamination number multiplier on the waterborne disease rate; 0 is safe, 1 is untreated water

DrinkingWater.values = {
    ["clean-water"] = {
        healthiness = 2,
        contamination = 0
    },
    ["drinkable-water"] = {
        healthiness = 0.5,
        contamination = 0.05
    },
    ["water"] = {
        healthiness = -5,
        contamination = 1
    },
    ["mechanically-cleaned-water"] = {
        healthiness = -3,
        contamination = 0.5
    },
    ["biologically-cleaned-water"] = {
        healthiness = -1,
        contamination = 0.2
    },
    ["ultra-pure-water"] = {
        healthiness = -2,
        contamination = 0
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
