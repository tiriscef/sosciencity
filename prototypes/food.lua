local Time = require("constants.time")
local Food = require("constants.food")
local Unlocks = require("constants.unlocks")

---------------------------------------------------------------------------------------------------
-- << items >>

-- things that are needed to create the prototype, but shouldn't be in memory during the control stage
local foods = {
    {
        name = "mammal-meat",
        spoil_ticks = 10 * Time.minute,
        spoil_result = "expired-food"
    },
    {
        name = "bird-meat",
        spoil_ticks = 10 * Time.minute,
        spoil_result = "expired-food"
    },
    {
        name = "insect-meat",
        spoil_ticks = 30 * Time.minute,
        spoil_result = "expired-food"
    },
    {
        name = "fish-meat",
        spoil_ticks = 10 * Time.minute,
        spoil_result = "expired-food"
    },
    {
        name = "biter-meat",
        spoil_ticks = 10 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "biter-meat", count = 2, include_icon = true}
    },
    {
        name = "fermented-biter-meat",
        spoil_ticks = 2 * Time.hour,
        spoil_result = "expired-food",
        sprite_variations = {name = "fermented-biter-meat", count = 2, include_icon = true}
    },
    {
        name = "offal",
        spoil_ticks = 10 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "offal", count = 2, include_icon = true}
    },
    {
        name = "nan-egg",
        spoil_ticks = 30 * Time.minute,
        spoil_result = "expired-food"
    },
    {
        name = "primal-egg",
        spoil_ticks = 30 * Time.minute,
        spoil_result = "expired-food"
    },
    {
        name = "bone-egg",
        spoil_ticks = 30 * Time.minute,
        spoil_result = "expired-food"
    },
    {
        name = "unnamed-fruit",
        spoil_ticks = 20 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "unnamed-fruit-pile", count = 4}
    },
    {
        name = "weird-berry",
        spoil_ticks = 20 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "weird-berry-pile", count = 4}
    },
    {
        name = "brutal-pumpkin",
        spoil_ticks = 20 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "brutal-pumpkin", count = 2, include_icon = true}
    },
    {
        name = "ortrot",
        spoil_ticks = 20 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "ortrot-pile", count = 4}
    },
    {
        name = "apple",
        spoil_ticks = 20 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "apple-pile", count = 4}
    },
    {
        name = "blue-grapes",
        spoil_ticks = 15 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "blue-grapes-pile", count = 3}
    },
    {
        name = "lemon",
        spoil_ticks = 15 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "lemon-pile", count = 3}
    },
    {
        name = "orange",
        spoil_ticks = 15 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "orange-pile", count = 3}
    },
    {
        name = "zetorn",
        spoil_ticks = 15 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "zetorn-pile", count = 3}
    },
    {
        name = "cherry",
        spoil_ticks = 15 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "cherry-pile", count = 3}
    },
    {
        name = "olive",
        spoil_ticks = 20 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "olive-pile", count = 3}
    },
    {
        name = "bell-pepper",
        spoil_ticks = 20 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "bell-pepper-pile", count = 4}
    },
    {
        name = "potato",
        spoil_ticks = 40 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "potato-pile", count = 4}
    },
    {
        name = "sesame",
        spoil_ticks = 40 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "sesame-pile", count = 3}
    },
    {
        name = "sugar-beet",
        spoil_ticks = 30 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "sugar-beet-pile", count = 3}
    },
    {
        name = "tomato",
        spoil_ticks = 15 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "tomato-pile", count = 4}
    },
    {
        name = "eggplant",
        spoil_ticks = 20 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "eggplant-pile", count = 5}
    },
    {
        name = "fawoxylas",
        spoil_ticks = 20 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "fawoxylas-pile", count = 4}
    },
    {
        name = "avocado",
        spoil_ticks = 15 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "avocado-pile", count = 4}
    },
    {
        name = "chickpea",
        spoil_ticks = 40 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "chickpea-pile", count = 3}
    },
    {
        name = "liontooth",
        spoil_ticks = 15 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "liontooth-pile", count = 3}
    },
    {
        name = "manok",
        spoil_ticks = 40 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "manok-pile", count = 3}
    },
    {
        name = "tello-fruit",
        spoil_ticks = 20 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "tello-pile", count = 3, include_icon = true}
    },
    {
        name = "razha-bean",
        spoil_ticks = 40 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "razha-bean-pile", count = 3}
    },
    {
        name = "dried-solfaen",
        sprite_variations = {name = "dried-solfaen", count = 3, include_icon = true},
        subgroup = "sosciencity-microorganism-products",
        spoil_ticks = 8 * Time.hour,
        spoil_result = "expired-food"
    },
    {
        name = "tofu",
        spoil_ticks = 20 * Time.minute,
        spoil_result = "expired-food"
    },
    {
        name = "yuba",
        spoil_ticks = 40 * Time.minute,
        spoil_result = "expired-food"
    },
    {
        name = "hummus",
        spoil_ticks = 15 * Time.minute,
        spoil_result = "expired-food"
    },
    {
        name = "bread",
        spoil_ticks = 20 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "bread-pile", count = 3}
    },
    {
        name = "queen-algae",
        spoil_ticks = 15 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "queen-algae", count = 3, include_icon = true}
    },
    {
        name = "endower-flower",
        spoil_ticks = 15 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "endower-flower", count = 3, include_icon = true}
    },
    {
        name = "pyrifera",
        spoil_ticks = 15 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "pyrifera", count = 3, include_icon = true}
    },
    {
        name = "pocelial",
        spoil_ticks = 15 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "pocelial-pile", count = 3}
    },
    {
        name = "red-hatty",
        spoil_ticks = 15 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "red-hatty-pile", count = 3}
    },
    {
        name = "birdsnake",
        spoil_ticks = 15 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "birdsnake-pile", count = 3}
    },
    {
        name = "wild-edible-plants",
        spoil_ticks = 45 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "wild-edible-plants", count = 7, include_icon = true}
    },
    {
        name = "wild-fungi",
        spoil_ticks = 45 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "wild-fungi", count = 7, include_icon = true}
    },
    {
        name = "wild-algae",
        spoil_ticks = 45 * Time.minute,
        spoil_result = "expired-food",
        sprite_variations = {name = "wild-algae", count = 7, include_icon = true}
    },
    {
        name = "potluck",
        spoil_ticks = 1 * Time.hour,
        spoil_result = "expired-food",
        sprite_variations = {name = "potluck", count = 3, include_icon = true}
    },
    {
        name = "fruit-salad",
        use_placeholder_icon = true,
        spoil_ticks = 1 * Time.hour,
        spoil_result = "expired-food"
    },
    {
        name = "fishers-stew",
        use_placeholder_icon = true,
        spoil_ticks = 1 * Time.hour,
        spoil_result = "expired-food"
    },
    {
        name = "roast",
        use_placeholder_icon = true,
        spoil_ticks = 1 * Time.hour,
        spoil_result = "expired-food"
    },
    {
        name = "mushroom-roast",
        use_placeholder_icon = true,
        spoil_ticks = 1 * Time.hour,
        spoil_result = "expired-food"
    },
    {
        name = "smoked-meat",
        use_placeholder_icon = true,
        spoil_ticks = 3 * Time.hour,
        spoil_result = "expired-food"
    },
    {
        name = "smoked-fish",
        use_placeholder_icon = true,
        spoil_ticks = 3 * Time.hour,
        spoil_result = "expired-food"
    },
    {
        name = "smoked-birdsnake",
        use_placeholder_icon = true,
        spoil_ticks = 3 * Time.hour,
        spoil_result = "expired-food"
    },
    {
        name = "smoked-tofu",
        use_placeholder_icon = true,
        spoil_ticks = 3 * Time.hour,
        spoil_result = "expired-food"
    },
    {
        name = "ignivern-curry-paste",
        use_placeholder_icon = true,
        spoil_ticks = 2 * Time.hour,
        spoil_result = "expired-food"
    },
    {
        name = "offal-pate",
        use_placeholder_icon = true,
        spoil_ticks = 1 * Time.hour,
        spoil_result = "expired-food"
    },
    {
        name = "fries",
        use_placeholder_icon = true,
        spoil_ticks = 30 * Time.minute,
        spoil_result = "expired-food"
    },
    {
        name = "custard-tart",
        use_placeholder_icon = true,
        spoil_ticks = 1 * Time.hour,
        spoil_result = "expired-food"
    },
    {
        name = "liontooth-kimchi",
        use_placeholder_icon = true,
        spoil_ticks = 3 * Time.hour,
        spoil_result = "expired-food"
    },
    {
        name = "razha-miso",
        use_placeholder_icon = true,
        spoil_ticks = 4 * Time.hour,
        spoil_result = "expired-food"
    },
    {
        name = "raisins",
        use_placeholder_icon = true,
        spoil_ticks = 8 * Time.hour,
        spoil_result = "expired-food"
    },
    {
        name = "stockfish",
        use_placeholder_icon = true,
        spoil_ticks = 8 * Time.hour,
        spoil_result = "expired-food"
    }
}

Tirislib.Item.batch_create(foods, {subgroup = "sosciencity-food"})

for _, food in pairs(foods) do
    Sosciencity.make_existing_item_food(food.name)
end

---------------------------------------------------------------------------------------------------
-- << recipes >>

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "fermented-biter-meat", amount = 10}
    },
    ingredients = {
        {type = "item", name = "biter-meat", amount = 10},
        {type = "item", name = "salt",       amount = 2}
    },
    category = "sosciencity-fermentation-tank",
    energy_required = 5,
    unlock = "fermentation",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "hummus", amount = 20}
    },
    ingredients = {
        {type = "item", name = "chickpea", amount = 20},
        {type = "item", name = "sesame",   amount = 10}
    },
    energy_required = 3,
    category = "sosciencity-orchid-food-processing",
    unlock = "hummus",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "dried-solfaen", amount = 5}
    },
    ingredients = {
        {type = "fluid", name = "solfaen", amount = 100}
    },
    energy_required = 5,
    category = "sosciencity-drying-unit",
    unlock = "basic-biotechnology",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "tofu", amount = 30, product = true},
        {type = "item", name = "yuba", amount = 10}
    },
    ingredients = {
        {type = "fluid", name = "soy-milk", amount = 200}
    },
    energy_required = 5,
    category = "sosciencity-orchid-food-processing",
    unlock = "soy-products",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "bread", amount_min = 10, amount_max = 20}
    },
    ingredients = {
        {type = "item",  name = "flour",   amount = 10},
        {type = "fluid", name = "pemtenn", amount = 10}
    },
    energy_required = 2,
    category = "sosciencity-orchid-food-processing",
    unlock_with_item = "flour",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "potluck", amount = 1}
    },
    ingredients = {
        {type = "item", name = "wild-edible-plants", amount = 1},
        {type = "item", name = "wild-fungi",         amount = 1},
        {type = "item", name = "wild-algae",         amount = 1}
    },
    category = "sosciencity-kitchen-for-all",
    energy_required = 3,
    unlock = "kitchen-for-all",
    auto_recycle = false
}

---------------------------------------------------------------------------------------------------
-- << meals of the kitchen for all >>

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "fruit-salad", amount = 1}
    },
    ingredients = {
        {type = "item", name = "unnamed-fruit", amount = 1},
        {type = "item", name = "blue-grapes", amount = 1}
    },
    category = "sosciencity-kitchen-for-all",
    energy_required = 3,
    unlock = "kitchen-for-all",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    name = "fruit-salad-from-orange-and-cherry",
    results = {
        {type = "item", name = "fruit-salad", amount = 1}
    },
    ingredients = {
        {type = "item", name = "orange", amount = 1},
        {type = "item", name = "cherry", amount = 1}
    },
    category = "sosciencity-kitchen-for-all",
    energy_required = 3,
    unlock = {Unlocks.get_tech_name("orange"), Unlocks.get_tech_name("cherry")},
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "fishers-stew", amount = 1}
    },
    ingredients = {
        {type = "item", name = "fish-meat", amount = 1},
        {type = "item", name = "wild-algae", amount = 1}
    },
    category = "sosciencity-kitchen-for-all",
    energy_required = 3,
    unlock = "kitchen-for-all",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "roast", amount = 1}
    },
    ingredients = {
        {type = "item", name = "mammal-meat", amount = 1},
        {type = "item", name = "wild-fungi", amount = 1}
    },
    category = "sosciencity-kitchen-for-all",
    energy_required = 3,
    unlock = "kitchen-for-all",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    name = "roast-from-bird-meat",
    results = {
        {type = "item", name = "roast", amount = 1}
    },
    ingredients = {
        {type = "item", name = "bird-meat", amount = 1},
        {type = "item", name = "wild-fungi", amount = 1}
    },
    category = "sosciencity-kitchen-for-all",
    energy_required = 3,
    unlock = "kitchen-for-all",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "mushroom-roast", amount = 1}
    },
    ingredients = {
        {type = "item", name = "pocelial", amount = 1},
        {type = "item", name = "fawoxylas", amount = 1}
    },
    category = "sosciencity-kitchen-for-all",
    energy_required = 3,
    unlock = "kitchen-for-all",
    auto_recycle = false
}

---------------------------------------------------------------------------------------------------
-- << smoked foods >>

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "smoked-meat", amount = 5}
    },
    ingredients = {
        {type = "item", name = "mammal-meat", amount = 5},
        {type = "item", name = "salt", amount = 1},
        {type = "item", name = "sawdust", amount = 2}
    },
    category = "sosciencity-smoking",
    energy_required = 10,
    unlock = "smoking",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    name = "smoked-meat-from-bird-meat",
    results = {
        {type = "item", name = "smoked-meat", amount = 5}
    },
    ingredients = {
        {type = "item", name = "bird-meat", amount = 5},
        {type = "item", name = "salt", amount = 1},
        {type = "item", name = "sawdust", amount = 2}
    },
    category = "sosciencity-smoking",
    energy_required = 10,
    unlock = "smoking",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "smoked-fish", amount = 5}
    },
    ingredients = {
        {type = "item", name = "fish-meat", amount = 5},
        {type = "item", name = "salt", amount = 1},
        {type = "item", name = "sawdust", amount = 2}
    },
    category = "sosciencity-smoking",
    energy_required = 10,
    unlock = "smoking",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "smoked-birdsnake", amount = 5}
    },
    ingredients = {
        {type = "item", name = "birdsnake", amount = 5},
        {type = "item", name = "salt", amount = 1},
        {type = "item", name = "sawdust", amount = 2}
    },
    category = "sosciencity-smoking",
    energy_required = 10,
    unlock = "smoking",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "smoked-tofu", amount = 5}
    },
    ingredients = {
        {type = "item", name = "tofu", amount = 5},
        {type = "item", name = "salt", amount = 1},
        {type = "item", name = "sawdust", amount = 2}
    },
    category = "sosciencity-smoking",
    energy_required = 10,
    unlock = "soy-products",
    auto_recycle = false
}

---------------------------------------------------------------------------------------------------
-- << refined foods of the orchid food factory >>

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "ignivern-curry-paste", amount = 20}
    },
    ingredients = {
        {type = "item", name = "ignivern", amount = 10},
        {type = "item", name = "red-hatty", amount = 10},
        {type = "fluid", name = "fatty-oil", amount = 20}
    },
    category = "sosciencity-orchid-food-processing",
    energy_required = 4,
    unlock = "food-processing",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "offal-pate", amount = 10}
    },
    ingredients = {
        {type = "item", name = "offal", amount = 10},
        {type = "item", name = "salt", amount = 2},
        {type = "item", name = "solid-fat", amount = 2}
    },
    category = "sosciencity-orchid-food-processing",
    energy_required = 4,
    unlock = "food-processing",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "fries", amount = 10}
    },
    ingredients = {
        {type = "item", name = "potato", amount = 10},
        {type = "item", name = "salt", amount = 1},
        {type = "fluid", name = "fatty-oil", amount = 10}
    },
    category = "sosciencity-orchid-food-processing",
    energy_required = 3,
    unlock = Unlocks.get_tech_name("potato"),
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "custard-tart", amount = 10}
    },
    ingredients = {
        {type = "item", name = "flour", amount = 10},
        {type = "item", name = "sugar", amount = 5},
        {type = "item", name = "queen-algae", amount = 5}
    },
    category = "sosciencity-orchid-food-processing",
    energy_required = 4,
    unlock_with_item = "flour",
    auto_recycle = false
}

---------------------------------------------------------------------------------------------------
-- << pickled and dried foods >>

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "liontooth-kimchi", amount = 10}
    },
    ingredients = {
        {type = "item", name = "liontooth", amount = 10},
        {type = "item", name = "salt", amount = 2}
    },
    category = "sosciencity-fermentation-tank",
    energy_required = 10,
    unlock = "fermentation",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "razha-miso", amount = 10}
    },
    ingredients = {
        {type = "item", name = "razha-bean", amount = 10},
        {type = "item", name = "salt", amount = 2},
        {type = "fluid", name = "pemtenn", amount = 10}
    },
    category = "sosciencity-fermentation-tank",
    energy_required = 10,
    unlock = "fermentation",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "raisins", amount = 10}
    },
    ingredients = {
        {type = "item", name = "blue-grapes", amount = 10}
    },
    category = "sosciencity-drying-unit",
    energy_required = 10,
    unlock = "fermentation",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "stockfish", amount = 10}
    },
    ingredients = {
        {type = "item", name = "fish-meat", amount = 10},
        {type = "item", name = "salt", amount = 2}
    },
    category = "sosciencity-drying-unit",
    energy_required = 10,
    unlock = "fermentation",
    auto_recycle = false
}

---------------------------------------------------------------------------------------------------
-- << test food items >>

if Sosciencity.Config.DEBUG then
    local test_food_names = {
        "test-food-fruity-carb",
        "test-food-fruity-fat",
        "test-food-neutral-protein-fat",
        "test-food-neutral-carb",
        "test-food-salty-protein",
        "test-food-spicy-alltags",
        "test-food-umami-carb",
        "test-food-umami-notag",
        "test-food-neutral-huwan-nutrients"
    }

    local test_food_items = {}
    for _, name in pairs(test_food_names) do
        local food_details = Food.values[name]
        test_food_items[#test_food_items + 1] = {
            name = name,
            use_placeholder_icon = true,
            durability = food_details.calories,
            durability_description_key = "description.food-key",
            durability_description_value = "description.food-value",
            infinite = false,
            localised_name = name,
            localised_description = {""}
        }
    end

    Tirislib.Item.batch_create(test_food_items, {
        type = "tool",
        subgroup = "sosciencity-food",
        icon = "__sosciencity-graphics__/graphics/icon/placeholder.png",
        icon_size = 64
    })

    -- Test kitchen-for-all recipes so integration tests can call set_recipe() to
    -- open the output inventory slots before inserting test food items.
    Tirislib.RecipeGenerator.create {
        results = {
            {type = "item", name = "test-food-fruity-carb", amount = 1}
        },
        name = "test-kitchen-fruity-carb",
        category = "sosciencity-kitchen-for-all"
    }
    Tirislib.RecipeGenerator.create {
        results = {
            {type = "item", name = "test-food-neutral-protein-fat", amount = 1}
        },
        name = "test-kitchen-protein-fat",
        category = "sosciencity-kitchen-for-all"
    }
end
