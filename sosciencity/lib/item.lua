Item = {}

function Item:get(name)
    local item_types = {
        "item",
        "tool",
        "ammo",
        "armor",
        "blueprint-book",
        "blueprint",
        "capsule",
        "deconstruction-item",
        "gun",
        "item-with-entity-data",
        "item-with-inventory",
        "item-with-label",
        "item-with-tags",
        "mining-tool",
        "module",
        "rail-planner",
        "repair-tool",
        "selection-tool"
    }
    new = Prototype:get(item_types, name)
    setmetatable(new, self)
    return new
end

function Item:__call(name)
    return self:get(name)
end

function Item:create(prototype)
    data:extend {prototype}
    return self.__call(prototype.name)
end
