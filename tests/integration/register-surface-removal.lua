local DeathCause = require("enums.death-cause")
local DeconstructionCause = require("enums.deconstruction-cause")
local EK = require("enums.entry-key")
local Type = require("enums.type")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

-- Surfaces get deleted at the end of the tick, so every test that deletes one needs a fresh name.
local surface_counter = 0

local function create_doomed_surface()
    surface_counter = surface_counter + 1
    return Helpers.create_test_surface("sosciencity-surface-removal-" .. surface_counter)
end

local function setup()
    Helpers.create_test_surface()
    storage.technologies["upbringing"] = 1
end

-- The handlers in control.lua look the function up on Register, so a wrapper sees whether an engine
-- event reached it. Checking the register alone isn't enough: Register.try_get also removes entries
-- whose entity became invalid, so the asserts would pass even without the handlers.
local original_remove_entries_on_surface = Register.remove_entries_on_surface
local removal_calls

local function spy_on_removals()
    removal_calls = {}
    Register.remove_entries_on_surface = function(surface_index, cause, chunk_positions)
        removal_calls[#removal_calls + 1] = {surface_index = surface_index, cause = cause, chunks = chunk_positions}
        return original_remove_entries_on_surface(surface_index, cause, chunk_positions)
    end
end

local function assert_removal_called_for(surface_index)
    Assert.equals(#removal_calls, 1, "the engine event should reach Register.remove_entries_on_surface once")
    if removal_calls[1] then
        Assert.equals(removal_calls[1].surface_index, surface_index)
        Assert.equals(removal_calls[1].cause, DeconstructionCause.surface_removed)
    end
end

local function teardown()
    Register.remove_entries_on_surface = original_remove_entries_on_surface
    Helpers.clean_up()
end

---------------------------------------------------------------------------------------------------
-- << Register.remove_entries_on_surface >>

Tirislib.Testing.add_test_case(
    "remove_entries_on_surface removes only the entries on the given surface",
    "integration|integration.register",
    function()
        local doomed = create_doomed_surface()
        local other = Helpers.create_test_surface()
        local doomed_entry = Helpers.create_and_register(doomed, "test-market", Helpers.next_position())
        local other_entry = Helpers.create_and_register(other, "test-market", Helpers.next_position())

        Register.remove_entries_on_surface(doomed.index, DeconstructionCause.surface_removed)

        Helpers.assert_not_registered(doomed_entry)
        Helpers.assert_is_registered(other_entry)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "remove_entries_on_surface with chunk positions removes only the entries in these chunks",
    "integration|integration.register",
    function()
        local surface = create_doomed_surface()
        local inside = Helpers.create_and_register(surface, "test-market", {5, 5})
        local outside = Helpers.create_and_register(surface, "test-market", {70, 5})

        Register.remove_entries_on_surface(surface.index, DeconstructionCause.surface_removed, {{x = 0, y = 0}})

        Helpers.assert_not_registered(inside)
        Helpers.assert_is_registered(outside)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "removing a house with its surface reports its inhabitants as dead without causing fear",
    "integration|integration.register",
    function()
        local surface = create_doomed_surface()
        local house = Helpers.create_inhabited_house(surface, Helpers.next_position(), Type.clockwork, 4)
        local deaths_before = storage.reports["death"][DeathCause.unknown] or 0
        local fear_before = storage.fear
        local homeless_before = storage.homeless[Type.clockwork][EK.inhabitants]

        Register.remove_entries_on_surface(surface.index, DeconstructionCause.surface_removed)

        Helpers.assert_not_registered(house)
        Assert.equals(storage.reports["death"][DeathCause.unknown], deaths_before + 4)
        Assert.equals(storage.fear, fear_before, "fear shouldn't change")
        Assert.equals(storage.homeless[Type.clockwork][EK.inhabitants], homeless_before, "nobody should become homeless")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << engine events >>

Tirislib.Testing.add_test_case(
    "deleting a surface removes the entries on it",
    "integration|integration.register",
    function()
        local surface = create_doomed_surface()
        local surface_index = surface.index
        local entry = Helpers.create_and_register(surface, "test-market", Helpers.next_position())
        spy_on_removals()

        game.delete_surface(surface)

        Tirislib.Testing.let_one_tick_pass(
            function()
                assert_removal_called_for(surface_index)
                Helpers.assert_not_registered(entry)
            end
        )
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "clearing a surface removes the entries on it",
    "integration|integration.register",
    function()
        local surface = create_doomed_surface()
        local entry = Helpers.create_and_register(surface, "test-market", Helpers.next_position())
        spy_on_removals()

        surface.clear()

        Tirislib.Testing.let_one_tick_pass(
            function()
                assert_removal_called_for(surface.index)
                Helpers.assert_not_registered(entry)
            end
        )
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "deleting a chunk removes the entries in it",
    "integration|integration.register",
    function()
        local surface = create_doomed_surface()
        local inside = Helpers.create_and_register(surface, "test-market", {5, 5})
        local outside = Helpers.create_and_register(surface, "test-market", {70, 5})

        spy_on_removals()

        surface.delete_chunk({0, 0})

        Tirislib.Testing.let_one_tick_pass(
            function()
                assert_removal_called_for(surface.index)
                Assert.equals(removal_calls[1] and removal_calls[1].chunks, {{x = 0, y = 0}})
                Helpers.assert_not_registered(inside)
                Helpers.assert_is_registered(outside)
            end
        )
    end,
    setup,
    teardown
)
