local Assert = Tirislib.Testing.Assert

local created_prototypes = {}

local function setup()
    created_prototypes = {}
end

local function create_test_category(name)
    local proto = {type = "recipe-category", name = name}
    created_prototypes[#created_prototypes + 1] = proto
    return Tirislib.RecipeCategory.create(proto)
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
-- << RecipeCategory.create and RecipeCategory.get >>

Tirislib.Testing.add_test_case(
    "RecipeCategory.create adds a category to data.raw",
    "lib.recipe-category",
    function()
        create_test_category("test-cat-create")

        local cat, found = Tirislib.RecipeCategory.get_by_name("test-cat-create")
        Assert.is_true(found)
        Assert.equals(cat.name, "test-cat-create")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "RecipeCategory.get returns dummy for nonexistent category",
    "lib.recipe-category",
    function()
        local cat, found = Tirislib.RecipeCategory.get_by_name("nonexistent-cat-xyz")
        Assert.is_false(found)
        Assert.is_true(Tirislib.Prototype.is_dummy(cat))
    end
)
