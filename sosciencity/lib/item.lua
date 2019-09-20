Item = {}

function Item:get(name)
    local item_types = require("lib.prototype-types.item-types")
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
