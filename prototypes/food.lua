require("constants.food")

local function percentage(numerator, denominator)
    return string.format("%.0f", 100. * numerator / denominator) .. "%"
end
---------------------------------------------------------------------------------------------------
-- << items >>

-- things that are needed to create the prototype, but shouldn't be in memory during the control stage
local foods = {
    {name = "mammal-meat"},
    {name = "bird-meat"},
    {name = "insect-meat"},
    {name = "fish-meat"},
    {name = "alien-meat", sprite_variations = {name = "alien-meat", count = 2, include_icon = true}},
    {name = "offal", sprite_variations = {name = "offal", count = 2, include_icon = true}},
    {name = "nan-egg"},
    {name = "primal-egg"},
    {name = "unnamed-fruit", sprite_variations = {name = "unnamed-fruit-pile", count = 4}},
    {name = "weird-berry", sprite_variations = {name = "weird-berry-pile", count = 4}},
    {name = "brutal-pumpkin", sprite_variations = {name = "brutal-pumpkin", count = 2, include_icon = true}},
    {name = "ortrot-fruit", sprite_variations = {name = "ortrot-fruit-pile", count = 4}},
    {name = "apple", sprite_variations = {name = "apple-pile", count = 4}},
    {name = "blue-grapes", sprite_variations = {name = "blue-grapes-pile", count = 3}},
    {name = "lemon", sprite_variations = {name = "lemon-pile", count = 3}},
    {name = "orange", sprite_variations = {name = "orange-pile", count = 3}},
    {name = "zetorn", sprite_variations = {name = "zetorn-pile", count = 3}},
    {name = "cherry", sprite_variations = {name = "cherry-pile", count = 3}},
    {name = "olive", sprite_variations = {name = "olive-pile", count = 3}},
    {name = "bell-pepper", sprite_variations = {name = "bell-pepper-pile", count = 4}},
    {name = "potato", sprite_variations = {name = "potato-pile", count = 4}},
    {name = "tomato", sprite_variations = {name = "tomato-pile", count = 4}},
    {name = "eggplant", sprite_variations = {name = "eggplant-pile", count = 5}},
    {name = "fawoxylas", sprite_variations = {name = "fawoxylas-pile", count = 4}},
    {name = "avocado", sprite_variations = {name = "avocado-pile", count = 4}},
    {name = "chickpeas"},
    {name = "hummus"}
}

-- add the food values to the... prototype prototype
for _, food in pairs(foods) do
    local food_details = Food.values[food.name]

    local calories = food_details.fat + food_details.carbohydrates + food_details.proteins

    local taste = food_details.taste_quality
    local health = food_details.healthiness
    local luxury = food_details.luxury

    food.distinctions = food.distinctions or {}
    local distinctions = food.distinctions

    distinctions.durability = food_details.calories
    distinctions.durability_description_key = "description.food-key"
    distinctions.durability_description_value = "description.food-value"
    distinctions.infinite = false
    distinctions.localised_description = {
        "sosciencity-util.foods",
        {"item-description." .. food.name},
        {"food-category." .. food_details.food_category},
        {"food-group." .. food_details.group},
        Food.taste_names[food_details.taste_category],
        {"color-scale." .. taste, {"taste-scale." .. taste}},
        {"description.sos-details", food_details.taste_quality},
        {"color-scale." .. health, {"health-scale." .. health}},
        {"description.sos-details", food_details.healthiness},
        {"color-scale." .. luxury, {"luxury-scale." .. luxury}},
        {"description.sos-details", food_details.luxury},
        food_details.fat,
        {"description.sos-details", percentage(food_details.fat, calories)},
        food_details.carbohydrates,
        {"description.sos-details", percentage(food_details.carbohydrates, calories)},
        food_details.proteins,
        {"description.sos-details", percentage(food_details.proteins, calories)}
    }
end

Tirislib_Item.batch_create(foods, {type = "tool", subgroup = "sosciencity-food"})

---------------------------------------------------------------------------------------------------
-- << recipes >>

Tirislib_RecipeGenerator.create {
    product = "hummus",
    ingredients = {
        {name = "chickpeas", amount = 10},
        --{name = "sesame", amount = 10} TODO: sesame item
    },
    category = "sosciencity-orchid-food-processing",
    unlock = "hummus"
}
