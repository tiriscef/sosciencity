require("constants.food")

local function percentage(numerator, denominator)
    return string.format("%.0f", 100. * numerator / denominator)
end

for food_name, food in pairs(food_values) do
    Item:create {
        type = "tool",
        name = food_name,
        enabled = true,
        icon = "__sosciencity__/graphics/icon/" .. food_name .. ".png",
        icon_size = 64,
        flags = {},
        subgroup = "sosciencity-food",
        order = food_name,
        stack_size = 200,
        durability = food.calories,
        durability_description_key = "description.sosciencity-food-key",
        durability_description_value = "description.sosciencity-food-value",
        infinite = false,
        localised_description = {
            "item-description.foods",
            {"item-description." .. food_name},
            {"food-category." .. food.food_category},
            {"taste-category." .. Types.taste_lookup[food.taste_category]},
            {"taste-scale." .. food.taste_quality},
            {"health-scale." .. food.healthiness},
            {"luxority-scale." .. food.luxority},
            food.fat,
            percentage(food.fat, food.calories),
            food.carbohydrates,
            percentage(food.carbohydrates, food.calories),
            food.proteins,
            percentage(food.proteins, food.calories),
        }
    }
end
