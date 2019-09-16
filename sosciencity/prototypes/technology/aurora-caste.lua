Technology:create {
    type = "technology",
    name = "aurora-caste",
    icon = "__sosciencity__/graphics/technology/aurora-caste.png", -- TODO create icon
    icon_size = 128,
    upgrade = false,
    prerequisites = {"orchid-caste", "space-science-pack"},
    effects = {},
    unit = {
        count = 500,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
            {"utility-science-pack", 1}
        },
        time = 30
    }
}
