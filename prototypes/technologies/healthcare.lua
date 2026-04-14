---------------------------------------------------------------------------------------------------
-- << healthcare >>

Tirislib.Technology.create {
    name = "medbay",
    icon = "__sosciencity-graphics__/graphics/technology/medbay.png",
    icon_size = 256,
    prerequisites = {"orchid-caste"},
    unit = {
        count = 29,
        ingredients = {
            {"automation-science-pack", 1}
        },
        time = 20
    }
}

Tirislib.Technology.create {
    name = "activated-carbon-filtering",
    icon = "__sosciencity-graphics__/graphics/technology/activated-carbon-filtering.png",
    icon_size = 256,
    prerequisites = {"medbay"},
    unit = {
        count = 41,
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

Tirislib.Technology.create {
    name = "transfusion-medicine",
    icon = "__sosciencity-graphics__/graphics/icon/blood-bag.png",
    icon_size = 64,
    prerequisites = {"chemical-science-pack", "hospital"},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.enable-blood-donations"}
        }
    },
    unit = {
        count = 86,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 30
    }
}

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
