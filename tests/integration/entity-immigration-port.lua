local EK = require("enums.entry-key")
local Type = require("enums.type")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface

local function setup()
    test_surface = Helpers.create_test_surface()
end

local function clean_up()
    Helpers.clean_up()
end

---------------------------------------------------------------------------------------------------
-- << creation >>

Tirislib.Testing.add_test_case(
    "Immigration port creation schedules first wave in the future",
    "integration|integration.immigration-port",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-immigration-port", {0, 0})

        Assert.not_nil(entry[EK.next_wave], "next_wave should be set on creation")
        Assert.is_true(
            entry[EK.next_wave] > entry[EK.last_update],
            "next_wave should be scheduled after creation tick"
        )
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << wave not yet due >>

Tirislib.Testing.add_test_case(
    "Immigration port does not consume materials when wave is not yet due",
    "integration|integration.immigration-port",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-immigration-port", {0, 0})
        Inventories.get_chest_inventory(entry).insert {name = "rope", count = 5}

        -- next_wave is set 100 ticks ahead after creation; update at next tick won't trigger
        Helpers.update_entry(entry)

        Assert.equals(
            Inventories.get_chest_inventory(entry).get_item_count("rope"),
            5,
            "rope should not be consumed before the wave is due"
        )
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << wave fires: materials present >>

Tirislib.Testing.add_test_case(
    "Immigration port consumes materials and triggers wave when due",
    "integration|integration.immigration-port",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-immigration-port", {0, 0})
        Inventories.get_chest_inventory(entry).insert {name = "rope", count = 5}
        storage.immigration[Type.clockwork] = 8

        entry[EK.next_wave] = 0  -- force wave to be due immediately
        Helpers.update_entry(entry)

        Assert.equals(
            Inventories.get_chest_inventory(entry).get_item_count("rope"),
            0,
            "rope should be consumed when wave fires"
        )
        Assert.less_than(
            storage.immigration[Type.clockwork],
            8,
            "immigration pool should be drawn from when wave fires"
        )
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << wave fires: materials missing >>

Tirislib.Testing.add_test_case(
    "Immigration port skips wave but still reschedules when materials are missing",
    "integration|integration.immigration-port",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-immigration-port", {0, 0})
        storage.immigration[Type.clockwork] = 8

        entry[EK.next_wave] = 0  -- no rope in inventory
        Helpers.update_entry(entry)

        Assert.equals(
            storage.immigration[Type.clockwork],
            8,
            "immigration should not change when materials are missing"
        )
        -- next_wave advances from 0: 0 + 100 + random(1) - 1 = 100
        Assert.equals(entry[EK.next_wave], 100, "next_wave should advance even when wave is skipped")
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << rescheduling >>

Tirislib.Testing.add_test_case(
    "Immigration port advances next_wave by interval from the previous next_wave after firing",
    "integration|integration.immigration-port",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-immigration-port", {0, 0})
        Inventories.get_chest_inventory(entry).insert {name = "rope", count = 5}

        -- With next_wave = 0, interval = 100, random_interval = 1:
        -- new next_wave = 0 + 100 + random(1) - 1 = 100 (deterministic since random(1) always returns 1)
        entry[EK.next_wave] = 0
        Helpers.update_entry(entry)

        Assert.equals(entry[EK.next_wave], 100, "next_wave should advance by interval from previous next_wave")
    end,
    setup,
    clean_up
)
