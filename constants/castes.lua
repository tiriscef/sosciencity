local Gender = require("enums.gender")
local Taste = require("enums.taste")
local Type = require("enums.type")

local Time = require("constants.time")

--- Things that define different kinds of people.
local Castes = {}

Castes.values = {
    [Type.clockwork] = {
        name = "clockwork",
        localised_name = {"caste-name.clockwork"},
        localised_name_short = {"caste-short.clockwork"},
        tech_name = "upbringing",
        efficiency_tech = "clockwork-caste-efficiency",
        fear_resilience = 0.5,
        calorific_demand = 3200, -- in kcal per day
        power_demand = 12, -- in kW
        power_bonus = 2,
        no_power_malus = -2,
        garbage_coefficient = 0.1 / Time.minute, -- garbage produced per inhabitant per tick
        water_demand = 4 / Time.minute,
        favored_taste = Taste.umami,
        least_favored_taste = Taste.spicy,
        desire_for_luxury = 0,
        minimum_food_count = 1,
        required_room_count = 1,
        minimum_comfort = 0,
        social_coefficient = 1,
        innate_sanity = 10,
        emigration_threshold = 5,
        emigration_coefficient = 0.1 / Time.minute,
        immigration_genders = {
            [Gender.agender] = 50,
            [Gender.fale] = 25,
            [Gender.pachin] = 5,
            [Gender.ga] = 20
        },
        housing_preferences = {
            ["sheltered"] = 1,
            ["technical"] = 3,
            ["compact"] = 1,
            ["simple"] = 2,
            ["cheap"] = 2,
            ["decorated"] = -1,
            ["green"] = -1,
            ["pompous"] = -1
        },
        accident_disease_resilience = 0.7,
        health_disease_resilience = 0.65,
        sanity_disease_resilience = 0.35
    },
    [Type.orchid] = {
        name = "orchid",
        localised_name = {"caste-name.orchid"},
        localised_name_short = {"caste-short.orchid"},
        tech_name = "upbringing",
        efficiency_tech = "orchid-caste-efficiency",
        fear_resilience = 1,
        calorific_demand = 2800,
        power_demand = 10,
        power_bonus = 2,
        no_power_malus = -1,
        garbage_coefficient = 0.05 / Time.minute,
        water_demand = 6 / Time.minute,
        favored_taste = Taste.fruity,
        least_favored_taste = Taste.acidic,
        desire_for_luxury = 0.2,
        minimum_food_count = 1,
        required_room_count = 1,
        minimum_comfort = 0,
        social_coefficient = 1,
        innate_sanity = 10,
        emigration_threshold = 5,
        emigration_coefficient = 0.1 / Time.minute,
        immigration_genders = {
            [Gender.agender] = 15,
            [Gender.fale] = 5,
            [Gender.pachin] = 60,
            [Gender.ga] = 20
        },
        housing_preferences = {
            ["green"] = 3,
            ["spacey"] = 3,
            ["low"] = 2,
            ["sheltered"] = -1,
            ["technical"] = -3,
            ["compact"] = -1
        },
        accident_disease_resilience = 0.35,
        health_disease_resilience = 0.2,
        sanity_disease_resilience = 0.65
    },
    [Type.gunfire] = {
        name = "gunfire",
        localised_name = {"caste-name.gunfire"},
        localised_name_short = {"caste-short.gunfire"},
        tech_name = "gunfire-caste",
        efficiency_tech = "gunfire-caste-efficiency",
        fear_resilience = 0,
        calorific_demand = 3680,
        power_demand = 2,
        power_bonus = 2,
        no_power_malus = -1,
        garbage_coefficient = 0.04 / Time.minute,
        water_demand = 3 / Time.minute,
        favored_taste = Taste.bitter,
        least_favored_taste = Taste.fruity,
        desire_for_luxury = 0,
        minimum_food_count = 2,
        required_room_count = 0.5,
        minimum_comfort = 0,
        social_coefficient = 0.5,
        innate_sanity = 10,
        emigration_threshold = 5,
        emigration_coefficient = 0.3 / Time.minute,
        immigration_genders = {
            [Gender.agender] = 91,
            [Gender.fale] = 3,
            [Gender.pachin] = 3,
            [Gender.ga] = 3
        },
        housing_preferences = {
            ["sheltered"] = 2.5,
            ["compact"] = 1,
            ["simple"] = 1,
            ["copy-paste"] = 1,
            ["cheap"] = 1,
            ["low"] = 1,
            ["spacey"] = -1,
            ["individualistic"] = -2,
            ["pompous"] = -1,
            ["tall"] = -1
        },
        accident_disease_resilience = 1,
        health_disease_resilience = 0.2,
        sanity_disease_resilience = 1
    },
    [Type.ember] = {
        name = "ember",
        localised_name = {"caste-name.ember"},
        localised_name_short = {"caste-short.ember"},
        tech_name = "upbringing",
        efficiency_tech = "ember-caste-efficiency",
        fear_resilience = 1.2,
        calorific_demand = 2000,
        power_demand = 10,
        power_bonus = 2,
        no_power_malus = -1,
        garbage_coefficient = 0.1 / Time.minute,
        water_demand = 4.5 / Time.minute,
        favored_taste = Taste.fruity,
        least_favored_taste = Taste.salty,
        desire_for_luxury = 0.1,
        minimum_food_count = 1,
        required_room_count = 1,
        minimum_comfort = 0,
        social_coefficient = 2,
        innate_sanity = 10,
        emigration_threshold = 5,
        emigration_coefficient = 0.1 / Time.minute,
        immigration_genders = {
            [Gender.agender] = 5,
            [Gender.fale] = 35,
            [Gender.pachin] = 15,
            [Gender.ga] = 45
        },
        housing_preferences = {
            ["decorated"] = 2.5,
            ["tall"] = 3,
            ["simple"] = -2
        },
        accident_disease_resilience = 0.1,
        health_disease_resilience = 0.8,
        sanity_disease_resilience = 0.6
    },
    [Type.foundry] = {
        name = "foundry",
        localised_name = {"caste-name.foundry"},
        localised_name_short = {"caste-short.foundry"},
        tech_name = "foundry-caste",
        efficiency_tech = "foundry-caste-efficiency",
        fear_resilience = 0.7,
        calorific_demand = 2240,
        power_demand = 10,
        power_bonus = 2,
        no_power_malus = -8,
        garbage_coefficient = 0.15 / Time.minute,
        water_demand = 15 / Time.minute,
        favored_taste = Taste.spicy,
        least_favored_taste = Taste.umami,
        desire_for_luxury = 0.2,
        minimum_food_count = 8,
        required_room_count = 4,
        minimum_comfort = 6,
        social_coefficient = 0.8,
        innate_sanity = 10,
        emigration_threshold = 10,
        emigration_coefficient = 1 / Time.minute,
        immigration_genders = {
            [Gender.agender] = 10,
            [Gender.fale] = 30,
            [Gender.pachin] = 30,
            [Gender.ga] = 30
        },
        housing_preferences = {
            ["technical"] = 2,
            ["spacey"] = 1,
            ["simple"] = 1,
            ["copy-paste"] = 1,
            ["green"] = -2,
            ["individualistic"] = -1,
            ["low"] = -2
        },
        accident_disease_resilience = 0.5,
        health_disease_resilience = 1,
        sanity_disease_resilience = 1
    },
    [Type.gleam] = {
        name = "gleam",
        localised_name = {"caste-name.gleam"},
        localised_name_short = {"caste-short.gleam"},
        tech_name = "gleam-caste",
        efficiency_tech = "gleam-caste-efficiency",
        fear_resilience = 1,
        calorific_demand = 2160,
        power_demand = 10,
        power_bonus = 2,
        no_power_malus = -8,
        garbage_coefficient = 0.25 / Time.minute,
        water_demand = 12 / Time.minute,
        favored_taste = Taste.spicy,
        least_favored_taste = Taste.umami,
        desire_for_luxury = 0.8,
        minimum_food_count = 4,
        required_room_count = 4,
        minimum_comfort = 7,
        social_coefficient = 1.5,
        innate_sanity = 10,
        emigration_threshold = 10,
        emigration_coefficient = 1 / Time.minute,
        immigration_genders = {
            [Gender.agender] = 10,
            [Gender.fale] = 30,
            [Gender.pachin] = 30,
            [Gender.ga] = 30
        },
        housing_preferences = {
            ["spacey"] = 1,
            ["individualistic"] = 1,
            ["pompous"] = 3,
            ["technical"] = -2,
            ["cheap"] = -3
        },
        accident_disease_resilience = 0.2,
        health_disease_resilience = 2,
        sanity_disease_resilience = 2
    },
    [Type.aurora] = {
        name = "aurora",
        localised_name = {"caste-name.aurora"},
        localised_name_short = {"caste-short.aurora"},
        tech_name = "aurora-caste",
        efficiency_tech = "aurora-caste-efficiency",
        fear_resilience = 2,
        calorific_demand = 2000,
        power_demand = 35,
        power_bonus = 2,
        no_power_malus = -10,
        garbage_coefficient = 1 / Time.minute,
        water_demand = 25 / Time.minute,
        favored_taste = Taste.fruity,
        least_favored_taste = Taste.salty,
        desire_for_luxury = 0.5,
        minimum_food_count = 8,
        required_room_count = 10,
        minimum_comfort = 9,
        social_coefficient = 5,
        innate_sanity = 10,
        emigration_threshold = 15,
        emigration_coefficient = 0.8 / Time.minute,
        immigration_genders = {
            [Gender.agender] = 25,
            [Gender.fale] = 25,
            [Gender.pachin] = 25,
            [Gender.ga] = 25
        },
        housing_preferences = {
            ["green"] = 1,
            ["spacey"] = 1,
            ["decorated"] = 1,
            ["individualistic"] = 1,
            ["pompous"] = 1,
            ["sheltered"] = -2,
            ["technical"] = -2,
            ["compact"] = -2,
            ["simple"] = -2,
            ["copy-paste"] = -2,
            ["cheap"] = -5
        },
        accident_disease_resilience = 0.2,
        health_disease_resilience = 1.5,
        sanity_disease_resilience = 1
    },
    [Type.plasma] = {
        name = "plasma",
        localised_name = {"caste-name.plasma"},
        localised_name_short = {"caste-short.plasma"},
        tech_name = "plasma-caste",
        efficiency_tech = "plasma-caste-efficiency",
        fear_resilience = 1,
        calorific_demand = 2400,
        power_demand = 6,
        power_bonus = 2,
        no_power_malus = -3,
        garbage_coefficient = 0.2 / Time.minute,
        water_demand = 7 / Time.minute,
        favored_taste = Taste.acidic,
        least_favored_taste = Taste.salty,
        desire_for_luxury = 0.2,
        minimum_food_count = 4,
        required_room_count = 3,
        minimum_comfort = 3,
        social_coefficient = 1.2,
        innate_sanity = 10,
        emigration_threshold = 7,
        emigration_coefficient = 0.5 / Time.minute,
        immigration_genders = {
            [Gender.agender] = 10,
            [Gender.fale] = 40,
            [Gender.pachin] = 20,
            [Gender.ga] = 30
        },
        housing_preferences = {
            ["green"] = 1,
            ["compact"] = 1,
            ["decorated"] = 2,
            ["individualistic"] = 2,
            ["sheltered"] = -1,
            ["simple"] = -1,
            ["cheap"] = -3
        },
        accident_disease_resilience = 0.2,
        health_disease_resilience = 0.2,
        sanity_disease_resilience = 1.5
    }
}

-- postprocessing
for _, caste in pairs(Castes.values) do
    -- convert calorific demand to kcal per tick
    caste.calorific_demand = caste.calorific_demand / Time.nauvis_day

    -- convert power demand to J / tick: https://wiki.factorio.com/Types/Energy
    caste.power_demand = caste.power_demand * 1000 / Time.second
end

return Castes
