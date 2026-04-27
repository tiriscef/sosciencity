local NutritionTag = require("enums.nutrition-tag")
local Taste = require("enums.taste")

--- Things that people like (and need) to eat.
local Food = {}

--- @class FoodDefinition
--- @field name string internal item name
--- @field localised_name LocalisedString
--- @field localised_description LocalisedString
--- @field fat number kcal per 100g from fat (converted from g/100g in postprocessing)
--- @field carbohydrates number kcal per 100g from carbohydrates (converted from g/100g in postprocessing)
--- @field proteins number kcal per 100g from proteins (converted from g/100g in postprocessing)
--- @field calories number total kcal per item (fat + carbohydrates + proteins) * 10 * item_weight
--- @field density number kcal per 100g independent of item_weight; used to weight item consumption rate
--- @field healthiness number intrinsic health quality of this food (1–10)
--- @field food_category string broad category (meat, egg, fruit, vegetable, legume, processed, alien-*, seed, etc.)
--- @field taste_category Taste taste profile of this food
--- @field appeal number overall desirability of this food (combining former taste quality and luxury) (1–10)
--- @field nutrition_tags table<NutritionTag, true> nutritional role flags
--- @field item_weight number kg per item; scales total calories per item — does not affect relative item consumption rate between foods
--- @field group string variety group; foods sharing a group count as one for variety purposes
--- @field max_spoil table<string, number> spoil ticks per quality level (set at runtime from prototype data)

-- fat, carbohydrates and proteins are in g per 100g
-- item_weight is in kg
Food.values = {
    ["mammal-meat"] = {
        fat = 15,
        carbohydrates = 0.2,
        proteins = 19.6,
        healthiness = 4,
        food_category = "meat",
        taste_category = Taste.umami,
        appeal = 7,
        nutrition_tags = {[NutritionTag.protein_rich] = true, [NutritionTag.fat_rich] = true},
        item_weight = 1,
        group = "meat"
    },
    ["bird-meat"] = {
        fat = 14,
        carbohydrates = 0.1,
        proteins = 20.6,
        healthiness = 6,
        food_category = "meat",
        taste_category = Taste.neutral,
        appeal = 6,
        nutrition_tags = {[NutritionTag.protein_rich] = true, [NutritionTag.fat_rich] = true},
        item_weight = 1,
        group = "bird-meat"
    },
    ["biter-meat"] = {
        fat = 17,
        carbohydrates = 1,
        proteins = 21,
        healthiness = 1,
        food_category = "meat",
        taste_category = Taste.salty,
        appeal = 4,
        nutrition_tags = {[NutritionTag.protein_rich] = true, [NutritionTag.fat_rich] = true},
        item_weight = 1,
        group = "biter-meat"
    },
    ["fermented-biter-meat"] = {
        fat = 13,
        carbohydrates = 0.7,
        proteins = 22,
        healthiness = 5,
        food_category = "meat",
        taste_category = Taste.acidic,
        appeal = 5,
        nutrition_tags = {[NutritionTag.protein_rich] = true},
        item_weight = 1,
        group = "biter-meat"
    },
    ["insect-meat"] = {
        fat = 28.7,
        carbohydrates = 2.7,
        proteins = 53.2,
        healthiness = 6,
        food_category = "meat",
        taste_category = Taste.soily,
        appeal = 4,
        nutrition_tags = {[NutritionTag.protein_rich] = true, [NutritionTag.fat_rich] = true},
        item_weight = 1,
        group = "insect-meat"
    },
    ["fish-meat"] = {
        fat = 13.6,
        carbohydrates = 0.6,
        proteins = 18.4,
        healthiness = 3,
        food_category = "meat",
        taste_category = Taste.salty,
        appeal = 6,
        nutrition_tags = {[NutritionTag.protein_rich] = true},
        item_weight = 1,
        group = "fish-meat"
    },
    ["offal"] = {
        fat = 5.1,
        carbohydrates = 3.8,
        proteins = 26,
        healthiness = 7,
        food_category = "meat",
        taste_category = Taste.umami,
        appeal = 5,
        nutrition_tags = {[NutritionTag.protein_rich] = true},
        item_weight = 1,
        group = "offal"
    },
    ["nan-egg"] = {
        fat = 13.8,
        carbohydrates = 2,
        proteins = 12.8,
        healthiness = 5,
        food_category = "egg",
        taste_category = Taste.sulfuric,
        appeal = 6,
        nutrition_tags = {[NutritionTag.protein_rich] = true, [NutritionTag.fat_rich] = true},
        item_weight = 1,
        group = "egg"
    },
    ["primal-egg"] = {
        fat = 14.8,
        carbohydrates = 0.9,
        proteins = 13.0,
        healthiness = 6,
        food_category = "egg",
        taste_category = Taste.sulfuric,
        appeal = 4,
        nutrition_tags = {[NutritionTag.protein_rich] = true, [NutritionTag.fat_rich] = true},
        item_weight = 1,
        group = "egg"
    },
    ["bone-egg"] = {
        fat = 10.4,
        carbohydrates = 3,
        proteins = 13.5,
        healthiness = 5,
        food_category = "egg",
        taste_category = Taste.sulfuric,
        appeal = 4,
        nutrition_tags = {[NutritionTag.protein_rich] = true},
        item_weight = 1,
        group = "egg"
    },
    ["wild-edible-plants"] = {
        fat = 1.1,
        carbohydrates = 8,
        proteins = 2.6,
        healthiness = 4,
        food_category = "alien-fruit",
        taste_category = Taste.varying,
        appeal = 2,
        nutrition_tags = {[NutritionTag.carb_rich] = true},
        item_weight = 2.2,
        group = "plant-mix"
    },
    ["wild-fungi"] = {
        fat = 0.7,
        carbohydrates = 2.4,
        proteins = 2.6,
        healthiness = 4,
        food_category = "alien-fungus",
        taste_category = Taste.varying,
        appeal = 3,
        nutrition_tags = {},
        item_weight = 3.8,
        group = "fungi-mix"
    },
    ["wild-algae"] = {
        fat = 1.9,
        carbohydrates = 5.8,
        proteins = 2.1,
        healthiness = 6,
        food_category = "alien-algae",
        taste_category = Taste.varying,
        appeal = 3,
        nutrition_tags = {[NutritionTag.carb_rich] = true},
        item_weight = 2,
        group = "algae-mix"
    },
    ["unnamed-fruit"] = {
        fat = 1,
        carbohydrates = 10,
        proteins = 3,
        healthiness = 8,
        food_category = "alien-fruit",
        taste_category = Taste.neutral,
        appeal = 2,
        nutrition_tags = {[NutritionTag.carb_rich] = true},
        item_weight = 1,
        group = "unnamed-fruit"
    },
    ["weird-berry"] = {
        fat = 6.2,
        carbohydrates = 10,
        proteins = 3.2,
        healthiness = 2,
        food_category = "alien-fruit",
        taste_category = Taste.soily,
        appeal = 3,
        nutrition_tags = {[NutritionTag.carb_rich] = true},
        item_weight = 1,
        group = "weird-berry"
    },
    ["brutal-pumpkin"] = {
        fat = 0.6,
        carbohydrates = 6.9,
        proteins = 0.6,
        healthiness = 6,
        food_category = "alien-vegetable",
        taste_category = Taste.umami,
        appeal = 3,
        nutrition_tags = {[NutritionTag.carb_rich] = true},
        item_weight = 5,
        group = "brutal-pumpkin"
    },
    ["ortrot"] = {
        fat = 0.2,
        carbohydrates = 7.4,
        proteins = 7.3,
        healthiness = 6,
        food_category = "alien-fruit",
        taste_category = Taste.weirdly_chemical,
        appeal = 2,
        nutrition_tags = {[NutritionTag.carb_rich] = true},
        item_weight = 1,
        group = "ortrot"
    },
    ["apple"] = {
        fat = 1,
        carbohydrates = 14.4,
        proteins = 1.3,
        healthiness = 6,
        food_category = "fruit",
        taste_category = Taste.fruity,
        appeal = 6,
        nutrition_tags = {[NutritionTag.carb_rich] = true},
        item_weight = 1,
        group = "apple"
    },
    ["blue-grapes"] = {
        fat = 0.3,
        carbohydrates = 17,
        proteins = 0.6,
        healthiness = 6,
        food_category = "alien-fruit",
        taste_category = Taste.fruity,
        appeal = 6,
        nutrition_tags = {[NutritionTag.carb_rich] = true},
        item_weight = 1,
        group = "grapes"
    },
    ["orange"] = {
        fat = 0.1,
        carbohydrates = 25,
        proteins = 1.0,
        healthiness = 6,
        food_category = "fruit",
        taste_category = Taste.fruity,
        appeal = 7,
        nutrition_tags = {[NutritionTag.carb_rich] = true},
        item_weight = 1,
        group = "orange"
    },
    ["lemon"] = {
        fat = 0.6,
        carbohydrates = 8.1,
        proteins = 0.8,
        healthiness = 6,
        food_category = "fruit",
        taste_category = Taste.acidic,
        appeal = 7,
        nutrition_tags = {[NutritionTag.carb_rich] = true},
        item_weight = 1,
        group = "lemon"
    },
    ["zetorn"] = {
        fat = 1.2,
        carbohydrates = 15.4,
        proteins = 0.9,
        healthiness = 6,
        food_category = "alien-fruit",
        taste_category = Taste.fruity,
        appeal = 4,
        nutrition_tags = {[NutritionTag.carb_rich] = true},
        item_weight = 1,
        group = "zetorn"
    },
    ["cherry"] = {
        fat = 0.4,
        carbohydrates = 12,
        proteins = 1,
        healthiness = 7,
        food_category = "fruit",
        taste_category = Taste.fruity,
        appeal = 6,
        nutrition_tags = {[NutritionTag.carb_rich] = true},
        item_weight = 1,
        group = "cherry"
    },
    ["olive"] = {
        fat = 11,
        carbohydrates = 6,
        proteins = 0.8,
        healthiness = 7,
        food_category = "fruit",
        taste_category = Taste.salty,
        appeal = 7,
        nutrition_tags = {[NutritionTag.fat_rich] = true},
        item_weight = 1,
        group = "olive"
    },
    ["bell-pepper"] = {
        fat = 0.2,
        carbohydrates = 8,
        proteins = 2,
        healthiness = 6,
        food_category = "vegetable",
        taste_category = Taste.spicy,
        appeal = 6,
        nutrition_tags = {[NutritionTag.carb_rich] = true},
        item_weight = 2.5,
        group = "bell-pepper"
    },
    ["potato"] = {
        fat = 0.5,
        carbohydrates = 17,
        proteins = 2,
        healthiness = 5,
        food_category = "vegetable",
        taste_category = Taste.umami,
        appeal = 3,
        nutrition_tags = {[NutritionTag.carb_rich] = true},
        item_weight = 1,
        group = "potato"
    },
    ["sesame"] = {
        fat = 48,
        carbohydrates = 26,
        proteins = 17,
        healthiness = 7,
        food_category = "seed",
        taste_category = Taste.umami,
        appeal = 7,
        nutrition_tags = {[NutritionTag.protein_rich] = true, [NutritionTag.fat_rich] = true, [NutritionTag.carb_rich] = true},
        item_weight = 0.2,
        group = "sesame"
    },
    ["tomato"] = {
        fat = 0.33,
        carbohydrates = 4,
        proteins = 1.5,
        healthiness = 5,
        food_category = "vegetable",
        taste_category = Taste.umami,
        appeal = 5,
        nutrition_tags = {},
        item_weight = 2.5,
        group = "tomato"
    },
    ["eggplant"] = {
        fat = 0.4,
        carbohydrates = 4.6,
        proteins = 1.5,
        healthiness = 6,
        food_category = "vegetable",
        taste_category = Taste.umami,
        appeal = 5,
        nutrition_tags = {},
        item_weight = 2.5,
        group = "eggplant"
    },
    ["fawoxylas"] = {
        fat = 0.5,
        carbohydrates = 3.5,
        proteins = 3.3,
        healthiness = 7,
        food_category = "alien-fungus",
        taste_category = Taste.umami,
        appeal = 6,
        nutrition_tags = {},
        item_weight = 2.5,
        group = "fawoxylas"
    },
    ["avocado"] = {
        fat = 15,
        carbohydrates = 9,
        proteins = 2,
        healthiness = 8,
        food_category = "vegetable",
        taste_category = Taste.neutral,
        appeal = 8,
        nutrition_tags = {[NutritionTag.fat_rich] = true},
        item_weight = 1,
        group = "avocado"
    },
    ["chickpea"] = {
        fat = 4,
        carbohydrates = 29.4,
        proteins = 12.6,
        healthiness = 7,
        food_category = "legume",
        taste_category = Taste.umami,
        appeal = 5,
        nutrition_tags = {[NutritionTag.carb_rich] = true, [NutritionTag.protein_rich] = true},
        item_weight = 1,
        group = "chickpea"
    },
    ["hummus"] = {
        fat = 20,
        carbohydrates = 28,
        proteins = 16,
        healthiness = 9,
        food_category = "processed",
        taste_category = Taste.spicy,
        appeal = 8,
        nutrition_tags = {[NutritionTag.protein_rich] = true, [NutritionTag.fat_rich] = true, [NutritionTag.carb_rich] = true},
        item_weight = 1,
        group = "hummus"
    },
    ["dried-solfaen"] = {
        fat = 0.6,
        carbohydrates = 3.1,
        proteins = 5.9,
        healthiness = 7,
        food_category = "processed",
        taste_category = Taste.neutral,
        appeal = 2,
        nutrition_tags = {[NutritionTag.protein_rich] = true},
        item_weight = 2,
        group = "algae"
    },
    ["razha-bean"] = {
        fat = 5.1,
        carbohydrates = 9.8,
        proteins = 12.2,
        healthiness = 6,
        food_category = "alien-legume",
        taste_category = Taste.umami,
        appeal = 4,
        nutrition_tags = {[NutritionTag.protein_rich] = true},
        item_weight = 1,
        group = "razha-bean"
    },
    ["tofu"] = {
        fat = 4.8,
        carbohydrates = 1.9,
        proteins = 8.5,
        healthiness = 7,
        food_category = "processed",
        taste_category = Taste.neutral,
        appeal = 6,
        nutrition_tags = {[NutritionTag.protein_rich] = true},
        item_weight = 1,
        group = "processed-razha"
    },
    ["yuba"] = {
        fat = 24.1,
        carbohydrates = 3.8,
        proteins = 52.3,
        healthiness = 7,
        food_category = "processed",
        taste_category = Taste.umami,
        appeal = 5,
        nutrition_tags = {[NutritionTag.protein_rich] = true, [NutritionTag.fat_rich] = true},
        item_weight = 0.2,
        group = "processed-razha"
    },
    ["liontooth"] = {
        fat = 0.7,
        carbohydrates = 2.4,
        proteins = 3.1,
        healthiness = 6,
        food_category = "alien-vegetable",
        taste_category = Taste.spicy,
        appeal = 3,
        nutrition_tags = {},
        item_weight = 2,
        group = "liontooth"
    },
    ["manok"] = {
        fat = 0.3,
        carbohydrates = 23.1,
        proteins = 2.3,
        healthiness = 6,
        food_category = "alien-vegetable",
        taste_category = Taste.umami,
        appeal = 5,
        nutrition_tags = {[NutritionTag.carb_rich] = true},
        item_weight = 1,
        group = "manok"
    },
    ["tello-fruit"] = {
        fat = 0.2,
        carbohydrates = 18.1,
        proteins = 1.7,
        healthiness = 2,
        food_category = "alien-vegetable",
        taste_category = Taste.fruity,
        appeal = 1,
        nutrition_tags = {[NutritionTag.carb_rich] = true},
        item_weight = 1,
        group = "tello"
    },
    ["sugar-beet"] = {
        fat = 0.5,
        carbohydrates = 27.1,
        proteins = 1.0,
        healthiness = 4,
        food_category = "vegetable",
        taste_category = Taste.fruity,
        appeal = 3,
        nutrition_tags = {[NutritionTag.carb_rich] = true},
        item_weight = 1,
        group = "sugar-beet"
    },
    ["bread"] = {
        fat = 1.2,
        carbohydrates = 48.8,
        proteins = 7.6,
        healthiness = 4,
        food_category = "processed",
        taste_category = Taste.fruity,
        appeal = 6,
        nutrition_tags = {[NutritionTag.carb_rich] = true},
        item_weight = 1,
        group = "bread"
    },
    ["queen-algae"] = {
        fat = 0.7,
        carbohydrates = 7.8,
        proteins = 3.1,
        healthiness = 7,
        food_category = "alien-algae",
        taste_category = Taste.fruity,
        appeal = 3,
        nutrition_tags = {[NutritionTag.carb_rich] = true},
        item_weight = 2.5,
        group = "algae"
    },
    ["endower-flower"] = {
        fat = 4.2,
        carbohydrates = 5.5,
        proteins = 3.4,
        healthiness = 6,
        food_category = "alien-underwater-plant",
        taste_category = Taste.acidic,
        appeal = 3,
        nutrition_tags = {},
        item_weight = 2.5,
        group = "endower-flower"
    },
    ["pyrifera"] = {
        fat = 1.4,
        carbohydrates = 4.5,
        proteins = 1.9,
        healthiness = 6,
        food_category = "alien-algae",
        taste_category = Taste.neutral,
        appeal = 3,
        nutrition_tags = {},
        item_weight = 2.5,
        group = "algae"
    },
    ["pocelial"] = {
        fat = 0.6,
        carbohydrates = 1.5,
        proteins = 3.7,
        healthiness = 6,
        food_category = "alien-fungus",
        taste_category = Taste.umami,
        appeal = 6,
        nutrition_tags = {[NutritionTag.protein_rich] = true},
        item_weight = 2.5,
        group = "pocelial"
    },
    ["red-hatty"] = {
        fat = 0.7,
        carbohydrates = 2.7,
        proteins = 2.7,
        healthiness = 4,
        food_category = "alien-fungus",
        taste_category = Taste.spicy,
        appeal = 5,
        nutrition_tags = {},
        item_weight = 2.5,
        group = "red-hatty"
    },
    ["birdsnake"] = {
        fat = 1.0,
        carbohydrates = 2.4,
        proteins = 3.2,
        healthiness = 8,
        food_category = "alien-fungus",
        taste_category = Taste.salty,
        appeal = 6,
        nutrition_tags = {[NutritionTag.protein_rich] = true},
        item_weight = 2.5,
        group = "birdsnake"
    },
    ["potluck"] = {
        fat = 15, -- TODO: values
        carbohydrates = 15,
        proteins = 15,
        healthiness = 8,
        food_category = "processed",
        taste_category = Taste.umami,
        appeal = 7,
        nutrition_tags = {[NutritionTag.protein_rich] = true, [NutritionTag.fat_rich] = true, [NutritionTag.carb_rich] = true},
        item_weight = 1,
        group = "potluck"
    },

    -- Test food items. Prototypes are only created when sosciencity-debug is active, but the
    -- constants are always present so the diet tests can reference stable, fixed values.
    ["test-food-fruity-carb"] = {
        fat = 5, carbohydrates = 20, proteins = 10,
        healthiness = 5, food_category = "processed",
        taste_category = Taste.fruity, appeal = 6,
        nutrition_tags = {[NutritionTag.carb_rich] = true},
        item_weight = 1, group = "test-food-a"
    },
    ["test-food-fruity-fat"] = {
        fat = 20, carbohydrates = 5, proteins = 10,
        healthiness = 5, food_category = "processed",
        taste_category = Taste.fruity, appeal = 6,
        nutrition_tags = {[NutritionTag.fat_rich] = true},
        item_weight = 1, group = "test-food-b"
    },
    ["test-food-neutral-protein-fat"] = {
        fat = 15, carbohydrates = 5, proteins = 20,
        healthiness = 5, food_category = "processed",
        taste_category = Taste.neutral, appeal = 7,
        nutrition_tags = {[NutritionTag.protein_rich] = true, [NutritionTag.fat_rich] = true},
        item_weight = 1, group = "test-food-c"
    },
    ["test-food-neutral-carb"] = {
        fat = 5, carbohydrates = 20, proteins = 5,
        healthiness = 5, food_category = "processed",
        taste_category = Taste.neutral, appeal = 5,
        nutrition_tags = {[NutritionTag.carb_rich] = true},
        item_weight = 1, group = "test-food-d"
    },
    ["test-food-salty-protein"] = {
        fat = 5, carbohydrates = 5, proteins = 20,
        healthiness = 5, food_category = "processed",
        taste_category = Taste.salty, appeal = 6,
        nutrition_tags = {[NutritionTag.protein_rich] = true},
        item_weight = 1, group = "test-food-e"
    },
    ["test-food-spicy-alltags"] = {
        fat = 20, carbohydrates = 28, proteins = 16,
        healthiness = 9, food_category = "processed",
        taste_category = Taste.spicy, appeal = 8,
        nutrition_tags = {[NutritionTag.protein_rich] = true, [NutritionTag.fat_rich] = true, [NutritionTag.carb_rich] = true},
        item_weight = 1, group = "test-food-f"
    },
    ["test-food-umami-carb"] = {
        fat = 5, carbohydrates = 20, proteins = 5,
        healthiness = 5, food_category = "processed",
        taste_category = Taste.umami, appeal = 5,
        nutrition_tags = {[NutritionTag.carb_rich] = true},
        item_weight = 1, group = "test-food-g"
    },
    ["test-food-umami-notag"] = {
        fat = 5, carbohydrates = 5, proteins = 5,
        healthiness = 5, food_category = "processed",
        taste_category = Taste.umami, appeal = 5,
        nutrition_tags = {},
        item_weight = 1, group = "test-food-h"
    }
}

--- Energy density of fat contents in kcal per g
Food.energy_density_fat = 9
--- Energy density of carbohydrate contents in kcal per g
Food.energy_density_carbohydrates = 4
--- Energy density of protein contents in kcal per g
Food.energy_density_proteins = 3.7

-- values postprocessing
for name, food_definition in pairs(Food.values) do
    food_definition.name = name

    -- convert nutrients from g per 100g to kcal per 100g
    food_definition.fat = food_definition.fat * Food.energy_density_fat
    food_definition.carbohydrates = food_definition.carbohydrates * Food.energy_density_carbohydrates
    food_definition.proteins = food_definition.proteins * Food.energy_density_proteins

    -- calories specifies the calorific value of one item
    -- the magic 10 is just to get from 100g to 1kg
    food_definition.calories = (food_definition.fat + food_definition.carbohydrates + food_definition.proteins) * 10 * food_definition.item_weight

    -- density is kcal per 100g, independent of item_weight
    -- used to weight consumption so that item consumption rate is inversely proportional to item_weight
    food_definition.density = food_definition.calories / food_definition.item_weight
end

Food.emergency_ration_calories = 1000

if Tirislib.Utils.is_control_stage() then
    for food_name, food_data in pairs(Food.values) do
        local food_prototype = prototypes.item[food_name]

        if not food_prototype then
            goto continue
        end

        local max_spoil = {}
        food_data.max_spoil = max_spoil
        for quality in pairs(prototypes.quality) do
            max_spoil[quality] = food_prototype.get_spoil_ticks(quality)
        end

        food_data.localised_name = food_prototype.localised_name
        food_data.localised_description = food_prototype.localised_description

        ::continue::
    end
end

return Food
