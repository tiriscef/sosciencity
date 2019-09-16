Technology:create {
    type = "technology",
    name = "ember-caste",
    icon = "__sosciencity__/graphics/technology/ember-caste.png", -- TODO create icon
    icon_size = 128,
    upgrade = false,
    prerequisites = {"clockwork-caste", "logistic-science-pack"},
    effects = {},
    unit = {
        count = 51,
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 20
    }
}
