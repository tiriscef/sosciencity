local EK = require("enums.entry-key")
local PE = require("enums.performance-effect")
local PK = require("enums.performance-key")
local Type = require("enums.type")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local find_effect = Helpers.find_effect

local test_surface

local function setup_surface()
    test_surface = Helpers.create_test_surface()
    storage.technologies["upbringing"] = 1
end

local function clean_up()
    game.forces["player"].mining_drill_productivity_bonus = 0
    Helpers.clean_up()
end

---------------------------------------------------------------------------------------------------
-- << creation >>

Tirislib.Testing.add_test_case(
    "Manufactory creation initializes performance to 1",
    "integration|integration.manufactory",
    function()
        local manufactory = Helpers.create_and_register(test_surface, "test-ember-manufactory", {0, 0})

        Assert.equals(manufactory[EK.performance], 1)
    end,
    setup_surface,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << update: activity >>

Tirislib.Testing.add_test_case(
    "Manufactory with no workers is inactive after update",
    "integration|integration.manufactory",
    function()
        local manufactory = Helpers.create_and_register(test_surface, "test-ember-manufactory", {0, 0})

        Helpers.update_entry(manufactory)

        Assert.is_false(manufactory[EK.active], "manufactory should be inactive with no workforce")
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Manufactory with workers is active after update",
    "integration|integration.manufactory",
    function()
        Helpers.create_inhabited_house(test_surface, {0, 0}, Type.ember, 20)
        local manufactory = Helpers.create_and_register(test_surface, "test-ember-manufactory", {5, 0})

        Helpers.update_entry(manufactory)

        Assert.is_true(manufactory[EK.active], "manufactory should be active with workforce")
        Assert.greater_than(manufactory[EK.performance], 0)
    end,
    setup_surface,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << performance report >>

Tirislib.Testing.add_test_case(
    "Manufactory report includes workforce and worker_happiness effects",
    "integration|integration.manufactory",
    function()
        local manufactory = Helpers.create_and_register(test_surface, "test-ember-manufactory", {0, 0})

        Helpers.update_entry(manufactory)

        local report = Entity.build_performance_report(manufactory)
        Assert.not_nil(find_effect(report, PE.workforce), "workforce effect should be in report")
        Assert.not_nil(find_effect(report, PE.worker_happiness), "worker_happiness effect should be in report")
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Non-mining manufactory report has no mining_productivity effect",
    "integration|integration.manufactory",
    function()
        local manufactory = Helpers.create_and_register(test_surface, "test-ember-manufactory", {0, 0})

        Helpers.update_entry(manufactory)

        local report = Entity.build_performance_report(manufactory)
        Assert.is_nil(find_effect(report, PE.mining_productivity), "non-mining manufactory should not report mining_productivity")
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Mining manufactory report includes mining_productivity effect",
    "integration|integration.manufactory",
    function()
        local manufactory = Helpers.create_and_register(test_surface, "test-mining-manufactory", {0, 0})

        Helpers.update_entry(manufactory)

        local report = Entity.build_performance_report(manufactory)
        Assert.not_nil(find_effect(report, PE.mining_productivity), "mining manufactory should report mining_productivity")
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Mining productivity value reflects force.mining_drill_productivity_bonus",
    "integration|integration.manufactory",
    function()
        game.forces["player"].mining_drill_productivity_bonus = 0.5
        local manufactory = Helpers.create_and_register(test_surface, "test-mining-manufactory", {0, 0})

        Helpers.update_entry(manufactory)

        local report = Entity.build_performance_report(manufactory)
        local effect = find_effect(report, PE.mining_productivity)
        Assert.not_nil(effect, "mining_productivity effect should be present")
        Assert.equals(effect[PK.value], 50, "mining_productivity value should be floor(0.5 * 100) = 50")
    end,
    setup_surface,
    clean_up
)
