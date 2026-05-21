local EK = require("enums.entry-key")
local PE = require("enums.performance-effect")
local PK = require("enums.performance-key")
local Type = require("enums.type")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local find_effect = Helpers.find_effect

local test_surface
local saved_machine_count
local saved_clockwork_bonus

local function setup()
    test_surface = Helpers.create_test_surface()
    saved_machine_count = storage.active_machine_count
    storage.active_machine_count = 0
    saved_clockwork_bonus = storage.caste_bonuses[Type.clockwork]
    storage.caste_bonuses[Type.clockwork] = 0
end

local function clean_up()
    storage.active_machine_count = saved_machine_count
    storage.caste_bonuses[Type.clockwork] = saved_clockwork_bonus
    Helpers.clean_up()
end

local function create_waterwell(position)
    return Helpers.create_and_register(test_surface, "test-waterwell", position)
end

---------------------------------------------------------------------------------------------------
-- << creation >>

Tirislib.Testing.add_test_case(
    "Waterwell creation initializes EK.performance to 1",
    "integration|integration.waterwell",
    function()
        local entry = create_waterwell({0, 0})

        Assert.equals(entry[EK.performance], 1)
    end,
    setup,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Waterwell creation wires create_active_machine_status (last_time_active is negative sentinel)",
    "integration|integration.waterwell",
    function()
        local entry = create_waterwell({0, 0})

        Assert.is_true(
            entry[EK.last_time_active] ~= nil and entry[EK.last_time_active] < 0,
            "last_time_active should be set to a negative sentinel by the creation handler"
        )
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << update - competition >>

Tirislib.Testing.add_test_case(
    "Waterwell update with no neighbors: performance equals clockwork boost (1.0 at zero bonus)",
    "integration|integration.waterwell",
    function()
        local entry = create_waterwell({0, 0})
        Helpers.update_entry(entry)

        Assert.equals(entry[EK.performance], 1.0, "solo waterwell with zero clockwork bonus should have performance 1.0")
    end,
    setup,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Waterwell update with one neighbor within range: performance is below 1.0",
    "integration|integration.waterwell",
    function()
        local entry = create_waterwell({0, 0})
        create_waterwell({5, 0})

        Helpers.update_entry(entry)

        Assert.less_than(entry[EK.performance], 1.0, "competition from a neighbor should reduce performance")
    end,
    setup,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Waterwell performance decreases monotonically as neighbor count grows",
    "integration|integration.waterwell",
    function()
        local entry = create_waterwell({0, 0})
        create_waterwell({5, 0})
        Helpers.update_entry(entry)
        local perf_one_neighbor = entry[EK.performance]

        create_waterwell({10, 0})
        Helpers.update_entry(entry)
        local perf_two_neighbors = entry[EK.performance]

        Assert.less_than(perf_two_neighbors, perf_one_neighbor, "two neighbors should give lower performance than one")
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << update - filter guard >>

Tirislib.Testing.add_test_case(
    "Waterwell update with clean-water-from-ground recipe and no filter: performance is 0 and entity inactive",
    "integration|integration.waterwell",
    function()
        local entry = create_waterwell({0, 0})
        local entity = entry[EK.entity]

        game.forces["player"].recipes["clean-water-from-ground"].enabled = true
        entity.set_recipe("clean-water-from-ground")

        Helpers.update_entry(entry)

        Assert.equals(entry[EK.performance], 0, "performance should be 0 without a water-filter module")
        Assert.is_false(entity.active, "entity should be inactive when filter guard fires")

        game.forces["player"].recipes["clean-water-from-ground"].enabled = false
    end,
    setup,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Waterwell update with clean-water-from-ground recipe and water-filter module: performance is positive",
    "integration|integration.waterwell",
    function()
        local entry = create_waterwell({0, 0})
        local entity = entry[EK.entity]

        game.forces["player"].recipes["clean-water-from-ground"].enabled = true
        entity.set_recipe("clean-water-from-ground")
        entity.get_inventory(defines.inventory.crafter_modules).insert({name = "water-filter", count = 1})

        Helpers.update_entry(entry)

        Assert.greater_than(entry[EK.performance], 0, "performance should be positive when water-filter module is present")

        game.forces["player"].recipes["clean-water-from-ground"].enabled = false
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << update - clockwork bonus >>

Tirislib.Testing.add_test_case(
    "Positive clockwork bonus raises waterwell performance above competition baseline",
    "integration|integration.waterwell",
    function()
        local entry = create_waterwell({0, 0})

        storage.caste_bonuses[Type.clockwork] = 20
        Helpers.update_entry(entry)

        Assert.greater_than(entry[EK.performance], 1.0, "positive clockwork bonus should push performance above 1.0")
    end,
    setup,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Negative clockwork bonus does not lower waterwell performance below competition baseline",
    "integration|integration.waterwell",
    function()
        local entry = create_waterwell({0, 0})

        storage.caste_bonuses[Type.clockwork] = -30
        Helpers.update_entry(entry)

        -- max(0, -30) = 0, so boost = 1.0; solo competition = 1.0 → performance == 1.0
        Assert.equals(entry[EK.performance], 1.0, "negative clockwork bonus should be clamped to 0 (no reduction)")
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << performance report >>

Tirislib.Testing.add_test_case(
    "Waterwell performance report on normal path has waterwell_competition and maintenance effects",
    "integration|integration.waterwell",
    function()
        local entry = create_waterwell({0, 0})
        entry[EK.entity].set_recipe("test-groundwater-pump-basic")
        Helpers.update_entry(entry)

        local report = Entity.build_performance_report(entry)
        Assert.not_nil(find_effect(report, PE.waterwell_competition), "waterwell_competition effect should be present")
        Assert.not_nil(find_effect(report, PE.maintenance), "maintenance effect should be present")
    end,
    setup,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Waterwell performance report on filter-blocked path returns empty effects",
    "integration|integration.waterwell",
    function()
        local entry = create_waterwell({0, 0})

        game.forces["player"].recipes["clean-water-from-ground"].enabled = true
        entry[EK.entity].set_recipe("clean-water-from-ground")

        local report = Entity.build_performance_report(entry)
        Assert.equals(next(report[PK.effects]), nil, "no effects should be reported when filter guard blocks the recipe")

        game.forces["player"].recipes["clean-water-from-ground"].enabled = false
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << destruction >>

Tirislib.Testing.add_test_case(
    "Destroying a recently-active waterwell decrements active_machine_count",
    "integration|integration.waterwell",
    function()
        local entry = create_waterwell({0, 0})

        entry[EK.last_time_active] = game.tick
        Helpers.update_entry(entry)

        Assert.equals(storage.active_machine_count, 1, "waterwell should be counted as active")

        Helpers.destroy_entry(entry)

        Assert.equals(storage.active_machine_count, 0, "count should decrement when active waterwell is destroyed")
    end,
    setup,
    clean_up
)
