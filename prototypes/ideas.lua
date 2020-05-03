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
    energy_required = 10,
    ingredients = {},
    results = {
        {type = "item", name = "note", amount_min = 2, amount_max = 4}
    },
    icon = "__sosciencity-graphics__/graphics/icon/note.png",
    icon_size = 64,
    subgroup = "sosciencity-ideas",
    order = "aaa",
    main_product = ""
}

Tirislib_Recipe.create {
    type = "recipe",
    name = "write-essay",
    category = "handcrafting",
    enabled = false,
    energy_required = 90,
    ingredients = {},
    results = {
        {type = "item", name = "essay", amount = 1}
    },
    icon = "__sosciencity-graphics__/graphics/icon/essay.png",
    icon_size = 64,
    subgroup = "sosciencity-ideas",
    order = "aab",
    main_product = ""
}:add_unlock("ember-caste")
