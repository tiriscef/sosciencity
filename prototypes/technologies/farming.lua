---------------------------------------------------------------------------------------------------
-- << processing >>

Tirislib.Technology.create {
    name = "composting-silo",
    icon = "__sosciencity-graphics__/graphics/technology/composting-silo.png",
    icon_size = 128,
    prerequisites = {"ember-caste"},
    unit = {
        count = 56,
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 15
    },
    localised_name = {"entity-name.composting-silo"}
}

Tirislib.Technology.create {
    name = "open-environment-farming",
    icon = "__sosciencity-graphics__/graphics/technology/open-environment-farming.png",
    icon_size = 128,
    prerequisites = {"composting-silo"},
    unit = {
        count = 56,
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 15
    }
}

Tirislib.Technology.create {
    name = "mushroom-farming",
    icon = "__sosciencity-graphics__/graphics/technology/mushroom-farming.png",
    icon_size = 128,
    prerequisites = {"open-environment-farming"},
    unit = {
        count = 79,
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 15
    }
}

Tirislib.Technology.create {
    name = "algae-farming",
    icon = "__sosciencity-graphics__/graphics/technology/algae-farming.png",
    icon_size = 128,
    prerequisites = {"open-environment-farming"},
    unit = {
        count = 74,
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 15
    }
}

Tirislib.Technology.create {
    name = "controlled-environment-farming",
    icon = "__sosciencity-graphics__/graphics/technology/controlled-environment-farming.png",
    icon_size = 128,
    prerequisites = {"open-environment-farming", "chemical-science-pack"},
    unit = {
        count = 239,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 30
    }
}

Tirislib.Technology.create {
    name = "robo-plant-care",
    icon = "__sosciencity-graphics__/graphics/technology/robo-plant-care.png",
    icon_size = 128,
    prerequisites = {"robotics"},
    unit = {
        count = 154,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 30
    }
}

Tirislib.Technology.create {
    name = "animal-husbandry",
    icon = "__sosciencity-graphics__/graphics/technology/animal-husbandry.png",
    icon_size = 128,
    prerequisites = {"architecture-2"},
    unit = {
        count = 151,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 30
    }
}
