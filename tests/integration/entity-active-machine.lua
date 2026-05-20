local EK = require("enums.entry-key")
local Time = require("constants.time")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local ACTIVE_TIME_THRESHOLD = 2 * Time.minute

local test_surface
local saved_machine_count

local function setup()
    test_surface = Helpers.create_test_surface()
    saved_machine_count = storage.active_machine_count
    storage.active_machine_count = 0
end

local function teardown()
    storage.active_machine_count = saved_machine_count
    Helpers.clean_up()
end

Tirislib.Testing.add_test_case(
    "active machine: freshly initialized entry is inactive and does not increment the count",
    "integration|integration.entity-active-machine",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-assembling-machine", {0, 0})
        Entity.create_active_machine_status(entry)
        Entity.update_active_machine_status(entry)

        Assert.is_false(entry[EK.active_machine_status], "freshly initialized entry should not count as active")
        Assert.equals(storage.active_machine_count, 0)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "active machine: count increments when entry transitions to recently active",
    "integration|integration.entity-active-machine",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-assembling-machine", {0, 0})
        Entity.create_active_machine_status(entry)

        entry[EK.last_time_active] = game.tick
        Entity.update_active_machine_status(entry)

        Assert.is_true(entry[EK.active_machine_status])
        Assert.equals(storage.active_machine_count, 1)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "active machine: count decrements when active entry goes stale",
    "integration|integration.entity-active-machine",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-assembling-machine", {0, 0})
        Entity.create_active_machine_status(entry)

        entry[EK.last_time_active] = game.tick
        Entity.update_active_machine_status(entry)
        Assert.equals(storage.active_machine_count, 1)

        entry[EK.last_time_active] = game.tick - ACTIVE_TIME_THRESHOLD - 1
        Entity.update_active_machine_status(entry)

        Assert.is_false(entry[EK.active_machine_status])
        Assert.equals(storage.active_machine_count, 0)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "active machine: remove decrements count for an active entry",
    "integration|integration.entity-active-machine",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-assembling-machine", {0, 0})
        Entity.create_active_machine_status(entry)

        entry[EK.last_time_active] = game.tick
        Entity.update_active_machine_status(entry)
        Assert.equals(storage.active_machine_count, 1)

        Entity.remove_active_machine_status(entry)

        Assert.equals(storage.active_machine_count, 0)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "active machine: remove does not decrement count for an inactive entry",
    "integration|integration.entity-active-machine",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-assembling-machine", {0, 0})
        Entity.create_active_machine_status(entry)
        Entity.update_active_machine_status(entry) -- entry is inactive

        Entity.remove_active_machine_status(entry)

        Assert.equals(storage.active_machine_count, 0)
    end,
    setup,
    teardown
)
