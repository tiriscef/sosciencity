---------------------------------------------------------------------------------------------------
-- << botany >>

Tirislib.Technology.create {
    name = "explore-alien-flora-1",
    icon = "__sosciencity-graphics__/graphics/technology/explore-alien-flora-1.png",
    icon_size = 128,
    prerequisites = {"orchid-caste"},
    unit = {
        count = 23,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 20
    },
    enabled = false,
    visible_when_disabled = true
}

Tirislib.Technology.create {
    name = "explore-alien-flora-2",
    icon = "__sosciencity-graphics__/graphics/technology/explore-alien-flora-2.png",
    icon_size = 128,
    prerequisites = {"explore-alien-flora-1"},
    unit = {
        count = 121,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 20
    },
    enabled = false,
    visible_when_disabled = true
}
