local Assert = Tirislib.Testing.Assert

local created_prototypes = {}

local function setup()
    created_prototypes = {}
end

local function create_test_fluid(name, fields)
    local proto = {
        type = "fluid",
        name = name,
        default_temperature = 10,
        max_temperature = 100,
        base_color = {r = 0, g = 0, b = 1},
        flow_color = {r = 0, g = 0, b = 1}
    }
    if fields then
        for k, v in pairs(fields) do
            proto[k] = v
        end
    end
    created_prototypes[#created_prototypes + 1] = proto
    return Tirislib.Fluid.create(proto)
end

local function teardown()
    for _, proto in pairs(created_prototypes) do
        if data.raw[proto.type] then
            data.raw[proto.type][proto.name] = nil
        end
    end
    created_prototypes = {}
end

---------------------------------------------------------------------------------------------------
-- << Fluid.create and Fluid.get >>

Tirislib.Testing.add_test_case(
    "Fluid.create adds a fluid to data.raw",
    "lib.fluid",
    function()
        create_test_fluid("test-fluid-create")

        local fluid, found = Tirislib.Fluid.get_by_name("test-fluid-create")
        Assert.is_true(found)
        Assert.equals(fluid.name, "test-fluid-create")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Fluid.get returns dummy for nonexistent fluid",
    "lib.fluid",
    function()
        local fluid, found = Tirislib.Fluid.get_by_name("nonexistent-fluid-xyz")
        Assert.is_false(found)
        Assert.is_true(Tirislib.Prototype.is_dummy(fluid))
    end
)

Tirislib.Testing.add_test_case(
    "Fluid.get accepts a prototype table",
    "lib.fluid",
    function()
        create_test_fluid("test-fluid-get-table")

        local proto = data.raw["fluid"]["test-fluid-get-table"]
        local fluid = Tirislib.Fluid.get(proto)
        Assert.equals(fluid.name, "test-fluid-get-table")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << localisation >>

Tirislib.Testing.add_test_case(
    "Fluid:get_localised_name returns explicit name when set",
    "lib.fluid",
    function()
        local fluid = create_test_fluid("test-fluid-loc", {localised_name = {"custom-fluid"}})

        Assert.equals(fluid:get_localised_name(), {"custom-fluid"})
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Fluid:get_localised_name falls back to fluid-name key",
    "lib.fluid",
    function()
        local fluid = create_test_fluid("test-fluid-loc-default")

        Assert.equals(fluid:get_localised_name(), {"fluid-name.test-fluid-loc-default"})
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Fluid:get_localised_description returns explicit description when set",
    "lib.fluid",
    function()
        local fluid = create_test_fluid("test-fluid-desc", {localised_description = {"custom-desc"}})

        Assert.equals(fluid:get_localised_description(), {"custom-desc"})
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Fluid:get_localised_description falls back to fluid-description key",
    "lib.fluid",
    function()
        local fluid = create_test_fluid("test-fluid-desc-default")

        Assert.equals(fluid:get_localised_description(), {"fluid-description.test-fluid-desc-default"})
    end,
    setup,
    teardown
)
