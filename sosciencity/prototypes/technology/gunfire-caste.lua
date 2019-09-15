TECHNOLOGY {
    type = "technology",
    name = "gunfire-caste",
    icon = "__sosciencity__/graphics/technology/gunfire-caste.png", -- TODO create icon
    icon_size = 128,
    upgrade = false,
    prerequisites = {"ember-caste", "military-science-pack"},
    effects = {},
    unit = {
        count = 77,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 20
    }
}
