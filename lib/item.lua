---------------------------------------------------------------------------------------------------
-- << class for items >>
Tirislib_Item = {}

-- this makes an object of this class call the class methods (if it has no own method)
-- lua is weird
Tirislib_Item.__index = Tirislib_Item

-- << getter functions >>
function Tirislib_Item.get_by_name(name)
    local item_types = require("lib.prototype-types.item-types")
    local new = Tirislib_Prototype.get(item_types, name)
    setmetatable(new, Tirislib_Item)
    return new
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

local meta = {}

function meta:__call(name)
    return Tirislib_Item.get(name)
end

setmetatable(Tirislib_Item, meta)
