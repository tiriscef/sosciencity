Fluid = {}

function Fluid:get(name)
    new = Prototype:get("fluid", name)
    setmetatable(new, self)
    return new
end

function Fluid:__call(name)
    return self:get(name)
end

function Fluid:create(prototype)
    data:extend{prototype}
    return self.__call(prototype.name)
end