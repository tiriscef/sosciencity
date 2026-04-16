local EK = require("enums.entry-key")
local Type = require("enums.type")

local Castes = require("constants.castes")
local Housing = require("constants.housing")

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

Tirislib.Testing.add_test_case(
    "create_house initializes InhabitantGroup fields",
    "integration|integration.inhabitants",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-house", {0, 0}, Type.clockwork)

        Assert.equals(entry[EK.inhabitants], 0, "inhabitants should be 0")
        Assert.not_nil(entry[EK.diseases], "diseases should exist")
        Assert.equals(entry[EK.official_inhabitants], 0, "official_inhabitants should be 0")
        Assert.not_nil(entry[EK.genders], "genders should exist")
        Assert.not_nil(entry[EK.ages], "ages should exist")
        Assert.not_nil(entry[EK.happiness_summands], "happiness_summands should exist")
        Assert.not_nil(entry[EK.health_summands], "health_summands should exist")
        Assert.not_nil(entry[EK.sanity_summands], "sanity_summands should exist")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "try_allow_for_caste converts empty house to caste housing",
    "integration|integration.inhabitants",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-house", {0, 0})
        Assert.equals(entry[EK.type], Type.empty_house, "house should start as empty_house")

        local new_entry = Inhabitants.try_allow_for_caste(entry, Type.clockwork, false)

        Assert.not_nil(new_entry, "try_allow_for_caste should return new entry on success")
        Assert.equals(new_entry[EK.type], Type.clockwork, "house type should be clockwork")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "try_allow_for_caste fails when caste is not researched",
    "integration|integration.inhabitants",
    function()
        storage.technologies["upbringing"] = nil

        local entry = Helpers.create_and_register(test_surface, "test-house", {0, 0})
        local result = Inhabitants.try_allow_for_caste(entry, Type.clockwork, false)

        Assert.is_nil(result, "try_allow_for_caste should return nil")
        Assert.equals(entry[EK.type], Type.empty_house, "house type should remain empty_house")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "add_to_city distributes inhabitants to free caste house",
    "integration|integration.inhabitants",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-house", {0, 0})
        local house = Inhabitants.try_allow_for_caste(entry, Type.clockwork, false)

        local count_before = house[EK.inhabitants]

        local group = InhabitantGroup.new(Type.clockwork, 5)
        Inhabitants.add_to_city(group)

        Assert.greater_than(house[EK.inhabitants], count_before, "house should have gained inhabitants")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "add_to_city sends overflow to homeless pool",
    "integration|integration.inhabitants",
    function()
        local group = InhabitantGroup.new(Type.clockwork, 10)
        Inhabitants.add_to_city(group)

        Assert.greater_than(
            storage.homeless[Type.clockwork][EK.inhabitants],
            0,
            "homeless pool should have increased"
        )
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "try_allow_for_caste succeeds for a house below caste minimum comfort",
    "integration|integration.inhabitants",
    function()
        -- test-house-3 has comfort=3, foundry minimum_comfort=6: previously blocked, now allowed
        storage.technologies["foundry-caste"] = 1
        local entry = Helpers.create_and_register(test_surface, "test-house-3", {0, 0})

        local result = Inhabitants.try_allow_for_caste(entry, Type.foundry, false)

        Assert.not_nil(result, "should succeed despite comfort being below caste minimum")
        Assert.equals(result[EK.type], Type.foundry, "house type should be foundry")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "House capacity depends on caste room requirements",
    "integration|integration.inhabitants",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-house", {0, 0})
        local house = Inhabitants.try_allow_for_caste(entry, Type.clockwork, false)

        local expected_capacity = math.floor(
            Housing.values["test-house"].room_count / Castes.values[Type.clockwork].required_room_count)
        Assert.equals(Housing.get_capacity(house), expected_capacity, "capacity should be floor(room_count / required_room_count)")
    end,
    setup,
    teardown
)
