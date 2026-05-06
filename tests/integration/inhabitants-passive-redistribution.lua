local EK = require("enums.entry-key")
local MoveCause = require("enums.move-cause")
local Type = require("enums.type")

local TechEffects = require("constants.tech-effects")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface
local HEALTHY = DiseaseGroup.HEALTHY

local function setup()
    test_surface = Helpers.create_test_surface()
    Helpers.reset_inhabitants_state()
    storage.technologies["upbringing"] = 1
    storage.technologies["passive-redistribution"] = true
    -- passive_redistribution_enabled is set to true by Inhabitants.init()
end

local function teardown()
    Helpers.clean_up()
end

-- Creates a clockwork house at position with count inhabitants and the given priority.
local function make_house(position, count, priority)
    local entry = Helpers.create_inhabited_house(test_surface, position, Type.clockwork, count)
    entry[EK.housing_priority] = priority
    return entry
end

---------------------------------------------------------------------------------------------------
-- << gate conditions >>

Tirislib.Testing.add_test_case(
    "passive_redistribution_pass does nothing when disabled",
    "integration|integration.passive-redistribution",
    function()
        local high = make_house({0, 0}, 0, 10)
        local low  = make_house({5, 0}, 100, 5)

        storage.passive_redistribution_enabled = false
        Inhabitants.passive_redistribution_pass()

        Assert.equals(high[EK.inhabitants], 0, "disabled pass should not move any inhabitants")
        Assert.equals(low[EK.inhabitants], 100)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "passive_redistribution_pass does nothing when tech is not researched",
    "integration|integration.passive-redistribution",
    function()
        local high = make_house({0, 0}, 0, 10)
        local low  = make_house({5, 0}, 100, 5)

        storage.technologies["passive-redistribution"] = false
        Inhabitants.passive_redistribution_pass()

        Assert.equals(high[EK.inhabitants], 0, "unresearched pass should not move any inhabitants")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << movement direction >>

Tirislib.Testing.add_test_case(
    "passive_redistribution_pass moves inhabitants from lower-priority to higher-priority vacancy",
    "integration|integration.passive-redistribution",
    function()
        local high = make_house({0, 0}, 0, 10)
        local low  = make_house({5, 0}, 100, 5)

        Inhabitants.passive_redistribution_pass()

        Assert.greater_than(high[EK.inhabitants], 0, "high-priority house should receive inhabitants")
        Assert.less_than(low[EK.inhabitants], 100, "low-priority house should lose inhabitants")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "passive_redistribution_pass does not move inhabitants between equal-priority houses",
    "integration|integration.passive-redistribution",
    function()
        local a = make_house({0, 0}, 0, 5)
        local b = make_house({5, 0}, 100, 5)

        Inhabitants.passive_redistribution_pass()

        Assert.equals(a[EK.inhabitants], 0, "equal-priority houses should not be redistributed")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "passive_redistribution_pass does not take from a higher-priority house to fill a lower-priority vacancy",
    "integration|integration.passive-redistribution",
    function()
        local low_vacant  = make_house({0, 0}, 0, 5)
        local high_full   = make_house({5, 0}, 100, 10)

        Inhabitants.passive_redistribution_pass()

        Assert.equals(low_vacant[EK.inhabitants], 0, "low-priority vacant house should not receive inhabitants from a higher-priority donor")
        Assert.equals(high_full[EK.inhabitants], 100, "high-priority full house should not be drained")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << exclusions >>

Tirislib.Testing.add_test_case(
    "passive_redistribution_pass does not take inhabitants from a sanatorium",
    "integration|integration.passive-redistribution",
    function()
        local high       = make_house({0, 0}, 0, 10)
        local sanatorium = make_house({5, 0}, 100, 5)
        sanatorium[EK.is_sanatorium] = true

        Inhabitants.passive_redistribution_pass()

        Assert.equals(high[EK.inhabitants], 0, "sanatorium inhabitants should not be redistributed")
        Assert.equals(sanatorium[EK.inhabitants], 100)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << budget >>

Tirislib.Testing.add_test_case(
    "passive_redistribution_pass moves exactly floor(population * base_fraction) inhabitants",
    "integration|integration.passive-redistribution",
    function()
        -- With 100 inhabitants and the base fraction (0.02), budget = floor(100 * 0.02) = 2.
        local high = make_house({0, 0}, 0, 10)
        local low  = make_house({5, 0}, 100, 5)

        local base_fraction = TechEffects.redistribution_budget_fractions[0]
        local expected_budget = math.floor(100 * base_fraction)

        Inhabitants.passive_redistribution_pass()

        Assert.equals(high[EK.inhabitants], expected_budget,
            "exactly the budget should be moved to the high-priority house")
        Assert.equals(low[EK.inhabitants], 100 - expected_budget)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "passive_redistribution_pass budget does not exceed total across multiple source houses",
    "integration|integration.passive-redistribution",
    function()
        -- Three low-priority donors; budget should still be capped at floor(population * fraction).
        local high  = make_house({0, 0},  0,  10)
        local low1  = make_house({5, 0},  50,  3)
        local low2  = make_house({10, 0}, 50,  3)
        local total = 100

        local base_fraction = TechEffects.redistribution_budget_fractions[0]
        local expected_budget = math.floor(total * base_fraction)

        Inhabitants.passive_redistribution_pass()

        local moved = high[EK.inhabitants]
        Assert.equals(moved, expected_budget,
            "total moved should not exceed the budget even with multiple donors")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << cohort registration >>

Tirislib.Testing.add_test_case(
    "passive_redistribution_pass registers a moving cohort on the destination house",
    "integration|integration.passive-redistribution",
    function()
        local high = make_house({0, 0}, 0, 10)
        local low  = make_house({5, 0}, 100, 5)

        Inhabitants.passive_redistribution_pass()

        Assert.not_nil(high[EK.moving_cohorts], "destination should have a moving cohort")
        local cohort = high[EK.moving_cohorts][1]
        Assert.not_nil(cohort)
        Assert.greater_than(cohort.expires, game.tick, "cohort should expire in the future")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "passive_redistribution_pass registers cohort with penalized = true",
    "integration|integration.passive-redistribution",
    function()
        local high = make_house({0, 0}, 0, 10)
        local low  = make_house({5, 0}, 100, 5)

        Inhabitants.passive_redistribution_pass()

        local cohort = high[EK.moving_cohorts][1]
        Assert.is_true(cohort.penalized,
            "passive redistribution is a forced relocation and should carry the relocation penalty")
    end,
    setup,
    teardown
)
