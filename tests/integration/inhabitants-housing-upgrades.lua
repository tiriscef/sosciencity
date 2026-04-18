local EK = require("enums.entry-key")
local Type = require("enums.type")
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

local function chest_inv(entry)
    return entry[EK.entity].get_inventory(defines.inventory.chest)
end

local function filter_count(inventory)
    local count = 0
    for i = 1, #inventory do
        if inventory.get_filter(i) ~= nil then
            count = count + 1
        end
    end
    return count
end

local function create_empty_house()
    return Helpers.create_and_register(test_surface, "test-house", {0, 0})
end

local function upgrade_cost(level)
    return Housing.get_upgrade_cost(Housing.values["test-house"], level)
end

local function fill_chest(entry, items)
    local inv = chest_inv(entry)
    for _, item in pairs(items) do
        inv.insert({name = item.name, count = item.count})
    end
end

---------------------------------------------------------------------------------------------------

Tirislib.Testing.add_test_case(
    "ItemRequests.fulfilled returns true when all required items are present",
    "integration|integration.housing-upgrades",
    function()
        local house = create_empty_house()
        local inv = chest_inv(house)
        inv.insert({name = "furniture", count = 100})

        Assert.is_true(ItemRequests.fulfilled(inv, {{name = "furniture", count = 100}}))
        Assert.is_true(ItemRequests.fulfilled(inv, {{name = "furniture", count = 50}}))
        Assert.is_true(ItemRequests.fulfilled(inv, {}))
    end,
    setup, teardown
)

Tirislib.Testing.add_test_case(
    "ItemRequests.fulfilled returns false when an item is insufficient or absent",
    "integration|integration.housing-upgrades",
    function()
        local house = create_empty_house()
        local inv = chest_inv(house)
        inv.insert({name = "furniture", count = 50})

        Assert.is_false(ItemRequests.fulfilled(inv, {{name = "furniture", count = 100}}))
        Assert.is_false(ItemRequests.fulfilled(inv, {{name = "bed", count = 1}}))
    end,
    setup, teardown
)

Tirislib.Testing.add_test_case(
    "try_auto_upgrade upgrades comfort, consumes items, and leaves no proxy or filters",
    "integration|integration.housing-upgrades",
    function()
        local house = create_empty_house()
        house[EK.target_comfort] = 1
        fill_chest(house, upgrade_cost(1))

        Inhabitants.try_auto_upgrade(house)

        Assert.equals(house[EK.current_comfort], 1, "comfort should have increased to 1")
        Assert.equals(chest_inv(house).get_item_count("furniture"), 0, "items should be consumed")
        Assert.equals(filter_count(chest_inv(house)), 0, "all slot filters should be cleared")
        Assert.is_nil(house[EK.entity].item_request_proxy, "no proxy should remain")
        Assert.is_nil(house[EK.upgrade_slots], "upgrade_slots should be cleared")
    end,
    setup, teardown
)

Tirislib.Testing.add_test_case(
    "try_auto_upgrade creates an item-request-proxy when items are missing",
    "integration|integration.housing-upgrades",
    function()
        local house = create_empty_house()
        house[EK.target_comfort] = 1

        Inhabitants.try_auto_upgrade(house)

        Assert.equals(house[EK.current_comfort], 0, "comfort should not have changed")
        Assert.not_nil(house[EK.entity].item_request_proxy, "a proxy should have been created")
        Assert.not_nil(house[EK.upgrade_slots], "upgrade_slots should be stored")
        Assert.greater_than(filter_count(chest_inv(house)), 0, "slot filters should be set")
    end,
    setup, teardown
)

Tirislib.Testing.add_test_case(
    "try_auto_upgrade does not create a duplicate proxy on repeated calls",
    "integration|integration.housing-upgrades",
    function()
        local house = create_empty_house()
        house[EK.target_comfort] = 1

        Inhabitants.try_auto_upgrade(house)
        local filters_after_first = filter_count(chest_inv(house))

        Inhabitants.try_auto_upgrade(house)

        Assert.equals(filter_count(chest_inv(house)), filters_after_first,
            "filter count should not change on second call")
        Assert.equals(house[EK.current_comfort], 0, "comfort should still be 0")
    end,
    setup, teardown
)

Tirislib.Testing.add_test_case(
    "try_auto_upgrade does not request items already present in the chest",
    "integration|integration.housing-upgrades",
    function()
        local house = create_empty_house()
        house[EK.target_comfort] = 1
        local cost = upgrade_cost(1) -- needs furniture

        -- Insert all but one furniture — a shortfall of 1 remains
        chest_inv(house).insert({name = cost[1].name, count = cost[1].count - 1})

        Inhabitants.try_auto_upgrade(house)

        -- Proxy should exist for the remaining 1 item, not the full cost
        Assert.not_nil(house[EK.entity].item_request_proxy)
        local slots = house[EK.upgrade_slots]
        Assert.not_nil(slots)
        -- 1 item with count=1 fits in exactly 1 slot
        Assert.equals(#slots, 1, "only one slot should be reserved for the remaining item")
    end,
    setup, teardown
)

Tirislib.Testing.add_test_case(
    "try_auto_upgrade immediately creates a proxy for the next level after a successful upgrade",
    "integration|integration.housing-upgrades",
    function()
        local house = create_empty_house()
        house[EK.target_comfort] = 2
        fill_chest(house, upgrade_cost(1))

        Inhabitants.try_auto_upgrade(house)

        Assert.equals(house[EK.current_comfort], 1, "comfort should have advanced to 1")
        Assert.not_nil(house[EK.entity].item_request_proxy,
            "a proxy for level 2 should be pre-created")
    end,
    setup, teardown
)

Tirislib.Testing.add_test_case(
    "assigning a caste to an empty house cancels any active upgrade proxy and clears slot filters",
    "integration|integration.housing-upgrades",
    function()
        local house = create_empty_house()
        house[EK.target_comfort] = 1
        Inhabitants.try_auto_upgrade(house) -- creates proxy
        Assert.not_nil(house[EK.entity].item_request_proxy, "proxy should exist before type change")

        local entity = house[EK.entity]
        Inhabitants.try_allow_for_caste(house, Type.clockwork, false)

        Assert.is_nil(entity.item_request_proxy, "proxy should be destroyed after type change")
        Assert.equals(filter_count(entity.get_inventory(defines.inventory.chest)), 0,
            "all slot filters should be cleared after type change")
    end,
    setup, teardown
)

Tirislib.Testing.add_test_case(
    "try_auto_upgrade never upgrades beyond max_comfort even when target exceeds it",
    "integration|integration.housing-upgrades",
    function()
        local house = create_empty_house()
        house[EK.current_comfort] = 9
        house[EK.target_comfort] = 999

        fill_chest(house, upgrade_cost(10))
        Inhabitants.try_auto_upgrade(house)

        Assert.equals(house[EK.current_comfort], 10, "comfort should reach max")

        -- Subsequent calls must not push past max
        Inhabitants.try_auto_upgrade(house)
        Assert.equals(house[EK.current_comfort], 10, "comfort must not exceed max_comfort")
        Assert.is_nil(house[EK.entity].item_request_proxy, "no proxy should be created at max")
    end,
    setup, teardown
)
