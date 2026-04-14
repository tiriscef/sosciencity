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
