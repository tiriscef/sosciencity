---------------------------------------------------------------------------------------------------
-- << caste technologies >>

Tirislib.Technology.create {
    name = "ember-caste",
    icon = "__sosciencity-graphics__/graphics/ember-caste.png",
    icon_size = 256,
    prerequisites = {"upbringing"},
    effects = {},
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
        },
        {
            type = "nothing",
            effect_description = {"description.caste-upbringing-efficiency", {"caste-name.ember"}}
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
    localised_name = {"technology-name.caste-efficiency", {"caste-short.ember"}}
}

Tirislib.Technology.create {
    name = "orchid-caste",
    icon = "__sosciencity-graphics__/graphics/orchid-caste.png",
    icon_size = 256,
    prerequisites = {"ember-caste", "open-environment-farming"},
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
        },
        {
            type = "nothing",
            effect_description = {"description.caste-upbringing-efficiency", {"caste-name.orchid"}}
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
    prerequisites = {"logistic-science-pack"},
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
        },
        {
            type = "nothing",
            effect_description = {"description.caste-upbringing-efficiency", {"caste-name.gunfire"}}
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
        },
        {
            type = "nothing",
            effect_description = {"description.caste-upbringing-efficiency", {"caste-name.plasma"}}
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
    name = "clockwork-caste",
    icon = "__sosciencity-graphics__/graphics/clockwork-caste.png",
    icon_size = 256,
    prerequisites = {"orchid-caste", "logistic-science-pack"},
    unit = {
        count = 133,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 20
    }
}

Tirislib.Technology("chemical-science-pack"):add_prerequisite("clockwork-caste")

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
        },
        {
            type = "nothing",
            effect_description = {"description.caste-upbringing-efficiency", {"caste-name.clockwork"}}
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
    localised_name = {"technology-name.caste-efficiency", {"caste-short.clockwork"}}
}

Tirislib.Technology.create {
    name = "foundry-caste",
    icon = "__sosciencity-graphics__/graphics/foundry-caste.png",
    icon_size = 256,
    prerequisites = {"clockwork-caste", "chemical-science-pack"},
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
        },
        {
            type = "nothing",
            effect_description = {"description.caste-upbringing-efficiency", {"caste-name.foundry"}}
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
    prerequisites = {"clockwork-caste", "chemical-science-pack"},
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
        },
        {
            type = "nothing",
            effect_description = {"description.caste-upbringing-efficiency", {"caste-name.gleam"}}
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
-- << split into separate files >>

require("prototypes.technologies.infrastructure")
require("prototypes.technologies.architecture")

require("prototypes.technologies.ember")
require("prototypes.technologies.orchid")
require("prototypes.technologies.clockwork")

require("prototypes.technologies.healthcare")
require("prototypes.technologies.biology")
require("prototypes.technologies.botany")
require("prototypes.technologies.farming")
require("prototypes.technologies.water-treatment")
require("prototypes.technologies.food-processing")
