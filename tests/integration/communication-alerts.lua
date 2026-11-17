local EK = require("enums.entry-key")
local Type = require("enums.type")
local WarningType = require("enums.warning-type")

local Time = require("constants.time")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

-- The grouped alerts record game.tick, so these tests let real ticks pass and update at game.tick,
-- like the update cycle does, instead of using Helpers.update_entry.

local test_surface

local function setup()
    test_surface = Helpers.create_test_surface()
    storage.technologies["upbringing"] = 1
    storage.alert_entries = {}
    Communication.migrate()
end

local function teardown()
    Helpers.clean_up()
    storage.alert_entries = {}
    Communication.migrate()
end

--- Runs the alert refresh of Communication.update.
local function refresh_alerts()
    local interval = 2 * Time.second
    Communication.update(interval * (math.floor(game.tick / interval) + 1))
end

local function is_recorded(warning_type, entry)
    local entries = storage.alert_entries[warning_type]
    return entries ~= nil and entries[entry[EK.unit_number]] ~= nil
end

Tirislib.Testing.add_test_case(
    "Grouped alert keeps houses that warn again in every update",
    "integration|integration.communication",
    function()
        -- a test house without a market has no food
        local entry = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 10)

        Tirislib.Testing.let_one_tick_pass(function()
            Register.update_entry(entry, game.tick)
            Assert.is_true(is_recorded(WarningType.no_food, entry), "a house without food should be recorded")

            Tirislib.Testing.let_one_tick_pass(function()
                Register.update_entry(entry, game.tick)
                refresh_alerts()
                Assert.is_true(is_recorded(WarningType.no_food, entry),
                    "a house that is still without food should stay recorded")
            end)
        end)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Grouped alert forgets houses whose latest update had no warning",
    "integration|integration.communication",
    function()
        local entry = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 10)

        Tirislib.Testing.let_one_tick_pass(function()
            -- a house without food can't be in food distress, so the next update won't warn again
            Communication.warning(WarningType.food_distress, entry)
            refresh_alerts()
            Assert.is_true(is_recorded(WarningType.food_distress, entry),
                "the house should stay recorded until it gets updated")

            Tirislib.Testing.let_one_tick_pass(function()
                Register.update_entry(entry, game.tick)
                refresh_alerts()
                Assert.is_false(is_recorded(WarningType.food_distress, entry),
                    "the house should be forgotten after an update without the warning")
            end)
        end)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Grouped alert forgets removed houses",
    "integration|integration.communication",
    function()
        local entry = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 10)
        local unit_number = entry[EK.unit_number]

        Communication.warning(WarningType.no_food, entry)
        Helpers.destroy_entry(entry)
        refresh_alerts()

        Assert.is_nil(storage.alert_entries[WarningType.no_food][unit_number], "a removed house should be forgotten")
    end,
    setup,
    teardown
)
