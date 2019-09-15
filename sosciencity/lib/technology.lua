Technology = {
    __call = function(self, name)
        new = Prototype:get("technology", name)
        setmetatable(new, self)
        return new
    end
}

function Technology:get(name)
    new = Prototype:get("technology", name)
    setmetatable(new, self)
    return new
end

function Technology:__call(name)
    return self:get(name)
end

function Technology:create(prototype)
    data:extend{prototype}
    return self.__call(prototype.name)
end
