---------------------------------------------------------------------------------------------------
-- << items >>

local furniture_items = {
    {
        name = "window",
        distinctions = {subgroup = "sosciencity-furniture", stack_size = 100}
    },
    {
        name = "bed",
        distinctions = {subgroup = "sosciencity-furniture", stack_size = 100}
    },
    {
        name = "furniture",
        distinctions = {subgroup = "sosciencity-furniture", stack_size = 100},
        sprite_variations = {name = "furniture", count = 4}
    },
    {
        name = "kitchen-furniture",
        distinctions = {subgroup = "sosciencity-furniture", stack_size = 100},
        use_placeholder_icon = true
    },
    {
        name = "bathroom-furniture",
        distinctions = {subgroup = "sosciencity-furniture", stack_size = 100},
        use_placeholder_icon = true
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
    }
}

Tirislib.Item.batch_create(
    furniture_items,
    {subgroup = "sosciencity-materials", stack_size = 200}
)

---------------------------------------------------------------------------------------------------
-- << recipes >>

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "window", amount = 1}
    },
    ingredients = {
        {theme = "glass", amount = 2},
        {type = "item", name = "lumber", amount = 1},
        {type = "item", name = "screw-set", amount = 1}
    }
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "bed", amount = 1}
    },
    ingredients = {
        {type = "item", name = "lumber", amount = 5},
        {type = "item", name = "cloth", amount = 2},
        {type = "item", name = "plemnemm-cotton", amount = 10},
        {type = "item", name = "screw-set", amount = 1}
    }
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "carpet", amount = 1}
    },
    ingredients = {
        {type = "item", name = "cloth", amount = 2},
        {type = "item", name = "yarn", amount = 1}
    }
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "furniture", amount = 1}
    },
    ingredients = {
        {type = "item", name = "lumber", amount = 5},
        {type = "item", name = "screw-set", amount = 1}
    }
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "kitchen-furniture", amount = 1}
    },
    ingredients = {
        {theme = "piping", amount = 2},
        {type = "item", name = "furniture", amount = 2},
        {type = "item", name = "refrigerator", amount = 1},
        {type = "item", name = "stove", amount = 1}
    }
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "bathroom-furniture", amount = 1}
    },
    ingredients = {
        {theme = "piping", amount = 2},
        {theme = "plating2", amount = 2},
        {type = "item", name = "ceramic", amount = 3}
    }
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "curtain", amount = 1}
    },
    ingredients = {
        {type = "item", name = "cloth", amount = 2},
        {type = "item", name = "yarn", amount = 1}
    }
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "sofa", amount = 1}
    },
    ingredients = {
        {type = "item", name = "lumber", amount = 5},
        {type = "item", name = "cloth", amount = 2},
        {type = "item", name = "yarn", amount = 1},
        {type = "item", name = "plemnemm-cotton", amount = 10},
        {type = "item", name = "screw-set", amount = 2}
    }
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "stove", amount = 1}
    },
    ingredients = {
        {theme = "wiring", amount = 5, level = 0},
        {theme = "casing", amount = 1},
        {type = "item", name = "screw-set", amount = 1}
    },
    default_theme_level = 2
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "refrigerator", amount = 1}
    },
    ingredients = {
        {theme = "electronics", amount = 1},
        {theme = "casing", amount = 1},
        {theme = "cooling_fluid", amount = 20}
    },
    category = "crafting-with-fluid",
    default_theme_level = 2
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "air-conditioner", amount = 1}
    },
    ingredients = {
        {theme = "electronics", amount = 1},
        {theme = "casing", amount = 1},
        {type = "item", name = "screw-set", amount = 1},
        {type = "item", name = "filter", amount = 2}
    },
    default_theme_level = 3
}
