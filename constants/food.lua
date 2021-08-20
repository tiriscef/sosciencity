require("constants.enums")

--- Things that people like (and need) to eat.
Food = {}

--fat, carbohydrates and proteins are in g per 100g
--portion_size is in kg
Food.values = {
    ["mammal-meat"] = {
        fat = 15,
        carbohydrates = 0.2,
        proteins = 19.6,
        healthiness = 4,
        food_category = "meat",
        taste_category = Taste.umami,
        taste_quality = 7,
        luxury = 7,
        portion_size = 10,
        group = "meat"
    },
    ["bird-meat"] = {
        fat = 14,
        carbohydrates = 0.1,
        proteins = 20.6,
        healthiness = 6,
        food_category = "meat",
        taste_category = Taste.neutral,
        taste_quality = 5,
        luxury = 6,
        portion_size = 10,
        group = "bird-meat"
    },
    ["insect-meat"] = {
        fat = 28.7,
        carbohydrates = 2.7,
        proteins = 53.2,
        healthiness = 6,
        food_category = "meat",
        taste_category = Taste.soily,
        taste_quality = 4,
        luxury = 3,
        portion_size = 10,
        group = "insect-meat"
    },
    ["fish-meat"] = {
        fat = 17,
        carbohydrates = 1,
        proteins = 21,
        healthiness = 3,
        food_category = "meat",
        taste_category = Taste.salty,
        taste_quality = 7,
        luxury = 5,
        portion_size = 10,
        group = "fish-meat"
    },
    ["biter-meat"] = {
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
    ["offal"] = {
        fat = 5.1,
        carbohydrates = 3.8,
        proteins = 26,
        healthiness = 7,
        food_category = "meat",
        taste_category = Taste.umami,
        taste_quality = 3,
        luxury = 6,
        portion_size = 10,
        group = "offal"
    },
    ["nan-egg"] = {
        fat = 13.8,
        carbohydrates = 2,
        proteins = 12.8,
        healthiness = 5,
        food_category = "egg",
        taste_category = Taste.umami,
        taste_quality = 6,
        luxury = 5,
        portion_size = 10,
        group = "egg"
    },
    ["primal-egg"] = {
        fat = 13.8,
        carbohydrates = 2,
        proteins = 12.8,
        healthiness = 6,
        food_category = "egg",
        taste_category = Taste.salty,
        taste_quality = 4,
        luxury = 3,
        portion_size = 10,
        group = "egg"
    },
    ["unnamed-fruit"] = {
        fat = 1,
        carbohydrates = 10,
        proteins = 3,
        healthiness = 8,
        food_category = "alien-fruit",
        taste_category = Taste.neutral,
        taste_quality = 2,
        luxury = 1,
        portion_size = 10,
        group = "unnamed-fruit"
    },
    ["weird-berry"] = {
        fat = 6.2,
        carbohydrates = 10,
        proteins = 3.2,
        healthiness = 2,
        food_category = "alien-fruit",
        taste_category = Taste.soily,
        taste_quality = 5,
        luxury = 1,
        portion_size = 10,
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
    ["ortrot-fruit"] = {
        fat = 0.2,
        carbohydrates = 7.4,
        proteins = 7.3,
        healthiness = 6,
        food_category = "alien-fruit",
        taste_category = Taste.weirdly_chemical,
        taste_quality = 2,
        luxury = 2,
        portion_size = 10,
        group = "ortrot"
    },
    ["apple"] = {
        fat = 1,
        carbohydrates = 14.4,
        proteins = 1.3,
        healthiness = 6,
        food_category = "fruit",
        taste_category = Taste.fruity,
        taste_quality = 7,
        luxury = 5,
        portion_size = 10,
        group = "apple"
    },
    ["blue-grapes"] = {
        fat = 0.3,
        carbohydrates = 17,
        proteins = 0.6,
        healthiness = 6,
        food_category = "alien-fruit",
        taste_category = Taste.fruity,
        taste_quality = 7,
        luxury = 5,
        portion_size = 10,
        group = "grapes"
    },
    ["orange"] = {
        fat = 0.1,
        carbohydrates = 25,
        proteins = 1.0,
        healthiness = 6,
        food_category = "fruit",
        taste_category = Taste.fruity,
        taste_quality = 7,
        luxury = 7,
        portion_size = 10,
        group = "orange"
    },
    ["lemon"] = {
        fat = 0.6,
        carbohydrates = 8.1,
        proteins = 0.8,
        healthiness = 6,
        food_category = "fruit",
        taste_category = Taste.acidic,
        taste_quality = 7,
        luxury = 7,
        portion_size = 10,
        group = "lemon"
    },
    ["zetorn"] = {
        fat = 1.2,
        carbohydrates = 15.4,
        proteins = 0.9,
        healthiness = 6,
        food_category = "alien-fruit",
        taste_category = Taste.fruity,
        taste_quality = 4,
        luxury = 3,
        portion_size = 10,
        group = "zetorn"
    },
    ["cherry"] = {
        fat = 0.4,
        carbohydrates = 12,
        proteins = 1,
        healthiness = 7,
        food_category = "fruit",
        taste_category = Taste.fruity,
        taste_quality = 7,
        luxury = 4,
        portion_size = 10,
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
        portion_size = 10,
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
        portion_size = 10,
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
        portion_size = 10,
        group = "potato"
    },
    ["sesame"] = {
        fat = 48,
        carbohydrates = 26,
        proteins = 17,
        healthiness = 7,
        food_category = "seed",
        taste_category = Taste.umami,
        taste_quality = 6,
        luxury = 7,
        portion_size = 2,
        group = "sesame"
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
        portion_size = 10,
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
        portion_size = 10,
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
        portion_size = 10,
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
        portion_size = 10,
        group = "avocado"
    },
    ["chickpea"] = {
        fat = 6,
        carbohydrates = 44,
        proteins = 19,
        healthiness = 7,
        food_category = "legume",
        taste_category = Taste.umami,
        taste_quality = 5,
        luxury = 5,
        portion_size = 10,
        group = "chickpea"
    },
    ["hummus"] = {
        fat = 10,
        carbohydrates = 14,
        proteins = 8,
        healthiness = 9,
        food_category = "processed",
        taste_category = Taste.spicy,
        taste_quality = 10,
        luxury = 5,
        portion_size = 10,
        group = "hummus"
    },
    ["dried-solfaen"] = {
        fat = 0.6,
        carbohydrates = 3.1,
        proteins = 5.9,
        healthiness = 7,
        food_category = "processed",
        taste_category = Taste.neutral,
        taste_quality = 2,
        luxury = 1,
        portion_size = 10,
        group = "algae"
    },
    ["razha-bean"] = { -- TODO values
        fat = 5.1,
        carbohydrates = 9.8,
        proteins = 11.2,
        healthiness = 6,
        food_category = "alien-legume",
        taste_category = Taste.umami,
        taste_quality = 5,
        luxury = 3,
        portion_size = 10,
        group = "razha-bean"
    },
    ["tofu"] = {
        fat = 4.8,
        carbohydrates = 1.9,
        proteins = 8.5,
        healthiness = 7,
        food_category = "processed",
        taste_category = Taste.neutral,
        taste_quality = 6,
        luxury = 5,
        portion_size = 10,
        group = "processed-razha"
    },
    ["yuba"] = {
        fat = 24.1,
        carbohydrates = 3.8,
        proteins = 52.3,
        healthiness = 7,
        food_category = "processed",
        taste_category = Taste.umami,
        taste_quality = 5,
        luxury = 4,
        portion_size = 2,
        group = "processed-razha"
    },
    ["liontooth"] = {
        fat = 0.7,
        carbohydrates = 2.4,
        proteins = 3.1,
        healthiness = 6,
        food_category = "alien-vegetable",
        taste_category = Taste.spicy,
        taste_quality = 4,
        luxury = 1,
        portion_size = 10,
        group = "liontooth"
    },
    ["manok"] = {
        fat = 0.3,
        carbohydrates = 23.1,
        proteins = 2.3,
        healthiness = 6,
        food_category = "alien-vegetable",
        taste_category = Taste.umami,
        taste_quality = 5,
        luxury = 5,
        portion_size = 10,
        group = "manok"
    },
    ["tello-fruit"] = {
        fat = 0.2,
        carbohydrates = 18.1,
        proteins = 1.7,
        healthiness = 2,
        food_category = "alien-vegetable",
        taste_category = Taste.fruity,
        taste_quality = 1,
        luxury = 1,
        portion_size = 10,
        group = "tello"
    },
    ["sugar-beet"] = {
        fat = 0.5,
        carbohydrates = 27.1,
        proteins = 1.0,
        healthiness = 4,
        food_category = "vegetable",
        taste_category = Taste.fruity,
        taste_quality = 4,
        luxury = 2,
        portion_size = 10,
        group = "sugar-beet"
    }
}

Food.taste_names = {
    [Taste.bitter] = {"taste-category.bitter"},
    [Taste.neutral] = {"taste-category.neutral"},
    [Taste.salty] = {"taste-category.salty"},
    [Taste.soily] = {"taste-category.soily"},
    [Taste.acidic] = {"taste-category.acidic"},
    [Taste.spicy] = {"taste-category.spicy"},
    [Taste.fruity] = {"taste-category.fruity"},
    [Taste.umami] = {"taste-category.umami"},
    [Taste.weirdly_chemical] = {"taste-category.weirdly-chemical"}
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
