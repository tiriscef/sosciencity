local EK = require("enums.entry-key")
local HousingTrait = require("enums.housing-trait")
local Type = require("enums.type")
local Housing = require("constants.housing")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface

local function setup()
    test_surface = Helpers.create_test_surface()
    storage.technologies["upbringing"] = 1
    -- comfort levels 1-10 require architecture-1 through architecture-7
    for i = 1, 7 do
        storage.technologies["architecture-" .. i] = 1
    end
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

local function has_filter_for(inventory, item_name)
    for i = 1, #inventory do
        local filter = inventory.get_filter(i)
        if filter and filter.name == item_name then
            return true
        end
    end
    return false
end

local function assert_all_consumed(entry, items)
    local inv = chest_inv(entry)
    for _, item in pairs(items) do
        Assert.equals(inv.get_item_count(item.name), 0, item.name .. " should be consumed")
    end
end

local function assert_none_consumed(entry, items)
    local inv = chest_inv(entry)
    for _, item in pairs(items) do
        Assert.equals(inv.get_item_count(item.name), item.count, item.name .. " should not be consumed")
    end
end

local function assert_has_filters_for_cost(inventory, items)
    for _, item in pairs(items) do
        Assert.is_true(has_filter_for(inventory, item.name), "proxy should include " .. item.name)
    end
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
    "try_auto_upgrades upgrades comfort, consumes items, and leaves no proxy or filters",
    "integration|integration.housing-upgrades",
    function()
        local house = create_empty_house()
        house[EK.target_comfort] = 1
        fill_chest(house, upgrade_cost(1))

        Inhabitants.try_auto_upgrades(house)

        Assert.equals(house[EK.current_comfort], 1, "comfort should have increased to 1")
        assert_all_consumed(house, upgrade_cost(1))
        Assert.equals(filter_count(chest_inv(house)), 0, "all slot filters should be cleared")
        Assert.is_nil(house[EK.entity].item_request_proxy, "no proxy should remain")
        Assert.is_nil(house[EK.item_requests], "item_requests should be cleared")
    end,
    setup, teardown
)

Tirislib.Testing.add_test_case(
    "try_auto_upgrades creates an item-request-proxy when items are missing",
    "integration|integration.housing-upgrades",
    function()
        local house = create_empty_house()
        house[EK.target_comfort] = 1

        Inhabitants.try_auto_upgrades(house)

        Assert.equals(house[EK.current_comfort], 0, "comfort should not have changed")
        Assert.not_nil(house[EK.entity].item_request_proxy, "a proxy should have been created")
        Assert.not_nil(house[EK.item_requests], "item_requests should be stored")
        Assert.greater_than(filter_count(chest_inv(house)), 0, "slot filters should be set")
    end,
    setup, teardown
)

Tirislib.Testing.add_test_case(
    "try_auto_upgrades does not create a duplicate proxy on repeated calls",
    "integration|integration.housing-upgrades",
    function()
        local house = create_empty_house()
        house[EK.target_comfort] = 1

        Inhabitants.try_auto_upgrades(house)
        local filters_after_first = filter_count(chest_inv(house))

        Inhabitants.try_auto_upgrades(house)

        Assert.equals(filter_count(chest_inv(house)), filters_after_first,
            "filter count should not change on second call")
        Assert.equals(house[EK.current_comfort], 0, "comfort should still be 0")
    end,
    setup, teardown
)

Tirislib.Testing.add_test_case(
    "try_auto_upgrades does not request items already present in the chest",
    "integration|integration.housing-upgrades",
    function()
        local house = create_empty_house()
        house[EK.target_comfort] = 1
        local cost = upgrade_cost(1) -- needs furniture

        -- Insert all but one furniture — a shortfall of 1 remains
        chest_inv(house).insert({name = cost[1].name, count = cost[1].count - 1})

        Inhabitants.try_auto_upgrades(house)

        -- Proxy should exist for the remaining 1 item, not the full cost
        Assert.not_nil(house[EK.entity].item_request_proxy)
        local data = house[EK.item_requests]
        Assert.not_nil(data)
        -- 1 item with count=1 fits in exactly 1 slot
        Assert.equals(#data.slots, 1, "only one slot should be reserved for the remaining item")
    end,
    setup, teardown
)

Tirislib.Testing.add_test_case(
    "try_auto_upgrades immediately creates a proxy for the next level after a successful upgrade",
    "integration|integration.housing-upgrades",
    function()
        local house = create_empty_house()
        house[EK.target_comfort] = 2
        fill_chest(house, upgrade_cost(1))

        Inhabitants.try_auto_upgrades(house)

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
        Inhabitants.try_auto_upgrades(house) -- creates proxy
        Assert.not_nil(house[EK.entity].item_request_proxy, "proxy should exist before type change")

        local entity = house[EK.entity]
        Inhabitants.try_allow_for_caste(house, Type.clockwork, false)

        Assert.is_nil(entity.item_request_proxy, "proxy should be destroyed after type change")
        Assert.equals(filter_count(entity.get_inventory(defines.inventory.chest)), 0,
            "all slot filters should be cleared after type change")
    end,
    setup, teardown
)

---------------------------------------------------------------------------------------------------
-- << phase 6 — tag upgrade tests >>

local function tag_cost(tag)
    return Housing.get_tag_cost(Housing.values["test-house"], tag)
end

local function setup_with_tags()
    test_surface = Helpers.create_test_surface()
    storage.technologies["upbringing"] = 1
    storage.technologies["architecture-1"] = 1
    storage.technologies["architecture-3"] = 1
end

---------------------------------------------------------------------------------------------------

Tirislib.Testing.add_test_case(
    "try_auto_upgrades never upgrades beyond max_comfort even when target exceeds it",
    "integration|integration.housing-upgrades",
    function()
        local house = create_empty_house()
        house[EK.current_comfort] = 9
        house[EK.target_comfort] = 999

        fill_chest(house, upgrade_cost(10))
        Inhabitants.try_auto_upgrades(house)

        Assert.equals(house[EK.current_comfort], 10, "comfort should reach max")

        -- Subsequent calls must not push past max
        Inhabitants.try_auto_upgrades(house)
        Assert.equals(house[EK.current_comfort], 10, "comfort must not exceed max_comfort")
        Assert.is_nil(house[EK.entity].item_request_proxy, "no proxy should be created at max")
    end,
    setup, teardown
)

Tirislib.Testing.add_test_case(
    "try_auto_upgrades applies a requested tag when items are present in the chest",
    "integration|integration.housing-upgrades",
    function()
        local house = create_empty_house()
        house[EK.target_tags] = {[HousingTrait.green] = true}
        fill_chest(house, tag_cost(HousingTrait.green))

        Inhabitants.try_auto_upgrades(house)

        local upgrades = house[EK.trait_upgrades]
        Assert.not_nil(upgrades, "trait_upgrades should be set")
        Assert.is_true(upgrades[HousingTrait.green], "green tag should be applied")
        assert_all_consumed(house, tag_cost(HousingTrait.green))
        Assert.is_nil(house[EK.entity].item_request_proxy, "no proxy should remain after fulfillment")
    end,
    setup_with_tags, teardown
)

Tirislib.Testing.add_test_case(
    "try_auto_upgrades creates a proxy for a requested tag when items are missing",
    "integration|integration.housing-upgrades",
    function()
        local house = create_empty_house()
        house[EK.target_tags] = {[HousingTrait.green] = true}

        Inhabitants.try_auto_upgrades(house)

        local upgrades = house[EK.trait_upgrades]
        Assert.is_true(not upgrades or not upgrades[HousingTrait.green], "tag should not be applied without items")
        Assert.not_nil(house[EK.entity].item_request_proxy, "a proxy should be created")
        Assert.greater_than(filter_count(chest_inv(house)), 0, "slot filters should be set")
    end,
    setup_with_tags, teardown
)

Tirislib.Testing.add_test_case(
    "try_auto_upgrades does not re-apply a tag already in trait_upgrades",
    "integration|integration.housing-upgrades",
    function()
        local house = create_empty_house()
        house[EK.target_tags] = {[HousingTrait.green] = true}
        house[EK.trait_upgrades] = {[HousingTrait.green] = true}
        local cost = tag_cost(HousingTrait.green)
        fill_chest(house, cost)

        Inhabitants.try_auto_upgrades(house)

        assert_none_consumed(house, cost)
    end,
    setup_with_tags, teardown
)

Tirislib.Testing.add_test_case(
    "try_request_tag adds the tag to target_tags and creates a proxy",
    "integration|integration.housing-upgrades",
    function()
        local house = create_empty_house()

        Inhabitants.try_request_tag(house, HousingTrait.green)

        Assert.not_nil(house[EK.target_tags], "target_tags should be set")
        Assert.is_true(house[EK.target_tags][HousingTrait.green], "green should be in target_tags")
        Assert.not_nil(house[EK.entity].item_request_proxy, "a proxy should be created")
        Assert.greater_than(filter_count(chest_inv(house)), 0, "slot filters should be set")
    end,
    setup_with_tags, teardown
)

Tirislib.Testing.add_test_case(
    "cancel_target_tag removes the tag and cancels the proxy when no other requests remain",
    "integration|integration.housing-upgrades",
    function()
        local house = create_empty_house()
        Inhabitants.try_request_tag(house, HousingTrait.green)
        Assert.not_nil(house[EK.entity].item_request_proxy, "proxy should exist before cancel")

        Inhabitants.cancel_target_tag(house, HousingTrait.green)

        Assert.is_nil(house[EK.target_tags], "target_tags should be cleared")
        Assert.is_nil(house[EK.entity].item_request_proxy, "proxy should be destroyed after cancel")
        Assert.equals(filter_count(chest_inv(house)), 0, "all slot filters should be cleared")
    end,
    setup_with_tags, teardown
)

Tirislib.Testing.add_test_case(
    "combined comfort and tag request uses a single proxy covering both item types",
    "integration|integration.housing-upgrades",
    function()
        local house = create_empty_house()
        house[EK.target_comfort] = 1              -- furniture: 1 item type → 1 slot
        house[EK.target_tags] = {[HousingTrait.green] = true}  -- phytofall-blossom: 1 item type → 1 slot

        Inhabitants.try_auto_upgrades(house)

        local inv = chest_inv(house)
        Assert.not_nil(house[EK.entity].item_request_proxy, "a combined proxy should exist")
        assert_has_filters_for_cost(inv, upgrade_cost(1))
        assert_has_filters_for_cost(inv, tag_cost(HousingTrait.green))
    end,
    setup_with_tags, teardown
)

Tirislib.Testing.add_test_case(
    "target_tags is preserved when assigning a caste to an empty house",
    "integration|integration.housing-upgrades",
    function()
        local house = create_empty_house()
        house[EK.target_tags] = {[HousingTrait.green] = true}

        local inhabited = Inhabitants.try_allow_for_caste(house, Type.clockwork, false)

        Assert.not_nil(inhabited, "caste assignment should succeed")
        Assert.not_nil(inhabited[EK.target_tags], "target_tags should be preserved after type change")
        Assert.is_true(inhabited[EK.target_tags][HousingTrait.green],
            "green tag request should survive caste assignment")
    end,
    setup_with_tags, teardown
)
