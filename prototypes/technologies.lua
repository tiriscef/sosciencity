
require("constants.unlocks")

---------------------------------------------------------------------------------------------------
-- << caste technologies >>

Tirislib_Technology.create {
    type = "technology",
    name = "clockwork-caste",
    icon = "__sosciencity-graphics__/graphics/clockwork-caste.png",
    icon_size = 256,
    upgrade = false,
    prerequisites = {},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.clockwork-caste"}
        }
    },
    unit = {
        count = 9,
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 10
    }
}

Tirislib_Technology.create {
    type = "technology",
    name = "clockwork-caste-effectivity",
    icon = "__sosciencity-graphics__/graphics/clockwork-caste.png",
    icon_size = 256,
    upgrade = true,
    prerequisites = {"clockwork-caste"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.caste-effectivity", {"caste-short.clockwork"}}
        }
    },
    unit = {
        count_formula = "120*1.5^(L-1)",
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 60
    },
    max_level = "infinite",
    localised_name = {"technology-name.caste-effectivity", {"caste-short.clockwork"}}
}

Tirislib_Technology.create {
    type = "technology",
    name = "orchid-caste",
    icon = "__sosciencity-graphics__/graphics/orchid-caste.png",
    icon_size = 256,
    upgrade = false,
    prerequisites = {"clockwork-caste"},
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

Tirislib_Technology("logistic-science-pack"):add_prerequisite("orchid-caste")

Tirislib_Technology.create {
    type = "technology",
    name = "orchid-caste-effectivity",
    icon = "__sosciencity-graphics__/graphics/orchid-caste.png",
    icon_size = 256,
    upgrade = true,
    prerequisites = {"orchid-caste"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.caste-effectivity", {"caste-short.orchid"}}
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
    localised_name = {"technology-name.caste-effectivity", {"caste-short.orchid"}}
}

Tirislib_Technology.create {
    type = "technology",
    name = "gunfire-caste",
    icon = "__sosciencity-graphics__/graphics/gunfire-caste.png",
    icon_size = 256,
    upgrade = false,
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

Tirislib_Technology("military-science-pack"):add_prerequisite("gunfire-caste")

Tirislib_Technology.create {
    type = "technology",
    name = "gunfire-caste-effectivity",
    icon = "__sosciencity-graphics__/graphics/gunfire-caste.png",
    icon_size = 256,
    upgrade = true,
    prerequisites = {"gunfire-caste"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.caste-effectivity", {"caste-short.gunfire"}}
        }
    },
    unit = {
        count_formula = "120*1.5^(L-1)",
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"military-science-pack", 1}
        },
        time = 60
    },
    max_level = "infinite",
    localised_name = {"technology-name.caste-effectivity", {"caste-short.gunfire"}}
}

Tirislib_Technology.create {
    type = "technology",
    name = "plasma-caste",
    icon = "__sosciencity-graphics__/graphics/plasma-caste.png",
    icon_size = 256,
    upgrade = false,
    prerequisites = {"logistic-science-pack"},
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

Tirislib_Technology.create {
    type = "technology",
    name = "plasma-caste-effectivity",
    icon = "__sosciencity-graphics__/graphics/plasma-caste.png",
    icon_size = 256,
    upgrade = true,
    prerequisites = {"plasma-caste"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.caste-effectivity", {"caste-short.plasma"}}
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
    localised_name = {"technology-name.caste-effectivity", {"caste-short.plasma"}}
}

Tirislib_Technology.create {
    type = "technology",
    name = "ember-caste",
    icon = "__sosciencity-graphics__/graphics/ember-caste.png",
    icon_size = 256,
    upgrade = false,
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

Tirislib_Technology("chemical-science-pack"):add_prerequisite("ember-caste")

Tirislib_Technology.create {
    type = "technology",
    name = "ember-caste-effectivity",
    icon = "__sosciencity-graphics__/graphics/ember-caste.png",
    icon_size = 256,
    upgrade = true,
    prerequisites = {"ember-caste"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.caste-effectivity", {"caste-short.ember"}}
        }
    },
    unit = {
        count_formula = "120*1.5^(L-1)",
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 60
    },
    max_level = "infinite",
    localised_name = {"technology-name.caste-effectivity", {"caste-short.ember"}}
}

Tirislib_Technology.create {
    type = "technology",
    name = "foundry-caste",
    icon = "__sosciencity-graphics__/graphics/foundry-caste.png",
    icon_size = 256,
    upgrade = false,
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

Tirislib_Technology("production-science-pack"):add_prerequisite("foundry-caste")

Tirislib_Technology.create {
    type = "technology",
    name = "foundry-caste-effectivity",
    icon = "__sosciencity-graphics__/graphics/foundry-caste.png",
    icon_size = 256,
    upgrade = true,
    prerequisites = {"foundry-caste"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.caste-effectivity", {"caste-short.foundry"}}
        }
    },
    unit = {
        count_formula = "120*1.5^(L-1)",
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1}
        },
        time = 60
    },
    max_level = "infinite",
    localised_name = {"technology-name.caste-effectivity", {"caste-short.foundry"}}
}

Tirislib_Technology.create {
    type = "technology",
    name = "gleam-caste",
    icon = "__sosciencity-graphics__/graphics/gleam-caste.png",
    icon_size = 256,
    upgrade = false,
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

Tirislib_Technology("utility-science-pack"):add_prerequisite("gleam-caste")

Tirislib_Technology.create {
    type = "technology",
    name = "gleam-caste-effectivity",
    icon = "__sosciencity-graphics__/graphics/gleam-caste.png",
    icon_size = 256,
    upgrade = true,
    prerequisites = {"gleam-caste"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.caste-effectivity", {"caste-short.gleam"}}
        }
    },
    unit = {
        count_formula = "120*1.5^(L-1)",
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"utility-science-pack", 1}
        },
        time = 60
    },
    max_level = "infinite",
    localised_name = {"technology-name.caste-effectivity", {"caste-short.gleam"}}
}

Tirislib_Technology.create {
    type = "technology",
    name = "aurora-caste",
    icon = "__sosciencity-graphics__/graphics/aurora-caste.png",
    icon_size = 256,
    upgrade = false,
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

Tirislib_Technology("space-science-pack"):add_prerequisite("aurora-caste")

Tirislib_Technology.create {
    type = "technology",
    name = "aurora-caste-effectivity",
    icon = "__sosciencity-graphics__/graphics/aurora-caste.png",
    icon_size = 256,
    upgrade = true,
    prerequisites = {"aurora-caste"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.caste-effectivity", {"caste-short.aurora"}}
        }
    },
    unit = {
        count_formula = "120*1.5^(L-1)",
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
    localised_name = {"technology-name.caste-effectivity", {"caste-short.aurora"}}
}

---------------------------------------------------------------------------------------------------
-- << architecture technologies >>

Tirislib_Technology.create {
    type = "technology",
    name = "architecture-1",
    icon = "__sosciencity-graphics__/graphics/technology/architecture.png",
    icon_size = 128,
    upgrade = true,
    prerequisites = {"clockwork-caste"},
    effects = {},
    unit = {
        count = 30,
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 10
    }
}

Tirislib_Technology.create {
    type = "technology",
    name = "architecture-2",
    icon = "__sosciencity-graphics__/graphics/technology/architecture.png",
    icon_size = 128,
    upgrade = true,
    prerequisites = {"logistic-science-pack", "architecture-1"},
    effects = {},
    unit = {
        count = 60,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 15
    }
}

Tirislib_Technology.create {
    type = "technology",
    name = "architecture-3",
    icon = "__sosciencity-graphics__/graphics/technology/architecture.png",
    icon_size = 128,
    upgrade = true,
    prerequisites = {"chemical-science-pack", "architecture-2"},
    effects = {},
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

Tirislib_Technology.create {
    type = "technology",
    name = "architecture-4",
    icon = "__sosciencity-graphics__/graphics/technology/architecture.png",
    icon_size = 128,
    upgrade = true,
    prerequisites = {"production-science-pack", "architecture-3"},
    effects = {},
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

Tirislib_Technology.create {
    type = "technology",
    name = "architecture-5",
    icon = "__sosciencity-graphics__/graphics/technology/architecture.png",
    icon_size = 128,
    upgrade = true,
    prerequisites = {"utility-science-pack", "architecture-4"},
    effects = {},
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

Tirislib_Technology.create {
    type = "technology",
    name = "architecture-6",
    icon = "__sosciencity-graphics__/graphics/technology/architecture.png",
    icon_size = 128,
    upgrade = true,
    prerequisites = {"aurora-caste", "architecture-5"},
    effects = {},
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

Tirislib_Technology.create {
    type = "technology",
    name = "architecture-7",
    icon = "__sosciencity-graphics__/graphics/technology/architecture.png",
    icon_size = 128,
    upgrade = true,
    prerequisites = {"space-science-pack", "architecture-6"},
    effects = {},
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

Tirislib_Technology.create {
    type = "technology",
    name = "hospital",
    icon = "__sosciencity-graphics__/graphics/technology/placeholder.png",
    icon_size = 128,
    prerequisites = {"plasma-caste"},
    effects = {},
    unit = {
        count = 166,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 30
    }
}

Tirislib_Technology.create {
    type = "technology",
    name = "transfusion-medicine",
    icon = "__sosciencity-graphics__/graphics/technology/placeholder.png",
    icon_size = 128,
    prerequisites = {"hospital"},
    effects = {},
    unit = {
        count = 166,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 30
    }
}

Tirislib_Technology.create {
    type = "technology",
    name = "psychiatry",
    icon = "__sosciencity-graphics__/graphics/technology/placeholder.png",
    icon_size = 128,
    prerequisites = {"hospital"},
    effects = {},
    unit = {
        count = 166,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 30
    }
}

Tirislib_Technology.create {
    type = "technology",
    name = "intensive-care",
    icon = "__sosciencity-graphics__/graphics/technology/placeholder.png",
    icon_size = 128,
    prerequisites = {"hospital", "architecture-3"},
    effects = {},
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
-- << gene technologies >>

Tirislib_Technology.create {
    type = "technology",
    name = "genetic-neogenesis",
    icon = "__sosciencity-graphics__/graphics/technology/placeholder.png",
    icon_size = 128,
    upgrade = false,
    prerequisites = {"orchid-caste", "plasma-caste"},
    effects = {},
    unit = {
        count = 107,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 20
    }
}

Tirislib_Technology.create {
    type = "technology",
    name = "nightshades",
    icon = "__sosciencity-graphics__/graphics/technology/nightshades.png",
    icon_size = 128,
    upgrade = false,
    prerequisites = {"genetic-neogenesis"},
    effects = {},
    unit = {
        count = 35,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 20
    }
}

Tirislib_Technology.create {
    type = "technology",
    name = "huwan-genetic-neogenesis",
    icon = "__sosciencity-graphics__/graphics/technology/placeholder.png",
    icon_size = 128,
    upgrade = false,
    prerequisites = {"genetic-neogenesis", "plasma-caste", "chemical-science-pack"},
    effects = {},
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

Tirislib_Technology.create {
    type = "technology",
    name = "zetorn-variations",
    icon = "__sosciencity-graphics__/graphics/technology/placeholder.png",
    icon_size = 128,
    upgrade = false,
    prerequisites = {Unlocks.get_tech_name("zetorn"), "genetic-neogenesis"},
    effects = {},
    unit = {
        count = 73,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 30
    }
}

Tirislib_Technology.create {
    type = "technology",
    name = "ortrot-variations",
    icon = "__sosciencity-graphics__/graphics/technology/placeholder.png",
    icon_size = 128,
    upgrade = false,
    prerequisites = {Unlocks.get_tech_name("ortrot"), "genetic-neogenesis"},
    effects = {},
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
-- << processing >>

Tirislib_Technology.create {
    type = "technology",
    name = "hummus",
    icon = "__sosciencity-graphics__/graphics/technology/placeholder.png",
    icon_size = 128,
    upgrade = false,
    prerequisites = {"orchid-caste"},
    effects = {},
    unit = {
        count = 233,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 15
    }
}

Tirislib_Technology.create {
    type = "technology",
    name = "drinking-water-treatment",
    icon = "__sosciencity-graphics__/graphics/technology/drinking-water-treatment.png",
    icon_size = 128,
    prerequisites = {"logistic-science-pack"},
    effects = {},
    unit = {
        count = 139,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 30
    }
}

Tirislib_Technology.create {
    type = "technology",
    name = "open-environment-farming",
    icon = "__sosciencity-graphics__/graphics/technology/open-environment-farming.png",
    icon_size = 128,
    prerequisites = {},
    effects = {},
    unit = {
        count = 11,
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 10
    }
}

Tirislib_Technology.create {
    type = "technology",
    name = "indoor-growing",
    icon = "__sosciencity-graphics__/graphics/technology/indoor-growing.png",
    icon_size = 128,
    prerequisites = {"open-environment-farming", "logistic-science-pack"},
    effects = {},
    unit = {
        count = 56,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 20
    }
}

Tirislib_Technology.create {
    type = "technology",
    name = "controlled-environment-farming",
    icon = "__sosciencity-graphics__/graphics/technology/controlled-environment-farming.png",
    icon_size = 128,
    prerequisites = {"indoor-growing", "chemical-science-pack"},
    effects = {},
    unit = {
        count = 139,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 30
    }
}

Tirislib_Technology.create {
    type = "technology",
    name = "animal-husbandry",
    icon = "__sosciencity-graphics__/graphics/technology/animal-husbandry.png",
    icon_size = 128,
    prerequisites = {"architecture-3"},
    effects = {},
    unit = {
        count = 151,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 30
    }
}
