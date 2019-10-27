require("constants.types")

--[[
    fat, carbohydrates and proteins are in g per 100g
    portion_size is in kg
]]
Food = {}

Food.values = {
    ["alien-meat"] = {
        fat = 17,
        carbohydrates = 0,
        proteins = 21,
        healthiness = 4,
        food_category = "meat",
        taste_category = TASTE_UMAMI,
        taste_quality = 5,
        luxury = 4,
        portion_size = 10
    },
}

local energy_density_fat = 9 -- kcal per g
local energy_density_carbohydrates = 4
local energy_density_proteins = 3.7

for _, food in pairs(Food.values) do
    -- convert nutrients from g per 100g to kcal per 100g
    food.fat = food.fat * energy_density_fat
    food.carbohydrates = food.carbohydrates * energy_density_carbohydrates
    food.proteins = food.proteins * energy_density_proteins

    -- calories specifies the calorific value of one item
    -- the magic 10 is just to get from 100g to 1kg
    food.calories = (food.fat + food.carbohydrates + food.proteins) * 10 * food.portion_size
end

local meta = {}

function meta:__call(item)
    return self.values[item]
end

setmetatable(Food, meta)
