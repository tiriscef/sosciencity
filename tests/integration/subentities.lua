local EK = require("enums.entry-key")
local SubentityType = require("enums.subentity-type")
local RenderingType = require("enums.rendering-type")
local DeconstructionCause = require("enums.deconstruction-cause")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface

-- << sprites >>

Tirislib.Testing.add_test_case(
    "Alt-mode sprite is created on registration",
    "integration|integration.subentities",
    function()
        -- test-house has Type.empty_house, which has alt_mode_sprite = "empty-caste"
        local entry = Helpers.create_and_register(test_surface, "test-house", {0, 0})

        local renderings = entry[EK.attached_renderings]
        Assert.not_nil(renderings, "should have attached renderings")

        local altmode = renderings[RenderingType.altmode_sprite]
        Assert.not_nil(altmode, "should have an alt-mode sprite")
        Assert.is_true(altmode.valid, "alt-mode sprite should be valid")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Common sprite add and remove",
    "integration|integration.subentities",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-house", {0, 0})

        Subentities.add_common_sprite(entry, RenderingType.food_warning)

        local renderings = entry[EK.attached_renderings]
        local food_sprite = renderings[RenderingType.food_warning]
        Assert.not_nil(food_sprite, "food warning sprite should exist")
        Assert.is_true(food_sprite.valid, "food warning sprite should be valid")

        Subentities.remove_common_sprite(entry, RenderingType.food_warning)
        Assert.is_nil(renderings[RenderingType.food_warning], "food warning sprite should be removed")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Adding the same common sprite twice does not create a duplicate",
    "integration|integration.subentities",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-house", {0, 0})

        Subentities.add_common_sprite(entry, RenderingType.food_warning)
        local first = entry[EK.attached_renderings][RenderingType.food_warning]

        Subentities.add_common_sprite(entry, RenderingType.food_warning)
        local second = entry[EK.attached_renderings][RenderingType.food_warning]

        Assert.equals(first, second, "should be the same rendering object")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

-- << subentity lifecycle >>

Tirislib.Testing.add_test_case(
    "remove_all_for destroys subentities and sprites",
    "integration|integration.subentities",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-house", {0, 0})

        local altmode_sprite = entry[EK.attached_renderings][RenderingType.altmode_sprite]
        Assert.is_true(altmode_sprite.valid, "sprite should be valid before removal")

        Register.remove_entry(entry, DeconstructionCause.unknown)

        Assert.is_false(altmode_sprite.valid, "sprite should be invalid after removal")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "get_or_create creates on first call, returns existing on second",
    "integration|integration.subentities",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})

        local beacon1, was_new1 = Subentities.get_or_create(entry, SubentityType.beacon)
        Assert.not_nil(beacon1, "should return a subentity")
        Assert.is_true(was_new1, "should be new on first call")
        Assert.is_true(beacon1.valid, "beacon should be valid")

        local beacon2, was_new2 = Subentities.get_or_create(entry, SubentityType.beacon)
        Assert.is_false(was_new2, "should not be new on second call")
        Assert.equals(beacon1, beacon2, "should return the same subentity")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

-- << EEI and power >>

Tirislib.Testing.add_test_case(
    "EEI is created for buildings with power_usage",
    "integration|integration.subentities",
    function()
        -- test-psych-ward has power_usage = 50 in its building definition
        local entry = Helpers.create_and_register(test_surface, "test-psych-ward", {0, 0})

        local subentities = entry[EK.subentities]
        Assert.not_nil(subentities, "should have subentities")

        local eei = subentities[SubentityType.eei]
        Assert.not_nil(eei, "should have an EEI subentity")
        Assert.is_true(eei.valid, "EEI should be valid")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "No EEI for buildings without power_usage",
    "integration|integration.subentities",
    function()
        -- test-market has no power_usage in its building definition
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})

        local subentities = entry[EK.subentities]
        if subentities then
            Assert.is_nil(subentities[SubentityType.eei], "should not have an EEI subentity")
        end
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "has_power returns true when no power_usage defined",
    "integration|integration.subentities",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})

        Assert.is_true(Subentities.has_power(entry), "should return true when building needs no power")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "set_power_usage creates EEI on demand for buildings that didn't have one",
    "integration|integration.subentities",
    function()
        -- test-market has no power_usage, so no EEI is created on registration
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})

        -- dynamically give it a power requirement
        Subentities.set_power_usage(entry, 100)

        local eei = entry[EK.subentities][SubentityType.eei]
        Assert.not_nil(eei, "EEI should have been created")
        Assert.is_true(eei.valid, "EEI should be valid")
        Assert.equals(entry[EK.power_usage], 100, "entry should store the power usage")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "set_power_usage adjusts power on an existing EEI",
    "integration|integration.subentities",
    function()
        -- test-psych-ward starts with power_usage defined (50 kW, post-processed to J/tick)
        local entry = Helpers.create_and_register(test_surface, "test-psych-ward", {0, 0})

        local eei_before = entry[EK.subentities][SubentityType.eei]
        local initial_usage = entry[EK.power_usage]
        Assert.not_nil(initial_usage, "should have an initial power usage")

        -- adjust to a different value
        local new_usage = initial_usage * 2
        Subentities.set_power_usage(entry, new_usage)

        Assert.equals(entry[EK.power_usage], new_usage, "power usage should be updated")
        -- should reuse the same EEI, not create a new one
        local eei_after = entry[EK.subentities][SubentityType.eei]
        Assert.equals(eei_before, eei_after, "should reuse the same EEI entity")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "has_power returns false when EEI has no energy",
    "integration|integration.subentities",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-psych-ward", {0, 0})

        -- EEI starts with 0 energy (not connected to any power network)
        Assert.is_false(Subentities.has_power(entry), "should return false when EEI has no energy")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "has_power returns true when EEI has energy",
    "integration|integration.subentities",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-psych-ward", {0, 0})

        -- simulate power being available by filling the buffer
        local eei = entry[EK.subentities][SubentityType.eei]
        eei.energy = eei.electric_buffer_size

        Assert.is_true(Subentities.has_power(entry), "should return true when EEI has energy")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Disabling power usage makes has_power return true again",
    "integration|integration.subentities",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-psych-ward", {0, 0})

        -- starts with power_usage = 50, no energy -> has_power is false
        Assert.is_false(Subentities.has_power(entry), "precondition: no power")

        -- disable power requirement by setting it to 0
        entry[EK.power_usage] = 0

        Assert.is_true(Subentities.has_power(entry),
            "should return true after power usage is disabled")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "has_power recreates EEI if it was destroyed externally",
    "integration|integration.subentities",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-psych-ward", {0, 0})

        -- destroy the EEI as if another mod deleted it
        local old_eei = entry[EK.subentities][SubentityType.eei]
        old_eei.destroy()

        -- has_power should recreate it and return true (safety fallback)
        Assert.is_true(Subentities.has_power(entry),
            "should return true when EEI had to be recreated")

        local new_eei = entry[EK.subentities][SubentityType.eei]
        Assert.not_nil(new_eei, "new EEI should exist")
        Assert.is_true(new_eei.valid, "new EEI should be valid")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)
