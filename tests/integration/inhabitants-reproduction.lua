local EK = require("enums.entry-key")
local Type = require("enums.type")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface

local function setup()
    test_surface = Helpers.create_test_surface()
    storage.technologies["upbringing"] = 1
end

local function teardown()
    Helpers.clean_up()
end

--- Long enough for at least one social meeting in a small environment.
local DELTA_TICKS = 10000

--- Creates a house with the given genders whose gas conceive in every meeting.
--- @return Entry
local function create_house(position, agender, fale, pachin, ga)
    local entry = Helpers.create_inhabited_house(test_surface, position, Type.clockwork, agender + fale + pachin + ga)
    entry[EK.genders] = GenderGroup.new(agender, fale, pachin, ga)
    entry[EK.conception_rate_factor] = 1000000
    entry[EK.ga_conceptions] = 0
    entry[EK.social_progress] = 0
    return entry
end

Tirislib.Testing.add_test_case(
    "Every ga with a partner conceives at most once per cycle",
    "integration|integration.reproduction",
    function()
        local entry = create_house({0, 0}, 0, 10, 10, 10)

        Inhabitants.evaluate_social_environment(entry, {}, DELTA_TICKS)
        Inhabitants.evaluate_social_environment(entry, {}, DELTA_TICKS)

        Assert.equals(entry[EK.ga_conceptions], 10, "every ga should conceive exactly once")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Gas without a partner don't conceive",
    "integration|integration.reproduction",
    function()
        local entry = create_house({0, 0}, 0, 5, 5, 10)

        Inhabitants.evaluate_social_environment(entry, {}, DELTA_TICKS)

        Assert.equals(entry[EK.ga_conceptions], 5, "only the gas with a partner should conceive")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "A house without gas doesn't conceive",
    "integration|integration.reproduction",
    function()
        local entry = create_house({0, 0}, 5, 5, 5, 0)

        Inhabitants.evaluate_social_environment(entry, {}, DELTA_TICKS)

        Assert.equals(entry[EK.ga_conceptions], 0)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "A single ga gets a partner as often as the partner rate of the environment says",
    "integration|integration.reproduction",
    function()
        -- the environment has 4 gas and 1 partner pair, so the lone ga has a partner in a quarter of the meetings
        local small = create_house({0, 0}, 0, 0, 0, 1)
        local other = create_house({10, 0}, 0, 1, 1, 3)
        small[EK.social_environment] = {small[EK.unit_number], other[EK.unit_number]}

        local trials = 200
        local conceived = 0
        for _ = 1, trials do
            small[EK.ga_conceptions] = 0
            small[EK.social_progress] = 0
            Inhabitants.evaluate_social_environment(small, {}, DELTA_TICKS)
            conceived = conceived + small[EK.ga_conceptions]
        end

        Assert.greater_than(conceived, trials * 0.1, "the lone ga should conceive in some cycles")
        Assert.less_than(conceived, trials * 0.45, "the lone ga should not have a partner every cycle")
    end,
    setup,
    teardown
)
