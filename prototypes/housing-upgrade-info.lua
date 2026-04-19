local Housing = require("constants.housing")

for level = 1, Housing.max_level do
    local costs = Housing.furniture_costs[level]
    if costs then
        local ingredients = {}
        for _, entry in pairs(costs) do
            ingredients[#ingredients + 1] = {type = "item", name = entry.name, amount = entry.amount}
        end

        local recipe = Tirislib.Recipe.create {
            name = "comfort-upgrade-info-" .. level,
            localised_name = {"recipe-name.comfort-upgrade-info", tostring(level)},
            localised_description = {"recipe-description.comfort-upgrade-info", tostring(level)},
            category = "sosciencity-comfort-upgrade",
            enabled = false,
            ingredients = ingredients,
            results = {},
            main_product = "",
            icons = {
                {icon = "__sosciencity-graphics__/graphics/utility/house.png", icon_size = 64}
            },
            subgroup = "sosciencity-comfort-upgrade-info",
            order = string.format("%02d", level),
            allow_decomposition = false,
            energy_required = 1,
        }

        recipe:add_icon_layer("__sosciencity-graphics__/graphics/utility/number-" .. level .. ".png", "topright", 0.6, nil, 32)
        recipe:add_unlock(Housing.required_tech[level])
    end
end
