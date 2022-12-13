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
        {type = "item", name = "gingil-hemp", amount = 5, probability = 0.5},
        {type = "item", name = "hardcorn-punk", amount = 5, probability = 0.5},
        {type = "item", name = "phytofall-blossom", amount = 2, probability = 0.32}
    },
    order = "000555"
}

create_hunting_gathering_recipe {
    name = "gathering-food",
    category = "sosciencity-hunting",
    energy_required = 4,
    icons = {
        {icon = "__sosciencity-graphics__/graphics/icon/gather-food-1.png"}
    },
    icon_size = 64,
    results = {
        {type = "item", name = "leafage", amount = 1},
        {type = "item", name = "liontooth", amount = 5, probability = 0.7},
        {type = "item", name = "razha-bean", amount = 3, probability = 0.2},
        {type = "item", name = "unnamed-fruit", amount = 3, probability = 0.5},
        {type = "item", name = "blue-grapes", amount = 3, probability = 0.3}
    },
    order = "000565"
}

create_hunting_gathering_recipe {
    name = "gathering-food-2",
    category = "sosciencity-hunting",
    energy_required = 4,
    icons = {
        {icon = "__sosciencity-graphics__/graphics/icon/gather-food-2.png"}
    },
    icon_size = 64,
    results = {
        {type = "item", name = "leafage", amount = 2},
        {type = "item", name = "liontooth", amount = 5, probability = 0.7},
        {type = "item", name = "razha-bean", amount = 5, probability = 0.2},
        {type = "item", name = "unnamed-fruit", amount = 3, probability = 0.5},
        {type = "item", name = "blue-grapes", amount = 5, probability = 0.3},
        {type = "item", name = "manok", amount = 2, probability = 0.35},
        {type = "item", name = "weird-berry", amount = 2, probability = 0.4}
    },
    order = "000566"
}:add_unlock("explore-alien-flora-1")

create_hunting_gathering_recipe {
    name = "gathering-food-3",
    category = "sosciencity-hunting",
    energy_required = 4,
    icons = {
        {icon = "__sosciencity-graphics__/graphics/icon/gather-food-3.png"}
    },
    icon_size = 64,
    results = {
        {type = "item", name = "leafage", amount = 4},
        {type = "item", name = "liontooth", amount = 5, probability = 0.7},
        {type = "item", name = "razha-bean", amount = 5, probability = 0.2},
        {type = "item", name = "unnamed-fruit", amount = 3, probability = 0.5},
        {type = "item", name = "blue-grapes", amount = 5, probability = 0.3},
        {type = "item", name = "manok", amount = 2, probability = 0.35},
        {type = "item", name = "weird-berry", amount = 2, probability = 0.4},
        {type = "item", name = "brutal-pumpkin", amount = 1, probability = 0.3},
        {type = "item", name = "ortrot", amount = 5, probability = 0.3},
        {type = "item", name = "tello-fruit", amount = 2, probability = 0.3},
        {type = "item", name = "zetorn", amount = 5, probability = 0.3}
    },
    order = "000567"
}:add_unlock("explore-alien-flora-2")

create_hunting_gathering_recipe {
    name = "gathering-mushrooms",
    category = "sosciencity-hunting",
    energy_required = 4,
    icons = {
        {icon = "__sosciencity-graphics__/graphics/icon/gather-mushrooms.png"}
    },
    icon_size = 64,
    results = {
        {type = "item", name = "fawoxylas", amount = 5, probability = 0.5},
        {type = "item", name = "pocelial", amount = 5, probability = 0.5},
        {type = "item", name = "red-hatty", amount = 5, probability = 0.5},
        {type = "item", name = "birdsnake", amount = 5, probability = 0.5}
    },
    order = "000575"
}

create_hunting_gathering_recipe {
    name = "gathering-algae",
    category = "sosciencity-fishery-hand",
    energy_required = 4,
    icons = {
        {icon = "__sosciencity-graphics__/graphics/icon/gather-algae.png"}
    },
    icon_size = 64,
    results = {
        {type = "item", name = "queen-algae", amount = 3},
        {type = "item", name = "pyrifera", amount = 2, probability = 0.5},
        {type = "item", name = "endower-flower", amount = 2, probability = 0.5}
    },
    order = "000585"
}

create_hunting_gathering_recipe {
    name = "hunting-with-trap",
    category = "sosciencity-hunting",
    energy_required = 10,
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
}:add_catalyst("trap", "item", 2, 0.85, 3, 0.7):add_unlock("clockwork-caste")

create_hunting_gathering_recipe {
    name = "hunting-with-trap-cage",
    category = "sosciencity-hunting",
    energy_required = 10,
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
        {type = "item", name = "smol-bonesnake", amount = 4, probability = 0.1},
        {type = "item", name = "cabar", amount = 4, probability = 0.5},
        {type = "item", name = "caddle", amount = 1, probability = 0.5}
    },
    order = "000656"
}:add_catalyst("trap-cage", "item", 2, 0.85, 3, 0.7):add_unlock("clockwork-caste")

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
}:add_catalyst("simple-fishtrap", "item", 1, 0.9, 1, 0.8):add_unlock("clockwork-caste")

create_hunting_gathering_recipe {
    name = "fishing-with-fishing-net",
    category = "sosciencity-fishery",
    energy_required = 15,
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
        {type = "item", name = "shellscript", amount = 3, probability = 0.5},
        {type = "item", name = "boofish", amount = 20, probability = 0.8},
        {type = "item", name = "fupper", amount = 10, probability = 0.8},
        {type = "item", name = "dodkopus", amount = 1, probability = 0.1},
        {type = "item", name = "ultra-squibbel", amount = 2, probability = 0.1},
        {type = "item", name = "miniscule-squibbel", amount = 1, probability = 0.08}
    },
    order = "000756"
}:add_catalyst("fishing-net", "item", 1, 0.95, 1, 0.9):add_unlock("advanced-fishing")

create_hunting_gathering_recipe {
    name = "fishing-with-harpoon",
    category = "sosciencity-fishery",
    energy_required = 20,
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
        {type = "item", name = "petunial", amount = 1, probability = 0.07},
        {type = "item", name = "hellfin", amount = 1, probability = 0.5},
        {type = "item", name = "warnal", amount = 1, probability = 0.1},
        {type = "item", name = "ultra-squibbel", amount_min = 1, amount_max = 3},
        {type = "item", name = "miniscule-squibbel", amount = 1, probability = 0.4}
    },
    order = "000757"
}:add_catalyst("harpoon", "item", 1, 0.85, 1, 0.7):add_unlock("advanced-fishing")
