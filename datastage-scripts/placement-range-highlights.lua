local Buildings = require("constants.buildings")

for name, details in pairs(Buildings.values) do
    if details.range == "global" then
        local entity = Tirislib.Entity.get_by_name(name)

        entity.radius_visualisation_specification = {
            sprite = {
                layers = {
                    {
                        filename = "__sosciencity-graphics__/graphics/utility/range-global-ring.png",
                        size = 256,
                        tint = {a = 0.4, r = 0.3, g = 1, b = 0.3}
                    },
                    {
                        filename = "__sosciencity-graphics__/graphics/utility/range-global-letters.png",
                        height = 30,
                        width = 150,
                        shift = {0.0, 4.75},
                        tint = {a = 0.4, r = 0.3, g = 1, b = 0.3}
                    }
                }
            },
            distance = 6,
            offset = {0.0, 0.0},
            draw_in_cursor = true,
            draw_on_selection = true
        }
    elseif details.range then
        local entity = Tirislib.Entity.get_by_name(name)

        entity.radius_visualisation_specification = {
            sprite = {
                filename = "__sosciencity-graphics__/graphics/utility/white-pixel.png",
                size = 1,
                scale = 32,
                tint = {a = 0.4, r = 1, g = 1, b = 1}
            },
            distance = details.range,
            offset = {0.0, 0.0},
            draw_in_cursor = true,
            draw_on_selection = false
        }
    end
end
