local Food = require("constants.food")

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
    {name = "biter-meat", sprite_variations = {name = "biter-meat", count = 2, include_icon = true}},
    {name = "fermented-biter-meat", sprite_variations = {name = "fermented-biter-meat", count = 2, include_icon = true}},
    {name = "offal", sprite_variations = {name = "offal", count = 2, include_icon = true}},
    {name = "nan-egg"},
    {name = "primal-egg"},
    {name = "bone-egg"},
    {name = "unnamed-fruit", sprite_variations = {name = "unnamed-fruit-pile", count = 4}},
    {name = "weird-berry", sprite_variations = {name = "weird-berry-pile", count = 4}},
    {name = "brutal-pumpkin", sprite_variations = {name = "brutal-pumpkin", count = 2, include_icon = true}},
    {name = "ortrot", sprite_variations = {name = "ortrot-pile", count = 4}},
    {name = "apple", sprite_variations = {name = "apple-pile", count = 4}},
    {name = "blue-grapes", sprite_variations = {name = "blue-grapes-pile", count = 3}},
    {name = "lemon", sprite_variations = {name = "lemon-pile", count = 3}},
    {name = "orange", sprite_variations = {name = "orange-pile", count = 3}},
    {name = "zetorn", sprite_variations = {name = "zetorn-pile", count = 3}},
    {name = "cherry", sprite_variations = {name = "cherry-pile", count = 3}},
    {name = "olive", sprite_variations = {name = "olive-pile", count = 3}},
    {name = "bell-pepper", sprite_variations = {name = "bell-pepper-pile", count = 4}},
    {name = "potato", sprite_variations = {name = "potato-pile", count = 4}},
    {name = "sesame", sprite_variations = {name = "sesame-pile", count = 3}},
    {name = "sugar-beet", sprite_variations = {name = "sugar-beet-pile", count = 3}},
    {name = "tomato", sprite_variations = {name = "tomato-pile", count = 4}},
    {name = "eggplant", sprite_variations = {name = "eggplant-pile", count = 5}},
    {name = "fawoxylas", sprite_variations = {name = "fawoxylas-pile", count = 4}},
    {name = "avocado", sprite_variations = {name = "avocado-pile", count = 4}},
    {name = "chickpea", sprite_variations = {name = "chickpea-pile", count = 3}},
    {name = "liontooth", sprite_variations = {name = "liontooth-pile", count = 3}},
    {name = "manok", sprite_variations = {name = "manok-pile", count = 3}},
    {name = "tello-fruit", sprite_variations = {name = "tello-pile", count = 3, include_icon = true}},
    {name = "razha-bean", sprite_variations = {name = "razha-bean-pile", count = 3}},
    {
        name = "dried-solfaen",
        sprite_variations = {name = "dried-solfaen", count = 3, include_icon = true},
        distinctions = {subgroup = "sosciencity-microorganism-products"}
    },
    {name = "tofu"},
    {name = "yuba"},
    {name = "hummus"},
    {name = "bread", sprite_variations = {name = "bread-pile", count = 3}},
    {name = "queen-algae", sprite_variations = {name = "queen-algae", count = 3, include_icon = true}},
    {name = "endower-flower", sprite_variations = {name = "endower-flower", count = 3, include_icon = true}},
    {name = "pyrifera", sprite_variations = {name = "pyrifera", count = 3, include_icon = true}},
    {name = "pocelial", sprite_variations = {name = "pocelial-pile", count = 3}}
}

-- add the food values to the... prototype prototype
for _, food in pairs(foods) do
    local food_details = Food.values[food.name]

    local calories = food_details.fat + food_details.carbohydrates + food_details.proteins

    local taste = food_details.taste_quality
    local health = food_details.healthiness
    local luxury = food_details.luxury

    local distinctions = Tirislib.Tables.get_subtbl(food, "distinctions")

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

Tirislib.Item.batch_create(foods, {type = "tool", subgroup = "sosciencity-food"})

---------------------------------------------------------------------------------------------------
-- << recipes >>

Tirislib.RecipeGenerator.create {
    product = "fermented-biter-meat",
    product_amount = 10,
    energy_required = 5,
    ingredients = {
        {type = "item", name = "biter-meat", amount = 10},
        {type = "item", name = "salt", amount = 2},
        {type = "fluid", name = "pemtenn", amount = 10}
    },
    category = "sosciencity-fermentation-tank",
    unlock = "fermentation"
}

Tirislib.RecipeGenerator.create {
    product = "hummus",
    product_amount = 20,
    energy_required = 3,
    ingredients = {
        {name = "chickpea", amount = 20},
        {name = "sesame", amount = 10}
    },
    category = Tirislib.RecipeGenerator.category_alias.food_processing,
    unlock = "hummus"
}

Tirislib.RecipeGenerator.create {
    product = "dried-solfaen",
    ingredients = {
        {type = "fluid", name = "solfaen", amount = 10}
    },
    category = Tirislib.RecipeGenerator.category_alias.drying,
    unlock = "basic-biotechnology"
}

Tirislib.RecipeGenerator.create {
    product = "tofu",
    product_amount = 30,
    energy_required = 5,
    byproducts = {{name = "yuba", amount = 10}},
    ingredients = {
        {type = "fluid", name = "soy-milk", amount = 200}
    },
    category = Tirislib.RecipeGenerator.category_alias.food_processing,
    unlock = "soy-products"
}

Tirislib.RecipeGenerator.create {
    product = "bread",
    product_min = 10,
    product_max = 20,
    energy_required = 2,
    ingredients = {
        {type = "item", name = "flour", amount = 10},
        {type = "fluid", name = "pemtenn", amount = 10}
    },
    category = Tirislib.RecipeGenerator.category_alias.food_processing,
    unlock = "food-processing"
}
