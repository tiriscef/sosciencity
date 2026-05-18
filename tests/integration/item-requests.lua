local EK = require("enums.entry-key")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface

local function make_house()
    local entry = Helpers.create_and_register(test_surface, "test-house", Helpers.next_position())
    local entity = entry[EK.entity]
    local inventory = entity.get_inventory(defines.inventory.chest)
    return entry, entity, inventory
end

local function setup()
    test_surface = Helpers.create_test_surface()
end

local function teardown()
    Helpers.clean_up()
end

Tirislib.Testing.add_test_case(
    "set_request creates a proxy when group goes from nil to items",
    "integration|integration.item-requests",
    function()
        local entry, entity, inventory = make_house()
        Assert.is_nil(entity.item_request_proxy, "no proxy before any request")
        ItemRequests.set_request(entity, inventory, entry, "test-group", {{name = "iron-plate", count = 5}})
        Assert.not_nil(entity.item_request_proxy, "proxy should be created")
        Assert.is_true(entity.item_request_proxy.valid, "proxy should be valid")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "set_request destroys proxy when last group is cleared",
    "integration|integration.item-requests",
    function()
        local entry, entity, inventory = make_house()
        ItemRequests.set_request(entity, inventory, entry, "test-group", {{name = "iron-plate", count = 5}})
        Assert.not_nil(entity.item_request_proxy, "proxy should exist before clearing")
        ItemRequests.set_request(entity, inventory, entry, "test-group", nil)
        Assert.is_nil(entity.item_request_proxy, "proxy should be destroyed when last group cleared")
        Assert.is_nil(entry[EK.item_requests], "item_requests data should be nil when all groups cleared")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "set_request does not rebuild proxy when updating items within an existing group",
    "integration|integration.item-requests",
    function()
        local entry, entity, inventory = make_house()
        ItemRequests.set_request(entity, inventory, entry, "test-group", {{name = "iron-plate", count = 5}})
        local first_proxy = entity.item_request_proxy
        Assert.not_nil(first_proxy, "proxy should exist after first request")
        -- non-nil to non-nil: the optimization should skip the rebuild
        ItemRequests.set_request(entity, inventory, entry, "test-group", {{name = "iron-plate", count = 10}})
        Assert.is_true(first_proxy.valid, "original proxy should survive a non-nil to non-nil update")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "set_request recreates proxy when previous proxy was consumed",
    "integration|integration.item-requests",
    function()
        local entry, entity, inventory = make_house()
        ItemRequests.set_request(entity, inventory, entry, "test-group", {{name = "iron-plate", count = 5}})
        Assert.not_nil(entity.item_request_proxy, "proxy should exist initially")
        -- simulate proxy consumed (items arrived, proxy auto-destroyed by Factorio)
        entity.item_request_proxy.destroy()
        Assert.is_nil(entity.item_request_proxy, "proxy should be gone after destroy")
        ItemRequests.set_request(entity, inventory, entry, "test-group", {{name = "iron-plate", count = 5}})
        Assert.not_nil(entity.item_request_proxy, "proxy should be recreated")
        Assert.is_true(entity.item_request_proxy.valid, "recreated proxy should be valid")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "set_request keeps proxy when one of multiple groups is cleared",
    "integration|integration.item-requests",
    function()
        local entry, entity, inventory = make_house()
        ItemRequests.set_request(entity, inventory, entry, "group-a", {{name = "iron-plate", count = 5}})
        ItemRequests.set_request(entity, inventory, entry, "group-b", {{name = "copper-plate", count = 3}})
        Assert.not_nil(entity.item_request_proxy, "proxy should exist with two active groups")
        ItemRequests.set_request(entity, inventory, entry, "group-a", nil)
        Assert.not_nil(entity.item_request_proxy, "proxy should remain while group-b is still active")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "cancel destroys proxy and clears all item_requests data",
    "integration|integration.item-requests",
    function()
        local entry, entity, inventory = make_house()
        ItemRequests.set_request(entity, inventory, entry, "group-a", {{name = "iron-plate", count = 5}})
        ItemRequests.set_request(entity, inventory, entry, "group-b", {{name = "copper-plate", count = 3}})
        Assert.not_nil(entity.item_request_proxy, "proxy should exist before cancel")
        ItemRequests.cancel(entity, inventory, entry)
        Assert.is_nil(entity.item_request_proxy, "proxy should be destroyed after cancel")
        Assert.is_nil(entry[EK.item_requests], "item_requests data should be nil after cancel")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "cancel is safe when no request has been made",
    "integration|integration.item-requests",
    function()
        local entry, entity, inventory = make_house()
        ItemRequests.cancel(entity, inventory, entry)
        Assert.is_nil(entity.item_request_proxy, "no proxy expected after cancel on clean entity")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "fulfilled returns true when all required items are present",
    "integration|integration.item-requests",
    function()
        local _, _, inventory = make_house()
        inventory.insert({name = "iron-plate", count = 10})
        Assert.is_true(ItemRequests.fulfilled(inventory, {{name = "iron-plate", count = 10}}), "exact amount")
        Assert.is_true(ItemRequests.fulfilled(inventory, {{name = "iron-plate", count = 5}}), "surplus amount")
        Assert.is_true(ItemRequests.fulfilled(inventory, {}), "empty requirement list is always fulfilled")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "fulfilled returns false when required items are missing or insufficient",
    "integration|integration.item-requests",
    function()
        local _, _, inventory = make_house()
        inventory.insert({name = "iron-plate", count = 3})
        Assert.is_false(ItemRequests.fulfilled(inventory, {{name = "iron-plate", count = 5}}), "insufficient amount")
        Assert.is_false(ItemRequests.fulfilled(inventory, {{name = "copper-plate", count = 1}}), "item absent")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "two groups requesting the same item merge their amounts",
    "integration|integration.item-requests",
    function()
        local entry, entity, inventory = make_house()
        ItemRequests.set_request(entity, inventory, entry, "group-a", {{name = "iron-plate", count = 5}})
        ItemRequests.set_request(entity, inventory, entry, "group-b", {{name = "iron-plate", count = 3}})
        Assert.not_nil(entity.item_request_proxy, "proxy should be created for merged request")
        Assert.is_true(Helpers.has_filter_for(inventory, "iron-plate"), "slot filter for iron-plate should be set")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "cancel clears inventory slot filters set by the proxy",
    "integration|integration.item-requests",
    function()
        local entry, entity, inventory = make_house()
        ItemRequests.set_request(entity, inventory, entry, "test-group", {{name = "iron-plate", count = 5}})
        Assert.is_true(Helpers.has_filter_for(inventory, "iron-plate"), "slot filter should be set before cancel")
        ItemRequests.cancel(entity, inventory, entry)
        Assert.is_false(Helpers.has_filter_for(inventory, "iron-plate"), "slot filter should be cleared after cancel")
    end,
    setup,
    teardown
)
