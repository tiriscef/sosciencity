Recipe:create {
    type = "recipe",
    name = "brainstorm",
    category = "handcrafting",
    enabled = true,
    energy_required = 10,
    ingredients = {},
    results = {
        {type = "item", name = "note", amount_min = 2, amount_max = 4}
    },
    icon = "__sosciencity__/graphics/icon/note.png",
    icon_size = 64,
    subgroup = "sosciencity-science-ingredients",
    order = "aaa", 
    main_product = ""
}

Recipe:create {
    type = "recipe",
    name = "write-essay",
    category = "handcrafting",
    enabled = false,
    energy_required = 90,
    ingredients = {},
    results = {
        {type = "item", name = "essay", amount = 1}
    },
    icon = "__sosciencity__/graphics/icon/essay.png",
    icon_size = 64,
    subgroup = "sosciencity-science-ingredients",
    order = "aab",
    main_product = ""
}:add_unlock("ember-caste")
