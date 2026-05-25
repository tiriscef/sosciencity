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

---------------------------------------------------------------------------------------------------
-- << Item.create: use_placeholder_icon meta-key >>

Tirislib.Testing.add_test_case(
    "Item.create use_placeholder_icon sets icon to placeholder_icon",
    "lib.item",
    function()
        local item = Tirislib.Item.create {
            type = "item", name = "test-item-placeholder-set",
            stack_size = 50, subgroup = "raw-material", order = "a",
            use_placeholder_icon = true
        }
        created_prototypes[#created_prototypes + 1] = {type = "item", name = "test-item-placeholder-set"}

        Assert.equals(item.icon, Tirislib.Prototype.placeholder_icon)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Item.create use_placeholder_icon overrides explicit icon",
    "lib.item",
    function()
        local item = Tirislib.Item.create {
            type = "item", name = "test-item-placeholder-override",
            stack_size = 50, subgroup = "raw-material", order = "a",
            icon = "explicit.png", icon_size = 64,
            use_placeholder_icon = true
        }
        created_prototypes[#created_prototypes + 1] = {type = "item", name = "test-item-placeholder-override"}

        Assert.equals(item.icon, Tirislib.Prototype.placeholder_icon)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Item.create use_placeholder_icon defaults icon_size to 64",
    "lib.item",
    function()
        local item = Tirislib.Item.create {
            type = "item", name = "test-item-placeholder-icon-size",
            stack_size = 50, subgroup = "raw-material", order = "a",
            use_placeholder_icon = true
        }
        created_prototypes[#created_prototypes + 1] = {type = "item", name = "test-item-placeholder-icon-size"}

        Assert.equals(item.icon_size, 64)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Item.create strips use_placeholder_icon from data.raw prototype",
    "lib.item",
    function()
        Tirislib.Item.create {
            type = "item", name = "test-item-placeholder-strip",
            stack_size = 50, subgroup = "raw-material", order = "a",
            use_placeholder_icon = true
        }
        created_prototypes[#created_prototypes + 1] = {type = "item", name = "test-item-placeholder-strip"}

        Assert.equals(data.raw["item"]["test-item-placeholder-strip"].use_placeholder_icon, nil)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Item.create auto-derives icon from default_icon_path when none given",
    "lib.item",
    function()
        Tirislib.Item.create {
            type = "item", name = "test-item-auto-icon",
            stack_size = 50, subgroup = "raw-material", order = "a"
        }
        created_prototypes[#created_prototypes + 1] = {type = "item", name = "test-item-auto-icon"}

        local expected = Tirislib.Prototype.default_icon_path .. "test-item-auto-icon.png"
        Assert.equals(data.raw["item"]["test-item-auto-icon"].icon, expected)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << Item.create: sprite_variations meta-key >>

Tirislib.Testing.add_test_case(
    "Item.create strips sprite_variations from data.raw prototype",
    "lib.item",
    function()
        Tirislib.Item.create {
            type = "item", name = "test-item-sv-strip",
            stack_size = 50, subgroup = "raw-material", order = "a",
            icon = "dummy.png", icon_size = 64,
            sprite_variations = {name = "dummy-pile", path = "p/", count = 2}
        }
        created_prototypes[#created_prototypes + 1] = {type = "item", name = "test-item-sv-strip"}

        Assert.equals(data.raw["item"]["test-item-sv-strip"].sprite_variations, nil)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Item.create sprite_variations builds correct picture filenames",
    "lib.item",
    function()
        local item = Tirislib.Item.create {
            type = "item", name = "test-item-sv-filenames",
            stack_size = 50, subgroup = "raw-material", order = "a",
            icon = "dummy.png", icon_size = 64,
            sprite_variations = {name = "pile", path = "custom/path/", count = 3}
        }
        created_prototypes[#created_prototypes + 1] = {type = "item", name = "test-item-sv-filenames"}

        Assert.equals(#item.pictures, 3)
        Assert.equals(item.pictures[1].filename, "custom/path/pile-1.png")
        Assert.equals(item.pictures[3].filename, "custom/path/pile-3.png")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Item.create sprite_variations include_icon appends icon as extra picture",
    "lib.item",
    function()
        local item = Tirislib.Item.create {
            type = "item", name = "test-item-sv-include-icon",
            stack_size = 50, subgroup = "raw-material", order = "a",
            icon = "my-icon.png", icon_size = 64,
            sprite_variations = {name = "pile", path = "p/", count = 2, include_icon = true}
        }
        created_prototypes[#created_prototypes + 1] = {type = "item", name = "test-item-sv-include-icon"}

        Assert.equals(#item.pictures, 3)
        Assert.equals(item.pictures[3].filename, "my-icon.png")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Item.create sprite_variations falls back to default_icon_path when path is omitted",
    "lib.item",
    function()
        local item = Tirislib.Item.create {
            type = "item", name = "test-item-sv-default-path",
            stack_size = 50, subgroup = "raw-material", order = "a",
            icon = "dummy.png", icon_size = 64,
            sprite_variations = {name = "my-pile", count = 1}
        }
        created_prototypes[#created_prototypes + 1] = {type = "item", name = "test-item-sv-default-path"}

        local expected = Tirislib.Prototype.default_icon_path .. "my-pile-1.png"
        Assert.equals(item.pictures[1].filename, expected)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << Item.batch_create >>

local function batch_create_test_items(items, batch_data)
    local results = Tirislib.Item.batch_create(items, batch_data)
    for _, item in pairs(results) do
        created_prototypes[#created_prototypes + 1] = {type = item.type or "item", name = item.name}
    end
    return results
end

Tirislib.Testing.add_test_case(
    "Item.batch_create item fields override batch_data defaults",
    "lib.item",
    function()
        local results = batch_create_test_items(
            {{name = "test-item-bc-override", stack_size = 99}},
            {subgroup = "raw-material", stack_size = 50}
        )

        Assert.equals(results[1].stack_size, 99)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Item.batch_create auto-generates icon from default_icon_path and name",
    "lib.item",
    function()
        batch_create_test_items(
            {{name = "test-item-bc-auto-icon"}},
            {subgroup = "raw-material"}
        )

        local item = data.raw["item"]["test-item-bc-auto-icon"]
        Assert.equals(item.icon, Tirislib.Prototype.default_icon_path .. "test-item-bc-auto-icon.png")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Item.batch_create skips auto-icon when use_placeholder_icon is set",
    "lib.item",
    function()
        local results = batch_create_test_items(
            {{name = "test-item-bc-placeholder", use_placeholder_icon = true}},
            {subgroup = "raw-material"}
        )

        Assert.equals(results[1].icon, Tirislib.Prototype.placeholder_icon)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Item.batch_create skips auto-icon when icon is explicitly set on the entry",
    "lib.item",
    function()
        batch_create_test_items(
            {{name = "test-item-bc-explicit-icon", icon = "explicit.png", icon_size = 64}},
            {subgroup = "raw-material"}
        )

        local item = data.raw["item"]["test-item-bc-explicit-icon"]
        Assert.equals(item.icon, "explicit.png")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Item.batch_create applies stack_size = 200 default",
    "lib.item",
    function()
        local results = batch_create_test_items(
            {{name = "test-item-bc-stack-default"}},
            {subgroup = "raw-material"}
        )

        Assert.equals(results[1].stack_size, 200)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Item.batch_create applies icon_size = 64 default",
    "lib.item",
    function()
        local results = batch_create_test_items(
            {{name = "test-item-bc-icon-size-default"}},
            {subgroup = "raw-material"}
        )

        Assert.equals(results[1].icon_size, 64)
    end,
    setup,
    teardown
)
