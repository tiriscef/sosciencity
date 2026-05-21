local EK = require("enums.entry-key")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface

local function setup()
    test_surface = Helpers.create_test_surface()
end

local function clean_up()
    Helpers.clean_up()
end

---------------------------------------------------------------------------------------------------
-- << creation >>

Tirislib.Testing.add_test_case(
    "Market creation initializes inventory_contents as a table",
    "integration|integration.market",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})

        Assert.not_nil(entry[EK.inventory_contents], "inventory_contents should be set after creation")
    end,
    setup,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Market creation with food pre-inserted: has_food is true without update",
    "integration|integration.market",
    function()
        local entity = Helpers.create_unregistered(test_surface, "test-market", {0, 0})
        entity.get_inventory(defines.inventory.chest).insert {name = "mammal-meat", count = 10}
        local entry = Register.add(entity)

        Assert.is_true(Entity.Market.has_food(entry), "has_food should be true when food was in chest at creation")
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << has_food >>

Tirislib.Testing.add_test_case(
    "Market has_food is false on empty inventory",
    "integration|integration.market",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})

        Assert.is_false(Entity.Market.has_food(entry), "has_food should be false when chest is empty")
    end,
    setup,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Market has_food is true after food is inserted and cache refreshed",
    "integration|integration.market",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        Inventories.get_chest_inventory(entry).insert {name = "mammal-meat", count = 10}
        Helpers.update_entry(entry)

        Assert.is_true(Entity.Market.has_food(entry), "has_food should be true after food inserted and updated")
    end,
    setup,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Market has_food is false when only non-food items are present",
    "integration|integration.market",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        Inventories.get_chest_inventory(entry).insert {name = "iron-plate", count = 10}
        Helpers.update_entry(entry)

        Assert.is_false(Entity.Market.has_food(entry), "has_food should be false for non-food items")
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << update >>

Tirislib.Testing.add_test_case(
    "Market has_food goes from true to false when food is removed",
    "integration|integration.market",
    function()
        local entity = Helpers.create_unregistered(test_surface, "test-market", {0, 0})
        local inv = entity.get_inventory(defines.inventory.chest)
        inv.insert {name = "mammal-meat", count = 10}
        local entry = Register.add(entity)

        Assert.is_true(Entity.Market.has_food(entry), "should have food before removal")

        inv.clear()
        Helpers.update_entry(entry)

        Assert.is_false(Entity.Market.has_food(entry), "has_food should be false after food removed and updated")
    end,
    setup,
    clean_up
)
