---------------------------------------------------------------------------------------------------
-- << class for items >>
Item = {}

-- this makes an object of this class call the class methods (if it hasn't an own method)
-- lua is weird
Item.__index = Item

-- << getter functions >>
function Item.get_by_name(name)
    local item_types = require("lib.prototype-types.item-types")
    local new = Prototype.get(item_types, name)
    setmetatable(new, Item)
    return new
end

function Item.get_from_prototype(prototype)
    setmetatable(prototype, Item)
    return prototype
end

function Item.get(name)
    if type(name) == "string" then
        return Item.get_by_name(name)
    else
        return Item.get_from_prototype(name)
    end
end

function Item.pairs(item_type)
    local index, value

    local function _next()
        index, value = next(data.raw[item_type], index)

        if index then
            setmetatable(value, Item)
            return index, value
        end
    end

    return _next, index, value
end

-- << creation >>
function Item.create(prototype)
    if not prototype.type then
        prototype.type = "item"
    end

    data:extend {prototype}
    return Item.get_by_name(prototype.name)
end

-- << manipulation >>
function Item:is_launchable()
    return (self.rocket_launch_product ~= nil) or (self.rocket_launch_products ~= nil)
end

function Item:get_launch_products()
    if not self:is_launchable() then
        return {}
    end

    return self.rocket_launch_product and {self.rocket_launch_product} or self.rocket_launch_products
end

function Item:add_launch_product(product_prototype)
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

function Item:add_sprite_variations(size, path, variations)
    if not self.pictures then
        self.pictures = {}
    end

    for i = 1, variations.count do
        table.insert(
            self.pictures,
            {
                size = size,
                filename = path .. variations.name .. "-" .. i .. ".png",
                scale = 16. / size
            }
        )
    end
end

function Item:add_icon_to_sprite_variations()
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

local meta = {}

function meta:__call(name)
    return Item.get(name)
end

setmetatable(Item, meta)
