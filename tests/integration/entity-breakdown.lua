local EK = require("enums.entry-key")
local Type = require("enums.type")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface

Tirislib.Testing.add_test_case(
    "breakdown offset: machines in one spot spread over many phases",
    "integration|integration.breakdown",
    function()
        -- consecutive unit numbers in the same area should not share a narrow band of phases,
        -- otherwise most of an area breaks down at once (regression: 10 phases gave over 60% at -6%)
        local offsets = {}
        local distinct = 0
        for unit_number = 1000, 1059 do
            local offset = Entity.get_breakdown_offset(unit_number, {x = 0, y = 0})
            if not offsets[offset] then
                offsets[offset] = true
                distinct = distinct + 1
            end
        end
        Assert.greater_than(distinct, 25, "60 machines in one spot should use more than 25 phases")
    end
)

Tirislib.Testing.add_test_case(
    "breakdown verdict: non-negative clockwork bonus never breaks any entry",
    "integration|integration.breakdown",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-assembling-machine", {0, 0})
        local saved_bonus = storage.caste_bonuses[Type.clockwork]

        storage.caste_bonuses[Type.clockwork] = 0
        Assert.is_false(Entity.get_breakdown_state(entry), "bonus 0 should never be broken")

        storage.caste_bonuses[Type.clockwork] = 50
        Assert.is_false(Entity.get_breakdown_state(entry), "positive bonus should never be broken")

        storage.caste_bonuses[Type.clockwork] = saved_bonus
    end,
    function() test_surface = Helpers.create_test_surface() end,
    function() Helpers.clean_up() end
)

Tirislib.Testing.add_test_case(
    "breakdown verdict: threshold above effective_phase breaks the entry; threshold at or below does not",
    "integration|integration.breakdown",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-assembling-machine", {0, 0})
        local saved_bonus = storage.caste_bonuses[Type.clockwork]

        local effective_phase = Entity.get_breakdown_phase(entry)

        -- threshold = effective_phase + 1 → effective_phase < threshold → broken
        storage.caste_bonuses[Type.clockwork] = -(effective_phase + 1)
        Assert.is_true(
            Entity.get_breakdown_state(entry),
            "threshold just above effective_phase should break the entry"
        )

        -- threshold = effective_phase → effective_phase < threshold is false → not broken
        if effective_phase > 0 then
            storage.caste_bonuses[Type.clockwork] = -effective_phase
            Assert.is_false(
                Entity.get_breakdown_state(entry),
                "threshold equal to effective_phase should not break the entry"
            )
        end

        storage.caste_bonuses[Type.clockwork] = saved_bonus
    end,
    function() test_surface = Helpers.create_test_surface() end,
    function() Helpers.clean_up() end
)

Tirislib.Testing.add_test_case(
    "update_machine: malus toggles entity inactive with broken-down custom_status; recovers when bonus clears",
    "integration|integration.breakdown",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-assembling-machine", {0, 0})
        local entity = entry[EK.entity]
        local saved_bonus = storage.caste_bonuses[Type.clockwork]

        local effective_phase = Entity.get_breakdown_phase(entry)

        -- Force a malus that breaks this specific entry's phase
        storage.caste_bonuses[Type.clockwork] = -(effective_phase + 1)
        Helpers.update_entry(entry)

        Assert.is_false(entity.active, "broken entry should be inactive after update_machine")
        Assert.not_nil(entity.custom_status, "broken entry should have a custom_status")
        Assert.equals(
            entity.custom_status.label[1],
            "sosciencity-custom-status.maintenance-broken-down",
            "custom_status should be the broken-down label"
        )

        -- Clear the bonus; the entry should recover on next update
        storage.caste_bonuses[Type.clockwork] = 0
        Helpers.update_entry(entry)

        Assert.is_true(entity.active, "entry should reactivate when bonus is no longer negative")
        Assert.is_nil(entity.custom_status, "custom_status should clear on recovery")

        storage.caste_bonuses[Type.clockwork] = saved_bonus
    end,
    function() test_surface = Helpers.create_test_surface() end,
    function() Helpers.clean_up() end
)

Tirislib.Testing.add_test_case(
    "update_machine: externally-owned entry is never toggled inactive by breakdown",
    "integration|integration.breakdown",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-assembling-machine", {0, 0})
        local entity = entry[EK.entity]
        local saved_bonus = storage.caste_bonuses[Type.clockwork]

        -- Mark the entry as externally owned (mimics another mod controlling it)
        entry[EK.externally_owned] = true

        local effective_phase = Entity.get_breakdown_phase(entry)

        -- Even though the breakdown verdict would fire, update_machine must skip the active write
        storage.caste_bonuses[Type.clockwork] = -(effective_phase + 1)
        Helpers.update_entry(entry)

        Assert.is_true(
            entity.active,
            "externally-owned entry should not be toggled inactive even when breakdown verdict fires"
        )
        Assert.is_nil(entity.custom_status, "externally-owned entry should not get our custom_status")

        storage.caste_bonuses[Type.clockwork] = saved_bonus
    end,
    function() test_surface = Helpers.create_test_surface() end,
    function() Helpers.clean_up() end
)
