---------------------------------------------------------------------------------------------------
-- << static class for technology effects >>
TechnologyEffect = {}

function TechnologyEffect:equal(effect1, effect2)
    for key, value in pairs(effect1) do
        if value ~= effect2[key] then
            return false
        end
    end

    return true
end

---------------------------------------------------------------------------------------------------
-- << class for technologies >>
Technology = {}

-- this makes an object of this class call the class methods (if it hasn't an own method)
-- lua is weird
Technology.__index = Technology

function Technology:get_by_name(name)
    local new = Prototype:get("technology", name)
    setmetatable(new, Technology)
    return new
end

function Technology:get_from_prototype(prototype)
    setmetatable(prototype, Technology)
    return prototype
end

function Technology:get(name)
    if type(name) == "string" then
        return self:get_by_name(name)
    else
        return self:get_from_prototype(name)
    end
end

setmetatable(Technology, {__call = Technology.get})

function Technology:create(prototype)
    if not prototype.type then
        prototype.type = "technology"
    end

    data:extend {prototype}
    return self:get_from_prototype(prototype)
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
