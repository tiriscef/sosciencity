local EK = require("enums.entry-key")
local PE = require("enums.performance-effect")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local find_effect = Helpers.find_effect

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
    "Nightclub creation initializes performance to 0",
    "integration|integration.nightclub",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-night-club", {0, 0})

        Assert.equals(entry[EK.performance], 0)
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << update >>

Tirislib.Testing.add_test_case(
    "Nightclub update sets performance using workforce and culture bonus",
    "integration|integration.nightclub",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-night-club", {0, 0})

        Helpers.update_entry(entry)

        -- test-night-club has no workforce requirement (evaluate_workforce returns 1)
        -- and no mixtapes produced (get_culture_bonus returns 1), so performance = 1 * 1 = 1
        Assert.equals(entry[EK.performance], 1)
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << performance report >>

Tirislib.Testing.add_test_case(
    "Nightclub report includes workforce and culture_bonus effects",
    "integration|integration.nightclub",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-night-club", {0, 0})

        Helpers.update_entry(entry)

        local report = Entity.build_performance_report(entry)
        Assert.not_nil(find_effect(report, PE.workforce), "workforce effect missing from report")
        Assert.not_nil(find_effect(report, PE.culture_bonus), "culture_bonus effect missing from report")
    end,
    setup,
    clean_up
)
