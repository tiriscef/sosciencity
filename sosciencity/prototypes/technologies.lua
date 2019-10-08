---------------------------------------------------------------------------------------------------
-- << caste technologies >>
Technology:create {
    type = "technology",
    name = "clockwork-caste",
    icon = "__sosciencity__/graphics/technology/clockwork-caste.png",
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
        ingredients = {{"automation-science-pack", 1}},
        time = 10
    }
}

Technology:create {
    type = "technology",
    name = "ember-caste",
    icon = "__sosciencity__/graphics/technology/ember-caste.png", -- TODO create icon
    icon_size = 128,
    upgrade = false,
    prerequisites = {"clockwork-caste", "logistic-science-pack"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.ember-caste"}
        }
    },
    unit = {
        count = 51,
        ingredients = {{"automation-science-pack", 1}},
        time = 20
    }
}

Technology:create {
    type = "technology",
    name = "gunfire-caste",
    icon = "__sosciencity__/graphics/technology/gunfire-caste.png", -- TODO create icon
    icon_size = 128,
    upgrade = false,
    prerequisites = {"ember-caste", "military-science-pack"},
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

Technology:create {
    type = "technology",
    name = "gleam-caste",
    icon = "__sosciencity__/graphics/technology/gleam-caste.png", -- TODO create icon
    icon_size = 128,
    upgrade = false,
    prerequisites = {"ember-caste", "chemical-science-pack"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.gleam-caste"}
        }
    },
    unit = {
        count = 66,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 20
    }
}

Technology:create {
    type = "technology",
    name = "foundry-caste",
    icon = "__sosciencity__/graphics/technology/foundry-caste.png", -- TODO create icon
    icon_size = 128,
    upgrade = false,
    prerequisites = {"gleam-caste", "production-science-pack"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.foundry-caste"}
        }
    },
    unit = {
        count = 133,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 30
    }
}

Technology:create {
    type = "technology",
    name = "orchid-caste",
    icon = "__sosciencity__/graphics/technology/orchid-caste.png", -- TODO create icon
    icon_size = 128,
    upgrade = false,
    prerequisites = {"gleam-caste", "utility-science-pack"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.orchid-caste"}
        }
    },
    unit = {
        count = 133,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 30
    }
}

Technology:create {
    type = "technology",
    name = "aurora-caste",
    icon = "__sosciencity__/graphics/technology/aurora-caste.png", -- TODO create icon
    icon_size = 128,
    upgrade = false,
    prerequisites = {"orchid-caste", "space-science-pack"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.aurora-caste"}
        }
    },
    unit = {
        count = 500,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
            {"utility-science-pack", 1}
        },
        time = 30
    }
}

---------------------------------------------------------------------------------------------------
-- << architecture technologies >>
Technology:create {
    type = "technology",
    name = "architecture-1",
    icon = "__sosciencity__/graphics/technology/architecture.png",
    icon_size = 256,
    upgrade = true,
    prerequisites = {"clockwork-caste"},
    effects = {},
    unit = {
        count = 30,
        ingredients = {{"automation-science-pack", 1}},
        time = 10
    }
}

Technology:create {
    type = "technology",
    name = "architecture-2",
    icon = "__sosciencity__/graphics/technology/architecture.png",
    icon_size = 256,
    upgrade = true,
    prerequisites = {"ember-caste", "architecture-1"},
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

Technology:create {
    type = "technology",
    name = "architecture-3",
    icon = "__sosciencity__/graphics/technology/architecture.png",
    icon_size = 256,
    upgrade = true,
    prerequisites = {"gunfire-caste", "architecture-2"},
    effects = {},
    unit = {
        count = 110,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 20
    }
}

Technology:create {
    type = "technology",
    name = "architecture-4",
    icon = "__sosciencity__/graphics/technology/architecture.png",
    icon_size = 256,
    upgrade = true,
    prerequisites = {"gleam-caste", "architecture-3"},
    effects = {},
    unit = {
        count = 230,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 25
    }
}

Technology:create {
    type = "technology",
    name = "architecture-5",
    icon = "__sosciencity__/graphics/technology/architecture.png",
    icon_size = 256,
    upgrade = true,
    prerequisites = {"foundry-caste", "architecture-4"},
    effects = {},
    unit = {
        count = 470,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 30
    }
}

Technology:create {
    type = "technology",
    name = "architecture-6",
    icon = "__sosciencity__/graphics/technology/architecture.png",
    icon_size = 256,
    upgrade = true,
    prerequisites = {"orchid-caste", "architecture-5"},
    effects = {},
    unit = {
        count = 1060,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 35
    }
}

Technology:create {
    type = "technology",
    name = "architecture-7",
    icon = "__sosciencity__/graphics/technology/architecture.png",
    icon_size = 256,
    upgrade = true,
    prerequisites = {"aurora-caste", "architecture-6"},
    effects = {},
    unit = {
        count = 2350,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
            {"utility-science-pack", 1}
        },
        time = 40
    }
}

Technology:create {
    type = "technology",
    name = "architecture-8",
    icon = "__sosciencity__/graphics/technology/architecture.png",
    icon_size = 256,
    upgrade = true,
    prerequisites = {"space-science-pack", "architecture-7"},
    effects = {},
    unit = {
        count = 5510,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
            {"utility-science-pack", 1}
        },
        time = 45
    }
}

---------------------------------------------------------------------------------------------------
-- << other technologies >>
Technology:create {
    type = "technology",
    name = "resettlement",
    icon = "__sosciencity__/graphics/technology/resettlement.png", -- TODO create icon
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
