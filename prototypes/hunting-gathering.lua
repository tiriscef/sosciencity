local Food = require("constants.food")

local function create_hunting_gathering_recipe(details)
    Tirislib_RecipeGenerator.merge_details(
        details,
        {
            energy_required = 4,
            allow_decomposition = false,
            always_show_made_in = true,
            main_product = "",
            subgroup = "sosciencity-gathering",
            unlock = "clockwork-caste"
        }
    )

    return Tirislib_Recipe.create(details)
end

create_hunting_gathering_recipe {
    name = "sosciencity-gathering",
    category = "sosciencity-hunting",
    energy_required = 8,
    icons = {
        {icon = "__sosciencity-graphics__/graphics/icon/gathering.png"}
    },
    icon_size = 64,
    results = {
        {type = "item", name = "blue-grapes", amount = 3, probability = 0.2},
        {type = "item", name = "brutal-pumpkin", amount = 1, probability = 0.1},
        {type = "item", name = "leafage", amount = 2},
        {type = "item", name = "liontooth", amount = 2, probability = 0.5},
        {type = "item", name = "fawoxylas", amount = 1, probability = 0.1},
        {type = "item", name = "gingil-hemp", amount = 3, probability = 0.5},
        {type = "item", name = "hardcorn-punk", amount = 3, probability = 0.5},
        {type = "item", name = "phytofall-blossom", amount = 2, probability = 0.3},
        {type = "item", name = "plemnemm-cotton", amount = 3, probability = 0.5},
        {type = "item", name = "manok", amount = 2, probability = 0.35},
        {type = "item", name = "ortrot", amount = 5, probability = 0.1},
        {type = "item", name = "razha-bean", amount = 3, probability = 0.2},
        {type = "item", name = "unnamed-fruit", amount = 3, probability = 0.1},
        {type = "item", name = "zetorn", amount = 5, probability = 0.1}
    }
}

local gather_for_food =
    Tirislib_Recipe.copy("sosciencity-gathering", "sosciencity-gathering-for-food"):add_unlock("clockwork-caste")
for _, recipe_data in pairs(gather_for_food:get_recipe_datas()) do
    recipe_data.results =
        Tirislib_Luaq.from(Tirislib_Tables.recursive_copy(recipe_data.results)):where(
        function(_, result)
            return Food.values[result.name]
        end
    ):foreach(
        function(_, result)
            result.probability =
                (result.probability * 1.1 < 1) and Tirislib_Utils.round_to_step(result.probability * 1.1, 0.01) or nil
        end
    ):to_array()
end

create_hunting_gathering_recipe {
    name = "sosciencity-hunting-with-trap",
    category = "sosciencity-hunting",
    energy_required = 5,
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
        {type = "item", name = "biter-meat", amount_min = 0, amount_max = 10}
    }
}:add_catalyst("trap", "item", 2, 0.85, 3, 0.7):add_unlock("clockwork-caste")

create_hunting_gathering_recipe {
    name = "sosciencity-hunting-with-trap-cage",
    category = "sosciencity-hunting",
    energy_required = 5,
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
        {type = "item", name = "primal-quackling", amount = 10, probability = 0.1},
        {type = "item", name = "primal-quacker", amount = 5, probability = 0.5},
        {type = "item", name = "primal-quackpa", amount = 2, probability = 0.2},
        {type = "item", name = "nan-swanling", amount = 5, probability = 0.1},
        {type = "item", name = "nan-swan", amount = 3, probability = 0.3},
        {type = "item", name = "elder-nan", amount = 2, probability = 0.15},
        {type = "item", name = "smol-bonesnake", amount = 2, probability = 0.1},
        {type = "item", name = "cabar", amount = 5, probability = 0.5},
        {type = "item", name = "caddle", amount = 1, probability = 0.5}
    }
}:add_catalyst("trap-cage", "item", 2, 0.85, 3, 0.7):add_unlock("clockwork-caste")

create_hunting_gathering_recipe {
    name = "sosciencity-fishing-with-fishing-net",
    category = "sosciencity-fishery",
    energy_required = 5,
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
        {type = "item", name = "miniscule-squibbel", amount = 1, probability = 0.1}
    }
}:add_catalyst("fishing-net", "item", 1, 0.95, 1, 0.9):add_unlock("clockwork-caste")

create_hunting_gathering_recipe {
    name = "sosciencity-fishing-with-harpoon",
    category = "sosciencity-fishery",
    energy_required = 5,
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
        {type = "item", name = "young-petunial", amount = 1, probability = 0.01},
        {type = "item", name = "petunial", amount = 1, probability = 0.01},
        {type = "item", name = "hellfin", amount = 1, probability = 0.05},
        {type = "item", name = "warnal", amount = 1, probability = 0.01},
        {type = "item", name = "ultra-squibbel", amount = 2, probability = 0.1},
        {type = "item", name = "miniscule-squibbel", amount = 1, probability = 0.1}
    }
}:add_catalyst("harpoon", "item", 1, 0.85, 1, 0.7):add_unlock("clockwork-caste")
