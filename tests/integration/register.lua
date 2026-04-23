local EK = require("enums.entry-key")
local Type = require("enums.type")
local DeconstructionCause = require("enums.deconstruction-cause")

local UpdateGroup = require("constants.update-groups")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface

Tirislib.Testing.add_test_case(
    "Register.add creates an entry with correct fields",
    "integration|integration.register",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})

        Assert.not_nil(entry, "entry should exist")
        Assert.equals(entry[EK.type], Type.market, "type should be market")
        Assert.equals(entry[EK.name], "test-market", "name should match")
        Assert.not_nil(entry[EK.unit_number], "should have a unit_number")
        Assert.not_nil(entry[EK.entity], "should have an entity reference")
        Assert.is_true(entry[EK.entity].valid, "entity should be valid")
        Assert.not_nil(entry[EK.last_update], "should have a last_update tick")
        Assert.not_nil(entry[EK.tick_of_creation], "should have a tick_of_creation")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Register.add makes entry retrievable via try_get",
    "integration|integration.register",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local unit_number = entry[EK.unit_number]

        local retrieved = Register.try_get(unit_number)
        Assert.not_nil(retrieved, "should be retrievable")
        Assert.equals(retrieved, entry, "should be the same entry")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Register.add updates type count",
    "integration|integration.register",
    function()
        local count_before = Register.get_type_count(Type.market)

        Helpers.create_and_register(test_surface, "test-market", {0, 0})

        Assert.equals(Register.get_type_count(Type.market), count_before + 1, "count should increase by 1")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Register.add registers entry in type iterator",
    "integration|integration.register",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local unit_number = entry[EK.unit_number]

        local found = false
        for un, e in Register.iterate_type(Type.market) do
            if un == unit_number then
                found = true
                Assert.equals(e, entry, "iterated entry should match")
            end
        end
        Assert.is_true(found, "entry should appear in type iterator")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Register.remove_entry cleans up completely",
    "integration|integration.register",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local unit_number = entry[EK.unit_number]
        local count_before = Register.get_type_count(Type.market)

        Register.remove_entry(entry, DeconstructionCause.unknown)

        Assert.is_nil(Register.try_get(unit_number), "entry should no longer be retrievable")
        Assert.equals(Register.get_type_count(Type.market), count_before - 1, "count should decrease")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Register.try_get cleans up entry with invalid entity",
    "integration|integration.register",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local unit_number = entry[EK.unit_number]

        -- destroy the entity without going through the register
        entry[EK.entity].destroy()

        local result = Register.try_get(unit_number)
        Assert.is_nil(result, "should return nil for invalid entity")
        -- The entry should have been cleaned up automatically
        Assert.equals(Register.get_type_count(Type.market), 0, "count should be 0 after cleanup")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Register.entity_update_cycle processes entries",
    "integration|integration.register",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local creation_tick = entry[EK.last_update]

        -- Simulate time passing and run update cycle
        local future_tick = creation_tick + 100
        storage.updates_per_cycle = 10
        Register.entity_update_cycle(future_tick)

        -- The entry's last_update should have been advanced
        Assert.equals(entry[EK.last_update], future_tick, "last_update should be advanced to current tick")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Register handles multiple entities of different types",
    "integration|integration.register",
    function()
        local market_count_before = Register.get_type_count(Type.market)
        local dumpster_count_before = Register.get_type_count(Type.dumpster)

        local market = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local dumpster = Helpers.create_and_register(test_surface, "test-dumpster", {10, 0})

        Assert.equals(Register.get_type_count(Type.market), market_count_before + 1)
        Assert.equals(Register.get_type_count(Type.dumpster), dumpster_count_before + 1)

        -- removing one shouldn't affect the other
        Register.remove_entry(market, DeconstructionCause.unknown)
        Assert.equals(Register.get_type_count(Type.market), market_count_before)
        Assert.equals(Register.get_type_count(Type.dumpster), dumpster_count_before + 1)
        Assert.not_nil(Register.try_get(dumpster[EK.unit_number]), "dumpster should still exist")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "entity_update_cycle updates all high-group entries in one cycle regardless of low-group count",
    "integration|integration.register",
    function()
        local high_entries = {}
        for i = 1, 3 do
            high_entries[i] = Helpers.create_and_register(test_surface, "test-market", {i * 5, 0})
        end
        for i = 1, 10 do
            Helpers.create_and_register(test_surface, "test-assembling-machine", {i * 5, 10})
        end

        -- high slice = ceil(5 * 0.60) = 3, low slice = ceil(5 * 0.40) = 2
        -- All 3 high entries fit in one slice; 10 low entries do not.
        local future_tick = game.tick + 100
        storage.updates_per_cycle = 5
        storage.last_index_per_group[UpdateGroup.high] = nil
        storage.last_index_per_group[UpdateGroup.low] = nil
        Register.entity_update_cycle(future_tick)

        for i = 1, 3 do
            Assert.equals(
                high_entries[i][EK.last_update],
                future_tick,
                "high-group entry " .. i .. " should be updated in one cycle"
            )
        end
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "entity_update_cycle processes low-group entries when high group is empty",
    "integration|integration.register",
    function()
        local low_entries = {}
        for i = 1, 3 do
            low_entries[i] = Helpers.create_and_register(test_surface, "test-assembling-machine", {i * 5, 0})
        end

        -- low slice = ceil(2 * 0.40) = 1 per cycle; need 3 cycles to cover all 3 entries
        local future_tick = game.tick + 100
        storage.updates_per_cycle = 2
        storage.last_index_per_group[UpdateGroup.high] = nil
        storage.last_index_per_group[UpdateGroup.low] = nil
        for _ = 1, 3 do
            Register.entity_update_cycle(future_tick)
        end

        for i = 1, 3 do
            Assert.equals(
                low_entries[i][EK.last_update],
                future_tick,
                "low-group entry " .. i .. " should be updated despite empty high group"
            )
        end
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "removing an entry advances its group cursor without touching the other group's cursor",
    "integration|integration.register",
    function()
        local entry_a = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        Helpers.create_and_register(test_surface, "test-market", {5, 0})
        local low_entry = Helpers.create_and_register(test_surface, "test-assembling-machine", {0, 10})

        local a_unit_number = entry_a[EK.unit_number]
        local low_unit_number = low_entry[EK.unit_number]

        -- Point each group cursor at a specific entry
        storage.last_index_per_group[UpdateGroup.high] = a_unit_number
        storage.last_index_per_group[UpdateGroup.low] = low_unit_number

        -- Remove the entry the high-group cursor is sitting on
        Helpers.destroy_entry(entry_a)

        Assert.unequal(
            storage.last_index_per_group[UpdateGroup.high],
            a_unit_number,
            "high-group cursor should have advanced away from the removed entry"
        )
        Assert.equals(
            storage.last_index_per_group[UpdateGroup.low],
            low_unit_number,
            "low-group cursor should be unchanged"
        )
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)
