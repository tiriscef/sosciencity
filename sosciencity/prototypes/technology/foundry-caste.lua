TECHNOLOGY {
    type = "technology",
    name = "foundry-caste",
    icon = "__sosciencity__/graphics/technology/foundry-caste.png", -- TODO create icon
    icon_size = 128,
    upgrade = false,
    prerequisites = {"gleam-caste", "production-science-pack"},
    effects = {},
    unit = {
        count = 100,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 30
    }
}
