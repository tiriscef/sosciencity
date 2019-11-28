---------------------------------------------------------------------------------------------------
-- << static class for recipe generation >>
-- generic recipes with configurable ingredients to facilitate integration/compatibility with other mods
-- assumes the result items already exist
RecipeGenerator = {}

-- table with tech_level -> array of IngredientPrototypes
-- 0: Start of the game, nothing researched
-- 1: automation science
-- 2: logistic science
-- 3: chemical science
-- 4: production science
-- 5: utility science
-- 6: space science
-- 7: post space science
RecipeGenerator.room_ingredients = {
    [0] = {
        {type = "item", name = "wood", amount = 5},
        {type = "item", name = "iron-plate", amount = 10}
    },
    [1] = {
        {type = "item", name = "wood", amount = 5},
        {type = "item", name = "iron-plate", amount = 10}
    },
    [2] = {},
    [3] = {},
    [4] = {},
    [5] = {},
    [6] = {},
    [7] = {},
    [8] = {}
}

RecipeGenerator.unlocking_tech = {
    [0] = nil,
    [1] = "architecture-1",
    [2] = "architecture-2",
    [3] = "architecture-3",
    [4] = "architecture-4",
    [5] = "architecture-5",
    [6] = "architecture-6",
    [7] = "architecture-7"
}

-- table with coziness -> array of IngredientPrototypes
RecipeGenerator.furniture_ingredients = {
    [0] = {},
    [1] = {
        {type = "item", name = "stool", amount = 2},
        {type = "item", name = "table", amount = 1}
    },
    [2] = {
        {type = "item", name = "bed", amount = 1}
    },
    [3] = {
        {type = "item", name = "furniture", amount = 2},
        {type = "item", name = "stool", amount = 2},
    },
    [4] = {},
    [5] = {},
    [6] = {},
    [7] = {},
    [8] = {},
    [9] = {},
    [10] = {}
}

RecipeGenerator.expensive_multiplier = 3

function RecipeGenerator.create_housing_recipe(housing_name, details)
    local item = Item.get_by_name(housing_name)

    local house_recipe =
        Recipe.create {
        name = housing_name,
        category = "crafting",
        enabled = (details.tech_level == 0),
        energy_required = 1 * details.room_count,
        ingredients = {},
        results = {
            {type = "item", name = housing_name, amount = 1}
        },
        subgroup = item.subgroup,
        order = item.order,
        main_product = housing_name
    }:create_difficulties()

    local room_ingredients = RecipeGenerator.room_ingredients[details.tech_level]
    house_recipe:add_ingredient_range(room_ingredients)
    house_recipe:multiply_expensive_ingredients(RecipeGenerator.expensive_multiplier)

    for _ = 0, details.comfort do
        local furniture = RecipeGenerator.furniture_ingredients[details.comfort]
        house_recipe:add_ingredient_range(furniture)
    end

    house_recipe:multiply_ingredients(details.room_count)

    return house_recipe
end
