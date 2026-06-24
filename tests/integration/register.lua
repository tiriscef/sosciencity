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

---------------------------------------------------------------------------------------------------
-- << external-ownership detection >>

Tirislib.Testing.add_test_case(
    "external-ownership: healthy catch-all entry is not flagged",
    "integration|integration.register",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-assembling-machine", {0, 0})

        Assert.is_nil(entry[EK.externally_owned], "fresh healthy entry should not have flag set")
        Assert.equals(entry[EK.active], true, "EK.active baseline should be initialized to true")
        Assert.is_false(Register.is_externally_owned(entry), "is_externally_owned should return false")
    end,
    function() test_surface = Helpers.create_test_surface() end,
    function() Helpers.clean_up() end
)

Tirislib.Testing.add_test_case(
    "external-ownership: entity inactive at registration is flagged",
    "integration|integration.register",
    function()
        local entity = Helpers.create_unregistered(test_surface, "test-assembling-machine", {0, 0})
        entity.disabled_by_script = true

        local entry = Register.add(entity)

        Assert.is_true(entry[EK.externally_owned], "inactive-at-registration entry should be flagged")
        Assert.is_true(Register.is_externally_owned(entry), "is_externally_owned should return true")
    end,
    function() test_surface = Helpers.create_test_surface() end,
    function() Helpers.clean_up() end
)

Tirislib.Testing.add_test_case(
    "external-ownership: entity with custom_status at registration is flagged",
    "integration|integration.register",
    function()
        local entity = Helpers.create_unregistered(test_surface, "test-assembling-machine", {0, 0})
        entity.custom_status = {
            diode = defines.entity_status_diode.red,
            label = {"sosciencity.machine"}
        }

        local entry = Register.add(entity)

        Assert.is_true(entry[EK.externally_owned], "entry with pre-existing custom_status should be flagged")
        Assert.is_true(Register.is_externally_owned(entry), "is_externally_owned should return true")
    end,
    function() test_surface = Helpers.create_test_surface() end,
    function() Helpers.clean_up() end
)

Tirislib.Testing.add_test_case(
    "external-ownership: runtime divergence flags an entry disabled post-registration",
    "integration|integration.register",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-assembling-machine", {0, 0})
        Assert.is_nil(entry[EK.externally_owned], "should start unflagged")

        -- Simulate another mod disabling the entity after registration
        entry[EK.entity].disabled_by_script = true

        Assert.is_true(Register.is_externally_owned(entry), "runtime divergence should flag the entry")
        Assert.is_true(entry[EK.externally_owned], "flag should be persisted on the entry")
    end,
    function() test_surface = Helpers.create_test_surface() end,
    function() Helpers.clean_up() end
)

Tirislib.Testing.add_test_case(
    "external-ownership: flag is sticky even after the entity becomes active again",
    "integration|integration.register",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-assembling-machine", {0, 0})

        entry[EK.entity].disabled_by_script = true
        Assert.is_true(Register.is_externally_owned(entry), "should flag on first divergence")

        -- External mod re-enables; flag must not auto-clear
        entry[EK.entity].disabled_by_script = false
        entry[EK.active] = true

        Assert.is_true(Register.is_externally_owned(entry), "flag should remain set (sticky)")
    end,
    function() test_surface = Helpers.create_test_surface() end,
    function() Helpers.clean_up() end
)

---------------------------------------------------------------------------------------------------
-- << Register.clone >>

Tirislib.Testing.add_test_case(
    "Register.clone creates destination entry with source's type",
    "integration|integration.register",
    function()
        local source = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local dest_entity = test_surface.create_entity {name = "test-market", position = {5, 0}, force = "player"}
        assert(dest_entity)

        local dest = Register.clone(source, dest_entity)

        Assert.equals(dest[EK.type], source[EK.type], "destination type should match source type")
    end,
    function() test_surface = Helpers.create_test_surface() end,
    function() Helpers.clean_up() end
)

Tirislib.Testing.add_test_case(
    "Register.clone copies tick_of_creation from source",
    "integration|integration.register",
    function()
        local source = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local source_tick = source[EK.tick_of_creation]
        local dest_entity = test_surface.create_entity {name = "test-market", position = {5, 0}, force = "player"}
        assert(dest_entity)

        local dest = Register.clone(source, dest_entity)

        Assert.equals(dest[EK.tick_of_creation], source_tick, "tick_of_creation should be copied from source")
    end,
    function() test_surface = Helpers.create_test_surface() end,
    function() Helpers.clean_up() end
)

Tirislib.Testing.add_test_case(
    "Register.clone leaves source in register alongside destination",
    "integration|integration.register",
    function()
        local source = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local count_before = Register.get_type_count(Type.market)
        local dest_entity = test_surface.create_entity {name = "test-market", position = {5, 0}, force = "player"}
        assert(dest_entity)

        Register.clone(source, dest_entity)

        Assert.equals(Register.get_type_count(Type.market), count_before + 1, "clone should add one more entry")
        Assert.not_nil(Register.try_get(source[EK.unit_number]), "source should still be in register")
        Assert.not_nil(Register.try_get(dest_entity.unit_number), "destination should be in register")
    end,
    function() test_surface = Helpers.create_test_surface() end,
    function() Helpers.clean_up() end
)

---------------------------------------------------------------------------------------------------
-- << Register.add_or_clone >>

Tirislib.Testing.add_test_case(
    "Register.add_or_clone takes the clone path when source is registered",
    "integration|integration.register",
    function()
        local source = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local source_tick = source[EK.tick_of_creation]
        local dest_entity = test_surface.create_entity {name = "test-market", position = {5, 0}, force = "player"}
        assert(dest_entity)

        Register.add_or_clone(source[EK.entity], dest_entity, nil)

        local dest = Register.try_get(dest_entity.unit_number)
        Assert.not_nil(dest, "destination should be registered")
        Assert.equals(dest[EK.tick_of_creation], source_tick, "clone path should copy tick_of_creation from source")
    end,
    function() test_surface = Helpers.create_test_surface() end,
    function() Helpers.clean_up() end
)

Tirislib.Testing.add_test_case(
    "Register.add_or_clone falls back to fresh add when source is not registered",
    "integration|integration.register",
    function()
        local source_entity = test_surface.create_entity {name = "test-market", position = {0, 0}, force = "player"}
        assert(source_entity)
        -- source deliberately not registered
        local dest_entity = test_surface.create_entity {name = "test-market", position = {5, 0}, force = "player"}
        assert(dest_entity)

        Register.add_or_clone(source_entity, dest_entity, nil)

        local dest = Register.try_get(dest_entity.unit_number)
        Assert.not_nil(dest, "destination should be registered via fresh add")
        Assert.equals(dest[EK.type], Type.market, "fresh add should resolve the correct type")
    end,
    function() test_surface = Helpers.create_test_surface() end,
    function() Helpers.clean_up() end
)

Tirislib.Testing.add_test_case(
    "Register.add_or_clone falls back to fresh add when source is nil",
    "integration|integration.register",
    function()
        local dest_entity = test_surface.create_entity {name = "test-market", position = {0, 0}, force = "player"}
        assert(dest_entity)

        Register.add_or_clone(nil, dest_entity, nil)

        Assert.not_nil(Register.try_get(dest_entity.unit_number), "destination should be registered")
    end,
    function() test_surface = Helpers.create_test_surface() end,
    function() Helpers.clean_up() end
)

Tirislib.Testing.add_test_case(
    "Register.add_or_clone falls back to fresh add when source entity is invalid",
    "integration|integration.register",
    function()
        local source_entity = test_surface.create_entity {name = "test-market", position = {0, 0}, force = "player"}
        assert(source_entity)
        source_entity.destroy()
        -- source now invalid, not in register
        local dest_entity = test_surface.create_entity {name = "test-market", position = {5, 0}, force = "player"}
        assert(dest_entity)

        Register.add_or_clone(source_entity, dest_entity, nil)

        Assert.not_nil(Register.try_get(dest_entity.unit_number), "destination should be registered via fresh add")
    end,
    function() test_surface = Helpers.create_test_surface() end,
    function() Helpers.clean_up() end
)

---------------------------------------------------------------------------------------------------
-- << Register.remove_entity >>

Tirislib.Testing.add_test_case(
    "Register.remove_entity removes the entry for the given entity",
    "integration|integration.register",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local unit_number = entry[EK.unit_number]

        Register.remove_entity(entry[EK.entity])

        Assert.is_nil(Register.try_get(unit_number), "entry should be gone after remove_entity")
    end,
    function() test_surface = Helpers.create_test_surface() end,
    function() Helpers.clean_up() end
)

Tirislib.Testing.add_test_case(
    "Register.remove_entity is a no-op for an entity not in the register",
    "integration|integration.register",
    function()
        local entity = test_surface.create_entity {name = "test-market", position = {0, 0}, force = "player"}
        assert(entity)

        Register.remove_entity(entity)

        Assert.is_true(entity.valid, "entity should still be valid; remove_entity should not error or touch it")
    end,
    function() test_surface = Helpers.create_test_surface() end,
    function() Helpers.clean_up() end
)

---------------------------------------------------------------------------------------------------
-- << fear on destruction >>

Tirislib.Testing.add_test_case(
    "removing a civil building with DeconstructionCause.destroyed increases fear",
    "integration|integration.register",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local fear_before = storage.fear

        Register.remove_entry(entry, DeconstructionCause.destroyed)

        Assert.is_true(storage.fear > fear_before, "fear should increase when a civil building is destroyed")
    end,
    function() test_surface = Helpers.create_test_surface() end,
    function() Helpers.clean_up() end
)

Tirislib.Testing.add_test_case(
    "removing a civil building with DeconstructionCause.mined does not increase fear",
    "integration|integration.register",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local fear_before = storage.fear

        Register.remove_entry(entry, DeconstructionCause.mined)

        Assert.equals(storage.fear, fear_before, "fear should not change when a civil building is mined")
    end,
    function() test_surface = Helpers.create_test_surface() end,
    function() Helpers.clean_up() end
)

Tirislib.Testing.add_test_case(
    "removing a non-civil building with DeconstructionCause.destroyed does not increase fear",
    "integration|integration.register",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-assembling-machine", {0, 0})
        local fear_before = storage.fear

        Register.remove_entry(entry, DeconstructionCause.destroyed)

        Assert.equals(storage.fear, fear_before, "fear should not change when a non-civil building is destroyed")
    end,
    function() test_surface = Helpers.create_test_surface() end,
    function() Helpers.clean_up() end
)

---------------------------------------------------------------------------------------------------
-- << Register.change_type >>

Tirislib.Testing.add_test_case(
    "Register.change_type updates counts, returns a correct new entry, and invalidates the old one",
    "integration|integration.register",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        local unit_number = entry[EK.unit_number]
        local original_tick = entry[EK.tick_of_creation]
        local market_count_before = Register.get_type_count(Type.market)
        local dumpster_count_before = Register.get_type_count(Type.dumpster)

        local new_entry = Register.change_type(entry, Type.dumpster)

        Assert.equals(Register.get_type_count(Type.market), market_count_before - 1, "market count should decrease")
        Assert.equals(Register.get_type_count(Type.dumpster), dumpster_count_before + 1, "dumpster count should increase")
        Assert.equals(new_entry[EK.type], Type.dumpster, "new entry should have the new type")
        Assert.equals(new_entry[EK.unit_number], unit_number, "new entry should have the same unit_number")
        Assert.equals(new_entry[EK.tick_of_creation], original_tick, "tick_of_creation should be preserved")
        Assert.equals(Register.try_get(unit_number), new_entry, "try_get should return the new entry")
        Assert.is_true(Register.is_stale(entry), "old entry should be stale after change_type")
    end,
    function() test_surface = Helpers.create_test_surface() end,
    function() Helpers.clean_up() end
)

---------------------------------------------------------------------------------------------------
-- << Register.ever_had_type >>

local saved_ever_had

Tirislib.Testing.add_test_case(
    "Register.ever_had_type returns false for a type with no entries",
    "integration|integration.register",
    function()
        Assert.is_false(Register.ever_had_type(Type.market), "should return false when type was never registered")
    end,
    function()
        test_surface = Helpers.create_test_surface()
        saved_ever_had = storage.ever_had_type[Type.market]
        storage.ever_had_type[Type.market] = nil
    end,
    function()
        storage.ever_had_type[Type.market] = saved_ever_had
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Register.ever_had_type returns true after an entry is added",
    "integration|integration.register",
    function()
        Helpers.create_and_register(test_surface, "test-market", {0, 0})
        Assert.is_true(Register.ever_had_type(Type.market), "should return true after adding an entry")
    end,
    function() test_surface = Helpers.create_test_surface() end,
    function() Helpers.clean_up() end
)

Tirislib.Testing.add_test_case(
    "Register.ever_had_type persists as true after all entries of the type are removed",
    "integration|integration.register",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        Register.remove_entry(entry, DeconstructionCause.unknown)

        Assert.is_true(Register.ever_had_type(Type.market), "flag should persist even when count drops to 0")
        Assert.equals(Register.get_type_count(Type.market), 0, "count should be 0 after removal")
    end,
    function()
        test_surface = Helpers.create_test_surface()
        saved_ever_had = storage.ever_had_type[Type.market]
        storage.ever_had_type[Type.market] = nil
    end,
    function()
        storage.ever_had_type[Type.market] = saved_ever_had
        Helpers.clean_up()
    end
)

---------------------------------------------------------------------------------------------------
-- << Register.is_stale >>

Tirislib.Testing.add_test_case(
    "Register.is_stale returns false for a live entry",
    "integration|integration.register",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        Assert.is_false(Register.is_stale(entry), "fresh entry should not be stale")
    end,
    function() test_surface = Helpers.create_test_surface() end,
    function() Helpers.clean_up() end
)

Tirislib.Testing.add_test_case(
    "Register.is_stale returns true after the entry is removed",
    "integration|integration.register",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-market", {0, 0})
        Register.remove_entry(entry, DeconstructionCause.unknown)
        Assert.is_true(Register.is_stale(entry), "removed entry should be stale")
    end,
    function() test_surface = Helpers.create_test_surface() end,
    function() Helpers.clean_up() end
)
