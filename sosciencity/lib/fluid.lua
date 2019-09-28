Fluid = {}

function Fluid:get(name)
    local new = Prototype:get("fluid", name)
    setmetatable(new, self)
    return new
end

function Fluid:__call(name)
    return self:get(name)
end

function Fluid:create(prototype)
    if not prototype.type then
        prototype.type = "fluid"
    end

    data:extend {prototype}
    return self.__call(prototype.name)
end
