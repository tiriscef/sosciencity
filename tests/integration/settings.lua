local Type = require("enums.type")
local Time = require("constants.time")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

-- Smoke tests for the runtime map settings: every setting at a non-default value, followed by the
-- code paths that only run on a timer or on rare events. Normal tests run with the default settings
-- and reach neither (the only crash report so far came from the disabled narrator, whose random
-- banter crashed the game 5 minutes into a game).

local test_surface
local saved_dev_mode_record

local function default_of(setting)
    return prototypes.mod_setting[setting].default_value
end

local function set_setting(setting, value)
    settings.global[setting] = {value = value}
end

local function restore_defaults()
    for name, setting in pairs(prototypes.mod_setting) do
        if setting.mod == "sosciencity" and setting.setting_type == "runtime-global" then
            set_setting(name, setting.default_value)
        end
    end
end

local function setup()
    test_surface = Helpers.create_test_surface()
    Helpers.reset_inhabitants_state()
    storage.technologies["upbringing"] = 1
    saved_dev_mode_record = storage.dev_mode_first_activation

    Helpers.create_inhabited_house(test_surface, Helpers.next_position(), Type.clockwork, 10)
    Helpers.create_inhabited_house(test_surface, Helpers.next_position(), Type.orchid, 10)
end

local function teardown()
    restore_defaults()
    storage.dev_mode_first_activation = saved_dev_mode_record
    Helpers.clean_up()
    Helpers.reset_inhabitants_state()
end

--- Runs the timed and event-driven code paths that read the settings.
local function run_settings_dependent_paths()
    -- entity updates, sliced by sosciencity-entity-updates-per-cycle
    for i = 1, 3 do
        Register.entity_update_cycle(game.tick + i)
    end

    -- Communication decides by the tick: banter (first after 5 minutes), reports (at :30 of a minute),
    -- warnings and informations (every 15 seconds)
    Communication.update(5 * Time.minute)
    Communication.update(Time.minute + 30 * Time.second)
    Communication.update(2 * Time.minute + 15 * Time.second)
    Communication.player_got_run_over()

    -- clockwork bonus and maintenance read the start points and the penalty module setting
    Inhabitants.get_clockwork_bonus()
    Inhabitants.has_sufficient_maintenance()

    -- a building with an auto-naming scheme
    Helpers.create_and_register(test_surface, "kitchen-for-all", Helpers.next_position())
end

Tirislib.Testing.add_test_case(
    "the setting smoke test runs with the default settings",
    "integration|integration.settings",
    function()
        Assert.does_not_throw(run_settings_dependent_paths)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_parameterized_test_case(
    "%s = %s doesn't break the timed code paths",
    "integration|integration.settings",
    {
        {"sosciencity-allow-tiriscef", false},
        {"sosciencity-penalty-module", false},
        {"sosciencity-start-clockwork-points", 0},
        {"sosciencity-start-clockwork-points", 100000},
        {"sosciencity-entity-updates-per-cycle", 1},
        {"sosciencity-entity-updates-per-cycle", 100000},
        {"sosciencity-auto-naming", false},
        {"sosciencity-dev-mode", true},
    },
    function(setting, value)
        Assert.unequal(value, default_of(setting), "the case should test a non-default value")
        set_setting(setting, value)
        Assert.does_not_throw(run_settings_dependent_paths)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "a narrator line planned before the narrator is disabled doesn't crash when it's due",
    "integration|integration.settings",
    function()
        -- player_got_run_over plans the line a second ahead; the scheduler then calls
        -- say_random_variant without a speaker, after the setting may have changed
        Communication.player_got_run_over()
        set_setting("sosciencity-allow-tiriscef", false)

        Assert.does_not_throw(function()
            Communication.say_random_variant("roadkill")
        end)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "changing a runtime setting from script updates the stored value",
    "integration|integration.settings",
    function()
        set_setting("sosciencity-entity-updates-per-cycle", 7)
        Assert.equals(storage.updates_per_cycle, 7)

        set_setting("sosciencity-allow-tiriscef", false)
        Assert.is_false(storage.tiriscef)
    end,
    setup,
    teardown
)
