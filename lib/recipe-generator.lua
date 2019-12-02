---------------------------------------------------------------------------------------------------
-- << static class for recipe generation >>
-- generic recipes with configurable ingredients to facilitate integration/compatibility with other mods
-- assumes the result items already exist
Tirislib_RecipeGenerator = {}

-- table with tech_level -> array of IngredientPrototypes
-- 0: Start of the game, nothing researched
-- 1: automation science
-- 2: logistic science
-- 3: chemical science
-- 4: production science
-- 5: utility science
-- 6: space science
-- 7: post space science
Tirislib_RecipeGenerator.room_ingredients = {
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

Tirislib_RecipeGenerator.unlocking_tech = {
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
Tirislib_RecipeGenerator.furniture_ingredients = {
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
        {type = "item", name = "stool", amount = 2}
    },
    [4] = {},
    [5] = {},
    [6] = {},
    [7] = {},
    [8] = {},
    [9] = {},
    [10] = {}
}

Tirislib_RecipeGenerator.greenhouse_ingredients = {
    {type = "item", name = "lumber", amount = 150},
    {type = "item", name = "stone-brick", amount = 150},
    {type = "item", name = "iron-plate", amount = 150},
    {type = "item", name = "steel-plate", amount = 100},
    {type = "item", name = "small-lamp", amount = 50},
    {type = "item", name = "electronic-circuit", amount = 20}
}

Tirislib_RecipeGenerator.expensive_multiplier = 3
Tirislib_RecipeGenerator.expensive_farming_multiplier = 2

Tirislib_RecipeGenerator.agriculture_time = 120
Tirislib_RecipeGenerator.greenhouse_time = 100

function Tirislib_RecipeGenerator.create_housing_recipe(housing_name, details)
    local item = Tirislib_Item.get(housing_name)

    local recipe =
        Tirislib_Recipe.create {
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

    local room_ingredients = Tirislib_RecipeGenerator.room_ingredients[details.tech_level]
    recipe:add_ingredient_range(room_ingredients)
    recipe:multiply_expensive_ingredients(Tirislib_RecipeGenerator.expensive_multiplier)

    for _ = 0, details.comfort do
        local furniture = Tirislib_RecipeGenerator.furniture_ingredients[details.comfort]
        recipe:add_ingredient_range(furniture)
    end

    recipe:multiply_ingredients(details.room_count)

    recipe:add_unlock(Tirislib_RecipeGenerator.unlocking_tech[details.tech_level])

    return recipe
end

function Tirislib_RecipeGenerator.create_recipe(product_name, ingredients, additional_fields)
    local item = Tirislib_Item.get(product_name)

    local recipe =
        Tirislib_Recipe.create {
        name = product_name,
        category = "crafting",
        enabled = true,
        energy_required = 5,
        ingredients = {},
        results = {
            {type = "item", name = product_name, amount = 1}
        },
        subgroup = item.subgroup,
        order = item.order
    }:create_difficulties()

    recipe:add_ingredient_range(ingredients)
    recipe:multiply_expensive_ingredients(Tirislib_RecipeGenerator.expensive_multiplier)

    Tirislib_Tables.set_fields(recipe, additional_fields)

    return recipe
end

function Tirislib_RecipeGenerator.create_agriculture_recipe(product_name, ingredients, yield, additional_fields)
    local recipe =
        Tirislib_Recipe.create {
        name = product_name .. "-agriculture",
        category = "sosciencity-agriculture",
        enabled = true,
        energy_required = Tirislib_RecipeGenerator.agriculture_time,
        ingredients = {},
        results = {
            {type = "item", name = product_name, amount_min = 1, amount_max = yield, probability = 0.5}
        },
        subgroup = "sosciencity-agriculture"
    }:create_difficulties()

    recipe:add_ingredient_range(ingredients)
    recipe:multiply_expensive_ingredients(Tirislib_RecipeGenerator.expensive_farming_multiplier)

    Tirislib_Tables.set_fields(recipe, additional_fields)

    return recipe
end

function Tirislib_RecipeGenerator.create_greenhouse_recipe(product_name, ingredients, yield, additional_fields)
    local min_yield = math.min(math.floor(yield / 2))

    local recipe =
        Tirislib_Recipe.create {
        name = product_name .. "-greenhouse",
        category = "sosciencity-greenhouse",
        enabled = true,
        energy_required = Tirislib_RecipeGenerator.greenhouse_time,
        ingredients = {},
        results = {
            {type = "item", name = product_name, amount_min = min_yield, amount_max = yield}
        },
        subgroup = "sosciencity-greenhouse"
    }:create_difficulties()

    recipe:add_ingredient_range(ingredients)
    recipe:multiply_expensive_ingredients(Tirislib_RecipeGenerator.expensive_farming_multiplier)

    Tirislib_Tables.set_fields(recipe, additional_fields)

    return recipe
end
