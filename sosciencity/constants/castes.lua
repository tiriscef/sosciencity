require("constants.types")

Caste = {}

Caste.values = {
    [TYPE_CLOCKWORK] = {
        panic_multiplier = 0.5,
        calorific_demand = 4000, -- in kcal per day
        power_demand = 10, -- in kW
        no_power_multiplier = 0.2,
        favored_taste = TASTE_UMAMI,
        least_favored_taste = TASTE_SPICY,
        desire_for_luxority = 0,
        minimum_food_count = 2,
        required_room_count = 1,
        minimum_housing_contentment = 0
    },
    [TYPE_EMBER] = {
        panic_multiplier = 1.2,
        calorific_demand = 2300,
        power_demand = 30,
        no_power_multiplier = 0.8,
        favored_taste = TASTE_SWEET,
        least_favored_taste = TASTE_SALTY,
        desire_for_luxority = 0.1,
        minimum_food_count = 3,
        required_room_count = 1,
        minimum_housing_contentment = 1
    },
    [TYPE_GUNFIRE] = {
        panic_multiplier = 0,
        calorific_demand = 4600,
        power_demand = 25,
        no_power_multiplier = 0.15,
        favored_taste = TASTE_BITTER,
        least_favored_taste = TASTE_SWEET,
        desire_for_luxority = 0,
        minimum_food_count = 2,
        required_room_count = 0.5,
        minimum_housing_contentment = 0
    },
    [TYPE_GLEAM] = {
        panic_multiplier = 1,
        calorific_demand = 2700,
        power_demand = 25,
        no_power_multiplier = 0.9,
        favored_taste = TASTE_SPICY,
        least_favored_taste = TASTE_SOUR,
        desire_for_luxority = 0.3,
        minimum_food_count = 4,
        required_room_count = 1,
        minimum_housing_contentment = 4
    },
    [TYPE_FOUNDRY] = {
        panic_multiplier = 0.7,
        calorific_demand = 2800,
        power_demand = 50,
        no_power_multiplier = 1,
        favored_taste = TASTE_SPICY,
        least_favored_taste = TASTE_SOUR,
        desire_for_luxority = 0.5,
        minimum_food_count = 8,
        required_room_count = 2,
        minimum_housing_contentment = 6
    },
    [TYPE_ORCHID] = {
        panic_multiplier = 2,
        calorific_demand = 2500,
        power_demand = 75,
        no_power_multiplier = 1.5,
        favored_taste = TASTE_SOUR,
        least_favored_taste = TASTE_UMAMI,
        desire_for_luxority = 1,
        minimum_food_count = 10,
        required_room_count = 2,
        minimum_housing_contentment = 8
    },
    [TYPE_AURORA] = {
        panic_multiplier = 2,
        calorific_demand = 2500,
        power_demand = 35,
        no_power_multiplier = 1.5,
        favored_taste = TASTE_SWEET,
        least_favored_taste = TASTE_SALTY,
        desire_for_luxority = 0.8,
        minimum_food_count = 8,
        required_room_count = 10,
        minimum_housing_contentment = 9
    },
    [TYPE_PLASMA] = {
        panic_multiplier = 1,
        calorific_demand = 3000,
        power_demand = 25,
        no_power_multiplier = 0.8,
        favored_taste = TASTE_SWEET,
        least_favored_taste = TASTE_SALTY,
        desire_for_luxority = 0.2,
        minimum_food_count = 5,
        required_room_count = 1,
        minimum_housing_contentment = 5
    }
}

-- postprocessing
for _, caste in pairs(Caste.values) do
    -- convert calorific demand to kcal per tick
    -- a day has 25000 ticks according to the wiki
    caste.calorific_demand = caste.calorific_demand / 25000.

    -- convert power demand to W
    caste.power_demand = caste.power_demand * 1000
end

function Caste:__call(entity)
    -- check if it's a registered entity or a enum
    if type(entity) == "table" then
        return self.values[entity.type]
    else
        return self.values[entity]
    end
end
