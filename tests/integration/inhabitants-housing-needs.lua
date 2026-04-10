local EK = require("enums.entry-key")
local HappinessFactor = require("enums.happiness-factor")
local HealthFactor = require("enums.health-factor")
local HealthSummand = require("enums.health-summand")
local Type = require("enums.type")

local Biology = require("constants.biology")
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

        Assert.is_nil(hf[HappinessFactor.thirst], "happiness factor should be absent (neutral) with enough water")
        Assert.is_nil(htf[HealthFactor.thirst], "health factor should be absent (neutral) with enough water")
        Assert.equals(hs[HealthSummand.water], DrinkingWater.values["drinkable-water"].healthiness, "health summand should equal water healthiness")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << partial satisfaction >>

Tirislib.Testing.add_test_case(
    "evaluate_water treats partial water supply as satisfied (binary)",
    "integration|integration.inhabitants",
    function()
        local house = Inhabitants.try_allow_for_caste(
            Helpers.create_and_register(test_surface, "test-house", {0, 0}), Type.clockwork, false)
        house[EK.inhabitants] = 10

        -- supply less than needed — any nonzero satisfaction counts as "has water"
        create_water_distributer({5, 0}, "drinkable-water", 10)

        local hf, htf, _ = run_evaluate_water(house, Time.minute)

        Assert.is_nil(hf[HappinessFactor.thirst], "happiness factor should be absent (neutral) when water is available")
        Assert.is_nil(htf[HealthFactor.thirst], "health factor should be absent (neutral) when water is available")
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

        Assert.equals(hf[HappinessFactor.thirst], Biology.dehydration.happiness_factor, "happiness factor should be dehydration floor with no water")
        Assert.equals(htf[HealthFactor.thirst], Biology.dehydration.health_factor, "health factor should be dehydration floor with no water")
        Assert.is_nil(hs[HealthSummand.water], "health summand should be absent when water quality is 0")
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

        Assert.equals(hf[HappinessFactor.thirst], Biology.dehydration.happiness_factor, "dry distributer should not count as water supply")
        Assert.equals(htf[HealthFactor.thirst], Biology.dehydration.health_factor, "dry distributer should not count as water supply")
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

        Assert.is_nil(hf[HappinessFactor.thirst], "happiness factor should be absent (neutral) when water is available")
        Assert.is_nil(htf[HealthFactor.thirst], "health factor should be absent (neutral) when water is available")
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

        Assert.equals(hf[HappinessFactor.thirst], Biology.dehydration.happiness_factor, "empty house with no water should return dehydration floor")
        Assert.equals(htf[HealthFactor.thirst], Biology.dehydration.health_factor, "empty house with no water should return dehydration floor")
        Assert.is_nil(hs[HealthSummand.water], "health summand should be absent when water quality is 0")
    end,
    setup,
    teardown
)
