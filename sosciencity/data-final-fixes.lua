--[[ helper functions ]]
-- returns the amount of items a table of the format {type = "item", name = "...", amount = x} or {"...", 7} specifies
-- the wiki calls them 'item product prototype'
local function get_item_count_in_item_product_prototype(prototype)
    local probability = prototype.probability or 1

    if prototype.amount_min then
        return (prototype.amount_min + prototype.amount_max) * 0.5 * probability
    end

    local amount = prototype.amount or prototype[2] or 1
    return amount * probability
end

-- returns the amount of [item_name] that occur in a results table
local function get_item_count_in_results_table(results_table, item_name)
    for _, result in pairs(results_table) do
        if result.name == item_name or result[1] == item_name then
            return get_item_count_in_item_product_prototype(result)
        end
    end

    return 0 -- item doesn't occur in this table
end

-- returns the amount of [item_name] that occur as result in a recipe (or recipe difficulty)
local function get_result_item_count_in_recipe(recipe, item_name)
    if recipe.result then
        if recipe.result == item_name then
            return recipe.result_count or 1 -- factorio defaults to 1 if no result_count is specified
        else 
            return 0
        end
    elseif recipe.results then
        return get_item_count_in_results_table(recipe.results, item_name)
    end
    error("Sosciencity found a weird recipe that it cannot understand. Recipe name: " .. recipe.name)
end

-- returns the average count of the item the recipe yields
-- as a table with the keys normal and expensive or no_difficulties
local function get_result_item_count(recipe, item_name)
    ret = {}

    if recipe.normal or recipe.expensive then
        if recipe.normal then
            ret.normal = get_result_item_count_in_recipe(recipe.normal, item_name)
        end
        if recipe.expensive then
            ret.expensive = get_result_item_count_in_recipe(recipe.expensive, item_name)
        end
    else
        ret.no_difficulties = get_result_item_count_in_recipe(recipe, item_name)
    end

    return ret
end

local function add_ingredient_if_result_contains(recipe, ingredient_details, result_item)
    local counts = get_result_item_count(recipe, result_item)

    if counts.normal and counts.normal > 0. then
        recipe:add_ingredient(
            {type = "item", name = ingredient_details.ingredient, amount = math.ceil(counts.normal * ingredient_details.factor)},
            {type = "item", name = ingredient_details.ingredient, amount = math.ceil(counts.expensive * ingredient_details.factor)}
        )
    elseif counts.no_difficulties and counts.no_difficulties > 0. then
        recipe:add_ingredient({type = "item", name = ingredient_details.ingredient, amount = math.ceil(counts.no_difficulties * ingredient_details.factor)})
    end
end

local result_ingredient_pairs = {
    ["automation-science-pack"] = {ingredient = "note", factor = 1},
    ["logistic-science-pack"] = {ingredient = "essay", factor = 1},
    ["military-science-pack"] = {ingredient = "strategic-considerations", factor = 1},
    ["chemical-science-pack"] = {ingredient = "published-paper", factor = 1},
    ["production-science-pack"] = {ingredient = "complex-scientific-data", factor = 1},
    ["utility-science-pack"] = {ingredient = "data-collection", factor = 1},
    ["space-science-pack"] = {ingredient = "well-funded-scientific-thesis", factor = 0.1}
}

local launchable_ingredient_pairs = {}

local function check_result_ingredient_pairs(recipe)
    for result_item, ingredient_details in pairs(result_ingredient_pairs) do
        add_ingredient_if_result_contains(recipe, ingredient_details, result_item)
    end

    for result_item, ingredient_details in pairs(launchable_ingredient_pairs) do
        add_ingredient_if_result_contains(recipe, ingredient_details, result_item)
    end
end

local function test_launchable(item)
    -- convert to a table if rocket_launch_product is defined to unify the output
    local launch_products = (item.rocket_launch_product and {item.rocket_launch_product}) or item.rocket_launch_products
    
    if not launch_products then 
        return 
    end

    for _, launch_product in pairs(launch_products) do
        for result_item, ingredient_details in pairs(result_ingredient_pairs) do
            if launch_product.name == result_item or launch_product[1] == result_item then
                launchable_ingredient_pairs[item.name] = {
                    ingredient = ingredient_details.ingredient,
                    factor = ingredient_details.factor * get_item_count_in_item_product_prototype(launch_product)
                }
            end
        end
    end
end

--[[ looping through items ]]
-- all the item types
-- a lot of them are really unlikely to be relevant, but I think it doesn't hurt covering them
-- in case other mods do strange things
local item_types = {
    "item", 
    "ammo", 
    "capsule", 
    "gun", 
    "item-with-entity-data", 
    "item-with-label",
    "item-with-inventory",
    "blueprint-book",
    "item-with-tags",
    "selection-tool",
    "blueprint",
    "copy-paste-tool",
    "deconstruction-item",
    "upgrade-item",
    "module",
    "rail-planner",
    "tool",
    "armor",
    "repair-tool"
}

local item_functions = {
    test_launchable
}

for _, item_type in pairs(item_types) do
    for _, item in pairs(data.raw[item_type]) do
        for _, func in pairs(item_functions) do
            func(item)
        end
    end
end

--[[ looping through recipes ]]
local recipe_functions = {
    check_result_ingredient_pairs
}

-- Find all the recipes that return science packs and add my science ingredient items to them
for _, recipe in pairs(data.raw.recipe) do
    local current_recipe = RECIPE(recipe.name)

    for _, func in pairs(recipe_functions) do
        func(current_recipe)
    end
end

--[[ handcrafting category ]]
-- add it when no other mod did
if not data.raw["recipe-category"]["handcrafting"] then
    data:extend {
        {
            type = "recipe-category",
            name = "handcrafting"
        }
    }

    for _, player in DATA:pairs("character") do
        player.crafting_categories = player:get_field("crafting_categories", default) + "handcrafting"
    end
    for _, controller in DATA:pairs("god-controller") do
        controller.crafting_categories = controller:get_field("crafting_categories", default) + "handcrafting"
    end
end
