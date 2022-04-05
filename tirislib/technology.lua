---------------------------------------------------------------------------------------------------
-- << class for technologies >>
Tirislib.Technology = {}

-- this makes an object of this class call the class methods (if it has no own method)
-- lua is weird
Tirislib.Technology.__index = Tirislib.Technology

--- Class for arrays of technologies. Setter-functions can be called on them.
Tirislib.TechnologyArray = {}
Tirislib.TechnologyArray.__index = Tirislib.PrototypeArray.__index

--- Gets the TechnologyPrototype of the given name. If no such Technology exists, a dummy object will be returned instead.
--- @param name string
--- @return TechnologyPrototype prototype
--- @return boolean found
function Tirislib.Technology.get_by_name(name)
    return Tirislib.Prototype.get("technology", name, Tirislib.Technology)
end

--- Creates the TechnologyPrototype metatable for the given prototype.
--- @param prototype table
--- @return TechnologyPrototype
function Tirislib.Technology.get_from_prototype(prototype)
    setmetatable(prototype, Tirislib.Technology)
    return prototype
end

--- Unified function for the get_by_name and for the get_from_prototype functions.
--- @param name string|table
--- @return TechnologyPrototype prototype
--- @return boolean|nil found
function Tirislib.Technology.get(name)
    if type(name) == "string" then
        return Tirislib.Technology.get_by_name(name)
    else
        return Tirislib.Technology.get_from_prototype(name)
    end
end

--- Creates an iterator over all TechnologyPrototypes.
--- @return function
--- @return string
--- @return TechnologyPrototype
function Tirislib.Technology.iterate()
    local index, prototype

    local function _next()
        index, prototype = next(data.raw["technology"], index)

        if index then
            setmetatable(prototype, Tirislib.Technology)
            return index, prototype
        end
    end

    return _next, index, prototype
end

--- Creates an TechnologyPrototype from the given prototype table.
--- @param prototype table
--- @return TechnologyPrototype prototype
function Tirislib.Technology.create(prototype)
    prototype.type = prototype.type or "technology"
    prototype.effects = prototype.effects or {}

    Tirislib.Prototype.create(prototype)

    return Tirislib.Technology.get_from_prototype(prototype)
end

--- Adds the given effect to this technology.
--- @param effect TechnologyEffectPrototype
--- @return TechnologyPrototype itself
function Tirislib.Technology:add_effect(effect)
    if not self.effects then
        self.effects = {}
    end

    -- check if the Technology already has this effect
    for _, current_effect in pairs(self.effects) do
        if Tirislib.Tables.equal(effect, current_effect) then
            -- return without doing anything in this case
            return self
        end
    end

    table.insert(self.effects, effect)
    return self
end

--- Adds an unlock effect for the given recipe to this technology.
--- @param recipe_name string
--- @return TechnologyPrototype itself
function Tirislib.Technology:add_unlock(recipe_name)
    return self:add_effect {
        type = "unlock-recipe",
        recipe = recipe_name
    }
end

--- Returns this technologies unlocked recipes as (index as integer, recipe as RecipePrototype) pairs.
--- @return array unlocked_recipes
function Tirislib.Technology:get_unlocked_recipes()
    local effects = Tirislib.Tables.get_subtbl(self, "effects")
    local ret = {}

    for _, effect in pairs(effects) do
        if effect.type == "unlock-recipe" then
            local recipe, found = Tirislib.Recipe.get_by_name(effect.recipe)

            if found then
                ret[#ret+1] = recipe
            end
        end
    end

    return ret
end

--- Adds the given technology to the prerequisites.
--- @param tech_name string
--- @return TechnologyPrototype itself
function Tirislib.Technology:add_prerequisite(tech_name)
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

--- Removes the given technology from the prerequisites.
--- @param tech_name string
--- @return TechnologyPrototype itself
function Tirislib.Technology:remove_prerequisite(tech_name)
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

local meta = {
    __index = Tirislib.BasePrototype
}

function meta:__call(name)
    return Tirislib.Technology.get(name)
end

setmetatable(Tirislib.Technology, meta)
