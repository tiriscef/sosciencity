--- Named color definitions.
Colors = {}

Colors.blue = {r = 0, g = 0, b = 1}
Colors.brown = {r = 0.45, g = 0.3, b = 0.1}
Colors.darkish_red = {r = 0.8, g = 0.1, b = 0.1}
Colors.grey = {r = 0.8, g = 0.8, b = 0.8}
Colors.light_teal = {r = 0, g = 0.8, b = 1}
Colors.orange = {r = 1, g = 0.45, b = 0}
Colors.purple = {r = 0.5, g = 0, b = 0.5}
Colors.white = {r = 1, g = 1, b = 1}

for _, color in pairs(Colors) do
    color.a = 1
end
