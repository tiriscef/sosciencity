local Assert = Tirislib.Testing.Assert

local created_prototypes = {}

local function setup()
    created_prototypes = {}
end

local function create_test_item(name)
    local proto = {type = "item", name = name, stack_size = 50, subgroup = "raw-material", order = "a"}
    created_prototypes[#created_prototypes + 1] = proto
    Tirislib.Prototype.create(proto)
end

local function create_recipe(name, fields)
    local proto = {
        name = name,
        enabled = true,
        energy_required = 0.5,
        ingredients = {},
        results = {{type = "item", name = name .. "-result", amount = 1}}
    }
    if fields then
        for k, v in pairs(fields) do
            proto[k] = v
        end
    end
    create_test_item(name .. "-result")
    local created_prototype = Tirislib.Recipe.create(proto)
    created_prototypes[#created_prototypes + 1] = created_prototype
    return created_prototype
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
-- << Recipe.create and Recipe.get >>

Tirislib.Testing.add_test_case(
    "Recipe.create adds a recipe to data.raw",
    "lib.recipe",
    function()
        create_recipe("test-r-create")

        local recipe, found = Tirislib.Recipe.get_by_name("test-r-create")
        Assert.is_true(found)
        Assert.equals(recipe.name, "test-r-create")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe.get_by_name returns dummy for nonexistent recipe",
    "lib.recipe",
    function()
        local _, found = Tirislib.Recipe.get_by_name("test-r-nonexistent-xyz")
        Assert.is_false(found)
    end
)

Tirislib.Testing.add_test_case(
    "Recipe.create sets default fields",
    "lib.recipe",
    function()
        create_recipe("test-r-defaults")

        local recipe = Tirislib.Recipe.get_by_name("test-r-defaults")
        Assert.equals(recipe.type, "recipe")
        Assert.not_nil(recipe.ingredients)
        Assert.not_nil(recipe.results)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << set_field / set_fields / get_field >>

Tirislib.Testing.add_test_case(
    "Recipe:set_field sets a field and returns self",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-setfield")
        local ret = recipe:set_field("category", "smelting")

        Assert.equals(recipe.category, "smelting")
        Assert.equals(ret.name, recipe.name)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:set_fields sets multiple fields",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-setfields")
        recipe:set_fields({category = "smelting", hidden = true})

        Assert.equals(recipe.category, "smelting")
        Assert.is_true(recipe.hidden)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:set_fields handles nil gracefully",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-setfields-nil")
        recipe:set_fields(nil)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:get_field returns default for unset fields",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-getfield")

        Assert.equals(recipe:get_field("category"), "crafting")
        Assert.equals(recipe:get_field("emissions_multiplier"), 1)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:get_field returns explicit value over default",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-getfield-explicit")
        recipe.category = "smelting"

        Assert.equals(recipe:get_field("category"), "smelting")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << ingredients >>

Tirislib.Testing.add_test_case(
    "Recipe:add_ingredient adds an ingredient",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-add-ingr")
        recipe:add_ingredient({type = "item", name = "iron-plate", amount = 5})

        Assert.is_true(recipe:has_ingredient("iron-plate"))
        Assert.equals(recipe:get_ingredient_count("iron-plate"), 5)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:add_ingredient merges duplicate ingredients",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-merge-ingr")
        recipe:add_ingredient({type = "item", name = "iron-plate", amount = 3})
        recipe:add_ingredient({type = "item", name = "iron-plate", amount = 2})

        Assert.equals(recipe:get_ingredient_count("iron-plate"), 5)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:add_ingredient ignores nil",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-nil-ingr")
        recipe:add_ingredient(nil)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:add_ingredient_range adds multiple ingredients",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-range-ingr")
        recipe:add_ingredient_range({
            {type = "item", name = "iron-plate", amount = 2},
            {type = "item", name = "copper-plate", amount = 3}
        })

        Assert.is_true(recipe:has_ingredient("iron-plate"))
        Assert.is_true(recipe:has_ingredient("copper-plate"))
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:add_ingredient_range handles nil",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-range-nil")
        recipe:add_ingredient_range(nil)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:remove_ingredient removes an ingredient",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-rm-ingr")
        recipe:add_ingredient({type = "item", name = "iron-plate", amount = 5})
        recipe:remove_ingredient("iron-plate")

        Assert.is_false(recipe:has_ingredient("iron-plate"))
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:clear_ingredients removes all ingredients",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-clear-ingr")
        recipe:add_ingredient({type = "item", name = "iron-plate", amount = 1})
        recipe:add_ingredient({type = "item", name = "copper-plate", amount = 1})
        recipe:clear_ingredients()

        Assert.is_false(recipe:has_ingredient("iron-plate"))
        Assert.is_false(recipe:has_ingredient("copper-plate"))
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:get_ingredient_count returns 0 for missing ingredient",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-no-ingr")
        Assert.equals(recipe:get_ingredient_count("nonexistent"), 0)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << results >>

Tirislib.Testing.add_test_case(
    "Recipe:add_result adds a result",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-add-result")
        recipe:add_result({type = "item", name = "copper-plate", amount = 2})

        Assert.is_true(recipe:has_result("copper-plate"))
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:add_result merges duplicates by default",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-merge-result")
        recipe:add_result({type = "item", name = "copper-plate", amount = 3})
        recipe:add_result({type = "item", name = "copper-plate", amount = 2})

        Assert.equals(recipe:get_result_count("copper-plate"), 5)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:add_result with suppress_merge creates separate entries",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-suppress")
        recipe:add_result({type = "item", name = "copper-plate", amount = 3}, true)
        recipe:add_result({type = "item", name = "copper-plate", amount = 2}, true)

        -- both entries exist; total count is still 5 but as separate entries
        Assert.equals(recipe:get_result_count("copper-plate"), 5)
        -- count the actual entries
        local count = 0
        for _, r in recipe:iterate_results() do
            if r.name == "copper-plate" then
                count = count + 1
            end
        end
        Assert.equals(count, 2)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:remove_result removes a result",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-rm-result")
        recipe:add_result({type = "item", name = "copper-plate", amount = 1})
        recipe:remove_result("copper-plate")

        Assert.is_false(recipe:has_result("copper-plate"))
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:clear_results removes all results",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-clear-results")
        recipe:clear_results()

        -- the default result from create_recipe is gone
        Assert.equals(recipe:get_first_result(), nil)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:get_first_result returns the first result name",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-first-result")
        Assert.equals(recipe:get_first_result(), "test-r-first-result-result")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << replace >>

Tirislib.Testing.add_test_case(
    "Recipe:replace_ingredient replaces by name",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-replace-ingr")
        recipe:add_ingredient({type = "item", name = "iron-plate", amount = 5})
        recipe:replace_ingredient("iron-plate", "steel-plate")

        Assert.is_false(recipe:has_ingredient("iron-plate"))
        Assert.is_true(recipe:has_ingredient("steel-plate"))
        Assert.equals(recipe:get_ingredient_count("steel-plate"), 5)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:replace_ingredient applies amount_fn",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-replace-fn")
        recipe:add_ingredient({type = "item", name = "iron-plate", amount = 4})
        recipe:replace_ingredient("iron-plate", "steel-plate", nil, nil, function(a) return a * 2 end)

        Assert.equals(recipe:get_ingredient_count("steel-plate"), 8)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << fluid indexing >>

Tirislib.Testing.add_test_case(
    "Recipe:index_fluid_ingredients assigns consecutive fluidbox indices",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-fluid-idx")
        recipe:add_ingredient({type = "item", name = "iron-plate", amount = 1})
        recipe:add_ingredient({type = "fluid", name = "water", amount = 10})
        recipe:add_ingredient({type = "fluid", name = "steam", amount = 5})
        recipe:index_fluid_ingredients()

        local water_idx, steam_idx
        for _, ingr in recipe:iterate_ingredients() do
            if ingr.name == "water" then water_idx = ingr.fluidbox_index end
            if ingr.name == "steam" then steam_idx = ingr.fluidbox_index end
        end
        Assert.equals(water_idx, 1)
        Assert.equals(steam_idx, 2)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << catalyst >>

Tirislib.Testing.add_test_case(
    "Recipe:add_catalyst adds both ingredient and result",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-catalyst")
        recipe:add_catalyst("iron-plate", "item", 5, 0.9)

        Assert.is_true(recipe:has_ingredient("iron-plate"))
        Assert.is_true(recipe:has_result("iron-plate"))
        Assert.equals(recipe:get_ingredient_count("iron-plate"), 5)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << copy >>

Tirislib.Testing.add_test_case(
    "Recipe.copy creates an independent copy",
    "lib.recipe",
    function()
        local original = create_recipe("test-r-copy-orig")
        original:add_ingredient({type = "item", name = "iron-plate", amount = 3})

        local copy, found = Tirislib.Recipe.copy("test-r-copy-orig", "test-r-copy-new")
        created_prototypes[#created_prototypes + 1] = copy
        Assert.is_true(found)
        Assert.equals(copy.name, "test-r-copy-new")
        Assert.is_true(copy:has_ingredient("iron-plate"))

        -- modifying the copy should not affect the original
        copy:remove_ingredient("iron-plate")
        Assert.is_true(original:has_ingredient("iron-plate"))
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe.copy returns dummy for nonexistent recipe",
    "lib.recipe",
    function()
        local _, found = Tirislib.Recipe.copy("test-r-copy-missing-xyz", "test-r-copy-new2")
        Assert.is_false(found)
    end
)

---------------------------------------------------------------------------------------------------
-- << Recipe.get (unified) and get_from_prototype >>

Tirislib.Testing.add_test_case(
    "Recipe.get with string delegates to get_by_name",
    "lib.recipe",
    function()
        create_recipe("test-r-get-str")

        local recipe, found = Tirislib.Recipe.get("test-r-get-str")
        Assert.is_true(found)
        Assert.equals(recipe.name, "test-r-get-str")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe.get with table delegates to get_from_prototype",
    "lib.recipe",
    function()
        local proto = {name = "test-r-get-tbl", type = "recipe", ingredients = {}, results = {}}
        local recipe = Tirislib.Recipe.get(proto)

        -- should have set the metatable so recipe methods work
        Assert.not_nil(recipe.set_field)
        Assert.equals(recipe.name, "test-r-get-tbl")
    end
)

---------------------------------------------------------------------------------------------------
-- << iterate and all >>

Tirislib.Testing.add_test_case(
    "Recipe.iterate iterates over all recipes in data.raw",
    "lib.recipe",
    function()
        create_recipe("test-r-iter-a")
        create_recipe("test-r-iter-b")

        local found_a, found_b = false, false
        for _, recipe in Tirislib.Recipe.iterate() do
            if recipe.name == "test-r-iter-a" then found_a = true end
            if recipe.name == "test-r-iter-b" then found_b = true end
        end
        Assert.is_true(found_a)
        Assert.is_true(found_b)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe.all returns an array of all recipes",
    "lib.recipe",
    function()
        create_recipe("test-r-all-x")

        local all = Tirislib.Recipe.all()
        local found = false
        for _, recipe in pairs(all) do
            if recipe.name == "test-r-all-x" then found = true end
        end
        Assert.is_true(found)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << get_first_ingredient, get_ingredient, get_result >>

Tirislib.Testing.add_test_case(
    "Recipe:get_first_ingredient returns the first ingredient name",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-first-ingr")
        recipe:add_ingredient({type = "item", name = "iron-plate", amount = 1})
        recipe:add_ingredient({type = "item", name = "copper-plate", amount = 1})

        Assert.equals(recipe:get_first_ingredient(), "iron-plate")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:get_ingredient returns the entry for a matching ingredient",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-get-ingr")
        recipe:add_ingredient({type = "item", name = "iron-plate", amount = 7})

        local entry = recipe:get_ingredient("iron-plate", "item")
        Assert.not_nil(entry)
        Assert.equals(entry.amount, 7)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:get_ingredient returns nil for non-matching ingredient",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-get-ingr-nil")
        Assert.is_nil(recipe:get_ingredient("nonexistent", "item"))
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:get_result returns the entry for a matching result",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-get-res")
        -- create_recipe adds a result named "test-r-get-res-result"
        local entry = recipe:get_result("test-r-get-res-result", "item")
        Assert.not_nil(entry)
        Assert.equals(entry.amount, 1)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:get_result returns nil for non-matching result",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-get-res-nil")
        Assert.is_nil(recipe:get_result("nonexistent", "item"))
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << add_new_ingredient, add_new_result, add_result_range >>

Tirislib.Testing.add_test_case(
    "Recipe:add_new_ingredient constructs and adds an ingredient entry",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-new-ingr")
        recipe:add_new_ingredient("iron-plate", 4)

        Assert.is_true(recipe:has_ingredient("iron-plate"))
        Assert.equals(recipe:get_ingredient_count("iron-plate"), 4)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:add_new_ingredient defaults type to item",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-new-ingr-type")
        recipe:add_new_ingredient("iron-plate", 1)

        local entry = recipe:get_ingredient("iron-plate", "item")
        Assert.not_nil(entry)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:add_new_result constructs and adds a result entry",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-new-result")
        recipe:add_new_result("copper-plate", 3)

        Assert.is_true(recipe:has_result("copper-plate"))
        Assert.equals(recipe:get_result_count("copper-plate"), 3)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:add_result_range adds multiple results",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-res-range")
        recipe:add_result_range({
            {type = "item", name = "iron-plate", amount = 2},
            {type = "item", name = "copper-plate", amount = 3}
        })

        Assert.is_true(recipe:has_result("iron-plate"))
        Assert.is_true(recipe:has_result("copper-plate"))
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:add_result_range handles nil",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-res-range-nil")
        recipe:add_result_range(nil)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << replace_result >>

Tirislib.Testing.add_test_case(
    "Recipe:replace_result replaces by name",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-replace-res")
        recipe:add_result({type = "item", name = "iron-plate", amount = 4})
        recipe:replace_result("iron-plate", "steel-plate")

        Assert.is_false(recipe:has_result("iron-plate"))
        Assert.is_true(recipe:has_result("steel-plate"))
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:replace_result applies amount_fn",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-replace-res-fn")
        recipe:add_result({type = "item", name = "iron-plate", amount = 4})
        recipe:replace_result("iron-plate", "steel-plate", nil, nil, function(a) return a * 3 end)

        Assert.equals(recipe:get_result_count("steel-plate"), 12)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << transform_ingredient_entries, transform_result_entries >>

Tirislib.Testing.add_test_case(
    "Recipe:transform_ingredient_entries applies fn to each ingredient",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-transform-ingr")
        recipe:add_ingredient({type = "item", name = "iron-plate", amount = 2})
        recipe:add_ingredient({type = "item", name = "copper-plate", amount = 3})

        recipe:transform_ingredient_entries(function(entry)
            entry.amount = entry.amount * 10
        end)

        Assert.equals(recipe:get_ingredient_count("iron-plate"), 20)
        Assert.equals(recipe:get_ingredient_count("copper-plate"), 30)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:transform_result_entries applies fn to each result",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-transform-res")
        recipe:add_result({type = "item", name = "copper-plate", amount = 4})

        recipe:transform_result_entries(function(entry)
            entry.amount = entry.amount * 5
        end)

        Assert.equals(recipe:get_result_count("copper-plate"), 20)
        -- the default result also got transformed
        Assert.equals(recipe:get_result_count("test-r-transform-res-result"), 5)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << index_fluid_results >>

Tirislib.Testing.add_test_case(
    "Recipe:index_fluid_results assigns consecutive fluidbox indices",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-fluid-res-idx")
        recipe:add_result({type = "fluid", name = "water", amount = 10})
        recipe:add_result({type = "fluid", name = "steam", amount = 5})
        recipe:index_fluid_results()

        local water_idx, steam_idx
        for _, res in recipe:iterate_results() do
            if res.name == "water" then water_idx = res.fluidbox_index end
            if res.name == "steam" then steam_idx = res.fluidbox_index end
        end
        Assert.equals(water_idx, 1)
        Assert.equals(steam_idx, 2)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:index_fluid_results skips non-fluid results",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-fluid-res-skip")
        recipe:add_result({type = "fluid", name = "water", amount = 10})
        recipe:index_fluid_results()

        -- the default item result should not have a fluidbox_index
        local item_entry = recipe:get_result("test-r-fluid-res-skip-result", "item")
        Assert.is_nil(item_entry.fluidbox_index)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << copy_localisation_from_item, copy_icon_from_item >>

Tirislib.Testing.add_test_case(
    "Recipe:copy_localisation_from_item copies name and description",
    "lib.recipe",
    function()
        create_test_item("test-r-loc-item")
        local recipe = create_recipe("test-r-loc")
        recipe:copy_localisation_from_item("test-r-loc-item")

        Assert.not_nil(recipe.localised_name)
        Assert.not_nil(recipe.localised_description)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:copy_icon_from_item copies icon fields",
    "lib.recipe",
    function()
        create_test_item("test-r-icon-item")
        -- set an icon on the item so we can verify it copies
        local item = Tirislib.Item.get_by_name("test-r-icon-item")
        item.icon = "__base__/graphics/icons/iron-plate.png"
        item.icon_size = 64

        local recipe = create_recipe("test-r-icon")
        recipe:copy_icon_from_item("test-r-icon-item")

        Assert.equals(recipe.icon, "__base__/graphics/icons/iron-plate.png")
        Assert.equals(recipe.icon_size, 64)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << pairing methods >>

Tirislib.Testing.add_test_case(
    "Recipe:pair_result_with_ingredient adds ingredient when result exists",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-pair-ri")
        -- default result is "test-r-pair-ri-result" with amount 1
        recipe:pair_result_with_ingredient("test-r-pair-ri-result", "item", "iron-plate", "item")

        Assert.is_true(recipe:has_ingredient("iron-plate"))
        Assert.equals(recipe:get_ingredient_count("iron-plate"), 1)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:pair_result_with_ingredient does nothing when result is absent",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-pair-ri-no")
        recipe:pair_result_with_ingredient("nonexistent", "item", "iron-plate", "item")

        Assert.is_false(recipe:has_ingredient("iron-plate"))
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:pair_result_with_ingredient applies amount_fn",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-pair-ri-fn")
        recipe:add_result({type = "item", name = "copper-plate", amount = 4})
        recipe:pair_result_with_ingredient("copper-plate", "item", "iron-plate", "item", function(a) return a * 2 end)

        Assert.equals(recipe:get_ingredient_count("iron-plate"), 8)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:pair_result_with_result adds result when trigger result exists",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-pair-rr")
        recipe:pair_result_with_result("test-r-pair-rr-result", "item", "copper-plate", "item")

        Assert.is_true(recipe:has_result("copper-plate"))
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:pair_result_with_result does nothing when trigger result is absent",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-pair-rr-no")
        recipe:pair_result_with_result("nonexistent", "item", "copper-plate", "item")

        Assert.is_false(recipe:has_result("copper-plate"))
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:pair_ingredient_with_result adds result when ingredient exists",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-pair-ir")
        recipe:add_ingredient({type = "item", name = "iron-plate", amount = 3})
        recipe:pair_ingredient_with_result("iron-plate", "item", "copper-plate", "item")

        Assert.is_true(recipe:has_result("copper-plate"))
        Assert.equals(recipe:get_result_count("copper-plate"), 3)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:pair_ingredient_with_result does nothing when ingredient is absent",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-pair-ir-no")
        recipe:pair_ingredient_with_result("nonexistent", "item", "copper-plate", "item")

        Assert.is_false(recipe:has_result("copper-plate"))
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:pair_ingredient_with_ingredient adds ingredient when trigger ingredient exists",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-pair-ii")
        recipe:add_ingredient({type = "item", name = "iron-plate", amount = 5})
        recipe:pair_ingredient_with_ingredient("iron-plate", "item", "copper-plate", "item")

        Assert.is_true(recipe:has_ingredient("copper-plate"))
        Assert.equals(recipe:get_ingredient_count("copper-plate"), 5)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:pair_ingredient_with_ingredient does nothing when trigger ingredient is absent",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-pair-ii-no")
        recipe:pair_ingredient_with_ingredient("nonexistent", "item", "copper-plate", "item")

        Assert.is_false(recipe:has_ingredient("copper-plate"))
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Recipe:pair_ingredient_with_ingredient applies amount_fn",
    "lib.recipe",
    function()
        local recipe = create_recipe("test-r-pair-ii-fn")
        recipe:add_ingredient({type = "item", name = "iron-plate", amount = 6})
        recipe:pair_ingredient_with_ingredient("iron-plate", "item", "copper-plate", "item", function(a) return a / 2 end)

        Assert.equals(recipe:get_ingredient_count("copper-plate"), 3)
    end,
    setup,
    teardown
)
