local EK = require("enums.entry-key")
local Type = require("enums.type")

local Housing = require("constants.housing")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface

Tirislib.Testing.add_test_case(
    "create_house initializes InhabitantGroup fields",
    "integration|integration.inhabitants",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-house", {0, 0})

        Assert.equals(entry[EK.inhabitants], 0, "inhabitants should be 0")
        Assert.not_nil(entry[EK.diseases], "diseases should exist")
        Assert.equals(entry[EK.official_inhabitants], 0, "official_inhabitants should be 0")
        Assert.not_nil(entry[EK.genders], "genders should exist")
        Assert.not_nil(entry[EK.ages], "ages should exist")
        Assert.not_nil(entry[EK.happiness_summands], "happiness_summands should exist")
        Assert.not_nil(entry[EK.health_summands], "health_summands should exist")
        Assert.not_nil(entry[EK.sanity_summands], "sanity_summands should exist")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "try_allow_for_caste converts empty house to caste housing",
    "integration|integration.inhabitants",
    function()
        local original = storage.technologies["upbringing"]
        storage.technologies["upbringing"] = 1

        local entry = Helpers.create_and_register(test_surface, "test-house", {0, 0})
        Assert.equals(entry[EK.type], Type.empty_house, "house should start as empty_house")

        local result = Inhabitants.try_allow_for_caste(entry, Type.clockwork, false)

        Assert.is_true(result and true or false, "try_allow_for_caste should return true")
        Assert.equals(entry[EK.type], Type.clockwork, "house type should be clockwork")

        storage.technologies["upbringing"] = original
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "try_allow_for_caste fails when caste is not researched",
    "integration|integration.inhabitants",
    function()
        local original = storage.technologies["upbringing"]
        storage.technologies["upbringing"] = nil

        local entry = Helpers.create_and_register(test_surface, "test-house", {0, 0})
        local result = Inhabitants.try_allow_for_caste(entry, Type.clockwork, false)

        Assert.is_false(result, "try_allow_for_caste should return false")
        Assert.equals(entry[EK.type], Type.empty_house, "house type should remain empty_house")

        storage.technologies["upbringing"] = original
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "add_to_city distributes inhabitants to free caste house",
    "integration|integration.inhabitants",
    function()
        local original_tech = storage.technologies["upbringing"]
        storage.technologies["upbringing"] = 1
        local original_pop = storage.population[Type.clockwork]

        local entry = Helpers.create_and_register(test_surface, "test-house", {0, 0})
        Inhabitants.try_allow_for_caste(entry, Type.clockwork, false)

        local count_before = entry[EK.inhabitants]
        local pop_before = storage.population[Type.clockwork] or 0

        local group = InhabitantGroup.new(Type.clockwork, 5)
        Inhabitants.add_to_city(group)

        Assert.greater_than(entry[EK.inhabitants], count_before, "house should have gained inhabitants")

        storage.technologies["upbringing"] = original_tech
        storage.population[Type.clockwork] = original_pop
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "add_to_city sends overflow to homeless pool",
    "integration|integration.inhabitants",
    function()
        local original_tech = storage.technologies["upbringing"]
        storage.technologies["upbringing"] = 1
        local original_homeless = storage.homeless[Type.clockwork][EK.inhabitants]

        local group = InhabitantGroup.new(Type.clockwork, 10)
        Inhabitants.add_to_city(group)

        Assert.greater_than(
            storage.homeless[Type.clockwork][EK.inhabitants],
            original_homeless,
            "homeless pool should have increased"
        )

        -- restore homeless count
        storage.homeless[Type.clockwork][EK.inhabitants] = original_homeless
        storage.technologies["upbringing"] = original_tech
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "House capacity depends on caste room requirements",
    "integration|integration.inhabitants",
    function()
        local original_tech = storage.technologies["upbringing"]
        storage.technologies["upbringing"] = 1

        local entry = Helpers.create_and_register(test_surface, "test-house", {0, 0})
        Inhabitants.try_allow_for_caste(entry, Type.clockwork, false)

        local capacity = Housing.get_capacity(entry)
        -- test-house has room_count=200, clockwork has required_room_count=1
        -- capacity = floor(200 / 1) = 200
        Assert.equals(capacity, 200, "capacity should be floor(room_count / required_room_count)")

        storage.technologies["upbringing"] = original_tech
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)
