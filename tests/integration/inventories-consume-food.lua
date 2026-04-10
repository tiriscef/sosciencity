local Food = require("constants.food")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface

local function setup()
    test_surface = Helpers.create_test_surface()
end

local function teardown()
    Helpers.clean_up()
end

---------------------------------------------------------------------------------------------------
-- << full satisfaction >>

Tirislib.Testing.add_test_case(
    "consume_food returns 1 when enough calories are available",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local inventory = Inventories.get_chest_inventory(entry)
        inventory.insert {name = "potato", count = 10}

        local demand = Food.values["potato"].calories * 5 -- half the available stock

        local result = Inventories.consume_food(entry, {inventory}, demand, {"potato"})

        Assert.greater_than(result, 0.999, "should return full satisfaction when enough food is available")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << partial satisfaction >>

Tirislib.Testing.add_test_case(
    "consume_food returns partial satisfaction when food runs short",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local inventory = Inventories.get_chest_inventory(entry)
        inventory.insert {name = "potato", count = 1}

        local demand = Food.values["potato"].calories * 2 -- twice the available stock

        local result = Inventories.consume_food(entry, {inventory}, demand, {"potato"})

        Assert.greater_than(result, 0, "some calories should have been consumed")
        Assert.less_than(result, 1, "satisfaction should be less than 1 when food is insufficient")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << fallback on exhaustion >>

Tirislib.Testing.add_test_case(
    "consume_food falls back to remaining foods when one is exhausted",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local inventory = Inventories.get_chest_inventory(entry)
        inventory.insert {name = "potato", count = 1}
        inventory.insert {name = "bread", count = 20}

        -- demand far exceeds what potato alone can provide
        local demand = Food.values["potato"].calories * 10

        local result = Inventories.consume_food(entry, {inventory}, demand, {"potato", "bread"})

        Assert.greater_than(result, 0.999, "should reach full satisfaction after falling back to bread")
        Assert.equals(inventory.get_item_count("potato"), 0, "potato should be fully exhausted")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << all foods exhausted >>

Tirislib.Testing.add_test_case(
    "consume_food terminates and returns partial satisfaction when all foods are exhausted",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local inventory = Inventories.get_chest_inventory(entry)
        inventory.insert {name = "potato", count = 1}
        inventory.insert {name = "bread", count = 1}

        local demand = (Food.values["potato"].calories + Food.values["bread"].calories) * 10

        local result = Inventories.consume_food(entry, {inventory}, demand, {"potato", "bread"})

        Assert.less_than(result, 1, "satisfaction should be less than 1 when all food is exhausted")
        Assert.greater_than(result, 0, "some calories should have been consumed")
        Assert.equals(inventory.get_item_count("potato"), 0, "potato should be exhausted")
        Assert.equals(inventory.get_item_count("bread"), 0, "bread should be exhausted")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << loop safety: food in diet but absent from inventory >>

Tirislib.Testing.add_test_case(
    "consume_food terminates without freezing when diet food is absent from inventory",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local inventory = Inventories.get_chest_inventory(entry)
        -- no food inserted — diet references food that isn't there

        local result = Inventories.consume_food(entry, {inventory}, 1000, {"potato"})

        Assert.equals(result, 0, "should return 0 satisfaction with no food in inventory")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "consume_food terminates without freezing when all diet foods are absent from inventory",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local inventory = Inventories.get_chest_inventory(entry)
        -- no food inserted — multiple diet items all absent

        local result = Inventories.consume_food(entry, {inventory}, 1000, {"potato", "bread", "apple"})

        Assert.equals(result, 0, "should return 0 satisfaction with no food in inventory")
    end,
    setup,
    teardown
)
