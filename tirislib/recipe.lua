---------------------------------------------------------------------------------------------------
-- << static class for Recipe Entries >>

-- Functions for ItemProductPrototype, FluidProductPrototype, ItemIngredientPrototype and FluidIngredientPrototype.
Tirislib.RecipeEntry = {}

--- Sets the RecipeEntryPrototype's return amount to the given value.
--- @param entry table
--- @param min integer
--- @param max integer|nil
function Tirislib.RecipeEntry.set_product_amount(entry, min, max)
    if not max then
        entry.amount = min
        entry.amount_min = nil
        entry.amount_max = nil
    else
        entry.amount = nil
        entry.amount_min = min
        entry.amount_max = max
    end
end

--- Adds to the amount of this RecipeEntryPrototype, assuming it is an IngredientPrototype.
--- @param entry RecipeEntryPrototype
--- @param min integer
--- @param max integer|nil
function Tirislib.RecipeEntry.add_product_amount(entry, min, max)
    if not max or min == max then
        if entry.amount_min then
            entry.amount_min = entry.amount_min + min
            entry.amount_max = entry.amount_max + min
        else
            entry.amount = entry.amount + min
        end
    else
        entry.amount_min = (entry.amount_min or entry.amount) + min
        entry.amount_max = (entry.amount_max or entry.amount) + max
        entry.amount = nil
    end
end

--- Multiplies this RecipeEntryPrototype's amount with the given multiplier.
--- @param entry RecipePrototype
--- @param multiplier number
function Tirislib.RecipeEntry.multiply_ingredient_amount(entry, multiplier)
    entry.amount = entry.amount * multiplier
end

--- Transforms the given RecipeEntryPrototype's amount by the given function.
--- @param entry RecipeEntryPrototype
--- @param fn function
function Tirislib.RecipeEntry.transform_amount(entry, fn)
    if entry.amount then
        entry.amount = fn(entry.amount)
        entry.amount = math.max(entry.amount, 1)
    elseif entry.amount_min then
        entry.amount_min = fn(entry.amount_min)
        entry.amount_max = fn(entry.amount_max)
    end
end

--- Returns the average yield of the given RecipeEntryPrototype, assuming it's a ProductPrototype.
--- @param entry RecipeEntryPrototype
--- @return number yield
function Tirislib.RecipeEntry.get_average_yield(entry)
    local probability = entry.probability or 1

    if entry.amount_min then
        return (entry.amount_min + entry.amount_max) * 0.5 * probability
    else
        return entry.amount * probability
    end
end

--- Returns the average yield of the given RecipeEntryPrototype, assuming it's a ProductPrototype.
--- @param entry RecipeEntryPrototype
--- @return number yield
function Tirislib.RecipeEntry.get_max_yield(entry)
    return entry.amount_max or entry.amount
end

--- Returns the probability of the given RecipeEntryPrototype, assuming it's a ProductPrototype.
--- @param entry RecipeEntryPrototype
--- @return number
function Tirislib.RecipeEntry.get_probability(entry)
    return entry.probability or 1
end

function Tirislib.RecipeEntry.get_percent_spoiled(entry)
    return entry.percent_spoiled or 0
end

--- Checks if the given RecipeEntryPrototypes can be merged, meaning they specify the same stuff and have the same probability.
--- @param lh RecipeEntryPrototype
--- @param rh RecipeEntryPrototype
--- @return boolean
function Tirislib.RecipeEntry.can_be_merged(lh, rh)
    -- for FluidProductPrototypes
    if rh.fluidbox_index and lh.fluidbox_index ~= rh.fluidbox_index then
        return false
    end

    return (lh.name == rh.name) and (lh.type == rh.type) and -- generic for all Ingredient-/ProductPrototypes
        Tirislib.RecipeEntry.get_probability(lh) == Tirislib.RecipeEntry.get_probability(rh) and -- for ProductPrototypes
        Tirislib.RecipeEntry.get_percent_spoiled(lh) == Tirislib.RecipeEntry.get_percent_spoiled(rh) and -- for ItemProductPrototypes
        lh.temperature == rh.temperature and -- for FluidProductPrototypes
        lh.minimum_temperature == rh.minimum_temperature and -- for FluidIngredientPrototypes
        lh.maximum_temperature == rh.maximum_temperature -- for FluidIngredientPrototypes
end

--- Merges the given right hand RecipeEntryPrototype into the given left hand RecipeEntryPrototype.
--- @param lh RecipeEntryPrototype
--- @param rh RecipeEntryPrototype
function Tirislib.RecipeEntry.merge(lh, rh)
    local min = rh.amount_min or rh.amount
    local max = rh.amount_max or rh.amount

    Tirislib.RecipeEntry.add_product_amount(lh, min, max)

    if rh.ignored_by_stats then
        lh.ignored_by_stats = (lh.ignored_by_stats or 0) + rh.ignored_by_stats
    end
    if rh.ignored_by_productivity then
        lh.ignored_by_productivity = (lh.ignored_by_productivity or 0) + rh.ignored_by_productivity
    end
    if rh.extra_count_fraction then
        lh.extra_count_fraction = (lh.extra_count_fraction or 0) + rh.extra_count_fraction

        if lh.extra_count_fraction >= 1 then
            local overhang = math.floor(lh.extra_count_fraction)
            lh.extra_count_fraction = lh.extra_count_fraction - overhang
            Tirislib.RecipeEntry.add_product_amount(lh, overhang)
        end
    end
end

--- Creates a ProductPrototype for the given product and with the given average yield.
--- @param product ItemID|FluidID
--- @param amount number
--- @param _type string|nil defaults to 'item'
--- @return RecipeEntryPrototype|nil
function Tirislib.RecipeEntry.create_product_prototype(product, amount, _type)
    if amount > 0 then
        local ret = {type = _type or "item", name = product}

        if amount < 1 then
            ret.amount = 1
            ret.probability = amount
        elseif math.floor(amount) == amount then -- amount doesn't have decimals
            ret.amount = amount
        else
            ret.amount = math.floor(amount)
            ret.extra_count_fraction = amount - math.floor(amount)
        end

        return ret
    end
end

---------------------------------------------------------------------------------------------------
-- << class for recipes >>
Tirislib.Recipe = {}

-- this makes an object of this class call the class methods (if it has no own method)
-- lua is weird
Tirislib.Recipe.__index = Tirislib.Recipe

--- Class for arrays of recipes. Setter-functions can be called on them.
Tirislib.RecipeArray = {}
Tirislib.RecipeArray.__index = Tirislib.PrototypeArray.__index

-- << getter functions >>

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

local function add_basic_structure(prototype)
    prototype.type = prototype.type or "recipe"
    prototype.ingredients = prototype.ingredients or {}
    prototype.results = prototype.results or {}
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

--- Iterator over the recipe's ingredients. Makes sure the ingredients table is set. 
--- @return function
--- @return table
function Tirislib.Recipe:iterate_ingredients()
    self.ingredients = self.ingredients or {}
    return next, self.ingredients
end

--- Iterator over the recipe's results. Makes sure the results table is set. 
--- @return function
--- @return table
function Tirislib.Recipe:iterate_results()
    self.results = self.results or {}
    return next, self.results
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

--- Sets the given field to the given value.
--- @param key string
--- @param value any
--- @return RecipePrototype itself
function Tirislib.Recipe:set_field(key, value)
    self[key] = value

    return self
end

--- Sets all of the given fields.
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
--- - If the field isn't set, the default value will be returned.
--- @param field string
--- @return any value of the field
function Tirislib.Recipe:get_field(field)
    return self[field] ~= nil and self[field] or default_values[field]
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

--- Returns the name of the result of this recipe. If there is more than one result, then the first one will be returned.
--- @return string
function Tirislib.Recipe:get_first_result()
    for _, current_result in Tirislib.Recipe.iterate_results(self) do
        return current_result.name
    end
end

--- Returns the ProductPrototype for the specified result, if that recipe contains it.
--- @param name string
--- @param _type string
--- @return RecipeEntryPrototype|nil
function Tirislib.Recipe:get_result(name, _type)
    for _, result in Tirislib.Recipe.iterate_results(self) do
        if result.name == name and result.type == _type then
            return result
        end
    end
end

--- Adds the given result to the recipe.
--- @param result RecipeEntryPrototype|nil
--- @return RecipePrototype itself
function Tirislib.Recipe:add_result(result, suppress_merge)
    if not result then
        return self
    end

    if not suppress_merge then
        for _, current_result in Tirislib.Recipe.iterate_results(self) do
            if Tirislib.RecipeEntry.can_be_merged(current_result, result) then
                Tirislib.RecipeEntry.merge(current_result, result)
                return self
            end
        end
    end

    table.insert(self.results, Tirislib.Tables.copy(result))
    return self
end

--- Adds the given results to the recipe.
--- @param results table of RecipeEntryPrototypes
--- @param suppress_merge boolean if the result should be merged with a similar other result prototype
--- @return RecipePrototype itself
function Tirislib.Recipe:add_result_range(results, suppress_merge)
    if not results then
        return self
    end

    for _, entry in pairs(results) do
        Tirislib.Recipe.add_result(self, entry, suppress_merge)
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
        Tirislib.RecipeEntry.create_product_prototype(result, amount, _type),
        suppress_merge
    )

    return self
end

--- Returns the name of the ingredient of this recipe. If there is more than one ingredient, then the first one will be returned.
--- @return string
function Tirislib.Recipe:get_first_ingredient()
    for _, current_ingredient in Tirislib.Recipe:iterate_ingredients() do
        return current_ingredient.name
    end
end

--- Returns the IngredientPrototype for the specified ingredient, if that recipe contains it.
--- @param name string
--- @param _type string
--- @return RecipeEntryPrototype|nil
function Tirislib.Recipe:get_ingredient(name, _type)
    for _, ingredient in Tirislib.Recipe:iterate_ingredients() do
        if ingredient.name == name and ingredient.type == _type then
            return ingredient
        end
    end
end

--- Adds the given ingredient to the recipe.
--- @param ingredient RecipeEntryPrototype|nil
--- @return RecipePrototype itself
function Tirislib.Recipe:add_ingredient(ingredient)
    if not ingredient then
        return self
    end

    -- check if the recipe already has an entry for this ingredient
    for _, current_ingredient in Tirislib.Recipe:iterate_ingredients() do
        if Tirislib.RecipeEntry.can_be_merged(current_ingredient, ingredient) then
            Tirislib.RecipeEntry.merge(current_ingredient, ingredient)
            return self
        end
    end

    -- create a copy to avoid reference bugs
    table.insert(self.ingredients, Tirislib.Tables.copy(ingredient))
    return self
end

--- Adds the given ingredients to the recipe.
--- @param ingredients table|nil of RecipeEntryPrototypes
--- @return RecipePrototype itself
function Tirislib.Recipe:add_ingredient_range(ingredients)
    if not ingredients then
        return self
    end

    for _, entry in Tirislib.Recipe:iterate_ingredients() do
        Tirislib.Recipe.add_ingredient(self, entry)
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

--- Removes the ingredient with the given name and type.
--- @param name string
--- @param _type string|nil defaults to 'item'
--- @return RecipePrototype itself
function Tirislib.Recipe:remove_ingredient(name, _type)
    _type = _type or "item"

    local foundindex = {}
    for index, ingredient in Tirislib.Recipe:iterate_ingredients() do
        if ingredient.name == name and ingredient.type == _type then
            foundindex[#foundindex + 1] = index
        end
    end

    for _, index in pairs(foundindex) do
        table.remove(self.ingredients, index)
    end

    return self
end

--- Removes the results with the given name and type.
--- @param name string
--- @param _type string|nil defaults to 'item'
--- @return RecipePrototype itself
function Tirislib.Recipe:remove_result(name, _type)
    _type = _type or "item"

    local foundindex = {}
    for index, result in Tirislib.Recipe.iterate_results(self) do
        if result.name == name and result.type == _type then
            foundindex[#foundindex + 1] = index
        end
    end

    for _, index in pairs(foundindex) do
        table.remove(self.results, index)
    end

    return self
end

--- Replaces the specified ingredient.
--- @param name string
--- @param replacement_name string
--- @param _type string|nil defaults to 'item'
--- @param replacement_type string|nil defaults to 'item'
--- @param amount_fn function|nil defaults to identity
--- @return RecipePrototype itself
function Tirislib.Recipe:replace_ingredient(name, replacement_name, _type, replacement_type, amount_fn)
    _type = _type or "item"
    replacement_type = replacement_type or "item"

    for _, ingredient in Tirislib.Recipe.iterate_ingredients(self) do
        if ingredient.name == name and ingredient.type == _type then
            ingredient.name = replacement_name
            ingredient.type = replacement_type
            if amount_fn then
                Tirislib.RecipeEntry.transform_amount(ingredient, amount_fn)
            end
        end
    end

    return self
end

--- Replaces the specified ingredient.
--- @param result_name string
--- @param replacement_name string
--- @param result_type string|nil defaults to 'item'
--- @param replacement_type string|nil defaults to 'item'
--- @param amount_fn function|nil defaults to identity
--- @return RecipePrototype itself
function Tirislib.Recipe:replace_result(result_name, replacement_name, result_type, replacement_type, amount_fn)
    result_type = result_type or "item"
    replacement_name = replacement_name or "item"

    for _, result in Tirislib.Recipe.iterate_results(self) do
        if result.name == result_name and result.type == result_type then
            result.name = replacement_name
            result.type = replacement_type
            if amount_fn then
                Tirislib.RecipeEntry.transform_amount(result, amount_fn)
            end
        end
    end

    return self
end

--- Adds a catalyst to the recipe. That means an ingredient that is also an output.
--- @param name string
--- @param _type string
--- @param amount integer
--- @param retrieval number probability
--- @return RecipePrototype itself
function Tirislib.Recipe:add_catalyst(name, _type, amount, retrieval)
    _type = _type or "item"

    retrieval = retrieval or 1
    amount = amount or 1

    Tirislib.Recipe.add_ingredient(
        self,
        {
            type = _type,
            name = name,
            amount = amount,
            ignored_by_stats = amount,
            ignored_by_productivity = amount
        }
    )
    Tirislib.Recipe.add_result(
        self,
        {
            type = _type,
            name = name,
            amount = amount,
            ignored_by_stats = amount,
            ignored_by_productivity = amount,
            probability = retrieval
        }
    )

    return self
end

--- Removes all ingredients.
--- @return RecipePrototype itself
function Tirislib.Recipe:clear_ingredients()
    self.ingredients = {}
    return self
end

--- Removes all results.
--- @return RecipePrototype itself
function Tirislib.Recipe:clear_results()
    self.results = {}
    return self
end

--- Adds an unlock effect for this recipe to the given technology.
--- @param technology_name string
--- @return RecipePrototype itself
function Tirislib.Recipe:add_unlock(technology_name)
    if not technology_name then
        return self
    end

    local tech, found = Tirislib.Technology.get_by_name(technology_name)

    if found then
        Tirislib.Recipe.set_field(self, "enabled", false)
        tech:add_unlock(self.name)
    else
        Tirislib.Prototype.postpone(Tirislib.Recipe.add_unlock, self, technology_name)
    end

    return self
end

--- Rounds all ingredient amounts down, but not to zero. Makes sure that they are integers.
--- @return RecipePrototype itself
function Tirislib.Recipe:floor_ingredients()
    -- TODO: Leaving this in for the moment. But I think this kind of function might not be a good idea

    for _, ingredient in Tirislib.Recipe.iterate_ingredients(self) do
        Tirislib.RecipeEntry.transform_amount(ingredient, math.floor)
    end

    return self
end

--- Rounds all result amounts down, but not to zero. Makes sure that they are integers.
--- @return RecipePrototype itself
function Tirislib.Recipe:floor_results()
    -- TODO: Leaving this in for the moment. But I think this kind of function might not be a good idea

    for _, result in Tirislib.Recipe.iterate_results(self) do
        Tirislib.RecipeEntry.transform_amount(result, math.floor)
    end

    return self
end

--- Transforms all ingredient entries with the given function.
--- @param fn function
--- @return RecipePrototype itself
function Tirislib.Recipe:transform_ingredient_entries(fn)
    for _, entry in Tirislib.Recipe:iterate_ingredients() do
        fn(entry)
    end

    return self
end

--- Transforms all result entries with the given function.
--- @param fn function
--- @return RecipePrototype itself
function Tirislib.Recipe:transform_result_entries(fn)
    for _, entry in Tirislib.Recipe.iterate_results(self) do
        fn(entry)
    end

    return self
end

--- Sets the fluidbox index for every fluid ingredient consecutively.
--- @return RecipePrototype itself
function Tirislib.Recipe:index_fluid_ingredients()
    local index = 1
    for _, entry in Tirislib.Recipe:iterate_ingredients() do
        if entry.type == "fluid" then
            entry.fluidbox_index = index
            index = index + 1
        end
    end

    return self
end

--- Sets the fluidbox index for every fluid result consecutively.
--- @return RecipePrototype itself
function Tirislib.Recipe:index_fluid_results()
    local index = 1
    for _, entry in Tirislib.Recipe.iterate_results(self) do
        if entry.type == "fluid" then
            entry.fluidbox_index = index
            index = index + 1
        end
    end

    return self
end

--- Adds the recipe to all productivity module's whitelist.
--- @return RecipePrototype
function Tirislib.Recipe:allow_productivity_modules()
    -- TODO: This might be deprecated

    Tirislib.Prototype.add_recipe_to_productivity_modules(self.name)

    return self
end

-- << analyze >>

--- Checks if the recipe has the result with the given name and type.
--- @param name string
--- @param _type string|nil defaults to 'item'
--- @return boolean
function Tirislib.Recipe:has_result(name, _type)
    _type = _type or "item"

    for _, entry in Tirislib.Recipe.iterate_results(self) do
        if entry.type == "item" and entry.name == name then
            return true
        end
    end
    return false
end

--- Returns the average yield of the result with the given name and type.
--- @param name string
--- @param _type string|nil defaults to 'item'
--- @return RecipePrototype itself
function Tirislib.Recipe:get_result_count(name, _type)
    _type = _type or "item"

    local amount = 0
    for _, result in Tirislib.Recipe.iterate_results(self) do
        if result.name == name and result.type == _type then
            amount = amount + Tirislib.RecipeEntry.get_average_yield(result)
        end
    end
    return amount
end

--- Checks if the recipe has the ingredient with the given name and type.
--- @param name string
--- @param _type string|nil defaults to 'item'
--- @return boolean
function Tirislib.Recipe:has_ingredient(name, _type)
    _type = _type or "item"

    for _, entry in Tirislib.Recipe:iterate_ingredients() do
        if entry.type == "item" and entry.name == name then
            return true
        end
    end
    return false
end

--- Returns the count of the ingredient with the given name and type.
--- @param name string
--- @param _type string|nil
--- @return RecipePrototype itself
function Tirislib.Recipe:get_ingredient_count(name, _type)
    _type = _type or "item"

    for _, ingredient in Tirislib.Recipe:iterate_ingredients() do
        if ingredient.name == name and ingredient.type == _type then
            return ingredient.amount
        end
    end

    return 0
end

-- << high level >>

--- Makes sure the recipe's main_product is set explicitly.
local function try_fix_main_product_pains(recipe, product)
    if not recipe.icon and not recipe.icons then
        recipe.main_product = recipe.main_product or product or Tirislib.Recipe.get_first_result(recipe)
    end
end

--- Adds the given ingredient to the recipe, if it contains the given result.
--- @param name string
--- @param _type string
--- @param pairing_name string
--- @param pairing_type string
--- @param amount_fn function defaults to identity
--- @return RecipePrototype itself
function Tirislib.Recipe:pair_result_with_ingredient(name, _type, pairing_name, pairing_type, amount_fn)
    local result_amount = Tirislib.Recipe.get_result_count(self, name, _type)
    if result_amount == 0 then
        return self
    end

    local amount = amount_fn and amount_fn(result_amount) or result_amount
    Tirislib.Recipe.add_ingredient(
        self,
        {
            type = pairing_type,
            name = pairing_name,
            amount = math.ceil(amount)
        }
    )

    return self
end

--- Adds the given result to the recipe, if it contains the given result.
--- @param name string
--- @param _type string
--- @param pairing_name string
--- @param pairing_type string
--- @param amount_fn function|nil defaults to identity
--- @param probability number|nil
--- @return RecipePrototype itself
function Tirislib.Recipe:pair_result_with_result(name, _type, pairing_name, pairing_type, amount_fn, probability)
    local result_amount = Tirislib.Recipe.get_result_count(self, name, _type)
    if result_amount == 0 then
        return self
    end

    local amount = amount_fn and amount_fn(result_amount) or result_amount
    Tirislib.Recipe.add_result(
        self,
        {
            type = pairing_type,
            name = pairing_name,
            amount = math.ceil(amount),
            probability = probability
        }
    )

    try_fix_main_product_pains(self, name)

    return self
end

--- Adds the given result to the recipe, if it contains the given ingredient.
--- @param name string
--- @param _type string
--- @param pairing_name string
--- @param pairing_type string
--- @param amount_fn function|nil defaults to identity
--- @param probability number|nil
--- @return RecipePrototype itself
function Tirislib.Recipe:pair_ingredient_with_result(name, _type, pairing_name, pairing_type, amount_fn, probability)
    local ingredient_amount = Tirislib.Recipe.get_ingredient_count(self, name, _type)
    if ingredient_amount == 0 then
        return self
    end

    local amount = amount_fn and amount_fn(ingredient_amount) or ingredient_amount
    Tirislib.Recipe.add_result(
        self,
        {
            type = pairing_type,
            name = pairing_name,
            amount = math.ceil(amount),
            probability = probability
        }
    )

    try_fix_main_product_pains(self, pairing_name)

    return self
end

--- Adds the given ingredient to the recipe, if it contains the given ingredient.
--- @param name string
--- @param _type string
--- @param pairing_name string
--- @param pairing_type string
--- @param amount_fn function|nil defaults to identity
--- @return RecipePrototype itself
function Tirislib.Recipe:pair_ingredient_with_ingredient(name, _type, pairing_name, pairing_type, amount_fn)
    local ingredient_amount = Tirislib.Recipe.get_ingredient_count(self, name, _type)
    if ingredient_amount == 0 then
        return self
    end

    local amount = amount_fn and amount_fn(ingredient_amount) or ingredient_amount
    Tirislib.Recipe.add_ingredient(
        self,
        {
            type = pairing_type,
            name = pairing_name,
            amount = math.ceil(amount)
        }
    )

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
