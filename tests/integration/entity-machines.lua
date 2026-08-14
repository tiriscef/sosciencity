local EK = require("enums.entry-key")
local Type = require("enums.type")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface
local saved_machine_count

local function setup()
    test_surface = Helpers.create_test_surface()
    saved_machine_count = storage.active_machine_count
    storage.active_machine_count = 0
end

local function clean_up()
    storage.active_machine_count = saved_machine_count
    Helpers.clean_up()
end

---------------------------------------------------------------------------------------------------
-- << creation >>

Tirislib.Testing.add_test_case(
    "Assembling machine registration wires create_active_machine_status",
    "integration|integration.machines",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-assembling-machine", {0, 0})

        -- create_active_machine_status sets last_time_active to a negative sentinel value
        Assert.is_true(
            entry[EK.last_time_active] ~= nil and entry[EK.last_time_active] < 0,
            "last_time_active should be set to a negative sentinel by the creation handler"
        )
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << update >>

Tirislib.Testing.add_test_case(
    "Assembling machine update applies the clockwork bonus as a local effect",
    "integration|integration.machines",
    function()
        storage.caste_bonuses[Type.clockwork] = 25
        local entry = Helpers.create_and_register(test_surface, "test-assembling-machine", {0, 0})

        Helpers.update_entry(entry)

        Assert.equals(
            entry[EK.entity].local_effect.speed,
            0.25,
            "the bonus should be applied to the entity as a local effect"
        )
    end,
    setup,
    clean_up
)

Tirislib.Testing.add_test_case(
    "A negative clockwork bonus doesn't slow down foreign machines",
    "integration|integration.machines",
    function()
        storage.caste_bonuses[Type.clockwork] = -25
        local entry = Helpers.create_and_register(test_surface, "test-assembling-machine", {0, 0})

        Helpers.update_entry(entry)

        -- the engine leaves zeroed values out of the effect it hands back
        Assert.equals(entry[EK.entity].local_effect.speed or 0, 0, "no slowdown should reach the machine")
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << destruction >>

Tirislib.Testing.add_test_case(
    "Destroying an active assembling machine decrements active_machine_count",
    "integration|integration.machines",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-assembling-machine", {0, 0})

        -- Simulate the machine having been recently active so update_active_machine_status marks it active
        entry[EK.last_time_active] = game.tick
        Helpers.update_entry(entry)

        Assert.equals(storage.active_machine_count, 1, "machine should be counted as active")

        Helpers.destroy_entry(entry)

        Assert.equals(storage.active_machine_count, 0, "count should decrement when active machine is destroyed")
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << rocket silo: distinct updater >>
-- update_rocket_silo differs from update_machine: it incorporates both clockwork and aurora
-- caste bonuses, and it takes the clockwork malus instead of clamping it away.
-- We register a test-assembling-machine entity as Type.rocket_silo to exercise this path
-- without needing a rocket silo prototype.

Tirislib.Testing.add_test_case(
    "Rocket silo update applies clockwork speed and aurora productivity",
    "integration|integration.machines",
    function()
        storage.caste_bonuses[Type.clockwork] = 10
        storage.caste_bonuses[Type.aurora] = 5
        local entry = Helpers.create_and_register(test_surface, "test-assembling-machine", {0, 0}, Type.rocket_silo)

        Helpers.update_entry(entry)

        local effect = entry[EK.entity].local_effect
        Assert.equals(effect.speed, 0.1, "clockwork bonus should reach the entity")
        Assert.equals(effect.productivity, 0.05, "aurora bonus should reach the entity")
    end,
    setup,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Rocket silo update passes a negative clockwork bonus through as a slowdown",
    "integration|integration.machines",
    function()
        storage.caste_bonuses[Type.clockwork] = -5
        local entry = Helpers.create_and_register(test_surface, "test-assembling-machine", {0, 0}, Type.rocket_silo)

        Helpers.update_entry(entry)

        Assert.equals(entry[EK.entity].local_effect.speed, -0.05, "the malus should reach the entity")
    end,
    setup,
    clean_up
)
