TechnologyEffect = {}

function TechnologyEffect:equal(effect1, effect2)
    for key, value in pairs(effect1) do
        if value ~= effect2[key] then
            return false
        end
    end

    return true
end

Technology = {}

function Technology:get(name)
    local new = Prototype:get("technology", name)
    setmetatable(new, self)
    return new
end

function Technology:__call(name)
    return self:get(name)
end

function Technology:create(prototype)
    if not prototype.type then
        prototype.type = "technology"
    end

    data:extend {prototype}
    return self.__call(prototype.name)
end

function Technology:add_effect(effect)
    if not self.effects then
        self.effects = {}
    end

    -- check if the Technology already has this effect
    for _, current_effect in pairs(self.effects) do
        if TechnologyEffect:equal(effect, current_effect) then
            -- return without doing anything in this case
            return self
        end
    end

    table.insert(self.effects, effect)
    return self
end

function Technology:add_unlock(recipe_name)
    return self:add_effect {
        type = "unlock-recipe",
        recipe = recipe_name
    }
end
