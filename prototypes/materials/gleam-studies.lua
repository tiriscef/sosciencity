---------------------------------------------------------------------------------------------------
-- << items >>

local gleam_items = {
    {name = "metastudy"},
    {name = "study-design", use_placeholder_icon = true},
    {name = "survey", use_placeholder_icon = true}
}

Tirislib.Item.batch_create(
    gleam_items,
    {subgroup = "sosciencity-gleam-studies", stack_size = 50}
)

---------------------------------------------------------------------------------------------------
-- << recipes >>

-- Psychology Institute

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "study-design", amount = 1}
    },
    ingredients = {
        {type = "item", name = "paper", amount = 2},
        {type = "item", name = "novel", amount = 1},
        {type = "item", name = "technical-drawing", amount = 1}
    },
    category = "sosciencity-psychology-institute",
    energy_required = 8,
    unlock = "gleam-caste",
    auto_recycle = false
}

-- Social Observatory

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "survey", amount = 1}
    },
    ingredients = {
        {type = "item", name = "study-design", amount = 1},
        {type = "item", name = "crayons", amount = 1}
    },
    category = "sosciencity-social-observatory",
    energy_required = 12,
    unlock = "gleam-caste",
    auto_recycle = false
}

-- Gleam HQ

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "metastudy", amount = 1}
    },
    ingredients = {
        {type = "item", name = "survey", amount = 1},
        {type = "item", name = "environmental-study", amount = 1},
        {type = "item", name = "artistic-insight", amount = 1}
    },
    category = "sosciencity-caste-gleam",
    energy_required = 8,
    unlock = "gleam-caste",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "metastudy", amount = 2}
    },
    ingredients = {
        {type = "item", name = "survey", amount = 1},
        {type = "item", name = "environmental-study", amount = 1},
        {type = "item", name = "experimental-data", amount = 1},
        {type = "item", name = "artistic-insight", amount = 1}
    },
    category = "sosciencity-caste-gleam",
    energy_required = 12,
    unlock = "academic-exchange",
    auto_recycle = false
}
