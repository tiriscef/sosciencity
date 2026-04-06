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

Tirislib.RecipeGenerator.create {
    product = "window",
    themes = {{"glass", 2}},
    ingredients = {
        {type = "item", name = "lumber", amount = 1},
        {type = "item", name = "screw-set", amount = 1}
    }
}

Tirislib.RecipeGenerator.create {
    product = "bed",
    ingredients = {
        {type = "item", name = "lumber", amount = 5},
        {type = "item", name = "cloth", amount = 2},
        {type = "item", name = "plemnemm-cotton", amount = 10},
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
    product = "furniture",
    ingredients = {
        {type = "item", name = "lumber", amount = 5},
        {type = "item", name = "screw-set", amount = 1}
    }
}

Tirislib.RecipeGenerator.create {
    product = "kitchen-furniture",
    themes = {{"piping", 2}},
    ingredients = {
        {type = "item", name = "furniture", amount = 2},
        {type = "item", name = "refrigerator", amount = 1},
        {type = "item", name = "stove", amount = 1}
    }
}

Tirislib.RecipeGenerator.create {
    product = "bathroom-furniture",
    themes = {{"piping", 2}, {"plating2", 2}},
    ingredients = {
        {type = "item", name = "ceramic", amount = 3}
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
    product = "sofa",
    ingredients = {
        {type = "item", name = "lumber", amount = 5},
        {type = "item", name = "cloth", amount = 2},
        {type = "item", name = "yarn", amount = 1},
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
        {"wiring", 5, 0},
        {"casing", 1}
    },
    default_theme_level = 2
}

Tirislib.RecipeGenerator.create {
    product = "refrigerator",
    themes = {
        {"electronics", 1},
        {"casing", 1},
        {"cooling_fluid", 20}
    },
    default_theme_level = 2,
    category = "crafting-with-fluid"
}

Tirislib.RecipeGenerator.create {
    product = "air-conditioner",
    ingredients = {
        {type = "item", name = "screw-set", amount = 1},
        {type = "item", name = "filter", amount = 2}
    },
    themes = {
        {"electronics", 1},
        {"casing", 1}
    },
    default_theme_level = 3
}
