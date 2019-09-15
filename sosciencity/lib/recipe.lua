-- class for those tables that the wiki calls ItemProductPrototype or FluidProductPrototype
ProductPrototype = {}

function ProductPrototype.get_average_yield()
    local probability = prototype.probability or 1

    if prototype.amount_min then
        return (prototype.amount_min + prototype.amount_max) * 0.5 * probability
    end

    local amount = prototype.amount or prototype[2] or 1
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

function Recipe:create(prototype)
    data:extend{prototype}
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

local function recipe_result_count(recipe, )

end

function Recipe:result_count(item_name)
    if Recipe:has_difficulties() then

    else

    end
end