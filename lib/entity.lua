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
local entity_types = require("lib.prototype-types.entity-types")

--- Gets the EntityPrototype of the given name. If no such Entity exists, a dummy object will be returned instead.
--- @param name string
--- @return EntityPrototype prototype
--- @return boolean found
function Tirislib_Entity.get_by_name(name)
    return Tirislib_Prototype.get(entity_types, name, Tirislib_Entity)
end

--- Creates the EntityPrototype metatable for the given prototype.
--- @param prototype table
--- @return EntityPrototype
function Tirislib_Entity.get_from_prototype(prototype)
    setmetatable(prototype, Tirislib_Entity)
    return prototype
end

--- Unified function for the get_by_name and for the get_from_prototype functions.
--- @param name string|table
--- @return EntityPrototype prototype
--- @return boolean|nil found
function Tirislib_Entity.get(name)
    if type(name) == "string" then
        return Tirislib_Entity.get_by_name(name)
    else
        return Tirislib_Entity.get_from_prototype(name)
    end
end

--- Creates an iterator over all EntityPrototypes of the given entity subtype.
--- @param prototype_type string
--- @return function
--- @return string
--- @return EntityPrototype
function Tirislib_Entity.iterate(prototype_type)
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

--- Creates an EntityPrototype from the given prototype table.
--- @param prototype table
--- @return EntityPrototype prototype
function Tirislib_Entity.create(prototype)
    data:extend {prototype}
    return Tirislib_Entity.get(prototype)
end

--- Creates a selection box with the given width and height in tiles.
--- @param width number
--- @param height number
--- @return table selection_box
function Tirislib_Entity.get_selection_box(width, height)
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
function Tirislib_Entity.get_collision_box(width, height)
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
function Tirislib_Entity:set_collision_box(width, height)
    self.collision_box = Tirislib_Entity.get_collision_box(width, height)
    return self
end

--- Sets the selection box of the EntityPrototype.
--- @param width number
--- @param height number
--- @return EntityPrototype itself
function Tirislib_Entity:set_selection_box(width, height)
    self.selection_box = Tirislib_Entity.get_selection_box(width, height)
    return self
end

--- Sets the size of the EntityPrototype, which inclused the selection and collision box.
--- @param width number
--- @param height number
--- @return EntityPrototype itself
function Tirislib_Entity:set_size(width, height)
    self.selection_box = Tirislib_Entity.get_selection_box(width, height)
    self.collision_box = Tirislib_Entity.get_collision_box(width, height)

    return self
end

--- Creates an empty sprite.
--- @return SpritePrototype empty
function Tirislib_Entity.get_empty_sprite()
    return {
        filename = "__sosciencity-graphics__/graphics/empty.png",
        size = 1
    }
end

--- Creates an empty animation.
--- @return AnimationPrototype empty
function Tirislib_Entity.get_empty_animation()
    return {
        filename = "__sosciencity-graphics__/graphics/empty.png",
        size = 1,
        frame_count = 1
    }
end

--- Creates a placeholder picture.
--- @return PicturePrototype placeholder
function Tirislib_Entity.get_placeholder_picture()
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
        ret[direction] = ret[direction] or Tirislib_Entity.get_empty_sprite()
    end

    return ret
end

local pipepictures = {
    north = {
        filename = "__sosciencity-graphics__/graphics/entity/assembling-machine-1-pipe-N.png",
        width = 35,
        height = 18,
        shift = util.by_pixel(2.5, 14),
        hr_version = {
            filename = "__sosciencity-graphics__/graphics/entity/hr-assembling-machine-1-pipe-N.png",
            width = 71,
            height = 38,
            shift = util.by_pixel(2.25, 13.5),
            scale = 0.5
        }
    },
    east = {
        filename = "__sosciencity-graphics__/graphics/entity/assembling-machine-1-pipe-E.png",
        width = 20,
        height = 38,
        shift = util.by_pixel(-25, 1),
        hr_version = {
            filename = "__sosciencity-graphics__/graphics/entity/hr-assembling-machine-1-pipe-E.png",
            width = 42,
            height = 76,
            shift = util.by_pixel(-24.5, 1),
            scale = 0.5
        }
    },
    south = {
        filename = "__sosciencity-graphics__/graphics/entity/assembling-machine-1-pipe-S.png",
        width = 44,
        height = 31,
        shift = util.by_pixel(0, -31.5),
        hr_version = {
            filename = "__sosciencity-graphics__/graphics/entity/hr-assembling-machine-1-pipe-S.png",
            width = 88,
            height = 61,
            shift = util.by_pixel(0, -31.25),
            scale = 0.5
        }
    },
    west = {
        filename = "__sosciencity-graphics__/graphics/entity/assembling-machine-1-pipe-W.png",
        width = 19,
        height = 37,
        shift = util.by_pixel(25.5, 1.5),
        hr_version = {
            filename = "__sosciencity-graphics__/graphics/entity/hr-assembling-machine-1-pipe-W.png",
            width = 39,
            height = 73,
            shift = util.by_pixel(25.75, 1.25),
            scale = 0.5
        }
    }
}

--- Creates the standart pipe pictures for the given directions.
--- @param directions table
--- @return PicturePrototype pipe_picture
function Tirislib_Entity.get_standard_pipe_pictures(directions)
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
--- @param directions table
--- @return PicturePrototype cover_picture
function Tirislib_Entity.get_standard_pipe_cover(directions)
    return copy_directions(pipecovers, directions)
end

local PIXEL_PER_TILE = 32
local PIXEL_PER_TILE_HR = 64

--- Deprecated. Creates the standard picture prototype framework.
--- @param path string
--- @param width number
--- @param height number
--- @param shift table
--- @return PicturePrototype
function Tirislib_Entity.create_standard_picture_old(path, width, height, shift)
    return {
        layers = {
            {
                filename = path .. ".png",
                priority = "high",
                width = width * PIXEL_PER_TILE,
                height = height * PIXEL_PER_TILE,
                shift = shift,
                hr_version = {
                    filename = path .. "-hr.png",
                    priority = "high",
                    width = width * PIXEL_PER_TILE_HR,
                    height = height * PIXEL_PER_TILE_HR,
                    shift = shift,
                    scale = 0.5
                }
            },
            {
                filename = path .. "-shadowmap.png",
                priority = "high",
                width = width * PIXEL_PER_TILE,
                height = height * PIXEL_PER_TILE,
                shift = shift,
                draw_as_shadow = true,
                hr_version = {
                    filename = path .. "-shadowmap-hr.png",
                    priority = "high",
                    width = width * PIXEL_PER_TILE_HR,
                    height = height * PIXEL_PER_TILE_HR,
                    shift = shift,
                    scale = 0.5,
                    draw_as_shadow = true
                }
            }
        }
    }
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
function Tirislib_Entity.create_standard_picture(details)
    local path = details.path
    local width = details.width
    local height = details.height
    local shift = details.shift

    local layers = {
        {
            filename = path .. "-lr.png",
            priority = "high",
            width = width * PIXEL_PER_TILE,
            height = height * PIXEL_PER_TILE,
            shift = shift,
            hr_version = {
                filename = path .. ".png",
                priority = "high",
                width = width * PIXEL_PER_TILE_HR,
                height = height * PIXEL_PER_TILE_HR,
                shift = shift,
                scale = 0.5
            }
        }
    }

    if details.shadowmap then
        layers[#layers + 1] = {
            filename = path .. "-shadowmap-lr.png",
            priority = "high",
            width = width * PIXEL_PER_TILE,
            height = height * PIXEL_PER_TILE,
            shift = shift,
            draw_as_shadow = true,
            hr_version = {
                filename = path .. "-shadowmap.png",
                priority = "high",
                width = width * PIXEL_PER_TILE_HR,
                height = height * PIXEL_PER_TILE_HR,
                shift = shift,
                scale = 0.5,
                draw_as_shadow = true
            }
        }
    end

    if details.lightmap then
        layers[#layers + 1] = {
            filename = path .. "-lightmap-lr.png",
            priority = "high",
            width = width * PIXEL_PER_TILE,
            height = height * PIXEL_PER_TILE,
            shift = shift,
            draw_as_light = true,
            hr_version = {
                filename = path .. "-lightmap.png",
                priority = "high",
                width = width * PIXEL_PER_TILE_HR,
                height = height * PIXEL_PER_TILE_HR,
                shift = shift,
                scale = 0.5,
                draw_as_light = true
            }
        }
    end

    if details.glow then
        layers[#layers + 1] = {
            filename = path .. "-glow-lr.png",
            priority = "high",
            width = width * PIXEL_PER_TILE,
            height = height * PIXEL_PER_TILE,
            shift = shift,
            draw_as_glow = true,
            hr_version = {
                filename = path .. "-glow.png",
                priority = "high",
                width = width * PIXEL_PER_TILE_HR,
                height = height * PIXEL_PER_TILE_HR,
                shift = shift,
                scale = 0.5,
                draw_as_glow = true
            }
        }
    end

    return {layers = layers}
end

--- Creates the standard impact sound.
--- @return SoundPrototype
function Tirislib_Entity.get_standard_impact_sound()
    return {
        filename = "__base__/sound/car-metal-impact.ogg",
        volume = 0.65
    }
end

--- Adds the given crafting category to the entity.
--- @param category_name string
--- @return EntityPrototype itself
function Tirislib_Entity:add_crafting_category(category_name)
    if not self.crafting_categories then
        self.crafting_categories = {}
    end

    if not Tirislib_Tables.contains(self.crafting_categories, category_name) then
        table.insert(self.crafting_categories, category_name)
    end

    return self
end

--- Checks if the EntityPrototype has the given crafting category.
--- @param category_name string
--- @return boolean
function Tirislib_Entity:has_crafting_category(category_name)
    local categories = self.crafting_categories

    return categories ~= nil and Tirislib_Tables.contains(categories, category_name)
end

--- Adds the given RecipeEntryPrototype to the EntityPrototype's loot.
--- @param loot RecipeEntryPrototype
--- @return EntityPrototype itself
function Tirislib_Entity:add_loot(loot)
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
function Tirislib_Entity:add_mining_result(mining_result)
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
        if Tirislib_RecipeEntry.can_be_merged(result, mining_result) then
            Tirislib_RecipeEntry.merge(result, mining_result)
            return self
        end
    end

    table.insert(minable.results, mining_result)

    return self
end

--- Copies the localisation of the item with the given name to this EntityPrototype.
--- @param item_name string
--- @return EntityPrototype itself
function Tirislib_Entity:copy_localisation_from_item(item_name)
    item_name = item_name or self.name
    local item = Tirislib_Item.get_by_name(item_name)

    self.localised_name = item.localised_name or {"item-name." .. item_name}
    self.localised_description = item.localised_description or {"item-description." .. item_name}

    return self
end

local meta = {}

function meta:__call(name)
    return Tirislib_Entity.get(name)
end

setmetatable(Tirislib_Entity, meta)
