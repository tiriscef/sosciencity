---------------------------------------------------------------------------------------------------
-- << items >>

local foundry_items = {
    {name = "scientific-theory", use_placeholder_icon = true},
    {name = "complex-scientific-data"},
    {name = "experimental-data", use_placeholder_icon = true},
    {name = "computing-model", use_placeholder_icon = true},
    {name = "metallurgical-report", use_placeholder_icon = true}
}

Tirislib.Item.batch_create(
    foundry_items,
    {subgroup = "sosciencity-foundry-studies", stack_size = 50}
)

---------------------------------------------------------------------------------------------------
-- << recipes >>

-- Experimental Workshop

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "experimental-data", amount = 1}
    },
    ingredients = {
        {type = "item", name = "tools", amount = 1},
        {type = "item", name = "contraption", amount = 1}
    },
    category = "sosciencity-experimental-workshop",
    energy_required = 6,
    unlock = "foundry-caste"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "experimental-data", amount = 2}
    },
    ingredients = {
        {type = "item", name = "power-tools", amount = 1},
        {type = "item", name = "contraption", amount = 1},
        {type = "item", name = "study-design", amount = 1}
    },
    category = "sosciencity-experimental-workshop",
    energy_required = 8,
    unlock = "academic-exchange"
}

-- Tech Institute

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "computing-model", amount = 1}
    },
    ingredients = {
        {type = "item", name = "empty-hard-drive", amount = 1},
        {type = "item", name = "paper", amount = 3}
    },
    category = "sosciencity-tech-institute",
    energy_required = 8,
    unlock = "foundry-caste"
}

-- Computing Center

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "complex-scientific-data", amount = 2}
    },
    ingredients = {
        {type = "item", name = "experimental-data", amount = 2},
        {type = "item", name = "computing-model", amount = 1}
    },
    category = "sosciencity-computing-center",
    energy_required = 6,
    unlock = "foundry-caste"
}

-- Foundry HQ

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "scientific-theory", amount = 1}
    },
    ingredients = {
        {type = "item", name = "complex-scientific-data", amount = 2},
        {type = "item", name = "sketch", amount = 1}
    },
    category = "sosciencity-caste-foundry",
    energy_required = 8,
    unlock = "foundry-caste"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "scientific-theory", amount = 2}
    },
    ingredients = {
        {type = "item", name = "complex-scientific-data", amount = 2},
        {type = "item", name = "sketch", amount = 1},
        {type = "item", name = "metastudy", amount = 1}
    },
    category = "sosciencity-caste-foundry",
    energy_required = 10,
    unlock = "academic-exchange"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "metallurgical-report", amount = 1}
    },
    ingredients = {
        {type = "item", name = "precious-ore", amount = 2},
        {type = "item", name = "glass-instruments", amount = 1}
    },
    category = "sosciencity-experimental-workshop",
    energy_required = 6,
    unlock = "foundry-caste"
}
