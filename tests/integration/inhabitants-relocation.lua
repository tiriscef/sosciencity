local EK = require("enums.entry-key")
local MoveCause = require("enums.move-cause")
local Type = require("enums.type")

local Castes = require("constants.castes")
local InhabitantsConstants = require("constants.inhabitants")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface
local HEALTHY = DiseaseGroup.HEALTHY
local castes = Castes.values
local moving_downtime = InhabitantsConstants.moving_downtime

local function setup()
    test_surface = Helpers.create_test_surface()
    Helpers.reset_inhabitants_state()
    storage.technologies["upbringing"] = 1
end

local function setup_gleam()
    setup()
    storage.technologies["gleam-caste"] = 1
end

local function teardown()
    Helpers.clean_up()
end

local function create_house(position, count)
    return Helpers.create_inhabited_house(test_surface, position, Type.clockwork, count)
end

---------------------------------------------------------------------------------------------------
-- << expire_moving_cohorts >>

Tirislib.Testing.add_test_case(
    "expire_moving_cohorts returns (0, 0) when entry has no cohorts",
    "integration|integration.relocation",
    function()
        local entry = create_house({0, 0}, 10)

        local still, still_healthy = Inhabitants.expire_moving_cohorts(entry)

        Assert.equals(still, 0)
        Assert.equals(still_healthy, 0)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "expire_moving_cohorts removes expired cohorts and returns (0, 0)",
    "integration|integration.relocation",
    function()
        local entry = create_house({0, 0}, 10)
        entry[EK.moving_cohorts] = {
            {count = 5, healthy = 4, expires = game.tick - 1}
        }

        local still, still_healthy = Inhabitants.expire_moving_cohorts(entry)

        Assert.equals(still, 0)
        Assert.equals(still_healthy, 0)
        Assert.is_nil(entry[EK.moving_cohorts], "expired cohorts list should be cleared to nil")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "expire_moving_cohorts keeps active cohorts and returns correct totals",
    "integration|integration.relocation",
    function()
        local entry = create_house({0, 0}, 10)
        entry[EK.moving_cohorts] = {
            {count = 5, healthy = 4, expires = game.tick + 1000}
        }

        local still, still_healthy = Inhabitants.expire_moving_cohorts(entry)

        Assert.equals(still, 5)
        Assert.equals(still_healthy, 4)
        Assert.not_nil(entry[EK.moving_cohorts], "active cohorts should remain")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "expire_moving_cohorts sums only active cohorts when mix of expired and active",
    "integration|integration.relocation",
    function()
        local entry = create_house({0, 0}, 20)
        entry[EK.moving_cohorts] = {
            {count = 3, healthy = 3, expires = game.tick - 1},
            {count = 7, healthy = 5, expires = game.tick + 1000}
        }

        local still, still_healthy = Inhabitants.expire_moving_cohorts(entry)

        Assert.equals(still, 7)
        Assert.equals(still_healthy, 5)
        Assert.equals(#entry[EK.moving_cohorts], 1, "only the active cohort should remain")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << add_to_house >>

Tirislib.Testing.add_test_case(
    "add_to_house registers a cohort with correct count and healthy when downtime > 0",
    "integration|integration.relocation",
    function()
        local dest = create_house({0, 0}, 0)
        local group = InhabitantGroup.new(Type.clockwork, 10)

        Inhabitants.add_to_house(dest, group, MoveCause.pull)

        Assert.not_nil(dest[EK.moving_cohorts], "cohorts should be set")
        local cohort = dest[EK.moving_cohorts][1]
        Assert.not_nil(cohort)
        Assert.equals(cohort.count, 10)
        Assert.equals(cohort.healthy, 10)
        Assert.greater_than(cohort.expires, game.tick)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "add_to_house does not register a cohort when downtime = 0",
    "integration|integration.relocation",
    function()
        local dest = create_house({0, 0}, 0)
        local group = InhabitantGroup.new(Type.clockwork, 10)

        Inhabitants.add_to_house(dest, group, MoveCause.sanatorium_eviction)

        Assert.is_nil(dest[EK.moving_cohorts], "no cohort should be registered for zero downtime")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "add_to_house applies relocation penalty shock to a Gleam house when downtime > 0",
    "integration|integration.relocation",
    function()
        local gleam_house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.gleam, 10)
        gleam_house[EK.happiness] = 10.0
        local shock = castes[Type.gleam].relocation_penalty.shock

        local group = InhabitantGroup.new(Type.gleam, 5)
        Inhabitants.add_to_house(gleam_house, group, MoveCause.pull)

        Assert.equals(gleam_house[EK.happiness], math.max(0, 10.0 - shock))
    end,
    setup_gleam,
    teardown
)

Tirislib.Testing.add_test_case(
    "add_to_house does not apply relocation penalty when downtime = 0",
    "integration|integration.relocation",
    function()
        local gleam_house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.gleam, 10)
        gleam_house[EK.happiness] = 10.0

        local group = InhabitantGroup.new(Type.gleam, 5)
        Inhabitants.add_to_house(gleam_house, group, MoveCause.sanatorium_eviction)

        Assert.equals(gleam_house[EK.happiness], 10.0, "no shock should apply when downtime = 0")
    end,
    setup_gleam,
    teardown
)

Tirislib.Testing.add_test_case(
    "add_to_house updates free space status after adding inhabitants",
    "integration|integration.relocation",
    function()
        local dest = create_house({0, 0}, 0)
        -- register as free before add
        Inhabitants.update_free_space_status(dest)
        local caste_id = dest[EK.type]
        local unit_number = dest[EK.unit_number]
        Assert.not_nil(storage.free_houses[false][caste_id][unit_number], "should be in free registry before add")

        -- fill to capacity
        local group = InhabitantGroup.new(Type.clockwork, 200)
        Inhabitants.add_to_house(dest, group, MoveCause.sanatorium_eviction)

        Assert.is_nil(storage.free_houses[false][caste_id][unit_number], "should be removed from free registry when full")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << take_from_house: moving cohort scaling >>

Tirislib.Testing.add_test_case(
    "take_from_house scales active cohorts proportionally when taking half the inhabitants",
    "integration|integration.relocation",
    function()
        local house = create_house({0, 0}, 20)
        house[EK.moving_cohorts] = {
            {count = 10, healthy = 8, expires = game.tick + 1000}
        }

        Inhabitants.take_from_house(house, 10, nil)

        Assert.not_nil(house[EK.moving_cohorts])
        local cohort = house[EK.moving_cohorts][1]
        -- remaining = 10, scale = 10/20 = 0.5; floor(10 * 0.5) = 5, floor(8 * 0.5) = 4
        Assert.equals(cohort.count, 5)
        Assert.equals(cohort.healthy, 4)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "take_from_house clears all cohorts when taking all inhabitants",
    "integration|integration.relocation",
    function()
        local house = create_house({0, 0}, 20)
        house[EK.moving_cohorts] = {
            {count = 10, healthy = 8, expires = game.tick + 1000}
        }

        Inhabitants.take_from_house(house, 20, nil)

        Assert.is_nil(house[EK.moving_cohorts], "cohorts should be cleared when all inhabitants taken")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "take_from_house works correctly when no cohorts exist",
    "integration|integration.relocation",
    function()
        local house = create_house({0, 0}, 10)

        Inhabitants.take_from_house(house, 5, nil)

        Assert.is_nil(house[EK.moving_cohorts], "no cohorts should appear when none existed")
        Assert.equals(house[EK.inhabitants], 5)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << pull_to_house >>

Tirislib.Testing.add_test_case(
    "pull_to_house pulls healthy inhabitants from a lower-priority source",
    "integration|integration.relocation",
    function()
        local target = create_house({0, 0}, 0)
        target[EK.housing_priority] = 10

        local source = create_house({5, 0}, 20)
        source[EK.housing_priority] = 5

        Inhabitants.pull_to_house(target, false)

        Assert.greater_than(target[EK.inhabitants], 0, "target should have received inhabitants")
        Assert.less_than(source[EK.inhabitants], 20, "source should have lost inhabitants")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "pull_to_house does not pull from a sanatorium",
    "integration|integration.relocation",
    function()
        local target = create_house({0, 0}, 0)
        target[EK.housing_priority] = 10

        local sanatorium = create_house({5, 0}, 20)
        sanatorium[EK.housing_priority] = 5
        sanatorium[EK.is_sanatorium] = true

        Inhabitants.pull_to_house(target, false)

        Assert.equals(target[EK.inhabitants], 0, "pull should not take from a sanatorium")
        Assert.equals(sanatorium[EK.inhabitants], 20, "sanatorium inhabitants should be untouched")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "pull_to_house does not pull from itself",
    "integration|integration.relocation",
    function()
        local house = create_house({0, 0}, 10)
        house[EK.housing_priority] = 10
        local inhabitants_before = house[EK.inhabitants]

        Inhabitants.pull_to_house(house, false)

        Assert.equals(house[EK.inhabitants], inhabitants_before, "house should not take from itself")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "pull_to_house with all_sources=false does not pull from higher-priority source",
    "integration|integration.relocation",
    function()
        local target = create_house({0, 0}, 0)
        target[EK.housing_priority] = 5

        local source = create_house({5, 0}, 20)
        source[EK.housing_priority] = 10

        Inhabitants.pull_to_house(target, false)

        Assert.equals(target[EK.inhabitants], 0, "should not pull from higher-priority source without all_sources")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "pull_to_house with all_sources=true pulls from higher-priority source",
    "integration|integration.relocation",
    function()
        local target = create_house({0, 0}, 0)
        target[EK.housing_priority] = 5

        local source = create_house({5, 0}, 20)
        source[EK.housing_priority] = 10

        Inhabitants.pull_to_house(target, true)

        Assert.greater_than(target[EK.inhabitants], 0, "all_sources=true should pull from any non-sanatorium house")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "pull_to_house returns 0 when target is already full",
    "integration|integration.relocation",
    function()
        local target = create_house({0, 0}, 200)
        target[EK.housing_priority] = 10

        local source = create_house({5, 0}, 20)
        source[EK.housing_priority] = 5

        local pulled = Inhabitants.pull_to_house(target, true)

        Assert.equals(pulled, 0, "should return 0 when target house is full")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << push_from_house >>

Tirislib.Testing.add_test_case(
    "push_from_house empties the source house",
    "integration|integration.relocation",
    function()
        local source = create_house({0, 0}, 20)
        local dest = create_house({5, 0}, 0)
        Inhabitants.update_free_space_status(dest)

        Inhabitants.push_from_house(source)

        Assert.equals(source[EK.inhabitants], 0, "source house should be empty after push")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "push_from_house distributes inhabitants to a free destination house",
    "integration|integration.relocation",
    function()
        local source = create_house({0, 0}, 20)
        local dest = create_house({5, 0}, 0)
        Inhabitants.update_free_space_status(dest)

        Inhabitants.push_from_house(source)

        Assert.greater_than(dest[EK.inhabitants], 0, "destination should have received pushed inhabitants")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << validate_employment_capacity >>

Tirislib.Testing.add_test_case(
    "validate_employment_capacity reduces employed count when it exceeds available capacity",
    "integration|integration.relocation",
    function()
        local entry = create_house({0, 0}, 10)
        entry[EK.employed] = 15
        entry[EK.employments] = {}
        entry[EK.strike_level] = 0
        -- healthy = 10, moving_healthy = 0, willing = 1.0 → available = 10, excess = 5

        Inhabitants.validate_employment_capacity(entry, 0)

        Assert.equals(entry[EK.employed], 10, "excess workers should be fired to match available capacity")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "validate_employment_capacity accounts for moving_healthy when capping employment",
    "integration|integration.relocation",
    function()
        local entry = create_house({0, 0}, 10)
        entry[EK.employed] = 8
        entry[EK.employments] = {}
        entry[EK.strike_level] = 0
        -- healthy = 10, moving_healthy = 6, willing = 1.0 → available = 4, excess = 4

        Inhabitants.validate_employment_capacity(entry, 6)

        Assert.equals(entry[EK.employed], 4, "employment should be capped by (healthy - moving_healthy)")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "validate_employment_capacity does nothing when employment is within bounds",
    "integration|integration.relocation",
    function()
        local entry = create_house({0, 0}, 10)
        entry[EK.employed] = 8
        entry[EK.employments] = {}
        entry[EK.strike_level] = 0
        -- healthy = 10, moving_healthy = 0, willing = 1.0 → available = 10, no excess

        Inhabitants.validate_employment_capacity(entry, 0)

        Assert.equals(entry[EK.employed], 8, "employed count should be unchanged when within capacity")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << caste points suppression >>

Tirislib.Testing.add_test_case(
    "update_housing_census gives full caste points when moving_still = 0",
    "integration|integration.relocation",
    function()
        local entry = create_house({0, 0}, 10)
        entry[EK.happiness] = 15.0
        entry[EK.strike_level] = 0
        entry[EK.caste_points] = 0
        storage.caste_points[Type.clockwork] = 0

        Inhabitants.update_housing_census(entry, 0)

        Assert.greater_than(entry[EK.caste_points], 0, "should have positive caste points")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "update_housing_census scales caste points proportionally by (inhabitants - moving_still) / inhabitants",
    "integration|integration.relocation",
    function()
        local entry = create_house({0, 0}, 10)
        entry[EK.happiness] = 15.0
        entry[EK.strike_level] = 0

        -- get baseline with no moving
        entry[EK.caste_points] = 0
        storage.caste_points[Type.clockwork] = 0
        Inhabitants.update_housing_census(entry, 0)
        local base_points = entry[EK.caste_points]

        -- get scaled points with 5 moving (half the inhabitants)
        Inhabitants.update_housing_census(entry, 5)
        local scaled_points = entry[EK.caste_points]

        Assert.less_than(scaled_points, base_points, "moving inhabitants should reduce caste points")
        Assert.equals(scaled_points, base_points * 0.5, "caste points should scale by (10-5)/10 = 0.5")
    end,
    setup,
    teardown
)
