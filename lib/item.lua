---------------------------------------------------------------------------------------------------
-- << class for items >>
Item = {}

-- this makes an object of this class call the class methods (if it hasn't an own method)
-- lua is weird
Item.__index = Item

-- << getter functions >>
function Item:get_by_name(name)
    local item_types = require("lib.prototype-types.item-types")
    local new = Prototype:get(item_types, name)
    setmetatable(new, Item)
    return new
end

function Item:get_from_prototype(prototype)
    setmetatable(prototype, Item)
    return prototype
end

function Item:get(name)
    if type(name) == "string" then
        return self:get_by_name(name)
    else
        return self:get_from_prototype(name)
    end
end

setmetatable(Item, {__call = Item.get})

-- << creation >>
function Item:create(prototype)
    if not prototype.type then
        prototype.type = "item"
    end

    data:extend {prototype}
    return Item:get_by_name(prototype.name)
end

-- << manipulation >>
function Item:is_launchable()
    return (self.rocket_launch_product ~= nil) or (self.rocket_launch_products ~= nil)
end

function Item:get_launch_products()
    if not self:is_launchable() then
        return nil
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

function Item:add_sprite_variations(size, path, variation_names)
    if not self.pictures then
        self.pictures = {}
    end

    for _, variation in pairs(variation_names) do
        table.insert(
            self.pictures,
            {
                size = size,
                filename = path .. variation .. ".png",
                scale = 16. / size
            }
        )
    end
end
