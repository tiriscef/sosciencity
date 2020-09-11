require("constants.enums")

--- Things that define different kinds of people.
Castes = {}

Castes.values = {
    [Type.clockwork] = {
        name = "clockwork",
        tech_name = "clockwork-caste",
        fear_multiplier = 0.5,
        calorific_demand = 4000, -- in kcal per day
        power_demand = 2, -- in kW
        power_bonus = 2,
        no_power_malus = -1,
        favored_taste = Taste.umami,
        least_favored_taste = Taste.spicy,
        desire_for_luxury = 0,
        minimum_food_count = 2,
        required_room_count = 1,
        minimum_comfort = 0,
        immigration_threshold = 5,
        immigration_coefficient = 1.5, -- immigrants per minute,
        gender_distribution = {
            [Gender.neutral] = 50,
            [Gender.fale] = 25,
            [Gender.pachin] = 5,
            [Gender.ga] = 20
        }
    },
    [Type.orchid] = {
        name = "orchid",
        tech_name = "orchid-caste",
        fear_multiplier = 1,
        calorific_demand = 3500,
        power_demand = 3,
        power_bonus = 2,
        no_power_malus = -2,
        favored_taste = Taste.sweet,
        least_favored_taste = Taste.sour,
        desire_for_luxury = 1,
        minimum_food_count = 4,
        required_room_count = 1,
        minimum_comfort = 8,
        immigration_threshold = 5,
        immigration_coefficient = 1.1,
        gender_distribution = {
            [Gender.neutral] = 15,
            [Gender.fale] = 5,
            [Gender.pachin] = 60,
            [Gender.ga] = 20
        }
    },
    [Type.gunfire] = {
        name = "gunfire",
        tech_name = "gunfire-caste",
        fear_multiplier = 0,
        calorific_demand = 4600,
        power_demand = 2,
        power_bonus = 2,
        no_power_malus = -1,
        favored_taste = Taste.bitter,
        least_favored_taste = Taste.sweet,
        desire_for_luxury = 0,
        minimum_food_count = 2,
        required_room_count = 0.5,
        minimum_comfort = 0,
        immigration_threshold = 5,
        immigration_coefficient = 1.5,
        gender_distribution = {
            [Gender.neutral] = 91,
            [Gender.fale] = 3,
            [Gender.pachin] = 3,
            [Gender.ga] = 3
        }
    },
    [Type.ember] = {
        name = "ember",
        tech_name = "ember-caste",
        fear_multiplier = 1.2,
        calorific_demand = 2300,
        power_demand = 5,
        power_bonus = 2,
        no_power_malus = -4,
        favored_taste = Taste.sweet,
        least_favored_taste = Taste.salty,
        desire_for_luxury = 0.1,
        minimum_food_count = 3,
        required_room_count = 1,
        minimum_comfort = 1,
        immigration_threshold = 5,
        immigration_coefficient = 2,
        gender_distribution = {
            [Gender.neutral] = 5,
            [Gender.fale] = 35,
            [Gender.pachin] = 15,
            [Gender.ga] = 45
        }
    },
    [Type.foundry] = {
        name = "foundry",
        tech_name = "foundry-caste",
        fear_multiplier = 0.7,
        calorific_demand = 2800,
        power_demand = 10,
        power_bonus = 2,
        no_power_malus = -8,
        favored_taste = Taste.spicy,
        least_favored_taste = Taste.umami,
        desire_for_luxury = 0.2,
        minimum_food_count = 8,
        required_room_count = 4,
        minimum_comfort = 6,
        immigration_threshold = 5,
        immigration_coefficient = 0.5,
        gender_distribution = {
            [Gender.neutral] = 10,
            [Gender.fale] = 30,
            [Gender.pachin] = 30,
            [Gender.ga] = 30
        }
    },
    [Type.gleam] = {
        name = "gleam",
        tech_name = "gleam-caste",
        fear_multiplier = 1,
        calorific_demand = 2700,
        power_demand = 10,
        power_bonus = 2,
        no_power_malus = -8,
        favored_taste = Taste.spicy,
        least_favored_taste = Taste.umami,
        desire_for_luxury = 0.2,
        minimum_food_count = 4,
        required_room_count = 4,
        minimum_comfort = 4,
        immigration_threshold = 5,
        immigration_coefficient = 0.5,
        gender_distribution = {
            [Gender.neutral] = 10,
            [Gender.fale] = 30,
            [Gender.pachin] = 30,
            [Gender.ga] = 30
        }
    },
    [Type.aurora] = {
        name = "aurora",
        tech_name = "aurora-caste",
        fear_multiplier = 2,
        calorific_demand = 2500,
        power_demand = 35,
        power_bonus = 2,
        no_power_malus = -10,
        favored_taste = Taste.sweet,
        least_favored_taste = Taste.salty,
        desire_for_luxury = 0.5,
        minimum_food_count = 8,
        required_room_count = 10,
        minimum_comfort = 9,
        immigration_threshold = 5,
        immigration_coefficient = 0.2,
        gender_distribution = {
            [Gender.neutral] = 25,
            [Gender.fale] = 25,
            [Gender.pachin] = 25,
            [Gender.ga] = 25
        }
    },
    [Type.plasma] = {
        name = "plasma",
        tech_name = "plasma-caste",
        fear_multiplier = 1,
        calorific_demand = 3000,
        power_demand = 6,
        power_bonus = 2,
        no_power_malus = -3,
        favored_taste = Taste.sour,
        least_favored_taste = Taste.salty,
        desire_for_luxury = 0.2,
        minimum_food_count = 5,
        required_room_count = 3,
        minimum_comfort = 5,
        immigration_threshold = 5,
        immigration_coefficient = 0.8,
        gender_distribution = {
            [Gender.neutral] = 10,
            [Gender.fale] = 40,
            [Gender.pachin] = 20,
            [Gender.ga] = 30
        }
    }
}
local castes = Castes.values

--- The number of people that leave a house per minute if they are unhappy.
Castes.emigration_coefficient = 0.8 / 3600. * -1

--- The number of general garbage an inhabitant produces per minute.
Castes.garbage_coefficient = 0.1 / 3600.

Castes.immigration_age_distribution = {
    
}

-- postprocessing
for _, caste in pairs(Castes.values) do
    -- convert calorific demand to kcal per tick
    -- a day has 25000 ticks according to the wiki
    caste.calorific_demand = caste.calorific_demand / 25000.

    -- convert power demand to J / tick: https://wiki.factorio.com/Types/Energy
    caste.power_demand = caste.power_demand * 1000 / 60

    -- convert immigration coefficients from immigrants per minute
    -- to immigrants per tick
    caste.immigration_coefficient = caste.immigration_coefficient / 3600.
end

local meta = {}

function meta:__call(_type)
    return castes[_type]
end

setmetatable(Castes, meta)

if script and script.active_mods["sosciencity-balancing"] then
    local tech_levels = {
        [1] = {Type.clockwork},
        [2] = {Type.clockwork, Type.orchid},
        [3] = {Type.clockwork, Type.orchid, Type.plasma},
        [4] = {Type.clockwork, Type.orchid, Type.plasma, Type.gunfire, Type.ember},
        [5] = {Type.clockwork, Type.orchid, Type.plasma, Type.gunfire, Type.ember, Type.foundry},
        [6] = {Type.clockwork, Type.orchid, Type.plasma, Type.gunfire, Type.ember, Type.foundry, Type.gleam},
        [7] = {Type.clockwork, Type.orchid, Type.plasma, Type.gunfire, Type.ember, Type.foundry, Type.gleam, Type.aurora}
    }

    for level, caste_array in pairs(tech_levels) do
        local neutral = 0
        local fale = 0
        local pachin = 0
        local ga = 0

        for _, caste in pairs(caste_array) do
            neutral = neutral + castes[caste].gender_distribution[Gender.neutral]
            fale = fale + castes[caste].gender_distribution[Gender.fale]
            pachin = pachin + castes[caste].gender_distribution[Gender.pachin]
            ga = ga + castes[caste].gender_distribution[Gender.ga]
        end

        log(string.format("Level %d: %d neutral, %d fale, %d pachin, %d ga", level, neutral, fale, pachin, ga))
    end
end
