---------------------------------------------------------------------------------------------------
-- << class for entities >>
Tirislib_Entity = {}

-- this makes an object of this class call the class methods (if it has no own method)
-- lua is weird
Tirislib_Entity.__index = Tirislib_Entity

--- Class for arrays of entities. Setter-functions can be called on them.
Tirislib_EntityArray = {}
Tirislib_EntityArray.__index = Tirislib_PrototypeArray.__index

-- << getter functions >>
function Tirislib_Entity.get_by_name(name)
    local entity_types = require("lib.prototype-types.entity-types")
    local new = Tirislib_Prototype.get(entity_types, name)
    setmetatable(new, Tirislib_Entity)
    return new
end

function Tirislib_Entity.get_from_prototype(prototype)
    setmetatable(prototype, Tirislib_Entity)
    return prototype
end

function Tirislib_Entity.get(name)
    if type(name) == "string" then
        return Tirislib_Entity.get_by_name(name)
    else
        return Tirislib_Entity.get_from_prototype(name)
    end
end

function Tirislib_Entity.pairs(prototype_type)
    local index, value

    local function _next()
        index, value = next(data.raw[prototype_type], index)

        if index then
            setmetatable(value, Tirislib_Entity)
            return index, value
        end
    end

    return _next, index, value
end

function Tirislib_Entity.create(prototype)
    data:extend {prototype}
    return Tirislib_Entity.get(prototype)
end

function Tirislib_Entity.get_selection_box(width, height)
    return {
        {-width / 2., -height / 2.},
        {width / 2., height / 2.}
    }
end

function Tirislib_Entity.get_collision_box(width, height)
    return {
        {-width / 2. + 0.2, -height / 2. + 0.2},
        {width / 2. - 0.2, height / 2. - 0.2}
    }
end

function Tirislib_Entity:set_size(width, height)
    self.selection_box = Tirislib_Entity.get_selection_box(width, height)
    self.collision_box = Tirislib_Entity.get_collision_box(width, height)

    return self
end

function Tirislib_Entity.get_empty_picture()
    return {
        filename = "__sosciencity__/graphics/empty.png",
        size = 1
    }
end

function Tirislib_Entity.get_placeholder_picture()
    return {
        filename = "__sosciencity__/graphics/placeholder.png",
        width = 64,
        height = 54
    }
end

function Tirislib_Entity.get_south_pipe_picture()
    return {
        filename = "__base__/graphics/entity/assembling-machine-1/assembling-machine-1-pipe-S.png",
        width = 44,
        height = 31,
        shift = util.by_pixel(0, -31.5),
        hr_version = {
            filename = "__base__/graphics/entity/assembling-machine-1/hr-assembling-machine-1-pipe-S.png",
            width = 88,
            height = 61,
            shift = util.by_pixel(0, -31.25),
            scale = 0.5
        }
    }
end

function Tirislib_Entity:add_crafting_category(category_name)
    if not self.crafting_categories then
        self.crafting_categories = {}
    end

    if not Tirislib_Tables.contains(self.crafting_categories, category_name) then
        table.insert(self.crafting_categories, category_name)
    end

    return self
end

function Tirislib_Entity:add_loot(loot)
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
    return Tirislib_Entity.get(name)
end

setmetatable(Tirislib_Entity, meta)
