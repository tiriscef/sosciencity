---------------------------------------------------------------------------------------------------
-- << class for fluids >>
Fluid = {}

-- this makes an object of this class call the class methods (if it hasn't an own method)
-- lua is weird
Fluid.__index = Fluid

function Fluid:get_by_name(name)
    local new = Prototype:get("fluid", name)
    setmetatable(new, Fluid)
    return new
end

function Fluid:get_from_prototype(prototype)
    setmetatable(prototype, Fluid)
    return prototype
end

function Fluid:get(name)
    if type(name) == "string" then
        return self:get_by_name(name)
    else
        return self:get_from_prototype(name)
    end
end

Fluid.__call = Fluid.get

function Fluid:create(prototype)
    if not prototype.type then
        prototype.type = "fluid"
    end

    data:extend {prototype}
    return self:get(prototype.name)
end
