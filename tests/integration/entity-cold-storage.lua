local EK = require("enums.entry-key")
local Food = require("constants.food")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local round = Tirislib.Utils.round

-- test-cold-storage has spoil_slowdown = 0.6 (mirrors storage-cellar, no power_usage)
local SPOIL_SLOWDOWN = 0.6
local SPOILABLE_FOOD = "mammal-meat"

local test_surface

local function setup()
    test_surface = Helpers.create_test_surface()
end

local function teardown()
    Helpers.clean_up()
end

---------------------------------------------------------------------------------------------------
-- << cold storage >>

Tirislib.Testing.add_test_case(
    "Cold storage sets active flag true when functional",
    "integration|integration.entity",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-cold-storage", {0, 0})

        Helpers.update_entry(entry)

        Assert.is_true(entry[EK.active])
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Cold storage delays food spoilage",
    "integration|integration.entity",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-cold-storage", {0, 0})
        local inv = Inventories.get_chest_inventory(entry)
        inv.insert {name = SPOILABLE_FOOD, count = 1}

        local stack = inv[1]
        local initial = game.tick + 200
        stack.spoil_tick = initial

        Register.update_entry(entry, entry[EK.last_update] + 100)

        Assert.greater_than(stack.spoil_tick, initial, "spoil_tick should be extended")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Cold storage spoil delay amount matches spoil_slowdown",
    "integration|integration.entity",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-cold-storage", {0, 0})
        local inv = Inventories.get_chest_inventory(entry)
        inv.insert {name = SPOILABLE_FOOD, count = 1}

        local stack = inv[1]
        local base = game.tick + 200
        stack.spoil_tick = base

        local delta = 100
        Register.update_entry(entry, entry[EK.last_update] + delta)

        Assert.equals(stack.spoil_tick, base + round(delta * SPOIL_SLOWDOWN))
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Cold storage caps spoil extension at item max freshness",
    "integration|integration.entity",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-cold-storage", {0, 0})
        local inv = Inventories.get_chest_inventory(entry)
        inv.insert {name = SPOILABLE_FOOD, count = 1}

        local stack = inv[1]
        local max_spoil = Food.values[SPOILABLE_FOOD].max_spoil["normal"]
        stack.spoil_tick = game.tick + max_spoil - 5

        Register.update_entry(entry, entry[EK.last_update] + 10000)

        Assert.equals(stack.spoil_tick, game.tick + max_spoil, "spoil_tick should not exceed max freshness")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Cold storage skips spoilable non-food items",
    "integration|integration.entity",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-cold-storage", {0, 0})
        local inv = Inventories.get_chest_inventory(entry)
        inv.insert {name = "test-spoilable-nonfood", count = 1}

        local stack = inv[1]
        local initial = game.tick + 200
        stack.spoil_tick = initial

        Register.update_entry(entry, entry[EK.last_update] + 100)

        Assert.equals(stack.spoil_tick, initial, "non-food spoil_tick should not change")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Cold storage handles food items with no spoil timer gracefully",
    "integration|integration.entity",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-cold-storage", {0, 0})
        local inv = Inventories.get_chest_inventory(entry)
        inv.insert {name = "test-food-fruity-carb", count = 5}

        Register.update_entry(entry, entry[EK.last_update] + 100)

        Assert.equals(inv.get_item_count("test-food-fruity-carb"), 5, "items should not be consumed or destroyed")
        Assert.is_true(entry[EK.active])
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Cold storage does not delay spoilage when inactive",
    "integration|integration.entity",
    function()
        -- test-cold-storage-powered has power_usage, so its EEI is created at registration.
        -- On the unpowered test surface the buffer stays at 0, making it immediately inactive.
        local entry = Helpers.create_and_register(test_surface, "test-cold-storage-powered", {0, 0})
        local inv = Inventories.get_chest_inventory(entry)
        inv.insert {name = SPOILABLE_FOOD, count = 1}

        local stack = inv[1]
        local initial = game.tick + 200
        stack.spoil_tick = initial

        Helpers.update_entry(entry)

        Assert.is_false(entry[EK.active], "entity should be inactive without power")
        Assert.equals(stack.spoil_tick, initial, "spoil_tick should not change when inactive")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Cold storage delays spoilage on all food stacks in inventory",
    "integration|integration.entity",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-cold-storage", {0, 0})
        local inv = Inventories.get_chest_inventory(entry)
        inv.insert {name = SPOILABLE_FOOD, count = 1}
        inv.insert {name = "bird-meat", count = 1}
        inv.insert {name = "test-spoilable-nonfood", count = 1}

        local food_stack_1 = inv[1]
        local food_stack_2 = inv[2]
        local nonfood_stack = inv[3]

        local initial_1 = game.tick + 200
        local initial_2 = game.tick + 300
        local initial_nonfood = game.tick + 150
        food_stack_1.spoil_tick = initial_1
        food_stack_2.spoil_tick = initial_2
        nonfood_stack.spoil_tick = initial_nonfood

        local delta = 100
        Register.update_entry(entry, entry[EK.last_update] + delta)

        local expected = round(delta * SPOIL_SLOWDOWN)
        Assert.equals(food_stack_1.spoil_tick, initial_1 + expected, "first food stack should be extended")
        Assert.equals(food_stack_2.spoil_tick, initial_2 + expected, "second food stack should be extended")
        Assert.equals(nonfood_stack.spoil_tick, initial_nonfood, "non-food stack should not change")
    end,
    setup,
    teardown
)
