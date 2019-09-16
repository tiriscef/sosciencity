Entity = {}

function Entity:get(name)
    local entity_types = require("lib.prototype-types.entity-types")
    new = Prototype:get(item_types, name)
    setmetatable(new, self)
    return new
end

function Entity:__call(name)
    return self:get(name)
end

function Entity:create(prototype)
    data:extend {prototype}
    return self.get(prototype.name)
end
