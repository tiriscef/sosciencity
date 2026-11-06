local Type = require("enums.type")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface

local function setup_surface()
    test_surface = Helpers.create_test_surface()
end

local function clean_up()
    Helpers.clean_up()
end

local function create_ghost(name, position)
    return test_surface.create_entity {
        name = "entity-ghost",
        inner_name = name,
        position = position,
        force = "player"
    }
end

--- Returns the line of the report whose caption uses the given locale key.
local function find_line(lines, key)
    for _, line in pairs(lines) do
        if line.caption[1] == key then
            return line
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << site reports >>

Tirislib.Testing.add_test_case(
    "Site report is nil for buildings that don't depend on their site",
    "integration|integration.site-report",
    function()
        local entity = Helpers.create_unregistered(test_surface, "test-house", {0, 0})
        Assert.is_nil(Entity.build_site_report(entity, entity.name))
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Groundwater pump site report counts the pumps in range, but not the ones further away",
    "integration|integration.site-report",
    function()
        Helpers.create_and_register(test_surface, "test-waterwell", {0, 0})
        Helpers.create_and_register(test_surface, "test-waterwell", {10, 0})
        Helpers.create_and_register(test_surface, "test-waterwell", {90, 0})
        local entity = Helpers.create_unregistered(test_surface, "test-waterwell", {5, 0})

        local lines = Entity.build_site_report(entity, entity.name)
        local line = find_line(lines, "sosciencity.site-waterwell-competition")
        Assert.equals(line.caption[2], 2)
        Assert.equals(line.caption[3], Tirislib.Utils.round(100 * 3 ^ (-0.45)))
        Assert.is_false(line.ok)
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Groundwater pump site report works for ghosts",
    "integration|integration.site-report",
    function()
        Helpers.create_and_register(test_surface, "test-waterwell", {0, 0})
        local ghost = create_ghost("test-waterwell", {5, 0})

        local lines = Entity.build_site_report(ghost, ghost.ghost_name)
        Assert.equals(find_line(lines, "sosciencity.site-waterwell-competition").caption[2], 1)
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Groundwater pump site report is ok without other pumps",
    "integration|integration.site-report",
    function()
        local entity = Helpers.create_unregistered(test_surface, "test-waterwell", {0, 0})

        local line = find_line(Entity.build_site_report(entity, entity.name), "sosciencity.site-waterwell-competition")
        Assert.equals(line.caption[2], 0)
        Assert.equals(line.caption[3], 100)
        Assert.is_true(line.ok)
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Hunting hut site report counts the trees in range",
    "integration|integration.site-report",
    function()
        for i = 1, 3 do
            test_surface.create_entity {name = "tree-01", position = {i * 3, 10}}
        end
        local ghost = create_ghost("test-hunting-hut", {0, 0})

        local line = find_line(Entity.build_site_report(ghost, ghost.ghost_name), "sosciencity.site-trees")
        Assert.equals(line.caption[2], 3)
        Assert.equals(line.caption[3], 50)
        Assert.is_false(line.ok)
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Site report counts the free workers of fitting castes whose houses reach the site",
    "integration|integration.site-report",
    function()
        Helpers.create_inhabited_house(test_surface, {10, 0}, Type.clockwork, 7)
        Helpers.create_inhabited_house(test_surface, {20, 0}, Type.clockwork, 6)
        -- too far away to reach the site
        Helpers.create_inhabited_house(test_surface, {90, 0}, Type.clockwork, 5)
        -- wrong caste
        Helpers.create_inhabited_house(test_surface, {0, 10}, Type.ember, 4)
        local ghost = create_ghost("test-fishery", {0, 0})

        local line = find_line(Entity.build_site_report(ghost, ghost.ghost_name), "sosciencity.site-workers")
        Assert.equals(line.caption[2], 13)
        Assert.equals(line.caption[3], 20)
        Assert.is_false(line.ok)
    end,
    setup_surface,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Fishing hut site report counts the competing fishing huts in range",
    "integration|integration.site-report",
    function()
        Helpers.create_and_register(test_surface, "test-fishery", {12, 0})
        local ghost = create_ghost("test-fishery", {0, 0})

        local line = find_line(Entity.build_site_report(ghost, ghost.ghost_name), "sosciencity.site-competition")
        Assert.equals(line.caption[2], 1)
        Assert.is_false(line.ok)
    end,
    setup_surface,
    clean_up
)
