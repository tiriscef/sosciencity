require("constants.food")

local function percentage(numerator, denominator)
    return string.format("%.0f", 100. * numerator / denominator)
end

for food_name, food_details in pairs(Food.values) do
    local calories = food_details.fat + food_details.carbohydrates + food_details.proteins

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
end
