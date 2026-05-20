local EK = require("enums.entry-key")
local Type = require("enums.type")

local InhabitantsConstants = require("constants.inhabitants")
local ItemConstants = require("constants.item-constants")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface

local function setup()
    test_surface = Helpers.create_test_surface()
end

local function teardown()
    Helpers.clean_up()
end

Tirislib.Testing.add_test_case(
    "get_chest_inventory returns a valid inventory",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})

        local inventory = Inventories.get_chest_inventory(entry)
        Assert.not_nil(inventory, "should return an inventory")
        Assert.is_true(inventory.valid, "inventory should be valid")
    end,
    setup,
    teardown
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
    setup,
    teardown
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
    setup,
    teardown
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
    setup,
    teardown
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
    setup,
    teardown
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
    setup,
    teardown
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
    setup,
    teardown
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
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "cache_contents stores item counts accessible by item name",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", Helpers.next_position())
        local inventory = Inventories.get_chest_inventory(entry)
        inventory.insert {name = "iron-plate", count = 10}

        Inventories.cache_contents(entry)

        local cached = entry[EK.inventory_contents]
        Assert.equals(cached["iron-plate"], 10, "cached contents should be accessible by item name")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "output_eggs sends eggs to collector only, not to house, when collector is present",
    "integration|integration.inventories",
    function()
        local house_entry = Helpers.create_and_register(test_surface, "test-house", Helpers.next_position())
        -- place collector within range 42 so it becomes a neighbor automatically
        Helpers.create_and_register(test_surface, "test-egg-collector", Helpers.next_position())

        Consumption.output_eggs(house_entry, 5)

        local collector_neighbors = Neighborhood.get_by_type(house_entry, Type.egg_collector)
        Assert.greater_than(#collector_neighbors, 0, "house should have egg_collector neighbor")

        local collector_inv = Inventories.get_chest_inventory(collector_neighbors[1])
        local house_inv = Inventories.get_chest_inventory(house_entry)

        Assert.equals(
            collector_inv.get_item_count(InhabitantsConstants.egg_fertile),
            5,
            "collector should have all 5 eggs"
        )
        Assert.equals(
            house_inv.get_item_count(InhabitantsConstants.egg_fertile),
            0,
            "house should have no eggs when collector is present"
        )
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << get_combined_contents >>

Tirislib.Testing.add_test_case(
    "get_combined_contents merges distinct items from multiple inventories",
    "integration|integration.inventories",
    function()
        local entry1 = Helpers.create_and_register(test_surface, "test-market", Helpers.next_position())
        local entry2 = Helpers.create_and_register(test_surface, "test-market", Helpers.next_position())
        local inv1 = Inventories.get_chest_inventory(entry1)
        local inv2 = Inventories.get_chest_inventory(entry2)
        inv1.insert {name = "iron-plate", count = 10}
        inv2.insert {name = "copper-plate", count = 5}

        local combined = Inventories.get_combined_contents({inv1, inv2})
        Assert.equals(combined["iron-plate"], 10, "should include iron-plate from first inventory")
        Assert.equals(combined["copper-plate"], 5, "should include copper-plate from second inventory")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "get_combined_contents sums overlapping item counts across inventories",
    "integration|integration.inventories",
    function()
        local entry1 = Helpers.create_and_register(test_surface, "test-market", Helpers.next_position())
        local entry2 = Helpers.create_and_register(test_surface, "test-market", Helpers.next_position())
        local inv1 = Inventories.get_chest_inventory(entry1)
        local inv2 = Inventories.get_chest_inventory(entry2)
        inv1.insert {name = "iron-plate", count = 10}
        inv2.insert {name = "iron-plate", count = 7}

        local combined = Inventories.get_combined_contents({inv1, inv2})
        Assert.equals(combined["iron-plate"], 17, "should sum counts of the same item across inventories")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << try_insert_into_inventory_range >>

Tirislib.Testing.add_test_case(
    "try_insert_into_inventory_range with count 0 returns 0",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", Helpers.next_position())
        local inv = Inventories.get_chest_inventory(entry)

        local inserted = Inventories.try_insert_into_inventory_range({inv}, "iron-plate", 0, true)
        Assert.equals(inserted, 0, "should insert nothing")
        Assert.equals(inv.get_item_count("iron-plate"), 0, "inventory should remain empty")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "try_insert_into_inventory_range inserts into the first inventory when it has space",
    "integration|integration.inventories",
    function()
        local entry1 = Helpers.create_and_register(test_surface, "test-market", Helpers.next_position())
        local entry2 = Helpers.create_and_register(test_surface, "test-market", Helpers.next_position())
        local inv1 = Inventories.get_chest_inventory(entry1)
        local inv2 = Inventories.get_chest_inventory(entry2)

        local inserted = Inventories.try_insert_into_inventory_range({inv1, inv2}, "iron-plate", 10, true)
        Assert.equals(inserted, 10, "all items should be inserted")
        Assert.equals(inv1.get_item_count("iron-plate"), 10, "items should go into the first inventory")
        Assert.equals(inv2.get_item_count("iron-plate"), 0, "second inventory should be untouched")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "try_insert_into_inventory_range overflows to the next inventory when the first is full",
    "integration|integration.inventories",
    function()
        local entry1 = Helpers.create_and_register(test_surface, "test-market", Helpers.next_position())
        local entry2 = Helpers.create_and_register(test_surface, "test-market", Helpers.next_position())
        local inv1 = Inventories.get_chest_inventory(entry1)
        local inv2 = Inventories.get_chest_inventory(entry2)
        local stack_size = prototypes.item["iron-plate"].stack_size
        inv1.set_bar(2) -- first inaccessible slot = 2; only slot 1 is usable
        inv1.insert {name = "iron-plate", count = stack_size - 3} -- leave 3 spaces in that slot

        local inserted = Inventories.try_insert_into_inventory_range({inv1, inv2}, "iron-plate", 10, true)
        Assert.equals(inserted, 10, "all 10 should be inserted across both inventories")
        Assert.equals(inv1.get_item_count("iron-plate"), stack_size, "first inventory should be full after absorbing 3")
        Assert.equals(inv2.get_item_count("iron-plate"), 7, "remaining 7 should overflow to second inventory")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << try_remove_item_range >>

Tirislib.Testing.add_test_case(
    "try_remove_item_range removes all requested items and returns true when all are present",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", Helpers.next_position())
        local inv = Inventories.get_chest_inventory(entry)
        inv.insert {name = "iron-plate", count = 10}
        inv.insert {name = "copper-plate", count = 5}

        local result = Inventories.try_remove_item_range(entry, {["iron-plate"] = 5, ["copper-plate"] = 3}, true)
        Assert.is_true(result, "should return true when all items are present")
        Assert.equals(inv.get_item_count("iron-plate"), 5, "remaining iron-plate should be 5")
        Assert.equals(inv.get_item_count("copper-plate"), 2, "remaining copper-plate should be 2")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "try_remove_item_range returns false and removes nothing when a required item is absent",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", Helpers.next_position())
        local inv = Inventories.get_chest_inventory(entry)
        inv.insert {name = "iron-plate", count = 10}

        local result = Inventories.try_remove_item_range(entry, {["iron-plate"] = 5, ["copper-plate"] = 3}, true)
        Assert.is_false(result, "should return false when a required item is absent")
        Assert.equals(inv.get_item_count("iron-plate"), 10, "iron-plate should be untouched on failure")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "try_remove_item_range returns false and removes nothing when a required item count is insufficient",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", Helpers.next_position())
        local inv = Inventories.get_chest_inventory(entry)
        inv.insert {name = "iron-plate", count = 3}

        local result = Inventories.try_remove_item_range(entry, {["iron-plate"] = 10}, true)
        Assert.is_false(result, "should return false when count is insufficient")
        Assert.equals(inv.get_item_count("iron-plate"), 3, "inventory should be untouched on failure")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << remove_item_range_from_inventory_range >>

Tirislib.Testing.add_test_case(
    "remove_item_range_from_inventory_range removes items spread across multiple inventories",
    "integration|integration.inventories",
    function()
        local entry1 = Helpers.create_and_register(test_surface, "test-market", Helpers.next_position())
        local entry2 = Helpers.create_and_register(test_surface, "test-market", Helpers.next_position())
        local inv1 = Inventories.get_chest_inventory(entry1)
        local inv2 = Inventories.get_chest_inventory(entry2)
        inv1.insert {name = "iron-plate", count = 3}
        inv2.insert {name = "iron-plate", count = 7}

        Inventories.remove_item_range_from_inventory_range({inv1, inv2}, {["iron-plate"] = 8})
        Assert.equals(inv1.get_item_count("iron-plate"), 0, "first inventory should be fully drained first")
        Assert.equals(inv2.get_item_count("iron-plate"), 2, "remainder should be removed from second inventory")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << try_move >>

Tirislib.Testing.add_test_case(
    "try_move transfers items from source to destination when space is available",
    "integration|integration.inventories",
    function()
        local entry1 = Helpers.create_and_register(test_surface, "test-market", Helpers.next_position())
        local entry2 = Helpers.create_and_register(test_surface, "test-market", Helpers.next_position())
        local src = Inventories.get_chest_inventory(entry1)
        local dst = Inventories.get_chest_inventory(entry2)
        src.insert {name = "iron-plate", count = 10}

        local moved = Inventories.try_move("iron-plate", 10, src, dst)
        Assert.equals(moved, 10, "all 10 items should be moved")
        Assert.equals(src.get_item_count("iron-plate"), 0, "source should be empty after move")
        Assert.equals(dst.get_item_count("iron-plate"), 10, "destination should have all the moved items")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "try_move returns 0 and leaves source unchanged when destination is full",
    "integration|integration.inventories",
    function()
        local entry1 = Helpers.create_and_register(test_surface, "test-market", Helpers.next_position())
        local entry2 = Helpers.create_and_register(test_surface, "test-market", Helpers.next_position())
        local src = Inventories.get_chest_inventory(entry1)
        local dst = Inventories.get_chest_inventory(entry2)
        src.insert {name = "iron-plate", count = 10}
        dst.insert {name = "iron-plate", count = 999999} -- fill destination completely

        local moved = Inventories.try_move("iron-plate", 10, src, dst)
        Assert.equals(moved, 0, "should move nothing when destination is full")
        Assert.equals(src.get_item_count("iron-plate"), 10, "source should be unchanged")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "try_move transfers only as many items as fit in the destination",
    "integration|integration.inventories",
    function()
        local entry1 = Helpers.create_and_register(test_surface, "test-market", Helpers.next_position())
        local entry2 = Helpers.create_and_register(test_surface, "test-market", Helpers.next_position())
        local src = Inventories.get_chest_inventory(entry1)
        local dst = Inventories.get_chest_inventory(entry2)
        src.insert {name = "iron-plate", count = 10}
        local stack_size = prototypes.item["iron-plate"].stack_size
        dst.set_bar(2) -- limit destination to 1 accessible slot
        dst.insert {name = "iron-plate", count = stack_size - 3} -- leave 3 spaces

        local moved = Inventories.try_move("iron-plate", 10, src, dst)
        Assert.equals(moved, 3, "should only move what fits in the destination")
        Assert.equals(src.get_item_count("iron-plate"), 7, "source should retain the unmoved items")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << output_eggs - additional paths >>

Tirislib.Testing.add_test_case(
    "output_eggs falls back to the house inventory when no egg collector is in range",
    "integration|integration.inventories",
    function()
        local house_entry = Helpers.create_and_register(test_surface, "test-house", Helpers.next_position())

        Consumption.output_eggs(house_entry, 5)

        Assert.equals(
            Inventories.get_chest_inventory(house_entry).get_item_count(InhabitantsConstants.egg_fertile),
            5,
            "eggs should go to house inventory when no collector is in range"
        )
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "output_eggs respects the 20-egg cap in the house inventory",
    "integration|integration.inventories",
    function()
        local house_entry = Helpers.create_and_register(test_surface, "test-house", Helpers.next_position())
        local house_inv = Inventories.get_chest_inventory(house_entry)
        house_inv.insert {name = InhabitantsConstants.egg_fertile, count = 18}

        Consumption.output_eggs(house_entry, 10)

        Assert.equals(
            house_inv.get_item_count(InhabitantsConstants.egg_fertile),
            20,
            "house inventory should not exceed 20 eggs"
        )
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "output_eggs sends only the remainder to the house when a collector is partially full",
    "integration|integration.inventories",
    function()
        local house_entry = Helpers.create_and_register(test_surface, "test-house", Helpers.next_position())
        local collector_entry = Helpers.create_and_register(test_surface, "test-egg-collector", Helpers.next_position())
        local egg_name = InhabitantsConstants.egg_fertile
        local stack_size = prototypes.item[egg_name].stack_size
        local collector_inv = Inventories.get_chest_inventory(collector_entry)
        collector_inv.set_bar(2) -- only 1 slot accessible
        collector_inv.insert {name = egg_name, count = stack_size - 3} -- leave 3 spaces

        Consumption.output_eggs(house_entry, 5)

        -- collector absorbs 3; house should receive exactly the 2 remaining eggs, not the full 5
        Assert.equals(collector_inv.get_item_count(egg_name), stack_size, "collector should be full (absorbed 3)")
        Assert.equals(
            Inventories.get_chest_inventory(house_entry).get_item_count(egg_name),
            2,
            "house should receive only the 2 remaining eggs"
        )
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "output_eggs skips an inactive collector and falls back to the house inventory",
    "integration|integration.inventories",
    function()
        local house_entry = Helpers.create_and_register(test_surface, "test-house", Helpers.next_position())
        local collector_entry = Helpers.create_and_register(test_surface, "test-egg-collector", Helpers.next_position())

        -- test-egg-collector has no power_usage, so has_power always returns true for it.
        -- Force the inactive path by (1) giving it a fake power requirement so has_power uses
        -- the EEI energy check, (2) materialising the EEI (first call returns true but creates
        -- the entity with 0 energy since there is no power grid in tests), and (3) clearing
        -- EK.active so the cached-true short-circuit in Entity.is_active is not taken.
        collector_entry[EK.power_usage] = 1
        Subentities.has_power(collector_entry) -- creates EEI; subsequent calls see energy == 0
        collector_entry[EK.active] = false

        Consumption.output_eggs(house_entry, 5)

        Assert.equals(
            Inventories.get_chest_inventory(collector_entry).get_item_count(InhabitantsConstants.egg_fertile),
            0,
            "inactive collector should receive no eggs"
        )
        Assert.equals(
            Inventories.get_chest_inventory(house_entry).get_item_count(InhabitantsConstants.egg_fertile),
            5,
            "eggs should fall back to the house inventory when the collector is inactive"
        )
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << remove_eggs >>

Tirislib.Testing.add_test_case(
    "remove_eggs removes up to max_count eggs and returns a map of what was removed",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-house", Helpers.next_position())
        local inv = Inventories.get_chest_inventory(entry)
        inv.insert {name = InhabitantsConstants.egg_fertile, count = 10}

        local removed = Consumption.remove_eggs(entry, 6)

        local total = 0
        for _, count in pairs(removed) do
            total = total + count
        end
        Assert.equals(total, 6, "should remove exactly max_count eggs in total")
        Assert.equals(inv.get_item_count(InhabitantsConstants.egg_fertile), 4, "inventory should have 4 eggs left")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "remove_eggs removes only what is available when max_count exceeds the inventory",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-house", Helpers.next_position())
        local inv = Inventories.get_chest_inventory(entry)
        inv.insert {name = InhabitantsConstants.egg_fertile, count = 3}

        local removed = Consumption.remove_eggs(entry, 10)

        local total = 0
        for _, count in pairs(removed) do
            total = total + count
        end
        Assert.equals(total, 3, "should remove only the 3 eggs that are available")
        Assert.equals(inv.get_item_count(InhabitantsConstants.egg_fertile), 0, "inventory should be empty")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << produce_garbage >>

Tirislib.Testing.add_test_case(
    "produce_garbage deposits garbage into an active dumpster neighbor",
    "integration|integration.inventories",
    function()
        local house_entry = Helpers.create_and_register(test_surface, "test-house", Helpers.next_position())
        local dumpster_entry = Helpers.create_and_register(test_surface, "test-dumpster", Helpers.next_position())

        Consumption.produce_garbage(house_entry, "garbage", 10)

        Assert.equals(
            Inventories.get_chest_inventory(dumpster_entry).get_item_count("garbage"),
            10,
            "garbage should go to the dumpster"
        )
        Assert.equals(
            Inventories.get_chest_inventory(house_entry).get_item_count("garbage"),
            0,
            "garbage should not land in the house inventory when a dumpster accepted it"
        )
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "produce_garbage falls back to the house inventory when no dumpster is in range",
    "integration|integration.inventories",
    function()
        local house_entry = Helpers.create_and_register(test_surface, "test-house", Helpers.next_position())

        Consumption.produce_garbage(house_entry, "garbage", 5)

        Assert.equals(
            Inventories.get_chest_inventory(house_entry).get_item_count("garbage"),
            5,
            "garbage should land in the house inventory when no dumpster is in range"
        )
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "produce_garbage spills items to the ground when both dumpster and house inventory are full",
    "integration|integration.inventories",
    function()
        local house_entry = Helpers.create_and_register(test_surface, "test-house", Helpers.next_position())
        -- no dumpster in range; fill the house inventory completely
        Inventories.get_chest_inventory(house_entry).insert {name = "iron-plate", count = 999999}

        Consumption.produce_garbage(house_entry, "garbage", 3)

        local spilled = test_surface.find_entities_filtered {type = "item-entity"}
        Assert.greater_than(#spilled, 0, "garbage should be spilled to the ground when all storage is full")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "produce_garbage sends the remainder to the house inventory when the dumpster is partially full",
    "integration|integration.inventories",
    function()
        local house_entry = Helpers.create_and_register(test_surface, "test-house", Helpers.next_position())
        local dumpster_entry = Helpers.create_and_register(test_surface, "test-dumpster", Helpers.next_position())
        local stack_size = prototypes.item["garbage"].stack_size
        local dumpster_inv = Inventories.get_chest_inventory(dumpster_entry)
        dumpster_inv.set_bar(2) -- only 1 slot accessible
        dumpster_inv.insert {name = "garbage", count = stack_size - 3} -- leave 3 spaces

        Consumption.produce_garbage(house_entry, "garbage", 10)

        Assert.equals(dumpster_inv.get_item_count("garbage"), stack_size, "dumpster should be full after absorbing 3")
        Assert.equals(
            Inventories.get_chest_inventory(house_entry).get_item_count("garbage"),
            7,
            "remaining 7 should overflow to the house inventory"
        )
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << get_garbage_value >>

Tirislib.Testing.add_test_case(
    "get_garbage_value returns 0 when no garbage items are in the inventory",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-house", Helpers.next_position())
        Inventories.get_chest_inventory(entry).insert {name = "iron-plate", count = 10}

        Assert.equals(Consumption.get_garbage_value(entry), 0, "non-garbage items should contribute 0 garbage value")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "get_garbage_value returns the correct weighted sum for garbage items",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-house", Helpers.next_position())
        Inventories.get_chest_inventory(entry).insert {name = "garbage", count = 10}

        local expected = ItemConstants.garbage_values["garbage"] * 10
        Assert.equals(Consumption.get_garbage_value(entry), expected, "value should be count times the garbage multiplier")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "get_garbage_value moves garbage to a dumpster and returns the residual value",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-house", Helpers.next_position())
        local dumpster_entry = Helpers.create_and_register(test_surface, "test-dumpster", Helpers.next_position())
        Inventories.get_chest_inventory(entry).insert {name = "garbage", count = 10}

        local value = Consumption.get_garbage_value(entry)

        Assert.equals(value, 0, "garbage value should be 0 after all garbage is moved to the dumpster")
        Assert.equals(
            Inventories.get_chest_inventory(dumpster_entry).get_item_count("garbage"),
            10,
            "garbage should have been moved to the dumpster"
        )
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "get_garbage_value applies the correct per-type multiplier for each garbage item",
    "integration|integration.inventories",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-house", Helpers.next_position())
        -- no dumpster in range so items are not moved and the full value is computed
        local inv = Inventories.get_chest_inventory(entry)
        inv.insert {name = "garbage", count = 4}
        inv.insert {name = "slaughter-waste", count = 2}

        local expected =
            ItemConstants.garbage_values["garbage"] * 4 +
            ItemConstants.garbage_values["slaughter-waste"] * 2
        Assert.equals(Consumption.get_garbage_value(entry), expected, "each item type should use its own multiplier")
    end,
    setup,
    teardown
)
