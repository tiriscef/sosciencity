---------------------------------------------------------------------------------------------------
-- << items >>

local orchid_items = {
    {name = "environmental-study", use_placeholder_icon = true},
    {name = "botanical-study", sprite_variations = {name = "botanical-study", count = 4}},
    {name = "zoological-study", use_placeholder_icon = true},
    {name = "soil-study", use_placeholder_icon = true},
    {name = "microorganism-study", use_placeholder_icon = true},
    {name = "anatomical-study", use_placeholder_icon = true}
}

Tirislib.Item.batch_create(
    orchid_items,
    {subgroup = "sosciencity-orchid-studies", stack_size = 100}
)

---------------------------------------------------------------------------------------------------
-- << recipes >>

-- Handcraft

Tirislib.RecipeGenerator.create {
    name = "botanical-study-handcraft",
    category = "sosciencity-handcrafting",
    enabled = false,
    energy_required = 5,
    ingredients = {
        {type = "item", name = "paper", amount = 1},
        {type = "item", name = "phytofall-blossom", amount = 1}
    },
    results = {
        {type = "item", name = "botanical-study", amount = 1}
    },
    icon = "__sosciencity-graphics__/graphics/icon/botanical-study.png",
    icon_size = 64,
    subgroup = "sosciencity-ideas-by-hand",
    order = "00001",
    main_product = "",
    unlock = "orchid-caste",
    auto_recycle = false
}

-- Orchid Paradise

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "botanical-study", amount = 4}
    },
    category = "sosciencity-orchid-paradise",
    energy_required = 2,
    ingredients = {
        {type = "item", name = "paper", amount = 4},
        {type = "item", name = "phytofall-blossom", amount = 1},
        {type = "item", name = "necrofall", amount = 1}
    },
    unlock = "orchid-caste",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "soil-study", amount = 1}
    },
    category = "sosciencity-orchid-paradise",
    energy_required = 4,
    ingredients = {
        {type = "item", name = "paper", amount = 2},
        {type = "item", name = "humus", amount = 2}
    },
    unlock = "orchid-caste",
    auto_recycle = false
}

-- Hunting/Gathering Hut

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "zoological-study", amount = 1}
    },
    category = "sosciencity-hunting",
    energy_required = 6,
    ingredients = {
        {type = "item", name = "paper", amount = 2},
        {type = "item", name = "wild-algae", amount = 1}
    },
    unlock = "orchid-caste",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "anatomical-study", amount = 1}
    },
    category = "sosciencity-orchid-paradise",
    energy_required = 8,
    ingredients = {
        {type = "item", name = "paper", amount = 2}
    },
    unlock = "orchid-caste",
    auto_recycle = false
}

-- TODO: move to bioreactor once that building exists
Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "microorganism-study", amount = 1}
    },
    category = "sosciencity-orchid-paradise",
    energy_required = 8,
    ingredients = {
        {type = "item", name = "paper", amount = 2},
        {type = "item", name = "wild-algae", amount = 1} -- TODO
    },
    unlock = "orchid-caste",
    auto_recycle = false
}

-- Orchid HQ

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "environmental-study", amount = 1}
    },
    category = "sosciencity-caste-orchid",
    energy_required = 8,
    ingredients = {
        {type = "item", name = "botanical-study", amount = 2},
        {type = "item", name = "zoological-study", amount = 1}
    },
    unlock = "orchid-caste",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "environmental-study", amount = 2}
    },
    category = "sosciencity-caste-orchid",
    energy_required = 10,
    ingredients = {
        {type = "item", name = "botanical-study", amount = 2},
        {type = "item", name = "zoological-study", amount = 1},
        {type = "item", name = "soil-study", amount = 1}
    },
    unlock = "indoor-growing",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "environmental-study", amount = 3}
    },
    category = "sosciencity-caste-orchid",
    energy_required = 14,
    ingredients = {
        {type = "item", name = "botanical-study", amount = 1},
        {type = "item", name = "soil-study", amount = 1},
        {type = "item", name = "zoological-study", amount = 1},
        {type = "item", name = "microorganism-study", amount = 1}
    },
    unlock = "academic-exchange",
    auto_recycle = false
}
