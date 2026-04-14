---------------------------------------------------------------------------------------------------
-- << all things biology >>

Tirislib.Technology.create {
    name = "sosciencity-computing",
    icon = "__sosciencity-graphics__/graphics/technology/computing.png",
    icon_size = 256,
    prerequisites = {"chemical-science-pack"},
    unit = {
        count = 97,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 20
    }
}

Tirislib.Technology.create {
    name = "fermentation",
    icon = "__sosciencity-graphics__/graphics/technology/fermentation.png",
    icon_size = 256,
    prerequisites = {"open-environment-farming"},
    unit = {
        count = 32,
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 30
    }
}

Tirislib.Technology.create {
    name = "basic-biotechnology",
    icon = "__sosciencity-graphics__/graphics/technology/basic-biotechnology.png",
    icon_size = 256,
    prerequisites = {"fermentation", "logistic-science-pack", "algae-farming"},
    unit = {
        count = 48,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 30
    }
}

Tirislib.Technology.create {
    name = "hunting-fishing",
    icon = "__sosciencity-graphics__/graphics/technology/hunting-fishing.png",
    icon_size = 128,
    prerequisites = {"ember-caste"},
    unit = {
        count = 67,
        ingredients = {
            {"automation-science-pack", 1},
        },
        time = 15
    }
}

Tirislib.Technology.create {
    name = "advanced-fishing",
    icon = "__sosciencity-graphics__/graphics/technology/advanced-fishing.png",
    icon_size = 128,
    prerequisites = {"chemical-science-pack", "hunting-fishing"},
    unit = {
        count = 87,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 30
    }
}

Tirislib.Technology.create {
    name = "genetic-neogenesis",
    icon = "__sosciencity-graphics__/graphics/technology/genetic-neogenesis.png",
    icon_size = 128,
    prerequisites = {"sosciencity-computing", "basic-biotechnology"},
    unit = {
        count = 167,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 20
    }
}

Tirislib.Technology.create {
    name = "nightshades",
    icon = "__sosciencity-graphics__/graphics/technology/nightshades.png",
    icon_size = 128,
    prerequisites = {"genetic-neogenesis"},
    unit = {
        count = 35,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 20
    }
}

Tirislib.Technology.create {
    name = "huwan-genetic-neogenesis",
    icon = "__sosciencity-graphics__/graphics/technology/huwan-genetic-neogenesis.png",
    icon_size = 256,
    prerequisites = {"genetic-neogenesis", "plasma-caste", "chemical-science-pack"},
    unit = {
        count = 267,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 30
    }
}

Tirislib.Technology.create {
    name = "in-situ-gene-editing",
    icon = "__sosciencity-graphics__/graphics/technology/in-situ-gene-editing.png",
    icon_size = 128,
    prerequisites = {"huwan-genetic-neogenesis", "foundry-caste"},
    unit = {
        count = 355,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1}
        },
        time = 60
    }
}

Tirislib.Technology.create {
    name = "improved-reproductive-healthcare",
    icon = "__sosciencity-graphics__/graphics/technology/placeholder.png",
    icon_size = 128,
    prerequisites = {"in-situ-gene-editing"},
    effects = {
        {
            type = "nothing",
            effect_description = {"sosciencity.reduced-birth-defect-rate"}
        }
    },
    unit = {
        count_formula = "486*1.5^(L-1)",
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1}
        },
        time = 60
    },
    max_level = 3
}

Tirislib.Technology.create {
    name = "zetorn-variations",
    icon = "__sosciencity-graphics__/graphics/technology/zetorn-variations.png",
    icon_size = 256,
    prerequisites = {"explore-alien-flora-1", "genetic-neogenesis"},
    unit = {
        count = 73,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 30
    }
}

Tirislib.Technology.create {
    name = "ortrot-variations",
    icon = "__sosciencity-graphics__/graphics/technology/ortrot-variations.png",
    icon_size = 256,
    prerequisites = {"explore-alien-flora-2", "genetic-neogenesis"},
    unit = {
        count = 68,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 30
    }
}
