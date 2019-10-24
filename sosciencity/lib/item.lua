---------------------------------------------------------------------------------------------------
-- << class for items >>
Item = {}

-- << getter functions >>
function Item:get(name)
    local item_types = require("lib.prototype-types.item-types")
    local new = Prototype:get(item_types, name)
    setmetatable(new, self)
    return new
end

function Item:__call(name)
    return self:get(name)
end

function Item:from_prototype(prototype)
    setmetatable(prototype, self)
    return prototype
end

-- << creation >>
function Item:create(prototype)
    data:extend {prototype}
    return self.__call(prototype.name)
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

function Item:add_sprite_variations(size, path, variations)
    if not self.pictures then
        self.pictures = {}
    end

    for _, variation in pairs(variations) do
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
