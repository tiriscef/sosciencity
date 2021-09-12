local Unlocks = require("constants.unlocks")

---------------------------------------------------------------------------------------------------
-- << items >>

local material_items = {
    {name = "lumber"},
    {
        name = "sawdust",
        sprite_variations = {name = "sawdust", count = 2, include_icon = true}
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
    {name = "rope"},
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
        sprite_variations = {name = "painting-on-belt", count = 6}
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
        name = "plant-genome",
        distinctions = {subgroup = "sosciencity-data"}
    },
    {
        name = "animal-genome",
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
        name = "amylum",
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
        name = "agarose",
        sprite_variations = {name = "agarose", count = 3, include_icon = true},
        distinctions = {subgroup = "sosciencity-biology-materials"}
    },
    {
        name = "solid-fat",
        distinctions = {subgroup = "sosciencity-biology-materials"}
    },
    {
        name = "proteins",
        sprite_variations = {name = "proteins-pile", count = 3},
        distinctions = {subgroup = "sosciencity-biology-materials"}
    },
    {
        name = "glass-instruments",
        distinctions = {subgroup = "sosciencity-laboratory-materials"}
    },
    {
        name = "nucleobases",
        --sprite_variations = {name = "nucleobases-on-belt", count = 1},
        distinctions = {subgroup = "sosciencity-laboratory-materials"}
    },
    {
        name = "phospholipids",
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
        distinctions = {subgroup = "sosciencity-laboratory-materials"}
    },
    {
        name = "thermostable-dna-polymerase",
        sprite_variations = {name = "thermostable-dna-polymerase-on-belt", count = 1},
        distinctions = {subgroup = "sosciencity-laboratory-materials"}
    },
    {
        name = "blank-dna-virus",
        distinctions = {subgroup = "sosciencity-laboratory-materials"}
    }
}

Tirislib_Item.batch_create(
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
        name = "ethanol"
    }
}

Tirislib_Fluid.batch_create(
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

Tirislib_RecipeGenerator.create {
    product = "lumber",
    product_amount = 3,
    ingredients = {
        {type = "item", name = "wood", amount = 1}
    },
    byproducts = {
        {name = "sawdust", amount = 1}
    },
    allow_productivity = true,
    unlock = "architecture-1"
}

Tirislib_RecipeGenerator.create_per_theme_level {
    product = "screw-set",
    followed_theme = "screw_material",
    energy_required = 1,
    dynamic_fields = {
        product_amount = function(n)
            return math.ceil(n / 10) * 2
        end
    },
    allow_productivity = true,
    unlock = "architecture-1"
}

Tirislib_RecipeGenerator.create {
    product = "tiriscefing-willow-barrel",
    energy_required = 1,
    ingredients = {
        {type = "item", name = "tiriscefing-willow-wood", amount = 2},
        {type = "item", name = "screw-set", amount = 1}
    },
    unlock = "fermentation"
}

Tirislib_RecipeGenerator.create {
    product = "yarn",
    product_amount = 10,
    energy_required = 8,
    ingredients = {
        {name = "plemnemm-cotton", amount = 20},
        {name = "lumber", amount = 1}
    },
    allow_productivity = true,
    unlock = "architecture-1"
}

Tirislib_RecipeGenerator.create {
    product = "cloth",
    energy_required = 8,
    ingredients = {
        {name = "yarn", amount = 5}
    },
    allow_productivity = true,
    unlock = "architecture-1"
}

Tirislib_RecipeGenerator.create {
    product = "pot",
    themes = {{"ceramic", 2, 3}};
    unlock = "open-environment-farming"
}

if Sosciencity_Config.add_glass or Sosciencity_Config.glass_compatibility_mode then
    Tirislib_RecipeGenerator.create {
        product = "glass-mixture",
        energy_required = 1.6,
        expensive_energy_required = 3.2,
        themes = {{"glass_educt", 2}},
        category = Tirislib_RecipeGenerator.category_alias[
            Sosciencity_Config.glass_compatibility_mode and "handcrafting" or "mixing"
        ],
        unlock = "architecture-1"
    }

    Tirislib_Recipe.create {
        name = "sosciencity-glass",
        energy_required = 3.2,
        ingredients = {{name = "glass-mixture", amount = 1}},
        results = {},
        category = "smelting",
        main_result = Tirislib_RecipeGenerator.item_alias.glass
    }:create_difficulties():multiply_expensive_ingredients(2):add_unlock("architecture-1"):add_result(
        {type = "item", name = Tirislib_RecipeGenerator.item_alias.glass, amount = 2}
    )
end

Tirislib_RecipeGenerator.create {
    product = "window",
    themes = {{"glass", 2}},
    ingredients = {
        {type = "item", name = "lumber", amount = 1},
        {type = "item", name = "screw-set", amount = 1}
    },
    unlock = "architecture-1"
}

Tirislib_RecipeGenerator.create {
    product = "mineral-mixture",
    energy_required = 1.6,
    themes = {
        {"glass", 1},
        {"gravel", 1},
        {"iron_ore", 1}
    },
    category = Tirislib_RecipeGenerator.category_alias.mixing,
    unlock = "architecture-4"
}

Tirislib_RecipeGenerator.create {
    product = "mineral-wool",
    energy_required = 3.2,
    ingredients = {{type = "item", name = "mineral-mixture", amount = 1}},
    category = "smelting",
    unlock = "architecture-4"
}

Tirislib_RecipeGenerator.create {
    product = "architectural-concept",
    energy_required = 4,
    ingredients = {},
    category = "sosciencity-architecture",
    unlock = "infrastructure-1"
}

Tirislib_RecipeGenerator.create {
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

Tirislib_RecipeGenerator.create {
    product = "bed",
    ingredients = {
        {type = "item", name = "lumber", amount = 5},
        {type = "item", name = "cloth", amount = 2},
        {type = "item", name = "plemnemm-cotton", amount = 5},
        {type = "item", name = "screw-set", amount = 1}
    }
}

Tirislib_RecipeGenerator.create {
    product = "carpet",
    ingredients = {
        {type = "item", name = "cloth", amount = 2},
        {type = "item", name = "yarn", amount = 1}
    }
}

Tirislib_RecipeGenerator.create {
    product = "chair",
    ingredients = {
        {type = "item", name = "lumber", amount = 2},
        {type = "item", name = "screw-set", amount = 1}
    }
}

Tirislib_RecipeGenerator.create {
    product = "cupboard",
    ingredients = {
        {type = "item", name = "lumber", amount = 5},
        {type = "item", name = "screw-set", amount = 1}
    }
}

Tirislib_RecipeGenerator.create {
    product = "curtain",
    ingredients = {
        {type = "item", name = "cloth", amount = 2},
        {type = "item", name = "yarn", amount = 1}
    }
}

Tirislib_RecipeGenerator.create {
    product = "painting",
    ingredients = {
        {type = "item", name = "lumber", amount = 1},
        {type = "item", name = "cloth", amount = 1},
        {type = "item", name = "ink", amount = 1}
    },
    category = "sosciencity-caste-ember"
}

Tirislib_RecipeGenerator.create {
    product = "refrigerator",
    themes = {
        {"electronics", 1, 2},
        {"casing", 1},
        {"cooling_fluid", 20, 50}
    },
    default_theme_level = 2,
    category = "crafting-with-fluid"
}

Tirislib_RecipeGenerator.create {
    product = "sofa",
    ingredients = {
        {type = "item", name = "lumber", amount = 5},
        {type = "item", name = "cloth", amount = 2},
        {type = "item", name = "plemnemm-cotton", amount = 10},
        {type = "item", name = "screw-set", amount = 2}
    }
}

Tirislib_RecipeGenerator.create {
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

Tirislib_RecipeGenerator.create {
    product = "table",
    ingredients = {
        {type = "item", name = "lumber", amount = 4},
        {type = "item", name = "screw-set", amount = 1}
    }
}

Tirislib_RecipeGenerator.create {
    product = "ink",
    ingredients = {
        {type = "fluid", name = "water", amount = 10},
        {type = "item", name = "ferrous-sulfate", amount = 1},
        -- TODO gallic acid
    },
    category = "chemistry",
    unlock = "ember-caste"
}

Tirislib_RecipeGenerator.create {
    product = "writing-paper",
    product_amount = 2,
    energy_required = 5,
    ingredients = {
        {name = "tiriscefing-willow-wood", amount = 5}
    },
    allow_productivity = true,
    unlock = "ember-caste"
}:add_unlock("gunfire-caste")

Tirislib_RecipeGenerator.create {
    product = "writing-paper",
    product_amount = 10,
    energy_required = 5,
    category = "chemistry",
    ingredients = {
        {name = "tiriscefing-willow-wood", amount = 5}
    },
    themes = {{"paper_production", 1}},
    allow_productivity = true,
    unlock = "ember-caste"
}:add_unlock("gunfire-caste")

Tirislib_RecipeGenerator.create {
    product = "trap",
    themes = {
        {"mechanism", 2}
    },
    energy_required = 0.8,
    allow_productivity = true,
    unlock = "clockwork-caste"
}

Tirislib_RecipeGenerator.create {
    product = "trap-cage",
    themes = {
        {"framework", 1},
        {"grating", 10}
    },
    energy_required = 0.8,
    allow_productivity = true,
    unlock = "clockwork-caste"
}

--[[Tirislib_RecipeGenerator.create {
    product = "bucket",
    themes = {
        {"handle", 1},
        {"plating", 1}
    },
    energy_required = 0.8,
    unlock = "clockwork-caste"
}]]

Tirislib_RecipeGenerator.create {
    product = "fishing-net",
    ingredients = {
        {name = "rope", amount = 5},
        {name = "yarn", amount = 1},
        {name = "lumber", amount = 2}
    },
    energy_required = 1,
    allow_productivity = true,
    unlock = "clockwork-caste"
}

Tirislib_RecipeGenerator.create {
    product = "harpoon",
    ingredients = {
        {name = "rope", amount = 1},
        {name = "yarn", amount = 1}
    },
    themes = {{"handle", 1}, {"mechanism", 2}},
    energy_required = 1,
    allow_productivity = true,
    unlock = "clockwork-caste"
}

Tirislib_RecipeGenerator.create {
    product = "ferrous-sulfate",
    product_amount = 3,
    ingredients = {
        {type = "item", name = "iron-plate", amount = 1},
        {type = "fluid", name = "sulfuric-acid", amount = 10}
    },
    category = "chemistry",
    energy_required = 1,
    allow_productivity = true,
    unlock = "drinking-water-treatment"
}

Tirislib_RecipeGenerator.create {
    product = "salt",
    product_amount = 5,
    ingredients = {
        {type = "fluid", name = "water", amount = 200}
    },
    energy_required = 4,
    category = "sosciencity-salt-pond",
    unlock = "food-processing"
}

Tirislib_RecipeGenerator.create {
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

Tirislib_RecipeGenerator.create {
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

Tirislib_RecipeGenerator.create {
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

Tirislib_RecipeGenerator.create {
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

Tirislib_RecipeGenerator.create {
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

Tirislib_RecipeGenerator.create {
    product = "plant-genome",
    ingredients = {
        {"empty-hard-drive", 1}
    },
    category = "sosciencity-computing-center",
    energy_required = 30,
    unlock = "huwan-genetic-neogenesis"
}

Tirislib_RecipeGenerator.create {
    product = "huwan-genome",
    ingredients = {
        {"empty-hard-drive", 1}
    },
    category = "sosciencity-computing-center",
    energy_required = 30,
    unlock = "huwan-genetic-neogenesis"
}

Tirislib_RecipeGenerator.create {
    product = "edited-huwan-genome",
    ingredients = {
        {"empty-hard-drive", 1}
    },
    category = "sosciencity-computing-center",
    energy_required = 30,
    unlock = "in-situ-gene-editing"
}

Tirislib_RecipeGenerator.create {
    product = "agarose",
    ingredients = {
        {type = "item", name = "dried-solfaen", amount = 1},
        {type = "fluid", name = "steam", amount = 10}
    },
    category = "chemistry",
    unlock = "biotechnology-1"
}

Tirislib_RecipeGenerator.create {
    product = "proteins",
    ingredients = {
        {type = "item", name = "razha-bean", amount = 1},
        {type = "fluid", name = "ethanol", amount = 10}
    },
    unlock = "basic-biotechnology"
}

Tirislib_RecipeGenerator.create {
    product = "soy-milk",
    product_amount = 10,
    ingredients = {
        {type = "item", name = "razha-bean", amount = 1},
        {type = "fluid", name = "clean-water", amount = 10}
    },
    category = Tirislib_RecipeGenerator.category_alias.food_processing,
    unlock = "soy-products"
}

Tirislib_RecipeGenerator.create {
    product = "ethanol",
    product_amount = 50,
    ingredients = {
        {type = "item", name = "sugar", amount = 10},
        {type = "fluid", name = "pemtenn", amount = 10}
    },
    category = "sosciencity-fermentation-tank",
    unlock = "fermentation"
}

Tirislib_RecipeGenerator.create {
    product = "glass-instruments",
    product_amount = 2,
    energy_required = 2,
    themes = {{"glass", 5, 10}, {"plastic", 2, 3}},
    default_theme_level = 2,
    unlock = "genetic-neogenesis"
}

Tirislib_RecipeGenerator.create {
    product = "semipermeable-membrane",
    themes = {{"plastic", 5, 7}, {"framework", 1}},
    default_theme_level = 2,
    category = "chemistry",
    unlock = "genetic-neogenesis"
}

Tirislib_RecipeGenerator.create {
    product = "nucleobases",
    ingredients = {

    },
    expensive_ingredients = {

    },
    unlock = "genetic-neogenesis"
}

Tirislib_RecipeGenerator.create {
    product = "phospholipids",
    unlock = "genetic-neogenesis"
}

Tirislib_RecipeGenerator.create {
    product = "chloroplasts",
    unlock = "genetic-neogenesis"
}

Tirislib_RecipeGenerator.create {
    product = "mitochondria",
    unlock = "genetic-neogenesis"
}

Tirislib_RecipeGenerator.create {
    product = "synthetase",
    unlock = "genetic-neogenesis"
}

Tirislib_RecipeGenerator.create {
    product = "thermostable-dna-polymerase",
    ingredients = {
        {type = "fluid", name = "fiicorum", amount = 10},
        {type = "item", name = "glass-instruments", amount = 1}
    },
    unlock = "genetic-neogenesis"
}

Tirislib_RecipeGenerator.create {
    product = "blank-dna-virus",
    unlock = "in-situ-gene-editing"
}
