---------------------------------------------------------------------------------------------------
-- << items >>

local orchid_items = {
    {name = "environmental-study", use_placeholder_icon = true},
    {name = "botanical-study", sprite_variations = {name = "botanical-study", count = 4}},
    {name = "zoological-study", use_placeholder_icon = true},
    {name = "soil-study", use_placeholder_icon = true},
    {name = "microorganism-study", use_placeholder_icon = true}
}

Tirislib.Item.batch_create(
    orchid_items,
    {subgroup = "sosciencity-orchid-studies", stack_size = 100}
)

---------------------------------------------------------------------------------------------------
-- << recipes >>

-- Handcraft

Tirislib.RecipeGenerator.create_from_prototype {
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
    subgroup = "sosciencity-ideas-per-hand",
    order = "00001",
    main_product = "",
    unlock = "orchid-caste"
}

-- Orchid Paradise

Tirislib.RecipeGenerator.create_from_prototype {
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
    unlock = "orchid-caste"
}

-- Orchid HQ

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "environmental-study", amount = 4}
    },
    category = "sosciencity-caste-orchid",
    energy_required = 2,
    ingredients = {
        {type = "item", name = "botanical-study", amount = 4}
    },
    unlock = "orchid-caste"
}
