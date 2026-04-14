---------------------------------------------------------------------------------------------------
-- << architecture technologies >>

Tirislib.Technology.create {
    name = "architecture-1",
    icon = "__sosciencity-graphics__/graphics/technology/architecture.png",
    icon_size = 128,
    upgrade = true,
    prerequisites = {"ember-caste"},
    unit = {
        count = 18,
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 10
    }
}

Tirislib.Technology.create {
    name = "architecture-2",
    icon = "__sosciencity-graphics__/graphics/technology/architecture.png",
    icon_size = 128,
    upgrade = true,
    prerequisites = {"logistic-science-pack", "architecture-1"},
    unit = {
        count = 60,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 15
    }
}

Tirislib.Technology.create {
    name = "architecture-3",
    icon = "__sosciencity-graphics__/graphics/technology/architecture.png",
    icon_size = 128,
    upgrade = true,
    prerequisites = {"chemical-science-pack", "architecture-2"},
    unit = {
        count = 110,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 20
    }
}

Tirislib.Technology.create {
    name = "architecture-4",
    icon = "__sosciencity-graphics__/graphics/technology/architecture.png",
    icon_size = 128,
    upgrade = true,
    prerequisites = {"production-science-pack", "architecture-3"},
    unit = {
        count = 230,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1}
        },
        time = 25
    }
}

Tirislib.Technology.create {
    name = "architecture-5",
    icon = "__sosciencity-graphics__/graphics/technology/architecture.png",
    icon_size = 128,
    upgrade = true,
    prerequisites = {"utility-science-pack", "architecture-4"},
    unit = {
        count = 470,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"utility-science-pack", 1}
        },
        time = 30
    }
}

Tirislib.Technology.create {
    name = "architecture-6",
    icon = "__sosciencity-graphics__/graphics/technology/architecture.png",
    icon_size = 128,
    upgrade = true,
    prerequisites = {"aurora-caste", "architecture-5"},
    unit = {
        count = 1060,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
            {"utility-science-pack", 1}
        },
        time = 35
    }
}

Tirislib.Technology.create {
    name = "architecture-7",
    icon = "__sosciencity-graphics__/graphics/technology/architecture.png",
    icon_size = 128,
    upgrade = true,
    prerequisites = {"space-science-pack", "architecture-6"},
    unit = {
        count = 2350,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
            {"utility-science-pack", 1},
            {"space-science-pack", 1}
        },
        time = 40
    }
}
