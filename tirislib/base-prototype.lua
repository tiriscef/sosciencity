---------------------------------------------------------------------------------------------------
-- << base class for all prototypes >>
--- @class BasePrototype
Tirislib.BasePrototype = Tirislib.BasePrototype or {}

-- this makes an object of this class call the class methods (if it has no own method)
-- lua is weird
Tirislib.BasePrototype.__index = Tirislib.BasePrototype

--- Resolves the main_product shorthand to an explicit icon, so that icon layer methods
--- work correctly on recipes that rely on Factorio's icon auto-derivation.
--- No-op if icon or icons is already set, or if main_product is absent/empty.
--- @return BasePrototype itself
function Tirislib.BasePrototype:resolve_main_product_icon()
    if self.icon or self.icons or type(self.main_product) ~= "string" or self.main_product == "" then
        return self
    end

    local source, found = Tirislib.Item.get_by_name(self.main_product)
    if not found then
        source, found = Tirislib.Fluid.get_by_name(self.main_product)
    end
    if not found then return self end

    if source.icons then
        -- shallow copy so later add_icon_layer calls don't mutate the source prototype
        self.icons = {}
        for k, v in pairs(source.icons) do
            self.icons[k] = v
        end
    elseif source.icon then
        self.icon = source.icon
        self.icon_size = self.icon_size or source.icon_size
    end

    return self
end

function Tirislib.BasePrototype:convert_to_icons_table()
    -- resolve before the guard so that a source.icons result sets self.icons and skips the init block
    Tirislib.BasePrototype.resolve_main_product_icon(self)

    if not self.icons then
        self.icons = {}

        if self.icon then
            local layer = {
                icon = self.icon,
                icon_size = self.icon_size
            }

            -- preserve Factorio 2.0 IconData fields
            if self.icon_draw_background ~= nil then
                layer.draw_background = self.icon_draw_background
            end
            if self.icon_floating ~= nil then
                layer.floating = self.icon_floating
            end

            self.icons[#self.icons + 1] = layer
        end

        self.icon = nil
        self.icon_size = nil
    end
end

local named_icon_shifts = {
    ["topleft"] = {-8, -8},
    ["topright"] = {8, -8},
    ["bottomleft"] = {-8, 8},
    ["bottomright"] = {8, 8}
}

--- Adds a new icon layer ontop the one of this prototype.
--- @param path string
--- @param shift table|string|nil a pixel offset table or a named position ("topleft", "topright", "bottomleft", "bottomright")
--- @param scale number?
--- @param tint table?
--- @param icon_size number? defaults to 64
--- @return BasePrototype itself
function Tirislib.BasePrototype:add_icon_layer(path, shift, scale, tint, icon_size)
    Tirislib.BasePrototype.convert_to_icons_table(self)

    if type(shift) == "string" then
        shift = named_icon_shifts[shift]
    end

    self.icons[#self.icons + 1] = {
        icon = path,
        icon_size = icon_size or 64,
        shift = shift,
        scale = scale or 0.3,
        tint = tint
    }

    return self
end

--- Adds a small number badge as an icon layer, used to visually distinguish
--- recipes that share the same product icon.
--- @param n integer the number to display (must have a matching number-N.png in sosciencity-graphics)
--- @param shift table|string|nil a pixel offset table or a named position ("topleft", "topright", "bottomleft", "bottomright"), defaults to "topright"
--- @return BasePrototype itself
function Tirislib.BasePrototype:add_number_layer(n, shift)
    if n > 15 or n < 1 then
        error("My friend, we don't have a number icon for " .. n .. " yet. Be realistic!")
    end

    return Tirislib.BasePrototype.add_icon_layer(
        self,
        "__sosciencity-graphics__/graphics/utility/number-" .. n .. ".png",
        shift or "topright",
        0.6,
        nil,
        32
    )
end

--- Registry of category-icon definitions used by add_category_layer.
Tirislib.BasePrototype.category_icons = Tirislib.BasePrototype.category_icons or {}

--- Registers a named category icon that can later be applied via add_category_layer.
--- Category icons are the "where it's made" indicator (e.g. handcrafting, workshop)
--- and live in the topleft corner per the icon-layer corner convention:
--- topright = tier indicator, topleft = category indicator, bottomleft = ingredient indicator.
--- @param key string
--- @param options table { path = string, scale? = number, tint? = table, no_tint? = bool, default_corner? = string, icon_size? = number }
function Tirislib.BasePrototype.register_category_icon(key, options)
    Tirislib.BasePrototype.category_icons[key] = {
        path = options.path,
        scale = options.scale or 0.25,
        tint = options.no_tint and nil or (options.tint or {a = 0.5, r = 1, g = 1, b = 1}),
        default_corner = options.default_corner or "topleft",
        icon_size = options.icon_size or 64,
    }
end

--- Adds a previously-registered category icon as an icon layer.
--- Errors loudly if the key was never registered.
--- @param key string registry key passed to register_category_icon
--- @param shift table|string|nil overrides the registered default corner
--- @return BasePrototype itself
function Tirislib.BasePrototype:add_category_layer(key, shift)
    local entry = Tirislib.BasePrototype.category_icons[key]
    if not entry then
        error("No category icon registered for key '" .. tostring(key) .. "'. This indicates a typo or a forgotten registration.")
    end

    return Tirislib.BasePrototype.add_icon_layer(
        self,
        entry.path,
        shift or entry.default_corner,
        entry.scale,
        entry.tint,
        entry.icon_size
    )
end

--- Adds the icon of the named item (or fluid) as an icon layer, used to disambiguate
--- recipes that produce the same product from different ingredients. Defaults to the
--- "ingredient" corner (bottomleft).<br>
--- The lookup is deferred via Tirislib.Prototype.postpone if the source prototype doesn't exist yet.
--- @param entry string|table prototype name (item-first lookup) OR an entry table {type = "item"|"fluid", name = "..."} to be explicit in case an item and a fluid share the name
--- @param shift table|string|nil defaults to "bottomleft"
--- @return BasePrototype itself
function Tirislib.BasePrototype:add_ingredient_layer(entry, shift)
    Tirislib.BasePrototype.convert_to_icons_table(self)

    if type(shift) == "string" then
        shift = named_icon_shifts[shift]
    end
    shift = shift or named_icon_shifts["bottomleft"]

    local source, found
    if type(entry) == "table" then
        if entry.type == "fluid" then
            source, found = Tirislib.Fluid.get_by_name(entry.name)
        else
            source, found = Tirislib.Item.get_by_name(entry.name)
        end
    else
        source, found = Tirislib.Item.get_by_name(entry)
        if not found then
            source, found = Tirislib.Fluid.get_by_name(entry)
        end
    end

    if not found then
        Tirislib.Prototype.postpone(
            Tirislib.BasePrototype.add_ingredient_layer, self, entry, shift
        )
        return self
    end

    local source_layers
    if source.icons then
        source_layers = source.icons
    elseif source.icon then
        source_layers = {{icon = source.icon, icon_size = source.icon_size}}
    else
        return self
    end

    local overlay_scale = 0.3
    for _, layer in pairs(source_layers) do
        local new_layer = {}
        for k, v in pairs(layer) do
            new_layer[k] = v
        end
        new_layer.scale = overlay_scale * (layer.scale or 1)
        local lsx = (layer.shift and layer.shift[1]) or 0
        local lsy = (layer.shift and layer.shift[2]) or 0
        new_layer.shift = {
            shift[1] + lsx * overlay_scale,
            shift[2] + lsy * overlay_scale,
        }
        self.icons[#self.icons + 1] = new_layer
    end

    return self
end

--- Adds a custom tooltip field to the prototype.
--- @param tooltip_table table
--- @return BasePrototype itself
function Tirislib.BasePrototype:add_custom_tooltip(tooltip_table)
    self.custom_tooltip_fields = self.custom_tooltip_fields or {}

    self.custom_tooltip_fields[#self.custom_tooltip_fields + 1] = tooltip_table

    return self
end
