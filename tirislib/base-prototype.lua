---------------------------------------------------------------------------------------------------
-- << base class for all prototypes >>
Tirislib.BasePrototype = {}

-- this makes an object of this class call the class methods (if it has no own method)
-- lua is weird
Tirislib.BasePrototype.__index = Tirislib.BasePrototype

function Tirislib.BasePrototype:convert_to_icons_table()
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
--- @param scale number|nil
--- @param tint table|nil
--- @param icon_size number|nil defaults to 64
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

--- Adds a custom tooltip field to the prototype.
--- @param tooltip_table table
--- @return BasePrototype itself
function Tirislib.BasePrototype:add_custom_tooltip(tooltip_table)
    self.custom_tooltip_fields = self.custom_tooltip_fields or {}

    self.custom_tooltip_fields[#self.custom_tooltip_fields + 1] = tooltip_table

    return self
end
