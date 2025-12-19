Tirislib.Recipe.create {
    name = "education-plasma",
    category = "sosciencity-medical-school",
    enabled = true,
    energy_required = 10,
    ingredients = {
        {type = "item", name = "medical-report", amount = 10}
    },
    results = {},
    icon = "__sosciencity-graphics__/graphics/plasma-caste.png",
    icon_size = 256,
    subgroup = "sosciencity-education-recipes",
    order = "aaa",
    main_product = ""
}:add_unlock("plasma-caste"):add_icon_layer("__sosciencity-graphics__/graphics/icon/graduation.png", "topright", 0.3)

Tirislib.Recipe.create {
    name = "education-gunfire",
    category = "sosciencity-military-school",
    enabled = true,
    energy_required = 10,
    ingredients = {
        {type = "item", name = "lumber", amount = 1}
    },
    results = {},
    icon = "__sosciencity-graphics__/graphics/gunfire-caste.png",
    icon_size = 256,
    subgroup = "sosciencity-education-recipes",
    order = "aba",
    main_product = ""
}:add_unlock("gunfire-caste"):add_icon_layer("__sosciencity-graphics__/graphics/icon/graduation.png", "topright", 0.3)

Tirislib.Recipe.create {
    name = "education-foundry",
    category = "sosciencity-natural-sciences-faculty",
    enabled = true,
    energy_required = 10,
    ingredients = {
        {type = "item", name = "lumber", amount = 1}
    },
    results = {},
    icon = "__sosciencity-graphics__/graphics/foundry-caste.png",
    icon_size = 256,
    subgroup = "sosciencity-education-recipes",
    order = "aca",
    main_product = ""
}:add_unlock("foundry-caste"):add_icon_layer("__sosciencity-graphics__/graphics/icon/graduation.png", "topright", 0.3)

Tirislib.Recipe.create {
    name = "education-gleam",
    category = "sosciencity-huwanities-faculty",
    enabled = true,
    energy_required = 10,
    ingredients = {
        {type = "item", name = "lumber", amount = 1}
    },
    results = {},
    icon = "__sosciencity-graphics__/graphics/gleam-caste.png",
    icon_size = 256,
    subgroup = "sosciencity-education-recipes",
    order = "ada",
    main_product = ""
}:add_unlock("gleam-caste"):add_icon_layer("__sosciencity-graphics__/graphics/icon/graduation.png", "topright", 0.3)
