Technology = {}

function Technology:get(name)
    local new = Prototype:get("technology", name)
    setmetatable(new, self)
    return new
end

function Technology:__call(name)
    return self:get(name)
end

function Technology:create(prototype)
    if not prototype.type then
        prototype.type = "technology"
    end

    data:extend {prototype}
    return self.__call(prototype.name)
end

function Technology:add_effect(effect)
    if not self.effects then
        self.effects = {}
    end

    table.insert(self.effects, effect)
end
