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

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "lumber", amount = 3, product = true},
        {type = "item", name = "sawdust", amount = 1}
    },
    ingredients = {
        {type = "item", name = "wood", amount = 1}
    },
    name = "wood",
    category = "sosciencity-wood-processing",
    allow_productivity = true
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "sawdust", amount = 4}
    },
    ingredients = {
        {type = "item", name = "lumber", amount = 1}
    },
    name = "lumber",
    category = "sosciencity-wood-processing",
    allow_productivity = true
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "marble", amount = 2}
    },
    ingredients = {
        {type = "item", name = "tools", amount = 1}
    },
    name = "tools",
    category = "sosciencity-clockwork-quarry",
    energy_required = 4,
    allow_productivity = true
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "marble", amount = 5}
    },
    ingredients = {
        {type = "item", name = "power-tools", amount = 1}
    },
    name = "power-tools",
    category = "sosciencity-clockwork-quarry",
    energy_required = 4,
    allow_productivity = true
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "tools", amount = 1}
    },
    ingredients = {
        {type = "item", name = "lumber", amount = 2},
        {type = "item", name = "iron-plate", amount = 2}
    },
    name = "lumber",
    category = "sosciencity-tinkering-workshop"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "power-tools", amount = 1}
    },
    ingredients = {
        {theme = "electronics", amount = 1},
        {theme = "battery", amount = 1},
        {type = "item", name = "steel-plate", amount = 2}
    },
    name = "steel-plate",
    category = "sosciencity-tinkering-workshop",
    default_theme_level = 3
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "screw-set", amount = 2}
    },
    ingredients = {
        {type = "item", name = "copper-plate", amount = 2}
    },
    name = "copper-plate",
    allow_productivity = true,
    unlock = "architecture-1"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "screw-set", amount = 2}
    },
    ingredients = {
        {type = "item", name = "iron-plate", amount = 2}
    },
    name = "iron-plate",
    allow_productivity = true,
    unlock = "architecture-1"
}

--[[Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "tiriscefing-willow-barrel", amount = 1}
    },
    ingredients = {
        {type = "item", name = "tiriscefing-willow-wood", amount = 2},
        {type = "item", name = "rope", amount = 1},
        {type = "item", name = "screw-set", amount = 1}
    },
    name = "tiriscefing-willow-wood",
    energy_required = 1,
    unlock = "fermentation"
}]]

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "yarn", amount = 10}
    },
    ingredients = {
        {type = "item", name = "plemnemm-cotton", amount = 20},
        {type = "item", name = "lumber", amount = 1}
    },
    name = "plemnemm-cotton",
    energy_required = 8,
    allow_productivity = true,
    unlock = "architecture-1"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "cloth", amount = 1}
    },
    ingredients = {
        {type = "item", name = "yarn", amount = 5}
    },
    name = "yarn",
    energy_required = 8,
    allow_productivity = true,
    unlock = "architecture-1"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "rope", amount = 10}
    },
    ingredients = {
        {type = "item", name = "gingil-hemp", amount = 20}
    },
    name = "gingil-hemp",
    energy_required = 8,
    allow_productivity = true,
    unlock = {"hunting-fishing", "clockwork-caste"}
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "pot", amount = 1}
    },
    ingredients = {
        {type = "item", name = "ceramic", amount = 2}
    },
    name = "ceramic",
    unlock = "indoor-growing"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "sand", amount = 1}
    },
    ingredients = {
        {type = "item", name = "stone", amount = 5}
    },
    name = "stone",
    energy_required = 4,
    unlock = "infrastructure-1"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "sand", amount = 10}
    },
    ingredients = {
    },
    category = "sosciencity-clockwork-quarry",
    energy_required = 4
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "glass-mixture", amount = 5}
    },
    ingredients = {
        {type = "item", name = "sand", amount = 5},
        {type = "item", name = "limestone", amount = 1},
        {type = "item", name = "soda", amount = 1}
    },
    name = "sand",
    energy_required = 1.6,
    unlock = "infrastructure-1"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "glass", amount = 2}
    },
    ingredients = {
        {type = "item", name = "glass-mixture", amount = 1}
    },
    name = "glass-mixture",
    category = "smelting",
    energy_required = 3.2
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "glass", amount = 1}
    },
    ingredients = {
        {type = "item", name = "sand", amount = 1}
    },
    name = "sand",
    category = "smelting",
    energy_required = 3.2,
    unlock = "infrastructure-1"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "clay-minerals", amount = 5}
    },
    ingredients = {
        {type = "fluid", name = "steam", amount = 600}
    },
    category = "sosciencity-clockwork-quarry",
    energy_required = 5
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "ceramic-mixture", amount = 2}
    },
    ingredients = {
        {type = "item", name = "clay-minerals", amount = 2},
        {type = "item", name = "limestone", amount = 1},
        {type = "fluid", name = "water", amount = 100}
    },
    name = "clay-minerals"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "ceramic", amount = 1}
    },
    ingredients = {
        {type = "item", name = "ceramic-mixture", amount = 1}
    },
    name = "ceramic-mixture",
    category = "smelting"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "mineral-mixture", amount = 2}
    },
    ingredients = {
        {theme = "glass", amount = 1},
        {theme = "gravel", amount = 1},
        {theme = "iron_ore", amount = 1}
    },
    energy_required = 1.6,
    unlock = "architecture-3"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "mineral-wool", amount = 1}
    },
    ingredients = {
        {type = "item", name = "mineral-mixture", amount = 1}
    },
    name = "mineral-mixture",
    category = "smelting",
    energy_required = 3.2,
    unlock = "architecture-3"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "architectural-concept", amount = 1}
    },
    ingredients = {
        {type = "item", name = "paper", amount = 2}
    },
    name = "paper",
    category = "sosciencity-architecture",
    energy_required = 2,
    unlock = "infrastructure-1"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "limestone", amount = 2}
    },
    category = "sosciencity-salt-pond",
    energy_required = 4
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "soda", amount = 2}
    },
    ingredients = {
        {type = "item", name = "pyrifera", amount = 5}
    },
    name = "pyrifera",
    energy_required = 5
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "ferrous-sulfate", amount = 3}
    },
    ingredients = {
        {type = "item", name = "iron-plate", amount = 1},
        {type = "fluid", name = "sulfuric-acid", amount = 10}
    },
    name = "iron-plate",
    category = "chemistry",
    energy_required = 1,
    allow_productivity = true,
    unlock = "clockwork-caste"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "filter", amount = 1}
    },
    ingredients = {
        {theme = "plating", amount = 5},
        {type = "item", name = "cloth", amount = 10},
        {type = "item", name = "glass", amount = 5}
    },
    name = "cloth",
    unlock = "activated-carbon-filtering"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "water-filter", amount = 1}
    },
    ingredients = {
        {type = "item", name = "activated-carbon", amount = 15},
        {type = "item", name = "filter", amount = 1}
    },
    name = "activated-carbon",
    unlock = "activated-carbon-filtering"
}
