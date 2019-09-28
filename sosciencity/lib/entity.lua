Entity = {}

function Entity:get(name)
    local entity_types = require("lib.prototype-types.entity-types")
    local new = Prototype:get(entity_types, name)
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

function Entity:get_selection_box(width, height)
    return {
        {-width / 2., -height / 2.},
        {width / 2., height / 2.}
    }
end

function Entity:get_collision_box(width, height)
    return {
        {-width / 2. + 0.2, -height / 2. + 0.2},
        {width / 2. - 0.2, height / 2. - 0.2}
    }
end

function Entity:add_crafting_category(category_name)
    if not self.crafting_categories then
        self.crafting_categories = {}
    end

    table.insert(self.crafting_categories, category_name)
end
