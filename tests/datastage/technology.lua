local Assert = Tirislib.Testing.Assert

local created_prototypes = {}

local function setup()
    created_prototypes = {}
end

local function create_test_tech(name, fields)
    local proto = {
        type = "technology",
        name = name,
        unit = {count = 10, time = 30, ingredients = {{"automation-science-pack", 1}}},
        effects = {}
    }
    if fields then
        for k, v in pairs(fields) do
            proto[k] = v
        end
    end
    created_prototypes[#created_prototypes + 1] = proto
    return Tirislib.Technology.create(proto)
end

local function create_test_recipe(name)
    local item_proto = {type = "item", name = name .. "-result", stack_size = 50, subgroup = "raw-material", order = "a"}
    created_prototypes[#created_prototypes + 1] = item_proto
    Tirislib.Prototype.create(item_proto)

    local proto = {
        type = "recipe",
        name = name,
        ingredients = {},
        results = {{type = "item", name = name .. "-result", amount = 1}}
    }
    created_prototypes[#created_prototypes + 1] = proto
    Tirislib.Prototype.create(proto)
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
-- << Technology.create and Technology.get >>

Tirislib.Testing.add_test_case(
    "Technology.create adds a technology to data.raw",
    "lib.technology",
    function()
        create_test_tech("test-tech-create")

        local tech, found = Tirislib.Technology.get_by_name("test-tech-create")
        Assert.is_true(found)
        Assert.equals(tech.name, "test-tech-create")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Technology.get returns dummy for nonexistent technology",
    "lib.technology",
    function()
        local tech, found = Tirislib.Technology.get_by_name("nonexistent-tech-xyz")
        Assert.is_false(found)
        Assert.is_true(Tirislib.Prototype.is_dummy(tech))
    end
)

---------------------------------------------------------------------------------------------------
-- << add_effect >>

Tirislib.Testing.add_test_case(
    "Technology:add_effect adds an effect",
    "lib.technology",
    function()
        local tech = create_test_tech("test-tech-effect")
        tech:add_effect({type = "unlock-recipe", recipe = "some-recipe"})

        Assert.equals(#tech.effects, 1)
        Assert.equals(tech.effects[1].recipe, "some-recipe")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Technology:add_effect does not duplicate identical effects",
    "lib.technology",
    function()
        local tech = create_test_tech("test-tech-effect-dup")
        tech:add_effect({type = "unlock-recipe", recipe = "some-recipe"})
        tech:add_effect({type = "unlock-recipe", recipe = "some-recipe"})

        Assert.equals(#tech.effects, 1)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << add_unlock >>

Tirislib.Testing.add_test_case(
    "Technology:add_unlock adds an unlock-recipe effect",
    "lib.technology",
    function()
        local tech = create_test_tech("test-tech-unlock")
        tech:add_unlock("iron-gear-wheel")

        Assert.equals(#tech.effects, 1)
        Assert.equals(tech.effects[1].type, "unlock-recipe")
        Assert.equals(tech.effects[1].recipe, "iron-gear-wheel")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << get_unlocked_recipes >>

Tirislib.Testing.add_test_case(
    "Technology:get_unlocked_recipes returns unlocked recipes",
    "lib.technology",
    function()
        create_test_recipe("test-tech-unlocked-r")

        local tech = create_test_tech("test-tech-get-unlocks")
        tech:add_unlock("test-tech-unlocked-r")

        local recipes = tech:get_unlocked_recipes()
        Assert.equals(#recipes, 1)
        Assert.equals(recipes[1].name, "test-tech-unlocked-r")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Technology:get_unlocked_recipes skips nonexistent recipes",
    "lib.technology",
    function()
        local tech = create_test_tech("test-tech-get-unlocks-miss")
        tech:add_unlock("nonexistent-recipe-xyz")

        local recipes = tech:get_unlocked_recipes()
        Assert.equals(#recipes, 0)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << prerequisites >>

Tirislib.Testing.add_test_case(
    "Technology:add_prerequisite adds a prerequisite",
    "lib.technology",
    function()
        local tech = create_test_tech("test-tech-prereq")
        tech:add_prerequisite("automation")

        Assert.equals(#tech.prerequisites, 1)
        Assert.equals(tech.prerequisites[1], "automation")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Technology:add_prerequisite does not duplicate",
    "lib.technology",
    function()
        local tech = create_test_tech("test-tech-prereq-dup")
        tech:add_prerequisite("automation")
        tech:add_prerequisite("automation")

        Assert.equals(#tech.prerequisites, 1)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Technology:remove_prerequisite removes a prerequisite",
    "lib.technology",
    function()
        local tech = create_test_tech("test-tech-prereq-rm")
        tech:add_prerequisite("automation")
        tech:add_prerequisite("logistics")
        tech:remove_prerequisite("automation")

        Assert.equals(#tech.prerequisites, 1)
        Assert.equals(tech.prerequisites[1], "logistics")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Technology:remove_prerequisite does nothing if not present",
    "lib.technology",
    function()
        local tech = create_test_tech("test-tech-prereq-rm-miss")
        tech:add_prerequisite("automation")
        tech:remove_prerequisite("logistics")

        Assert.equals(#tech.prerequisites, 1)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << localisation >>

Tirislib.Testing.add_test_case(
    "Technology:get_localised_name returns explicit name when set",
    "lib.technology",
    function()
        local tech = create_test_tech("test-tech-loc", {localised_name = {"custom-tech"}})

        Assert.equals(tech:get_localised_name(), {"custom-tech"})
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Technology:get_localised_name falls back to technology-name key",
    "lib.technology",
    function()
        local tech = create_test_tech("test-tech-loc-default")

        Assert.equals(tech:get_localised_name(), {"technology-name.test-tech-loc-default"})
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Technology:get_localised_name strips level suffix",
    "lib.technology",
    function()
        local tech = create_test_tech("test-tech-level-3")

        Assert.equals(tech:get_localised_name(), {"technology-name.test-tech-level"})
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Technology:get_localised_name does not mutate the prototype",
    "lib.technology",
    function()
        local tech = create_test_tech("test-tech-no-mutate")
        tech:get_localised_name()

        Assert.is_nil(tech.localised_name)
    end,
    setup,
    teardown
)
