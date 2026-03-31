local Assert = Tirislib.Testing.Assert

local created_prototypes = {}

local function setup()
    created_prototypes = {}
end

local function create_test_item(name, fields)
    local proto = {type = "item", name = name, stack_size = 50}
    if fields then
        for k, v in pairs(fields) do
            proto[k] = v
        end
    end
    created_prototypes[#created_prototypes + 1] = proto
    return Tirislib.Prototype.create(proto)
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
-- << Prototype.create and Prototype.get >>

Tirislib.Testing.add_test_case(
    "Prototype.create adds a prototype to data.raw",
    "lib.prototype",
    function()
        create_test_item("test-prototype-create")

        local proto, found = Tirislib.Prototype.get("item", "test-prototype-create")
        Assert.is_true(found)
        Assert.equals(proto.name, "test-prototype-create")
        Assert.equals(proto.stack_size, 50)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Prototype.create sets the owner field",
    "lib.prototype",
    function()
        create_test_item("test-prototype-owner")

        local proto = Tirislib.Prototype.get("item", "test-prototype-owner")
        Assert.equals(proto.owner, Tirislib.Prototype.modname)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Prototype.get returns a dummy for nonexistent prototypes",
    "lib.prototype",
    function()
        local proto, found = Tirislib.Prototype.get("item", "this-does-not-exist-at-all")
        Assert.is_false(found)
        Assert.is_true(Tirislib.Prototype.is_dummy(proto))
    end
)

Tirislib.Testing.add_test_case(
    "Prototype.get searches multiple types",
    "lib.prototype",
    function()
        create_test_item("test-multi-type-search")

        local proto, found = Tirislib.Prototype.get({"recipe", "item"}, "test-multi-type-search")
        Assert.is_true(found)
        Assert.equals(proto.name, "test-multi-type-search")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "dummy prototype methods do not error",
    "lib.prototype",
    function()
        local dummy = Tirislib.Prototype.get("item", "nonexistent-dummy-test")
        -- calling arbitrary methods on a dummy should silently do nothing
        dummy:set_something("value")
        dummy:another_method(1, 2, 3)
    end
)

---------------------------------------------------------------------------------------------------
-- << Prototype.batch_create >>

Tirislib.Testing.add_test_case(
    "Prototype.batch_create creates multiple prototypes",
    "lib.prototype",
    function()
        local protos = {
            {type = "item", name = "test-batch-1", stack_size = 10},
            {type = "item", name = "test-batch-2", stack_size = 20}
        }
        for _, p in pairs(protos) do
            created_prototypes[#created_prototypes + 1] = p
        end
        Tirislib.Prototype.batch_create(protos)

        local proto1, found1 = Tirislib.Prototype.get("item", "test-batch-1")
        local proto2, found2 = Tirislib.Prototype.get("item", "test-batch-2")
        Assert.is_true(found1)
        Assert.is_true(found2)
        Assert.equals(proto1.stack_size, 10)
        Assert.equals(proto2.stack_size, 20)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << Prototype.get_unique_name >>

Tirislib.Testing.add_test_case(
    "get_unique_name returns the name itself if no collision",
    "lib.prototype",
    function()
        local name = Tirislib.Prototype.get_unique_name("unique-name-test-xyz", "item")
        Assert.equals(name, "unique-name-test-xyz")
    end
)

Tirislib.Testing.add_test_case(
    "get_unique_name appends a number on collision",
    "lib.prototype",
    function()
        create_test_item("test-collision-name")

        local name = Tirislib.Prototype.get_unique_name("test-collision-name", "item")
        Assert.unequal(name, "test-collision-name")
        Assert.equals(name, "test-collision-name1")
    end,
    setup,
    teardown
)
