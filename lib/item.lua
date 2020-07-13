---------------------------------------------------------------------------------------------------
-- << class for items >>
Tirislib_Item = {}

-- this makes an object of this class call the class methods (if it has no own method)
-- lua is weird
Tirislib_Item.__index = Tirislib_Item

--- Class for arrays of items. Setter-functions can be called on them.
Tirislib_ItemArray = {}
Tirislib_ItemArray.__index = Tirislib_PrototypeArray.__index

-- << getter functions >>
local item_types = require("lib.prototype-types.item-types")
function Tirislib_Item.get_by_name(name)
    return Tirislib_Prototype.get(item_types, name, Tirislib_Item)
end

function Tirislib_Item.get_from_prototype(prototype)
    setmetatable(prototype, Tirislib_Item)
    return prototype
end

function Tirislib_Item.get(name)
    if type(name) == "string" then
        return Tirislib_Item.get_by_name(name)
    else
        return Tirislib_Item.get_from_prototype(name)
    end
end

function Tirislib_Item.pairs(item_type)
    local index, value

    local function _next()
        index, value = next(data.raw[item_type], index)

        if index then
            setmetatable(value, Tirislib_Item)
            return index, value
        end
    end

    return _next, index, value
end

-- << creation >>
function Tirislib_Item.create(prototype)
    if not prototype.type then
        prototype.type = "item"
    end

    data:extend {prototype}
    return Tirislib_Item.get_by_name(prototype.name)
end

--- Creates a bunch of item prototypes.
--- Item specification:
--- name: name of the item prototype
--- sprite_variations: sprite variations for the prototype to use
--- distinctions: table of prototype fields that should be different from the batch specification
function Tirislib_Item.batch_create(item_detail_array, batch_details)
    local prototype_type = batch_details.type or "item"
    local path = batch_details.icon_path or "__sosciencity-graphics__/graphics/icon/"
    local size = batch_details.icon_size or 64
    local subgroup = batch_details.subgroup
    local stack_size = batch_details.stack_size or 200

    local created_items = {}
    for index, details in pairs(item_detail_array) do
        local item =
            Tirislib_Item.create {
            type = prototype_type,
            name = details.name,
            icon = path .. details.name .. ".png",
            icon_size = size,
            subgroup = subgroup,
            order = string.format("%03d", index),
            stack_size = stack_size
        }

        local variations = details.sprite_variations
        if variations then
            item:add_sprite_variations(64, path .. variations.name, variations.count)

            if variations.include_icon then
                item:add_icon_to_sprite_variations()
            end
        end

        Tirislib_Tables.set_fields(item, details.distinctions)

        created_items[#created_items + 1] = item
    end

    setmetatable(created_items, Tirislib_ItemArray)
    return created_items
end

-- << manipulation >>
function Tirislib_Item:is_launchable()
    return (self.rocket_launch_product ~= nil) or (self.rocket_launch_products ~= nil)
end

function Tirislib_Item:get_launch_products()
    if not self:is_launchable() then
        return {}
    end

    return self.rocket_launch_product and {self.rocket_launch_product} or self.rocket_launch_products
end

function Tirislib_Item:add_launch_product(product_prototype)
    if not self:is_launchable() then
        self.rocket_launch_products = {product_prototype}
    else
        if self.rocket_launch_product then
            self.rocket_launch_products = {self.rocket_launch_product}
            self.rocket_launch_product = nil
        end
        table.insert(self.rocket_launch_products, product_prototype)
    end

    return self
end

function Tirislib_Item:add_sprite_variations(size, path, count)
    if not self.pictures then
        self.pictures = {}
    end

    for i = 1, count do
        table.insert(
            self.pictures,
            {
                size = size,
                filename = path .. "-" .. i .. ".png",
                scale = 16. / size
            }
        )
    end
end

function Tirislib_Item:add_icon_to_sprite_variations()
    if not self.pictures then
        self.pictures = {}
    end

    table.insert(
        self.pictures,
        {
            size = self.icon_size,
            filename = self.icon,
            scale = 16. / self.icon_size
        }
    )
end

function Tirislib_Item:set_min_stack_size(size)
    if self.stack_size < size then
        self.stack_size = size
    end

    return self
end

function Tirislib_Item:get_localised_name()
    return self.localised_name or {"item-name." .. self.name}
end

function Tirislib_Item:get_localised_description()
    return self.localised_description or {"item-description." .. self.name}
end

local meta = {}

function meta:__call(name)
    return Tirislib_Item.get(name)
end

setmetatable(Tirislib_Item, meta)
