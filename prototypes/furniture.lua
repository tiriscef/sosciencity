---------------------------------------------------------------------------------------------------
-- << items >>
local furniture_items = {
    {name = "bed"},
    {name = "chair"},
    {name = "table"},
    {name = "cupboard", sprite_variations = {name = "cupboard", count = 1, include_icon = true}},
    {name = "carpet"},
    {name = "sofa"},
    {name = "curtain", sprite_variations = {name = "curtain-on-belt", count = 4}},
    {name = "air-conditioner"},
    {name = "stove"},
    {name = "refrigerator"},
    {name = "painting", sprite_variations = {name = "painting-on-belt", count = 6}}
}

Tirislib_Item.batch_create(furniture_items, {subgroup = "sosciencity-furniture", stack_size = 100})

---------------------------------------------------------------------------------------------------
-- << recipes >>
Tirislib_RecipeGenerator.create {
    product = "air-conditioner",
    themes = {
        {"electronics", 1, 2},
        {"casing", 1, 2}
    },
    allow_productivity = true
}

Tirislib_RecipeGenerator.create {
    product = "bed",
    ingredients = {
        {type = "item", name = "lumber", amount = 5},
        {type = "item", name = "cloth", amount = 2},
        {type = "item", name = "plemnemm-cotton", amount = 10},
        {type = "item", name = "screw-set", amount = 1}
    },
    allow_productivity = true
}

Tirislib_RecipeGenerator.create {
    product = "carpet",
    ingredients = {
        {type = "item", name = "cloth", amount = 2},
        {type = "item", name = "yarn", amount = 1}
    },
    allow_productivity = true
}

Tirislib_RecipeGenerator.create {
    product = "chair",
    ingredients = {
        {type = "item", name = "lumber", amount = 2},
        {type = "item", name = "screw-set", amount = 1}
    },
    allow_productivity = true
}

Tirislib_RecipeGenerator.create {
    product = "cupboard",
    ingredients = {
        {type = "item", name = "lumber", amount = 5},
        {type = "item", name = "screw-set", amount = 1}
    },
    allow_productivity = true
}

Tirislib_RecipeGenerator.create {
    product = "curtain",
    ingredients = {
        {type = "item", name = "cloth", amount = 2},
        {type = "item", name = "yarn", amount = 1}
    },
    allow_productivity = true
}

Tirislib_RecipeGenerator.create {
    product = "painting",
    ingredients = {
        {type = "item", name = "lumber", amount = 1},
        {type = "item", name = "cloth", amount = 1}
    },
    category = "sosciencity-caste-ember",
    allow_productivity = true
}

Tirislib_RecipeGenerator.create {
    product = "refrigerator",
    themes = {
        {"electronics", 1, 2},
        {"casing", 1, 2},
        {"cooling_fluid", 20, 0}
    },
    category = "crafting-with-fluid",
    allow_productivity = true
}

Tirislib_RecipeGenerator.create {
    product = "sofa",
    ingredients = {
        {type = "item", name = "lumber", amount = 5},
        {type = "item", name = "cloth", amount = 2},
        {type = "item", name = "plemnemm-cotton", amount = 10},
        {type = "item", name = "screw-set", amount = 2}
    },
    allow_productivity = true
}

Tirislib_RecipeGenerator.create {
    product = "stove",
    themes = {
        {"wiring", 5, 0},
        {"casing", 1, 2}
    },
    allow_productivity = true
}

Tirislib_RecipeGenerator.create {
    product = "table",
    ingredients = {
        {type = "item", name = "lumber", amount = 4},
        {type = "item", name = "screw-set", amount = 1}
    },
    allow_productivity = true
}
