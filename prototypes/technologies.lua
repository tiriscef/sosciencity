---------------------------------------------------------------------------------------------------
-- << caste technologies >>
Tirislib_Technology.create {
    type = "technology",
    name = "clockwork-caste",
    icon = "__sosciencity__/graphics/clockwork-caste.png",
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
        count = 10,
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 10
    }
}

Tirislib_Technology.create {
    type = "technology",
    name = "orchid-caste",
    icon = "__sosciencity__/graphics/empty-caste.png", -- TODO create icon
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
    name = "gunfire-caste",
    icon = "__sosciencity__/graphics/gunfire-caste.png",
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
    name = "plasma-caste",
    icon = "__sosciencity__/graphics/plasma-caste.png",
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
    name = "ember-caste",
    icon = "__sosciencity__/graphics/ember-caste.png",
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
    name = "foundry-caste",
    icon = "__sosciencity__/graphics/foundry-caste.png",
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
    name = "gleam-caste",
    icon = "__sosciencity__/graphics/gleam-caste.png",
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
    name = "aurora-caste",
    icon = "__sosciencity__/graphics/empty-caste.png", -- TODO create icon
    icon_size = 256,
    upgrade = false,
    prerequisites = {"orchid-caste", "utility-science-pack", "production-science-pack"},
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

---------------------------------------------------------------------------------------------------
-- << architecture technologies >>
Tirislib_Technology.create {
    type = "technology",
    name = "architecture-1",
    icon = "__sosciencity__/graphics/technology/architecture.png",
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
    icon = "__sosciencity__/graphics/technology/architecture.png",
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
    icon = "__sosciencity__/graphics/technology/architecture.png",
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
    icon = "__sosciencity__/graphics/technology/architecture.png",
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
    icon = "__sosciencity__/graphics/technology/architecture.png",
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
    icon = "__sosciencity__/graphics/technology/architecture.png",
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
    icon = "__sosciencity__/graphics/technology/architecture.png",
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
-- << food stuff >>
Tirislib_Technology.create {
    type = "technology",
    name = "nightshades",
    icon = "__sosciencity__/graphics/technology/nightshades.png",
    icon_size = 128,
    upgrade = false,
    prerequisites = {},
    effects = {},
    unit = {
        count = 35,
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 20
    }
}

---------------------------------------------------------------------------------------------------
-- << other technologies >>
Tirislib_Technology.create {
    type = "technology",
    name = "resettlement",
    icon = "__sosciencity__/graphics/technology/placeholder.png", -- TODO create icon
    icon_size = 128,
    upgrade = false,
    prerequisites = {"gleam-caste"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.resettlement"}
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
