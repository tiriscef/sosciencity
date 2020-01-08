---------------------------------------------------------------------------------------------------
-- << class for fluids >>
Tirislib_Fluid = {}

-- this makes an object of this class call the class methods (if it has no own method)
-- lua is weird
Tirislib_Fluid.__index = Tirislib_Fluid

function Tirislib_Fluid.get_by_name(name)
    local new = Tirislib_Prototype.get("fluid", name)
    setmetatable(new, Tirislib_Fluid)
    return new
end

function Tirislib_Fluid.get_from_prototype(prototype)
    setmetatable(prototype, Tirislib_Fluid)
    return prototype
end

function Tirislib_Fluid.get(name)
    if type(name) == "string" then
        return Tirislib_Fluid.get_by_name(name)
    else
        return Tirislib_Fluid.get_from_prototype(name)
    end
end

function Tirislib_Fluid.pairs()
    local index, value

    local function _next()
        index, value = next(data.raw["fluid"], index)

        if index then
            setmetatable(value, Tirislib_Fluid)
            return index, value
        end
    end

    return _next, index, value
end

function Tirislib_Fluid:create(prototype)
    if not prototype.type then
        prototype.type = "fluid"
    end

    data:extend {prototype}
    return Tirislib_Fluid.get(prototype.name)
end

local meta = {}

function meta:__call(name)
    return Tirislib_Fluid.get(name)
end

setmetatable(Tirislib_Fluid, meta)
