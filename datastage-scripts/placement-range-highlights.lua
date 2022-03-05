local Buildings = require("constants.buildings")

for name, details in pairs(Buildings.values) do
    if details.range and details.range ~= "global" then
        local entity = Tirislib.Entity.get_by_name(name)

        entity.radius_visualisation_specification = {
            sprite = {
                filename = "__sosciencity-graphics__/graphics/utility/highlight-left-top.png",
                size = 1,
                scale = 32,
                tint = {a = 0.4, r = 1, g = 1, b = 1}
            },
            distance = details.range * 32,
            offset = {0.0, 0.0},
            draw_in_cursor = true,
            draw_on_selection = false
        }
    end
end
