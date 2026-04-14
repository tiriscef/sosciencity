-- TODO: Not sure if these buildings should be unlocked before or after automation

Tirislib.Technology.create {
    name = "orchid-paradise",
    icon = Tirislib.Prototype.placeholder_icon,
    icon_size = 64,
    prerequisites = {"open-environment-farming"},
    unit = {
        count = 36,
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 15
    }
}

Tirislib.Technology.create {
    name = "indoor-growing", -- rename to bloomhouse?
    icon = "__sosciencity-graphics__/graphics/technology/indoor-growing.png",
    icon_size = 128,
    prerequisites = {"open-environment-farming", "logistic-science-pack"},
    unit = {
        count = 129,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 20
    }
}
