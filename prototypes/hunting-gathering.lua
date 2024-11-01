local function create_hunting_gathering_recipe(details)
    Tirislib.RecipeGenerator.merge_details(
        details,
        {
            energy_required = 4,
            allow_decomposition = false,
            always_show_made_in = true,
            main_product = "",
            subgroup = "sosciencity-gathering"
        }
    )

    return Tirislib.Recipe.create(details)
end

create_hunting_gathering_recipe {
    name = "gathering-food",
    category = "sosciencity-hunting",
    energy_required = 5,
    icons = {
        {icon = "__sosciencity-graphics__/graphics/icon/gather-food-1.png"}
    },
    icon_size = 64,
    results = {
        {type = "item", name = "wild-edible-plants", amount_min = 0, amount_max = 6},
        {type = "item", name = "leafage", amount = 1}
    },
    order = "000565"
}

create_hunting_gathering_recipe {
    name = "gathering-mushrooms",
    category = "sosciencity-hunting",
    energy_required = 5,
    icons = {
        {icon = "__sosciencity-graphics__/graphics/icon/gather-mushrooms.png"}
    },
    icon_size = 64,
    results = {
        {type = "item", name = "wild-fungi", amount_min = 0, amount_max = 6}
    },
    order = "000575"
}

create_hunting_gathering_recipe {
    name = "gathering-algae",
    category = "sosciencity-fishery-hand",
    energy_required = 5,
    icons = {
        {icon = "__sosciencity-graphics__/graphics/icon/gather-algae.png"}
    },
    icon_size = 64,
    results = {
        {type = "item", name = "wild-algae", amount_min = 0, amount_max = 6}
    },
    order = "000585"
}

create_hunting_gathering_recipe {
    name = "gathering-materials",
    category = "sosciencity-hunting",
    energy_required = 3,
    icons = {
        {icon = "__sosciencity-graphics__/graphics/icon/gather-materials.png"}
    },
    icon_size = 64,
    results = {
        {type = "item", name = "leafage", amount = 2},
        {type = "item", name = "tiriscefing-willow-wood", amount = 3},
        {type = "item", name = "plemnemm-cotton", amount = 5},
        {type = "item", name = "gingil-hemp", amount = 5, probability = 0.5}
    },
    order = "000590"
}

create_hunting_gathering_recipe {
    name = "gathering-wood",
    category = "sosciencity-hunting",
    energy_required = 3,
    icon = "__sosciencity-graphics__/graphics/icon/tiriscefing-willow-wood.png",
    icon_size = 64,
    results = {
        {type = "item", name = "tiriscefing-willow-wood", amount = 3},
        {type = "item", name = "leafage", amount = 1}
    },
    order = "000592"
}

create_hunting_gathering_recipe {
    name = "gathering-cotton",
    category = "sosciencity-hunting",
    energy_required = 3,
    icon = "__sosciencity-graphics__/graphics/icon/plemnemm-cotton.png",
    icon_size = 64,
    results = {
        {type = "item", name = "plemnemm-cotton", amount = 5},
        {type = "item", name = "leafage", amount = 1}
    },
    order = "000593"
}

create_hunting_gathering_recipe {
    name = "gathering-hemp",
    category = "sosciencity-hunting",
    energy_required = 3,
    icon = "__sosciencity-graphics__/graphics/icon/gingil-hemp.png",
    icon_size = 64,
    results = {
        {type = "item", name = "gingil-hemp", amount = 5},
        {type = "item", name = "leafage", amount = 1}
    },
    order = "000594"
}

create_hunting_gathering_recipe {
    name = "gathering-flowers",
    category = "sosciencity-hunting",
    energy_required = 3,
    icon = "__sosciencity-graphics__/graphics/icon/phytofall-blossom.png",
    icon_size = 64,
    results = {
        {type = "item", name = "phytofall-blossom", amount = 2},
        {type = "item", name = "leafage", amount = 1}
    },
    order = "000595"
}:add_unlock("orchid-caste")

create_hunting_gathering_recipe {
    name = "hunting-with-trap",
    category = "sosciencity-hunting",
    energy_required = 20,
    icons = {
        {
            icon = "__sosciencity-graphics__/graphics/icon/hunting.png"
        },
        {
            icon = "__sosciencity-graphics__/graphics/icon/trap.png",
            scale = 0.3,
            shift = {8, 8}
        }
    },
    icon_size = 64,
    results = {
        {type = "item", name = "river-horse", amount = 1, probability = 0.1},
        {type = "item", name = "bonesnake", amount = 1, probability = 0.1},
        {type = "item", name = "caddle", amount = 1, probability = 0.5},
        {type = "item", name = "biter-meat", amount_min = 0, amount_max = 20}
    },
    order = "000655"
}:add_catalyst("trap", "item", 2, 0.85):add_unlock("hunting-fishing")

create_hunting_gathering_recipe {
    name = "hunting-with-trap-cage",
    category = "sosciencity-hunting",
    energy_required = 20,
    icons = {
        {
            icon = "__sosciencity-graphics__/graphics/icon/hunting.png"
        },
        {
            icon = "__sosciencity-graphics__/graphics/icon/trap-cage.png",
            scale = 0.3,
            shift = {8, 8}
        }
    },
    icon_size = 64,
    results = {
        {type = "item", name = "primal-quackling", amount = 3, probability = 0.5},
        {type = "item", name = "primal-quacker", amount = 2, probability = 0.5},
        {type = "item", name = "nan-swanling", amount = 5, probability = 0.1},
        {type = "item", name = "nan-swan", amount = 1, probability = 0.4},
        {type = "item", name = "cabar", amount = 4, probability = 0.5},
        {type = "item", name = "caddle", amount = 1, probability = 0.5}
    },
    order = "000656"
}:add_catalyst("trap-cage", "item", 2, 0.85):add_unlock("hunting-fishing")

create_hunting_gathering_recipe {
    name = "fishing-with-simple-fishtrap",
    category = "sosciencity-fishery",
    energy_required = 6.5,
    icons = {
        {
            icon = "__sosciencity-graphics__/graphics/icon/fishing.png"
        },
        {
            icon = "__sosciencity-graphics__/graphics/icon/simple-fishtrap.png",
            scale = 0.3,
            shift = {8, 8}
        }
    },
    icon_size = 64,
    results = {
        {type = "item", name = "boofish", amount_min = 1, amount_max = 2},
        {type = "item", name = "fupper", amount_min = 0, amount_max = 1}
    },
    order = "000755"
}:add_catalyst("simple-fishtrap", "item", 1, 0.9):add_unlock("hunting-fishing")

create_hunting_gathering_recipe {
    name = "fishing-with-fishing-net",
    category = "sosciencity-fishery",
    energy_required = 30,
    icons = {
        {
            icon = "__sosciencity-graphics__/graphics/icon/fishing.png"
        },
        {
            icon = "__sosciencity-graphics__/graphics/icon/fishing-net.png",
            scale = 0.3,
            shift = {8, 8}
        }
    },
    icon_size = 64,
    results = {
        {type = "item", name = "shellscript", amount_min = 1, amount_max = 2},
        {type = "item", name = "boofish", amount_min = 10, amount_max = 16},
        {type = "item", name = "fupper", amount_min = 5, amount_max = 10},
        {type = "item", name = "dodkopus", amount = 1, probability = 0.1},
        {type = "item", name = "ultra-squibbel", amount = 2, probability = 0.1},
        {type = "item", name = "miniscule-squibbel", amount = 1, probability = 0.08}
    },
    order = "000756"
}:add_catalyst("fishing-net", "item", 1, 0.95):add_unlock("advanced-fishing")

create_hunting_gathering_recipe {
    name = "fishing-with-harpoon",
    category = "sosciencity-fishery",
    energy_required = 40,
    icons = {
        {
            icon = "__sosciencity-graphics__/graphics/icon/fishing.png"
        },
        {
            icon = "__sosciencity-graphics__/graphics/icon/harpoon.png",
            scale = 0.3,
            shift = {8, 8}
        }
    },
    icon_size = 64,
    results = {
        {type = "item", name = "petunial", amount = 1, probability = 0.06},
        {type = "item", name = "hellfin", amount = 1, probability = 0.3},
        {type = "item", name = "warnal", amount = 1, probability = 0.1},
        {type = "item", name = "ultra-squibbel", amount_min = 1, amount_max = 3},
        {type = "item", name = "miniscule-squibbel", amount = 1, probability = 0.4}
    },
    order = "000757"
}:add_catalyst("harpoon", "item", 1, 0.85):add_unlock("advanced-fishing")
