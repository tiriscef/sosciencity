local Unlocks = require("constants.unlocks")

---------------------------------------------------------------------------------------------------
-- << items >>

local material_items = {
    {name = "lumber"},
    {
        name = "sawdust",
        sprite_variations = {name = "sawdust", count = 2, include_icon = true},
        distinctions = {fuel_value = "200kJ", fuel_category = "chemical"}
    },
    {
        name = "screw-set",
        sprite_variations = {name = "screw-set", count = 2, include_icon = true}
    },
    {name = "tiriscefing-willow-barrel"},
    {
        name = "cloth",
        sprite_variations = {name = "cloth", count = 3, include_icon = true}
    },
    {
        name = "yarn",
        sprite_variations = {name = "yarn-pile", count = 4}
    },
    {name = "rope"},
    {name = "pot"},
    {name = "glass-mixture"},
    {name = "glass"},
    {name = "mineral-mixture"},
    {name = "mineral-wool"},
    {
        name = "architectural-concept",
        distinctions = {
            icon = "__sosciencity-graphics__/graphics/icon/blueprint-1.png",
            icon_size = 64,
            pictures = Sosciencity_Config.blueprint_on_belt
        }
    },
    {
        name = "window",
        distinctions = {subgroup = "sosciencity-furniture", stack_size = 100}
    },
    {
        name = "bed",
        distinctions = {subgroup = "sosciencity-furniture", stack_size = 100}
    },
    {
        name = "chair",
        distinctions = {subgroup = "sosciencity-furniture", stack_size = 100}
    },
    {
        name = "table",
        distinctions = {subgroup = "sosciencity-furniture", stack_size = 100}
    },
    {
        name = "cupboard",
        distinctions = {subgroup = "sosciencity-furniture", stack_size = 100},
        sprite_variations = {name = "cupboard", count = 1, include_icon = true}
    },
    {
        name = "carpet",
        distinctions = {subgroup = "sosciencity-furniture", stack_size = 100}
    },
    {
        name = "sofa",
        distinctions = {subgroup = "sosciencity-furniture", stack_size = 100}
    },
    {
        name = "curtain",
        distinctions = {subgroup = "sosciencity-furniture", stack_size = 100},
        sprite_variations = {name = "curtain-on-belt", count = 4}
    },
    {
        name = "air-conditioner",
        distinctions = {subgroup = "sosciencity-furniture", stack_size = 100}
    },
    {
        name = "stove",
        distinctions = {subgroup = "sosciencity-furniture", stack_size = 100}
    },
    {
        name = "refrigerator",
        distinctions = {subgroup = "sosciencity-furniture", stack_size = 100}
    },
    {
        name = "painting",
        distinctions = {subgroup = "sosciencity-furniture", stack_size = 100},
        sprite_variations = {name = "painting-on-belt", count = 7}
    },
    {
        name = "feathers",
        sprite_variations = {name = "feather-pile", count = 4}
    },
    {name = "ink"},
    {
        name = "writing-paper",
        sprite_variations = {name = "writing-paper-pile", count = 4}
    },
    {name = "semipermeable-membrane"},
    {
        name = "trap",
        distinctions = {subgroup = "sosciencity-gathering"}
    },
    {
        name = "trap-cage",
        distinctions = {subgroup = "sosciencity-gathering"}
    },
    {
        name = "bucket",
        distinctions = {subgroup = "sosciencity-gathering"}
    },
    {
        name = "simple-fishtrap",
        distinctions = {subgroup = "sosciencity-gathering"}
    },
    {
        name = "fishing-net",
        distinctions = {subgroup = "sosciencity-gathering"}
    },
    {
        name = "harpoon",
        distinctions = {subgroup = "sosciencity-gathering"}
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
    {name = "ferrous-sulfate"},
    {
        name = "salt",
        sprite_variations = {name = "salt", count = 3, include_icon = true},
        distinctions = {subgroup = "sosciencity-biology-materials"}
    },
    {
        name = "empty-hard-drive",
        distinctions = {subgroup = "sosciencity-data"}
    },
    {
        name = "virus-genome",
        distinctions = {subgroup = "sosciencity-data"}
    },
    {
        name = "plant-genome",
        distinctions = {subgroup = "sosciencity-data"}
    },
    {
        name = "huwan-genome",
        distinctions = {subgroup = "sosciencity-data"}
    },
    {
        name = "edited-huwan-genome",
        distinctions = {subgroup = "sosciencity-data"}
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
        name = "glass-instruments",
        sprite_variations = {name = "glass-instruments-on-belt", count = 3},
        distinctions = {subgroup = "sosciencity-laboratory-materials"}
    },
    {
        name = "nucleobases",
        sprite_variations = {name = "nucleobases-on-belt", count = 3},
        distinctions = {subgroup = "sosciencity-laboratory-materials"}
    },
    {
        name = "phospholipids",
        sprite_variations = {name = "phospholipids-on-belt", count = 3},
        distinctions = {subgroup = "sosciencity-laboratory-materials"}
    },
    {
        name = "chloroplasts",
        sprite_variations = {name = "chloroplasts-on-belt", count = 1},
        distinctions = {subgroup = "sosciencity-laboratory-materials"}
    },
    {
        name = "mitochondria",
        sprite_variations = {name = "mitochondria-on-belt", count = 1},
        distinctions = {subgroup = "sosciencity-laboratory-materials"}
    },
    {
        name = "synthetase",
        sprite_variations = {name = "synthetase-on-belt", count = 1},
        distinctions = {subgroup = "sosciencity-laboratory-materials"}
    },
    {
        name = "thermostable-dna-polymerase",
        sprite_variations = {name = "thermostable-dna-polymerase-on-belt", count = 1},
        distinctions = {subgroup = "sosciencity-laboratory-materials"}
    },
    {
        name = "blank-dna-virus",
        sprite_variations = {name = "blank-dna-virus-on-belt", count = 1},
        distinctions = {subgroup = "sosciencity-laboratory-materials"}
    },
    {
        name = "pemtenn-extract",
        distinctions = {subgroup = "sosciencity-microorganism-products"}
    }
}

Tirislib.Item.batch_create(
    material_items,
    {prefix = Sosciencity_Config.prefix, subgroup = "sosciencity-materials", stack_size = 200}
)

---------------------------------------------------------------------------------------------------
-- << fluids >>

local fluids = {
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
    fluids,
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
    product = "lumber",
    product_amount = 3,
    ingredients = {
        {type = "item", name = "wood", amount = 1}
    },
    byproducts = {
        {type = "item", name = "sawdust", amount = 1}
    },
    allow_productivity = true,
    unlock = "infrastructure-1"
}

Tirislib.RecipeGenerator.create_per_theme_level {
    product = "screw-set",
    followed_theme = "screw_material",
    dynamic_fields = {
        product_amount = function(n)
            return math.ceil(n / 10) * 2
        end
    },
    allow_productivity = true,
    unlock = "infrastructure-1"
}

Tirislib.RecipeGenerator.create {
    product = "tiriscefing-willow-barrel",
    energy_required = 1,
    ingredients = {
        {type = "item", name = "tiriscefing-willow-wood", amount = 2},
        {type = "item", name = "rope", amount = 1},
        {type = "item", name = "screw-set", amount = 1}
    },
    unlock = "fermentation"
}

Tirislib.RecipeGenerator.create {
    product = "yarn",
    product_amount = 10,
    energy_required = 8,
    ingredients = {
        {type = "item", name = "plemnemm-cotton", amount = 20},
        {type = "item", name = "lumber", amount = 1}
    },
    allow_productivity = true,
    unlock = "infrastructure-1"
}

Tirislib.RecipeGenerator.create {
    product = "cloth",
    energy_required = 8,
    ingredients = {
        {type = "item", name = "yarn", amount = 5}
    },
    allow_productivity = true,
    unlock = "infrastructure-1"
}

Tirislib.RecipeGenerator.create {
    product = "rope",
    product_amount = 10,
    energy_required = 8,
    ingredients = {
        {type = "item", name = "gingil-hemp", amount = 20},
        {type = "item", name = "lumber", amount = 1}
    },
    allow_productivity = true,
    unlock = "infrastructure-1"
}

Tirislib.RecipeGenerator.create {
    product = "pot",
    themes = {{"ceramic", 2, 3}},
    unlock = "open-environment-farming"
}

if Sosciencity_Config.add_glass or Sosciencity_Config.glass_compatibility_mode then
    Tirislib.RecipeGenerator.create {
        product = "glass-mixture",
        energy_required = 1.6,
        expensive_energy_required = 3.2,
        themes = {{"glass_educt", 2}},
        category = Tirislib.RecipeGenerator.category_alias[
            Sosciencity_Config.glass_compatibility_mode and "handcrafting" or "mixing"
        ],
        unlock = "infrastructure-1"
    }

    Tirislib.Recipe.create {
        name = "sosciencity-glass",
        energy_required = 3.2,
        ingredients = {{name = "glass-mixture", amount = 1}},
        results = {},
        category = "smelting",
        main_result = Tirislib.RecipeGenerator.item_alias.glass
    }:create_difficulties():multiply_expensive_ingredients(2):add_unlock("infrastructure-1"):add_result(
        {type = "item", name = Tirislib.RecipeGenerator.item_alias.glass, amount = 2}
    )
end

Tirislib.RecipeGenerator.create {
    product = "window",
    themes = {{"glass", 2}},
    ingredients = {
        {type = "item", name = "lumber", amount = 1},
        {type = "item", name = "screw-set", amount = 1}
    },
    unlock = "infrastructure-1"
}

Tirislib.RecipeGenerator.create {
    product = "mineral-mixture",
    product_amount = 2,
    energy_required = 1.6,
    themes = {
        {"glass", 1},
        {"gravel", 1},
        {"iron_ore", 1}
    },
    category = Tirislib.RecipeGenerator.category_alias.mixing,
    unlock = "architecture-3"
}

Tirislib.RecipeGenerator.create {
    product = "mineral-wool",
    energy_required = 3.2,
    ingredients = {{type = "item", name = "mineral-mixture", amount = 1}},
    category = "smelting",
    unlock = "architecture-3"
}

Tirislib.RecipeGenerator.create {
    product = "architectural-concept",
    energy_required = 4,
    ingredients = {},
    category = "sosciencity-architecture",
    unlock = "infrastructure-1"
}

Tirislib.RecipeGenerator.create {
    product = "air-conditioner",
    ingredients = {
        {type = "item", name = "screw-set", amount = 1}
    },
    themes = {
        {"electronics", 1},
        {"casing", 1}
    },
    default_theme_level = 3
}

Tirislib.RecipeGenerator.create {
    product = "bed",
    ingredients = {
        {type = "item", name = "lumber", amount = 5},
        {type = "item", name = "cloth", amount = 2},
        {type = "item", name = "plemnemm-cotton", amount = 5},
        {type = "item", name = "screw-set", amount = 1}
    }
}

Tirislib.RecipeGenerator.create {
    product = "carpet",
    ingredients = {
        {type = "item", name = "cloth", amount = 2},
        {type = "item", name = "yarn", amount = 1}
    }
}

Tirislib.RecipeGenerator.create {
    product = "chair",
    ingredients = {
        {type = "item", name = "lumber", amount = 2},
        {type = "item", name = "screw-set", amount = 1}
    }
}

Tirislib.RecipeGenerator.create {
    product = "cupboard",
    ingredients = {
        {type = "item", name = "lumber", amount = 5},
        {type = "item", name = "screw-set", amount = 1}
    }
}

Tirislib.RecipeGenerator.create {
    product = "curtain",
    ingredients = {
        {type = "item", name = "cloth", amount = 2},
        {type = "item", name = "yarn", amount = 1}
    }
}

Tirislib.RecipeGenerator.create {
    product = "painting",
    ingredients = {
        {type = "item", name = "lumber", amount = 1},
        {type = "item", name = "cloth", amount = 1},
        {type = "item", name = "ink", amount = 1}
    },
    category = "sosciencity-caste-ember"
}

Tirislib.RecipeGenerator.create {
    product = "refrigerator",
    themes = {
        {"electronics", 1, 2},
        {"casing", 1},
        {"cooling_fluid", 20, 50}
    },
    default_theme_level = 2,
    category = "crafting-with-fluid"
}

Tirislib.RecipeGenerator.create {
    product = "sofa",
    ingredients = {
        {type = "item", name = "lumber", amount = 5},
        {type = "item", name = "cloth", amount = 2},
        {type = "item", name = "plemnemm-cotton", amount = 10},
        {type = "item", name = "screw-set", amount = 2}
    }
}

Tirislib.RecipeGenerator.create {
    product = "stove",
    ingredients = {
        {type = "item", name = "screw-set", amount = 1}
    },
    themes = {
        {"wiring", 5, 10, 0},
        {"casing", 1}
    },
    default_theme_level = 3
}

Tirislib.RecipeGenerator.create {
    product = "table",
    ingredients = {
        {type = "item", name = "lumber", amount = 4},
        {type = "item", name = "screw-set", amount = 1}
    }
}

Tirislib.RecipeGenerator.create {
    product = "ink",
    ingredients = {
        {type = "fluid", name = "water", amount = 10},
        {type = "item", name = "ferrous-sulfate", amount = 1},
        {type = "item", name = "necrofall", amount = 2}
    },
    category = "chemistry",
    unlock = "ember-caste"
}

Tirislib.RecipeGenerator.create {
    product = "writing-paper",
    product_amount = 2,
    energy_required = 5,
    ingredients = {
        {name = "tiriscefing-willow-wood", amount = 5}
    },
    allow_productivity = true,
    unlock = "ember-caste"
}:add_unlock("gunfire-caste")

Tirislib.RecipeGenerator.create {
    product = "writing-paper",
    product_amount = 10,
    energy_required = 5,
    category = "chemistry",
    ingredients = {
        {name = "sawdust", amount = 5}
    },
    themes = {{"paper_production", 1}},
    allow_productivity = true,
    unlock = "ember-caste"
}:add_unlock("gunfire-caste")

Tirislib.RecipeGenerator.create {
    product = "trap",
    themes = {
        {"mechanism", 2}
    },
    energy_required = 0.8,
    allow_productivity = true,
    unlock = "clockwork-caste"
}

Tirislib.RecipeGenerator.create {
    product = "trap-cage",
    themes = {
        {"plating", 2},
        {"grating", 10}
    },
    energy_required = 0.8,
    allow_productivity = true,
    unlock = "clockwork-caste"
}

--[[Tirislib.RecipeGenerator.create {
    product = "bucket",
    themes = {
        {"handle", 1},
        {"plating", 1}
    },
    energy_required = 0.8,
    unlock = "clockwork-caste"
}]]

Tirislib.RecipeGenerator.create {
    product = "simple-fishtrap",
    ingredients = {
        {name = "gingil-hemp", amount = 2}
    },
    energy_required = 1.5,
    allow_productivity = true,
    unlock = "clockwork-caste"
}

Tirislib.RecipeGenerator.create {
    product = "fishing-net",
    ingredients = {
        {name = "rope", amount = 5},
        {name = "yarn", amount = 1},
        {name = "lumber", amount = 2}
    },
    energy_required = 1,
    allow_productivity = true,
    unlock = "advanced-fishing"
}

Tirislib.RecipeGenerator.create {
    product = "harpoon",
    ingredients = {
        {name = "rope", amount = 1},
        {name = "yarn", amount = 1}
    },
    themes = {{"handle", 1}, {"mechanism", 2}},
    energy_required = 1,
    allow_productivity = true,
    unlock = "advanced-fishing"
}

Tirislib.RecipeGenerator.create {
    product = "ferrous-sulfate",
    product_amount = 3,
    ingredients = {
        {type = "item", name = "iron-plate", amount = 1},
        {type = "fluid", name = "sulfuric-acid", amount = 10}
    },
    category = "chemistry",
    energy_required = 1,
    allow_productivity = true,
    unlock = "ember-caste"
}

Tirislib.RecipeGenerator.create {
    product = "salt",
    product_amount = 5,
    ingredients = {
        {type = "fluid", name = "water", amount = 200}
    },
    energy_required = 4,
    category = "sosciencity-salt-pond",
    unlock = "food-processing"
}

Tirislib.RecipeGenerator.create {
    product = "amylum",
    product_min = 2,
    product_max = 6,
    ingredients = {
        {type = "item", name = "manok", amount = 5},
        {type = "fluid", name = "clean-water", amount = 80}
    },
    category = "crafting-with-fluid",
    energy_required = 4,
    allow_productivity = true,
    unlock = "hospital"
}

Tirislib.RecipeGenerator.create {
    product = "flour",
    product_amount = 5,
    ingredients = {
        {type = "item", name = "hardcorn-punk", amount = 5}
    },
    category = Tirislib.RecipeGenerator.category_alias.milling,
    energy_required = 1,
    unlock = Unlocks.get_tech_name("hardcorn-punk")
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
    unlock = "food-processing"
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
    product = "empty-hard-drive",
    themes = {
        {"electronics", 20},
        {"casing", 1},
        {"wiring", 10}
    },
    energy_required = 5,
    default_theme_level = 3,
    unlock = "sosciencity-computing"
}

Tirislib.RecipeGenerator.create {
    product = "virus-genome",
    ingredients = {
        {"empty-hard-drive", 1}
    },
    category = "sosciencity-computing-center",
    energy_required = 10,
    unlock = "huwan-genetic-neogenesis"
}

Tirislib.RecipeGenerator.create {
    product = "plant-genome",
    ingredients = {
        {"empty-hard-drive", 1}
    },
    category = "sosciencity-computing-center",
    energy_required = 30,
    unlock = "huwan-genetic-neogenesis"
}

Tirislib.RecipeGenerator.create {
    product = "huwan-genome",
    ingredients = {
        {"empty-hard-drive", 1}
    },
    category = "sosciencity-computing-center",
    energy_required = 30,
    unlock = "huwan-genetic-neogenesis"
}

Tirislib.RecipeGenerator.create {
    product = "edited-huwan-genome",
    ingredients = {
        {"empty-hard-drive", 1}
    },
    category = "sosciencity-computing-center",
    energy_required = 30,
    unlock = "in-situ-gene-editing"
}

Tirislib.RecipeGenerator.create {
    product = "agarose",
    ingredients = {
        {type = "item", name = "dried-solfaen", amount = 1},
        {type = "fluid", name = "steam", amount = 10}
    },
    category = "chemistry",
    unlock = "biotechnology-1"
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
    unlock = Unlocks.get_tech_name("weird-berry")
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
    product = "solid-fat",
    energy_required = 1.6,
    expensive_energy_required = 2.4,
    themes = {
        {"hydrogen", 10}
    },
    ingredients = {
        {type = "fluid", name = "fatty-oil", amount = 10}
    },
    category = "chemistry",
    unlock = "food-processing"
}:add_catalyst(Tirislib.RecipeGenerator.item_alias.nickel_catalyst, "item", 1, 0.99, 1, 0.98)

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
    product_amount = 10,
    ingredients = {
        {type = "item", name = "razha-bean", amount = 1},
        {type = "fluid", name = "clean-water", amount = 10}
    },
    category = Tirislib.RecipeGenerator.category_alias.food_processing,
    unlock = "soy-products"
}

Tirislib.RecipeGenerator.create {
    product = "glass-instruments",
    product_min = 1,
    product_max = 5,
    energy_required = 2,
    themes = {{"glass", 5, 10}, {"plastic", 2, 3}},
    default_theme_level = 2,
    unlock = "genetic-neogenesis"
}

Tirislib.RecipeGenerator.create {
    product = "semipermeable-membrane",
    themes = {{"plastic", 5, 7}, {"framework", 1}},
    default_theme_level = 2,
    category = "chemistry",
    unlock = "genetic-neogenesis"
}

Tirislib.RecipeGenerator.create {
    product = "nucleobases",
    energy_required = 3.2,
    ingredients = {
        {type = "item", name = "pemtenn-extract", amount = 2},
        {type = "item", name = "glass-instruments", amount = 1},
        {type = "fluid", name = "ethanol", amount = 15}
    },
    expensive_ingredients = {
        {type = "item", name = "pemtenn-extract", amount = 3},
        {type = "item", name = "glass-instruments", amount = 2},
        {type = "fluid", name = "ethanol", amount = 20}
    },
    category = "chemistry",
    unlock = "genetic-neogenesis"
}

Tirislib.RecipeGenerator.create {
    product = "phospholipids",
    energy_required = 3.2,
    theme = {{"phosphorous_source", 1}},
    ingredients = {
        {type = "item", name = "solid-fat", amount = 1},
        {type = "item", name = "glass-instruments", amount = 1},
        {type = "fluid", name = "flinnum", amount = 10}
    },
    category = "sosciencity-bioreactor",
    unlock = "genetic-neogenesis"
}

Tirislib.RecipeGenerator.create {
    product = "chloroplasts",
    energy_required = 3.2,
    ingredients = {
        {type = "item", name = "glass-instruments", amount = 1},
        {type = "fluid", name = "mynellia", amount = 25}
    },
    category = "chemistry",
    unlock = "genetic-neogenesis"
}

Tirislib.RecipeGenerator.create {
    product = "mitochondria",
    energy_required = 3.2,
    ingredients = {
        {type = "item", name = "glass-instruments", amount = 1},
        {type = "fluid", name = "pemtenn", amount = 25}
    },
    category = "chemistry",
    unlock = "genetic-neogenesis"
}

Tirislib.RecipeGenerator.create {
    product = "synthetase",
    energy_required = 3.2,
    ingredients = {
        {type = "item", name = "glass-instruments", amount = 1},
        {type = "fluid", name = "pemtenn", amount = 10},
        {type = "fluid", name = "ethanol", amount = 10}
    },
    category = "chemistry",
    unlock = "genetic-neogenesis"
}

Tirislib.RecipeGenerator.create {
    product = "thermostable-dna-polymerase",
    ingredients = {
        {type = "fluid", name = "fiicorum", amount = 10},
        {type = "item", name = "glass-instruments", amount = 1}
    },
    category = "chemistry",
    unlock = "genetic-neogenesis"
}

Tirislib.RecipeGenerator.create {
    product = "blank-dna-virus",
    ingredients = {
        {type = "item", name = "proteins", amount = 1},
        {type = "item", name = "nucleobases", amount = 1},
        {type = "item", name = "synthetase", amount = 1},
        {type = "item", name = "glass-instruments", amount = 1},
        {type = "item", name = "virus-genome", amount = 1}
    },
    byproducts = {
        {type = "item", name = "empty-hard-drive", amount = 1, probability = 0.95}
    },
    category = "sosciencity-reproductive-gene-lab",
    unlock = "in-situ-gene-editing"
}

Tirislib.RecipeGenerator.create {
    product = "pemtenn-extract",
    ingredients = {
        {type = "fluid", name = "pemtenn", amount = 10}
    },
    category = Tirislib.RecipeGenerator.category_alias.drying,
    unlock = "fermentation"
}

Tirislib.RecipeGenerator.create {
    product = "ethanol",
    product_amount = 50,
    ingredients = {
        {type = "item", name = "sugar", amount = 2},
        {type = "fluid", name = "pemtenn", amount = 10}
    },
    category = "sosciencity-fermentation-tank",
    unlock = "fermentation"
}
