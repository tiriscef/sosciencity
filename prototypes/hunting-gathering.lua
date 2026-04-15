---------------------------------------------------------------------------------------------------
-- << items >>

local gathering_tool_items = {
    {
        name = "trap",
        distinctions = {subgroup = "sosciencity-gathering"}
    },
    {
        name = "trap-cage",
        distinctions = {subgroup = "sosciencity-gathering"}
    },
    {
        name = "bucket",
        distinctions = {subgroup = "sosciencity-gathering"}
    },
    {
        name = "simple-fishtrap",
        distinctions = {subgroup = "sosciencity-gathering"}
    },
    {
        name = "fishing-net",
        distinctions = {subgroup = "sosciencity-gathering"}
    },
    {
        name = "harpoon",
        distinctions = {subgroup = "sosciencity-gathering"}
    }
}

Tirislib.Item.batch_create(
    gathering_tool_items,
    {subgroup = "sosciencity-materials", stack_size = 200}
)

---------------------------------------------------------------------------------------------------
-- << recipes >>

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "trap", amount = 1}
    },
    ingredients = {
        {theme = "mechanism", amount = 2}
    },
    energy_required = 0.8,
    allow_productivity = true,
    unlock = "hunting-fishing"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "trap-cage", amount = 1}
    },
    ingredients = {
        {theme = "plating", amount = 2},
        {theme = "grating", amount = 10}
    },
    energy_required = 0.8,
    allow_productivity = true,
    unlock = "hunting-fishing"
}

--[[Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "bucket", amount = 1}
    },
    ingredients = {
        {theme = "handle", amount = 1},
        {theme = "plating", amount = 1}
    },
    energy_required = 0.8,
    unlock = "clockwork-caste"
}]]

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "simple-fishtrap", amount = 1}
    },
    ingredients = {
        {type = "item", name = "gingil-hemp", amount = 5},
        {type = "item", name = "rope", amount = 1}
    },
    name = "gingil-hemp",
    energy_required = 1.5,
    allow_productivity = true,
    unlock = "hunting-fishing"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "fishing-net", amount = 1}
    },
    ingredients = {
        {type = "item", name = "rope", amount = 5},
        {type = "item", name = "yarn", amount = 1},
        {type = "item", name = "lumber", amount = 2}
    },
    name = "rope",
    energy_required = 1,
    allow_productivity = true,
    unlock = "advanced-fishing"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "harpoon", amount = 1}
    },
    ingredients = {
        {theme = "handle", amount = 1},
        {theme = "mechanism", amount = 2},
        {type = "item", name = "rope", amount = 1}
    },
    name = "rope",
    energy_required = 1,
    allow_productivity = true,
    unlock = "advanced-fishing"
}

---------------------------------------------------------------------------------------------------
-- << hunting/gathering/fishing recipes >>

local function create_hunting_gathering_recipe(details)
    details.energy_required = details.energy_required or 4
    details.allow_decomposition = details.allow_decomposition or false
    details.always_show_made_in = details.always_show_made_in or true
    details.main_product = details.main_product or ""
    details.subgroup = details.subgroup or "sosciencity-gathering"

    return Tirislib.RecipeGenerator.create_from_prototype(details)
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
    order = "000595",
    unlock = "orchid-caste"
}

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
    order = "000655",
    unlock = "hunting-fishing"
}:add_catalyst("trap", "item", 2, 0.85)

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
    order = "000656",
    unlock = "hunting-fishing"
}:add_catalyst("trap-cage", "item", 2, 0.85)

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
    order = "000755",
    unlock = "hunting-fishing"
}:add_catalyst("simple-fishtrap", "item", 1, 0.9)

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
    order = "000756",
    unlock = "advanced-fishing"
}:add_catalyst("fishing-net", "item", 1, 0.95)

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
    order = "000757",
    unlock = "advanced-fishing"
}:add_catalyst("harpoon", "item", 1, 0.85)
