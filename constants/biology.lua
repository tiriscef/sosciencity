local Climate = require("enums.climate")
local Gender = require("enums.gender")
local Humidity = require("enums.humidity")

--- Values regarding carbon-based life-forms
local Biology = {}

--[[
    growth coefficient: 
        persistent: biomass growth per tick
        non-persistent: divider for the 'energy_required'-field, coincidentally also the number of items yielded per second
]]
Biology.flora = {
    ["apple"] = {
        persistent = true,
        growth_coefficient = 1,
        preferred_climate = Climate.temperate,
        wrong_climate_coefficient = 0.8,
        preferred_humidity = Humidity.moderate,
        wrong_humidity_coefficient = 0.8,
        recipes = {"farming-perennial-apple"},
        required_module = "apple-sapling"
    },
    ["avocado"] = {
        persistent = true,
        growth_coefficient = 1,
        preferred_climate = Climate.hot,
        wrong_climate_coefficient = 0.5,
        preferred_humidity = Humidity.dry,
        wrong_humidity_coefficient = 0.5,
        recipes = {"farming-perennial-avocado"},
        required_module = "avocado-sapling"
    },
    ["bell-pepper"] = {
        persistent = false,
        growth_coefficient = 1,
        preferred_climate = Climate.hot,
        wrong_climate_coefficient = 0.8,
        preferred_humidity = Humidity.moderate,
        wrong_humidity_coefficient = 0.7,
        recipes = {"farming-annual-bell-pepper"}
    },
    ["blue-grapes"] = {
        persistent = false,
        growth_coefficient = 1.25,
        preferred_climate = Climate.temperate,
        wrong_climate_coefficient = 0.95,
        preferred_humidity = Humidity.humid,
        wrong_humidity_coefficient = 0.75,
        recipes = {"farming-annual-blue-grapes"}
    },
    ["brutal-pumpkin"] = {
        persistent = false,
        growth_coefficient = 0.5,
        preferred_climate = Climate.cold,
        wrong_climate_coefficient = 0.9,
        preferred_humidity = Humidity.dry,
        wrong_humidity_coefficient = 0.9,
        recipes = {"farming-annual-brutal-pumpkin"}
    },
    ["cherry"] = {
        persistent = true,
        growth_coefficient = 1,
        preferred_climate = Climate.temperate,
        wrong_climate_coefficient = 0.7,
        preferred_humidity = Humidity.moderate,
        wrong_humidity_coefficient = 0.8,
        recipes = {"farming-perennial-cherry"},
        required_module = "cherry-sapling"
    },
    ["chickpea"] = {
        persistent = false,
        growth_coefficient = 1,
        preferred_climate = Climate.temperate,
        wrong_climate_coefficient = 0.6,
        preferred_humidity = Humidity.moderate,
        wrong_humidity_coefficient = 0.7,
        recipes = {"farming-annual-chickpea"}
    },
    ["eggplant"] = {
        persistent = false,
        growth_coefficient = 2,
        preferred_climate = Climate.temperate,
        wrong_climate_coefficient = 0.8,
        preferred_humidity = Humidity.moderate,
        wrong_humidity_coefficient = 0.7,
        recipes = {"farming-annual-eggplant"}
    },
    ["endower-flower"] = {
        persistent = false,
        growth_coefficient = 1,
        preferred_climate = Climate.temperate,
        wrong_climate_coefficient = 0.8,
        preferred_humidity = Humidity.moderate,
        wrong_humidity_coefficient = 1,
        recipes = {"farming-algae-endower-flower"}
    },
    ["fawoxylas"] = {
        persistent = false,
        growth_coefficient = 1,
        preferred_climate = Climate.temperate,
        wrong_climate_coefficient = 0.9,
        preferred_humidity = Humidity.humid,
        wrong_humidity_coefficient = 0.8,
        recipes = {"farming-mushroom-fawoxylas"}
    },
    ["gingil-hemp"] = {
        persistent = false,
        growth_coefficient = 1.5,
        preferred_climate = Climate.cold,
        wrong_climate_coefficient = 0.9,
        preferred_humidity = Humidity.moderate,
        wrong_humidity_coefficient = 0.9,
        recipes = {"farming-annual-gingil-hemp"}
    },
    ["hardcorn-punk"] = {
        persistent = false,
        growth_coefficient = 2,
        preferred_climate = Climate.temperate,
        wrong_climate_coefficient = 0.8,
        preferred_humidity = Humidity.moderate,
        wrong_humidity_coefficient = 0.8,
        recipes = {"farming-annual-hardcorn-punk"}
    },
    ["lemon"] = {
        persistent = true,
        growth_coefficient = 1,
        preferred_climate = Climate.hot,
        wrong_climate_coefficient = 0.75,
        preferred_humidity = Humidity.dry,
        wrong_humidity_coefficient = 0.75,
        recipes = {"farming-perennial-lemon"},
        required_module = "lemon-sapling"
    },
    ["liontooth"] = {
        persistent = false,
        growth_coefficient = 1.5,
        preferred_climate = Climate.cold,
        wrong_climate_coefficient = 0.9,
        preferred_humidity = Humidity.dry,
        wrong_humidity_coefficient = 0.9,
        recipes = {"farming-annual-liontooth"}
    },
    ["manok"] = {
        persistent = false,
        growth_coefficient = 1,
        preferred_climate = Climate.hot,
        wrong_climate_coefficient = 0.8,
        preferred_humidity = Humidity.moderate,
        wrong_humidity_coefficient = 0.7,
        recipes = {"farming-annual-manok"}
    },
    ["necrofall"] = {
        persistent = false,
        growth_coefficient = 0.5,
        preferred_climate = Climate.cold,
        wrong_climate_coefficient = 0.7,
        preferred_humidity = Humidity.humid,
        wrong_humidity_coefficient = 0.7,
        recipes = {
            "farming-annual-necrofall",
            "farming-annual-bloomhouse-necrofall"
        }
    },
    ["olive"] = {
        persistent = true,
        growth_coefficient = 1,
        preferred_climate = Climate.hot,
        wrong_climate_coefficient = 0.8,
        preferred_humidity = Humidity.dry,
        wrong_humidity_coefficient = 0.7,
        recipes = {"farming-perennial-olive"}
    },
    ["orange"] = {
        persistent = true,
        growth_coefficient = 1,
        preferred_climate = Climate.hot,
        wrong_climate_coefficient = 0.75,
        preferred_humidity = Humidity.dry,
        wrong_humidity_coefficient = 0.75,
        recipes = {"farming-perennial-orange"},
        required_module = "orange-sapling"
    },
    ["ortrot"] = {
        persistent = true,
        growth_coefficient = 1,
        preferred_climate = Climate.temperate,
        wrong_climate_coefficient = 0.8,
        preferred_humidity = Humidity.dry,
        wrong_humidity_coefficient = 0.95,
        recipes = {"farming-perennial-ortrot"},
        required_module = "ortrot-sapling"
    },
    ["phytofall-blossom"] = {
        persistent = false,
        growth_coefficient = 1,
        preferred_climate = Climate.temperate,
        wrong_climate_coefficient = 0.7,
        preferred_humidity = Humidity.moderate,
        wrong_humidity_coefficient = 0.7,
        recipes = {
            "farming-annual-phytofall-blossom",
            "farming-annual-bloomhouse-phytofall-blossom"
        }
    },
    ["pocelial"] = {
        persistent = false,
        growth_coefficient = 1,
        preferred_climate = Climate.temperate,
        wrong_climate_coefficient = 0.8,
        preferred_humidity = Humidity.moderate,
        wrong_humidity_coefficient = 0.9,
        recipes = {"farming-mushroom-pocelial"}
    },
    ["potato"] = {
        persistent = false,
        growth_coefficient = 1.5,
        preferred_climate = Climate.temperate,
        wrong_climate_coefficient = 0.7,
        preferred_humidity = Humidity.moderate,
        wrong_humidity_coefficient = 0.9,
        recipes = {"farming-annual-potato"}
    },
    ["pyrifera"] = {
        persistent = false,
        growth_coefficient = 1,
        preferred_climate = Climate.hot,
        wrong_climate_coefficient = 0.8,
        preferred_humidity = Humidity.moderate,
        wrong_humidity_coefficient = 1,
        recipes = {"farming-algae-pyrifera"}
    },
    ["queen-algae"] = {
        persistent = false,
        growth_coefficient = 1.5,
        preferred_climate = Climate.hot,
        wrong_climate_coefficient = 0.6,
        preferred_humidity = Humidity.moderate,
        wrong_humidity_coefficient = 1,
        recipes = {"farming-algae-queen-algae"}
    },
    ["razha-bean"] = {
        persistent = false,
        growth_coefficient = 1.75,
        preferred_climate = Climate.temperate,
        wrong_climate_coefficient = 0.9,
        preferred_humidity = Humidity.humid,
        wrong_humidity_coefficient = 0.7,
        recipes = {"farming-annual-razha-bean"}
    },
    ["sesame"] = {
        persistent = false,
        growth_coefficient = 0.8,
        preferred_climate = Climate.temperate,
        wrong_climate_coefficient = 0.9,
        preferred_humidity = Humidity.dry,
        wrong_humidity_coefficient = 0.9,
        recipes = {"farming-annual-sesame"}
    },
    ["sugar-beet"] = {
        persistent = false,
        growth_coefficient = 1.25,
        preferred_climate = Climate.temperate,
        wrong_climate_coefficient = 0.8,
        preferred_humidity = Humidity.moderate,
        wrong_humidity_coefficient = 0.8,
        recipes = {"farming-annual-sugar-beet"}
    },
    ["sugar-cane"] = {
        persistent = false,
        growth_coefficient = 2,
        preferred_climate = Climate.hot,
        wrong_climate_coefficient = 0.8,
        preferred_humidity = Humidity.humid,
        wrong_humidity_coefficient = 0.7,
        recipes = {"farming-annual-sugar-cane"}
    },
    ["tomato"] = {
        persistent = false,
        growth_coefficient = 2,
        preferred_climate = Climate.temperate,
        wrong_climate_coefficient = 0.9,
        preferred_humidity = Humidity.humid,
        wrong_humidity_coefficient = 0.8,
        recipes = {"farming-annual-tomato"}
    },
    ["plemnemm-cotton"] = {
        persistent = false,
        growth_coefficient = 1,
        preferred_climate = Climate.temperate,
        wrong_climate_coefficient = 0.9,
        preferred_humidity = Humidity.humid,
        wrong_humidity_coefficient = 0.8,
        recipes = {"farming-annual-plemnemm-cotton"}
    },
    ["tiriscefing-willow-wood"] = {
        persistent = true,
        growth_coefficient = 1,
        preferred_climate = Climate.cold,
        wrong_climate_coefficient = 0.9,
        preferred_humidity = Humidity.moderate,
        wrong_humidity_coefficient = 0.8,
        recipes = {"farming-perennial-tiriscefing-willow-wood"}
    },
    ["unnamed-fruit"] = {
        persistent = false,
        growth_coefficient = 1,
        preferred_climate = Climate.cold,
        wrong_climate_coefficient = 0.8,
        preferred_humidity = Humidity.moderate,
        wrong_humidity_coefficient = 0.9,
        recipes = {"farming-annual-unnamed-fruit"}
    },
    ["weird-berry"] = {
        persistent = false,
        growth_coefficient = 1,
        preferred_climate = Climate.hot,
        wrong_climate_coefficient = 0.8,
        preferred_humidity = Humidity.humid,
        wrong_humidity_coefficient = 0.8,
        recipes = {"farming-annual-weird-berry"}
    },
    ["zetorn"] = {
        persistent = true,
        growth_coefficient = 1,
        preferred_climate = Climate.hot,
        wrong_climate_coefficient = 0.85,
        preferred_humidity = Humidity.dry,
        wrong_humidity_coefficient = 0.85,
        recipes = {"farming-perennial-zetorn"},
        required_module = "zetorn-sapling"
    }
}

Biology.composting_climate_factors = {
    [Climate.hot] = 1.25,
    [Climate.temperate] = 1,
    [Climate.temperate] = 0.80
}

Biology.composting_humidity_factors = {
    [Humidity.humid] = 1.5,
    [Humidity.moderate] = 1,
    [Humidity.dry] = 2 / 3
}

Biology.egg_calories = 10000
Biology.egg_fertile = "huwan-egg"

Biology.egg_values = {
    ["huwan-egg"] = {
        [Gender.agender] = 0.3,
        [Gender.fale] = 0.2,
        [Gender.pachin] = 0.2,
        [Gender.ga] = 0.3
    },
    ["huwan-agender-egg"] = {
        [Gender.agender] = 1,
        [Gender.fale] = 0,
        [Gender.pachin] = 0,
        [Gender.ga] = 0
    },
    ["huwan-fale-egg"] = {
        [Gender.agender] = 0,
        [Gender.fale] = 1,
        [Gender.pachin] = 0,
        [Gender.ga] = 0
    },
    ["huwan-pachin-egg"] = {
        [Gender.agender] = 0,
        [Gender.fale] = 0,
        [Gender.pachin] = 1,
        [Gender.ga] = 0
    },
    ["huwan-ga-egg"] = {
        [Gender.agender] = 0,
        [Gender.fale] = 0,
        [Gender.pachin] = 0,
        [Gender.ga] = 1
    }
}

-- create the lookup table
local species_lookup = {}
for _, family in pairs({"flora"}) do
    for name, details in pairs(Biology[family]) do
        for _, recipe_name in pairs(details.recipes) do
            species_lookup[recipe_name] = name
        end
    end
end

--- Returns the species table for the given recipe.
--- @param recipe string|nil
--- @return table|nil
function Biology.get_species(recipe)
    return recipe and species_lookup[recipe.name] or nil
end

return Biology
