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
    "Assembling machine update applies clockwork beacon speed effects",
    "integration|integration.machines",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-assembling-machine", {0, 0})

        Helpers.update_entry(entry)

        -- set_beacon_effects stores the applied speed in EK.speed_bonus
        Assert.not_nil(entry[EK.speed_bonus], "speed_bonus should be set after update (beacon effects applied)")
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
-- caste bonuses, and switches to a penalty module when clockwork bonus goes negative.
-- We register a test-assembling-machine entity as Type.rocket_silo to exercise this path
-- without needing a rocket silo prototype.

Tirislib.Testing.add_test_case(
    "Rocket silo update with non-negative clockwork bonus applies speed and aurora productivity",
    "integration|integration.machines",
    function()
        storage.caste_bonuses[Type.clockwork] = 10
        storage.caste_bonuses[Type.aurora] = 5
        local entry = Helpers.create_and_register(test_surface, "test-assembling-machine", {0, 0}, Type.rocket_silo)

        Helpers.update_entry(entry)

        Assert.equals(entry[EK.speed_bonus], 10, "speed_bonus should equal clockwork bonus")
        Assert.equals(entry[EK.productivity_bonus], 5, "productivity_bonus should equal aurora bonus")
        Assert.is_false(entry[EK.has_penalty_module], "no penalty module when clockwork bonus is non-negative")
    end,
    setup,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Rocket silo update with negative clockwork bonus adds penalty module and offsets speed by 80",
    "integration|integration.machines",
    function()
        storage.caste_bonuses[Type.clockwork] = -5
        local entry = Helpers.create_and_register(test_surface, "test-assembling-machine", {0, 0}, Type.rocket_silo)

        Helpers.update_entry(entry)

        -- penalty path: clockwork_bonus = -5 + 80 = 75, has_penalty_module = true
        Assert.equals(entry[EK.speed_bonus], 75, "speed_bonus should be clockwork_bonus + 80 in penalty path")
        Assert.is_true(entry[EK.has_penalty_module], "penalty module should be used when clockwork bonus is negative")
    end,
    setup,
    clean_up
)
