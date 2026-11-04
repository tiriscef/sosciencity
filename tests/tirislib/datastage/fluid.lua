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

---------------------------------------------------------------------------------------------------
-- << Fluid.create: use_placeholder_icon and auto-icon >>

Tirislib.Testing.add_test_case(
    "Fluid.create use_placeholder_icon sets icon to placeholder_icon",
    "lib.fluid",
    function()
        local fluid = Tirislib.Fluid.create {
            type = "fluid", name = "test-fluid-placeholder-set",
            default_temperature = 10, max_temperature = 100,
            base_color = {r = 0, g = 0, b = 1}, flow_color = {r = 0, g = 0, b = 1},
            use_placeholder_icon = true
        }
        created_prototypes[#created_prototypes + 1] = {type = "fluid", name = "test-fluid-placeholder-set"}

        Assert.equals(fluid.icon, Tirislib.Prototype.placeholder_icon)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Fluid.create use_placeholder_icon overrides explicit icon",
    "lib.fluid",
    function()
        local fluid = Tirislib.Fluid.create {
            type = "fluid", name = "test-fluid-placeholder-override",
            default_temperature = 10, max_temperature = 100,
            base_color = {r = 0, g = 0, b = 1}, flow_color = {r = 0, g = 0, b = 1},
            icon = "explicit.png", icon_size = 64,
            use_placeholder_icon = true
        }
        created_prototypes[#created_prototypes + 1] = {type = "fluid", name = "test-fluid-placeholder-override"}

        Assert.equals(fluid.icon, Tirislib.Prototype.placeholder_icon)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Fluid.create use_placeholder_icon defaults icon_size to 64",
    "lib.fluid",
    function()
        local fluid = Tirislib.Fluid.create {
            type = "fluid", name = "test-fluid-placeholder-icon-size",
            default_temperature = 10, max_temperature = 100,
            base_color = {r = 0, g = 0, b = 1}, flow_color = {r = 0, g = 0, b = 1},
            use_placeholder_icon = true
        }
        created_prototypes[#created_prototypes + 1] = {type = "fluid", name = "test-fluid-placeholder-icon-size"}

        Assert.equals(fluid.icon_size, 64)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Fluid.create strips use_placeholder_icon from data.raw prototype",
    "lib.fluid",
    function()
        Tirislib.Fluid.create {
            type = "fluid", name = "test-fluid-placeholder-strip",
            default_temperature = 10, max_temperature = 100,
            base_color = {r = 0, g = 0, b = 1}, flow_color = {r = 0, g = 0, b = 1},
            use_placeholder_icon = true
        }
        created_prototypes[#created_prototypes + 1] = {type = "fluid", name = "test-fluid-placeholder-strip"}

        Assert.equals(data.raw["fluid"]["test-fluid-placeholder-strip"].use_placeholder_icon, nil)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Fluid.create auto-derives icon from default_icon_path when none given",
    "lib.fluid",
    function()
        Tirislib.Fluid.create {
            type = "fluid", name = "test-fluid-auto-icon",
            default_temperature = 10, max_temperature = 100,
            base_color = {r = 0, g = 0, b = 1}, flow_color = {r = 0, g = 0, b = 1}
        }
        created_prototypes[#created_prototypes + 1] = {type = "fluid", name = "test-fluid-auto-icon"}

        local expected = Tirislib.Prototype.default_icon_path .. "test-fluid-auto-icon.png"
        Assert.equals(data.raw["fluid"]["test-fluid-auto-icon"].icon, expected)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << Fluid.batch_create >>

local base_batch_data = {
    icon_size = 64,
    default_temperature = 10,
    max_temperature = 100,
    base_color = {r = 0, g = 0, b = 1},
    flow_color = {r = 0, g = 0, b = 1},
    subgroup = "sosciencity-fluid-materials"
}

local function batch_create_test_fluids(fluids, batch_data)
    local results = Tirislib.Fluid.batch_create(fluids, batch_data or base_batch_data)
    for _, fluid in pairs(results) do
        created_prototypes[#created_prototypes + 1] = {type = "fluid", name = fluid.name}
    end
    return results
end

Tirislib.Testing.add_test_case(
    "Fluid.batch_create auto-generates icon from default_icon_path and name",
    "lib.fluid",
    function()
        batch_create_test_fluids({{name = "test-fluid-bc-auto-icon"}})

        local fluid = data.raw["fluid"]["test-fluid-bc-auto-icon"]
        Assert.equals(fluid.icon, Tirislib.Prototype.default_icon_path .. "test-fluid-bc-auto-icon.png")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Fluid.batch_create explicit icon on entry skips auto-icon",
    "lib.fluid",
    function()
        batch_create_test_fluids({{name = "test-fluid-bc-explicit-icon", icon = "explicit.png"}})

        local fluid = data.raw["fluid"]["test-fluid-bc-explicit-icon"]
        Assert.equals(fluid.icon, "explicit.png")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Fluid.batch_create fluid fields override batch_data defaults",
    "lib.fluid",
    function()
        local results = batch_create_test_fluids(
            {{name = "test-fluid-bc-override", base_color = {r = 1, g = 0, b = 0}}}
        )

        Assert.equals(results[1].base_color.r, 1)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Fluid.batch_create applies icon_size = 64 default",
    "lib.fluid",
    function()
        local batch_no_size = {
            default_temperature = 10, max_temperature = 100,
            base_color = {r = 0, g = 0, b = 1}, flow_color = {r = 0, g = 0, b = 1},
            subgroup = "sosciencity-fluid-materials"
        }
        local results = batch_create_test_fluids({{name = "test-fluid-bc-icon-size"}}, batch_no_size)

        Assert.equals(results[1].icon_size, 64)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Fluid.batch_create auto-assigns order when not set",
    "lib.fluid",
    function()
        local results = batch_create_test_fluids({
            {name = "test-fluid-bc-order-a"},
            {name = "test-fluid-bc-order-b"}
        })

        Assert.equals(results[1].order, "001")
        Assert.equals(results[2].order, "002")
    end,
    setup,
    teardown
)
