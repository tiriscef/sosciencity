local EK = require("enums.entry-key")
local Type = require("enums.type")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface

---------------------------------------------------------------------------------------------------
-- << composter >>

Tirislib.Testing.add_test_case(
    "Composter creation initializes fields",
    "integration|integration.entity",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-composter", {0, 0})

        Assert.equals(entry[EK.humus], 0, "humus should start at 0")
        Assert.equals(entry[EK.composting_progress], 0, "composting_progress should start at 0")
        Assert.equals(entry[EK.necrofall_progress], 0, "necrofall_progress should start at 0")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Composter accumulates composting progress with compostable items",
    "integration|integration.entity",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-composter", {0, 0})

        -- put compostable items in the composter
        local inventory = Inventories.get_chest_inventory(entry)
        inventory.insert {name = "wood", count = 10}

        Register.update_entry(entry, game.tick + 100)

        -- progress should have increased (wood is compostable)
        Assert.greater_than(entry[EK.composting_progress], 0, "composting progress should increase")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Composter does not accumulate progress with empty inventory",
    "integration|integration.entity",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-composter", {0, 0})

        Register.update_entry(entry, game.tick + 100)

        Assert.equals(entry[EK.composting_progress], 0, "composting progress should remain 0")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Composter does not accumulate progress with non-compostable items",
    "integration|integration.entity",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-composter", {0, 0})

        local inventory = Inventories.get_chest_inventory(entry)
        inventory.insert {name = "iron-plate", count = 50}

        Register.update_entry(entry, game.tick + 100)

        Assert.equals(entry[EK.composting_progress], 0, "composting progress should remain 0")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Composter converts items to humus when progress reaches 1",
    "integration|integration.entity",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-composter", {0, 0})

        local inventory = Inventories.get_chest_inventory(entry)
        inventory.insert {name = "wood", count = 100}

        -- composting_coefficient = 1/240000
        -- with 100 wood (1 type): progress_factor = 100 * 1 / 240000 = 1/2400
        -- need delta_ticks = 2400 to reach progress = 1
        -- use a large delta to ensure at least one item is consumed
        Register.update_entry(entry, game.tick + 5000)

        -- wood has compost_value = 4, so humus should increase
        Assert.greater_than(entry[EK.humus], 0, "humus should have been produced")
        Assert.less_than(inventory.get_item_count("wood"), 100, "some wood should have been consumed")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

---------------------------------------------------------------------------------------------------
-- << composter output >>

Tirislib.Testing.add_test_case(
    "Composter output pulls humus from nearby composter",
    "integration|integration.entity",
    function()
        -- test-compost-output has range 5
        local composter = Helpers.create_and_register(test_surface, "test-composter", {0, 0})
        local output = Helpers.create_and_register(test_surface, "test-compost-output", {3, 0})

        -- manually set humus on the composter
        composter[EK.humus] = 100

        Register.update_entry(output, game.tick + 100)

        -- output should have pulled humus
        local output_inventory = Inventories.get_chest_inventory(output)
        local humus_in_output = output_inventory.get_item_count("humus")
        Assert.greater_than(humus_in_output, 0, "output should contain humus")
        Assert.less_than(composter[EK.humus], 100, "composter humus should have decreased")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Composter output does not pull when composter has no humus",
    "integration|integration.entity",
    function()
        local composter = Helpers.create_and_register(test_surface, "test-composter", {0, 0})
        local output = Helpers.create_and_register(test_surface, "test-compost-output", {3, 0})

        -- humus starts at 0

        Register.update_entry(output, game.tick + 100)

        local output_inventory = Inventories.get_chest_inventory(output)
        Assert.equals(output_inventory.get_item_count("humus"), 0, "output should have no humus")
        Assert.equals(composter[EK.humus], 0, "composter humus should still be 0")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Composter output does not pull from out-of-range composter",
    "integration|integration.entity",
    function()
        -- test-compost-output has range 5, place composter far away
        local composter = Helpers.create_and_register(test_surface, "test-composter", {0, 0})
        local output = Helpers.create_and_register(test_surface, "test-compost-output", {50, 0})

        composter[EK.humus] = 100

        Register.update_entry(output, game.tick + 100)

        local output_inventory = Inventories.get_chest_inventory(output)
        Assert.equals(output_inventory.get_item_count("humus"), 0, "output should have no humus")
        Assert.equals(composter[EK.humus], 100, "composter humus should be unchanged")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Composter output pulls from multiple nearby composters",
    "integration|integration.entity",
    function()
        local composter1 = Helpers.create_and_register(test_surface, "test-composter", {0, 0})
        local composter2 = Helpers.create_and_register(test_surface, "test-composter", {0, -4})
        local output = Helpers.create_and_register(test_surface, "test-compost-output", {3, 0})

        composter1[EK.humus] = 50
        composter2[EK.humus] = 30

        Register.update_entry(output, game.tick + 100)

        local output_inventory = Inventories.get_chest_inventory(output)
        local humus_in_output = output_inventory.get_item_count("humus")

        -- should have pulled from both (50 + 30 = 80 integer humus)
        Assert.equals(humus_in_output, 80, "output should contain humus from both composters")
        Assert.equals(composter1[EK.humus], 0, "composter1 should be drained")
        Assert.equals(composter2[EK.humus], 0, "composter2 should be drained")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Composter output preserves fractional humus",
    "integration|integration.entity",
    function()
        local composter = Helpers.create_and_register(test_surface, "test-composter", {0, 0})
        local output = Helpers.create_and_register(test_surface, "test-compost-output", {3, 0})

        -- set fractional humus - floor(0.5) = 0, so nothing should transfer
        composter[EK.humus] = 0.5

        Register.update_entry(output, game.tick + 100)

        local output_inventory = Inventories.get_chest_inventory(output)
        Assert.equals(output_inventory.get_item_count("humus"), 0, "no transfer for fractional humus")
        Assert.equals(composter[EK.humus], 0.5, "fractional humus should be preserved")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)
