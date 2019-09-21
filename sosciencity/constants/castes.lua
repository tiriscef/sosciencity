require("constants.types")

caste_values = {
    [TYPE_CLOCKWORK] = {
        panic_multiplier = 0.5,
        calorific_demand = 4000, -- in kcal per day
        power_demand = 10, -- in kW
        no_power_multiplier = 0.2,
        favorite_taste = TASTE_UMAMI,
    },
    [TYPE_EMBER] = {
        panic_multiplier = 1.5,
        calorific_demand = 2300,
        power_demand = 30,
        no_power_multiplier = 0.8,
        favorite_taste = TASTE_SWEET,
    },
    [TYPE_GUNFIRE] = {
        panic_multiplier = 0,
        calorific_demand = 4600,
        power_demand = 25,
        no_power_multiplier = 0.15,
        favorite_taste = TASTE_BITTER,
    },
    [TYPE_GLEAM] = {
        panic_multiplier = 1,
        calorific_demand = 2700,
        power_demand = 25,
        no_power_multiplier = 0.9,
        favorite_taste = TASTE_SPICY,
    },
    [TYPE_FOUNDRY] = {
        panic_multiplier = 0.7,
        calorific_demand = 2800,
        power_demand = 50,
        no_power_multiplier = 1,
        favorite_taste = TASTE_SPICY,
    },
    [TYPE_ORCHID] = {
        panic_multiplier = 2,
        calorific_demand = 2500,
        power_demand = 75,
        no_power_multiplier = 1.5,
        favorite_taste = TASTE_SOUR,
    },
    [TYPE_AURORA] = {
        panic_multiplier = 2,
        calorific_demand = 2500,
        power_demand = 35,
        no_power_multiplier = 1.5,
        favorite_taste = TASTE_SWEET,
    }
}
