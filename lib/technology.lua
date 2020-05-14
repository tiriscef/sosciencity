---------------------------------------------------------------------------------------------------
-- << class for technologies >>
Tirislib_Technology = {}

-- this makes an object of this class call the class methods (if it has no own method)
-- lua is weird
Tirislib_Technology.__index = Tirislib_Technology

function Tirislib_Technology.get_by_name(name)
    return Tirislib_Prototype.get("technology", name, Tirislib_Technology)
end

function Tirislib_Technology.get_from_prototype(prototype)
    setmetatable(prototype, Tirislib_Technology)
    return prototype
end

function Tirislib_Technology.get(name)
    if type(name) == "string" then
        return Tirislib_Technology.get_by_name(name)
    else
        return Tirislib_Technology.get_from_prototype(name)
    end
end

function Tirislib_Technology.pairs()
    local index, prototype

    local function _next()
        index, prototype = next(data.raw["technology"], index)

        if index then
            setmetatable(prototype, Tirislib_Technology)
            return index, prototype
        end
    end

    return _next, index, prototype
end

function Tirislib_Technology.create(prototype)
    if not prototype.type then
        prototype.type = "technology"
    end

    data:extend {prototype}
    return Tirislib_Technology.get_from_prototype(prototype)
end

function Tirislib_Technology:add_effect(effect)
    if not self.effects then
        self.effects = {}
    end

    -- check if the Technology already has this effect
    for _, current_effect in pairs(self.effects) do
        if Tirislib_Tables.equal(effect, current_effect) then
            -- return without doing anything in this case
            return self
        end
    end

    table.insert(self.effects, effect)
    return self
end

function Tirislib_Technology:add_unlock(recipe_name)
    return self:add_effect {
        type = "unlock-recipe",
        recipe = recipe_name
    }
end

function Tirislib_Technology:add_prerequisite(tech_name)
    if not self.prerequisites then
        self.prerequisites = {}
    end

    for _, prerequisite in pairs(self.prerequisites) do
        if prerequisite == tech_name then
            return self
        end
    end

    table.insert(self.prerequisites, tech_name)
    return self
end

function Tirislib_Technology:remove_prerequisite(tech_name)
    if not self.prerequisites then
        -- nothing to do
        return self
    end

    for index, prerequisite in pairs(self.prerequisites) do
        if prerequisite == tech_name then
            self.prerequisites[index] = nil
        end
    end

    return self
end

local meta = {}

function meta:__call(name)
    return Tirislib_Technology.get(name)
end

setmetatable(Tirislib_Technology, meta)
