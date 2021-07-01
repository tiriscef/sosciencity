---------------------------------------------------------------------------------------------------
-- << class for technologies >>
Tirislib_Technology = {}

-- this makes an object of this class call the class methods (if it has no own method)
-- lua is weird
Tirislib_Technology.__index = Tirislib_Technology

--- Class for arrays of technologies. Setter-functions can be called on them.
Tirislib_TechnologyArray = {}
Tirislib_TechnologyArray.__index = Tirislib_PrototypeArray.__index

--- Gets the TechnologyPrototype of the given name. If no such Technology exists, a dummy object will be returned instead.
--- @param name string
--- @return TechnologyPrototype prototype
--- @return boolean found
function Tirislib_Technology.get_by_name(name)
    return Tirislib_Prototype.get("technology", name, Tirislib_Technology)
end

--- Creates the TechnologyPrototype metatable for the given prototype.
--- @param prototype table
--- @return TechnologyPrototype
function Tirislib_Technology.get_from_prototype(prototype)
    setmetatable(prototype, Tirislib_Technology)
    return prototype
end

--- Unified function for the get_by_name and for the get_from_prototype functions.
--- @param name string|table
--- @return TechnologyPrototype prototype
--- @return boolean|nil found
function Tirislib_Technology.get(name)
    if type(name) == "string" then
        return Tirislib_Technology.get_by_name(name)
    else
        return Tirislib_Technology.get_from_prototype(name)
    end
end

--- Creates an iterator over all TechnologyPrototypes.
--- @return function
--- @return string
--- @return TechnologyPrototype
function Tirislib_Technology.iterate()
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

--- Creates an TechnologyPrototype from the given prototype table.
--- @param prototype table
--- @return TechnologyPrototype prototype
function Tirislib_Technology.create(prototype)
    if not prototype.type then
        prototype.type = "technology"
    end

    data:extend {prototype}
    return Tirislib_Technology.get_from_prototype(prototype)
end

--- Adds the given effect to this technology.
--- @param effect TechnologyEffectPrototype
--- @return TechnologyPrototype itself
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

--- Adds an unlock effect for the given recipe to this technology.
--- @param recipe_name string
--- @return TechnologyPrototype itself
function Tirislib_Technology:add_unlock(recipe_name)
    return self:add_effect {
        type = "unlock-recipe",
        recipe = recipe_name
    }
end

--- Adds the given technology to the prerequisites.
--- @param tech_name string
--- @return TechnologyPrototype itself
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

--- Removes the given technology from the prerequisites.
--- @param tech_name string
--- @return TechnologyPrototype itself
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
