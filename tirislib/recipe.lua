---------------------------------------------------------------------------------------------------
-- << static class for Recipe Entries >>
-- those tables that the wiki calls ItemProductPrototype or FluidProductPrototype or IngredientPrototype
Tirislib.RecipeEntry = {}
local Entries = Tirislib.RecipeEntry

--- Converts the RecipeEntryPrototype to named keys if it uses the numbered keys.
--- @param entry RecipeEntryPrototype
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

--- Returns the name of the specified stuff.
--- @param entry RecipeEntryPrototype
--- @return string
function Entries.get_name(entry)
    return entry.name or entry[1]
end

--- Sets the name of the specified stuff.
--- @param entry table
--- @param name string
function Entries.set_name(entry, name)
    if entry[1] then
        entry[1] = name
    else
        entry.name = name
    end
end

--- Checks if the RecipeEntryPrototype specifies an item.
--- @param entry RecipeEntryPrototype
--- @return boolean
function Entries.yields_item(entry)
    if entry.type then
        return entry.type == "item"
    end
    return true
end

--- Checks if the RecipeEntryPrototype specifies a fluid.
--- @param entry RecipeEntryPrototype
--- @return boolean
function Entries.yields_fluid(entry)
    return entry.type == "fluid"
end

--- Returns the type of the specified stuff.
--- @param entry RecipeEntryPrototype
--- @return string
function Entries.get_type(entry)
    return entry.type or "item"
end

--- Sets the type of the specified stuff.
--- @param entry table
--- @param _type string
function Entries.set_type(entry, _type)
    Entries.convert_to_named_keys(entry)
    entry.type = _type
end

--- Checks if the given RecipeEntryPrototypes specify the same stuff.
--- @param entry1 RecipeEntryPrototype
--- @param entry2 RecipeEntryPrototype
--- @return boolean
function Entries.specify_same_stuff(entry1, entry2)
    return (Entries.get_name(entry1) == Entries.get_name(entry2)) and
        (Entries.get_type(entry1) == Entries.get_type(entry2))
end

--- Checks if the given RecipeEntryPrototype has a catalyst amound defined.
--- @param entry RecipeEntryPrototype
--- @return boolean
function Entries.has_catalyst(entry)
    return entry.catalyst_amount ~= nil
end

--- Sets the RecipeEntryPrototype's return amount to the given value.
--- @param entry table
--- @param value integer
function Entries.set_amount(entry, value)
    entry.amount = value
    entry[2] = nil
    entry.amount_min = nil
    entry.amount_max = nil
    entry.catalyst_amount = entry.catalyst_amount and value or nil
end

--- Returns the amount defined in this RecipeEntryPrototype, assuming it is an IngredientPrototype.
--- @param entry RecipeEntryPrototype
--- @return number
function Entries.get_ingredient_amount(entry)
    return entry.amount or entry[2]
end

--- Sets the amount of this RecipeEntryPrototype, assuming it is an IngredientPrototype.
--- @param entry RecipeEntryPrototype
--- @param min integer
--- @param max integer
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

--- Adds the given value to the given RecipeEntryPrototype's amount.
--- @param entry RecipeEntryPrototype
--- @param amount integer
function Entries.add_ingredient_amount(entry, amount)
    if entry.amount then
        entry.amount = entry.amount + amount
    elseif entry[2] then
        entry[2] = entry[2] + amount
    else
        error("Sosciencity found a IngredientPrototype without a valid amount:\n" .. serpent.block(entry))
    end
end

--- Multiplies this RecipeEntryPrototype's amount with the given multiplier.
--- @param entry RecipePrototype
--- @param multiplier number
function Entries.multiply_ingredient_amount(entry, multiplier)
    if entry.amount then
        entry.amount = entry.amount * multiplier
    elseif entry[2] then
        entry[2] = entry[2] * multiplier
    else
        error("Sosciencity found a IngredientPrototype without a valid amount:\n" .. serpent.block(entry))
    end
end

--- Transforms the given RecipeEntryPrototype's amount by the given function.
--- @param entry RecipeEntryPrototype
--- @param fn function
function Entries.transform_amount(entry, fn)
    if entry.amount then
        entry.amount = fn(entry.amount)
        entry.amount = math.max(entry.amount, 1)
    elseif entry[2] then
        entry[2] = fn(entry[2])
        entry[2] = math.max(entry[2], 1)
    elseif entry.amount_min then
        entry.amount_min = fn(entry.amount_min)
        entry.amount_max = fn(entry.amount_max)
    else
        error("Sosciencity found a RecipeEntry without a valid amount:\n" .. serpent.block(entry))
    end
end

--- Adds the given value to the given RecipeEntryPrototype's catalyst amount.
--- @param entry RecipeEntryPrototype
--- @param amount integer
function Entries.add_catalyst_amount(entry, amount)
    Entries.convert_to_named_keys(entry)

    entry.catalyst_amount = (entry.catalyst_amount or 0) + amount
end

--- Returns the average yield of the given RecipeEntryPrototype, assuming it's a ResultPrototype.
--- @param entry RecipeEntryPrototype
--- @return number yield
function Entries.get_average_yield(entry)
    local probability = entry.probability or 1

    if entry.amount_min then
        return (entry.amount_min + entry.amount_max) * 0.5 * probability
    end

    local amount = entry.amount or entry[2] or 1
    return amount * probability
end

--- Returns the average yield of the given RecipeEntryPrototype, assuming it's a ResultPrototype.
--- @param entry RecipeEntryPrototype
--- @return number yield
function Entries.get_max_yield(entry)
    if entry.amount_max then
        return entry.amount_max
    else
        return entry.amount or entry[2] or 1
    end
end

--- Returns the probability of the given RecipeEntryPrototype, assuming it's a ResultPrototype.
--- @param entry RecipeEntryPrototype
--- @return number
function Entries.get_probability(entry)
    return entry.probability or 1
end

--- Sets the probability for the given RecipeEntryPrototype, assuming it'S a ResultPrototype.
--- @param entry RecipeEntryPrototype
--- @param probability number
function Entries.set_probability(entry, probability)
    Entries.convert_to_named_keys(entry)
    entry.probability = probability
end

--- Checks if the given RecipeEntryPrototypes can be merged, meaning they specify the same stuff and have the same probability.
--- @param entry1 RecipeEntryPrototype
--- @param entry2 RecipeEntryPrototype
--- @return boolean
function Entries.can_be_merged(entry1, entry2)
    return Entries.specify_same_stuff(entry1, entry2) and
        Entries.get_probability(entry1) == Entries.get_probability(entry2)
end

--- Merges the given RecipeEntryPrototypes.
--- @param entry1 RecipeEntryPrototype
--- @param entry2 RecipeEntryPrototype
function Entries.merge(entry1, entry2)
    local min = entry2.amount_min or entry2.amount or entry2[2]
    local max = entry2.amount_max or entry2.amount or entry2[2]

    Entries.add_result_amount(entry1, min, max)
end

--- Creates a ResultPrototype for the given product and with the given average yield.
--- @param product string
--- @param amount number
--- @param _type string|nil defaults to 'item'
--- @return RecipeEntryPrototype|nil
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
Tirislib.Recipe = {}

--- Class for the part of a recipe that the wiki calls "recipe data", which exist for every difficulty.
Tirislib.RecipeData = {}

Tirislib.RecipeDifficulty = {
    undefined = "undefined",
    normal = "normal",
    expensive = "expensive"
}

-- this makes an object of this class call the class methods (if it has no own method)
-- lua is weird
Tirislib.Recipe.__index = Tirislib.Recipe

--- Class for arrays of recipes. Setter-functions can be called on them.
Tirislib.RecipeArray = {}
Tirislib.RecipeArray.__index = Tirislib.PrototypeArray.__index

-- << getter functions >>

--- Makes sure the recipe's main_product is set explicitly.
local function try_fix_main_product_pains(recipe, product)
    if not recipe.icon and not recipe.icons then
        for _, recipe_data in pairs(Tirislib.Recipe.get_recipe_datas(recipe)) do
            recipe_data.main_product = recipe_data.main_product or product or Tirislib.RecipeData.get_first_result(recipe_data)
        end
    end
end

--- Gets the RecipePrototype of the given name. If no such Recipe exists, a dummy object will be returned instead.
--- @param name string
--- @return RecipePrototype prototype
--- @return boolean found
function Tirislib.Recipe.get_by_name(name)
    local ret, found = Tirislib.Prototype.get("recipe", name, Tirislib.Recipe)
    return ret, found
end

--- Creates the RecipePrototype metatable for the given prototype.
--- @param prototype table
--- @return RecipePrototype
function Tirislib.Recipe.get_from_prototype(prototype)
    setmetatable(prototype, Tirislib.Recipe)
    return prototype
end

--- Unified function for the get_by_name and for the get_from_prototype functions.
--- @param name string|table
--- @return RecipePrototype prototype
--- @return boolean|nil found
function Tirislib.Recipe.get(name)
    if type(name) == "string" then
        return Tirislib.Recipe.get_by_name(name)
    else
        return Tirislib.Recipe.get_from_prototype(name)
    end
end

--- Creates an iterator over all RecipePrototypes.
--- @return function
--- @return string
--- @return RecipePrototype
function Tirislib.Recipe.iterate()
    local index, value

    local function _next()
        index, value = next(data.raw["recipe"] or {}, index)

        if index then
            setmetatable(value, Tirislib.Recipe)
            return index, value
        end
    end

    return _next, index, value
end

--- Returns an RecipePrototypeArray with all RecipePrototypes.
--- @return RecipePrototypeArray prototypes
function Tirislib.Recipe.all()
    local array = {}
    setmetatable(array, Tirislib.RecipeArray)

    for _, recipe in Tirislib.Recipe.iterate() do
        array[#array + 1] = recipe
    end

    return array
end

-- << creation >>

function Tirislib.RecipeData.add_ingredients_table(recipe_data)
    recipe_data.ingredients = recipe_data.ingredients or {}
end

function Tirislib.RecipeData.add_results_table(recipe_data)
    if not recipe_data.result and not recipe_data.results then
        recipe_data.results = {}
    end
end

local function add_basic_structure(prototype)
    prototype.type = prototype.type or "recipe"
    Tirislib.Recipe.call_on_recipe_data(prototype, Tirislib.RecipeData.add_ingredients_table)
    Tirislib.Recipe.call_on_recipe_data(prototype, Tirislib.RecipeData.add_results_table)
end

--- Creates an RecipePrototype from the given prototype table.
--- @param prototype table
--- @return RecipePrototype prototype
function Tirislib.Recipe.create(prototype)
    add_basic_structure(prototype)

    Tirislib.Prototype.create(prototype)
    return Tirislib.Recipe.get(prototype)
end

--- Copies the given RecipePrototype and adds the copy to data.raw. If the given recipe couldn't be found, a dummy object will be returned.
--- @param name string|table
--- @param new_name string
--- @return RecipePrototype prototype
--- @return boolean found
function Tirislib.Recipe.copy(name, new_name)
    local recipe, found = Tirislib.Recipe.get(name)

    if found then
        local new = Tirislib.Tables.recursive_copy(recipe)
        new.name = new_name
        return Tirislib.Recipe.create(new), true
    else
        return recipe --[[the dummy object]], false
    end
end

-- << manipulation >>

--- Checks if the recipe has a normal difficulty defined.
--- @return boolean
function Tirislib.Recipe:has_normal_difficulty()
    return self.normal ~= nil and self.normal ~= false
end

--- Checks if the recipe has an expensive difficulty defined.
--- @return boolean
function Tirislib.Recipe:has_expensive_difficulty()
    return self.expensive ~= nil and self.expensive ~= false
end

--- Checks if the recipe has an difficulties defined.
--- @return boolean
function Tirislib.Recipe:has_difficulties()
    return Tirislib.Recipe.has_normal_difficulty(self) or Tirislib.Recipe.has_expensive_difficulty(self)
end

--- Calls the given function of this recipe's recipe data.
--- @param fn function
--- @return any normal_return_value
--- @return any expensive_return_value
function Tirislib.Recipe:call_on_recipe_data(fn, ...)
    if not Tirislib.Recipe.has_difficulties(self) then
        return fn(self, ...)
    end
    local has_normal = Tirislib.Recipe.has_normal_difficulty(self)
    local has_expensive = Tirislib.Recipe.has_expensive_difficulty(self)

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

--- Calls the given function of this recipe's normal recipe data. If there are no difficulties defined,\
--- the function will be called on the recipe itself.
--- @param fn function
--- @return any return_values
function Tirislib.Recipe:call_on_normal_recipe_data(fn, ...)
    if not Tirislib.Recipe.has_difficulties(self) then
        return fn(self, ...)
    end
    if Tirislib.Recipe.has_normal_difficulty(self) then
        return fn(self.normal, ...)
    end
end

--- Calls the given function of this recipe's normal recipe data. If there are no difficulties defined,\
--- the function won't be called.
--- @param fn function
--- @return any return_values
function Tirislib.Recipe:call_on_expensive_recipe_data(fn, ...)
    if Tirislib.Recipe.has_expensive_difficulty(self) then
        return fn(self.expensive, ...)
    end
end

--- Returns the RecipeData objects defined in this RecipePrototype.
--- @return table recipe_datas
function Tirislib.Recipe:get_recipe_datas()
    if not Tirislib.Recipe.has_difficulties(self) then
        return {[Tirislib.RecipeDifficulty.undefined] = self}
    else
        return {
            [Tirislib.RecipeDifficulty.normal] = self.normal and self.normal or nil,
            [Tirislib.RecipeDifficulty.expensive] = self.expensive and self.expensive or nil
        }
    end
end

--- Default values for some possible keys.
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

--- Sets the given field to the given value.
--- - This function checks if the field belongs to recipe data.
--- @param key string
--- @param value any
--- @param expensive_value any
--- @return RecipePrototype itself
function Tirislib.Recipe:set_field(key, value, expensive_value)
    if recipe_data_fields[key] then
        if not Tirislib.Recipe.has_difficulties(self) then
            self[key] = value
        end
        if Tirislib.Recipe.has_normal_difficulty(self) then
            self.normal[key] = value
        end
        if Tirislib.Recipe.has_expensive_difficulty(self) then
            self.expensive[key] = expensive_value or value
        end
    else
        self[key] = value
    end

    return self
end

--- Sets the given recipe data field to the given value, in expensive mode.
--- @param key string
--- @param value any
--- @return RecipePrototype itself
function Tirislib.Recipe:set_expensive_field(key, value)
    if recipe_data_fields[key] then
        if Tirislib.Recipe.has_expensive_difficulty(self) then
            self.expensive[key] = value
        end
    end

    return self
end

--- Sets all of the given fields.
--- - This function checks if the field belongs to recipe data.
--- @param fields table
--- @return RecipePrototype itself
function Tirislib.Recipe:set_fields(fields)
    if fields then
        for key, value in pairs(fields) do
            Tirislib.Recipe.set_field(self, key, value)
        end
    end

    return self
end

--- Returns the content of the given field.
--- - This function checks if the field belongs to recipe data.
--- - If the field isn't set, the default value will be returned.
--- - The difficulty mode can be specified for fields that belong to recipe data.
--- - If the difficulty mode isn't specified and the field is recipe data, both values will be returned.
--- @param field string
--- @param mode string|nil
--- @return any normal
--- @return any expensive
function Tirislib.Recipe:get_field(field, mode)
    if mode then
        return self[mode][field] ~= nil and self[mode][field] or default_values[field]
    else
        if Tirislib.Recipe.has_difficulties(self) then
            local normal = self["normal"][field] ~= nil and self["normal"][field] or default_values[field]
            local expensive = self["expensive"][field] ~= nil and self["expensive"][field] or default_values[field]

            return normal, expensive
        else
            return self[field] ~= nil and self[field] or default_values[field]
        end
    end
end

--- Multiplies the content of the given field with the given multiplier.
--- - This function checks if the field belongs to recipe data.
--- - The multiplier for the expensive field can be specified. Otherwise the normal field will be used.
---@param field string
---@param normal_multiplier number
---@param expensive_multiplier number
---@return RecipePrototype itself
function Tirislib.Recipe:multiply_field(field, normal_multiplier, expensive_multiplier)
    -- use the normal multiplier if no expensive one is given
    expensive_multiplier = expensive_multiplier or normal_multiplier

    if not Tirislib.Recipe.has_difficulties(self) then
        self.energy_required = Tirislib.Recipe.get_field(self, field) * normal_multiplier
    else
        if Tirislib.Recipe.has_normal_difficulty(self) then
            self.normal.energy_required = Tirislib.Recipe.get_field(self, field, "normal") * normal_multiplier
        end
        if Tirislib.Recipe.has_expensive_difficulty(self) then
            self.expensive.energy_required = Tirislib.Recipe.get_field(self, field, "expensive") * expensive_multiplier
        end
    end

    return self
end

--- Multiplies the content of the given field with the given multiplier, in expensive mode.
---@param field string
---@param multiplier number
---@return RecipePrototype itself
function Tirislib.Recipe:multiply_expensive_field(field, multiplier)
    if Tirislib.Recipe.has_expensive_difficulty(self) then
        self.expensive[field] = Tirislib.Recipe.get_field(self, field, "expensive") * multiplier
    end
    return self
end

--- Copies the localisation of the item with the given name to this RecipePrototype.
--- @param item_name string
--- @return RecipePrototype itself
function Tirislib.Recipe:copy_localisation_from_item(item_name)
    if not item_name then
        item_name = self.name
    end

    local item, found = Tirislib.Item.get_by_name(item_name)

    if found then
        self.localised_name = item:get_localised_name()
        self.localised_description = item:get_localised_description()
    end

    return self
end

--- Copies the icon of the item with the given name to this RecipePrototype.
--- @param item_name string
--- @return RecipePrototype itself
function Tirislib.Recipe:copy_icon_from_item(item_name)
    if not item_name then
        item_name = self.name
    end

    local item, found = Tirislib.Item.get_by_name(item_name)

    if found then
        self.icon = item.icon
        self.icons = item.icons
        self.icon_size = item.icon_size
    end

    return self
end

--- Defines difficulties for this recipe, if they aren't defined already.
--- @return RecipePrototype itself
function Tirislib.Recipe:create_difficulties()
    -- silently do nothing if they already exist
    if Tirislib.Recipe.has_difficulties(self) then
        return self
    end

    self.normal = {}
    self.expensive = {}

    -- copy the data that the wiki calls "recipe data" and which need to be set for both difficulty modes
    for field, _ in pairs(recipe_data_fields) do
        if type(self[field]) == "table" then
            self.normal[field] = Tirislib.Tables.recursive_copy(self[field])
            self.expensive[field] = Tirislib.Tables.recursive_copy(self[field])
        else
            self.normal[field] = self[field]
            self.expensive[field] = self[field]
        end

        self[field] = nil
    end

    return self
end

--- Converts the result of this recipe data to a results table.\
--- (A single result can be defined in a different way. But it's way easier to work with a results table.)
--- @param recipe_data table
function Tirislib.RecipeData.convert_to_results_table(recipe_data)
    if not recipe_data.results then
        recipe_data.results = {
            {type = "item", name = recipe_data.result, amount = recipe_data.result_count or 1}
        }

        if recipe_data.result then
            recipe_data.main_product = recipe_data.main_product or recipe_data.result
            recipe_data.result = nil
            recipe_data.result_count = nil
        end
    end
end

function Tirislib.RecipeData.get_first_result(recipe_data)
    if recipe_data.result then
        return recipe_data.result
    end
    if recipe_data.results then
        for _, current_result in pairs(recipe_data.results) do
            return Entries.get_name(current_result)
        end
    end
end

--- Returns the name of the result of this recipe. If there is more than one result, then the first one will be returned.
--- @return string
function Tirislib.Recipe:get_first_result()
    return Tirislib.Recipe.call_on_recipe_data(self, Tirislib.RecipeData.get_first_result)
end

function Tirislib.RecipeData.get_result(recipe_data, name, _type)
    Tirislib.RecipeData.convert_to_results_table(recipe_data)

    for _, result in pairs(recipe_data.results) do
        if Entries.get_name(result) == name and Entries.get_type(result) == _type then
            return result
        end
    end
end

--- Returns the ResultPrototype for the specified result, if that recipe contains it.
--- @param name string
--- @param _type string
--- @return RecipeEntryPrototype
function Tirislib.Recipe:get_result(name, _type)
    return Tirislib.Recipe.call_on_recipe_data(self, Tirislib.RecipeData.get_result, name, _type)
end

function Tirislib.RecipeData.add_result(recipe_data, result, suppress_merge)
    Tirislib.RecipeData.convert_to_results_table(recipe_data)

    if not suppress_merge then
        for _, current_result in pairs(recipe_data.results) do
            if Entries.can_be_merged(current_result, result) then
                Entries.merge(current_result, result)
                return
            end
        end
    end

    table.insert(recipe_data.results, Tirislib.Tables.copy(result))
end

--- Adds the given result to the recipe.
--- - A different result for the expensive difficulty can be specified. Otherwise the normal one will be used.
--- @param result RecipeEntryPrototype|nil
--- @param expensive_result RecipeEntryPrototype|nil
--- @return RecipePrototype itself
function Tirislib.Recipe:add_result(result, expensive_result, suppress_merge)
    if not Tirislib.Recipe.has_difficulties(self) and result then
        Tirislib.RecipeData.add_result(self, result, suppress_merge)
        return self
    end

    if Tirislib.Recipe.has_normal_difficulty(self) and result then
        Tirislib.RecipeData.add_result(self.normal, result, suppress_merge)
    end
    if Tirislib.Recipe.has_expensive_difficulty(self) then
        Tirislib.RecipeData.add_result(self.expensive, expensive_result or result, suppress_merge)
    end
    return self
end

function Tirislib.RecipeData.add_results(recipe_data, results, suppress_merge)
    for _, entry in pairs(results) do
        Tirislib.RecipeData.add_result(recipe_data, entry, suppress_merge)
    end
end

--- Adds the given results to the recipe.
--- - Different results for the expensive difficulty can be specified. Otherwise the normal ones will be used.
--- @param results table of RecipeEntryPrototypes
--- @param expensive_results table of RecipeEntryPrototypes
--- @return RecipePrototype itself
function Tirislib.Recipe:add_result_range(results, expensive_results, suppress_merge)
    if not results and not expensive_results then
        return self
    end

    if not Tirislib.Recipe.has_difficulties(self) and results then
        Tirislib.RecipeData.add_results(self, results, suppress_merge)
        return self
    end

    if Tirislib.Recipe.has_normal_difficulty(self) and results then
        Tirislib.RecipeData.add_results(self.normal, results, suppress_merge)
    end
    if Tirislib.Recipe.has_expensive_difficulty(self) then
        Tirislib.RecipeData.add_results(self.expensive, expensive_results or results, suppress_merge)
    end
    return self
end

--- Adds a newly constructed RecipeEntryPrototype to the recipe.
--- @param result string
--- @param amount number
--- @param _type string|nil
--- @return RecipePrototype itself
function Tirislib.Recipe:add_new_result(result, amount, _type, suppress_merge)
    Tirislib.Recipe.add_result(
        self,
        Tirislib.RecipeEntry.create_result_prototype(result, amount, _type),
        nil,
        suppress_merge
    )

    return self
end

function Tirislib.RecipeData.get_first_ingredient(recipe_data)
    for _, current_ingredient in pairs(recipe_data.ingredients) do
        return Entries.get_name(current_ingredient)
    end
end

--- Returns the name of the ingredient of this recipe. If there is more than one ingredient, then the first one will be returned.
--- @return string
function Tirislib.Recipe:get_first_ingredient()
    return Tirislib.Recipe.call_on_recipe_data(self, Tirislib.RecipeData.get_first_ingredient)
end

function Tirislib.RecipeData.get_ingredient(recipe_data, name, _type)
    for _, ingredient in pairs(recipe_data.ingredients) do
        if Entries.get_name(ingredient) == name and Entries.get_type(ingredient) == _type then
            return ingredient
        end
    end
end

--- Returns the IngredientPrototype for the specified ingredient, if that recipe contains it.
--- @param name string
--- @param _type string
--- @return RecipeEntryPrototype
function Tirislib.Recipe:get_ingredient(name, _type)
    return Tirislib.Recipe.call_on_recipe_data(self, Tirislib.RecipeData.get_ingredient, name, _type)
end

function Tirislib.RecipeData.add_ingredient(recipe_data, ingredient)
    -- check if the recipe already has an entry for this ingredient
    for _, current_ingredient in pairs(recipe_data.ingredients) do
        if Tirislib.RecipeEntry.specify_same_stuff(current_ingredient, ingredient) then
            local ingredient_amount = Tirislib.RecipeEntry.get_ingredient_amount(ingredient)
            Tirislib.RecipeEntry.add_ingredient_amount(current_ingredient, ingredient_amount)

            if Tirislib.RecipeEntry.has_catalyst(current_ingredient) and Tirislib.RecipeEntry.has_catalyst(ingredient) then
                Tirislib.RecipeEntry.add_catalyst_amount(current_ingredient, ingredient.catalyst_amount)
            end
            return
        end
    end

    -- create a copy to avoid reference bugs
    table.insert(recipe_data.ingredients, Tirislib.Tables.copy(ingredient))
end

--- Adds the given ingredient to the recipe.
--- - A different ingredient for the expensive difficulty can be specified. Otherwise the normal one will be used.
--- @param ingredient RecipeEntryPrototype|nil
--- @param expensive_ingredient RecipeEntryPrototype|nil
--- @return RecipePrototype itself
function Tirislib.Recipe:add_ingredient(ingredient, expensive_ingredient)
    expensive_ingredient = expensive_ingredient or ingredient

    Tirislib.RecipeEntry.convert_to_named_keys(ingredient)
    Tirislib.RecipeEntry.convert_to_named_keys(expensive_ingredient)

    Tirislib.Recipe.call_on_normal_recipe_data(self, Tirislib.RecipeData.add_ingredient, ingredient)
    Tirislib.Recipe.call_on_expensive_recipe_data(self, Tirislib.RecipeData.add_ingredient, expensive_ingredient)

    return self
end

--- Adds the given ingredients to the recipe.
--- - Different ingredients for the expensive difficulty can be specified. Otherwise the normal ones will be used.
--- @param ingredients table|nil of RecipeEntryPrototypes
--- @param expensive_ingredients table|nil of RecipeEntryPrototypes
--- @return RecipePrototype itself
function Tirislib.Recipe:add_ingredient_range(ingredients, expensive_ingredients)
    if ingredients == nil and expensive_ingredients == nil then
        return self
    end

    if not Tirislib.Recipe.has_difficulties(self) then
        if ingredients then
            for _, entry in pairs(ingredients) do
                Tirislib.RecipeData.add_ingredient(self, entry)
            end
        end
        return self
    end

    if ingredients and Tirislib.Recipe.has_normal_difficulty(self) then
        for _, entry in pairs(ingredients) do
            Tirislib.RecipeData.add_ingredient(self.normal, entry)
        end
    end
    if Tirislib.Recipe.has_expensive_difficulty(self) then
        local ingredients_to_do = expensive_ingredients or ingredients

        for _, entry in pairs(ingredients_to_do) do
            Tirislib.RecipeData.add_ingredient(self.expensive, entry)
        end
    end

    return self
end

--- Adds a newly constructed RecipeEntryPrototype to the recipe.
--- @param ingredient string
--- @param amount number
--- @param _type string|nil
--- @return RecipePrototype itself
function Tirislib.Recipe:add_new_ingredient(ingredient, amount, _type)
    Tirislib.Recipe.add_ingredient(self, {type = _type or "item", name = ingredient, amount = amount})

    return self
end

function Tirislib.RecipeData.remove_ingredient(recipe_data, ingredient_name, ingredient_type)
    for index, ingredient in pairs(recipe_data.ingredients) do
        if
            Tirislib.RecipeEntry.get_name(ingredient) == ingredient_name and
                Tirislib.RecipeEntry.get_type(ingredient) == ingredient_type
         then
            recipe_data.ingredients[index] = nil
        end
    end
end

--- Removes the ingredient with the given name and type.
--- - If not given, the type defaults to 'item'
--- @param ingredient_name string
--- @param ingredient_type string
--- @return RecipePrototype itself
function Tirislib.Recipe:remove_ingredient(ingredient_name, ingredient_type)
    -- default to item if no type is given
    if not ingredient_type then
        ingredient_type = "item"
    end

    Tirislib.Recipe.call_on_recipe_data(self, Tirislib.RecipeData.remove_ingredient, ingredient_name, ingredient_type)

    return self
end

function Tirislib.RecipeData.remove_result(recipe_data, ingredient_name, ingredient_type)
    Tirislib.RecipeData.convert_to_results_table(recipe_data)

    for index, result in pairs(recipe_data.results) do
        if
            Tirislib.RecipeEntry.get_name(result) == ingredient_name and
                Tirislib.RecipeEntry.get_type(result) == ingredient_type
         then
            recipe_data.results[index] = nil
        end
    end
end

--- Removes the result with the given name and type.
--- - If not given, the type defaults to 'item'
--- @param ingredient_name string
--- @param ingredient_type string
--- @return RecipePrototype itself
function Tirislib.Recipe:remove_result(ingredient_name, ingredient_type)
    -- default to item if no type is given
    if not ingredient_type then
        ingredient_type = "item"
    end

    Tirislib.Recipe.call_on_recipe_data(self, Tirislib.RecipeData.remove_result, ingredient_name, ingredient_type)

    return self
end

function Tirislib.RecipeData.replace_ingredient(
    recipe_data,
    ingredient_name,
    ingredient_type,
    replacement_name,
    replacement_type,
    amount_fn)
    for _, ingredient in pairs(recipe_data.ingredients) do
        if Entries.get_name(ingredient) == ingredient_name and Entries.get_type(ingredient) == ingredient_type then
            Entries.set_name(ingredient, replacement_name)
            Entries.set_type(ingredient, replacement_type)
            if amount_fn then
                Entries.transform_amount(ingredient, amount_fn)
            end
        end
    end
end

--- Replaces the specified ingredient.
--- @param ingredient_name string
--- @param replacement_name string
--- @param ingredient_type string
--- @param replacement_type string
--- @param amount_fn function
--- @return RecipePrototype itself
function Tirislib.Recipe:replace_ingredient(
    ingredient_name,
    replacement_name,
    ingredient_type,
    replacement_type,
    amount_fn)
    ingredient_type = ingredient_type or "item"
    replacement_name = replacement_name or "item"

    Tirislib.Recipe.call_on_recipe_data(
        self,
        Tirislib.RecipeData.replace_ingredient,
        ingredient_name,
        ingredient_type,
        replacement_name,
        replacement_type,
        amount_fn
    )

    return self
end

function Tirislib.RecipeData.replace_result(
    recipe_data,
    result_name,
    result_type,
    replacement_name,
    replacement_type,
    amount_fn)
    Tirislib.RecipeData.convert_to_results_table(recipe_data)

    for _, result in pairs(recipe_data.results) do
        if Entries.get_name(result) == result_name and Entries.get_type(result) == result_type then
            Entries.set_name(result, replacement_name)
            Entries.set_type(result, replacement_type)
            if amount_fn then
                Entries.transform_amount(result, amount_fn)
            end
        end
    end
end

--- Replaces the specified ingredient.
--- @param result_name string
--- @param replacement_name string
--- @param result_type string
--- @param replacement_type string
--- @param amount_fn function
--- @return RecipePrototype itself
function Tirislib.Recipe:replace_result(result_name, replacement_name, result_type, replacement_type, amount_fn)
    result_type = result_type or "item"
    replacement_name = replacement_name or "item"

    Tirislib.Recipe.call_on_recipe_data(
        self,
        Tirislib.RecipeData.replace_result,
        result_name,
        result_type,
        replacement_name,
        replacement_type,
        amount_fn
    )

    return self
end

--- Adds a catalyst to the recipe. That means an ingredient that is also an output.
--- @param catalyst string
--- @param catalyst_type string
--- @param amount integer
--- @param retrieval number probability
--- @param expensive_amount integer
--- @param expensive_retrieval number probability
--- @return RecipePrototype itself
function Tirislib.Recipe:add_catalyst(catalyst, catalyst_type, amount, retrieval, expensive_amount, expensive_retrieval)
    catalyst_type = catalyst_type or "item"

    retrieval = retrieval or 1
    expensive_retrieval = expensive_retrieval or retrieval

    amount = amount or 1
    expensive_amount = expensive_amount or amount

    if retrieval ~= expensive_retrieval or amount ~= expensive_amount then
        Tirislib.Recipe.create_difficulties(self)
    end

    Tirislib.Recipe.add_ingredient(
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
    Tirislib.Recipe.add_result(
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

function Tirislib.RecipeData.clear_ingredients(recipe_data)
    recipe_data.ingredients = {}
end

--- Removes all ingredients.
--- @return RecipePrototype itself
function Tirislib.Recipe:clear_ingredients()
    Tirislib.Recipe.call_on_recipe_data(self, Tirislib.RecipeData.clear_ingredients)

    return self
end

function Tirislib.RecipeData.clear_results(recipe_data)
    Tirislib.RecipeData.convert_to_results_table(recipe_data)
    recipe_data.results = {}
end

--- Removes all results.
--- @return RecipePrototype itself
function Tirislib.Recipe:clear_results()
    Tirislib.Recipe.call_on_recipe_data(self, Tirislib.RecipeData.clear_results)

    return self
end

--- Kinda deprecated. Sets the enabled field for the recipe.
--- @param normal any
--- @param expensive any
--- @return RecipePrototype itself
function Tirislib.Recipe:set_enabled(normal, expensive)
    Tirislib.Recipe.set_field(self, "enabled", normal, expensive)

    return self
end

--- Adds an unlock effect for this recipe to the given technology.
--- @param technology_name string
--- @return RecipePrototype itself
function Tirislib.Recipe:add_unlock(technology_name)
    if not technology_name then
        return self
    end

    Tirislib.Recipe.set_enabled(self, false)
    local tech, found = Tirislib.Technology.get_by_name(technology_name)

    if found then
        tech:add_unlock(self.name)
    else
        Tirislib.Prototype.postpone(Tirislib.Recipe.add_unlock, self, technology_name)
    end

    return self
end

function Tirislib.RecipeData.set_ingredient_amounts(recipe_data, value)
    for _, entry in pairs(recipe_data.ingredients) do
        Tirislib.RecipeEntry.set_amount(entry, value)
    end
end

--- Sets the amounts of all ingredients to the given value.
--- @param value integer
--- @param expensive_value integer
--- @return RecipePrototype itself
function Tirislib.Recipe:set_ingredient_amounts(value, expensive_value)
    Tirislib.Recipe.call_on_normal_recipe_data(self, Tirislib.RecipeData.set_ingredient_amounts, value)
    Tirislib.Recipe.call_on_expensive_recipe_data(
        self,
        Tirislib.RecipeData.set_ingredient_amounts,
        expensive_value or value
    )

    return self
end

function Tirislib.RecipeData.set_result_amounts(recipe_data, value)
    Tirislib.RecipeData.convert_to_results_table(recipe_data)

    for _, entry in pairs(recipe_data.results) do
        Tirislib.RecipeEntry.set_amount(entry, value)
    end
end

--- Sets the amounts of all results to the given value.
--- @param value integer
--- @param expensive_value integer
--- @return RecipePrototype itself
function Tirislib.Recipe:set_result_amounts(value, expensive_value)
    Tirislib.Recipe.call_on_normal_recipe_data(self, Tirislib.RecipeData.set_result_amounts, value)
    Tirislib.Recipe.call_on_expensive_recipe_data(
        self,
        Tirislib.RecipeData.set_result_amounts,
        expensive_value or value
    )

    return self
end

function Tirislib.RecipeData.multiply_ingredient_amounts(recipe_data, multiplier)
    for _, ingredient in pairs(recipe_data.ingredients) do
        Tirislib.RecipeEntry.multiply_ingredient_amount(ingredient, multiplier)
    end
end

--- Multiplies the amounts of all ingredients with the given multiplier.
--- @param normal_multiplier number
--- @param expensive_multiplier number
--- @return RecipePrototype itself
function Tirislib.Recipe:multiply_ingredients(normal_multiplier, expensive_multiplier)
    normal_multiplier = normal_multiplier or 1
    expensive_multiplier = expensive_multiplier or normal_multiplier or 1

    for difficulty, recipe_data in pairs(Tirislib.Recipe.get_recipe_datas(self)) do
        Tirislib.RecipeData.multiply_ingredient_amounts(
            recipe_data,
            (difficulty == Tirislib.RecipeDifficulty.expensive) and expensive_multiplier or normal_multiplier
        )
    end

    return self
end

--- Multiplies the amounts of all ingredients in expensive mode with the given multiplier.
--- @param multiplier number
--- @return RecipePrototype itself
function Tirislib.Recipe:multiply_expensive_ingredients(multiplier)
    multiplier = multiplier or 1

    if Tirislib.Recipe.has_expensive_difficulty(self) then
        Tirislib.RecipeData.multiply_ingredient_amounts(self.expensive, multiplier)
    end

    return self
end

function Tirislib.RecipeData.ceil_ingredient_amounts(recipe_data)
    for _, ingredient in pairs(recipe_data.ingredients) do
        Entries.transform_amount(ingredient, math.ceil)
    end
end

--- Rounds all ingredient amounts up. Makes sure that they are integers.
--- @return RecipePrototype itself
function Tirislib.Recipe:ceil_ingredients()
    Tirislib.Recipe.call_on_recipe_data(self, Tirislib.RecipeData.ceil_ingredient_amounts)

    return self
end

function Tirislib.RecipeData.floor_ingredient_amounts(recipe_data)
    for _, ingredient in pairs(recipe_data.results) do
        Entries.transform_amount(ingredient, math.floor)
    end
end

--- Rounds all ingredient amounts down, but not to zero. Makes sure that they are integers.
--- @return RecipePrototype itself
function Tirislib.Recipe:floor_ingredients()
    Tirislib.Recipe.call_on_recipe_data(self, Tirislib.RecipeData.floor_ingredient_amounts)

    return self
end

function Tirislib.RecipeData.ceil_result_amounts(recipe_data)
    if recipe_data.results then
        for _, result in pairs(recipe_data.results) do
            Entries.transform_amount(result, math.ceil)
        end
    elseif recipe_data.result_count then
        recipe_data.result_count = math.ceil(recipe_data.result_count)
    end
end

--- Rounds all result amounts up. Makes sure that they are integers.
--- @return RecipePrototype itself
function Tirislib.Recipe:ceil_results()
    Tirislib.Recipe.call_on_recipe_data(self, Tirislib.RecipeData.ceil_result_amounts)

    return self
end

function Tirislib.RecipeData.floor_result_amounts(recipe_data)
    if recipe_data.results then
        for _, result in pairs(recipe_data.results) do
            Entries.transform_amount(result, math.floor)
        end
    elseif recipe_data.result_count then
        recipe_data.result_count = math.max(math.floor(recipe_data.result_count), 1)
    end
end

--- Rounds all result amounts down, but not to zero. Makes sure that they are integers.
--- @return RecipePrototype itself
function Tirislib.Recipe:floor_results()
    Tirislib.Recipe.call_on_recipe_data(self, Tirislib.RecipeData.floor_result_amounts)

    return self
end

function Tirislib.RecipeData.transform_ingredient_entries(recipe_data, fn)
    for _, entry in pairs(recipe_data.ingredients) do
        fn(entry)
    end
end

--- Transforms all ingredient entries with the given function.
--- @param fn function
--- @return RecipePrototype itself
function Tirislib.Recipe:transform_ingredient_entries(fn)
    Tirislib.Recipe.call_on_recipe_data(self, Tirislib.RecipeData.transform_ingredient_entries, fn)

    return self
end

function Tirislib.RecipeData.transform_result_entries(recipe_data, fn)
    Tirislib.RecipeData.convert_to_results_table(recipe_data)

    for _, entry in pairs(recipe_data.results) do
        fn(entry)
    end
end

--- Transforms all result entries with the given function.
--- @param fn function
--- @return RecipePrototype itself
function Tirislib.Recipe:transform_result_entries(fn)
    Tirislib.Recipe.call_on_recipe_data(self, Tirislib.RecipeData.transform_result_entries, fn)

    return self
end

function Tirislib.RecipeData.index_fluid_ingredients(recipe_data)
    local index = 1
    for _, entry in pairs(recipe_data.ingredients) do
        if Entries.get_type(entry) == "fluid" then
            entry.fluidbox_index = index
            index = index + 1
        end
    end
end

--- Sets the fluidbox index for every fluid ingredient consecutively.
--- @return RecipePrototype itself
function Tirislib.Recipe:index_fluid_ingredients()
    Tirislib.Recipe.call_on_recipe_data(self, Tirislib.RecipeData.index_fluid_ingredients)

    return self
end

function Tirislib.RecipeData.index_fluid_results(recipe_data)
    Tirislib.RecipeData.convert_to_results_table(recipe_data)

    local index = 1
    for _, entry in pairs(recipe_data.results) do
        if Entries.get_type(entry) == "fluid" then
            entry.fluidbox_index = index
            index = index + 1
        end
    end
end

--- Sets the fluidbox index for every fluid result consecutively.
--- @return RecipePrototype itself
function Tirislib.Recipe:index_fluid_results()
    Tirislib.Recipe.call_on_recipe_data(self, Tirislib.RecipeData.index_fluid_results)

    return self
end

--- Adds the recipe to all productivity module's whitelist.
--- @return RecipePrototype
function Tirislib.Recipe:allow_productivity_modules()
    Tirislib.Prototype.add_recipe_to_productivity_modules(self.name)

    return self
end

-- << analyze >>
-- these functions often have the trouble of the recipe definitions having too many options and pitfalls
-- keep difficulties in mind when using them

function Tirislib.RecipeData.results_contain(recipe_data, name, _type)
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

--- Checks if the recipe has the result with the given name and type.
--- @param name string
--- @param _type string
--- @return boolean
function Tirislib.Recipe:has_result(name, _type)
    _type = _type or "item"

    return Tirislib.Recipe.call_on_recipe_data(self, Tirislib.RecipeData.results_contain, name, _type)
end

function Tirislib.RecipeData.get_result_amount(recipe_data, name, _type)
    if recipe_data.results then
        local amount = 0
        for _, result in pairs(recipe_data.results) do
            if Tirislib.RecipeEntry.get_name(result) == name and Tirislib.RecipeEntry.get_type(result) == _type then
                amount = amount + Tirislib.RecipeEntry.get_average_yield(result)
            end
        end
        return amount
    end

    if _type == "item" and recipe_data.result == name then
        return recipe_data.result_count or 1 -- factorio defaults to 1 if no result_count is specified
    end

    return 0
end

--- Returns the average yield of the result with the given name and type.
--- @param name string
--- @param _type string
--- @return RecipePrototype itself
function Tirislib.Recipe:get_result_count(name, _type)
    _type = _type or "item"

    return Tirislib.Recipe.call_on_recipe_data(self, Tirislib.RecipeData.get_result_amount, name, _type)
end

function Tirislib.RecipeData.ingredients_contain(recipe_data, name, _type)
    _type = _type or "item"

    for _, entry in pairs(recipe_data.ingredients) do
        if Entries.get_type(entry) == "item" and Entries.get_name(entry) == name then
            return true
        end
    end
    return false
end

--- Checks if the recipe has the ingredient with the given name and type.
--- @param name string
--- @param _type string
--- @return boolean
function Tirislib.Recipe:has_ingredient(name, _type)
    return Tirislib.Recipe.call_on_recipe_data(self, Tirislib.RecipeData.ingredients_contain, name, _type)
end

function Tirislib.RecipeData.get_ingredient_amount(recipe_data, name, _type)
    for _, ingredient in pairs(recipe_data.ingredients or {}) do
        if Tirislib.RecipeEntry.get_name(ingredient) == name and Tirislib.RecipeEntry.get_type(ingredient) == _type then
            return Tirislib.RecipeEntry.get_ingredient_amount(ingredient)
        end
    end

    return 0
end

--- Returns the count of the ingredient with the given name and type.
--- @param name string
--- @param _type string|nil
--- @return RecipePrototype itself
function Tirislib.Recipe:get_ingredient_count(name, _type)
    _type = _type or "item"

    return Tirislib.Recipe.call_on_recipe_data(self, Tirislib.RecipeData.get_ingredient_amount, name, _type)
end

-- << high level >>

function Tirislib.RecipeData.pair_result_with_ingredient(
    recipe_data,
    result,
    result_type,
    ingredient,
    ingredient_type,
    amount_fn)
    local result_amount = Tirislib.RecipeData.get_result_amount(recipe_data, result, result_type)
    if result_amount == 0 then
        return
    end

    local amount = amount_fn and amount_fn(result_amount) or result_amount
    Tirislib.RecipeData.add_ingredient(
        recipe_data,
        {
            type = ingredient_type,
            name = ingredient,
            amount = math.ceil(amount)
        }
    )
end

--- Adds the given ingredient to the recipe, if it contains the given result.
--- @param result string
--- @param result_type string
--- @param ingredient string
--- @param ingredient_type string
--- @param amount_fn function
--- @return RecipePrototype itself
function Tirislib.Recipe:pair_result_with_ingredient(result, result_type, ingredient, ingredient_type, amount_fn)
    Tirislib.Recipe.call_on_recipe_data(
        self,
        Tirislib.RecipeData.pair_result_with_ingredient,
        result,
        result_type,
        ingredient,
        ingredient_type,
        amount_fn
    )

    return self
end

function Tirislib.RecipeData.pair_result_with_result(
    recipe_data,
    result,
    result_type,
    result_to_add,
    result_to_add_type,
    amount_fn)
    local result_amount = Tirislib.RecipeData.get_result_amount(recipe_data, result, result_type)
    if result_amount == 0 then
        return false
    end

    local amount = amount_fn and amount_fn(result_amount) or result_amount
    Tirislib.RecipeData.add_result(
        recipe_data,
        {
            type = result_to_add_type,
            name = result_to_add,
            amount = math.ceil(amount)
        }
    )

    return true
end

--- Adds the given result to the recipe, if it contains the given result.
--- @param result string
--- @param result_type string
--- @param result_to_add string
--- @param result_to_add_type string
--- @param amount_fn function
--- @return RecipePrototype itself
function Tirislib.Recipe:pair_result_with_result(result, result_type, result_to_add, result_to_add_type, amount_fn)
    local normal, expensive = Tirislib.Recipe.call_on_recipe_data(
        self,
        Tirislib.RecipeData.pair_result_with_result,
        result,
        result_type,
        result_to_add,
        result_to_add_type,
        amount_fn
    )

    if normal or expensive then
        try_fix_main_product_pains(self, result)
    end

    return self
end

function Tirislib.RecipeData.pair_ingredient_with_result(
    recipe_data,
    result,
    result_type,
    ingredient,
    ingredient_type,
    amount_fn,
    probability)
    local ingredient_amount = Tirislib.RecipeData.get_ingredient_amount(recipe_data, result, result_type)
    if ingredient_amount == 0 then
        return false
    end

    local amount = amount_fn and amount_fn(ingredient_amount) or ingredient_amount
    Tirislib.RecipeData.add_result(
        recipe_data,
        {
            type = ingredient_type,
            name = ingredient,
            amount = math.ceil(amount),
            probability = probability
        }
    )

    return true
end

--- Adds the given result to the recipe, if it contains the given ingredient.
--- @param ingredient string
--- @param ingredient_type string
--- @param result string
--- @param result_type string
--- @param amount_fn function|nil
--- @param probability number|nil
--- @return RecipePrototype itself
function Tirislib.Recipe:pair_ingredient_with_result(
    ingredient,
    ingredient_type,
    result,
    result_type,
    amount_fn,
    probability)
    local normal, expensive = Tirislib.Recipe.call_on_recipe_data(
        self,
        Tirislib.RecipeData.pair_ingredient_with_result,
        ingredient,
        ingredient_type,
        result,
        result_type,
        amount_fn,
        probability
    )

    if normal or expensive then
        try_fix_main_product_pains(self, result)
    end

    return self
end

-- << meta stuff >>
local meta = {
    __index = Tirislib.BasePrototype
}

function meta:__call(name)
    return Tirislib.Recipe.get(name)
end

setmetatable(Tirislib.Recipe, meta)
