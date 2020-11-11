---------------------------------------------------------------------------------------------------
-- << static class for Recipe Entries >>
-- those tables that the wiki calls ItemProductPrototype or FluidProductPrototype or IngredientPrototype
Tirislib_RecipeEntry = {}
local Entries = Tirislib_RecipeEntry

function Entries.convert_to_named_keys(entry)
    if entry[1] then
        entry.name = entry[1]
        entry[1] = nil
    end
    if entry[2] then
        entry.amount = entry[2]
        entry[2] = nil
    end
    if not entry.type then
        entry.type = "item"
    end
end

function Entries.get_name(entry)
    return entry.name or entry[1]
end

function Entries.set_name(entry, name)
    if entry[1] then
        entry[1] = name
    else
        entry.name = name
    end
end

function Entries.yields_item(entry)
    if entry.type then
        return entry.type == "item"
    end
    return true
end

function Entries.yields_fluid(entry)
    return (entry.type ~= nil) and (entry.type == "fluid")
end

function Entries.get_type(entry)
    return entry.type or "item"
end

function Entries.specify_same_stuff(entry1, entry2)
    return (Entries.get_name(entry1) == Entries.get_name(entry2)) and
        (Entries.get_type(entry1) == Entries.get_type(entry2))
end

function Entries.has_catalyst(entry)
    return entry.catalyst_amount ~= nil
end

function Entries.set_amount(entry, value)
    entry.amount = value
    entry[2] = nil
    entry.amount_min = nil
    entry.amount_max = nil
    entry.catalyst_amount = entry.catalyst_amount and value or nil
end

function Entries.get_ingredient_amount(entry)
    local ret = entry.amount or entry[2]
    if not ret then
        error("Sosciencity found a IngredientPrototype without a valid amount:\n" .. serpent.block(entry))
    end
    return ret
end

function Entries.add_result_amount(entry, min, max)
    if not max or min == max then
        if entry.amount_min then
            entry.amount_min = entry.amount_min + min
            entry.amount_max = entry.amount_max + min
        elseif entry.amount then
            entry.amount = entry.amount + min
        elseif entry[2] then
            entry[2] = entry[2] + min
        else
            -- I don't actually know if ResultPrototypes without a specified amount are valid
            -- I will just assume they default to 1
            Entries.convert_to_named_keys(entry)
            entry.amount = min + 1
        end
    else
        Entries.convert_to_named_keys(entry)
        entry.amount_min = (entry.amount_min or entry.amount) + min
        entry.amount_max = (entry.amount_max or entry.amount) + max
        entry.amount = nil
    end
end

function Entries.add_ingredient_amount(entry, amount)
    if entry.amount then
        entry.amount = entry.amount + amount
    elseif entry[2] then
        entry[2] = entry[2] + amount
    else
        error("Sosciencity found a IngredientPrototype without a valid amount:\n" .. serpent.block(entry))
    end
end

function Entries.multiply_ingredient_amount(entry, multiplier)
    if entry.amount then
        entry.amount = entry.amount * multiplier
    elseif entry[2] then
        entry[2] = entry[2] * multiplier
    else
        error("Sosciencity found a IngredientPrototype without a valid amount:\n" .. serpent.block(entry))
    end
end

function Entries.transform_amount(entry, fn)
    if entry.amount then
        entry.amount = fn(entry.amount)
    elseif entry[2] then
        entry[2] = fn(entry[2])
    elseif entry.amount_min then
        entry.amount_min = fn(entry.amount_min)
        entry.amount_max = fn(entry.amount_max)
    else
        error("Sosciencity found a RecipeEntry without a valid amount:\n" .. serpent.block(entry))
    end
end

function Entries.add_catalyst_amount(entry, amount)
    entry.catalyst_amount = (entry.catalyst_amount or 0) + amount

    if entry[2] then
        entry.amount = entry[2]
        entry[2] = nil
    end
end

function Entries.get_average_yield(entry)
    local probability = entry.probability or 1

    if entry.amount_min then
        return (entry.amount_min + entry.amount_max) * 0.5 * probability
    end

    local amount = entry.amount or entry[2] or 1
    return amount * probability
end

function Entries.get_probability(entry)
    return entry.probability or 1
end

function Entries.can_be_merged(entry1, entry2)
    return Entries.specify_same_stuff(entry1, entry2) and
        Entries.get_probability(entry1) == Entries.get_probability(entry2)
end

function Entries.merge(entry1, entry2)
    local min = entry2.amount_min or entry2.amount or entry2[2]
    local max = entry2.amount_max or entry2.amount or entry2[2]

    Entries.add_result_amount(entry1, min, max)
end

function Entries.create_result_prototype(product, amount, _type)
    if amount > 0 then
        local ret = {type = _type or "item", name = product}

        if amount < 1 then
            ret.amount = 1
            ret.probability = amount
        elseif math.floor(amount) == amount then -- amount doesn't have decimals
            ret.amount = amount
        else
            -- close enough solution
            ret.amount_min = math.floor(amount)
            ret.amount_max = math.ceil(amount)
        end

        return ret
    end
end

---------------------------------------------------------------------------------------------------
-- << class for recipes >>
Tirislib_Recipe = {}

-- this makes an object of this class call the class methods (if it has no own method)
-- lua is weird
Tirislib_Recipe.__index = Tirislib_Recipe

--- Class for arrays of items. Setter-functions can be called on them.
Tirislib_RecipeArray = {}
Tirislib_RecipeArray.__index = Tirislib_PrototypeArray.__index

-- << getter functions >>
function Tirislib_Recipe.get_by_name(name)
    return Tirislib_Prototype.get("recipe", name, Tirislib_Recipe)
end

function Tirislib_Recipe.get_from_prototype(prototype)
    setmetatable(prototype, Tirislib_Recipe)
    return prototype
end

function Tirislib_Recipe.get(name)
    if type(name) == "string" then
        return Tirislib_Recipe.get_by_name(name)
    else
        return Tirislib_Recipe.get_from_prototype(name)
    end
end

function Tirislib_Recipe.iterate()
    local index, value

    local function _next()
        index, value = next(data.raw["recipe"], index)

        if index then
            setmetatable(value, Tirislib_Recipe)
            return index, value
        end
    end

    return _next, index, value
end

function Tirislib_Recipe.all()
    local array = {}
    setmetatable(array, Tirislib_RecipeArray)

    for _, recipe in Tirislib_Recipe.iterate() do
        array[#array + 1] = recipe
    end

    return array
end

-- << creation >>
local function add_ingredients_table(recipe_data)
    recipe_data.ingredients = recipe_data.ingredients or {}
end

local function add_results_table(recipe_data)
    if not recipe_data.result and not recipe_data.results then
        recipe_data.results = {}
    end
end

local function add_basic_structure(prototype)
    prototype.type = "recipe"
    Tirislib_Recipe.call_on_recipe_data(prototype, add_ingredients_table)
    Tirislib_Recipe.call_on_recipe_data(prototype, add_results_table)
end

function Tirislib_Recipe.create(prototype)
    add_basic_structure(prototype)

    data:extend {prototype}
    return Tirislib_Recipe.get(prototype)
end

-- << manipulation >>
function Tirislib_Recipe:has_normal_difficulty()
    return self.normal
end

function Tirislib_Recipe:has_expensive_difficulty()
    return self.expensive
end

function Tirislib_Recipe:has_difficulties()
    return Tirislib_Recipe.has_normal_difficulty(self) or Tirislib_Recipe.has_expensive_difficulty(self)
end

function Tirislib_Recipe:call_on_recipe_data(fn, ...)
    if not Tirislib_Recipe.has_difficulties(self) then
        return fn(self, ...)
    end
    local has_normal = Tirislib_Recipe.has_normal_difficulty(self)
    local has_expensive = Tirislib_Recipe.has_expensive_difficulty(self)

    if has_normal then
        if has_expensive then
            return fn(self.normal, ...), fn(self.expensive, ...)
        else
            return fn(self.normal, ...)
        end
    else
        return nil, fn(self.expensive, ...)
    end
end

function Tirislib_Recipe:call_on_normal_recipe_data(fn, ...)
    if not Tirislib_Recipe.has_difficulties(self) then
        return fn(self, ...)
    end
    if Tirislib_Recipe.has_normal_difficulty(self) then
        return fn(self.normal, ...)
    end
end

function Tirislib_Recipe:call_on_expensive_recipe_data(fn, ...)
    if Tirislib_Recipe.has_expensive_difficulty(self) then
        return fn(self.expensive, ...)
    end
end

local default_values = {
    category = "crafting",
    result_count = 1,
    energy_required = 0.5,
    emissions_multiplier = 1,
    requester_paste_multiplier = 30,
    overload_multiplier = 0,
    enabled = true,
    hidden = false,
    hide_from_stats = false,
    hide_from_player_crafting = false,
    allow_decomposition = true,
    allow_as_intermediate = true,
    allow_intermediates = true,
    always_show_made_in = false,
    show_amount_in_title = true,
    always_show_products = false
}

--- The prototype fields that the wiki calls "recipe data".
--- These are defined for each difficulty.
local recipe_data_fields = {
    ingredients = true,
    result = true,
    result_count = true,
    results = true,
    energy_required = true,
    emissions_multiplier = true,
    requester_paste_multiplier = true,
    overload_multiplier = true,
    enabled = true,
    hidden = true,
    hide_from_stats = true,
    hide_from_player_crafting = true,
    allow_decomposition = true,
    allow_as_intermediate = true,
    allow_intermediates = true,
    always_show_made_in = true,
    show_amount_in_title = true,
    always_show_products = true,
    main_product = true
}

function Tirislib_Recipe:set_field(key, value)
    if recipe_data_fields[key] then
        if not Tirislib_Recipe.has_difficulties(self) then
            self[key] = value
        end
        if Tirislib_Recipe.has_normal_difficulty(self) then
            self.normal[key] = value
        end
        if Tirislib_Recipe.has_expensive_difficulty(self) then
            self.expensive[key] = value
        end
    else
        self[key] = value
    end

    return self
end

function Tirislib_Recipe:set_expensive_field(key, value)
    if recipe_data_fields[key] then
        if Tirislib_Recipe.has_expensive_difficulty(self) then
            self.expensive[key] = value
        end
    end

    return self
end

function Tirislib_Recipe:set_fields(fields)
    if fields then
        for key, value in pairs(fields) do
            Tirislib_Recipe.set_field(self, key, value)
        end
    end

    return self
end

function Tirislib_Recipe:get_field(field, mode)
    local ret
    if mode then
        ret = self[mode][field]
    else
        if Tirislib_Recipe.has_difficulties(self) then
            ret = self["normal"][field]
        else
            ret = self[field]
        end
    end

    return ret or default_values[field]
end

function Tirislib_Recipe:multiply_field(field, normal_multiplier, expensive_multiplier)
    -- use the normal multiplier if no expensive one is given
    expensive_multiplier = expensive_multiplier or normal_multiplier

    if not Tirislib_Recipe.has_difficulties(self) then
        self.energy_required = Tirislib_Recipe.get_field(self, field) * normal_multiplier
    else
        if Tirislib_Recipe.has_normal_difficulty(self) then
            self.normal.energy_required = Tirislib_Recipe.get_field(self, field, "normal") * normal_multiplier
        end
        if Tirislib_Recipe.has_expensive_difficulty(self) then
            self.expensive.energy_required = Tirislib_Recipe.get_field(self, field, "expensive") * expensive_multiplier
        end
    end

    return self
end

function Tirislib_Recipe:multiply_expensive_field(field, multiplier)
    if Tirislib_Recipe.has_expensive_difficulty(self) then
        self.expensive[field] = Tirislib_Recipe.get_field(self, field, "expensive") * multiplier
    end
    return self
end

function Tirislib_Recipe:create_difficulties()
    -- silently do nothing if they already exist
    if Tirislib_Recipe.has_difficulties(self) then
        return self
    end

    self.normal = {}
    self.expensive = {}

    -- copy the data that the wiki calls "recipe data" and which need to be set for both difficulty modes
    for field, _ in pairs(recipe_data_fields) do
        if type(self[field]) == "table" then
            self.normal[field] = Tirislib_Tables.recursive_copy(self[field])
            self.expensive[field] = Tirislib_Tables.recursive_copy(self[field])
        else
            self.normal[field] = self[field]
            self.expensive[field] = self[field]
        end

        self[field] = nil
    end

    return self
end

local function convert_to_results_table(recipe_data)
    if recipe_data.result and not recipe_data.results then
        recipe_data.results = {
            {type = "item", name = recipe_data.result, amount = recipe_data.result_count or 1}
        }

        recipe_data.result = nil
        recipe_data.result_count = nil
    end
end

local function add_result(recipe_data, result)
    convert_to_results_table(recipe_data)

    for _, current_result in pairs(recipe_data.results) do
        if Entries.can_be_merged(current_result, result) then
            Entries.merge(current_result, result)
            return
        end
    end

    table.insert(recipe_data.results, Tirislib_Tables.copy(result))
end

function Tirislib_Recipe:add_result(result, expensive_result)
    if not Tirislib_Recipe.has_difficulties(self) and result then
        add_result(self, result)
        return self
    end

    if Tirislib_Recipe.has_normal_difficulty(self) and result then
        add_result(self.normal, result)
    end
    if Tirislib_Recipe.has_expensive_difficulty(self) then
        add_result(self.expensive, expensive_result or result)
    end
    return self
end

local function add_results(recipe_data, results)
    for _, entry in pairs(results) do
        add_result(recipe_data, entry)
    end
end

function Tirislib_Recipe:add_result_range(results, expensive_results)
    if not results and not expensive_results then
        return self
    end

    if not Tirislib_Recipe.has_difficulties(self) and results then
        add_results(self, results)
        return self
    end

    if Tirislib_Recipe.has_normal_difficulty(self) and results then
        add_results(self.normal, results)
    end
    if Tirislib_Recipe.has_expensive_difficulty(self) then
        add_results(self.expensive, expensive_results or results)
    end
    return self
end

--- Adds a newly constructed ResultPrototype to the recipe.
function Tirislib_Recipe:add_new_result(result, amount, _type)
    Tirislib_Recipe.add_result(self, Tirislib_RecipeEntry.create_result_prototype(result, amount, _type))
end

local function add_ingredient(recipe_data, ingredient)
    -- check if the recipe already has an entry for this ingredient
    for _, current_ingredient in pairs(recipe_data.ingredients) do
        if Tirislib_RecipeEntry.specify_same_stuff(current_ingredient, ingredient) then
            local ingredient_amount = Tirislib_RecipeEntry.get_ingredient_amount(ingredient)
            Tirislib_RecipeEntry.add_ingredient_amount(current_ingredient, ingredient_amount)

            if Tirislib_RecipeEntry.has_catalyst(current_ingredient) and Tirislib_RecipeEntry.has_catalyst(ingredient) then
                Tirislib_RecipeEntry.add_catalyst_amount(current_ingredient, ingredient.catalyst_amount)
            end
            return
        end
    end

    -- create a copy to avoid reference bugs
    table.insert(recipe_data.ingredients, Tirislib_Tables.copy(ingredient))
end

function Tirislib_Recipe:add_ingredient(ingredient, expensive_ingredient)
    expensive_ingredient = expensive_ingredient or ingredient

    Tirislib_RecipeEntry.convert_to_named_keys(ingredient)
    Tirislib_RecipeEntry.convert_to_named_keys(expensive_ingredient)

    Tirislib_Recipe.call_on_normal_recipe_data(self, add_ingredient, ingredient)
    Tirislib_Recipe.call_on_expensive_recipe_data(self, add_ingredient, expensive_ingredient)

    return self
end

function Tirislib_Recipe:add_ingredient_range(ingredients, expensive_ingredients)
    if ingredients == nil and expensive_ingredients == nil then
        return self
    end

    if not Tirislib_Recipe.has_difficulties(self) then
        if ingredients then
            for _, entry in pairs(ingredients) do
                add_ingredient(self, entry)
            end
        end
        return self
    end

    if ingredients and Tirislib_Recipe.has_normal_difficulty(self) then
        for _, entry in pairs(ingredients) do
            add_ingredient(self.normal, entry)
        end
    end
    if Tirislib_Recipe.has_expensive_difficulty(self) then
        local ingredients_to_do = expensive_ingredients or ingredients

        for _, entry in pairs(ingredients_to_do) do
            add_ingredient(self.expensive, entry)
        end
    end

    return self
end

function Tirislib_Recipe:add_new_ingredient(ingredient, amount, _type)
    Tirislib_Recipe.add_ingredient(self, {type = _type or "item", name = ingredient, amount = amount})
end

local function remove_ingredient(recipe_data, ingredient_name, ingredient_type)
    for index, ingredient in pairs(recipe_data.ingredients) do
        if
            Tirislib_RecipeEntry.get_name(ingredient) == ingredient_name and
                Tirislib_RecipeEntry.get_type(ingredient) == ingredient_type
         then
            recipe_data.ingredients[index] = nil
        end
    end
end

function Tirislib_Recipe:remove_ingredient(ingredient_name, ingredient_type)
    -- default to item if no type is given
    if not ingredient_type then
        ingredient_type = "item"
    end

    Tirislib_Recipe.call_on_recipe_data(self, remove_ingredient, ingredient_name, ingredient_type)

    return self
end

local function remove_result(recipe_data, ingredient_name, ingredient_type)
    convert_to_results_table(recipe_data)

    for index, result in pairs(recipe_data.results) do
        if
            Tirislib_RecipeEntry.get_name(result) == ingredient_name and
                Tirislib_RecipeEntry.get_type(result) == ingredient_type
         then
            recipe_data.results[index] = nil
        end
    end
end

function Tirislib_Recipe:remove_result(ingredient_name, ingredient_type)
    -- default to item if no type is given
    if not ingredient_type then
        ingredient_type = "item"
    end

    Tirislib_Recipe.call_on_recipe_data(self, remove_result, ingredient_name, ingredient_type)

    return self
end

local function replace_ingredient(recipe_data, ingredient_name, replacement_name)
    for _, ingredient in pairs(recipe_data.ingredients) do
        if Tirislib_RecipeEntry.get_name(ingredient) == ingredient_name then
            Tirislib_RecipeEntry.set_name(ingredient, replacement_name)
        end
    end
end

function Tirislib_Recipe:replace_ingredient(ingredient_name, replacement_name)
    Tirislib_Recipe.call_on_recipe_data(self, replace_ingredient, ingredient_name, replacement_name)

    return self
end

function Tirislib_Recipe:add_catalyst(catalyst, catalyst_type, amount, retrieval, expensive_amount, expensive_retrieval)
    catalyst_type = catalyst_type or "item"

    retrieval = retrieval or 1
    expensive_retrieval = expensive_retrieval or retrieval

    amount = amount or 1
    expensive_amount = expensive_amount or amount

    Tirislib_Recipe.add_ingredient(
        self,
        {
            type = catalyst_type,
            name = catalyst,
            amount = amount,
            catalyst_amount = amount
        },
        {
            type = catalyst_type,
            name = catalyst,
            amount = expensive_amount,
            catalyst_amount = expensive_amount
        }
    )
    Tirislib_Recipe.add_result(
        self,
        {
            type = catalyst_type,
            name = catalyst,
            amount = amount,
            catalyst_amount = amount,
            probability = retrieval
        },
        {
            type = catalyst_type,
            name = catalyst,
            amount = expensive_amount,
            catalyst_amount = expensive_amount,
            probability = expensive_retrieval
        }
    )

    return self
end

local function clear_ingredients(recipe_data)
    recipe_data.ingredients = {}
end

function Tirislib_Recipe:clear_ingredients()
    Tirislib_Recipe.call_on_recipe_data(self, clear_ingredients)

    return self
end

local function clear_results(recipe_data)
    convert_to_results_table(recipe_data)
    recipe_data.results = {}
end

function Tirislib_Recipe:clear_results()
    Tirislib_Recipe.call_on_recipe_data(self, clear_results)

    return self
end

function Tirislib_Recipe:set_enabled(normal, expensive)
    if not expensive then
        self.enabled = normal
        expensive = normal
    else
        self.enabled = nil
    end

    if self.normal then
        self.normal.enabled = normal
    end
    if self.expensive then
        self.expensive.enabled = expensive
    end
end

function Tirislib_Recipe:add_unlock(technology_name)
    if not technology_name then
        return self
    end

    Tirislib_Recipe.set_enabled(self, false)
    local tech = Tirislib_Technology.get_by_name(technology_name)

    if tech then
        tech:add_unlock(self.name)
    else
        Tirislib_Prototype.postpone {
            recipe = self,
            technology = technology_name,
            execute = function(self)
                self.recipe:add_unlock(self.technology)
            end
        }
    end

    return self
end

local function set_ingredient_amounts(recipe_data, value)
    for _, entry in pairs(recipe_data.ingredients) do
        Tirislib_RecipeEntry.set_amount(entry, value)
    end
end

function Tirislib_Recipe:set_ingredient_amounts(value, expensive_value)
    Tirislib_Recipe.call_on_normal_recipe_data(self, set_ingredient_amounts, value)
    Tirislib_Recipe.call_on_expensive_recipe_data(self, set_ingredient_amounts, expensive_value or value)

    return self
end

local function set_result_amounts(recipe_data, value)
    convert_to_results_table(recipe_data)

    for _, entry in pairs(recipe_data.results) do
        Tirislib_RecipeEntry.set_amount(entry, value)
    end
end

function Tirislib_Recipe:set_result_amounts(value, expensive_value)
    Tirislib_Recipe.call_on_normal_recipe_data(self, set_result_amounts, value)
    Tirislib_Recipe.call_on_expensive_recipe_data(self, set_result_amounts, expensive_value or value)

    return self
end

local function multiply_ingredient_table_amounts(ingredients, multiplier)
    for _, ingredient in pairs(ingredients) do
        Tirislib_RecipeEntry.multiply_ingredient_amount(ingredient, multiplier)
    end
end

function Tirislib_Recipe:multiply_ingredients(normal_multiplier, expensive_multiplier)
    normal_multiplier = normal_multiplier or 1
    expensive_multiplier = expensive_multiplier or 1

    if not Tirislib_Recipe.has_difficulties(self) then
        multiply_ingredient_table_amounts(self.ingredients, normal_multiplier)
    else
        if Tirislib_Recipe.has_normal_difficulty(self) then
            multiply_ingredient_table_amounts(self.normal.ingredients, normal_multiplier)
        end
        if Tirislib_Recipe.has_expensive_difficulty(self) then
            multiply_ingredient_table_amounts(self.expensive.ingredients, expensive_multiplier or normal_multiplier)
        end
    end

    return self
end

function Tirislib_Recipe:multiply_expensive_ingredients(multiplier)
    multiplier = multiplier or 1

    if Tirislib_Recipe.has_expensive_difficulty(self) then
        multiply_ingredient_table_amounts(self.expensive.ingredients, multiplier)
    end

    return self
end

local function ceil_ingredient_amounts(recipe_data)
    for _, ingredient in pairs(recipe_data.ingredients) do
        Entries.transform_amount(ingredient, math.ceil)
    end
end

function Tirislib_Recipe:ceil_ingredients()
    Tirislib_Recipe.call_on_recipe_data(self, ceil_ingredient_amounts)

    return self
end

local function floor_savely(n)
    return math.max(math.floor(n), 1)
end

local function floor_ingredient_amounts(recipe_data)
    for _, ingredient in pairs(recipe_data.results) do
        Entries.transform_amount(ingredient, floor_savely)
    end
end

function Tirislib_Recipe:floor_ingredients()
    Tirislib_Recipe.call_on_recipe_data(self, floor_ingredient_amounts)

    return self
end

local function ceil_result_amounts(recipe_data)
    if recipe_data.results then
        for _, result in pairs(recipe_data.results) do
            Entries.transform_amount(result, math.ceil)
        end
    elseif recipe_data.result_count then
        recipe_data.result_count = math.ceil(recipe_data.result_count)
    end
end

function Tirislib_Recipe:ceil_results()
    Tirislib_Recipe.call_on_recipe_data(self, ceil_result_amounts)

    return self
end

local function floor_result_amounts(recipe_data)
    if recipe_data.results then
        for _, result in pairs(recipe_data.results) do
            Entries.transform_amount(result, floor_savely)
        end
    elseif recipe_data.result_count then
        recipe_data.result_count = floor_savely(recipe_data.result_count)
    end
end

function Tirislib_Recipe:floor_results()
    Tirislib_Recipe.call_on_recipe_data(self, floor_result_amounts)

    return self
end

local function transform_ingredient_entries(recipe_data, fn)
    for _, entry in pairs(recipe_data.ingredients) do
        fn(entry)
    end
end

function Tirislib_Recipe:transform_ingredient_entries(fn)
    Tirislib_Recipe.call_on_recipe_data(self, transform_ingredient_entries, fn)

    return self
end

local function transform_result_entries(recipe_data, fn)
    convert_to_results_table(recipe_data)

    for _, entry in pairs(recipe_data.results) do
        fn(entry)
    end
end

function Tirislib_Recipe:transform_result_entries(fn)
    Tirislib_Recipe.call_on_recipe_data(self, transform_result_entries, fn)

    return self
end

function Tirislib_Recipe:allow_productivity_modules()
    Tirislib_Prototype.add_recipe_to_productivity_modules(self.name)

    return self
end

-- << analyze >>
-- these functions often have the trouble of the recipe definitions having too many options and pitfalls
-- keep difficulties in mind when using them
local function results_contain(recipe_data, name, _type)
    if recipe_data.results then
        for _, entry in pairs(recipe_data.results) do
            if Entries.get_type(entry) == "item" and Entries.get_name(entry) == name then
                return true
            end
        end
    end
    if _type == "item" and recipe_data.result == name then
        return true
    end
    return false
end

function Tirislib_Recipe:has_result(name, _type)
    _type = _type or "item"

    return Tirislib_Recipe.call_on_recipe_data(self, results_contain, name, _type)
end

local function get_result_count(recipe_data, name, _type)
    if recipe_data.results then
        for _, result in pairs(recipe_data.results) do
            if Tirislib_RecipeEntry.get_name(result) == name and Tirislib_RecipeEntry.get_type(result) == _type then
                return Tirislib_RecipeEntry.get_average_yield(result)
            end
        end
        return 0
    end
    if _type == "item" and recipe_data.result == name then
        return recipe_data.result_count or 1 -- factorio defaults to 1 if no result_count is specified
    end

    return 0
end

function Tirislib_Recipe:get_result_count(name, _type)
    _type = _type or "item"

    return Tirislib_Recipe.call_on_recipe_data(self, get_result_count, name, _type)
end

local function ingredients_contain(recipe_data, name, _type)
    _type = _type or "item"

    for _, entry in pairs(recipe_data.ingredients) do
        if Entries.get_type(entry) == "item" and Entries.get_name(entry) == name then
            return true
        end
    end
    return false
end

function Tirislib_Recipe:has_ingredient(name, _type)
    return Tirislib_Recipe.call_on_recipe_data(self, ingredients_contain, name, _type)
end

-- << high level >>
local function pair_ingredient_with_result(recipe_data, result, result_type, ingredient, ingredient_type, amount_fn)
    local result_amount = get_result_count(recipe_data, result, result_type)
    if result_amount == 0 then
        return
    end

    local amount = amount_fn and amount_fn(result_amount) or result_amount
    add_ingredient(
        recipe_data,
        {
            type = ingredient_type,
            name = ingredient,
            amount = math.ceil(amount)
        }
    )
end

function Tirislib_Recipe:pair_result_with_ingredient(result, result_type, ingredient, ingredient_type, amount_fn)
    Tirislib_Recipe.call_on_recipe_data(
        self,
        pair_ingredient_with_result,
        result,
        result_type,
        ingredient,
        ingredient_type,
        amount_fn
    )

    return self
end

-- << meta stuff >>
local meta = {}

function meta:__call(name)
    return Tirislib_Recipe.get(name)
end

setmetatable(Tirislib_Recipe, meta)
