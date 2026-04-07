local EK = require("enums.entry-key")
local Type = require("enums.type")
local DeconstructionCause = require("enums.deconstruction-cause")

local Housing = require("constants.housing")

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
-- << distribute >>

Tirislib.Testing.add_test_case(
    "distribute fills houses by descending priority",
    "integration|integration.inhabitants",
    function()
        local low_priority = Inhabitants.try_allow_for_caste(
            Helpers.create_and_register(test_surface, "test-house", {0, 0}), Type.clockwork, false)
        low_priority[EK.housing_priority] = 0

        local high_priority = Inhabitants.try_allow_for_caste(
            Helpers.create_and_register(test_surface, "test-house", {10, 0}), Type.clockwork, false)
        high_priority[EK.housing_priority] = 10

        -- distribute 5 inhabitants — should go to high priority first
        local group = InhabitantGroup.new(Type.clockwork, 5)
        Inhabitants.distribute(group, false)

        Assert.equals(high_priority[EK.inhabitants], 5, "high priority house should get all 5")
        Assert.equals(low_priority[EK.inhabitants], 0, "low priority house should get none")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "distribute overflows to lower priority houses",
    "integration|integration.inhabitants",
    function()
        -- test-house has room_count=200, clockwork needs 1 room each -> capacity 200
        local high_priority = Inhabitants.try_allow_for_caste(
            Helpers.create_and_register(test_surface, "test-house", {0, 0}), Type.clockwork, false)
        high_priority[EK.housing_priority] = 10

        local low_priority = Inhabitants.try_allow_for_caste(
            Helpers.create_and_register(test_surface, "test-house", {10, 0}), Type.clockwork, false)
        low_priority[EK.housing_priority] = 0

        -- fill the high priority house to capacity first
        local fill_group = InhabitantGroup.new(Type.clockwork, Housing.get_capacity(high_priority))
        InhabitantGroup.merge(high_priority, fill_group)
        Inhabitants.update_free_space_status(high_priority)

        -- now distribute 10 more — should go to low priority
        local overflow = InhabitantGroup.new(Type.clockwork, 10)
        Inhabitants.distribute(overflow, false)

        Assert.equals(low_priority[EK.inhabitants], 10, "overflow should go to low priority house")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << try_add_to_house >>

Tirislib.Testing.add_test_case(
    "try_add_to_house respects capacity",
    "integration|integration.inhabitants",
    function()
        local house = Inhabitants.try_allow_for_caste(
            Helpers.create_and_register(test_surface, "test-house", {0, 0}), Type.clockwork, false)

        local capacity = Housing.get_capacity(house)
        local free_space = 2

        -- fill to near capacity
        local fill = InhabitantGroup.new(Type.clockwork, capacity - free_space)
        InhabitantGroup.merge(house, fill)
        Inhabitants.update_free_space_status(house)

        -- try to add 10 more — only free_space should fit
        local group = InhabitantGroup.new(Type.clockwork, 10)
        local added = Inhabitants.try_add_to_house(house, group, true)

        Assert.equals(added, free_space, "should only add up to capacity")
        Assert.equals(house[EK.inhabitants], capacity, "house should be at capacity")
        Assert.equals(group[EK.inhabitants], 10 - free_space, "remaining group should have " .. (10 - free_space) .. " left")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << homeless -> free houses >>

Tirislib.Testing.add_test_case(
    "Homeless inhabitants move into free houses automatically",
    "integration|integration.inhabitants",
    function()
        -- create a free clockwork house
        local house = Inhabitants.try_allow_for_caste(
            Helpers.create_and_register(test_surface, "test-house", {0, 0}), Type.clockwork, false)

        -- add inhabitants to the homeless pool
        local group = InhabitantGroup.new(Type.clockwork, 5)
        Inhabitants.add_to_homeless_pool(group)

        -- add_to_homeless_pool calls try_house_homeless internally
        Assert.equals(house[EK.inhabitants], 5, "homeless should have moved into the free house")
        Assert.equals(storage.homeless[Type.clockwork][EK.inhabitants], 0,
            "homeless pool should be empty after housing")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Homeless inhabitants stay homeless when no free houses exist",
    "integration|integration.inhabitants",
    function()
        -- no houses created — nowhere to go
        local group = InhabitantGroup.new(Type.clockwork, 5)
        Inhabitants.add_to_homeless_pool(group)

        Assert.equals(storage.homeless[Type.clockwork][EK.inhabitants], 5,
            "homeless pool should contain all 5")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << homeless -> empty houses >>

Tirislib.Testing.add_test_case(
    "Homeless occupy empty houses when no caste houses are available",
    "integration|integration.inhabitants",
    function()
        -- create an empty (unassigned) house and make it liveable
        local empty_house = Helpers.create_and_register(test_surface, "test-house", {0, 0})
        empty_house[EK.is_liveable] = true
        local unit_number = empty_house[EK.unit_number]

        -- put some homeless clockwork inhabitants
        storage.homeless[Type.clockwork][EK.inhabitants] = 5
        storage.homeless[Type.clockwork][EK.diseases] = DiseaseGroup.new(5)
        storage.homeless[Type.clockwork][EK.genders] = GenderGroup.new(5, 0, 0, 0)
        storage.homeless[Type.clockwork][EK.ages] = AgeGroup.new(5)

        Inhabitants.try_occupy_empty_housing()

        -- try_occupy_empty_housing calls try_allow_for_caste which invalidates empty_house
        local new_entry = Register.try_get(unit_number)
        if new_entry then
            Assert.unequal(new_entry[EK.type], Type.empty_house,
                "house should no longer be empty_house")
            Assert.greater_than(new_entry[EK.inhabitants], 0,
                "house should have inhabitants")
        end
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Homeless do not occupy empty houses that are not liveable",
    "integration|integration.inhabitants",
    function()
        -- create an empty house but don't set is_liveable
        local empty_house = Helpers.create_and_register(test_surface, "test-house", {0, 0})
        -- is_liveable defaults to nil/false

        storage.homeless[Type.clockwork][EK.inhabitants] = 5
        storage.homeless[Type.clockwork][EK.diseases] = DiseaseGroup.new(5)
        storage.homeless[Type.clockwork][EK.genders] = GenderGroup.new(5, 0, 0, 0)
        storage.homeless[Type.clockwork][EK.ages] = AgeGroup.new(5)

        Inhabitants.try_occupy_empty_housing()

        -- house should still be empty_house type
        Assert.equals(empty_house[EK.type], Type.empty_house,
            "non-liveable house should remain empty")
        Assert.equals(storage.homeless[Type.clockwork][EK.inhabitants], 5,
            "homeless should still be homeless")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << remove_house >>

Tirislib.Testing.add_test_case(
    "Removing a mined house sends inhabitants to homeless pool",
    "integration|integration.inhabitants",
    function()
        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 10)

        local homeless_before = storage.homeless[Type.clockwork][EK.inhabitants]

        Register.remove_entry(house, DeconstructionCause.mined)

        Assert.greater_than(storage.homeless[Type.clockwork][EK.inhabitants], homeless_before,
            "mined house inhabitants should go to homeless pool")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Removing a house decreases population count",
    "integration|integration.inhabitants",
    function()
        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 10)
        Inhabitants.update_housing_census(house)

        local pop_before = storage.population[Type.clockwork]

        Register.remove_entry(house, DeconstructionCause.mined)

        Assert.less_than(storage.population[Type.clockwork], pop_before,
            "population should decrease when house is removed")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << free space tracking >>

Tirislib.Testing.add_test_case(
    "House is tracked as free when it has capacity",
    "integration|integration.inhabitants",
    function()
        local house = Inhabitants.try_allow_for_caste(
            Helpers.create_and_register(test_surface, "test-house", {0, 0}), Type.clockwork, false)

        Assert.not_nil(storage.free_houses[false][Type.clockwork][house[EK.unit_number]],
            "empty house should be tracked as free")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Full house is removed from free tracking",
    "integration|integration.inhabitants",
    function()
        local house = Inhabitants.try_allow_for_caste(
            Helpers.create_and_register(test_surface, "test-house", {0, 0}), Type.clockwork, false)

        -- fill to capacity
        local group = InhabitantGroup.new(Type.clockwork, Housing.get_capacity(house))
        InhabitantGroup.merge(house, group)
        Inhabitants.update_free_space_status(house)

        Assert.is_nil(storage.free_houses[false][Type.clockwork][house[EK.unit_number]],
            "full house should not be tracked as free")
    end,
    setup,
    teardown
)
