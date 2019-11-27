---------------------------------------------------------------------------------------------------
-- << class for entities >>
Entity = {}

-- this makes an object of this class call the class methods (if it hasn't an own method)
-- lua is weird
Entity.__index = Entity

function Entity.get_by_name(name)
    local entity_types = require("lib.prototype-types.entity-types")
    local new = Prototype.get(entity_types, name)
    setmetatable(new, Entity)
    return new
end

function Entity.get_from_prototype(prototype)
    setmetatable(prototype, Entity)
    return prototype
end

function Entity.get(name)
    if type(name) == "string" then
        return Entity.get_by_name(name)
    else
        return Entity.get_from_prototype(name)
    end
end

function Entity.pairs(prototype_type)
    local index, value

    local function _next()
        index, value = next(data.raw[prototype_type], index)

        if index then
            setmetatable(value, Entity)
            return index, value
        end
    end

    return _next, index, value
end

function Entity.create(prototype)
    data:extend {prototype}
    return Entity.get(prototype)
end

function Entity.get_selection_box(width, height)
    return {
        {-width / 2., -height / 2.},
        {width / 2., height / 2.}
    }
end

function Entity.get_collision_box(width, height)
    return {
        {-width / 2. + 0.2, -height / 2. + 0.2},
        {width / 2. - 0.2, height / 2. - 0.2}
    }
end

function Entity:add_crafting_category(category_name)
    if not self.crafting_categories then
        self.crafting_categories = {}
    end

    if not Tables.contains(self.crafting_categories, category_name) then
        table.insert(self.crafting_categories, category_name)
    end

    return self
end

function Entity:add_loot(loot)
    if not self.loot then
        self.loot = {}
    end

    for _, current_loot in pairs(self.loot) do
        if current_loot.item == loot.item and current_loot.probability == loot.probability then
            current_loot.count_min = (current_loot.count_min or 1) + (loot.count_min or 1)
            current_loot.count_max = (current_loot.count_max or 1) + (loot.count_max or 1)
        end
    end

    table.insert(self.loot, loot)
    return self
end

local meta = {}

function meta:__call(name)
    return Entity.get(name)
end

setmetatable(Entity, meta)
