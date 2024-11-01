--- Generator for generic recipes with configurable ingredients to facilitate integration/compatibility with other mods.
--- Assumes the result items already exist.
Tirislib.RecipeGenerator = {}

---------------------------------------------------------------------------------------------------
-- << definitions >>

local ingredient_themes = {}

--- Table with Theme -> table with (level, array of IngredientPrototypes) pairs\
--- Most of the time level is defined by the research stage at which the player should be able to use this recipe.\
--- **0:** Start of the game, nothing researched\
--- **1:** automation science\
--- **2:** logistic science\
--- **3:** chemical science\
--- **4:** production science\
--- **5:** utility science\
--- **6:** space science\
--- **7:** post space science
function Tirislib.RecipeGenerator.add_themes(themes)
    for k, v in pairs(themes) do
        ingredient_themes[k] = v
    end
end

local result_themes = {}

--- Table with Theme -> table with (level, array of ResultPrototypes) pairs\
--- These are separate from the ingredient themes, because ResultPrototypes aren't valid IngredientPrototypes.
function Tirislib.RecipeGenerator.add_result_themes(themes)
    for k, v in pairs(themes) do
        result_themes[k] = v
    end
end

Tirislib.RecipeGenerator.category_alias = {}

--- Table with (alias, name of RecipeCategory) pairs.
function Tirislib.RecipeGenerator.add_category_aliases(aliases)
    Tirislib.Tables.set_fields(Tirislib.RecipeGenerator.category_alias, aliases)
end

Tirislib.RecipeGenerator.item_alias = {}

--- Table with (alias, name of item) pairs.
function Tirislib.RecipeGenerator.add_item_aliases(aliases)
    Tirislib.Tables.set_fields(Tirislib.RecipeGenerator.item_alias, aliases)
end

-- << generation >>

--- Returns the entry in the theme definition that is the closest to the given level.
--- It doesn't return a definition with a higher level to avoid creating progression deadlocks.
local function get_nearest_level(theme_definition, level)
    local ret
    local distance = math.huge

    for defined_level, defined_ingredients in pairs(theme_definition) do
        local current_distance = level - defined_level

        if current_distance >= 0 and current_distance < distance then
            ret = defined_ingredients
            distance = current_distance
        end
    end

    return ret
end

local function get_theme_definition(name, level, for_result)
    local ret

    local theme_definition = (for_result and result_themes[name]) or ingredient_themes[name]
    if theme_definition then
        ret = get_nearest_level(theme_definition, level)
    else
        log("Tirislib RecipeGenerator was told to generate a recipe with an undefined theme: " .. name)
    end

    return ret and Tirislib.Tables.recursive_copy(ret)
end

function Tirislib.RecipeGenerator.add_ingredient_theme(recipe, theme, default_level)
    local name = theme[1]
    local amount = theme[2]
    local expensive_amount = theme[3]
    local level = theme[4] or default_level or 1

    local theme_definition = get_theme_definition(name, level)
    if not theme_definition then
        return
    end

    for _, entry in pairs(theme_definition) do
        entry.amount = entry.amount * amount
    end

    local expensive_theme_definition
    if expensive_amount then
        expensive_theme_definition = get_theme_definition(name, level)
        for _, entry in pairs(expensive_theme_definition) do
            entry.amount = entry.amount * expensive_amount
        end
    end

    recipe:add_ingredient_range(theme_definition, expensive_theme_definition)
end

function Tirislib.RecipeGenerator.add_ingredient_theme_range(recipe, themes, default_level)
    if themes then
        for _, theme in pairs(themes) do
            Tirislib.RecipeGenerator.add_ingredient_theme(recipe, theme, default_level)
        end

        recipe:floor_ingredients()
    end
end

function Tirislib.RecipeGenerator.add_result_theme(recipe, theme, default_level)
    local name = theme[1]
    local amount = theme[2]
    local expensive_amount = theme[3]
    local level = theme[4] or default_level or 1

    local results = get_theme_definition(name, level, true)
    if not results then
        return
    end

    local expensive_results
    if expensive_amount then
        expensive_results = get_theme_definition(name, level, true)
        for _, entry in pairs(expensive_results) do
            entry.amount = entry.amount * expensive_amount
        end
    end

    for _, entry in pairs(results) do
        entry.amount = entry.amount * amount
    end

    recipe:add_result_range(results, expensive_results)
end

function Tirislib.RecipeGenerator.add_result_theme_range(recipe, themes, default_level)
    if themes then
        for _, theme in pairs(themes) do
            Tirislib.RecipeGenerator.add_result_theme(recipe, theme, default_level)
        end

        recipe:floor_results()
    end
end

local function get_product_prototype(details)
    local product_name = details.product
    local product, found

    if details.product_type then -- explicitly set
        product, found = (details.product_type == "item" and Tirislib.Item or Tirislib.Fluid).get_by_name(product_name)
    else -- implicit, look if an item or a fluid exists
        product, found = Tirislib.Item.get_by_name(product_name)

        if found then
            -- check that no fluid with the same name exists
            local _, found_again = Tirislib.Fluid.get_by_name(product_name)
            if found_again then
                error(
                    "Tirislib RecipeGenerator was told to create a recipe for a product with an implicit type, but there is is both an item and a fluid with the given name:  " ..
                        product_name
                )
            end
        else
            product, found = Tirislib.Fluid.get_by_name(product_name)
        end
    end

    if not found then
        error(
            "Tirislib RecipeGenerator was told to create a recipe for a non-existant product. A task it's unable to complete. The product's name is " ..
                tostring(product_name)
        )
    end

    return product
end

local function get_main_product_entry(product, details)
    local main_product = {
        type = product.type == "fluid" and "fluid" or "item",
        name = product.name,
        probability = details.product_probability
    }

    if details.product_amount then
        main_product.amount = details.product_amount
    elseif details.product_min then
        main_product.amount_min = details.product_min
        main_product.amount_max = details.product_max
    else
        main_product.amount = 1
    end

    return main_product
end

local function has_fluid_ingredient(recipe_data)
    for _, ingredient in pairs(recipe_data.ingredients) do
        if ingredient.type == "fluid" then
            return true
        end
    end

    return false
end

local function get_standard_category(recipe)
    local normal, expensive = recipe:call_on_recipe_data(has_fluid_ingredient)
    return (normal or expensive) and "crafting-with-fluid" or "crafting"
end

--- Creates a dynamic recipe.\
--- **product:** name of the main product\
--- **product_type:** type of the main product (defaults to "item")\
--- **product_amount:** amount of the main product (defaults to 1)\
--- **product_min:** minimal amount of the main product (if the recipe should use a range)\
--- **product_max:** maximal amount of the main product (if the recipe should use a range)\
--- **product_probability:** probability of the main product\
--- **name:** name of the recipe (defaults to the name of the product)\
--- **byproducts:** array of ResultPrototypes\
--- **expensive_byproducts:** array of ResultPrototypes (defaults to the byproducts field)\
--- **category:** RecipeCategory of the recipe (defaults to "crafting" or "crafting-with-fluid")\
--- **themes:** array of themes\
--- **result_themes:** array of themes\
--- **default_theme_level:** number\
--- **ingredients:** array of IngredientPrototypes\
--- **expensive_ingredients:** array of IngredientPrototypes (defaults to the ingredient field)\
--- **expensive_multiplier:** ingredient multiplier for expensive mode\
--- **energy_required:** energy_required field for the recipe (defaults to 0.5)\
--- **expensive_energy_required:** energy_required field for the expensive recipe (defaults to energy_required)\
--- **unlock:** technology that unlocks the recipe\
--- **additional_fields:** other fields that should be set for the recipe\
--- **allow_productivity:** bool\
--- **localised_name:** locale\
--- **localised_description:** locale\
--- **icon:** path to icon\
--- **icons:** array of SpritePrototypes\
--- **icon_size:** integer\
--- **subgroup:** name of the subgroup (defaults to the product's subgroup)\
--- **index_fluid_ingredients:** bool (defaults to false)\
--- **index_fluid_results:** bool (defaults to false)\
function Tirislib.RecipeGenerator.create(details)
    local product = get_product_prototype(details)
    local main_product = get_main_product_entry(product, details)

    local recipe =
        Tirislib.Recipe.create {
        name = details.name or Tirislib.Prototype.get_unique_name(product.name, "recipe"),
        enabled = true,
        energy_required = details.energy_required or 0.5,
        results = {main_product},
        subgroup = details.subgroup or product.subgroup,
        order = product.order,
        always_show_products = (product.place_result == nil)
    }

    if details.localised_name or details.localised_description or details.icon or details.icons then
        recipe.localised_name = details.localised_name or product:get_localised_name()
        if details.localised_name then
            recipe.show_amount_in_title = false
        end
        recipe.localised_description = details.localised_description or product:get_localised_description()

        if details.icon or details.icons then
            recipe.icon = details.icon
            recipe.icons = details.icons
            recipe.icon_size = details.icon_size or 64
        else
            recipe.icon = product.icon
            recipe.icons = product.icons
            recipe.icon_size = product.icon_size or 64
        end
    else
        recipe.main_product = product.name
    end

    --recipe:create_difficulties()

    -- explicit defined
    recipe:add_ingredient_range(details.ingredients, details.expensive_ingredients)
    recipe:add_result_range(details.byproducts, details.expensive_byproducts, true)

    -- theme defined
    Tirislib.RecipeGenerator.add_ingredient_theme_range(recipe, details.themes, details.default_theme_level)
    Tirislib.RecipeGenerator.add_result_theme_range(recipe, details.result_themes, details.default_theme_level)

    if details.expensive_multiplier then
        recipe:multiply_expensive_ingredients(details.expensive_multiplier)
    end
    recipe:set_expensive_field("energy_required", details.expensive_energy_required or details.energy_required or 0.5)

    recipe:add_unlock(details.unlock)

    local category = details.category or get_standard_category(recipe)
    recipe:set_field("category", category)
    recipe:set_field("always_show_made_in", category ~= "crafting")

    recipe:set_fields(details.additional_fields)

    if details.allow_productivity then
        recipe:allow_productivity_modules()
    end

    if details.index_fluid_ingredients then
        recipe:index_fluid_ingredients()
    end

    if details.index_fluid_results then
        recipe:index_fluid_results()
    end

    return recipe
end

--- Creates a dynamic recipe for every level of a given ingredient theme.\
--- Additional fields:\
--- **followed_theme:** name\
--- **followed_theme_amount:** number or function\
--- **dynamic_fields:** table with (detail field, fn) pairs. The functions will be called with the theme level as the argument.\
function Tirislib.RecipeGenerator.create_per_theme_level(details)
    local theme_name = details.followed_theme
    local theme_definition = ingredient_themes[theme_name]
    local theme_amount = details.followed_theme_amount or 1
    local dynamic = details.dynamic_fields or {}

    local created_recipes = {}
    setmetatable(created_recipes, Tirislib.RecipeArray)

    if not theme_definition then
        log("Tirislib RecipeGenerator was told to follow an undefined theme: " .. details.followed_theme)
        theme_definition = {}
    end

    for level in pairs(theme_definition) do
        local current_details = Tirislib.Tables.copy(details)

        -- set dynamic fields
        for field, fn in pairs(dynamic) do
            current_details[field] = fn(level)
        end

        -- set the current followed theme
        local themes = Tirislib.Tables.get_subtbl(current_details, "themes")
        themes[#themes + 1] = {
            theme_name,
            type(theme_amount) == "function" and theme_amount(level) or theme_amount,
            nil,
            level
        }

        created_recipes[#created_recipes + 1] = Tirislib.RecipeGenerator.create(current_details)
    end

    return created_recipes
end

local arrays = {"ingredients", "expensive_ingredients", "byproducts", "expensive_byproducts", "themes", "result_themes"}
arrays = Tirislib.Tables.array_to_lookup(arrays)

--- Merges the right hand recipe details into the left hand recipe details.
--- @param lh table
--- @param rh table
function Tirislib.RecipeGenerator.merge_details(lh, rh)
    if not lh or not rh then
        return
    end

    for key, value in pairs(rh) do
        if arrays[key] then
            Tirislib.Tables.merge(Tirislib.Tables.get_subtbl(lh, key), value)
        else
            -- set the field passively
            lh[key] = (lh[key] ~= nil) and lh[key] or value
        end
    end
end
