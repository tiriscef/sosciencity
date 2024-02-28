---------------------------------------------------------------------------------------------------
-- << items >>
local idea_items = {
    {
        name = "invention",
        sprite_variations = {name = "invention", count = 4}
    },
    {
        name = "botanical-study",
        sprite_variations = {name = "botanical-study", count = 4}
    },
    {name = "strategic-considerations"},
    {name = "sketchbook"},
    {name = "complex-scientific-data"},
    {name = "published-paper"},
    {name = "well-funded-scientific-thesis"}
}

Tirislib.Item.batch_create(idea_items, {subgroup = "sosciencity-ideas", stack_size = 100})

---------------------------------------------------------------------------------------------------
-- << recipes >>

Tirislib.Recipe.create {
    type = "recipe",
    name = "brainstorm",
    category = "sosciencity-handcrafting",
    enabled = true,
    energy_required = 5,
    ingredients = {},
    results = {
        {type = "item", name = "sketchbook", amount_min = 2, amount_max = 4}
    },
    icon = "__sosciencity-graphics__/graphics/icon/sketchbook.png",
    icon_size = 64,
    subgroup = "sosciencity-ideas-per-hand",
    order = "00000",
    main_product = ""
}

Tirislib.Recipe.create {
    type = "recipe",
    name = "botanical-study-handcraft",
    category = "sosciencity-handcrafting",
    enabled = false,
    energy_required = 10,
    ingredients = {},
    results = {
        {type = "item", name = "botanical-study", amount = 1}
    },
    icon = "__sosciencity-graphics__/graphics/icon/botanical-study.png",
    icon_size = 64,
    subgroup = "sosciencity-ideas-per-hand",
    order = "00001",
    main_product = ""
}:add_unlock("orchid-caste")

Tirislib.RecipeGenerator.create {
    product = "invention",
    product_amount = 4,
    category = "sosciencity-caste-clockwork",
    energy_required = 4,
    expensive_energy_required = 6,
    ingredients = {
        {type = "item", name = "writing-paper", amount = 4},
        {type = "item", name = "ink", amount = 1},
        {type = "item", name = "lumber", amount = 20},
        {type = "item", name = "screw-set", amount = 20}
    },
    unlock = "clockwork-caste"
}

Tirislib.RecipeGenerator.create {
    product = "botanical-study",
    product_amount = 4,
    category = "sosciencity-caste-orchid",
    energy_required = 2,
    expensive_energy_required = 3,
    ingredients = {
        {type = "item", name = "writing-paper", amount = 4},
        {type = "item", name = "phytofall-blossom", amount = 1},
        {type = "item", name = "necrofall", amount = 1}
    },
    unlock = "orchid-caste"
}

Tirislib.RecipeGenerator.create {
    product = "strategic-considerations",
    product_amount = 4,
    category = "sosciencity-caste-gunfire",
    energy_required = 2,
    expensive_energy_required = 3,
    ingredients = {
        {type = "item", name = "writing-paper", amount = 4}
    },
    unlock = "gunfire-caste"
}

Tirislib.RecipeGenerator.create {
    product = "sketchbook",
    product_amount = 4,
    category = "sosciencity-caste-ember",
    energy_required = 2,
    expensive_energy_required = 3,
    ingredients = {
        {type = "item", name = "writing-paper", amount = 1}
    },
    unlock = "ember-caste"
}

Tirislib.RecipeGenerator.create {
    product = "complex-scientific-data",
    product_amount = 4,
    category = "sosciencity-caste-foundry",
    energy_required = 2,
    expensive_energy_required = 3,
    ingredients = {
        {type = "item", name = "empty-hard-drive", amount = 4}
    },
    unlock = "foundry-caste"
}

Tirislib.RecipeGenerator.create {
    product = "published-paper",
    product_amount = 4,
    category = "sosciencity-caste-gleam",
    energy_required = 2,
    expensive_energy_required = 3,
    ingredients = {
        {type = "item", name = "complex-scientific-data", amount = 2}
    },
    unlock = "gleam-caste"
}

Tirislib.RecipeGenerator.create {
    product = "well-funded-scientific-thesis",
    product_amount = 4,
    --category = "sosciencity-caste-aurora",
    energy_required = 2,
    expensive_energy_required = 3,
    ingredients = {
        {type = "item", name = "published-paper", amount = 20}
    },
    unlock = "aurora-caste"
}
