--- Values regarding carbon-based life-forms
Biology = {}

Biology.flora = {
    ["avocado"] = {
        persistent = true,
        growth_coefficient = 0.7,
        recipes = {}
    },
    ["cherry"] = {
        persistent = true,
        growth_coefficient = 1,
        recipes = {}
    },
    ["tiriscefing-willow"] = {
        growth_coefficient = 2,
        recipes = {}
    },
    ["lemon"] = {
        persistent = true,
        growth_coefficient = 0.6,
        recipes = {}
    },
    ["orange"] = {
        persistent = true,
        growth_coefficient = 0.6,
        recipes = {}
    },
    ["olive"] = {
        persistent = true,
        growth_coefficient = 0.8,
        recipes = {}
    },
    ["zetorn"] = {
        persistent = true,
        growth_coefficient = 0.6,
        recipes = {}
    },
    ["bell-pepper"] = {
        recipes = {}
    },
    ["brutal-pumpkin"] = {
        recipes = {}
    },
    ["potato"] = {
        recipes = {}
    },
    ["tomato"] = {
        recipes = {}
    },
    ["eggplant"] = {
        recipes = {}
    },
    ["plemnemm-cotton"] = {
        recipes = {}
    },
    ["unnamed-fruit"] = {
        recipes = {}
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

function Biology.get_species(recipe)
    return species_lookup[recipe.name]
end