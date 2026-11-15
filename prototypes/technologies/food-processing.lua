---------------------------------------------------------------------------------------------------
-- << food processing >>

Tirislib.Technology.create {
    name = "food-processing",
    icon = "__sosciencity-graphics__/graphics/technology/food-processing.png",
    icon_size = 128,
    prerequisites = {"orchid-caste", "logistic-science-pack"},
    unit = {
        count = 132,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 20
    }
}

Tirislib.Technology.create {
    name = "hummus",
    icon = "__sosciencity-graphics__/graphics/technology/hummus.png",
    icon_size = 256,
    prerequisites = {"food-processing", "genetic-neogenesis"},
    unit = {
        count = 233,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 20
    }
}

Tirislib.Technology.create {
    name = "soy-products",
    icon = "__sosciencity-graphics__/graphics/technology/soy-products.png",
    icon_size = 256,
    prerequisites = {"food-processing"},
    unit = {
        count = 188,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 20
    }
}

Tirislib.Technology.create {
    name = "smoking",
    icon = Tirislib.Prototype.placeholder_icon,
    icon_size = 64,
    prerequisites = {"kitchen-for-all", "salt-pond"},
    unit = {
        count = 27,
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 15
    }
}

Tirislib.Technology.create {
    name = "smokehouse",
    icon = Tirislib.Prototype.placeholder_icon,
    icon_size = 64,
    -- gated by population
    enabled = false,
    prerequisites = {"smoking", "orchid-caste", "clockwork-caste", "chemical-science-pack"},
    unit = {
        count = 157,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 30
    }
}
