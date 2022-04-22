--- Named color definitions.
local Color = {}

Color.blue = {r = 0, g = 0, b = 1}
Color.brown = {r = 0.45, g = 0.3, b = 0.1}
Color.darkish_red = {r = 0.8, g = 0.1, b = 0.1}
Color.red = {r = 1, g = 0, b = 0}
Color.green = {r = 0, g = 1, b = 0}
Color.grey = {r = 0.8, g = 0.8, b = 0.8}
Color.yellowish_green = {r = 0.7, g = 0.9, b = 0.2}
Color.light_blue = {r = 0.13, g = 0.57, b = 0.75}
Color.light_teal = {r = 0, g = 0.8, b = 1}
Color.orange = {r = 1, g = 0.45, b = 0}
Color.tooltip_orange = {r = 1, g = 0.9, b = 0.75}
Color.purple = {r = 0.5, g = 0, b = 0.5}
Color.white = {r = 1, g = 1, b = 1}

for _, color in pairs(Color) do
    color.a = 1
end

return Color
