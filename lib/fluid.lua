---------------------------------------------------------------------------------------------------
-- << class for fluids >>
Fluid = {}

-- this makes an object of this class call the class methods (if it hasn't an own method)
-- lua is weird
Fluid.__index = Fluid

function Fluid.get_by_name(name)
    local new = Prototype.get("fluid", name)
    setmetatable(new, Fluid)
    return new
end

function Fluid.get_from_prototype(prototype)
    setmetatable(prototype, Fluid)
    return prototype
end

function Fluid.get(name)
    if type(name) == "string" then
        return Fluid.get_by_name(name)
    else
        return Fluid.get_from_prototype(name)
    end
end

function Fluid.pairs()
    local index, value

    local function _next()
        index, value = next(data.raw["fluid"], index)

        if index then
            setmetatable(value, Fluid)
            return index, value
        end
    end

    return _next, index, value
end

function Fluid:create(prototype)
    if not prototype.type then
        prototype.type = "fluid"
    end

    data:extend {prototype}
    return Fluid.get(prototype.name)
end

local meta = {}

function meta:__call(name)
    return Fluid.get(name)
end

setmetatable(Fluid, meta)
