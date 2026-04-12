local Food = require("constants.food")
local Time = require("constants.time")
local Locale = require("classes.locale")

local function make_nutrition_string(nutrition_tags)
    local query = Tirislib.LazyLuaq.from_keyset(nutrition_tags)

    if query:count() == 0 then
        return {"nutrition-tag.none"}
    end

    local localised_tags = query:select(Locale.nutrition_tag):to_array()

    return Tirislib.Locales.create_enumeration(localised_tags, " · ")
end

---------------------------------------------------------------------------------------------------
-- << items >>

-- things that are needed to create the prototype, but shouldn't be in memory during the control stage
local foods = {
    {
        name = "mammal-meat",
        distinctions = {spoil_ticks = 10 * Time.minute, spoil_result = "expired-food"}
    },
    {
        name = "bird-meat",
        distinctions = {spoil_ticks = 10 * Time.minute, spoil_result = "expired-food"}
    },
    {
        name = "insect-meat",
        distinctions = {spoil_ticks = 10 * Time.minute, spoil_result = "expired-food"}
    },
    {
        name = "fish-meat",
        distinctions = {spoil_ticks = 10 * Time.minute, spoil_result = "expired-food"}
    },
    {
        name = "biter-meat",
        distinctions = {spoil_ticks = 10 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "biter-meat", count = 2, include_icon = true}
    },
    {
        name = "fermented-biter-meat",
        distinctions = {spoil_ticks = 10 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "fermented-biter-meat", count = 2, include_icon = true}
    },
    {
        name = "offal",
        distinctions = {spoil_ticks = 10 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "offal", count = 2, include_icon = true}
    },
    {
        name = "nan-egg",
        distinctions = {spoil_ticks = 30 * Time.minute, spoil_result = "expired-food"}
    },
    {
        name = "primal-egg",
        distinctions = {spoil_ticks = 30 * Time.minute, spoil_result = "expired-food"}
    },
    {
        name = "bone-egg",
        distinctions = {spoil_ticks = 30 * Time.minute, spoil_result = "expired-food"}
    },
    {
        name = "unnamed-fruit",
        distinctions = {spoil_ticks = 20 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "unnamed-fruit-pile", count = 4}
    },
    {
        name = "weird-berry",
        distinctions = {spoil_ticks = 20 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "weird-berry-pile", count = 4}
    },
    {
        name = "brutal-pumpkin",
        distinctions = {spoil_ticks = 20 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "brutal-pumpkin", count = 2, include_icon = true}
    },
    {
        name = "ortrot",
        distinctions = {spoil_ticks = 20 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "ortrot-pile", count = 4}
    },
    {
        name = "apple",
        distinctions = {spoil_ticks = 20 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "apple-pile", count = 4}
    },
    {
        name = "blue-grapes",
        distinctions = {spoil_ticks = 15 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "blue-grapes-pile", count = 3}
    },
    {
        name = "lemon",
        distinctions = {spoil_ticks = 15 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "lemon-pile", count = 3}
    },
    {
        name = "orange",
        distinctions = {spoil_ticks = 15 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "orange-pile", count = 3}
    },
    {
        name = "zetorn",
        distinctions = {spoil_ticks = 15 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "zetorn-pile", count = 3}
    },
    {
        name = "cherry",
        distinctions = {spoil_ticks = 15 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "cherry-pile", count = 3}
    },
    {
        name = "olive",
        distinctions = {spoil_ticks = 20 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "olive-pile", count = 3}
    },
    {
        name = "bell-pepper",
        distinctions = {spoil_ticks = 20 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "bell-pepper-pile", count = 4}
    },
    {
        name = "potato",
        distinctions = {spoil_ticks = 40 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "potato-pile", count = 4}
    },
    {
        name = "sesame",
        distinctions = {spoil_ticks = 40 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "sesame-pile", count = 3}
    },
    {
        name = "sugar-beet",
        distinctions = {spoil_ticks = 30 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "sugar-beet-pile", count = 3}
    },
    {
        name = "tomato",
        distinctions = {spoil_ticks = 15 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "tomato-pile", count = 4}
    },
    {
        name = "eggplant",
        distinctions = {spoil_ticks = 20 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "eggplant-pile", count = 5}
    },
    {
        name = "fawoxylas",
        distinctions = {spoil_ticks = 20 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "fawoxylas-pile", count = 4}
    },
    {
        name = "avocado",
        distinctions = {spoil_ticks = 15 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "avocado-pile", count = 4}
    },
    {
        name = "chickpea",
        distinctions = {spoil_ticks = 40 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "chickpea-pile", count = 3}
    },
    {
        name = "liontooth",
        distinctions = {spoil_ticks = 15 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "liontooth-pile", count = 3}
    },
    {
        name = "manok",
        distinctions = {spoil_ticks = 40 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "manok-pile", count = 3}
    },
    {
        name = "tello-fruit",
        distinctions = {spoil_ticks = 20 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "tello-pile", count = 3, include_icon = true}
    },
    {
        name = "razha-bean",
        distinctions = {spoil_ticks = 40 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "razha-bean-pile", count = 3}
    },
    {
        name = "dried-solfaen",
        sprite_variations = {name = "dried-solfaen", count = 3, include_icon = true},
        distinctions = {
            subgroup = "sosciencity-microorganism-products",
            spoil_ticks = 40 * Time.minute,
            spoil_result = "expired-food"
        }
    },
    {
        name = "tofu",
        distinctions = {spoil_ticks = 20 * Time.minute, spoil_result = "expired-food"}
    },
    {
        name = "yuba",
        distinctions = {spoil_ticks = 40 * Time.minute, spoil_result = "expired-food"}
    },
    {
        name = "hummus",
        distinctions = {spoil_ticks = 15 * Time.minute, spoil_result = "expired-food"}
    },
    {
        name = "bread",
        distinctions = {spoil_ticks = 20 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "bread-pile", count = 3}
    },
    {
        name = "queen-algae",
        distinctions = {spoil_ticks = 15 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "queen-algae", count = 3, include_icon = true}
    },
    {
        name = "endower-flower",
        distinctions = {spoil_ticks = 15 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "endower-flower", count = 3, include_icon = true}
    },
    {
        name = "pyrifera",
        distinctions = {spoil_ticks = 15 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "pyrifera", count = 3, include_icon = true}
    },
    {
        name = "pocelial",
        distinctions = {spoil_ticks = 15 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "pocelial-pile", count = 3}
    },
    {
        name = "red-hatty",
        distinctions = {spoil_ticks = 15 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "red-hatty-pile", count = 3}
    },
    {
        name = "birdsnake",
        distinctions = {spoil_ticks = 15 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "birdsnake-pile", count = 3}
    },
    {
        name = "wild-edible-plants",
        distinctions = {spoil_ticks = 15 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "wild-edible-plants", count = 7, include_icon = true}
    },
    {
        name = "wild-fungi",
        distinctions = {spoil_ticks = 15 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "wild-fungi", count = 7, include_icon = true}
    },
    {
        name = "wild-algae",
        distinctions = {spoil_ticks = 15 * Time.minute, spoil_result = "expired-food"},
        sprite_variations = {name = "wild-algae", count = 7, include_icon = true}
    },
    {
        name = "potluck",
        distinctions = {spoil_ticks = 1 * Time.hour, spoil_result = "expired-food"},
        sprite_variations = {name = "potluck", count = 3, include_icon = true}
    }
}

-- add the food values to the... prototype prototype
for _, food in pairs(foods) do
    local food_details = Food.values[food.name]

    local appeal = food_details.appeal
    local health = food_details.healthiness

    local distinctions = Tirislib.Tables.get_subtbl(food, "distinctions")

    distinctions.durability = food_details.calories
    distinctions.durability_description_key = "description.food-key"
    distinctions.durability_description_value = "description.food-value"
    distinctions.infinite = false
    distinctions.localised_description = {
        "sosciencity-util.foods",
        {"item-description." .. food.name}, -- 1: description
        {"food-category." .. food_details.food_category}, -- 2: category
        {"food-group." .. food_details.group}, -- 3: group
        Locale.taste_category(food_details.taste_category), -- 4: taste
        {"color-scale." .. appeal, {"taste-scale." .. appeal}}, -- 5: colored appeal label
        {"description.sos-details", tostring(appeal)}, -- 6: appeal value
        {"color-scale." .. health, {"health-scale." .. health}}, -- 7: colored health label
        {"description.sos-details", tostring(health)}, -- 8: health value
        make_nutrition_string(food_details.nutrition_tags), -- 9: nutrition tags
        tostring(Tirislib.Utils.round_to_step(food_details.fat / Food.energy_density_fat, 0.1)), -- 10: fat g/100g
        tostring(Tirislib.Utils.round_to_step(food_details.carbohydrates / Food.energy_density_carbohydrates, 0.1)), -- 11: carbs g/100g
        tostring(Tirislib.Utils.round_to_step(food_details.proteins / Food.energy_density_proteins, 0.1)) -- 12: protein g/100g
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
        {type = "item", name = "salt", amount = 2}
    },
    category = "sosciencity-fermentation-tank",
    unlock = "fermentation"
}

Tirislib.RecipeGenerator.create {
    product = "hummus",
    product_amount = 20,
    energy_required = 3,
    ingredients = {
        {type = "item", name = "chickpea", amount = 20},
        {type = "item", name = "sesame", amount = 10}
    },
    category = Tirislib.RecipeGenerator.category_alias.food_processing,
    unlock = "hummus"
}

Tirislib.RecipeGenerator.create {
    product = "dried-solfaen",
    product_amount = 5,
    energy_required = 5,
    ingredients = {
        {type = "fluid", name = "solfaen", amount = 100}
    },
    category = Tirislib.RecipeGenerator.category_alias.drying,
    unlock = "basic-biotechnology"
}

Tirislib.RecipeGenerator.create {
    product = "tofu",
    product_amount = 30,
    energy_required = 5,
    byproducts = {{type = "item", name = "yuba", amount = 10}},
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

Tirislib.RecipeGenerator.create {
    product = "potluck",
    energy_required = 3,
    ingredients = {
        {type = "item", name = "wild-edible-plants", amount = 1},
        {type = "item", name = "wild-fungi", amount = 1},
        {type = "item", name = "wild-algae", amount = 1}
    },
    category = "sosciencity-kitchen-for-all"
}

---------------------------------------------------------------------------------------------------
-- << test food items >>

if Sosciencity_Config.DEBUG then
    local test_food_names = {
        "test-food-fruity-carb",
        "test-food-fruity-fat",
        "test-food-neutral-protein-fat",
        "test-food-neutral-carb",
        "test-food-salty-protein",
        "test-food-spicy-alltags",
        "test-food-umami-carb",
        "test-food-umami-notag"
    }

    local test_food_items = {}
    for _, name in pairs(test_food_names) do
        local food_details = Food.values[name]
        test_food_items[#test_food_items + 1] = {
            name = name,
            use_placeholder_icon = true,
            distinctions = {
                durability = food_details.calories,
                durability_description_key = "description.food-key",
                durability_description_value = "description.food-value",
                infinite = false,
                localised_name = name,
                localised_description = {""}
            }
        }
    end

    Tirislib.Item.batch_create(test_food_items, {
        type = "tool",
        subgroup = "sosciencity-food",
        icon = "__sosciencity-graphics__/graphics/icon/placeholder.png",
        icon_size = 64
    })
end
