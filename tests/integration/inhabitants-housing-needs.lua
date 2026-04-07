local EK = require("enums.entry-key")
local HappinessFactor = require("enums.happiness-factor")
local HealthFactor = require("enums.health-factor")
local HealthSummand = require("enums.health-summand")
local Type = require("enums.type")

local Castes = require("constants.castes")
local DrinkingWater = require("constants.drinking-water")
local Time = require("constants.time")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface

local function setup()
    test_surface = Helpers.create_test_surface()
    Helpers.reset_inhabitants_state()
    storage.technologies["upbringing"] = 1
end

local function teardown()
    Helpers.clean_up()
end

--- Creates a test water distributer, optionally filling it with fluid.
--- water_name and water_quality are set manually because is_active returns false
--- for unpowered test entities, so the creation handler cannot auto-detect water.
--- @param position table
--- @param fluid_name string? DrinkingWater fluid name; nil produces a dry distributer
--- @param fluid_amount number? units to insert, defaults to 10000
--- @return Entry
local function create_water_distributer(position, fluid_name, fluid_amount)
    local entry = Helpers.create_and_register(test_surface, "test-water-distributer", position)
    if fluid_name then
        entry[EK.entity].insert_fluid {name = fluid_name, amount = fluid_amount or 10000}
        entry[EK.water_name] = fluid_name
        entry[EK.water_quality] = DrinkingWater.values[fluid_name].healthiness
    end
    return entry
end

--- Calls evaluate_water on a house entry with fresh factor tables.
--- Returns the three factor/summand tables so tests can inspect them.
--- @param house Entry
--- @param delta_ticks number
--- @return table happiness_factors, table health_factors, table health_summands
local function run_evaluate_water(house, delta_ticks)
    local happiness_factors = {}
    local health_factors = {}
    local health_summands = {}
    Inhabitants.evaluate_water(house, delta_ticks, happiness_factors, health_factors, health_summands)
    return happiness_factors, health_factors, health_summands
end

-- Water demand: castes[Type.clockwork].water_demand = 4 / Time.minute
-- With 10 inhabitants and delta_ticks = Time.minute: water_to_consume = 40

---------------------------------------------------------------------------------------------------
-- << full satisfaction >>

Tirislib.Testing.add_test_case(
    "evaluate_water sets satisfaction to 1 when enough water is available",
    "integration|integration.inhabitants",
    function()
        local house = Inhabitants.try_allow_for_caste(
            Helpers.create_and_register(test_surface, "test-house", {0, 0}), Type.clockwork, false)
        house[EK.inhabitants] = 10

        -- drinkable-water: healthiness = 0.5
        create_water_distributer({5, 0}, "drinkable-water")

        local hf, htf, hs = run_evaluate_water(house, Time.minute)

        Assert.equals(hf[HappinessFactor.thirst], 1, "happiness factor should be 1 with enough water")
        Assert.equals(htf[HealthFactor.thirst], 1, "health factor should be 1 with enough water")
        Assert.equals(hs[HealthSummand.water], DrinkingWater.values["drinkable-water"].healthiness, "health summand should equal water healthiness")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << partial satisfaction >>

Tirislib.Testing.add_test_case(
    "evaluate_water sets partial satisfaction when water supply is insufficient",
    "integration|integration.inhabitants",
    function()
        local house = Inhabitants.try_allow_for_caste(
            Helpers.create_and_register(test_surface, "test-house", {0, 0}), Type.clockwork, false)
        house[EK.inhabitants] = 10

        local supplied = 10
        -- need inhabitants * water_demand * delta_ticks, only supplied available
        create_water_distributer({5, 0}, "drinkable-water", supplied)

        local hf, htf, _ = run_evaluate_water(house, Time.minute)

        local water_demand = Castes.values[Type.clockwork].water_demand
        local expected_satisfaction = supplied / (10 * water_demand * Time.minute)
        Assert.equals(hf[HappinessFactor.thirst], expected_satisfaction, "happiness factor should be supplied/needed")
        Assert.equals(htf[HealthFactor.thirst], expected_satisfaction, "health factor should be supplied/needed")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << no water >>

Tirislib.Testing.add_test_case(
    "evaluate_water sets satisfaction to 0 when no water distributer is present",
    "integration|integration.inhabitants",
    function()
        local house = Inhabitants.try_allow_for_caste(
            Helpers.create_and_register(test_surface, "test-house", {0, 0}), Type.clockwork, false)
        house[EK.inhabitants] = 10

        -- no distributer created

        local hf, htf, hs = run_evaluate_water(house, Time.minute)

        Assert.equals(hf[HappinessFactor.thirst], 0, "happiness factor should be 0 with no water")
        Assert.equals(htf[HealthFactor.thirst], 0, "health factor should be 0 with no water")
        Assert.equals(hs[HealthSummand.water], 0, "health summand should be 0 with no water")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "evaluate_water ignores dry distributers",
    "integration|integration.inhabitants",
    function()
        local house = Inhabitants.try_allow_for_caste(
            Helpers.create_and_register(test_surface, "test-house", {0, 0}), Type.clockwork, false)
        house[EK.inhabitants] = 10

        -- distributer present but water_name = nil (not set = dry)
        create_water_distributer({5, 0}, nil)

        local hf, htf, _ = run_evaluate_water(house, Time.minute)

        Assert.equals(hf[HappinessFactor.thirst], 0, "dry distributer should not count as water supply")
        Assert.equals(htf[HealthFactor.thirst], 0, "dry distributer should not count as water supply")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << zero-inhabitant edge cases >>

Tirislib.Testing.add_test_case(
    "evaluate_water sets satisfaction to 1 for empty house when water distributer is present",
    "integration|integration.inhabitants",
    function()
        local house = Inhabitants.try_allow_for_caste(
            Helpers.create_and_register(test_surface, "test-house", {0, 0}), Type.clockwork, false)
        -- house[EK.inhabitants] is already 0 after try_allow_for_caste

        -- clean-water: healthiness = 2
        create_water_distributer({5, 0}, "clean-water")

        local hf, htf, hs = run_evaluate_water(house, Time.minute)

        Assert.equals(hf[HappinessFactor.thirst], 1, "empty house should report full satisfaction when water is available")
        Assert.equals(htf[HealthFactor.thirst], 1, "empty house should report full satisfaction when water is available")
        Assert.equals(hs[HealthSummand.water], DrinkingWater.values["clean-water"].healthiness, "health summand should reflect clean-water healthiness")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "evaluate_water sets satisfaction to 0 for empty house when no water is available",
    "integration|integration.inhabitants",
    function()
        local house = Inhabitants.try_allow_for_caste(
            Helpers.create_and_register(test_surface, "test-house", {0, 0}), Type.clockwork, false)

        local hf, htf, hs = run_evaluate_water(house, Time.minute)

        Assert.equals(hf[HappinessFactor.thirst], 0, "empty house should report zero satisfaction with no water")
        Assert.equals(htf[HealthFactor.thirst], 0, "empty house should report zero satisfaction with no water")
        Assert.equals(hs[HealthSummand.water], 0, "health summand should be 0 with no water")
    end,
    setup,
    teardown
)
