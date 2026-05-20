local EK = require("enums.entry-key")
local PE = require("enums.performance-effect")
local PK = require("enums.performance-key")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface
local find_effect = Helpers.find_effect

local function create_hunting_hut(recipe_name)
    local entry = Helpers.create_and_register(test_surface, "test-hunting-hut", Helpers.next_position())
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

-- "gathering-food" and "gathering-wood" are in sosciencity-hunting with no unlock,
-- so they are enabled by default and can be set via set_recipe.

---------------------------------------------------------------------------------------------------
-- << competition (tested through performance report since get_hunting_competition is local) >>

Tirislib.Testing.add_test_case(
    "Hunting-hut with no neighbors has competition value of 1.0",
    "integration|integration.hunting-hut",
    function()
        local entry = create_hunting_hut("gathering-food")
        local report = Entity.build_performance_report(entry)
        local competition_effect = find_effect(report, PE.hunting_competition)
        Assert.not_nil(competition_effect)
        Assert.equals(competition_effect[PK.value], 1.0)
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Hunting-hut competition drops below 1.0 when a same-recipe neighbor is present",
    "integration|integration.hunting-hut",
    function()
        local entry = create_hunting_hut("gathering-food")
        create_hunting_hut("gathering-food")
        local report = Entity.build_performance_report(entry)
        local competition_effect = find_effect(report, PE.hunting_competition)
        Assert.less_than(competition_effect[PK.value], 1.0)
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Hunting-hut competition penalizes different-recipe neighbor less than same-recipe neighbor",
    "integration|integration.hunting-hut",
    function()
        local entry = create_hunting_hut("gathering-food")
        local neighbor = create_hunting_hut("gathering-food")

        local competition_same = find_effect(Entity.build_performance_report(entry), PE.hunting_competition)[PK.value]

        neighbor[EK.entity].set_recipe("gathering-wood")
        local competition_diff = find_effect(Entity.build_performance_report(entry), PE.hunting_competition)[PK.value]

        Assert.is_true(
            competition_diff > competition_same,
            "different recipe should penalize less than same recipe"
        )
    end,
    setup_surface,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << creation >>

Tirislib.Testing.add_test_case(
    "Hunting-hut creation makes performance report builder available",
    "integration|integration.hunting-hut",
    function()
        local entry = create_hunting_hut()
        Assert.not_nil(Entity.build_performance_report(entry))
    end,
    setup_surface,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << update >>

Tirislib.Testing.add_test_case(
    "Hunting-hut update records workforce, trees, hunting_competition, and worker_happiness effects",
    "integration|integration.hunting-hut",
    function()
        local entry = create_hunting_hut()
        Helpers.update_entry(entry)

        local report = Entity.build_performance_report(entry)
        Assert.not_nil(find_effect(report, PE.workforce), "workforce effect missing")
        Assert.not_nil(find_effect(report, PE.trees), "trees effect missing")
        Assert.not_nil(find_effect(report, PE.hunting_competition), "hunting_competition effect missing")
        Assert.not_nil(find_effect(report, PE.worker_happiness), "worker_happiness effect missing")
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Injected tree count raises the trees effect value above zero",
    "integration|integration.hunting-hut",
    function()
        local entry = create_hunting_hut()
        -- First update: fresh count on lab surface (no trees) = 0
        Helpers.update_entry(entry)

        -- Inject a non-zero count; storage.last_entity_update = -1 so cache is used on next update
        entry[EK.tree_count] = 25
        Helpers.update_entry(entry)

        local report = Entity.build_performance_report(entry)
        local trees_effect = find_effect(report, PE.trees)
        Assert.greater_than(trees_effect[PK.value], 0, "injected tree count should raise trees effect above 0")
    end,
    setup_surface,
    clean_up
)
