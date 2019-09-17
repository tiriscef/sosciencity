-- static class for those tables that the wiki calls ItemProductPrototype or FluidProductPrototype or IngredientPrototype
RecipeEntry = {}

function RecipeEntry:get_name(entry)
    return entry.name or entry[1]
end

function RecipeEntry:yields_item(entry)
    if entry.type then
        return entry.type == "item"
    end
    return true
end

function RecipeEntry:yields_fluid(entry)
    return (entry.type ~= nil) and (entry.type == "fluid")
end

function RecipeEntry:get_type(entry)
    return entry.type or "item"
end

function RecipeEntry:specify_same_stuff(entry1, entry2)
    return (RecipeEntry:get_name(entry1) == RecipeEntry:get_name(entry2)) and
        (RecipeEntry:get_type(entry1) == RecipeEntry:get_type(entry2))
end

function RecipeEntry:has_catalyst(entry)
    return entry.catalyst_amount ~= nil
end

function RecipeEntry:get_ingredient_amount(entry)
    local ret = entry.amount or entry[2]
    if not ret then
        error("Sosciencity found a IngredientPrototype without a valid amount:\n" .. serpent.block(entry))
    end
    return ret
end

function RecipeEntry:add_ingredient_amount(entry, amount)
    if entry.amount then
        entry.amount = entry.amount + amount
    elseif entry[2] then
        entry[2] = entry[2] + amount
    else
        error("Sosciencity found a IngredientPrototype without a valid amount:\n" .. serpent.block(entry))
    end
end

function RecipeEntry:add_catalyst_amount(entry, amount)
    entry.catalyst_amount = (entry.catalyst_amount or 0) + amount

    if entry[2] then
        entry.amount = entry[2]
        entry[2] = nil
    end
end

function RecipeEntry:get_average_yield(entry)
    local probability = entry.probability or 1

    if entry.amount_min then
        return (entry.amount_min + entry.amount_max) * 0.5 * probability
    end

    local amount = entry.amount or entry[2] or 1
    return amount * probability
end

-- class for recipes
Recipe = {}

function Recipe:get(name)
    new = Prototype:get("recipe", name)
    setmetatable(new, self)
    return new
end

function Recipe:__call(name)
    return self:get(name)
end

function Recipe:from_prototype(prototype)
    setmetatable(prototype, self)
    return prototype
end

function Recipe:create(prototype)
    data:extend {prototype}
    return Recipe(prototype.name)
end

function Recipe:has_normal_difficulty()
    return self.normal ~= nil
end

function Recipe:has_expensive_difficulty()
    return self.expensive ~= nil
end

function Recipe:has_difficulties()
    return self.has_normal_difficulty() or self.has_expensive_difficulty()
end

local function recipe_results_contain_item(recipe, item_name)
    if recipe.result then
        return recipe.result == item_name
    elseif recipe.results then
        for _, result in pairs(recipe.results) do
            if result.type == "item" and (result.name == item_name or result[1] == item_name) then
                return true
            end
        end
        return false
    end
end

function Recipe:results_contain_item(item_name)
    if self.has_normal_difficulty then
        return recipe_results_contain_item(self.normal, item_name)
    elseif self.has_expensive_difficulty then
        return recipe_results_contain_item(self.expensive, item_name)
    else
        return recipe_results_contain_item(self, item_name)
    end
end

local function recipe_result_count(recipe, name, type)
    if recipe.result then
        if recipe.result == name then
            return recipe.result_count or 1 -- factorio defaults to 1 if no result_count is specified
        else
            return 0
        end
    elseif recipe.results then
        for _, result in pairs(results_table) do
            if RecipeEntry:get_name(result) == name and RecipeEntry:get_type(result) then
                return RecipeEntry:get_average_yield(result)
            end
        end
        return 0 -- item doesn't occur in this table
    end
    error("Sosciencity found a recipe without a valid result:\n" .. serpent.block(recipe))
end

function Recipe:get_result_item_count(item_name)
    if self:has_difficulties() then
        if self:has_normal_difficulty() then
            normal_count = recipe_result_count(self.normal, item_name)
        end
        if self:has_expensive_difficulty() then
            expensive_count = recipe_result_count(self.expensive, item_name)
        end
        return normal_count, expensive_count
    else
        return recipe_result_count(self, item_name)
    end
end

local function add_ingredient(recipe, ingredient_prototype)
    for _, ingredient in pairs(recipe.ingredients) do
        if RecipeEntry:specify_same_stuff(ingredient, ingredient_prototype) then
            local ingredient_amount = RecipeEntry:get_ingredient_amount(ingredient_prototype)
            RecipeEntry:add_ingredient_amount(ingredient, ingredient_amount)

            if RecipeEntry:has_catalyst(ingredient) and Recipe:has_catalyst(ingredient_prototype) then
                RecipeEntry:add_catalyst_amount(ingredient, ingredient_prototype.catalyst_amount)
            end
            return
        end
    end

    table.insert(recipe.ingredients, ingredient_prototype)
end

function Recipe:add_ingredient(ingredient_prototype_normal, ingredient_prototype_expensive)
    if not self:has_difficulties() then
        add_ingredient(self, ingredient_prototype_normal)
    else
        if ingredient_prototype_normal and self:has_normal_difficulty() then
            add_ingredient(self.normal, ingredient_prototype_normal)
        end
        if self:has_expensive_difficulty() then
            ingredient_to_add = ingredient_prototype_expensive or ingredient_prototype_normal
            add_ingredient(self.expensive, ingredient_to_add)
        end
    end

    return self
end

local function remove_ingredient(recipe, ingredient_name, ingredient_type)
    for index, ingredient in pairs(recipe.ingredients) do
        if RecipeEntry:get_name(ingredient) == ingredient_name and RecipeEntry:get_type(ingredient) == ingredient_type then
            recipe.ingredients[index] = nil
        end
    end
end

function Recipe:remove_ingredient(ingredient_name, ingredient_type)
    if not self:has_difficulties() then
        remove_ingredient(self, ingredient_name, ingredient_type)
    else
        if self:has_normal_difficulty() then
            remove_ingredient(self.normal, ingredient_name, ingredient_type)
        end
        if self.has_expensive_difficulty() then
            remove_ingredient(self.expensive, ingredient_name, ingredient_type)
        end
    end

    return self
end

function Recipe:add_unlock(technology_name)
    local tech = Technology:get(technology_name)

    if not tech then
        Prototype:postpone {
            object = self,
            technology = technology_name,
            execute = function()
                self.object:add_unlock(self.technology)
            end
        }
    end

    return self
end
