require("constants.enums")

--- Things that define different kinds of people.
Caste = {}

Caste.values = {
    [Type.clockwork] = {
        name = "clockwork",
        tech_name = "clockwork-caste",
        fear_multiplier = 0.5,
        calorific_demand = 4000, -- in kcal per day
        power_demand = 10, -- in kW
        power_bonus = 2,
        no_power_malus = -1,
        favored_taste = Taste.umami,
        least_favored_taste = Taste.spicy,
        desire_for_luxury = 0,
        minimum_food_count = 2,
        required_room_count = 1,
        minimum_comfort = 0,
        immigration_threshold = 5,
        immigration_coefficient = 1.5, -- immigrants per minute
        idea_threshold = 5,
        idea_coefficient = 0.04, -- idea-items per minute per inhabitant
        idea_item = "note"
    },
    [Type.orchid] = {
        name = "orchid",
        tech_name = "orchid-caste",
        fear_multiplier = 1,
        calorific_demand = 3500,
        power_demand = 15,
        power_bonus = 2,
        no_power_malus = -2,
        favored_taste = Taste.sour,
        least_favored_taste = Taste.umami,
        desire_for_luxury = 1,
        minimum_food_count = 10,
        required_room_count = 1,
        minimum_comfort = 8,
        immigration_threshold = 5,
        immigration_coefficient = 1.1,
        idea_threshold = 5,
        idea_coefficient = 0.04,
        idea_item = "essay"
    },
    [Type.gunfire] = {
        name = "gunfire",
        tech_name = "gunfire-caste",
        fear_multiplier = 0,
        calorific_demand = 4600,
        power_demand = 25,
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
        idea_threshold = 5,
        idea_coefficient = 0.04,
        idea_item = "strategic-considerations"
    },
    [Type.ember] = {
        name = "ember",
        tech_name = "ember-caste",
        fear_multiplier = 1.2,
        calorific_demand = 2300,
        power_demand = 30,
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
        idea_threshold = 5,
        idea_coefficient = 0.01,
        idea_item = "sketchbook"
    },
    [Type.foundry] = {
        name = "foundry",
        tech_name = "foundry-caste",
        fear_multiplier = 0.7,
        calorific_demand = 2800,
        power_demand = 50,
        power_bonus = 2,
        no_power_malus = -8,
        favored_taste = Taste.spicy,
        least_favored_taste = Taste.sour,
        desire_for_luxury = 0.5,
        minimum_food_count = 8,
        required_room_count = 4,
        minimum_comfort = 6,
        immigration_threshold = 5,
        immigration_coefficient = 0.5,
        idea_threshold = 5,
        idea_coefficient = 0.2,
        idea_item = "complex-scientific-data"
    },
    [Type.gleam] = {
        name = "gleam",
        tech_name = "gleam-caste",
        fear_multiplier = 1,
        calorific_demand = 2700,
        power_demand = 25,
        power_bonus = 2,
        no_power_malus = -8,
        favored_taste = Taste.spicy,
        least_favored_taste = Taste.sour,
        desire_for_luxury = 0.3,
        minimum_food_count = 4,
        required_room_count = 4,
        minimum_comfort = 4,
        immigration_threshold = 5,
        immigration_coefficient = 0.5,
        idea_threshold = 5,
        idea_coefficient = 0.2,
        idea_item = "published-paper"
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
        desire_for_luxury = 0.8,
        minimum_food_count = 8,
        required_room_count = 10,
        minimum_comfort = 9,
        immigration_threshold = 5,
        immigration_coefficient = 0.2,
        idea_threshold = 5,
        idea_coefficient = 0.5,
        idea_item = "well-funded-scientific-thesis"
    },
    [Type.plasma] = {
        name = "plasma",
        tech_name = "plasma-caste",
        fear_multiplier = 1,
        calorific_demand = 3000,
        power_demand = 25,
        power_bonus = 2,
        no_power_malus = -3,
        favored_taste = Taste.sweet,
        least_favored_taste = Taste.salty,
        desire_for_luxury = 0.2,
        minimum_food_count = 5,
        required_room_count = 3,
        minimum_comfort = 5,
        immigration_threshold = 5,
        immigration_coefficient = 0.8
    }
}
local castes = Caste.values

function Caste.produces_ideas(caste)
    return caste.idea_item ~= nil
end

--- The number of people that leave a house per minute if they are unhappy.
Caste.emigration_coefficient = 0.8

--- The number of general garbage an inhabitant produces per minute.
Caste.garbage_coefficient = 0.1

-- postprocessing
for _, caste in pairs(Caste.values) do
    -- convert calorific demand to kcal per tick
    -- a day has 25000 ticks according to the wiki
    caste.calorific_demand = caste.calorific_demand / 25000.

    -- convert power demand to J / tick: https://wiki.factorio.com/Types/Energy
    caste.power_demand = caste.power_demand * 1000 / 60

    -- convert immigration coefficients from immigrants per minute
    -- to immigrants per tick
    caste.immigration_coefficient = caste.immigration_coefficient / 3600.

    -- same with the other coefficients
    if caste.idea_coefficient then
        caste.idea_coefficient = caste.idea_coefficient / 3600.
    end
end
Caste.emigration_coefficient = Caste.emigration_coefficient / 3600. * -1
Caste.garbage_coefficient = Caste.garbage_coefficient / 3600.

local meta = {}

function meta:__call(_type)
    return castes[_type]
end

setmetatable(Caste, meta)
