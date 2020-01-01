require("constants.types")

Caste = {}

Caste.values = {
    [TYPE_CLOCKWORK] = {
        name = "clockwork",
        fear_multiplier = 0.5,
        calorific_demand = 4000, -- in kcal per day
        power_demand = 10, -- in kW
        power_bonus = 2,
        no_power_malus = -1,
        favored_taste = TASTE_UMAMI,
        least_favored_taste = TASTE_SPICY,
        desire_for_luxury = 0,
        minimum_food_count = 2,
        required_room_count = 1,
        minimum_comfort = 0,
        influx_threshold = 0,
        idea_threshold = 5
    },
    [TYPE_ORCHID] = {
        name = "orchid",
        fear_multiplier = 1,
        calorific_demand = 3500,
        power_demand = 15,
        power_bonus = 2,
        no_power_malus = -2,
        favored_taste = TASTE_SOUR,
        least_favored_taste = TASTE_UMAMI,
        desire_for_luxury = 1,
        minimum_food_count = 10,
        required_room_count = 1,
        minimum_comfort = 8,
        influx_threshold = 5,
        idea_threshold = 5
    },
    [TYPE_GUNFIRE] = {
        name = "gunfire",
        fear_multiplier = 0,
        calorific_demand = 4600,
        power_demand = 25,
        power_bonus = 2,
        no_power_malus = -1,
        favored_taste = TASTE_BITTER,
        least_favored_taste = TASTE_SWEET,
        desire_for_luxury = 0,
        minimum_food_count = 2,
        required_room_count = 0.5,
        minimum_comfort = 0,
        influx_threshold = 5,
        idea_threshold = 5
    },
    [TYPE_EMBER] = {
        name = "ember",
        fear_multiplier = 1.2,
        calorific_demand = 2300,
        power_demand = 30,
        power_bonus = 2,
        no_power_malus = -4,
        favored_taste = TASTE_SWEET,
        least_favored_taste = TASTE_SALTY,
        desire_for_luxury = 0.1,
        minimum_food_count = 3,
        required_room_count = 1,
        minimum_comfort = 1,
        influx_threshold = 5,
        idea_threshold = 5
    },
    [TYPE_FOUNDRY] = {
        name = "foundry",
        fear_multiplier = 0.7,
        calorific_demand = 2800,
        power_demand = 50,
        power_bonus = 2,
        no_power_malus = -8,
        favored_taste = TASTE_SPICY,
        least_favored_taste = TASTE_SOUR,
        desire_for_luxury = 0.5,
        minimum_food_count = 8,
        required_room_count = 4,
        minimum_comfort = 6,
        influx_threshold = 5,
        idea_threshold = 5
    },
    [TYPE_GLEAM] = {
        name = "gleam",
        fear_multiplier = 1,
        calorific_demand = 2700,
        power_demand = 25,
        power_bonus = 2,
        no_power_malus = -8,
        favored_taste = TASTE_SPICY,
        least_favored_taste = TASTE_SOUR,
        desire_for_luxury = 0.3,
        minimum_food_count = 4,
        required_room_count = 4,
        minimum_comfort = 4,
        influx_threshold = 5,
        idea_threshold = 5
    },
    [TYPE_AURORA] = {
        name = "aurora",
        fear_multiplier = 2,
        calorific_demand = 2500,
        power_demand = 35,
        power_bonus = 2,
        no_power_malus = -10,
        favored_taste = TASTE_SWEET,
        least_favored_taste = TASTE_SALTY,
        desire_for_luxury = 0.8,
        minimum_food_count = 8,
        required_room_count = 10,
        minimum_comfort = 9,
        influx_threshold = 5,
        idea_threshold = 5
    },
    [TYPE_PLASMA] = {
        name = "plasma",
        fear_multiplier = 1,
        calorific_demand = 3000,
        power_demand = 25,
        power_bonus = 2,
        no_power_malus = -3,
        favored_taste = TASTE_SWEET,
        least_favored_taste = TASTE_SALTY,
        desire_for_luxury = 0.2,
        minimum_food_count = 5,
        required_room_count = 3,
        minimum_comfort = 5,
        influx_threshold = 5,
        idea_threshold = 5
    }
}
local castes = Caste.values

-- postprocessing
for _, caste in pairs(Caste.values) do
    -- convert calorific demand to kcal per tick
    -- a day has 25000 ticks according to the wiki
    caste.calorific_demand = caste.calorific_demand / 25000.

    -- convert power demand to W
    caste.power_demand = caste.power_demand * 1000
end

local meta = {}

function meta:__call(_type)
    return castes[_type]
end

setmetatable(Caste, meta)
