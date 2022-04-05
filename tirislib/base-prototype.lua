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
            self.icons[#self.icons+1] = {icon = self.icon}
        end

        self.icon = nil
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
--- @param shift table|string|nil
--- @param scale number|nil
function Tirislib.BasePrototype:add_icon_layer(path, shift, scale)
    Tirislib.BasePrototype.convert_to_icons_table(self)

    if type(shift) == "string" then
        shift = named_icon_shifts[shift]
    end

    self.icons[#self.icons+1] = {
        icon = path,
        shift = shift,
        scale = scale or 0.3
    }

    return self
end
