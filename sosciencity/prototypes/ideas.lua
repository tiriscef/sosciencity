Item:create {
    type = "item",
    name = "note",
    enabled = true,
    icon = "__sosciencity__/graphics/icon/note.png",
    icon_size = 64,
    flags = {},
    subgroup = "sosciencity-science-ingredients",
    order = "aaa",
    stack_size = 200
}

Item:create {
    type = "item",
    name = "essay",
    enabled = false,
    icon = "__sosciencity__/graphics/icon/essay.png",
    icon_size = 64,
    flags = {},
    subgroup = "sosciencity-science-ingredients",
    order = "aab",
    stack_size = 200
}

Item:create {
    type = "item",
    name = "strategic-considerations",
    enabled = false,
    icon = "__sosciencity__/graphics/icon/strategic-considerations.png",
    icon_size = 64,
    flags = {},
    subgroup = "sosciencity-science-ingredients",
    order = "aac",
    stack_size = 200
}

Item:create {
    type = "item",
    name = "data-collection",
    enabled = false,
    icon = "__sosciencity__/graphics/icon/data-collection.png",
    icon_size = 64,
    flags = {},
    subgroup = "sosciencity-science-ingredients",
    order = "aad",
    stack_size = 200
}

Item:create {
    type = "item",
    name = "complex-scientific-data",
    enabled = false,
    icon = "__sosciencity__/graphics/icon/complex-scientific-data.png",
    icon_size = 64,
    flags = {},
    subgroup = "sosciencity-science-ingredients",
    order = "aae",
    stack_size = 200
}

Item:create {
    type = "item",
    name = "published-paper",
    enabled = false,
    icon = "__sosciencity__/graphics/icon/published-paper.png",
    icon_size = 64,
    flags = {},
    subgroup = "sosciencity-science-ingredients",
    order = "aaf",
    stack_size = 200
}

Item:create {
    type = "item",
    name = "well-funded-scientific-thesis",
    enabled = false,
    icon = "__sosciencity__/graphics/icon/well-funded-scientific-thesis.png",
    icon_size = 64,
    flags = {},
    subgroup = "sosciencity-science-ingredients",
    order = "aag",
    stack_size = 200
}

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
