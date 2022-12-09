local Unlocks = require("constants.unlocks")

---------------------------------------------------------------------------------------------------
-- << caste technologies >>

Tirislib.Technology.create {
    name = "clockwork-caste",
    icon = "__sosciencity-graphics__/graphics/clockwork-caste.png",
    icon_size = 256,
    prerequisites = {"infrastructure-1"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.clockwork-caste"}
        }
    },
    unit = {
        count = 11,
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 10
    },
    ignore_tech_cost_multiplier = true
}

Tirislib.Technology.create {
    name = "clockwork-caste-efficiency",
    icons = {
        {
            icon = "__sosciencity-graphics__/graphics/clockwork-caste.png",
            icon_size = 256
        },
        {
            icon = "__sosciencity-graphics__/graphics/icon/plus.png",
            icon_size = 64,
            shift = {100, 100}
        }
    },
    upgrade = true,
    prerequisites = {"clockwork-caste"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.caste-efficiency", {"caste-short.clockwork"}}
        }
    },
    unit = {
        count_formula = "55*1.5^(L-1)",
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 60
    },
    max_level = "infinite",
    localised_name = {"technology-name.caste-efficiency", {"caste-short.clockwork"}}
}

Tirislib.Technology.create {
    name = "orchid-caste",
    icon = "__sosciencity-graphics__/graphics/orchid-caste.png",
    icon_size = 256,
    prerequisites = {"clockwork-caste", "open-environment-farming"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.orchid-caste"}
        }
    },
    unit = {
        count = 51,
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 15
    }
}

Tirislib.Technology("logistic-science-pack"):add_prerequisite("orchid-caste")

Tirislib.Technology.create {
    name = "orchid-caste-efficiency",
    icons = {
        {
            icon = "__sosciencity-graphics__/graphics/orchid-caste.png",
            icon_size = 256
        },
        {
            icon = "__sosciencity-graphics__/graphics/icon/plus.png",
            icon_size = 64,
            shift = {100, 100}
        }
    },
    upgrade = true,
    prerequisites = {"orchid-caste"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.caste-efficiency", {"caste-short.orchid"}}
        }
    },
    unit = {
        count_formula = "120*1.5^(L-1)",
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 60
    },
    max_level = "infinite",
    localised_name = {"technology-name.caste-efficiency", {"caste-short.orchid"}}
}

Tirislib.Technology.create {
    name = "gunfire-caste",
    icon = "__sosciencity-graphics__/graphics/gunfire-caste.png",
    icon_size = 256,
    prerequisites = {"orchid-caste", "logistic-science-pack"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.gunfire-caste"}
        }
    },
    unit = {
        count = 77,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 20
    }
}

Tirislib.Technology("military-science-pack"):add_prerequisite("gunfire-caste")

Tirislib.Technology.create {
    name = "gunfire-caste-efficiency",
    icons = {
        {
            icon = "__sosciencity-graphics__/graphics/gunfire-caste.png",
            icon_size = 256
        },
        {
            icon = "__sosciencity-graphics__/graphics/icon/plus.png",
            icon_size = 64,
            shift = {100, 100}
        }
    },
    upgrade = true,
    prerequisites = {"gunfire-caste"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.caste-efficiency", {"caste-short.gunfire"}}
        }
    },
    unit = {
        count_formula = "166*1.5^(L-1)",
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"military-science-pack", 1}
        },
        time = 60
    },
    max_level = "infinite",
    localised_name = {"technology-name.caste-efficiency", {"caste-short.gunfire"}}
}

Tirislib.Technology.create {
    name = "plasma-caste",
    icon = "__sosciencity-graphics__/graphics/plasma-caste.png",
    icon_size = 256,
    prerequisites = {"logistic-science-pack", "medbay"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.plasma-caste"}
        }
    },
    unit = {
        count = 278,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 20
    }
}

Tirislib.Technology.create {
    name = "plasma-caste-efficiency",
    icons = {
        {
            icon = "__sosciencity-graphics__/graphics/plasma-caste.png",
            icon_size = 256
        },
        {
            icon = "__sosciencity-graphics__/graphics/icon/plus.png",
            icon_size = 64,
            shift = {100, 100}
        }
    },
    upgrade = true,
    prerequisites = {"plasma-caste"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.caste-efficiency", {"caste-short.plasma"}}
        }
    },
    unit = {
        count_formula = "301*1.5^(L-1)",
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 60
    },
    max_level = "infinite",
    localised_name = {"technology-name.caste-efficiency", {"caste-short.plasma"}}
}

Tirislib.Technology.create {
    name = "ember-caste",
    icon = "__sosciencity-graphics__/graphics/ember-caste.png",
    icon_size = 256,
    prerequisites = {"orchid-caste", "logistic-science-pack"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.ember-caste"}
        }
    },
    unit = {
        count = 133,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 20
    }
}

Tirislib.Technology("chemical-science-pack"):add_prerequisite("ember-caste")

Tirislib.Technology.create {
    name = "ember-caste-efficiency",
    icons = {
        {
            icon = "__sosciencity-graphics__/graphics/ember-caste.png",
            icon_size = 256
        },
        {
            icon = "__sosciencity-graphics__/graphics/icon/plus.png",
            icon_size = 64,
            shift = {100, 100}
        }
    },
    upgrade = true,
    prerequisites = {"ember-caste"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.caste-efficiency", {"caste-short.ember"}}
        }
    },
    unit = {
        count_formula = "180*1.5^(L-1)",
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 60
    },
    max_level = "infinite",
    localised_name = {"technology-name.caste-efficiency", {"caste-short.ember"}}
}

Tirislib.Technology.create {
    name = "foundry-caste",
    icon = "__sosciencity-graphics__/graphics/foundry-caste.png",
    icon_size = 256,
    prerequisites = {"ember-caste", "chemical-science-pack"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.foundry-caste"}
        }
    },
    unit = {
        count = 233,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 30
    }
}

Tirislib.Technology("production-science-pack"):add_prerequisite("foundry-caste")

Tirislib.Technology.create {
    name = "foundry-caste-efficiency",
    icons = {
        {
            icon = "__sosciencity-graphics__/graphics/foundry-caste.png",
            icon_size = 256
        },
        {
            icon = "__sosciencity-graphics__/graphics/icon/plus.png",
            icon_size = 64,
            shift = {100, 100}
        }
    },
    upgrade = true,
    prerequisites = {"foundry-caste"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.caste-efficiency", {"caste-short.foundry"}}
        }
    },
    unit = {
        count_formula = "255*1.5^(L-1)",
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1}
        },
        time = 60
    },
    max_level = "infinite",
    localised_name = {"technology-name.caste-efficiency", {"caste-short.foundry"}}
}

Tirislib.Technology.create {
    name = "gleam-caste",
    icon = "__sosciencity-graphics__/graphics/gleam-caste.png",
    icon_size = 256,
    prerequisites = {"ember-caste", "chemical-science-pack"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.gleam-caste"}
        }
    },
    unit = {
        count = 233,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 30
    }
}

Tirislib.Technology("utility-science-pack"):add_prerequisite("gleam-caste")

Tirislib.Technology.create {
    name = "gleam-caste-efficiency",
    icons = {
        {
            icon = "__sosciencity-graphics__/graphics/gleam-caste.png",
            icon_size = 256
        },
        {
            icon = "__sosciencity-graphics__/graphics/icon/plus.png",
            icon_size = 64,
            shift = {100, 100}
        }
    },
    upgrade = true,
    prerequisites = {"gleam-caste"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.caste-efficiency", {"caste-short.gleam"}}
        }
    },
    unit = {
        count_formula = "366*1.5^(L-1)",
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"utility-science-pack", 1}
        },
        time = 60
    },
    max_level = "infinite",
    localised_name = {"technology-name.caste-efficiency", {"caste-short.gleam"}}
}

Tirislib.Technology.create {
    name = "aurora-caste",
    icon = "__sosciencity-graphics__/graphics/aurora-caste.png",
    icon_size = 256,
    prerequisites = {"utility-science-pack", "production-science-pack"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.aurora-caste"}
        }
    },
    unit = {
        count = 511,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
            {"utility-science-pack", 1}
        },
        time = 60
    }
}

Tirislib.Technology("space-science-pack"):add_prerequisite("aurora-caste")

Tirislib.Technology.create {
    name = "aurora-caste-efficiency",
    icons = {
        {
            icon = "__sosciencity-graphics__/graphics/aurora-caste.png",
            icon_size = 256
        },
        {
            icon = "__sosciencity-graphics__/graphics/icon/plus.png",
            icon_size = 64,
            shift = {100, 100}
        }
    },
    upgrade = true,
    prerequisites = {"aurora-caste"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.caste-efficiency", {"caste-short.aurora"}}
        }
    },
    unit = {
        count_formula = "610*1.5^(L-1)",
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
            {"utility-science-pack", 1},
            {"space-science-pack", 1}
        },
        time = 60
    },
    max_level = "infinite",
    localised_name = {"technology-name.caste-efficiency", {"caste-short.aurora"}}
}

---------------------------------------------------------------------------------------------------
-- << infrastructure technologies >>

Tirislib.Technology.create {
    name = "infrastructure-1",
    icon = "__sosciencity-graphics__/graphics/icon/infrastructure.png",
    icon_size = 128,
    upgrade = true,
    prerequisites = {},
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

---------------------------------------------------------------------------------------------------
-- << architecture technologies >>

Tirislib.Technology.create {
    name = "architecture-1",
    icon = "__sosciencity-graphics__/graphics/technology/architecture.png",
    icon_size = 128,
    upgrade = true,
    prerequisites = {"clockwork-caste"},
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

---------------------------------------------------------------------------------------------------
-- << healthcare >>

Tirislib.Technology.create {
    name = "medbay",
    icon = "__sosciencity-graphics__/graphics/technology/medbay.png",
    icon_size = 256,
    prerequisites = {"clockwork-caste"},
    unit = {
        count = 29,
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 20
    }
}

Tirislib.Technology.create {
    name = "hospital",
    icon = "__sosciencity-graphics__/graphics/technology/placeholder.png",
    icon_size = 128,
    prerequisites = {"plasma-caste"},
    unit = {
        count = 51,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 30
    }
}

--[[Tirislib.Technology.create {
    name = "transfusion-medicine",
    icon = "__sosciencity-graphics__/graphics/technology/placeholder.png",
    icon_size = 128,
    prerequisites = {"infrastructure-3", "hospital"},
    unit = {
        count = 86,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 30
    }
}]]
Tirislib.Technology.create {
    name = "psychiatry",
    icon = "__sosciencity-graphics__/graphics/technology/placeholder.png",
    icon_size = 128,
    prerequisites = {"hospital"},
    unit = {
        count = 166,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 30
    }
}

Tirislib.Technology.create {
    name = "intensive-care",
    icon = "__sosciencity-graphics__/graphics/technology/placeholder.png",
    icon_size = 128,
    prerequisites = {"infrastructure-3", "hospital"},
    unit = {
        count = 248,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 30
    }
}

---------------------------------------------------------------------------------------------------
-- << all things biology >>

Tirislib.Technology.create {
    name = "sosciencity-computing",
    icon = "__sosciencity-graphics__/graphics/technology/placeholder.png",
    icon_size = 128,
    prerequisites = {"logistic-science-pack"},
    unit = {
        count = 97,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 20
    }
}

Tirislib.Technology.create {
    name = "fermentation",
    icon = "__sosciencity-graphics__/graphics/technology/fermentation.png",
    icon_size = 256,
    prerequisite = {"clockwork-caste"},
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
    prerequisites = {"fermentation", "logistic-science-pack"},
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
    name = "advanced-fishing",
    icon = "__sosciencity-graphics__/graphics/technology/placeholder.png",
    icon_size = 128,
    prerequisites = {"chemical-science-pack"},
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
    icon = "__sosciencity-graphics__/graphics/technology/placeholder.png",
    icon_size = 128,
    prerequisites = {"sosciencity-computing", "basic-biotechnology"},
    unit = {
        count = 107,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
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
            {"logistic-science-pack", 1}
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
    icon = "__sosciencity-graphics__/graphics/technology/placeholder.png",
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
    prerequisites = {Unlocks.get_tech_name("zetorn"), "genetic-neogenesis"},
    unit = {
        count = 73,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 30
    }
}

Tirislib.Technology.create {
    name = "ortrot-variations",
    icon = "__sosciencity-graphics__/graphics/technology/ortrot-variations.png",
    icon_size = 256,
    prerequisites = {Unlocks.get_tech_name("ortrot"), "genetic-neogenesis"},
    unit = {
        count = 68,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 30
    }
}

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

---------------------------------------------------------------------------------------------------
-- << processing >>

Tirislib.Technology.create {
    name = "food-processing",
    icon = "__sosciencity-graphics__/graphics/technology/placeholder.png",
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
            {"logistic-science-pack", 1}
        },
        time = 20
    }
}

Tirislib.Technology.create {
    name = "soy-products",
    icon = "__sosciencity-graphics__/graphics/technology/soy-products.png",
    icon_size = 256,
    prerequisites = {"food-processing", Unlocks.get_tech_name("razha-bean")},
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
    name = "drinking-water-treatment",
    icon = "__sosciencity-graphics__/graphics/technology/drinking-water-treatment.png",
    icon_size = 128,
    prerequisites = {"chemical-science-pack"},
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
    name = "open-environment-farming",
    icon = "__sosciencity-graphics__/graphics/technology/open-environment-farming.png",
    icon_size = 128,
    prerequisites = {},
    unit = {
        count = 56,
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 15
    }
}

Tirislib.Technology.create {
    name = "indoor-growing",
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
            {"chemical-science-pack", 1},
            {"production-science-pack", 1}
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
