require("constants.food")

-- things that are needed to create the prototype, but shouldn't be in memory during the control stage
local additional_prototype_data = {
    ["alien-meat"] = {
        sprite_variations = {name = "alien-meat", count = 2, include_icon = true}
    },
    ["potato"] = {
        sprite_variations = {name = "potato-pile", count = 4}
    },
    ["unnamed-fruit"] = {
        sprite_variations = {name = "unnamed-fruit-pile", count = 4}
    },
    ["tomato"] = {
        sprite_variations = {name = "tomato-pile", count = 4}
    },
    ["eggplant"] = {
        sprite_variations = {name = "eggplant-pile", count = 5}
    }
}

local function percentage(numerator, denominator)
    return string.format("%.0f", 100. * numerator / denominator) .. "%"
end

for food_name, food_details in pairs(Food.values) do
    local calories = food_details.fat + food_details.carbohydrates + food_details.proteins

    local taste = food_details.taste_quality
    local health = food_details.healthiness
    local luxury = food_details.luxury

    local item_prototype =
        Tirislib_Item.create {
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
            {"taste-category." .. Types.taste_names[food_details.taste_category]},
            {"color-scale." .. taste ,{"taste-scale." .. taste}},
            {"description.sos-details", food_details.taste_quality},
            {"color-scale." .. health ,{"health-scale." .. health}},
            {"description.sos-details", food_details.healthiness},
            {"color-scale." .. luxury ,{"luxury-scale." .. luxury}},
            {"description.sos-details", food_details.luxury},
            food_details.fat,
            {"description.sos-details", percentage(food_details.fat, calories)},
            food_details.carbohydrates,
            {"description.sos-details", percentage(food_details.carbohydrates, calories)},
            food_details.proteins,
            {"description.sos-details", percentage(food_details.proteins, calories)}
        }
    }

    local details = additional_prototype_data[food_name] or {}

    if details.sprite_variations then
        item_prototype:add_sprite_variations(64, "__sosciencity__/graphics/icon/", details.sprite_variations)

        if details.sprite_variations.include_icon then
            item_prototype:add_icon_to_sprite_variations()
        end
    end

    Tirislib_Tables.set_fields(item_prototype, details.distinctions)
end
