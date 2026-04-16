--- Generator for generic recipes with configurable ingredients to facilitate integration/compatibility with other mods.
--- Assumes the result items already exist.
Tirislib.RecipeGenerator = {}

---------------------------------------------------------------------------------------------------
-- << definitions >>

local ingredient_themes = {}

--- Table with Theme -> table with (level, array of IngredientPrototypes) pairs<br>
--- Most of the time level is defined by the research stage at which the player should be able to use this recipe.<br>
--- **0:** Start of the game, nothing researched<br>
--- **1:** automation science<br>
--- **2:** logistic science<br>
--- **3:** chemical science<br>
--- **4:** production science<br>
--- **5:** utility science<br>
--- **6:** space science<br>
--- **7:** post space science
function Tirislib.RecipeGenerator.add_themes(themes)
    for k, v in pairs(themes) do
        ingredient_themes[k] = v
    end
end

local result_themes = {}

--- Table with Theme -> table with (level, array of ResultPrototypes) pairs<br>
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

    local theme_definition
    if for_result then
        theme_definition = result_themes[name]
    else
        theme_definition = ingredient_themes[name]
    end

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
    local level = theme[3] or default_level or 0

    local theme_definition = get_theme_definition(name, level)
    if not theme_definition then
        return
    end

    for _, entry in pairs(theme_definition) do
        entry.amount = entry.amount * amount
    end

    recipe:add_ingredient_range(theme_definition)
end

function Tirislib.RecipeGenerator.add_ingredient_theme_range(recipe, themes, default_level)
    if themes then
        for _, theme in pairs(themes) do
            Tirislib.RecipeGenerator.add_ingredient_theme(recipe, theme, default_level)
        end

        recipe:transform_ingredient_entries(function(entry) Tirislib.RecipeEntry.transform_amount(entry, math.floor) end)
    end
end

function Tirislib.RecipeGenerator.add_result_theme(recipe, theme, default_level)
    local name = theme[1]
    local amount = theme[2]
    local level = theme[3] or default_level or 0

    local results = get_theme_definition(name, level, true)
    if not results then
        return
    end

    for _, entry in pairs(results) do
        entry.amount = entry.amount * amount
    end

    recipe:add_result_range(results)
end

function Tirislib.RecipeGenerator.add_result_theme_range(recipe, themes, default_level)
    if themes then
        for _, theme in pairs(themes) do
            Tirislib.RecipeGenerator.add_result_theme(recipe, theme, default_level)
        end

        recipe:transform_result_entries(function(entry) Tirislib.RecipeEntry.transform_amount(entry, math.floor) end)
    end
end

--- Finds the product prototype. Returns nil if not found (no error).
local function find_product_prototype(product_name, product_type)
    local product, found

    if product_type then -- explicitly set
        product, found = (product_type == "item" and Tirislib.Item or Tirislib.Fluid).get_by_name(product_name)
    else -- implicit, look if an item or a fluid exists
        product, found = Tirislib.Item.get_by_name(product_name)

        if found then
            -- check that no fluid with the same name exists
            local _, found_again = Tirislib.Fluid.get_by_name(product_name)
            if found_again then
                error(
                    "Tirislib RecipeGenerator was told to create a recipe for a product with an implicit type, but there is is both an item and a fluid with the given name: " ..
                        product_name
                )
            end
        else
            product, found = Tirislib.Fluid.get_by_name(product_name)
        end
    end

    return found and product or nil
end

local function get_product_prototype(product_name, product_type)
    local product = find_product_prototype(product_name, product_type)

    if not product then
        error(
            "Tirislib RecipeGenerator was told to create a recipe for a non-existant product. A task it's unable to complete. The product's name is: " ..
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

local function get_standard_category(recipe)
    for _, ingredient in recipe:iterate_ingredients() do
        if ingredient.type == "fluid" then
            return "crafting-with-fluid"
        end
    end

    return "crafting"
end

--- Creates a dynamic recipe.<br>
--- **Deprecated**, I want to migrate to the prototype-based `create_from_prototype` method instead.<br>
--- **product:** name of the main product<br>
--- **product_type:** type of the main product (defaults to "item")<br>
--- **product_amount:** amount of the main product (defaults to 1)<br>
--- **product_min:** minimal amount of the main product (if the recipe should use a range)<br>
--- **product_max:** maximal amount of the main product (if the recipe should use a range)<br>
--- **product_probability:** probability of the main product<br>
--- **name:** name of the recipe (defaults to the name of the product)<br>
--- **byproducts:** array of ResultPrototypes<br>
--- **category:** RecipeCategory of the recipe (defaults to "crafting" or "crafting-with-fluid")<br>
--- **themes:** array of themes<br>
--- **result_themes:** array of themes<br>
--- **default_theme_level:** number<br>
--- **ingredients:** array of IngredientPrototypes<br>
--- **energy_required:** energy_required field for the recipe (defaults to 0.5)<br>
--- **unlock:** technology that unlocks the recipe<br>
--- **additional_fields:** other fields that should be set for the recipe<br>
--- **localised_name:** locale<br>
--- **localised_description:** locale<br>
--- **icon:** path to icon<br>
--- **icons:** array of SpritePrototypes<br>
--- **icon_size:** integer<br>
--- **subgroup:** name of the subgroup (defaults to the product's subgroup)<br>
--- **do_index_fluid_ingredients:** bool (defaults to false)<br>
--- **do_index_fluid_results:** bool (defaults to false)
function Tirislib.RecipeGenerator.create(details)
    local product = get_product_prototype(details.product, details.product_type)
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
        recipe.localised_name = product:get_localised_name()
    end

    -- explicit defined
    recipe:add_ingredient_range(details.ingredients)
    recipe:add_result_range(details.byproducts, true)

    -- theme defined
    Tirislib.RecipeGenerator.add_ingredient_theme_range(recipe, details.themes, details.default_theme_level)
    Tirislib.RecipeGenerator.add_result_theme_range(recipe, details.result_themes, details.default_theme_level)

    -- unlock (accepts a single string or a table of strings)
    local unlock = details.unlock
    if type(unlock) == "table" then
        for _, tech in pairs(unlock) do
            recipe:add_unlock(tech)
        end
    else
        recipe:add_unlock(unlock)
    end

    local category = details.category or get_standard_category(recipe)
    recipe:set_field("category", category)
    recipe:set_field("always_show_made_in", category ~= "crafting")

    recipe:set_fields(details.additional_fields)

    if details.allow_productivity then
        recipe.allow_productivity = true
    end

    if details.do_index_fluid_ingredients then
        recipe:index_fluid_ingredients()
    end

    if details.do_index_fluid_results then
        recipe:index_fluid_results()
    end

    return recipe
end

-- << prototype-based creation >>

---------------------------------------------------------------------------------------------------
-- << EmmyLua type definitions >>

--- An ingredient entry that expands to the concrete items/fluids defined for a theme at a given
--- technology level. Theme entries are interleaved with regular IngredientPrototypes in the
--- `ingredients` array of an ExtendedRecipePrototype and are removed before the recipe is created.
---@class ThemeEntry
---@field theme string Name of the ingredient theme (e.g. `"metal"`, `"piping"`).
---@field amount number Multiplier applied to every ingredient in the theme expansion.
---@field level? number Technology level override. Falls back to `ExtendedRecipePrototype.default_theme_level`, then 0.

--- A regular Factorio ResultPrototype that may additionally carry a `product` marker used by the
--- RecipeGenerator to identify which result drives name, subgroup, order, and icon derivation.
--- Exactly one entry per prototype should be marked; if none are marked the first result is used.
--- The flag is stripped before the underlying recipe is created.
---@class ProductResultEntry : data.ProductPrototype
---@field product? true Marks this entry as the product for field derivation. Stripped before recipe creation.

--- A complete or partial Factorio RecipePrototype that `create_from_prototype` and
--- `merge_prototypes` accept. All standard recipe fields are valid. In addition:
---
--- - `ingredients` and `results` may contain `ThemeIngredientEntry` objects alongside regular
---   entries; those are expanded and removed before the recipe prototype is submitted.
--- - One entry in `results` may be marked with `product = true` to identify the main product for
---   field derivation (name, subgroup, order, icon, localisation). Falls back to `results[1]`.
--- - `unlock`, `default_theme_level`, `do_index_fluid_ingredients`, and
---   `do_index_fluid_results` are extra keys consumed by `create_from_prototype` and never
---   forwarded to the underlying Factorio prototype.
---@class ExtendedRecipePrototype : data.RecipePrototype
---@field ingredients? (data.IngredientPrototype | ThemeEntry)[] Regular ingredient entries and/or inline theme expansions.
---@field results? (ProductResultEntry | ThemeEntry)[] Result entries (with optional `product` marker) and/or inline theme expansions.
---@field unlock? string | string[] Technology name(s) that unlock the recipe. Accepts a single string or an array.
---@field default_theme_level? number Fallback technology level used when a theme entry omits its own `level`. Defaults to 0.
---@field do_index_fluid_ingredients? boolean When true, fluid ingredient entries receive an explicit `fluidbox_index` after creation.
---@field do_index_fluid_results? boolean When true, fluid result entries receive an explicit `fluidbox_index` after creation.

---------------------------------------------------------------------------------------------------

--- Separates theme entries from real entries in an array.
--- Theme entries are identified by having a `theme` key.
local function separate_themes(entries)
    if not entries then
        return nil, nil
    end

    local real, themes
    for _, entry in pairs(entries) do
        if entry.theme ~= nil then
            themes = themes or {}
            themes[#themes + 1] = entry
        else
            real = real or {}
            real[#real + 1] = entry
        end
    end

    return real, themes
end

--- Finds the result entry marked as product, or defaults to the first result.
--- Strips the product flag from the entry.
local function find_product_entry(results)
    if not results or #results == 0 then
        return nil
    end

    for _, entry in pairs(results) do
        if entry.product then
            entry.product = nil
            return entry
        end
    end

    return results[1]
end

--- Returns the product entry from a recipe prototype without modifying it.
--- The product is the result marked with `product = true`, or the first result if none are marked.
--- Useful in prototype-building wrapper functions that need to identify the product
--- from the prototype's `results` array without consuming or altering it.
---@param prototype ExtendedRecipePrototype
---@return ProductResultEntry | nil
function Tirislib.RecipeGenerator.get_product_entry(prototype)
    local results = prototype.results
    if not results or #results == 0 then
        return nil
    end

    for _, entry in pairs(results) do
        if entry.product then
            return entry
        end
    end

    return results[1]
end

--- Derives recipe fields from the product's item/fluid prototype where not already set.
local function derive_fields_from_product(prototype, product_entry)
    if not product_entry then
        return
    end

    local product = find_product_prototype(product_entry.name, product_entry.type)

    if product then
        prototype.name = prototype.name or Tirislib.Prototype.get_unique_name(product.name, "recipe")
        prototype.subgroup = prototype.subgroup or product.subgroup
        prototype.order = prototype.order or product.order

        if prototype.always_show_products == nil then
            prototype.always_show_products = (product.place_result == nil)
        end
    end

    -- localisation and icon derivation
    local has_custom_identity = prototype.localised_name or prototype.localised_description or prototype.icon or prototype.icons
    local caller_set_name = prototype.localised_name ~= nil

    if has_custom_identity then
        if product then
            prototype.localised_name = prototype.localised_name or product:get_localised_name()
            prototype.localised_description = prototype.localised_description or product:get_localised_description()
        end

        if caller_set_name and prototype.show_amount_in_title == nil then
            prototype.show_amount_in_title = false
        end

        if not prototype.icon and not prototype.icons then
            if product then
                prototype.icon = product.icon
                prototype.icons = product.icons
                prototype.icon_size = prototype.icon_size or product.icon_size or 64
            end
        end
    else
        if not product then
            error(
                "Tirislib RecipeGenerator couldn't derive the identity for recipe from product '" ..
                    tostring(product_entry.name) ..
                    "'. The product prototype doesn't exist and no custom identity was provided."
            )
        end
        prototype.main_product = product.name
        prototype.localised_name = product:get_localised_name()
    end
end

--- Creates a recipe from a (potentially incomplete) recipe prototype.<br>
--- The prototype can contain regular recipe fields as well as these extra keys:<br>
--- **unlock:** technology that unlocks the recipe<br>
--- **default_theme_level:** default level for theme entries without an explicit level<br>
--- **do_index_fluid_ingredients:** bool<br>
--- **do_index_fluid_results:** bool<br>
---<br>
--- Entries in the **ingredients** and **results** arrays can be theme entries:<br>
--- `{theme = "metal", amount = 2, level = 3}`<br>
--- These are expanded into real ingredients/results based on the theme definitions.<br>
---<br>
--- One result entry can be marked as the product:<br>
--- `{type = "item", name = "my-widget", amount = 1, product = true}`<br>
--- The product is used to derive name, subgroup, order, localisation, and icon where not explicitly set.<br>
--- If no entry is marked, the first result is used as the product.<br>
--- The product is optional if all derived fields are provided explicitly.
--- @param prototype ExtendedRecipePrototype
--- @return data.RecipePrototype
function Tirislib.RecipeGenerator.create_from_prototype(prototype)
    -- consume and nil extra keys
    local unlock = prototype.unlock
    local default_theme_level = prototype.default_theme_level
    local index_fluid_ingredients = prototype.do_index_fluid_ingredients
    local index_fluid_results = prototype.do_index_fluid_results
    prototype.unlock = nil
    prototype.default_theme_level = nil
    prototype.do_index_fluid_ingredients = nil
    prototype.do_index_fluid_results = nil

    -- separate theme entries from real entries
    local real_ingredients, ingredient_theme_entries = separate_themes(prototype.ingredients)
    local real_results, result_theme_entries = separate_themes(prototype.results)
    prototype.ingredients = real_ingredients or {}
    prototype.results = real_results or {}

    -- find product and derive missing fields
    local product_entry = find_product_entry(prototype.results)
    derive_fields_from_product(prototype, product_entry)

    -- defaults
    if prototype.enabled == nil then
        prototype.enabled = true
    end
    prototype.energy_required = prototype.energy_required or 0.5

    -- track caller-provided values before creation
    local explicit_category = prototype.category
    local explicit_always_show_made_in = prototype.always_show_made_in

    -- create the recipe
    local recipe = Tirislib.Recipe.create(prototype)

    -- expand ingredient themes
    if ingredient_theme_entries then
        for _, entry in pairs(ingredient_theme_entries) do
            Tirislib.RecipeGenerator.add_ingredient_theme(
                recipe,
                {entry.theme, entry.amount or 1, entry.level},
                default_theme_level
            )
        end
        recipe:transform_ingredient_entries(function(e) Tirislib.RecipeEntry.transform_amount(e, math.floor) end)
    end

    -- expand result themes
    if result_theme_entries then
        for _, entry in pairs(result_theme_entries) do
            Tirislib.RecipeGenerator.add_result_theme(
                recipe,
                {entry.theme, entry.amount or 1, entry.level},
                default_theme_level
            )
        end
        recipe:transform_result_entries(function(e) Tirislib.RecipeEntry.transform_amount(e, math.floor) end)
    end

    -- unlock (accepts a single string or a table of strings)
    if type(unlock) == "table" then
        for _, tech in pairs(unlock) do
            recipe:add_unlock(tech)
        end
    elseif unlock then
        recipe:add_unlock(unlock)
    end

    -- category (auto-detect after themes are expanded so fluid ingredients are known)
    local category = explicit_category or get_standard_category(recipe)
    recipe:set_field("category", category)
    if explicit_always_show_made_in == nil then
        recipe:set_field("always_show_made_in", category ~= "crafting")
    end

    -- post-processing
    if index_fluid_ingredients then
        recipe:index_fluid_ingredients()
    end

    if index_fluid_results then
        recipe:index_fluid_results()
    end

    return recipe
end

local arrays = {"ingredients", "byproducts", "themes", "result_themes"}
arrays = Tirislib.Arrays.to_lookup(arrays)

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

local prototype_arrays = {ingredients = true, results = true}

--- Merges the right hand recipe prototype into the left hand recipe prototype.<br>
--- Array fields (`ingredients`, `results`) are concatenated (lh entries come first).<br>
--- This includes inline theme entries in both arrays.<br>
--- All other fields are set passively: a field already present in lh is never overwritten.
--- @param lh ExtendedRecipePrototype Prototype to merge into. Fields already set here take priority.
--- @param rh ExtendedRecipePrototype Prototype supplying defaults. Its arrays are appended to lh's arrays.
function Tirislib.RecipeGenerator.merge_prototypes(lh, rh)
    if not lh or not rh then
        return
    end

    for key, value in pairs(rh) do
        if prototype_arrays[key] then
            Tirislib.Tables.merge(Tirislib.Tables.get_subtbl(lh, key), value)
        else
            lh[key] = (lh[key] ~= nil) and lh[key] or value
        end
    end
end
