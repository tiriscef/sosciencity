---------------------------------------------------------------------------------------------------
-- << items >>

local construction_items = {
    {name = "lumber"},
    {
        name = "sawdust",
        sprite_variations = {name = "sawdust", count = 2, include_icon = true},
        distinctions = {fuel_value = "200kJ", fuel_category = "chemical"}
    },
    {
        name = "marble",
        sprite_variations = {name = "marble", count = 7, include_icon = true}
    },
    {
        name = "sand",
        sprite_variations = {name = "sand", count = 3, include_icon = true}
    },
    {
        name = "limestone",
        sprite_variations = {name = "limestone", count = 3, include_icon = true}
    },
    {
        name = "soda",
        sprite_variations = {name = "soda", count = 3, include_icon = true}
    },
    {name = "glass"},
    {name = "glass-mixture"},
    {
        name = "clay-minerals",
        sprite_variations = {name = "clay-minerals", count = 3, include_icon = true}
    },
    {
        name = "ceramic-mixture",
        sprite_variations = {name = "ceramic-mixture", count = 3, include_icon = true}
    },
    {
        name = "ceramic",
        sprite_variations = {name = "ceramic", count = 3, include_icon = true}
    },
    {
        name = "tools",
        sprite_variations = {name = "tools", count = 5}
    },
    {
        name = "power-tools",
        use_placeholder_icon = true
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
    {name = "filter"},
    {
        name = "water-filter",
        distinctions = {
            type = "module",
            effect = {},
            limitation = {"clean-water-from-ground"},
            category = "sosciencity-water-filter",
            tier = 1,
            subgroup = "sosciencity-drinking-water",
            order = "z"
        }
    },
    {name = "ferrous-sulfate"},
    {
        name = "granite",
        use_placeholder_icon = true
    },
    {
        name = "precious-ore",
        use_placeholder_icon = true
    },
    {
        name = "rosegold-ingot",
        use_placeholder_icon = true
    },
    {
        name = "gemstone",
        use_placeholder_icon = true
    },
    {
        name = "tirinite",
        use_placeholder_icon = true
    }
}

Tirislib.Item.batch_create(
    construction_items,
    {subgroup = "sosciencity-materials", stack_size = 200}
)

---------------------------------------------------------------------------------------------------
-- << module categories >>

Tirislib.Prototype.create {
    name = "sosciencity-water-filter",
    type = "module-category"
}

---------------------------------------------------------------------------------------------------
-- << recipes >>

Tirislib.RecipeGenerator.create {
    product = "lumber",
    product_amount = 3,
    category = "sosciencity-wood-processing",
    ingredients = {
        {type = "item", name = "wood", amount = 1}
    },
    byproducts = {
        {type = "item", name = "sawdust", amount = 1}
    },
    allow_productivity = true
}

Tirislib.RecipeGenerator.create {
    product = "sawdust",
    product_amount = 4,
    category = "sosciencity-wood-processing",
    ingredients = {
        {type = "item", name = "lumber", amount = 1}
    },
    allow_productivity = true
}

Tirislib.RecipeGenerator.create {
    product = "marble",
    product_amount = 2,
    energy_required = 4,
    ingredients = {
        {type = "item", name = "tools", amount = 1}
    },
    category = "sosciencity-clockwork-quarry",
    allow_productivity = true
}

Tirislib.RecipeGenerator.create {
    product = "marble",
    product_amount = 5,
    energy_required = 4,
    ingredients = {
        {type = "item", name = "power-tools", amount = 1}
    },
    category = "sosciencity-clockwork-quarry",
    allow_productivity = true
}

Tirislib.RecipeGenerator.create {
    product = "tools",
    ingredients = {
        {type = "item", name = "lumber", amount = 2},
        {type = "item", name = "iron-plate", amount = 2}
    }
    --category = "sosciencity-clockwork-workshop"
}

Tirislib.RecipeGenerator.create {
    product = "power-tools",
    themes = {
        {"electronics", 1},
        {"battery", 1}
    },
    default_theme_level = 3,
    ingredients = {
        {type = "item", name = "steel-plate", amount = 2}
    }
    --category = "sosciencity-clockwork-workshop"
}

Tirislib.RecipeGenerator.create {
    product = "screw-set",
    product_amount = 2,
    ingredients = {
        {type = "item", name = "copper-plate", amount = 2}
    },
    allow_productivity = true,
    unlock = "architecture-1"
}

Tirislib.RecipeGenerator.create {
    product = "screw-set",
    product_amount = 2,
    ingredients = {
        {type = "item", name = "iron-plate", amount = 2}
    },
    allow_productivity = true,
    unlock = "architecture-1"
}

--[[Tirislib.RecipeGenerator.create {
    product = "tiriscefing-willow-barrel",
    energy_required = 1,
    ingredients = {
        {type = "item", name = "tiriscefing-willow-wood", amount = 2},
        {type = "item", name = "rope", amount = 1},
        {type = "item", name = "screw-set", amount = 1}
    },
    unlock = "fermentation"
}]]

Tirislib.RecipeGenerator.create {
    product = "yarn",
    product_amount = 10,
    energy_required = 8,
    ingredients = {
        {type = "item", name = "plemnemm-cotton", amount = 20},
        {type = "item", name = "lumber", amount = 1}
    },
    allow_productivity = true,
    unlock = "architecture-1"
}

Tirislib.RecipeGenerator.create {
    product = "cloth",
    energy_required = 8,
    ingredients = {
        {type = "item", name = "yarn", amount = 5}
    },
    allow_productivity = true,
    unlock = "architecture-1"
}

Tirislib.RecipeGenerator.create {
    product = "rope",
    product_amount = 10,
    energy_required = 8,
    ingredients = {
        {type = "item", name = "gingil-hemp", amount = 20}
    },
    allow_productivity = true,
    unlock = "hunting-fishing"
}:add_unlock("clockwork-caste")

Tirislib.RecipeGenerator.create {
    product = "pot",
    ingredients = {
        {type = "item", name = "ceramic", amount = 2}
    },
    unlock = "indoor-growing"
}

Tirislib.RecipeGenerator.create {
    product = "sand",
    energy_required = 4,
    ingredients = {
        {type = "item", name = "stone", amount = 5}
    },
    unlock = "infrastructure-1"
}

Tirislib.RecipeGenerator.create {
    product = "sand",
    product_amount = 10,
    energy_required = 4,
    ingredients = {},
    category = "sosciencity-clockwork-quarry"
}

Tirislib.RecipeGenerator.create {
    product = "glass-mixture",
    product_amount = 5,
    energy_required = 1.6,
    ingredients = {
        {type = "item", name = "sand", amount = 5},
        {type = "item", name = "limestone", amount = 1},
        {type = "item", name = "soda", amount = 1}
    },
    category = Tirislib.RecipeGenerator.category_alias["mixing"],
    unlock = "infrastructure-1"
}

Tirislib.RecipeGenerator.create {
    product = "glass",
    product_amount = 2,
    energy_required = 3.2,
    ingredients = {{type = "item", name = "glass-mixture", amount = 1}},
    category = "smelting"
}

Tirislib.RecipeGenerator.create {
    product = "glass",
    product_amount = 1,
    energy_required = 3.2,
    ingredients = {{type = "item", name = "sand", amount = 1}},
    category = "smelting",
    unlock = "infrastructure-1"
}

Tirislib.RecipeGenerator.create {
    product = "clay-minerals",
    product_amount = 5,
    energy_required = 5,
    ingredients = {
        {type = "fluid", name = "steam", amount = 600}
    },
    category = "sosciencity-clockwork-quarry"
}

Tirislib.RecipeGenerator.create {
    product = "ceramic-mixture",
    product_amount = 2,
    ingredients = {
        {type = "item", name = "clay-minerals", amount = 2},
        {type = "item", name = "limestone", amount = 1},
        {type = "fluid", name = "water", amount = 100}
    }
}

Tirislib.RecipeGenerator.create {
    product = "ceramic",
    ingredients = {
        {type = "item", name = "ceramic-mixture", amount = 1}
    },
    category = "smelting"
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
    energy_required = 2,
    ingredients = {
        {type = "item", name = "paper", amount = 2}
    },
    category = "sosciencity-architecture",
    unlock = "infrastructure-1"
}

Tirislib.RecipeGenerator.create {
    product = "limestone",
    product_amount = 2,
    energy_required = 4,
    category = "sosciencity-salt-pond"
}

Tirislib.RecipeGenerator.create {
    product = "soda",
    product_amount = 2,
    energy_required = 5,
    ingredients = {
        {type = "item", name = "pyrifera", amount = 5}
    },
    category = Tirislib.RecipeGenerator.category_alias.drying
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
    unlock = "clockwork-caste"
}

Tirislib.RecipeGenerator.create {
    product = "filter",
    ingredients = {
        {type = "item", name = "cloth", amount = 10},
        {type = "item", name = "glass", amount = 5}
    },
    themes = {{"plating", 5}},
    unlock = "activated-carbon-filtering"
}

Tirislib.RecipeGenerator.create {
    product = "water-filter",
    ingredients = {
        {type = "item", name = "activated-carbon", amount = 15},
        {type = "item", name = "filter", amount = 1}
    },
    unlock = "activated-carbon-filtering"
}
