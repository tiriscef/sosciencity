local Assert = Tirislib.Testing.Assert

local created_prototypes = {}
local saved_pending

local function setup()
    created_prototypes = {}
    saved_pending = Tirislib.Recipe.pending_item_unlocks
    Tirislib.Recipe.pending_item_unlocks = {}
end

local function teardown()
    for _, proto in pairs(created_prototypes) do
        if data.raw[proto.type] then
            data.raw[proto.type][proto.name] = nil
        end
    end
    created_prototypes = {}
    Tirislib.Recipe.pending_item_unlocks = saved_pending
end

local function create_item(name)
    local proto = {type = "item", name = name, stack_size = 50, subgroup = "raw-material", order = "a"}
    created_prototypes[#created_prototypes + 1] = proto
    Tirislib.Prototype.create(proto)
end

--- Creates a recipe that turns `ingredient` (optional) into `result`.
local function create_recipe(name, result, ingredient, enabled)
    local proto = {
        type = "recipe",
        name = name,
        enabled = enabled,
        ingredients = ingredient and {{type = "item", name = ingredient, amount = 1}} or {},
        results = {{type = "item", name = result, amount = 1}}
    }
    created_prototypes[#created_prototypes + 1] = proto
    return Tirislib.Recipe.create(proto)
end

local function create_tech(name, prerequisites, unlocks)
    local effects = {}
    for _, recipe_name in pairs(unlocks or {}) do
        effects[#effects + 1] = {type = "unlock-recipe", recipe = recipe_name}
    end
    local proto = {
        type = "technology",
        name = name,
        prerequisites = prerequisites,
        unit = {count = 10, time = 30, ingredients = {{"automation-science-pack", 1}}},
        effects = effects
    }
    created_prototypes[#created_prototypes + 1] = proto
    return Tirislib.Technology.create(proto)
end

local function unlocks(technology_name, recipe_name)
    for _, effect in pairs(data.raw["technology"][technology_name].effects or {}) do
        if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
            return true
        end
    end
    return false
end

Tirislib.Testing.add_test_case(
    "unlock_with_item: item available from the start keeps the recipe enabled",
    "lib.recipe|lib.unlock-with-item",
    function()
        create_item("test-uwi-wood")
        create_item("test-uwi-lumber")
        create_recipe("test-uwi-gather", "test-uwi-wood", nil, true)
        local recipe = create_recipe("test-uwi-saw", "test-uwi-lumber", "test-uwi-wood", true)

        recipe:add_unlock_with_item("test-uwi-wood")
        Assert.equals(recipe.enabled, false, "disabled until resolved")

        Tirislib.Recipe.resolve_item_unlocks()
        Assert.equals(recipe.enabled, true)
        Assert.is_table_empty(Tirislib.Recipe.pending_item_unlocks)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "unlock_with_item: only the earliest of dependent technologies unlocks the recipe",
    "lib.recipe|lib.unlock-with-item",
    function()
        create_item("test-uwi-wood")
        create_item("test-uwi-lumber")
        create_recipe("test-uwi-farm", "test-uwi-wood", nil, false)
        create_recipe("test-uwi-farm-2", "test-uwi-wood", nil, false)
        create_tech("test-uwi-early", nil, {"test-uwi-farm"})
        create_tech("test-uwi-middle", {"test-uwi-early"})
        create_tech("test-uwi-late", {"test-uwi-middle"}, {"test-uwi-farm-2"})
        local recipe = create_recipe("test-uwi-saw", "test-uwi-lumber", "test-uwi-wood")

        recipe:add_unlock_with_item("test-uwi-wood")
        Tirislib.Recipe.resolve_item_unlocks()

        Assert.equals(recipe.enabled, false)
        Assert.is_true(unlocks("test-uwi-early", "test-uwi-saw"), "earliest tech unlocks it")
        Assert.is_false(unlocks("test-uwi-late", "test-uwi-saw"), "indirect successor doesn't")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "unlock_with_item: independent technologies all unlock the recipe",
    "lib.recipe|lib.unlock-with-item",
    function()
        create_item("test-uwi-wood")
        create_item("test-uwi-lumber")
        create_recipe("test-uwi-farm", "test-uwi-wood", nil, false)
        create_recipe("test-uwi-farm-2", "test-uwi-wood", nil, false)
        create_tech("test-uwi-a", nil, {"test-uwi-farm"})
        create_tech("test-uwi-b", nil, {"test-uwi-farm-2"})
        local recipe = create_recipe("test-uwi-saw", "test-uwi-lumber", "test-uwi-wood")

        recipe:add_unlock_with_item("test-uwi-wood")
        Tirislib.Recipe.resolve_item_unlocks()

        Assert.is_true(unlocks("test-uwi-a", "test-uwi-saw"))
        Assert.is_true(unlocks("test-uwi-b", "test-uwi-saw"))
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "unlock_with_item: chains resolve in order",
    "lib.recipe|lib.unlock-with-item",
    function()
        create_item("test-uwi-wood")
        create_item("test-uwi-lumber")
        create_item("test-uwi-chair")
        create_recipe("test-uwi-farm", "test-uwi-wood", nil, false)
        create_tech("test-uwi-a", nil, {"test-uwi-farm"})
        local saw = create_recipe("test-uwi-saw", "test-uwi-lumber", "test-uwi-wood")
        local chair = create_recipe("test-uwi-chair", "test-uwi-chair", "test-uwi-lumber")

        -- registered in the "wrong" order on purpose: the chair waits for the saw
        chair:add_unlock_with_item("test-uwi-lumber")
        saw:add_unlock_with_item("test-uwi-wood")
        Tirislib.Recipe.resolve_item_unlocks()

        Assert.is_true(unlocks("test-uwi-a", "test-uwi-saw"))
        Assert.is_true(unlocks("test-uwi-a", "test-uwi-chair"))
        Assert.is_table_empty(Tirislib.Recipe.pending_item_unlocks)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "unlock_with_item: item without a producing recipe stays locked and gets reported",
    "lib.recipe|lib.unlock-with-item",
    function()
        create_item("test-uwi-wood")
        create_item("test-uwi-lumber")
        local recipe = create_recipe("test-uwi-saw", "test-uwi-lumber", "test-uwi-wood", true)

        recipe:add_unlock_with_item("test-uwi-wood")
        Tirislib.Recipe.resolve_item_unlocks()

        Assert.equals(recipe.enabled, false)
        Assert.equals(Tirislib.Recipe.describe_unresolved_item_unlocks(), {"test-uwi-saw with test-uwi-wood"})
    end,
    setup,
    teardown
)
