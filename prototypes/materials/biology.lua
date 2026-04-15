local Unlocks = require("constants.unlocks")

---------------------------------------------------------------------------------------------------
-- << items >>

local biology_items = {
    {
        name = "feathers",
        sprite_variations = {name = "feather-pile", count = 4}
    },
    {
        name = "humus",
        sprite_variations = {name = "humus", count = 2, include_icon = true},
        distinctions = {subgroup = "sosciencity-biology-materials"}
    },
    {
        name = "sewage-sludge",
        sprite_variations = {name = "sewage-sludge", count = 3, include_icon = true},
        distinctions = {subgroup = "sosciencity-biology-materials"}
    },
    {
        name = "salt",
        sprite_variations = {name = "salt", count = 3, include_icon = true},
        distinctions = {subgroup = "sosciencity-biology-materials"}
    },
    {
        name = "flour",
        sprite_variations = {name = "flour", count = 2, include_icon = true},
        distinctions = {subgroup = "sosciencity-biology-materials"}
    },
    {
        name = "sugar",
        sprite_variations = {name = "sugar", count = 3, include_icon = true},
        distinctions = {subgroup = "sosciencity-biology-materials"}
    },
    {
        name = "molasses",
        sprite_variations = {name = "molasses", count = 3, include_icon = true},
        distinctions = {subgroup = "sosciencity-biology-materials"}
    },
    {
        name = "mold",
        distinctions = {subgroup = "sosciencity-biology-materials"}
    },
    {
        name = "amylum",
        distinctions = {subgroup = "sosciencity-biology-materials"}
    },
    {
        name = "agarose",
        sprite_variations = {name = "agarose", count = 3, include_icon = true},
        distinctions = {subgroup = "sosciencity-biology-materials"}
    },
    {
        name = "solid-fat",
        distinctions = {
            subgroup = "sosciencity-biology-materials",
            fuel_value = "500kJ",
            fuel_category = "chemical"
        }
    },
    {
        name = "proteins",
        sprite_variations = {name = "proteins-pile", count = 3},
        distinctions = {subgroup = "sosciencity-biology-materials"}
    },
    {
        name = "pemtenn-extract",
        distinctions = {subgroup = "sosciencity-microorganism-products"}
    }
}

Tirislib.Item.batch_create(
    biology_items,
    {subgroup = "sosciencity-materials", stack_size = 200}
)

---------------------------------------------------------------------------------------------------
-- << fluids >>

local biology_fluids = {
    {
        name = "fatty-oil",
        distinctions = {
            base_color = {r = 0.965, g = 0.784, b = 0.040},
            flow_color = {r = 0.965, g = 0.784, b = 0.040}
        }
    },
    {
        name = "soy-milk",
        distinctions = {
            base_color = {r = 0.933, g = 0.894, b = 0.729},
            flow_color = {r = 0.933, g = 0.894, b = 0.729}
        }
    },
    {
        name = "ethanol",
        distinctions = {subgroup = "sosciencity-microorganism-products"}
    }
}

Tirislib.Fluid.batch_create(
    biology_fluids,
    {
        default_temperature = 10,
        max_temperature = 100,
        base_color = {r = 0.151, g = 0.483, b = 0.933},
        flow_color = {r = 0.151, g = 0.483, b = 0.933},
        subgroup = "sosciencity-fluid-materials"
    }
)

---------------------------------------------------------------------------------------------------
-- << recipes >>

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "salt", amount = 5}
    },
    name = "salty-water-evaporation",
    category = "sosciencity-salt-pond",
    energy_required = 4,
    unlock = {"fermentation", "medbay"}
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "flour", amount = 5}
    },
    ingredients = {
        {type = "item", name = "hardcorn-punk", amount = 5}
    },
    name = "hardcorn-punk",
    energy_required = 1,
    unlock = "food-processing"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "sugar", amount = 1, product = true},
        {type = "item", name = "molasses", amount = 1}
    },
    ingredients = {
        {type = "item", name = "tello-fruit", amount = 2}
    },
    name = "tello-fruit",
    category = "chemistry",
    energy_required = 1.6,
    allow_productivity = true,
    unlock = "basic-biotechnology"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "sugar", amount = 3, product = true},
        {type = "item", name = "molasses", amount = 1}
    },
    ingredients = {
        {type = "item", name = "sugar-beet", amount = 2}
    },
    name = "sugar-beet",
    category = "chemistry",
    energy_required = 1.6,
    allow_productivity = true
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "sugar", amount = 3, product = true},
        {type = "item", name = "molasses", amount = 2}
    },
    ingredients = {
        {type = "item", name = "sugar-cane", amount = 2}
    },
    name = "sugar-cane",
    category = "chemistry",
    energy_required = 1.6,
    allow_productivity = true
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "amylum", amount_min = 2, amount_max = 6}
    },
    ingredients = {
        {type = "item", name = "flour", amount = 5},
        {type = "fluid", name = "clean-water", amount = 80}
    },
    name = "flour",
    category = "sosciencity-pharma",
    energy_required = 4,
    allow_productivity = true,
    do_index_fluid_ingredients = true,
    unlock = "medbay"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "agarose", amount = 1}
    },
    ingredients = {
        {type = "item", name = "dried-solfaen", amount = 1},
        {type = "fluid", name = "steam", amount = 10}
    },
    name = "dried-solfaen",
    category = "chemistry",
    unlock = "basic-biotechnology"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "fluid", name = "fatty-oil", amount = 20}
    },
    ingredients = {
        {type = "item", name = "weird-berry", amount = 5}
    },
    name = "weird-berry",
    energy_required = 1.6,
    unlock = "explore-alien-flora-1"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "fluid", name = "fatty-oil", amount = 30}
    },
    ingredients = {
        {type = "item", name = "avocado", amount = 5}
    },
    name = "avocado",
    energy_required = 1.6
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "fluid", name = "fatty-oil", amount = 30}
    },
    ingredients = {
        {type = "item", name = "olive", amount = 5}
    },
    name = "olive",
    energy_required = 1.6
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "fluid", name = "fatty-oil", amount = 30}
    },
    ingredients = {
        {type = "item", name = "sesame", amount = 5}
    },
    name = "sesame",
    energy_required = 1.6,
    unlock = "hummus"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "solid-fat", amount = 1}
    },
    ingredients = {
        {theme = "hydrogen", amount = 10},
        {type = "fluid", name = "fatty-oil", amount = 10}
    },
    name = "fatty-oil",
    category = "chemistry",
    energy_required = 1.6,
    unlock = "food-processing"
}:add_catalyst(Tirislib.RecipeGenerator.item_alias.nickel_catalyst, "item", 1, 0.5)

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "proteins", amount = 1}
    },
    ingredients = {
        {type = "item", name = "razha-bean", amount = 1},
        {type = "fluid", name = "ethanol", amount = 10}
    },
    name = "razha-bean",
    unlock = "basic-biotechnology"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "soy-milk", amount = 50}
    },
    ingredients = {
        {type = "item", name = "razha-bean", amount = 5},
        {type = "fluid", name = "clean-water", amount = 50}
    },
    name = "razha-bean",
    energy_required = 2,
    unlock = "soy-products"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "ethanol", amount = 50}
    },
    ingredients = {
        {type = "item", name = "blue-grapes", amount = 10},
        {type = "fluid", name = "pemtenn", amount = 10}
    },
    name = "blue-grapes",
    category = "sosciencity-fermentation-tank",
    energy_required = 5,
    unlock = "fermentation"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "ethanol", amount = 50}
    },
    ingredients = {
        {type = "item", name = "sugar", amount = 2},
        {type = "fluid", name = "pemtenn", amount = 10}
    },
    name = "sugar",
    category = "sosciencity-fermentation-tank",
    energy_required = 5,
    unlock = "basic-biotechnology"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "pemtenn-extract", amount = 10}
    },
    ingredients = {
        {type = "fluid", name = "pemtenn", amount = 100}
    },
    name = "pemtenn",
    energy_required = 5,
    unlock = "fermentation"
}
