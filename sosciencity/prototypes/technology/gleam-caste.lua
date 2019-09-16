Technology:create {
    type = "technology",
    name = "gleam-caste",
    icon = "__sosciencity__/graphics/technology/gleam-caste.png", -- TODO create icon
    icon_size = 128,
    upgrade = false,
    prerequisites = {"ember-caste", "chemical-science-pack"},
    effects = {},
    unit = {
        count = 66,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 20
    }
}
