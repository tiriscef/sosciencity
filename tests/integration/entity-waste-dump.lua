local DeconstructionCause = require("enums.deconstruction-cause")
local EK = require("enums.entry-key")
local Type = require("enums.type")
local WasteDumpOperationMode = require("enums.waste-dump-operation-mode")

local Buildings = require("constants.buildings")
local Time = require("constants.time")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local Table = Tirislib.Tables

local test_surface

local function setup()
    test_surface = Helpers.create_test_surface()
end

local function teardown()
    Helpers.clean_up()
end

local function make_dump(position)
    return Helpers.create_and_register(test_surface, "test-waste-dump", position)
end

--- Runs update with delta_ticks = n ticks from current tick.
local function do_update(entry, delta_ticks)
    Register.update_entry(entry, game.tick + delta_ticks)
end

---------------------------------------------------------------------------------------------------
-- << creation >>

Tirislib.Testing.add_test_case(
    "waste dump: creation initializes all entry fields to defaults",
    "integration|integration.waste-dump",
    function()
        local entry = make_dump(Helpers.next_position())

        Assert.equals(Table.sum(entry[EK.stored_garbage]), 0, "stored_garbage should be empty")
        Assert.equals(entry[EK.waste_dump_mode], WasteDumpOperationMode.store, "mode should default to store")
        Assert.equals(entry[EK.press_mode], false, "press_mode should default to false")
        Assert.equals(entry[EK.store_progress], 0, "store_progress should start at 0")
        Assert.equals(entry[EK.garbagify_progress], 0, "garbagify_progress should start at 0")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << store mode >>

-- dump_store_rate = 200 items/second; delta_ticks=Time.second stores floor(200) = 200 items,
-- which exceeds our small test inventory so all items are stored regardless of count.

Tirislib.Testing.add_test_case(
    "waste dump: store mode moves garbage items from chest to stored_garbage",
    "integration|integration.waste-dump",
    function()
        local entry = make_dump(Helpers.next_position())
        local inventory = Inventories.get_chest_inventory(entry)
        inventory.insert {name = "garbage", count = 10}

        do_update(entry, Time.second)

        Assert.equals(inventory.get_item_count("garbage"), 0, "garbage should be removed from chest")
        Assert.equals(entry[EK.stored_garbage]["garbage"], 10, "stored_garbage should have 10 garbage")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "waste dump: store mode leaves non-garbage items in chest",
    "integration|integration.waste-dump",
    function()
        local entry = make_dump(Helpers.next_position())
        local inventory = Inventories.get_chest_inventory(entry)
        inventory.insert {name = "iron-plate", count = 10}

        do_update(entry, Time.second)

        Assert.equals(inventory.get_item_count("iron-plate"), 10, "non-garbage should remain in chest")
        Assert.equals(Table.sum(entry[EK.stored_garbage]), 0, "stored_garbage should stay empty")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "waste dump: store mode does not store when chest garbage count meets or exceeds capacity",
    "integration|integration.waste-dump",
    function()
        -- capacity = 50; put 55 garbage items in chest → to_store = min(200, 50 - 55) = -5 → nothing stored
        local entry = make_dump(Helpers.next_position())
        local inventory = Inventories.get_chest_inventory(entry)
        inventory.insert {name = "garbage", count = 55}

        do_update(entry, Time.second)

        Assert.equals(inventory.get_item_count("garbage"), 55, "garbage should remain in chest when over capacity")
        Assert.equals(Table.sum(entry[EK.stored_garbage]), 0, "stored_garbage should stay empty")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << output mode >>

-- dump_output_rate = 400 items/second; delta_ticks=Time.second outputs floor(400) = 400 items.

Tirislib.Testing.add_test_case(
    "waste dump: output mode inserts stored_garbage into chest",
    "integration|integration.waste-dump",
    function()
        local entry = make_dump(Helpers.next_position())
        entry[EK.waste_dump_mode] = WasteDumpOperationMode.output
        entry[EK.stored_garbage] = {["garbage"] = 10}

        do_update(entry, Time.second)

        local inventory = Inventories.get_chest_inventory(entry)
        Assert.equals(inventory.get_item_count("garbage"), 10, "chest should contain output garbage")
        Assert.equals(entry[EK.stored_garbage]["garbage"], nil, "stored_garbage entry should be cleared")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << neutral mode >>

Tirislib.Testing.add_test_case(
    "waste dump: neutral mode does not move garbage and resets store_progress to 0",
    "integration|integration.waste-dump",
    function()
        local entry = make_dump(Helpers.next_position())
        entry[EK.waste_dump_mode] = WasteDumpOperationMode.neutral
        entry[EK.store_progress] = 5
        local inventory = Inventories.get_chest_inventory(entry)
        inventory.insert {name = "garbage", count = 5}

        do_update(entry, Time.second)

        Assert.equals(inventory.get_item_count("garbage"), 5, "garbage should stay in chest in neutral mode")
        Assert.equals(Table.sum(entry[EK.stored_garbage]), 0, "stored_garbage should remain empty")
        Assert.equals(entry[EK.store_progress], 0, "store_progress should be reset to 0 in neutral mode")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << garbagify >>

-- press_garbagify_rate = 2 items/tick; with delta_ticks=Time.second and no stored_garbage:
-- garbagify_progress = 60 * 2 = 120 → to_garbagify = 120.
-- With 10 non-garbage items in chest, all 10 are converted.

Tirislib.Testing.add_test_case(
    "waste dump: press mode garbagifies non-garbage items in chest",
    "integration|integration.waste-dump",
    function()
        local entry = make_dump(Helpers.next_position())
        entry[EK.waste_dump_mode] = WasteDumpOperationMode.neutral
        entry[EK.press_mode] = true
        local inventory = Inventories.get_chest_inventory(entry)
        inventory.insert {name = "iron-plate", count = 10}

        do_update(entry, Time.second)

        Assert.equals(inventory.get_item_count("iron-plate"), 0, "non-garbage items should be consumed by garbagify")
        Assert.equals(entry[EK.stored_garbage]["garbage"], 10, "garbagified items should appear as garbage in stored_garbage")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "waste dump: organic garbagify rate (from stored garbage count) converts non-garbage items without press mode",
    "integration|integration.waste-dump",
    function()
        -- (30 / 6000)^0.2 ≈ 0.347 items/tick; delta_ticks=Time.second → floor(60 * 0.347) = 20 garbagified
        -- Starting at 30 keeps the final total (40) under the test capacity (50), so over-capacity does not trigger.
        local entry = make_dump(Helpers.next_position())
        entry[EK.waste_dump_mode] = WasteDumpOperationMode.neutral
        entry[EK.stored_garbage] = {["garbage"] = 30}
        local inventory = Inventories.get_chest_inventory(entry)
        inventory.insert {name = "iron-plate", count = 10}

        do_update(entry, Time.second)

        Assert.equals(inventory.get_item_count("iron-plate"), 0, "non-garbage should be garbagified by organic rate")
        Assert.equals(entry[EK.stored_garbage]["garbage"], 40, "garbagified items should be added to stored_garbage as garbage")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "waste dump: without press mode and no stored garbage, garbagify does not run",
    "integration|integration.waste-dump",
    function()
        -- (0 / 6000)^0.2 = 0; press_garbagify_rate = 0 → no garbagify progress
        local entry = make_dump(Helpers.next_position())
        entry[EK.waste_dump_mode] = WasteDumpOperationMode.neutral
        local inventory = Inventories.get_chest_inventory(entry)
        inventory.insert {name = "iron-plate", count = 10}

        do_update(entry, Time.second)

        Assert.equals(inventory.get_item_count("iron-plate"), 10, "non-garbage should be untouched without press mode")
        Assert.equals(Table.sum(entry[EK.stored_garbage]), 0, "stored_garbage should remain empty")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "waste dump: garbagify does not touch garbage-classified items in chest",
    "integration|integration.waste-dump",
    function()
        -- garbage items appear in garbage_items, not non_garbage_items; garbagify only targets non_garbage_items
        local entry = make_dump(Helpers.next_position())
        entry[EK.waste_dump_mode] = WasteDumpOperationMode.neutral
        entry[EK.press_mode] = true
        local inventory = Inventories.get_chest_inventory(entry)
        inventory.insert {name = "food-leftovers", count = 5}

        do_update(entry, Time.second)

        Assert.equals(inventory.get_item_count("food-leftovers"), 5, "garbage-classified items should not be garbagified")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << over-capacity >>

Tirislib.Testing.add_test_case(
    "waste dump: stored_garbage exceeding capacity is pushed back to chest",
    "integration|integration.waste-dump",
    function()
        -- capacity = 50; set stored_garbage to 60 → over_capacity = 10 → output 10 to chest
        local entry = make_dump(Helpers.next_position())
        entry[EK.waste_dump_mode] = WasteDumpOperationMode.neutral
        entry[EK.stored_garbage] = {["garbage"] = 60}

        do_update(entry, 1)

        local inventory = Inventories.get_chest_inventory(entry)
        Assert.equals(inventory.get_item_count("garbage"), 10, "10 excess items should have been output to chest")
        Assert.equals(entry[EK.stored_garbage]["garbage"], 50, "stored_garbage should be trimmed to capacity")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << minable flag >>

Tirislib.Testing.add_test_case(
    "waste dump: entity is not minable when stored_garbage reaches 1000",
    "integration|integration.waste-dump",
    function()
        local entry = make_dump(Helpers.next_position())
        entry[EK.waste_dump_mode] = WasteDumpOperationMode.neutral
        entry[EK.stored_garbage] = {["garbage"] = 1000}

        do_update(entry, 1)

        Assert.equals(entry[EK.entity].minable, false, "entity should not be minable with >= 1000 stored garbage")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "waste dump: entity remains minable when stored_garbage is below 1000",
    "integration|integration.waste-dump",
    function()
        local entry = make_dump(Helpers.next_position())
        entry[EK.waste_dump_mode] = WasteDumpOperationMode.neutral
        entry[EK.stored_garbage] = {["garbage"] = 999}

        do_update(entry, 1)

        Assert.equals(entry[EK.entity].minable, true, "entity should remain minable with < 1000 stored garbage")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << copy >>

Tirislib.Testing.add_test_case(
    "waste dump: clone copies all entry fields",
    "integration|integration.waste-dump",
    function()
        local source = make_dump(Helpers.next_position())
        source[EK.stored_garbage] = {["garbage"] = 7}
        source[EK.waste_dump_mode] = WasteDumpOperationMode.output
        source[EK.press_mode] = true
        source[EK.store_progress] = 1.5
        source[EK.garbagify_progress] = 0.3

        local dest_entity = Helpers.create_unregistered(test_surface, "test-waste-dump", Helpers.next_position())
        local dest = Register.clone(source, dest_entity)

        Assert.equals(dest[EK.stored_garbage]["garbage"], 7, "stored_garbage should be copied")
        Assert.equals(dest[EK.waste_dump_mode], WasteDumpOperationMode.output, "mode should be copied")
        Assert.equals(dest[EK.press_mode], true, "press_mode should be copied")
        Assert.equals(dest[EK.store_progress], 1.5, "store_progress should be copied")
        Assert.equals(dest[EK.garbagify_progress], 0.3, "garbagify_progress should be copied")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "waste dump: clone produces an independent stored_garbage table",
    "integration|integration.waste-dump",
    function()
        local source = make_dump(Helpers.next_position())
        source[EK.stored_garbage] = {["garbage"] = 5}

        local dest_entity = Helpers.create_unregistered(test_surface, "test-waste-dump", Helpers.next_position())
        local dest = Register.clone(source, dest_entity)

        source[EK.stored_garbage]["garbage"] = 99
        Assert.equals(dest[EK.stored_garbage]["garbage"], 5, "modifying source should not affect destination")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << paste settings >>

Tirislib.Testing.add_test_case(
    "waste dump: pasting settings copies mode and press_mode to destination",
    "integration|integration.waste-dump",
    function()
        local source = make_dump(Helpers.next_position())
        local dest = make_dump(Helpers.next_position())
        source[EK.waste_dump_mode] = WasteDumpOperationMode.output
        source[EK.press_mode] = true
        dest[EK.waste_dump_mode] = WasteDumpOperationMode.neutral
        dest[EK.press_mode] = false

        Register.on_settings_pasted(Type.waste_dump, source, Type.waste_dump, dest, {})

        Assert.equals(dest[EK.waste_dump_mode], WasteDumpOperationMode.output, "mode should be pasted")
        Assert.equals(dest[EK.press_mode], true, "press_mode should be pasted")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << destruction >>

Tirislib.Testing.add_test_case(
    "waste dump: destroyed cause spills stored_garbage as item entities on the surface",
    "integration|integration.waste-dump",
    function()
        local entry = make_dump(Helpers.next_position())
        entry[EK.stored_garbage] = {["garbage"] = 10}

        Register.remove_entry(entry, DeconstructionCause.destroyed)

        local spilled = test_surface.find_entities_filtered {type = "item-entity"}
        local spilled_count = 0
        for _, item_entity in pairs(spilled) do
            if item_entity.stack.name == "garbage" then
                spilled_count = spilled_count + item_entity.stack.count
            end
        end
        Assert.equals(spilled_count, 10, "stored garbage should be spilled as item entities on destruction")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "waste dump: mined cause inserts stored_garbage into event buffer",
    "integration|integration.waste-dump",
    function()
        local entry = make_dump(Helpers.next_position())
        entry[EK.stored_garbage] = {["garbage"] = 5, ["food-leftovers"] = 3}

        local received = {}
        local fake_event = {
            buffer = {
                insert = function(item_stack)
                    received[item_stack.name] = (received[item_stack.name] or 0) + item_stack.count
                end
            }
        }

        Register.remove_entry(entry, DeconstructionCause.mined, fake_event)

        Assert.equals(received["garbage"], 5, "garbage should be inserted into buffer")
        Assert.equals(received["food-leftovers"], 3, "food-leftovers should be inserted into buffer")
    end,
    setup,
    teardown
)
