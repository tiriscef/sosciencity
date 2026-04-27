Tirislib.Technology.create {
    name = "clockwork-quarry",
    icon = Tirislib.Prototype.placeholder_icon,
    icon_size = 64,
    prerequisites = {"upbringing"},
    unit = {
        count = 36,
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 15
    }
}

Tirislib.Technology.create {
    name = "tinkering-workshop",
    icon = Tirislib.Prototype.placeholder_icon,
    icon_size = 64,
    prerequisites = {"clockwork-quarry"},
    unit = {
        count = 56,
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 15
    }
}

Tirislib.Technology.create {
    name = "clockwork-mines",
    icon = Tirislib.Prototype.placeholder_icon,
    icon_size = 64,
    prerequisites = {"clockwork-caste", "chemical-science-pack"},
    unit = {
        count = 179,
         ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 15
    }
}

Tirislib.Technology.create {
    name = "precious-metalworking",
    icon = Tirislib.Prototype.placeholder_icon,
    icon_size = 64,
    prerequisites = {"clockwork-mines", "foundry-caste"},
    unit = {
        count = 150,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1}
        },
        time = 30
    }
}
