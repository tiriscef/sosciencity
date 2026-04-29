local EK = require("enums.entry-key")
local PE = require("enums.performance-effect")
local PK = require("enums.performance-key")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local Farm = Entity.Farm
local Pruning = Entity.Pruning

local test_surface

--- Find an effect by ID inside a performance report, or nil if absent.
local function find_effect(report, effect_id)
    for _, eff in pairs(report[PK.effects]) do
        if eff[PK.effect] == effect_id then
            return eff
        end
    end
    return nil
end

--- Create a test farm at the given position with an optional recipe set on the entity.
local function create_farm(position, recipe_name)
    local entry = Helpers.create_and_register(test_surface, "test-farm", position)
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
-- << Entity.Farm.biomass_to_productivity >>

Tirislib.Testing.add_test_case(
    "biomass_to_productivity returns 0 below threshold",
    "integration|integration.farm",
    function()
        Assert.equals(Farm.biomass_to_productivity(0), 0)
        Assert.equals(Farm.biomass_to_productivity(500), 0)
        Assert.equals(Farm.biomass_to_productivity(999), 0)
    end
)

Tirislib.Testing.add_test_case(
    "biomass_to_productivity returns 0 at threshold",
    "integration|integration.farm",
    function()
        Assert.equals(Farm.biomass_to_productivity(1000), 0)
    end
)

Tirislib.Testing.add_test_case(
    "biomass_to_productivity returns positive integer above threshold",
    "integration|integration.farm",
    function()
        local result = Farm.biomass_to_productivity(10000)
        Assert.is_integer(result)
        Assert.is_positive(result)
    end
)

---------------------------------------------------------------------------------------------------
-- << Entity.Pruning.effective_slots >>

Tirislib.Testing.add_test_case(
    "Pruning.effective_slots returns max at full performance",
    "integration|integration.farm",
    function()
        Assert.equals(Pruning.effective_slots(1.0, 5), 5)
    end
)

Tirislib.Testing.add_test_case(
    "Pruning.effective_slots returns 0 at zero performance",
    "integration|integration.farm",
    function()
        Assert.equals(Pruning.effective_slots(0.0, 5), 0)
    end
)

Tirislib.Testing.add_test_case(
    "Pruning.effective_slots scales linearly in 10% steps",
    "integration|integration.farm",
    function()
        Assert.equals(Pruning.effective_slots(0.5, 10), 5)
    end
)

---------------------------------------------------------------------------------------------------
-- << farm creation >>

Tirislib.Testing.add_test_case(
    "Farm creation initializes performance_report and plant care modes",
    "integration|integration.farm",
    function()
        local entry = create_farm({0, 0})

        Assert.not_nil(entry[EK.performance_report], "performance_report should be set on creation")
        Assert.is_true(entry[EK.humus_mode], "humus_mode defaults to true on a plant-care farm")
        Assert.is_true(entry[EK.pruning_mode], "pruning_mode defaults to true on a plant-care farm")
    end,
    setup_surface,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << farm update: baseline factors >>

Tirislib.Testing.add_test_case(
    "Farm update populates baseline workforce, happiness and caste effects",
    "integration|integration.farm",
    function()
        local farm = create_farm({0, 0}, "farming-annual-bell-pepper")
        Register.update_entry(farm, game.tick + 100)

        local report = farm[EK.performance_report]
        Assert.not_nil(find_effect(report, PE.workforce), "workforce effect missing")
        Assert.not_nil(find_effect(report, PE.worker_happiness), "worker_happiness effect missing")
        Assert.not_nil(find_effect(report, PE.orchid_caste_bonus), "orchid_caste_bonus effect missing")
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Farm update tracks species name from current recipe",
    "integration|integration.farm",
    function()
        local farm = create_farm({0, 0}, "farming-annual-bell-pepper")
        Register.update_entry(farm, game.tick + 100)

        Assert.equals(farm[EK.species], "bell-pepper")
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Changing species resets biomass to 0",
    "integration|integration.farm",
    function()
        local farm = create_farm({0, 0}, "farming-perennial-olive")
        Register.update_entry(farm, game.tick + 1)
        farm[EK.biomass] = 50000

        farm[EK.entity].set_recipe("farming-annual-bell-pepper")
        Register.update_entry(farm, game.tick + 100)

        Assert.equals(farm[EK.species], "bell-pepper")
        Assert.equals(farm[EK.biomass], 0)
    end,
    setup_surface,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << humus fertilization >>

Tirislib.Testing.add_test_case(
    "Farm with humus_mode disabled records no humus_fertilization effect",
    "integration|integration.farm",
    function()
        local farm = create_farm({0, 0}, "farming-annual-bell-pepper")
        farm[EK.humus_mode] = false

        Register.update_entry(farm, game.tick + 100)

        local report = farm[EK.performance_report]
        Assert.is_nil(find_effect(report, PE.humus_fertilization))
        Assert.is_nil(farm[EK.humus_bonus])
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Farm consumes humus from neighbor station and records humus_fertilization effect",
    "integration|integration.farm",
    function()
        local farm = create_farm({0, 0}, "farming-annual-bell-pepper")
        local station = Helpers.create_and_register(test_surface, "test-fertilization-station", {3, 0})
        station[EK.humus_stored] = 50

        Register.update_entry(station, game.tick + 1)
        Assert.is_true(station[EK.active], "station should mark itself active")

        Register.update_entry(farm, game.tick + 100)

        local report = farm[EK.performance_report]
        Assert.not_nil(find_effect(report, PE.humus_fertilization))
        Assert.less_than(station[EK.humus_stored], 50, "humus should have been drawn from the station")
    end,
    setup_surface,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << pruning >>

Tirislib.Testing.add_test_case(
    "Pruning station claims neighbor farm with pruning_mode on",
    "integration|integration.farm",
    function()
        local farm = create_farm({0, 0}, "farming-annual-bell-pepper")
        local station = Helpers.create_and_register(test_surface, "test-pruning-station", {3, 0})

        Register.update_entry(station, game.tick + 1)

        Assert.equals(farm[EK.pruned_by], station[EK.unit_number])
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Pruning station does not claim farm with pruning_mode off",
    "integration|integration.farm",
    function()
        local farm = create_farm({0, 0}, "farming-annual-bell-pepper")
        farm[EK.pruning_mode] = false
        local station = Helpers.create_and_register(test_surface, "test-pruning-station", {3, 0})

        Register.update_entry(station, game.tick + 1)

        Assert.is_nil(farm[EK.pruned_by])
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Claimed farm records pruning productivity effect",
    "integration|integration.farm",
    function()
        local farm = create_farm({0, 0}, "farming-annual-bell-pepper")
        local station = Helpers.create_and_register(test_surface, "test-pruning-station", {3, 0})
        Register.update_entry(station, game.tick + 1)

        Register.update_entry(farm, game.tick + 100)

        local report = farm[EK.performance_report]
        Assert.not_nil(find_effect(report, PE.pruning))
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Disabling pruning_mode releases the station's claim on next farm update",
    "integration|integration.farm",
    function()
        local farm = create_farm({0, 0}, "farming-annual-bell-pepper")
        local station = Helpers.create_and_register(test_surface, "test-pruning-station", {3, 0})
        Register.update_entry(station, game.tick + 1)
        Assert.not_nil(farm[EK.pruned_by], "precondition: claim should be in place")

        farm[EK.pruning_mode] = false
        Register.update_entry(farm, game.tick + 100)

        Assert.is_nil(farm[EK.pruned_by])
    end,
    setup_surface,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << biomass productivity >>

Tirislib.Testing.add_test_case(
    "Persistent crop above biomass threshold records biomass productivity effect",
    "integration|integration.farm",
    function()
        local farm = create_farm({0, 0}, "farming-perennial-olive")
        farm[EK.biomass] = 100000

        Register.update_entry(farm, game.tick + 100)

        local report = farm[EK.performance_report]
        Assert.not_nil(find_effect(report, PE.biomass))
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Persistent crop below biomass threshold records no biomass effect",
    "integration|integration.farm",
    function()
        local farm = create_farm({0, 0}, "farming-perennial-olive")
        farm[EK.biomass] = 500

        Register.update_entry(farm, game.tick + 100)

        local report = farm[EK.performance_report]
        Assert.is_nil(find_effect(report, PE.biomass))
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Non-persistent crop never records biomass effect",
    "integration|integration.farm",
    function()
        local farm = create_farm({0, 0}, "farming-annual-bell-pepper")
        -- biomass field still gets set but the productivity factor should never appear
        farm[EK.biomass] = 100000

        Register.update_entry(farm, game.tick + 100)

        local report = farm[EK.performance_report]
        Assert.is_nil(find_effect(report, PE.biomass))
    end,
    setup_surface,
    clean_up
)
