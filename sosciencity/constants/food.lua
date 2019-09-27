require("constants.types")

--[[
    fat, carbohydrates and proteins are in g per 100g
    one item is a portion of 10kg
]]
food_values = {
--[[    ["oats"] = {
        fat = 7,
        carbohydrates = 63,
        proteins = 13,
        healthiness = 1,
        food_category = "organic",
        taste_category = TASTE_NEUTRAL,
        taste_quality = 1,
        luxority = 0
    },]]
}

local energy_density_fat = 900 -- kcal per g
local energy_density_carbohydrates = 400
local energy_density_proteins = 370


for _, food in pairs(food_values) do
    -- convert nutrients from g per 100g to kcal per 100g
    food.fat = food.fat * energy_density_fat
    food.carbohydrates = food.carbohydrates * energy_density_carbohydrates
    food.proteins = food.proteins * energy_density_proteins

    -- calories specifies the calorific value of one item
    food.calories = (food.fat + food.carbohydrates + food.proteins) * 100
end
