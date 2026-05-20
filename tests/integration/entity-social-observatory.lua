local EK = require("enums.entry-key")
local PE = require("enums.performance-effect")
local PK = require("enums.performance-key")
local Type = require("enums.type")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local find_effect = Helpers.find_effect

local test_surface

local function setup()
    test_surface = Helpers.create_test_surface()
    -- clockwork, orchid, and ember all share "upbringing" as their required tech
    storage.technologies["upbringing"] = true
end

local function clean_up()
    Helpers.clean_up()
end

local function create_observatory(position)
    return Helpers.create_and_register(test_surface, "test-social-observatory", position)
end

---------------------------------------------------------------------------------------------------
-- << creation >>

Tirislib.Testing.add_test_case(
    "Social observatory creation initializes performance to 1",
    "integration|integration.social-observatory",
    function()
        local entry = create_observatory({0, 0})

        Assert.equals(entry[EK.performance], 1)
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << population performance >>

Tirislib.Testing.add_test_case(
    "Social observatory with no nearby houses has performance 0",
    "integration|integration.social-observatory",
    function()
        local entry = create_observatory({0, 0})

        Helpers.update_entry(entry)

        -- target_population = 50, total_pop = 0 -> population_performance = 0/(0+50) = 0
        -- performance = min(1, 0) * competition * happiness = 0
        Assert.equals(entry[EK.performance], 0)
    end,
    setup,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Social observatory performance scales with nearby population",
    "integration|integration.social-observatory",
    function()
        -- target_population = 50; 50 inhabitants -> population_performance = 50/(50+50) = 0.5
        Helpers.create_inhabited_house(test_surface, {5, 0}, Type.clockwork, 50)
        local entry = create_observatory({0, 0})

        Helpers.update_entry(entry)

        -- worker_performance = 1 (no workforce), competition = 1 (solo), happiness = 1
        -- performance = min(1, 0.5) * 1 * 1 = 0.5
        Assert.equals(entry[EK.performance], 0.5)
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << competition >>

Tirislib.Testing.add_test_case(
    "Nearby observatory lowers competition and reduces performance",
    "integration|integration.social-observatory",
    function()
        Helpers.create_inhabited_house(test_surface, {5, 0}, Type.clockwork, 50)
        local obs1 = create_observatory({0, 0})
        -- obs2 within range 42 of obs1; both subscribe to Type.social_observatory bidirectionally
        local obs2 = create_observatory({10, 0})

        Helpers.update_entry(obs1)

        -- obs1 has 1 observatory neighbor -> competition = 2^(-0.35) < 1
        -- performance < 0.5 (the solo-observatory value with 50 inhabitants)
        Assert.less_than(obs1[EK.performance], 0.5)
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << caste diversity >>

Tirislib.Testing.add_test_case(
    "Exactly min_castes castes gives zero productivity bonus",
    "integration|integration.social-observatory",
    function()
        -- min_castes = 2; with exactly 2 different castes -> max(0, 2-2) * 10 = 0
        Helpers.create_inhabited_house(test_surface, {5,  0}, Type.clockwork, 10)
        Helpers.create_inhabited_house(test_surface, {10, 0}, Type.orchid,    10)
        local entry = create_observatory({0, 0})

        Helpers.update_entry(entry)

        local report = Entity.build_performance_report(entry)
        local diversity = find_effect(report, PE.caste_diversity)
        Assert.not_nil(diversity, "caste_diversity effect should be present")
        Assert.equals(diversity[PK.value], 0, "productivity should be 0 with exactly min_castes castes")
    end,
    setup,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Three-caste neighborhood gives productivity bonus in report",
    "integration|integration.social-observatory",
    function()
        -- min_castes = 2, caste_bonus = 10; 3 different castes -> productivity = max(0, 3-2) * 10 = 10
        Helpers.create_inhabited_house(test_surface, {5,  0}, Type.clockwork, 10)
        Helpers.create_inhabited_house(test_surface, {10, 0}, Type.orchid,    10)
        Helpers.create_inhabited_house(test_surface, {15, 0}, Type.ember,     10)
        local entry = create_observatory({0, 0})

        Helpers.update_entry(entry)

        local report = Entity.build_performance_report(entry)
        local diversity = find_effect(report, PE.caste_diversity)
        Assert.not_nil(diversity, "caste_diversity effect should be present in report")
        Assert.equals(diversity[PK.value], 10, "productivity bonus should be (3 - 2) * 10 = 10")
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << report structure >>

Tirislib.Testing.add_test_case(
    "Social observatory report includes all five performance effects",
    "integration|integration.social-observatory",
    function()
        local entry = create_observatory({0, 0})

        Helpers.update_entry(entry)

        local report = Entity.build_performance_report(entry)
        Assert.not_nil(find_effect(report, PE.workforce),              "workforce effect missing")
        Assert.not_nil(find_effect(report, PE.nearby_population),      "nearby_population effect missing")
        Assert.not_nil(find_effect(report, PE.observatory_competition), "observatory_competition effect missing")
        Assert.not_nil(find_effect(report, PE.worker_happiness),       "worker_happiness effect missing")
        Assert.not_nil(find_effect(report, PE.caste_diversity),        "caste_diversity effect missing")
    end,
    setup,
    clean_up
)
