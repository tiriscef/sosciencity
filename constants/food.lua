require("constants.types")

--[[
    fat, carbohydrates and proteins are in g per 100g
    portion_size is in kg
]]
Food = {}

Food.values = {
    ["alien-meat"] = {
        fat = 17,
        carbohydrates = 1,
        proteins = 21,
        healthiness = 3,
        food_category = "meat",
        taste_category = TASTE_SALTY,
        taste_quality = 5,
        luxury = 4,
        portion_size = 10,
        group = "biter-meat"
    },
    ["unnamed-fruit"] = {
        fat = 1,
        carbohydrates = 10,
        proteins = 3,
        healthiness = 7,
        food_category = "alien-vegetable",
        taste_category = TASTE_NEUTRAL,
        taste_quality = 2,
        luxury = 1,
        portion_size = 50,
        group = "unnamed-fruit"
    },
    ["potato"] = {
        fat = 0.5,
        carbohydrates = 17,
        proteins = 2,
        healthiness = 5,
        food_category = "vegetable",
        taste_category = TASTE_UMAMI,
        taste_quality = 3,
        luxury = 3,
        portion_size = 50,
        group = "potato"
    },
    ["tomato"] = {
        fat = 0.33,
        carbohydrates = 4,
        proteins = 1.5,
        healthiness = 5,
        food_category = "vegetable",
        taste_category = TASTE_UMAMI,
        taste_quality = 6,
        luxury = 4,
        portion_size = 50,
        group = "tomato"
    },
    ["eggplant"] = {
        fat = 0.33,
        carbohydrates = 4,
        proteins = 1.5,
        healthiness = 6,
        food_category = "vegetable",
        taste_category = TASTE_UMAMI,
        taste_quality = 6,
        luxury = 4,
        portion_size = 50,
        group = "eggplant"
    }
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
    return Food.values[item]
end

setmetatable(Food, meta)
