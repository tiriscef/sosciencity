---------------------------------------------------------------------------------------------------
-- << items >>
local idea_items = {
    {name = "note"},
    {name = "essay"},
    {name = "strategic-considerations"},
    {name = "sketchbook"},
    {name = "complex-scientific-data"},
    {name = "published-paper"},
    {name = "well-funded-scientific-thesis"}
}

Tirislib_Item.batch_create(idea_items, {subgroup = "sosciencity-ideas", stack_size = 100})

---------------------------------------------------------------------------------------------------
-- << recipes >>
Tirislib_Recipe.create {
    type = "recipe",
    name = "brainstorm",
    category = "handcrafting",
    enabled = true,
    energy_required = 5,
    ingredients = {},
    results = {
        {type = "item", name = "note", amount_min = 2, amount_max = 4}
    },
    icon = "__sosciencity-graphics__/graphics/icon/note.png",
    icon_size = 64,
    subgroup = "sosciencity-ideas",
    order = "00000",
    main_product = ""
}

Tirislib_RecipeGenerator.create {
    product = "note",
    category = "sosciencity-caste-clockwork",
    energy_required = 10,
    expensive_energy_required = 15,
    unlock = "clockwork-caste"
}

Tirislib_RecipeGenerator.create {
    product = "note",
    product_amount = 8,
    category = "sosciencity-caste-clockwork",
    energy_required = 8,
    expensive_energy_required = 16,
    ingredients = {
        {type = "item", name = "tiriscefing-whisky", amount = 1}
    },
    unlock = "clockwork-caste"
}

Tirislib_Recipe.create {
    type = "recipe",
    name = "write-essay",
    category = "handcrafting",
    enabled = false,
    energy_required = 10,
    ingredients = {},
    results = {
        {type = "item", name = "essay", amount = 1}
    },
    icon = "__sosciencity-graphics__/graphics/icon/essay.png",
    icon_size = 64,
    subgroup = "sosciencity-ideas",
    order = "00001",
    main_product = ""
}:add_unlock("orchid-caste")

Tirislib_RecipeGenerator.create {
    product = "essay",
    product_amount = 7,
    category = "sosciencity-caste-orchid",
    energy_required = 5,
    expensive_energy_required = 10,
    ingredients = {
        {type = "item", name = "phytofall-blossom", amount = 2}
    },
    expensive_multiplier = 1.5,
    unlock = "orchid-caste"
}

Tirislib_RecipeGenerator.create {
    product = "strategic-considerations",
    product_amount = 7,
    category = "sosciencity-caste-gunfire",
    energy_required = 10,
    expensive_energy_required = 20,
    ingredients = {
    },
    unlock = "gunfire-caste"
}

Tirislib_RecipeGenerator.create {
    product = "sketchbook",
    product_amount = 7,
    category = "sosciencity-caste-ember",
    energy_required = 10,
    expensive_energy_required = 20,
    ingredients = {
    },
    unlock = "ember-caste"
}

Tirislib_RecipeGenerator.create {
    product = "complex-scientific-data",
    product_amount = 7,
    category = "sosciencity-caste-foundry",
    energy_required = 10,
    expensive_energy_required = 20,
    ingredients = {
    },
    unlock = "foundry-caste"
}

Tirislib_RecipeGenerator.create {
    product = "published-paper",
    product_amount = 7,
    category = "sosciencity-caste-gleam",
    energy_required = 10,
    expensive_energy_required = 20,
    ingredients = {
    },
    unlock = "gleam-caste"
}

Tirislib_RecipeGenerator.create {
    product = "well-funded-scientific-thesis",
    product_amount = 7,
    category = "sosciencity-caste-aurora",
    energy_required = 10,
    expensive_energy_required = 20,
    ingredients = {
    },
    unlock = "aurora-caste"
}