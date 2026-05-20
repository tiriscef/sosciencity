local EK = require("enums.entry-key")
local PE = require("enums.performance-effect")
local PK = require("enums.performance-key")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local Fishery = Entity.Fishery

local test_surface
local find_effect = Helpers.find_effect

local function create_fishery(recipe_name)
    local entry = Helpers.create_and_register(test_surface, "test-fishery", Helpers.next_position())
    if recipe_name then
        entry[EK.entity].set_recipe(recipe_name)
    end
    return entry
end

local function setup_surface()
    test_surface = Helpers.create_test_surface()
end

local function clean_up()
    Helpers.clean_up()
end

---------------------------------------------------------------------------------------------------
-- << Fishery.get_fishing_competition >>

Tirislib.Testing.add_test_case(
    "get_fishing_competition with no neighbors returns 1.0",
    "integration|integration.fishery",
    function()
        local entry = create_fishery()
        local competition, same_count, other_count = Fishery.get_fishing_competition(entry)
        Assert.equals(competition, 1.0)
        Assert.equals(same_count, 0)
        Assert.equals(other_count, 0)
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "get_fishing_competition counts same-recipe neighbor as same_count and lowers competition",
    "integration|integration.fishery",
    function()
        local entry = create_fishery("test-fishing-carp")
        create_fishery("test-fishing-carp")
        local competition, same_count, other_count = Fishery.get_fishing_competition(entry)
        Assert.equals(same_count, 1)
        Assert.equals(other_count, 0)
        Assert.less_than(competition, 1.0)
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "get_fishing_competition penalizes different-recipe neighbor less than same-recipe neighbor",
    "integration|integration.fishery",
    function()
        local entry = create_fishery("test-fishing-carp")
        local neighbor = create_fishery("test-fishing-carp")
        local competition_same = Fishery.get_fishing_competition(entry)

        neighbor[EK.entity].set_recipe("test-fishing-salmon")
        local competition_diff, same_count, other_count = Fishery.get_fishing_competition(entry)

        Assert.equals(same_count, 0)
        Assert.equals(other_count, 1)
        Assert.less_than(competition_diff, 1.0)
        Assert.is_true(competition_diff > competition_same, "different recipe should compete less than same recipe")
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "get_fishing_competition ignores neighbor with no recipe set",
    "integration|integration.fishery",
    function()
        local entry = create_fishery("test-fishing-carp")
        create_fishery()
        local competition, same_count, other_count = Fishery.get_fishing_competition(entry)
        Assert.equals(competition, 1.0)
        Assert.equals(same_count, 0)
        Assert.equals(other_count, 0)
    end,
    setup_surface,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << fishery creation >>

Tirislib.Testing.add_test_case(
    "Fishery creation makes performance report builder available",
    "integration|integration.fishery",
    function()
        local entry = create_fishery()
        Assert.not_nil(Entity.build_performance_report(entry))
    end,
    setup_surface,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << fishery update >>

Tirislib.Testing.add_test_case(
    "Fishery update records workforce, water_tiles, fishing_competition, and worker_happiness effects",
    "integration|integration.fishery",
    function()
        local entry = create_fishery()
        Helpers.update_entry(entry)

        local report = Entity.build_performance_report(entry)
        Assert.not_nil(find_effect(report, PE.workforce), "workforce effect missing")
        Assert.not_nil(find_effect(report, PE.water_tiles), "water_tiles effect missing")
        Assert.not_nil(find_effect(report, PE.fishing_competition), "fishing_competition effect missing")
        Assert.not_nil(find_effect(report, PE.worker_happiness), "worker_happiness effect missing")
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Injected water tile count raises the water_tiles effect value above zero",
    "integration|integration.fishery",
    function()
        local entry = create_fishery()
        -- First update: fresh tile count on lab surface = 0
        Helpers.update_entry(entry)

        -- Inject a non-zero count; storage.last_tile_update = -1 so cache is used on next update
        entry[EK.water_tiles] = 150
        Helpers.update_entry(entry)

        local report = Entity.build_performance_report(entry)
        local water_effect = find_effect(report, PE.water_tiles)
        Assert.greater_than(water_effect[PK.value], 0, "injected water tiles should raise water_tiles effect above 0")
    end,
    setup_surface,
    clean_up
)
