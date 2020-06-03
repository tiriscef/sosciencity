require("constants.enums")

--- Things that people like (and need) to eat.
Food = {}

--fat, carbohydrates and proteins are in g per 100g
--portion_size is in kg
Food.values = {
    ["alien-meat"] = {
        fat = 17,
        carbohydrates = 1,
        proteins = 21,
        healthiness = 3,
        food_category = "meat",
        taste_category = Taste.salty,
        taste_quality = 5,
        luxury = 4,
        portion_size = 10,
        group = "biter-meat"
    },
    ["unnamed-fruit"] = {
        fat = 1,
        carbohydrates = 10,
        proteins = 3,
        healthiness = 8,
        food_category = "alien-vegetable",
        taste_category = Taste.neutral,
        taste_quality = 2,
        luxury = 1,
        portion_size = 50,
        group = "unnamed-fruit"
    },
    ["brutal-pumpkin"] = {
        fat = 0.6,
        carbohydrates = 6.9,
        proteins = 0.6,
        healthiness = 6,
        food_category = "alien-vegetable",
        taste_category = Taste.umami,
        taste_quality = 4,
        luxury = 2,
        portion_size = 50,
        group = "brutal-pumpkin"
    },
    ["blue-grapes"] = {
        fat = 0.3,
        carbohydrates = 17,
        proteins = 0.6,
        healthiness = 6,
        food_category = "fruit",
        taste_category = Taste.sweet,
        taste_quality = 7,
        luxury = 5,
        portion_size = 50,
        group = "grapes"
    },
    ["cherry"] = {
        fat = 0.4,
        carbohydrates = 12,
        proteins = 1,
        healthiness = 7,
        food_category = "fruit",
        taste_category = Taste.sweet,
        taste_quality = 7,
        luxury = 4,
        portion_size = 50,
        group = "cherry"
    },
    ["olive"] = {
        fat = 11,
        carbohydrates = 6,
        proteins = 0.8,
        healthiness = 7,
        food_category = "fruit",
        taste_category = Taste.salty,
        taste_quality = 7,
        luxury = 6,
        portion_size = 50,
        group = "olive"
    },
    ["bell-pepper"] = {
        fat = 0.2,
        carbohydrates = 8,
        proteins = 2,
        healthiness = 6,
        food_category = "vegetable",
        taste_category = Taste.spicy,
        taste_quality = 7,
        luxury = 4,
        portion_size = 50,
        group = "bell-pepper"
    },
    ["potato"] = {
        fat = 0.5,
        carbohydrates = 17,
        proteins = 2,
        healthiness = 5,
        food_category = "vegetable",
        taste_category = Taste.umami,
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
        taste_category = Taste.umami,
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
        taste_category = Taste.umami,
        taste_quality = 6,
        luxury = 4,
        portion_size = 50,
        group = "eggplant"
    },
    ["fawoxylas"] = {
        fat = 0.5,
        carbohydrates = 3.5,
        proteins = 3.3,
        healthiness = 7,
        food_category = "alien-fungus",
        taste_category = Taste.umami,
        taste_quality = 6,
        luxury = 6,
        portion_size = 50,
        group = "fawoxylas"
    },
    ["avocado"] = {
        fat = 15,
        carbohydrates = 9,
        proteins = 2,
        healthiness = 8,
        food_category = "vegetable",
        taste_category = Taste.neutral,
        taste_quality = 8,
        luxury = 8,
        portion_size = 50,
        group = "avocado"
    }
}

Food.taste_names = {
    [Taste.bitter] = "bitter",
    [Taste.neutral] = "neutral",
    [Taste.salty] = "salty",
    [Taste.sour] = "sour",
    [Taste.spicy] = "spicy",
    [Taste.sweet] = "sweet",
    [Taste.umami] = "umami"
}

local energy_density_fat = 9 -- kcal per g
local energy_density_carbohydrates = 4
local energy_density_proteins = 3.7

-- values postprocessing
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
