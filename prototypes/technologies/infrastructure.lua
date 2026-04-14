---------------------------------------------------------------------------------------------------
-- << infrastructure technologies >>

Tirislib.Technology.create {
    name = "infrastructure-1",
    icon = "__sosciencity-graphics__/graphics/icon/infrastructure.png",
    icon_size = 128,
    upgrade = true,
    prerequisites = {"automation-science-pack"},
    unit = {
        count = 9,
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 10
    },
    ignore_tech_cost_multiplier = true
}

Tirislib.Technology.create {
    name = "upbringing",
    icon = "__sosciencity-graphics__/graphics/technology/upbringing.png",
    icon_size = 128,
    upgrade = true,
    prerequisites = {"infrastructure-1"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.clockwork-caste"}
        },
        {
            type = "nothing",
            effect_description = {"description.orchid-caste"}
        },
        {
            type = "nothing",
            effect_description = {"description.ember-caste"}
        }
    },
    unit = {
        count = 13,
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 10
    },
    ignore_tech_cost_multiplier = true
}

Tirislib.Technology.create {
    name = "infrastructure-2",
    icon = "__sosciencity-graphics__/graphics/icon/infrastructure.png",
    icon_size = 128,
    upgrade = true,
    prerequisites = {"logistic-science-pack", "infrastructure-1"},
    unit = {
        count = 58,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 20
    }
}

Tirislib.Technology.create {
    name = "infrastructure-3",
    icon = "__sosciencity-graphics__/graphics/icon/infrastructure.png",
    icon_size = 128,
    upgrade = true,
    prerequisites = {"chemical-science-pack", "infrastructure-2"},
    unit = {
        count = 189,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 30
    }
}

Tirislib.Technology.create {
    name = "infrastructure-4",
    icon = "__sosciencity-graphics__/graphics/icon/infrastructure.png",
    icon_size = 128,
    upgrade = true,
    prerequisites = {"production-science-pack", "infrastructure-3"},
    unit = {
        count = 364,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1}
        },
        time = 60
    }
}
