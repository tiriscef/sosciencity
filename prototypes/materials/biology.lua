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

Tirislib.RecipeGenerator.create {
    product = "salt",
    name = "salty-water-evaporation",
    product_amount = 5,
    energy_required = 4,
    category = "sosciencity-salt-pond",
    unlock = "fermentation"
}:add_unlock("medbay")

Tirislib.RecipeGenerator.create {
    product = "flour",
    product_amount = 5,
    ingredients = {
        {type = "item", name = "hardcorn-punk", amount = 5}
    },
    category = Tirislib.RecipeGenerator.category_alias.milling,
    energy_required = 1,
    unlock = "food-processing"
}

Tirislib.RecipeGenerator.create {
    product = "sugar",
    product_amount = 1,
    ingredients = {
        {type = "item", name = "tello-fruit", amount = 2}
    },
    byproducts = {
        {type = "item", name = "molasses", amount = 1}
    },
    category = "chemistry",
    energy_required = 1.6,
    allow_productivity = true,
    unlock = "basic-biotechnology"
}

Tirislib.RecipeGenerator.create {
    product = "sugar",
    product_amount = 3,
    ingredients = {
        {type = "item", name = "sugar-beet", amount = 2}
    },
    byproducts = {
        {type = "item", name = "molasses", amount = 1}
    },
    category = "chemistry",
    energy_required = 1.6,
    allow_productivity = true,
    unlock = Unlocks.get_tech_name("sugar-beet")
}

Tirislib.RecipeGenerator.create {
    product = "sugar",
    product_amount = 3,
    ingredients = {
        {type = "item", name = "sugar-cane", amount = 2}
    },
    byproducts = {
        {type = "item", name = "molasses", amount = 2}
    },
    category = "chemistry",
    energy_required = 1.6,
    allow_productivity = true,
    unlock = Unlocks.get_tech_name("sugar-cane")
}

Tirislib.RecipeGenerator.create {
    product = "amylum",
    product_min = 2,
    product_max = 6,
    ingredients = {
        {type = "item", name = "flour", amount = 5},
        {type = "fluid", name = "clean-water", amount = 80}
    },
    do_index_fluid_ingredients = true,
    category = "sosciencity-pharma",
    energy_required = 4,
    allow_productivity = true,
    unlock = "medbay"
}

Tirislib.RecipeGenerator.create {
    product = "agarose",
    ingredients = {
        {type = "item", name = "dried-solfaen", amount = 1},
        {type = "fluid", name = "steam", amount = 10}
    },
    category = "chemistry",
    unlock = "basic-biotechnology"
}

Tirislib.RecipeGenerator.create {
    product = "fatty-oil",
    product_type = "fluid",
    product_amount = 20,
    energy_required = 1.6,
    ingredients = {
        {type = "item", name = "weird-berry", amount = 5}
    },
    category = Tirislib.RecipeGenerator.category_alias.plant_oil_extraction,
    unlock = "explore-alien-flora-1"
}

Tirislib.RecipeGenerator.create {
    product = "fatty-oil",
    product_type = "fluid",
    product_amount = 30,
    energy_required = 1.6,
    ingredients = {
        {type = "item", name = "avocado", amount = 5}
    },
    category = Tirislib.RecipeGenerator.category_alias.plant_oil_extraction,
    unlock = Unlocks.get_tech_name("avocado")
}

Tirislib.RecipeGenerator.create {
    product = "fatty-oil",
    product_type = "fluid",
    product_amount = 30,
    energy_required = 1.6,
    ingredients = {
        {type = "item", name = "olive", amount = 5}
    },
    category = Tirislib.RecipeGenerator.category_alias.plant_oil_extraction,
    unlock = Unlocks.get_tech_name("olive")
}

Tirislib.RecipeGenerator.create {
    product = "fatty-oil",
    product_type = "fluid",
    product_amount = 30,
    energy_required = 1.6,
    ingredients = {
        {type = "item", name = "sesame", amount = 5}
    },
    category = Tirislib.RecipeGenerator.category_alias.plant_oil_extraction,
    unlock = "hummus"
}

Tirislib.RecipeGenerator.create {
    product = "solid-fat",
    energy_required = 1.6,
    themes = {
        {"hydrogen", 10}
    },
    ingredients = {
        {type = "fluid", name = "fatty-oil", amount = 10}
    },
    category = "chemistry",
    unlock = "food-processing"
}:add_catalyst(Tirislib.RecipeGenerator.item_alias.nickel_catalyst, "item", 1, 0.5)

Tirislib.RecipeGenerator.create {
    product = "proteins",
    ingredients = {
        {type = "item", name = "razha-bean", amount = 1},
        {type = "fluid", name = "ethanol", amount = 10}
    },
    unlock = "basic-biotechnology"
}

Tirislib.RecipeGenerator.create {
    product = "soy-milk",
    product_amount = 50,
    energy_required = 2,
    ingredients = {
        {type = "item", name = "razha-bean", amount = 5},
        {type = "fluid", name = "clean-water", amount = 50}
    },
    category = Tirislib.RecipeGenerator.category_alias.fluid_mixing,
    unlock = "soy-products"
}

Tirislib.RecipeGenerator.create {
    product = "ethanol",
    product_amount = 50,
    energy_required = 5,
    ingredients = {
        {type = "item", name = "blue-grapes", amount = 10},
        {type = "fluid", name = "pemtenn", amount = 10}
    },
    category = "sosciencity-fermentation-tank",
    unlock = "fermentation"
}

Tirislib.RecipeGenerator.create {
    product = "ethanol",
    product_amount = 50,
    energy_required = 5,
    ingredients = {
        {type = "item", name = "sugar", amount = 2},
        {type = "fluid", name = "pemtenn", amount = 10}
    },
    category = "sosciencity-fermentation-tank",
    unlock = "basic-biotechnology"
}

Tirislib.RecipeGenerator.create {
    product = "pemtenn-extract",
    product_amount = 10,
    energy_required = 5,
    ingredients = {
        {type = "fluid", name = "pemtenn", amount = 100}
    },
    category = Tirislib.RecipeGenerator.category_alias.drying,
    unlock = "fermentation"
}
