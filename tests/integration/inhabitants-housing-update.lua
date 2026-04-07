local EK = require("enums.entry-key")
local Type = require("enums.type")
local HappinessSummand = require("enums.happiness-summand")
local SanitySummand = require("enums.sanity-summand")

local Castes = require("constants.castes")
local Housing = require("constants.housing")
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

---------------------------------------------------------------------------------------------------
-- << happiness/health/sanity convergence >>

Tirislib.Testing.add_test_case(
    "Housing update converges happiness toward nominal",
    "integration|integration.inhabitants",
    function()
        local entry = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 10)

        entry[EK.happiness] = 0

        Inhabitants.update_happiness(entry, 10, 100)

        -- happiness should have moved toward nominal (increased from 0)
        Assert.greater_than(entry[EK.happiness], 0, "happiness should have increased from 0")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Housing update converges health toward nominal",
    "integration|integration.inhabitants",
    function()
        local entry = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 10)

        entry[EK.health] = 0

        Inhabitants.update_health(entry, 10, 100)

        Assert.greater_than(entry[EK.health], 0, "health should have increased from 0")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Housing update converges sanity toward nominal",
    "integration|integration.inhabitants",
    function()
        local entry = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 10)

        entry[EK.sanity] = 0

        Inhabitants.update_sanity(entry, 10, 100)

        Assert.greater_than(entry[EK.sanity], 0, "sanity should have increased from 0")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << update_housing_census >>

Tirislib.Testing.add_test_case(
    "update_housing_census syncs population count",
    "integration|integration.inhabitants",
    function()
        local entry = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 10)

        -- manually add more inhabitants without updating census
        local group = InhabitantGroup.new(Type.clockwork, 5)
        InhabitantGroup.merge(entry, group)
        -- now entry has 15 inhabitants but official_inhabitants is still 10

        Inhabitants.update_housing_census(entry)

        Assert.equals(entry[EK.official_inhabitants], 15, "official_inhabitants should be synced")
        Assert.equals(storage.population[Type.clockwork], 15, "storage.population should reflect 15")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "update_housing_census updates caste_points",
    "integration|integration.inhabitants",
    function()
        local entry = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 10)

        Inhabitants.update_housing_census(entry)

        Assert.not_nil(entry[EK.caste_points], "entry should have caste_points")
        -- with 10 healthy unemployed inhabitants and default happiness,
        -- caste_points should be > 0
        Assert.greater_than(entry[EK.caste_points], 0, "caste_points should be positive")
        Assert.greater_than(storage.caste_points[Type.clockwork], 0, "global caste_points should be positive")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << garbage >>

Tirislib.Testing.add_test_case(
    "Garbage progress advances with inhabitants",
    "integration|integration.inhabitants",
    function()
        local entry = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 10)

        local progress_before = entry[EK.garbage_progress]

        Register.update_entry(entry, game.tick + 100)

        -- garbage_progress should have increased (inhabitants produce garbage)
        Assert.greater_than(entry[EK.garbage_progress], progress_before,
            "garbage progress should advance with inhabitants")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << emigration >>

Tirislib.Testing.add_test_case(
    "Emigration trend increases when happiness is very low",
    "integration|integration.inhabitants",
    function()
        local entry = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 10)

        -- force happiness to 0 — well below any emigration threshold
        entry[EK.happiness] = 0

        Register.update_entry(entry, game.tick + 100)

        Assert.greater_than(entry[EK.emigration_trend], 0,
            "emigration trend should increase with zero happiness")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "No emigration trend when happiness is high",
    "integration|integration.inhabitants",
    function()
        local entry = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 10)

        -- force happiness well above any emigration threshold
        entry[EK.happiness] = 50

        Register.update_entry(entry, game.tick + 100)

        Assert.equals(entry[EK.emigration_trend], 0,
            "emigration trend should be 0 when happiness is high")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << ages >>

Tirislib.Testing.add_test_case(
    "update_ages shifts ages after a week passes",
    "integration|integration.inhabitants",
    function()
        local entry = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 10)

        -- set last_age_shift far in the past (more than a week ago)
        entry[EK.last_age_shift] = game.tick - 2 * Time.nauvis_week

        -- all inhabitants start at age 0
        local ages_before = Tirislib.Tables.copy(entry[EK.ages])

        Inhabitants.update_ages(entry)

        -- ages should have shifted
        Assert.unequal(entry[EK.ages], ages_before, "ages should have changed after a week")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << fear >>

Tirislib.Testing.add_test_case(
    "Fear creates a happiness malus",
    "integration|integration.inhabitants",
    function()
        local entry = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 10)

        -- set fear to a significant value
        storage.fear = -20

        Register.update_entry(entry, game.tick + 100)

        -- the fear happiness summand should be negative
        Assert.less_than(entry[EK.happiness_summands][HappinessSummand.fear], 0,
            "fear summand should be negative when fear is present")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << evaluate_housing >>

Tirislib.Testing.add_test_case(
    "evaluate_housing sets comfort summand from housing definition",
    "integration|integration.inhabitants",
    function()
        local entry = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 10)

        local caste = Castes.values[Type.clockwork]
        Inhabitants.evaluate_housing(entry, entry[EK.happiness_summands], entry[EK.sanity_summands], caste)

        local comfort = Housing.values["test-house"].comfort
        Assert.equals(entry[EK.happiness_summands][HappinessSummand.housing], comfort,
            "housing comfort summand should match test-house comfort value")
        Assert.equals(entry[EK.sanity_summands][SanitySummand.housing], comfort,
            "sanity housing summand should match test-house comfort value")
    end,
    setup,
    teardown
)
