require("constants.food")

-- things that are needed to create the prototype, but shouldn't be in memory during the control stage
local additional_prototype_data = {
    ["potato"] = {
        sprite_variations = {name = "potato-pile", count = 4}
    }
}

local function percentage(numerator, denominator)
    return string.format("%.0f", 100. * numerator / denominator)
end

for food_name, food_details in pairs(Food.values) do
    local calories = food_details.fat + food_details.carbohydrates + food_details.proteins

    local item_prototype = Item:create {
        type = "tool",
        name = food_name,
        enabled = true,
        icon = "__sosciencity__/graphics/icon/" .. food_name .. ".png",
        icon_size = 64,
        flags = {},
        subgroup = "sosciencity-food",
        order = food_name,
        stack_size = 200,
        durability = food_details.calories,
        durability_description_key = "description.food-key",
        durability_description_value = "description.food-value",
        infinite = false,
        localised_description = {
            "item-description.foods",
            {"item-description." .. food_name},
            {"food-category." .. food_details.food_category},
            {"taste-category." .. Types.taste_lookup[food_details.taste_category]},
            {"taste-scale." .. food_details.taste_quality},
            {"health-scale." .. food_details.healthiness},
            {"luxury-scale." .. food_details.luxury},
            food_details.fat,
            percentage(food_details.fat, calories),
            food_details.carbohydrates,
            percentage(food_details.carbohydrates, calories),
            food_details.proteins,
            percentage(food_details.proteins, calories),
        }
    }

    local details = additional_prototype_data[food_name] or {}

    if details.sprite_variations then
        item_prototype:add_sprite_variations(64, "__sosciencity__/graphics/icon/", details.sprite_variations)

        if details.sprite_variations.include_icon then
            item_prototype:add_icon_to_sprite_variations()
        end
    end
end
