---------------------------------------------------------------------------------------------------
-- << items >>

local clockwork_items = {
    {name = "invention"},
    {name = "technical-drawing", use_placeholder_icon = true},
    {name = "contraption", use_placeholder_icon = true},
    {name = "prototype-component", use_placeholder_icon = true}
}

Tirislib.Item.batch_create(
    clockwork_items,
    {subgroup = "sosciencity-clockwork-studies", stack_size = 100}
)

---------------------------------------------------------------------------------------------------
-- << recipes >>

-- Clockwork HQ

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "invention", amount = 1}
    },
    ingredients = {
        {type = "item", name = "technical-drawing", amount = 1},
        {type = "item", name = "contraption", amount = 1}
    },
    category = "sosciencity-caste-clockwork",
    energy_required = 4,
    unlock = "clockwork-caste"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "technical-drawing", amount = 1}
    },
    ingredients = {
        {type = "item", name = "paper", amount = 10},
        {type = "item", name = "dye", amount = 1}
    },
    category = "sosciencity-architecture",
    energy_required = 4,
    unlock = "clockwork-caste"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "contraption", amount = 10}
    },
    ingredients = {
        {type = "item", name = "rope", amount = 5},
        {type = "item", name = "lumber", amount = 20},
        {type = "item", name = "screw-set", amount = 20},
        {type = "item", name = "prototype-component", amount = 10}
    },
    category = "sosciencity-tinkering-workshop",
    energy_required = 4,
    unlock = "clockwork-caste"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "prototype-component", amount = 5}
    },
    ingredients = {
        {theme = "plating", amount = 5},
        {theme = "plating2", amount = 5},
        {type = "item", name = "tools", amount = 1}
    },
    category = "sosciencity-caste-clockwork",
    energy_required = 4,
    unlock = "clockwork-caste"
}
