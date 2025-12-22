---------------------------------------------------------------------------------------------------
-- << class for items >>
--- @class ItemPrototype
Tirislib.Item = {}

-- this makes an object of this class call the class methods (if it has no own method)
-- lua is weird
Tirislib.Item.__index = Tirislib.Item

--- Class for arrays of items. Setter-functions can be called on them.
--- @class ItemPrototypeArray
Tirislib.ItemArray = {}
Tirislib.ItemArray.__index = Tirislib.PrototypeArray.__index

-- << getter functions >>
local item_types = require("prototype-types.item-types")
local equipment_types = require("prototype-types.equipment-types")

--- Gets the ItemPrototype of the given name. If no such Item exists, a dummy object will be returned instead.
--- @param name string
--- @return ItemPrototype prototype
--- @return boolean found
function Tirislib.Item.get_by_name(name)
    return Tirislib.Prototype.get(item_types, name, Tirislib.Item)
end

--- Creates the ItemPrototype metatable for the given prototype.
--- @param prototype table
--- @return ItemPrototype
function Tirislib.Item.get_from_prototype(prototype)
    setmetatable(prototype, Tirislib.Item)
    return prototype
end

--- Unified function for the get_by_name and for the get_from_prototype functions.
--- @param name string|table
--- @return ItemPrototype prototype
--- @return boolean|nil found
function Tirislib.Item.get(name)
    if type(name) == "string" then
        return Tirislib.Item.get_by_name(name)
    else
        return Tirislib.Item.get_from_prototype(name)
    end
end

--- Creates an iterator over all ItemPrototypes of the given entity subtypes.
--- @param types table|string|nil
--- @return function
--- @return string
--- @return ItemPrototype
function Tirislib.Item.iterate(types)
    -- no argument - iterate over all types
    if types == nil then
        types = item_types
    end
    -- one type given - iterate over just that type
    if type(types) ~= "table" then
        types = {types}
    end

    local name, item, type_index, prototype_type
    type_index, prototype_type = next(types, type_index)

    local function _next()
        name, item = next(data.raw[prototype_type] or {}, name)

        if name then
            setmetatable(item, Tirislib.Item)
            return name, item
        else
            type_index, prototype_type = next(types, type_index)
            if prototype_type ~= nil then
                return _next()
            end
        end
    end

    return _next, name, item
end

--- Returns an ItemPrototypeArray with all ItemPrototypes of the given subtypes.
--- @return ItemPrototypeArray prototypes
function Tirislib.Item.all(...)
    local types = {...}
    if #types == 0 then
        -- return all items if no types are given
        types = item_types
    end

    local array = {}
    setmetatable(array, Tirislib.ItemArray)

    for _, item in Tirislib.Item.iterate(types) do
        array[#array + 1] = item
    end

    return array
end

-- << creation >>

--- Creates an ItemPrototype from the given prototype table.
--- @param prototype table
--- @return ItemPrototype prototype
function Tirislib.Item.create(prototype)
    prototype.type = prototype.type or "item"

    Tirislib.Prototype.create(prototype)

    local ret = Tirislib.Item.get_by_name(prototype.name)
    return ret
end

--- Creates a bunch of item prototypes.\
--- **Item specification:**\
--- **name:** name of the item prototype\
--- **sprite_variations:** sprite variations for the prototype to use\
--- **distinctions:** table of prototype fields that should be different from the batch specification\
--- **custom_tooltip_fields:** array of custom tooltip fields
--- @param item_data_array table
--- @param batch_data table
--- @return ItemPrototypeArray
function Tirislib.Item.batch_create(item_data_array, batch_data)
    local prototype_type = batch_data.type or "item"
    local path = batch_data.icon_path or "__sosciencity-graphics__/graphics/icon/"
    local size = batch_data.icon_size or 64
    local subgroup = batch_data.subgroup
    local stack_size = batch_data.stack_size or 200

    local created_items = {}
    for index, data in pairs(item_data_array) do
        local icon = data.use_placeholder_icon and Tirislib.Prototype.placeholder_icon or (path .. data.name .. ".png")

        local prototype = {
            type = prototype_type,
            name = data.name,
            icon = icon,
            icon_size = size,
            subgroup = subgroup,
            order = string.format("%03d", index),
            stack_size = stack_size
        }
        Tirislib.Tables.set_fields_passively(prototype, batch_data)
        Tirislib.Tables.set_fields(prototype, data.distinctions)

        local item = Tirislib.Item.create(prototype)

        local variations = data.sprite_variations
        if variations then
            item:add_sprite_variations(64, path .. variations.name, variations.count)

            if variations.include_icon then
                item:add_icon_to_sprite_variations()
            end
        end

        for _, field in pairs(data.custom_tooltip_fields or {}) do
            item:add_custom_tooltip(field)
        end

        created_items[#created_items + 1] = item
    end

    setmetatable(created_items, Tirislib.ItemArray)
    return created_items
end

-- << manipulation >>

--- Checks if the item is launchable, which means that it has launch products.
--- @return boolean
function Tirislib.Item:is_launchable()
    return (self.rocket_launch_product ~= nil) or (self.rocket_launch_products ~= nil)
end

--- Returns the RecipeEntryPrototypes of this item's launch products.
--- @return table
function Tirislib.Item:get_launch_products()
    if not self:is_launchable() then
        return {}
    end

    return self.rocket_launch_product and {self.rocket_launch_product} or self.rocket_launch_products
end

--- Adds the given RecipeEntryPrototype to this item's launch products.
--- @param product_prototype RecipeEntryPrototype
--- @return ItemPrototype itself
function Tirislib.Item:add_launch_product(product_prototype)
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

--- Adds the given amount of standardized sprite variations to the item.
--- @param size number
--- @param path string
--- @param count integer
--- @return ItemPrototype itself
function Tirislib.Item:add_sprite_variations(size, path, count)
    if not self.pictures then
        self.pictures = {}
    end

    for i = 1, count do
        table.insert(
            self.pictures,
            {
                size = size,
                filename = path .. "-" .. i .. ".png",
                scale = 32. / size
            }
        )
    end

    return self
end

--- Adds the item's icon to its sprite variations.
--- @return ItemPrototype itself
function Tirislib.Item:add_icon_to_sprite_variations()
    if not self.pictures then
        self.pictures = {}
    end

    table.insert(
        self.pictures,
        {
            size = self.icon_size,
            filename = self.icon,
            scale = 32. / self.icon_size
        }
    )

    return self
end

--- Sets the stack size to the given number if that number isn't smaller that the current stack size.
--- @param size integer
--- @return ItemPrototype itself
function Tirislib.Item:set_min_stack_size(size)
    if self.stack_size < size then
        self.stack_size = size
    end

    return self
end

--- Returns the localised name of the item.
--- @return locale
function Tirislib.Item:get_localised_name()
    if self.localised_name then
        return self.localised_name
    end

    if self.place_result then
        local entity = Tirislib.Entity.get_by_name(self.place_result)
        return entity:get_localised_name()
    end
    if self.place_as_equipment_result then
        local equipment = Tirislib.Prototype.get(equipment_types, self.place_as_equipment_result)
        return equipment.localised_name or {"equipment-name" .. self.place_as_equipment_result}
    end
    if self.place_as_tile then
        local tile = Tirislib.Prototype.get("tile", self.place_as_tile)

        if tile.localised_name then
            return tile.localised_name
        end
    end

    return {"item-name." .. self.name}
end

--- Returns the localised description of the item.
--- @return locale
function Tirislib.Item:get_localised_description()
    if self.localised_description then
        return self.localised_description
    end

    if self.place_result then
        local entity = Tirislib.Entity.get_by_name(self.place_result)
        return entity:get_localised_description()
    end
    if self.place_as_equipment_result then
        local equipment = Tirislib.Prototype.get(equipment_types, self.place_as_equipment_result)
        return equipment.localised_description or {"equipment-name" .. self.place_as_equipment_result}
    end
    if self.place_as_tile then
        local tile = Tirislib.Prototype.get("tile", self.place_as_tile)

        if tile.localised_description then
            return tile.localised_description
        end
    end

    return {"item-description." .. self.name}
end

local meta = {
    __index = Tirislib.BasePrototype
}

function meta:__call(name)
    return Tirislib.Item.get(name)
end

setmetatable(Tirislib.Item, meta)
