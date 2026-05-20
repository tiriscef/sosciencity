local EK = require("enums.entry-key")
local PE = require("enums.performance-effect")
local PK = require("enums.performance-key")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local Buildings = require("constants.buildings")

local test_surface
local find_effect = Helpers.find_effect

local function create_salt_pond()
    return Helpers.create_and_register(test_surface, "test-salt-pond", Helpers.next_position())
end

local function setup_surface()
    test_surface = Helpers.create_test_surface()
end

local function clean_up()
    Helpers.clean_up()
end

---------------------------------------------------------------------------------------------------
-- << creation >>

Tirislib.Testing.add_test_case(
    "Salt-pond creation makes performance report builder available",
    "integration|integration.salt-pond",
    function()
        local entry = create_salt_pond()
        Assert.not_nil(Entity.build_performance_report(entry))
    end,
    setup_surface,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << update: water tile performance >>

Tirislib.Testing.add_test_case(
    "Salt-pond update records a water_tiles effect",
    "integration|integration.salt-pond",
    function()
        local entry = create_salt_pond()
        Helpers.update_entry(entry)
        local report = Entity.build_performance_report(entry)
        Assert.not_nil(find_effect(report, PE.water_tiles), "water_tiles effect missing")
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Salt-pond with zero water tiles has water_tiles effect value of 0",
    "integration|integration.salt-pond",
    function()
        local entry = create_salt_pond()
        -- First update: fresh count on lab surface = 0
        Helpers.update_entry(entry)

        local report = Entity.build_performance_report(entry)
        Assert.equals(find_effect(report, PE.water_tiles)[PK.value], 0)
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Salt-pond at full water tiles has water_tiles effect value of 1.0",
    "integration|integration.salt-pond",
    function()
        local entry = create_salt_pond()
        -- First update: fresh count = 0
        Helpers.update_entry(entry)

        -- Inject full capacity; storage.last_tile_update = -1 so cache is used on next update
        local building_details = Buildings.get(entry)
        entry[EK.water_tiles] = building_details.water_tiles
        Helpers.update_entry(entry)

        local report = Entity.build_performance_report(entry)
        Assert.equals(find_effect(report, PE.water_tiles)[PK.value], 1.0)
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Salt-pond water_tiles effect value increases with more water tiles",
    "integration|integration.salt-pond",
    function()
        local entry = create_salt_pond()
        Helpers.update_entry(entry)

        entry[EK.water_tiles] = 10
        Helpers.update_entry(entry)
        local perf_low = find_effect(Entity.build_performance_report(entry), PE.water_tiles)[PK.value]

        entry[EK.water_tiles] = 40
        Helpers.update_entry(entry)
        local perf_high = find_effect(Entity.build_performance_report(entry), PE.water_tiles)[PK.value]

        Assert.is_true(perf_high > perf_low, "more water tiles should yield a higher performance value")
    end,
    setup_surface,
    clean_up
)
