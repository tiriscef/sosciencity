local Assert = Tirislib.Testing.Assert

local created_prototypes = {}

local function setup()
    created_prototypes = {}
end

local function create_test_item(name, fields)
    local proto = {type = "item", name = name, stack_size = 50, subgroup = "raw-material", order = "a"}
    if fields then
        for k, v in pairs(fields) do
            proto[k] = v
        end
    end
    created_prototypes[#created_prototypes + 1] = proto
    return Tirislib.Item.create(proto)
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
-- << Item.create and Item.get >>

Tirislib.Testing.add_test_case(
    "Item.create adds an item to data.raw",
    "lib.item",
    function()
        create_test_item("test-item-create")

        local item, found = Tirislib.Item.get_by_name("test-item-create")
        Assert.is_true(found)
        Assert.equals(item.name, "test-item-create")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Item.get returns dummy for nonexistent item",
    "lib.item",
    function()
        local item, found = Tirislib.Item.get_by_name("nonexistent-item-xyz")
        Assert.is_false(found)
        Assert.is_true(Tirislib.Prototype.is_dummy(item))
    end
)

Tirislib.Testing.add_test_case(
    "Item.get accepts a prototype table",
    "lib.item",
    function()
        create_test_item("test-item-get-table")

        local proto = data.raw["item"]["test-item-get-table"]
        local item = Tirislib.Item.get(proto)
        Assert.equals(item.name, "test-item-get-table")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << launch products >>

Tirislib.Testing.add_test_case(
    "Item:is_launchable returns false for normal items",
    "lib.item",
    function()
        local item = create_test_item("test-item-not-launchable")
        Assert.is_false(item:is_launchable())
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Item:add_launch_product makes item launchable",
    "lib.item",
    function()
        local item = create_test_item("test-item-launch")
        item:add_launch_product({type = "item", name = "satellite", amount = 1})

        Assert.is_true(item:is_launchable())
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Item:get_launch_products returns empty table for non-launchable items",
    "lib.item",
    function()
        local item = create_test_item("test-item-no-launch")
        Assert.equals(item:get_launch_products(), {})
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Item:add_launch_product appends to existing products",
    "lib.item",
    function()
        local item = create_test_item("test-item-launch-multi")
        item:add_launch_product({type = "item", name = "satellite", amount = 1})
        item:add_launch_product({type = "item", name = "rocket-part", amount = 5})

        local products = item:get_launch_products()
        Assert.equals(#products, 2)
        Assert.equals(products[1].name, "satellite")
        Assert.equals(products[2].name, "rocket-part")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << sprite variations >>

Tirislib.Testing.add_test_case(
    "Item:add_sprite_variations adds the correct number of sprites",
    "lib.item",
    function()
        local item = create_test_item("test-item-sprites")
        item:add_sprite_variations(64, "path/sprite", 3)

        Assert.equals(#item.pictures, 3)
        Assert.equals(item.pictures[1].filename, "path/sprite-1.png")
        Assert.equals(item.pictures[3].filename, "path/sprite-3.png")
        Assert.equals(item.pictures[1].scale, 0.5)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << set_min_stack_size >>

Tirislib.Testing.add_test_case(
    "Item:set_min_stack_size increases stack size when needed",
    "lib.item",
    function()
        local item = create_test_item("test-item-stack-up", {stack_size = 10})
        item:set_min_stack_size(100)

        Assert.equals(item.stack_size, 100)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Item:set_min_stack_size does not decrease stack size",
    "lib.item",
    function()
        local item = create_test_item("test-item-stack-keep", {stack_size = 200})
        item:set_min_stack_size(50)

        Assert.equals(item.stack_size, 200)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << localisation >>

Tirislib.Testing.add_test_case(
    "Item:get_localised_name returns explicit name when set",
    "lib.item",
    function()
        local item = create_test_item("test-item-loc-name", {localised_name = {"custom-name"}})

        Assert.equals(item:get_localised_name(), {"custom-name"})
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Item:get_localised_name falls back to item-name key",
    "lib.item",
    function()
        local item = create_test_item("test-item-loc-default")

        Assert.equals(item:get_localised_name(), {"item-name.test-item-loc-default"})
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Item:get_localised_description returns explicit description when set",
    "lib.item",
    function()
        local item = create_test_item("test-item-loc-desc", {localised_description = {"custom-desc"}})

        Assert.equals(item:get_localised_description(), {"custom-desc"})
    end,
    setup,
    teardown
)
