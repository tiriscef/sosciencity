---------------------------------------------------------------------------------------------------
-- << class for entities >>
--- @class EntityPrototype
Tirislib.Entity = {}

-- this makes an object of this class call the class methods (if it has no own method)
-- lua is weird
Tirislib.Entity.__index = Tirislib.Entity

--- Class for arrays of entities. Setter-functions can be called on them.
--- @class EntityPrototypeArray
Tirislib.EntityArray = {}
Tirislib.EntityArray.__index = Tirislib.PrototypeArray.__index

--- @class SpritePrototype
--- @class AnimationPrototype
--- @class PicturePrototype
--- @class SoundPrototype

-- << getter functions >>
local entity_types = require("prototype-types.entity-types")

--- Gets the EntityPrototype of the given name. If no such Entity exists, a dummy object will be returned instead.
--- @param name string
--- @return EntityPrototype prototype
--- @return boolean found
function Tirislib.Entity.get_by_name(name)
    return Tirislib.Prototype.get(entity_types, name, Tirislib.Entity)
end

--- Creates the EntityPrototype metatable for the given prototype.
--- @param prototype table
--- @return EntityPrototype
function Tirislib.Entity.get_from_prototype(prototype)
    setmetatable(prototype, Tirislib.Entity)
    return prototype
end

--- Unified function for the get_by_name and for the get_from_prototype functions.
--- @param name string|table
--- @return EntityPrototype prototype
--- @return boolean|nil found
function Tirislib.Entity.get(name)
    if type(name) == "string" then
        return Tirislib.Entity.get_by_name(name)
    else
        return Tirislib.Entity.get_from_prototype(name)
    end
end

--- Creates an iterator over all EntityPrototypes of the given entity subtypes.
--- @param types table|string|nil
--- @return function
--- @return string
--- @return EntityPrototype
function Tirislib.Entity.iterate(types)
    -- no argument - iterate over all types
    if types == nil then
        types = entity_types
    end
    -- one type given - iterate over just that type
    if type(types) ~= "table" then
        types = {types}
    end

    local name, entity, type_index, prototype_type
    type_index, prototype_type = next(types, type_index)

    local function _next()
        name, entity = next(data.raw[prototype_type] or {}, name)

        if name then
            setmetatable(entity, Tirislib.Entity)
            return name, entity
        else
            type_index, prototype_type = next(types, type_index)
            if prototype_type ~= nil then
                return _next()
            end
        end
    end

    return _next, name, entity
end

--- Returns an ItemPrototypeArray with all ItemPrototypes of the given subtypes.
--- @return ItemPrototypeArray prototypes
function Tirislib.Entity.all(...)
    local types = {...}
    if #types == 0 then
        -- return all entities if no types are given
        types = entity_types
    end

    local array = {}
    setmetatable(array, Tirislib.EntityArray)

    for _, item in Tirislib.Entity.iterate(types) do
        array[#array + 1] = item
    end

    return array
end

-- << creation >>

--- Creates an EntityPrototype from the given prototype table.
--- @param prototype table
--- @return EntityPrototype prototype
function Tirislib.Entity.create(prototype)
    Tirislib.Prototype.create(prototype)

    return Tirislib.Entity.get(prototype)
end

--- Creates a selection box with the given width and height in tiles.
--- @param width number
--- @param height number
--- @return table selection_box
function Tirislib.Entity.get_selection_box(width, height)
    return {
        {-width / 2., -height / 2.},
        {width / 2., height / 2.}
    }
end

--- Creates a collision box with the given width and height in tiles. This includes a margin to allow
--- the player to walk between them.
--- @param width number
--- @param height number
--- @return table collision_box
function Tirislib.Entity.get_collision_box(width, height)
    local margin = 0.25
    return {
        {-width / 2. + margin, -height / 2. + margin},
        {width / 2. - margin, height / 2. - margin}
    }
end

--- Sets the collision box of the EntityPrototype.
--- @param width number
--- @param height number
--- @return EntityPrototype itself
function Tirislib.Entity:set_collision_box(width, height)
    self.collision_box = Tirislib.Entity.get_collision_box(width, height)
    return self
end

--- Sets the selection box of the EntityPrototype.
--- @param width number
--- @param height number
--- @return EntityPrototype itself
function Tirislib.Entity:set_selection_box(width, height)
    self.selection_box = Tirislib.Entity.get_selection_box(width, height)
    return self
end

--- Sets the size of the EntityPrototype, which inclused the selection and collision box.
--- @param width number
--- @param height number
--- @return EntityPrototype itself
function Tirislib.Entity:set_size(width, height)
    self.selection_box = Tirislib.Entity.get_selection_box(width, height)
    self.collision_box = Tirislib.Entity.get_collision_box(width, height)

    return self
end

--- Creates an empty sprite.
--- @return SpritePrototype empty
function Tirislib.Entity.get_empty_sprite()
    return {
        filename = "__sosciencity-graphics__/graphics/empty.png",
        size = 1
    }
end

--- Creates an empty animation.
--- @return AnimationPrototype empty
function Tirislib.Entity.get_empty_animation()
    return {
        filename = "__sosciencity-graphics__/graphics/empty.png",
        size = 1,
        frame_count = 1
    }
end

--- Creates a placeholder picture.
--- @return PicturePrototype placeholder
function Tirislib.Entity.get_placeholder_picture()
    return {
        filename = "__sosciencity-graphics__/graphics/placeholder.png",
        width = 64,
        height = 54
    }
end

local all_directions = {"north", "east", "south", "west"}

local function copy_directions(definition, directions)
    if not directions then
        directions = all_directions
    end

    local ret = {}

    for _, direction in pairs(directions) do
        ret[direction] = definition[direction]
    end

    for _, direction in pairs(all_directions) do
        ret[direction] = ret[direction] or Tirislib.Entity.get_empty_sprite()
    end

    return ret
end

local pipepictures = {
    north = {
        filename = "__sosciencity-graphics__/graphics/entity/hr-assembling-machine-1-pipe-N.png",
        width = 71,
        height = 38,
        shift = util.by_pixel(2.25, 13.5),
        scale = 0.5
    },
    east = {
        filename = "__sosciencity-graphics__/graphics/entity/hr-assembling-machine-1-pipe-E.png",
        width = 42,
        height = 76,
        shift = util.by_pixel(-24.5, 1),
        scale = 0.5
    },
    south = {
        filename = "__sosciencity-graphics__/graphics/entity/hr-assembling-machine-1-pipe-S.png",
        width = 88,
        height = 61,
        shift = util.by_pixel(0, -31.25),
        scale = 0.5
    },
    west = {
        filename = "__sosciencity-graphics__/graphics/entity/hr-assembling-machine-1-pipe-W.png",
        width = 39,
        height = 73,
        shift = util.by_pixel(25.75, 1.25),
        scale = 0.5
    }
}

--- Creates the standart pipe pictures for the given directions.
--- @param directions table|nil
--- @return PicturePrototype pipe_picture
function Tirislib.Entity.get_standard_pipe_pictures(directions)
    return copy_directions(pipepictures, directions)
end

local pipecovers = pipecoverspictures()

-- remove the shadows because they never seem to look appropriate
for _, direction in pairs(pipecovers) do
    for i, layer in pairs(direction.layers) do
        if layer.draw_as_shadow then
            direction.layers[i] = nil
        end
    end
end

--- Creates the standart pipe cover pictures for the given directions.
--- @param directions table|nil
--- @return PicturePrototype cover_picture
function Tirislib.Entity.get_standard_pipe_cover(directions)
    return copy_directions(pipecovers, directions)
end

local PIXEL_PER_TILE = 64

--- Deprecated. Creates the standard picture prototype framework.
--- @param path string
--- @param width number
--- @param height number
--- @param shift table
--- @return PicturePrototype
function Tirislib.Entity.create_standard_picture_old(path, width, height, shift)
    return {
        layers = {
            {
                filename = path .. "-hr.png",
                priority = "high",
                width = width * PIXEL_PER_TILE,
                height = height * PIXEL_PER_TILE,
                shift = shift,
                scale = 0.5
            },
            {
                filename = path .. "-shadowmap-hr.png",
                priority = "high",
                width = width * PIXEL_PER_TILE,
                height = height * PIXEL_PER_TILE,
                shift = shift,
                scale = 0.5,
                draw_as_shadow = true
            }
        }
    }
end

local function center_coordinates_to_shift(center, height, width)
    return {width / 2 - center[1], height / 2 - center[2]}
end

--- Creates the standard picture prototype framework from a details table.\
--- **path**: string\
--- **width**: number\
--- **height**: number\
--- **shift**: table\
--- **shadowmap**: boolean\
--- **lightmap**: boolean\
--- **glow**: boolean
--- @param details table
--- @return PicturePrototype
function Tirislib.Entity.create_standard_picture(details)
    local path = details.path
    local width = details.width
    local height = details.height
    local shift = details.shift or center_coordinates_to_shift(details.center, height, width)
    local scale = details.scale or 1

    local layers = {
        {
            filename = path .. ".png",
            frame_count = 1,
            priority = "high",
            width = width * PIXEL_PER_TILE,
            height = height * PIXEL_PER_TILE,
            shift = shift,
            scale = 0.5 * scale
        }
    }

    if details.shadowmap then
        layers[#layers + 1] = {
            filename = path .. "-shadowmap.png",
            frame_count = 1,
            width = width * PIXEL_PER_TILE,
            height = height * PIXEL_PER_TILE,
            shift = shift,
            scale = 0.5 * scale,
            draw_as_shadow = true
        }
    end

    if details.lightmap then
        layers[#layers + 1] = {
            filename = path .. "-lightmap.png",
            frame_count = 1,
            width = width * PIXEL_PER_TILE,
            height = height * PIXEL_PER_TILE,
            shift = shift,
            scale = 0.5 * scale,
            draw_as_light = true
        }
    end

    if details.glow then
        layers[#layers + 1] = {
            filename = path .. "-glow.png",
            frame_count = 1,
            width = width * PIXEL_PER_TILE,
            height = height * PIXEL_PER_TILE,
            shift = shift,
            scale = 0.5 * scale,
            draw_as_glow = true
        }
    end

    return {layers = layers}
end

--- Creates the standard impact sound.
--- @return SoundPrototype
function Tirislib.Entity.get_standard_impact_sound()
    return {
        filename = "__base__/sound/car-metal-impact.ogg",
        volume = 0.65
    }
end

--- Adds the given crafting category to the entity.
--- @param category_name string
--- @return EntityPrototype itself
function Tirislib.Entity:add_crafting_category(category_name)
    if not self.crafting_categories then
        self.crafting_categories = {}
    end

    if not Tirislib.Tables.contains(self.crafting_categories, category_name) then
        table.insert(self.crafting_categories, category_name)
    end

    return self
end

--- Checks if the EntityPrototype has the given crafting category.
--- @param category_name string
--- @return boolean
function Tirislib.Entity:has_crafting_category(category_name)
    local categories = self.crafting_categories

    return categories ~= nil and Tirislib.Tables.contains(categories, category_name)
end

--- Adds the given RecipeEntryPrototype to the EntityPrototype's loot.
--- @param loot RecipeEntryPrototype
--- @return EntityPrototype itself
function Tirislib.Entity:add_loot(loot)
    if not self.loot then
        self.loot = {}
    end

    for _, current_loot in pairs(self.loot) do
        if current_loot.item == loot.item and current_loot.probability == loot.probability then
            current_loot.count_min = (current_loot.count_min or 1) + (loot.count_min or 1)
            current_loot.count_max = (current_loot.count_max or 1) + (loot.count_max or 1)

            return self
        end
    end

    table.insert(self.loot, loot)
    return self
end

--- Adds the given RecipeEntryPrototype to the EntityPrototype's mining results.
---@param mining_result RecipeEntryPrototype
---@return EntityPrototype itself
function Tirislib.Entity:add_mining_result(mining_result)
    local minable = self.minable

    if not minable then
        return self -- silently do nothing
    end

    if not minable.results then
        if minable.result then
            -- convert to results table
            minable.results = {{type = "item", name = minable.result, amount = minable.count or 1}}
            minable.result = nil
            minable.count = nil
        else
            minable.results = {}
        end
    end

    for _, result in pairs(minable.results) do
        if Tirislib.RecipeEntry.can_be_merged(result, mining_result) then
            Tirislib.RecipeEntry.merge(result, mining_result)
            return self
        end
    end

    table.insert(minable.results, mining_result)

    return self
end

function Tirislib.Entity:get_localised_name()
    return self.localised_name or {"entity-name." .. self.name}
end

function Tirislib.Entity:get_localised_description()
    return self.localised_description or {"entity-description." .. self.name}
end

--- Copies the localisation of the item with the given name to this EntityPrototype.
--- @param item_name string?
--- @return EntityPrototype itself
function Tirislib.Entity:copy_localisation_from_item(item_name)
    if Tirislib then
        return self
    end

    if not item_name then
        if self.minable then
            -- TODO: annoying case of results-table instead of single result
            item_name = self.minable.result
        else
            item_name = self.name
        end
    end

    local item, found = Tirislib.Item.get_by_name(item_name)

    if found then
        self.localised_name = item:get_localised_name()
        self.localised_description = item:get_localised_description()
    end

    return self
end

--- Copies the icon of the item with the given name to this EntityPrototype.
--- @param item_name string?
--- @return EntityPrototype itself
function Tirislib.Entity:copy_icon_from_item(item_name)
    if not item_name then
        if self.minable then
            -- TODO: annoying case of results-table instead of single result
            item_name = self.minable.result
        else
            item_name = self.name
        end
    end

    local item, found = Tirislib.Item.get_by_name(item_name)

    if found then
        self.icon = item.icon
        self.icons = item.icons
        self.icon_size = item.icon_size
    end

    return self
end

local meta = {
    __index = Tirislib.BasePrototype
}

function meta:__call(name)
    return Tirislib.Entity.get(name)
end

setmetatable(Tirislib.Entity, meta)
