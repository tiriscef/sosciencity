--[[
    fat, carbohydrates and proteins are in g per 100g
    one item is a portion of 10kg
]]
food_values = {
    ["oats"] = {
        fat = 7,
        carbohydrates = 63,
        proteins = 13,
        healthiness = 1,
        food_category = "organic",
        taste_category = "neutral",
        taste_quality = 1,
        luxority = 0
    },
    ["potato"] = {
        fat = 0.01,
        carbohydrates = 15,
        proteins = 1.9,
        healthiness = 1,
        food_category = "organic",
        taste_category = "umami",
        taste_quality = 1,
        luxority = 0
    },
    ["rice"] = {
        fat = 1,
        carbohydrates = 75,
        proteins = 9,
        healthiness = 1,
        food_category = "organic",
        taste_category = "umami",
        taste_quality = 1,
        luxority = 0
    },
    ["tomato"] = {
        fat = 0,
        carbohydrates = 300,
        proteins = 100,
        healthiness = 2,
        food_category = "organic",
        taste_category = "umami",
        taste_quality = 2,
        luxority = 1
    }
}

local energy_density_fat = 900 -- kcal per g
local energy_density_carbohydrates = 400
local energy_density_proteins = 370


for _, food in pairs(food_values) do
    -- convert nutrients from g to kcal
    food.fat = food.fat * energy_density_fat
    food.carbohydrates = food.carbohydrates * energy_density_carbohydrates
    food.proteins = food.proteins * energy_density_proteins

    -- calories specifies the calorific value of one item
    food.calories = (food.fat + food.carbohydrates + food.proteins) * 100
end
