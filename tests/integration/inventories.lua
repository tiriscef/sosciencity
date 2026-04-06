local EK = require("enums.entry-key")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface

Tirislib.Testing.add_test_case(
    "get_chest_inventory returns a valid inventory",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})

        local inventory = Inventories.get_chest_inventory(entry)
        Assert.not_nil(inventory, "should return an inventory")
        Assert.is_true(inventory.valid, "inventory should be valid")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "try_insert inserts items and returns the inserted count",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local inventory = Inventories.get_chest_inventory(entry)

        local inserted = Inventories.try_insert(inventory, "iron-plate", 10, true)
        Assert.equals(inserted, 10, "should insert all 10")
        Assert.equals(inventory.get_item_count("iron-plate"), 10, "inventory should contain 10 iron plates")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "try_insert with count 0 returns 0",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local inventory = Inventories.get_chest_inventory(entry)

        local inserted = Inventories.try_insert(inventory, "iron-plate", 0, true)
        Assert.equals(inserted, 0, "should insert nothing")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "try_remove removes items and returns the removed count",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local inventory = Inventories.get_chest_inventory(entry)

        inventory.insert {name = "iron-plate", count = 20}

        local removed = Inventories.try_remove(inventory, "iron-plate", 15, true)
        Assert.equals(removed, 15, "should remove 15")
        Assert.equals(inventory.get_item_count("iron-plate"), 5, "should have 5 remaining")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "try_remove returns 0 when item is not present",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local inventory = Inventories.get_chest_inventory(entry)

        local removed = Inventories.try_remove(inventory, "iron-plate", 10, true)
        Assert.equals(removed, 0, "should remove nothing")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "try_remove removes only as much as available",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local inventory = Inventories.get_chest_inventory(entry)

        inventory.insert {name = "iron-plate", count = 5}

        local removed = Inventories.try_remove(inventory, "iron-plate", 20, true)
        Assert.equals(removed, 5, "should only remove what's available")
        Assert.equals(inventory.get_item_count("iron-plate"), 0, "inventory should be empty")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "get_contents returns item counts by name",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local inventory = Inventories.get_chest_inventory(entry)

        inventory.insert {name = "iron-plate", count = 10}
        inventory.insert {name = "copper-plate", count = 5}

        local contents = Inventories.get_contents(inventory)
        Assert.equals(contents["iron-plate"], 10, "should have 10 iron plates")
        Assert.equals(contents["copper-plate"], 5, "should have 5 copper plates")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "get_contents returns empty table for empty inventory",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local inventory = Inventories.get_chest_inventory(entry)

        local contents = Inventories.get_contents(inventory)
        Assert.equals(contents, {}, "should be empty")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)
