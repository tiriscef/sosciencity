local Housing = require("constants.housing")
local HousingTrait = require("enums.housing-trait")

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

        recipe:add_icon_layer(
            "__sosciencity-graphics__/graphics/utility/number-" .. level .. ".png",
            "topright",
            0.6,
            nil,
            32)
        recipe:add_unlock(Housing.required_tech[level])
    end
end

-- TODO: better fitting icons
local tag_info = {
    [HousingTrait.green]     = {name = "green", icon = "__sosciencity-graphics__/graphics/icon/phytofall-blossom.png", icon_size = 64},
    [HousingTrait.technical] = {name = "technical", icon = "__base__/graphics/icons/advanced-circuit.png", icon_size = 64},
    [HousingTrait.decorated] = {name = "decorated", icon = "__sosciencity-graphics__/graphics/icon/painting.png", icon_size = 64},
}

for tag, info in pairs(tag_info) do
    local costs = Housing.tag_costs[tag]
    if costs then
        local ingredients = {}
        for _, entry in pairs(costs) do
            ingredients[#ingredients + 1] = {type = "item", name = entry.name, amount = entry.amount}
        end

        local recipe = Tirislib.Recipe.create {
            name = "housing-trait-upgrade-info-" .. info.name,
            localised_name = {"recipe-name.housing-trait-upgrade-info", {"housing-trait." .. info.name}},
            localised_description = {"recipe-description.housing-trait-upgrade-info", {"housing-trait." .. info.name}},
            category = "sosciencity-comfort-upgrade",
            enabled = false,
            ingredients = ingredients,
            results = {},
            main_product = "",
            icons = {
                {icon = "__sosciencity-graphics__/graphics/utility/house.png", icon_size = 64}
            },
            subgroup = "sosciencity-trait-upgrade-info",
            order = info.name,
            allow_decomposition = false,
            energy_required = 1,
        }

        recipe:add_icon_layer(info.icon, "bottomright", 0.6, nil, info.icon_size)
        recipe:add_unlock(Housing.tag_required_tech[tag])
    end
end
