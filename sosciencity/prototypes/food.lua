require("constants.food")

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
        durability = 100,
        durability_description_key = "description.sosciencity-food-key",
        durability_description_value = "description.sosciencity-food-value",
        infinite = false
    }

    if food.food_category == "organic" then
        -- TODO create grow recipes
        Recipe:create {}
    end
end
