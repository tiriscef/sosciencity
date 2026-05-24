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
    return Tirislib.Prototype.create(proto)
end

local function create_test_fluid(name, fields)
    local proto = {type = "fluid", name = name, default_temperature = 15, max_temperature = 100}
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
    -- clean up any recipes we created
    if data.raw["recipe"] then
        for name, recipe in pairs(data.raw["recipe"]) do
            if string.find(name, "^test%-rg%-") then
                data.raw["recipe"][name] = nil
            end
        end
    end
    created_prototypes = {}
end

---------------------------------------------------------------------------------------------------
-- << get_nearest_level (tested indirectly through add_ingredient_theme) >>

Tirislib.Testing.add_test_case(
    "RecipeGenerator.add_ingredient_theme picks the closest level not exceeding the requested one",
    "lib.recipe-generator",
    function()
        Tirislib.RecipeGenerator.add_themes({
            ["test-rg-level-theme"] = {
                [0] = {{name = "test-rg-level-item-0", type = "item", amount = 1}},
                [2] = {{name = "test-rg-level-item-2", type = "item", amount = 1}},
                [5] = {{name = "test-rg-level-item-5", type = "item", amount = 1}}
            }
        })

        create_test_item("test-rg-level-product")
        create_test_item("test-rg-level-item-0")
        create_test_item("test-rg-level-item-2")
        create_test_item("test-rg-level-item-5")

        -- request level 3: should pick level 2 (closest without exceeding)
        local recipe = Tirislib.Recipe.create {
            name = "test-rg-level-recipe",
            enabled = true,
            energy_required = 0.5,
            results = {{type = "item", name = "test-rg-level-product", amount = 1}}
        }

        Tirislib.RecipeGenerator.add_ingredient_theme(recipe, {"test-rg-level-theme", 1, 3})

        Assert.is_true(recipe:has_ingredient("test-rg-level-item-2"))
        Assert.is_false(recipe:has_ingredient("test-rg-level-item-0"))
        Assert.is_false(recipe:has_ingredient("test-rg-level-item-5"))
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "RecipeGenerator.add_ingredient_theme uses default_level when theme entry has no level",
    "lib.recipe-generator",
    function()
        Tirislib.RecipeGenerator.add_themes({
            ["test-rg-default-level-theme"] = {
                [0] = {{name = "test-rg-dl-item-0", type = "item", amount = 1}},
                [3] = {{name = "test-rg-dl-item-3", type = "item", amount = 1}}
            }
        })

        create_test_item("test-rg-dl-product")
        create_test_item("test-rg-dl-item-0")
        create_test_item("test-rg-dl-item-3")

        local recipe = Tirislib.Recipe.create {
            name = "test-rg-dl-recipe",
            enabled = true,
            energy_required = 0.5,
            results = {{type = "item", name = "test-rg-dl-product", amount = 1}}
        }

        -- theme entry has no level (3rd element nil), default_level = 3
        Tirislib.RecipeGenerator.add_ingredient_theme(recipe, {"test-rg-default-level-theme", 1}, 3)

        Assert.is_true(recipe:has_ingredient("test-rg-dl-item-3"))
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << add_ingredient_theme_range >>

Tirislib.Testing.add_test_case(
    "RecipeGenerator.add_ingredient_theme_range adds multiple themes",
    "lib.recipe-generator",
    function()
        Tirislib.RecipeGenerator.add_themes({
            ["test-rg-range-a"] = {
                [0] = {{name = "test-rg-range-item-a", type = "item", amount = 2}}
            },
            ["test-rg-range-b"] = {
                [0] = {{name = "test-rg-range-item-b", type = "item", amount = 3}}
            }
        })

        create_test_item("test-rg-range-product")
        create_test_item("test-rg-range-item-a")
        create_test_item("test-rg-range-item-b")

        local recipe = Tirislib.Recipe.create {
            name = "test-rg-range-recipe",
            enabled = true,
            energy_required = 0.5,
            results = {{type = "item", name = "test-rg-range-product", amount = 1}}
        }

        Tirislib.RecipeGenerator.add_ingredient_theme_range(
            recipe,
            {{"test-rg-range-a", 1}, {"test-rg-range-b", 1}},
            0
        )

        Assert.is_true(recipe:has_ingredient("test-rg-range-item-a"))
        Assert.is_true(recipe:has_ingredient("test-rg-range-item-b"))
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "RecipeGenerator.add_ingredient_theme_range does nothing for nil themes",
    "lib.recipe-generator",
    function()
        create_test_item("test-rg-nil-product")

        local recipe = Tirislib.Recipe.create {
            name = "test-rg-nil-recipe",
            enabled = true,
            energy_required = 0.5,
            results = {{type = "item", name = "test-rg-nil-product", amount = 1}}
        }

        -- should not error
        Tirislib.RecipeGenerator.add_ingredient_theme_range(recipe, nil, 0)
        Assert.pass()
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << add_result_theme and add_result_theme_range >>

Tirislib.Testing.add_test_case(
    "RecipeGenerator.add_result_theme adds results from result_themes",
    "lib.recipe-generator",
    function()
        Tirislib.RecipeGenerator.add_result_themes({
            ["test-rg-result-theme"] = {
                [0] = {{name = "test-rg-result-byproduct", type = "item", amount = 1}}
            }
        })

        create_test_item("test-rg-rt-product")
        create_test_item("test-rg-result-byproduct")

        local recipe = Tirislib.Recipe.create {
            name = "test-rg-rt-recipe",
            enabled = true,
            energy_required = 0.5,
            results = {{type = "item", name = "test-rg-rt-product", amount = 1}}
        }

        Tirislib.RecipeGenerator.add_result_theme(recipe, {"test-rg-result-theme", 1, 0})

        Assert.is_true(recipe:has_result("test-rg-result-byproduct"))
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "RecipeGenerator.add_result_theme multiplies the amount",
    "lib.recipe-generator",
    function()
        Tirislib.RecipeGenerator.add_result_themes({
            ["test-rg-result-amount"] = {
                [0] = {{name = "test-rg-ra-byproduct", type = "item", amount = 2}}
            }
        })

        create_test_item("test-rg-ra-product")
        create_test_item("test-rg-ra-byproduct")

        local recipe = Tirislib.Recipe.create {
            name = "test-rg-ra-recipe",
            enabled = true,
            energy_required = 0.5,
            results = {{type = "item", name = "test-rg-ra-product", amount = 1}}
        }

        Tirislib.RecipeGenerator.add_result_theme(recipe, {"test-rg-result-amount", 3, 0})

        Assert.equals(recipe:get_result_count("test-rg-ra-byproduct"), 6)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << merge_details >>

Tirislib.Testing.add_test_case(
    "RecipeGenerator.merge_details merges ingredient arrays",
    "lib.recipe-generator",
    function()
        local lh = {
            ingredients = {{name = "a", type = "item", amount = 1}}
        }
        local rh = {
            ingredients = {{name = "b", type = "item", amount = 2}}
        }
        Tirislib.RecipeGenerator.merge_details(lh, rh)

        Assert.equals(#lh.ingredients, 2)
    end
)

Tirislib.Testing.add_test_case(
    "RecipeGenerator.merge_details sets scalar fields passively",
    "lib.recipe-generator",
    function()
        local lh = {energy_required = 5}
        local rh = {energy_required = 10, category = "smelting"}
        Tirislib.RecipeGenerator.merge_details(lh, rh)

        -- existing field not overwritten
        Assert.equals(lh.energy_required, 5)
        -- new field is set
        Assert.equals(lh.category, "smelting")
    end
)

Tirislib.Testing.add_test_case(
    "RecipeGenerator.merge_details creates array field if not present in lh",
    "lib.recipe-generator",
    function()
        local lh = {}
        local rh = {themes = {{"metal", 1}}}
        Tirislib.RecipeGenerator.merge_details(lh, rh)

        Assert.not_nil(lh.themes)
        Assert.equals(#lh.themes, 1)
    end
)

Tirislib.Testing.add_test_case(
    "RecipeGenerator.merge_details handles nil arguments gracefully",
    "lib.recipe-generator",
    function()
        -- should not error
        Tirislib.RecipeGenerator.merge_details(nil, {energy_required = 5})
        Tirislib.RecipeGenerator.merge_details({energy_required = 5}, nil)
        Tirislib.RecipeGenerator.merge_details(nil, nil)
        Assert.pass()
    end
)

---------------------------------------------------------------------------------------------------
-- << theme amount multiplier >>

Tirislib.Testing.add_test_case(
    "RecipeGenerator.add_ingredient_theme multiplies amounts by the theme amount",
    "lib.recipe-generator",
    function()
        Tirislib.RecipeGenerator.add_themes({
            ["test-rg-mult-theme"] = {
                [0] = {{name = "test-rg-mult-item", type = "item", amount = 4}}
            }
        })

        create_test_item("test-rg-mult-product")
        create_test_item("test-rg-mult-item")

        local recipe = Tirislib.Recipe.create {
            name = "test-rg-mult-recipe",
            enabled = true,
            energy_required = 0.5,
            results = {{type = "item", name = "test-rg-mult-product", amount = 1}}
        }

        Tirislib.RecipeGenerator.add_ingredient_theme(recipe, {"test-rg-mult-theme", 3, 0})

        -- 4 * 3 = 12
        Assert.equals(recipe:get_ingredient_count("test-rg-mult-item"), 12)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << create >>

Tirislib.Testing.add_test_case(
    "create creates a recipe with basic results",
    "lib.recipe-generator",
    function()
        create_test_item("test-rg-cfp-product")

        local recipe = Tirislib.RecipeGenerator.create {
            name = "test-rg-cfp-basic",
            results = {{type = "item", name = "test-rg-cfp-product", amount = 1}}
        }

        Assert.not_nil(recipe)
        Assert.is_true(recipe:has_result("test-rg-cfp-product"))
        Assert.equals(recipe.energy_required, 0.5)
        Assert.equals(recipe.enabled, true)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "create errors for a non-existent product",
    "lib.recipe-generator",
    function()
        Assert.throws(function()
            Tirislib.RecipeGenerator.create {
                name = "test-rg-nonexistent-recipe",
                results = {{type = "item", name = "test-rg-nonexistent-item-xyz", amount = 1}}
            }
        end)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "create derives fields from first result as default product",
    "lib.recipe-generator",
    function()
        create_test_item("test-rg-cfp-derive", {subgroup = "raw-material", order = "z"})

        local recipe = Tirislib.RecipeGenerator.create {
            results = {{type = "item", name = "test-rg-cfp-derive", amount = 1}}
        }

        Assert.not_nil(recipe.name)
        Assert.equals(recipe.subgroup, "raw-material")
        Assert.equals(recipe.order, "z")
        Assert.equals(recipe.main_product, "test-rg-cfp-derive")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "create respects the product flag on a non-first result",
    "lib.recipe-generator",
    function()
        create_test_item("test-rg-cfp-byprod")
        create_test_item("test-rg-cfp-main", {subgroup = "raw-material", order = "m"})

        local recipe = Tirislib.RecipeGenerator.create {
            name = "test-rg-cfp-prodflag",
            results = {
                {type = "item", name = "test-rg-cfp-byprod", amount = 1},
                {type = "item", name = "test-rg-cfp-main", amount = 2, product = true}
            }
        }

        Assert.equals(recipe.main_product, "test-rg-cfp-main")
        Assert.is_true(recipe:has_result("test-rg-cfp-byprod"))
        Assert.is_true(recipe:has_result("test-rg-cfp-main"))
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "create strips the product flag from the result entry",
    "lib.recipe-generator",
    function()
        create_test_item("test-rg-cfp-strip")

        local recipe = Tirislib.RecipeGenerator.create {
            name = "test-rg-cfp-strip-recipe",
            results = {{type = "item", name = "test-rg-cfp-strip", amount = 1, product = true}}
        }

        local result = recipe:get_result("test-rg-cfp-strip", "item")
        Assert.is_nil(result.product)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "create expands inline ingredient themes",
    "lib.recipe-generator",
    function()
        Tirislib.RecipeGenerator.add_themes({
            ["test-rg-cfp-itheme"] = {
                [0] = {{name = "test-rg-cfp-themed-ingr", type = "item", amount = 5}}
            }
        })

        create_test_item("test-rg-cfp-itheme-product")
        create_test_item("test-rg-cfp-themed-ingr")
        create_test_item("test-rg-cfp-explicit-ingr")

        local recipe = Tirislib.RecipeGenerator.create {
            name = "test-rg-cfp-itheme-recipe",
            results = {{type = "item", name = "test-rg-cfp-itheme-product", amount = 1}},
            ingredients = {
                {type = "item", name = "test-rg-cfp-explicit-ingr", amount = 3},
                {theme = "test-rg-cfp-itheme", amount = 2}
            }
        }

        Assert.is_true(recipe:has_ingredient("test-rg-cfp-explicit-ingr"))
        Assert.equals(recipe:get_ingredient_count("test-rg-cfp-explicit-ingr"), 3)
        Assert.is_true(recipe:has_ingredient("test-rg-cfp-themed-ingr"))
        -- 5 * 2 = 10
        Assert.equals(recipe:get_ingredient_count("test-rg-cfp-themed-ingr"), 10)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "create expands inline result themes",
    "lib.recipe-generator",
    function()
        Tirislib.RecipeGenerator.add_result_themes({
            ["test-rg-cfp-rtheme"] = {
                [0] = {{name = "test-rg-cfp-themed-result", type = "item", amount = 3}}
            }
        })

        create_test_item("test-rg-cfp-rtheme-product")
        create_test_item("test-rg-cfp-themed-result")

        local recipe = Tirislib.RecipeGenerator.create {
            name = "test-rg-cfp-rtheme-recipe",
            results = {
                {type = "item", name = "test-rg-cfp-rtheme-product", amount = 1},
                {theme = "test-rg-cfp-rtheme", amount = 2}
            }
        }

        Assert.is_true(recipe:has_result("test-rg-cfp-rtheme-product"))
        Assert.is_true(recipe:has_result("test-rg-cfp-themed-result"))
        -- 3 * 2 = 6
        Assert.equals(recipe:get_result_count("test-rg-cfp-themed-result"), 6)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "create respects default_theme_level for inline themes",
    "lib.recipe-generator",
    function()
        Tirislib.RecipeGenerator.add_themes({
            ["test-rg-cfp-dtl-theme"] = {
                [0] = {{name = "test-rg-cfp-dtl-item-0", type = "item", amount = 1}},
                [3] = {{name = "test-rg-cfp-dtl-item-3", type = "item", amount = 1}}
            }
        })

        create_test_item("test-rg-cfp-dtl-product")
        create_test_item("test-rg-cfp-dtl-item-0")
        create_test_item("test-rg-cfp-dtl-item-3")

        local recipe = Tirislib.RecipeGenerator.create {
            name = "test-rg-cfp-dtl-recipe",
            default_theme_level = 3,
            results = {{type = "item", name = "test-rg-cfp-dtl-product", amount = 1}},
            ingredients = {
                {theme = "test-rg-cfp-dtl-theme", amount = 1}
            }
        }

        Assert.is_true(recipe:has_ingredient("test-rg-cfp-dtl-item-3"))
        Assert.is_false(recipe:has_ingredient("test-rg-cfp-dtl-item-0"))
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "create inline theme level overrides default_theme_level",
    "lib.recipe-generator",
    function()
        Tirislib.RecipeGenerator.add_themes({
            ["test-rg-cfp-ovr-theme"] = {
                [0] = {{name = "test-rg-cfp-ovr-item-0", type = "item", amount = 1}},
                [3] = {{name = "test-rg-cfp-ovr-item-3", type = "item", amount = 1}}
            }
        })

        create_test_item("test-rg-cfp-ovr-product")
        create_test_item("test-rg-cfp-ovr-item-0")
        create_test_item("test-rg-cfp-ovr-item-3")

        local recipe = Tirislib.RecipeGenerator.create {
            name = "test-rg-cfp-ovr-recipe",
            default_theme_level = 3,
            results = {{type = "item", name = "test-rg-cfp-ovr-product", amount = 1}},
            ingredients = {
                {theme = "test-rg-cfp-ovr-theme", amount = 1, level = 0}
            }
        }

        Assert.is_true(recipe:has_ingredient("test-rg-cfp-ovr-item-0"))
        Assert.is_false(recipe:has_ingredient("test-rg-cfp-ovr-item-3"))
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "create nils extra keys from the prototype",
    "lib.recipe-generator",
    function()
        create_test_item("test-rg-cfp-nil-product")

        local recipe = Tirislib.RecipeGenerator.create {
            name = "test-rg-cfp-nil-recipe",
            results = {{type = "item", name = "test-rg-cfp-nil-product", amount = 1}},
            default_theme_level = 2,
            do_index_fluid_ingredients = true,
            do_index_fluid_results = true
        }

        Assert.is_nil(recipe.unlock)
        Assert.is_nil(recipe.default_theme_level)
        Assert.is_nil(recipe.do_index_fluid_ingredients)
        Assert.is_nil(recipe.do_index_fluid_results)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "create auto-detects crafting-with-fluid after theme expansion",
    "lib.recipe-generator",
    function()
        Tirislib.RecipeGenerator.add_themes({
            ["test-rg-cfp-fluidcat"] = {
                [0] = {{name = "test-rg-cfp-fluidcat-fluid", type = "fluid", amount = 10}}
            }
        })

        create_test_item("test-rg-cfp-fluidcat-product")
        create_test_fluid("test-rg-cfp-fluidcat-fluid")

        local recipe = Tirislib.RecipeGenerator.create {
            name = "test-rg-cfp-fluidcat-recipe",
            results = {{type = "item", name = "test-rg-cfp-fluidcat-product", amount = 1}},
            ingredients = {
                {theme = "test-rg-cfp-fluidcat", amount = 1}
            }
        }

        Assert.equals(recipe.category, "crafting-with-fluid")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "create respects explicit category",
    "lib.recipe-generator",
    function()
        create_test_item("test-rg-cfp-ecat-product")

        local recipe = Tirislib.RecipeGenerator.create {
            name = "test-rg-cfp-ecat-recipe",
            category = "smelting",
            results = {{type = "item", name = "test-rg-cfp-ecat-product", amount = 1}}
        }

        Assert.equals(recipe.category, "smelting")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "create respects explicit energy_required",
    "lib.recipe-generator",
    function()
        create_test_item("test-rg-cfp-energy-product")

        local recipe = Tirislib.RecipeGenerator.create {
            name = "test-rg-cfp-energy-recipe",
            energy_required = 10,
            results = {{type = "item", name = "test-rg-cfp-energy-product", amount = 1}}
        }

        Assert.equals(recipe.energy_required, 10)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "create works with no product when all fields are explicit",
    "lib.recipe-generator",
    function()
        local recipe = Tirislib.RecipeGenerator.create {
            name = "test-rg-cfp-noproduct",
            subgroup = "raw-material",
            order = "a",
            localised_name = {"item-name.iron-plate"},
            icon = "__base__/graphics/icons/iron-plate.png",
            icon_size = 64,
            results = {}
        }

        Assert.not_nil(recipe)
        Assert.equals(recipe.name, "test-rg-cfp-noproduct")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "create sets always_show_made_in based on category",
    "lib.recipe-generator",
    function()
        create_test_item("test-rg-cfp-asmi-product")

        local recipe_crafting = Tirislib.RecipeGenerator.create {
            name = "test-rg-cfp-asmi-crafting",
            results = {{type = "item", name = "test-rg-cfp-asmi-product", amount = 1}}
        }

        Assert.is_false(recipe_crafting.always_show_made_in)

        create_test_item("test-rg-cfp-asmi-product2")

        local recipe_smelting = Tirislib.RecipeGenerator.create {
            name = "test-rg-cfp-asmi-smelting",
            category = "smelting",
            results = {{type = "item", name = "test-rg-cfp-asmi-product2", amount = 1}}
        }

        Assert.is_true(recipe_smelting.always_show_made_in)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "create allows explicit always_show_made_in override",
    "lib.recipe-generator",
    function()
        create_test_item("test-rg-cfp-asmi-ov-product")

        local recipe = Tirislib.RecipeGenerator.create {
            name = "test-rg-cfp-asmi-ov-recipe",
            category = "smelting",
            always_show_made_in = false,
            results = {{type = "item", name = "test-rg-cfp-asmi-ov-product", amount = 1}}
        }

        Assert.is_false(recipe.always_show_made_in)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "create passes allow_productivity through as a native recipe field",
    "lib.recipe-generator",
    function()
        create_test_item("test-rg-cfp-prod-product")

        local recipe = Tirislib.RecipeGenerator.create {
            name = "test-rg-cfp-prod-recipe",
            allow_productivity = true,
            results = {{type = "item", name = "test-rg-cfp-prod-product", amount = 1}}
        }

        Assert.is_true(recipe.allow_productivity)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << merge_prototypes >>

Tirislib.Testing.add_test_case(
    "merge_prototypes concatenates ingredients arrays",
    "lib.recipe-generator",
    function()
        local lh = {
            ingredients = {{type = "item", name = "a", amount = 1}}
        }
        local rh = {
            ingredients = {{type = "item", name = "b", amount = 2}}
        }
        Tirislib.RecipeGenerator.merge_prototypes(lh, rh)

        Assert.equals(#lh.ingredients, 2)
    end
)

Tirislib.Testing.add_test_case(
    "merge_prototypes concatenates results arrays",
    "lib.recipe-generator",
    function()
        local lh = {
            results = {{type = "item", name = "a", amount = 1}}
        }
        local rh = {
            results = {{type = "item", name = "b", amount = 2}}
        }
        Tirislib.RecipeGenerator.merge_prototypes(lh, rh)

        Assert.equals(#lh.results, 2)
    end
)

Tirislib.Testing.add_test_case(
    "merge_prototypes concatenates inline theme entries alongside real entries",
    "lib.recipe-generator",
    function()
        local lh = {
            ingredients = {{type = "item", name = "a", amount = 1}}
        }
        local rh = {
            ingredients = {{theme = "metal", amount = 2}}
        }
        Tirislib.RecipeGenerator.merge_prototypes(lh, rh)

        Assert.equals(#lh.ingredients, 2)
        Assert.equals(lh.ingredients[1].name, "a")
        Assert.equals(lh.ingredients[2].theme, "metal")
    end
)

Tirislib.Testing.add_test_case(
    "merge_prototypes sets scalar fields passively",
    "lib.recipe-generator",
    function()
        local lh = {energy_required = 5}
        local rh = {energy_required = 10, category = "smelting"}
        Tirislib.RecipeGenerator.merge_prototypes(lh, rh)

        Assert.equals(lh.energy_required, 5)
        Assert.equals(lh.category, "smelting")
    end
)

Tirislib.Testing.add_test_case(
    "merge_prototypes creates array field if not present in lh",
    "lib.recipe-generator",
    function()
        local lh = {}
        local rh = {ingredients = {{type = "item", name = "a", amount = 1}}}
        Tirislib.RecipeGenerator.merge_prototypes(lh, rh)

        Assert.not_nil(lh.ingredients)
        Assert.equals(#lh.ingredients, 1)
    end
)

Tirislib.Testing.add_test_case(
    "merge_prototypes handles nil arguments gracefully",
    "lib.recipe-generator",
    function()
        Tirislib.RecipeGenerator.merge_prototypes(nil, {energy_required = 5})
        Tirislib.RecipeGenerator.merge_prototypes({energy_required = 5}, nil)
        Tirislib.RecipeGenerator.merge_prototypes(nil, nil)
        Assert.pass()
    end
)

---------------------------------------------------------------------------------------------------
-- << auto-catalyst detection >>

Tirislib.Testing.add_test_case(
    "create auto-detects catalyst and sets ignored_by_productivity",
    "lib.recipe-generator",
    function()
        create_test_item("test-rg-cat-item")

        local recipe = Tirislib.RecipeGenerator.create {
            name = "test-rg-cat-recipe",
            results = {{type = "item", name = "test-rg-cat-item", amount = 3}},
            ingredients = {{type = "item", name = "test-rg-cat-item", amount = 5}}
        }

        local result = recipe:get_result("test-rg-cat-item", "item")
        Assert.equals(result.ignored_by_productivity, 3) -- min(5, 3)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "create no_auto_catalyst skips catalyst detection",
    "lib.recipe-generator",
    function()
        create_test_item("test-rg-nocat-item")

        local recipe = Tirislib.RecipeGenerator.create {
            name = "test-rg-nocat-recipe",
            no_auto_catalyst = true,
            results = {{type = "item", name = "test-rg-nocat-item", amount = 3}},
            ingredients = {{type = "item", name = "test-rg-nocat-item", amount = 5}}
        }

        local result = recipe:get_result("test-rg-nocat-item", "item")
        Assert.is_nil(result.ignored_by_productivity)
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << localised_name_wrapper >>

Tirislib.Testing.add_test_case(
    "create localised_name_wrapper wraps the product name",
    "lib.recipe-generator",
    function()
        create_test_item("test-rg-lnw-product")

        local recipe = Tirislib.RecipeGenerator.create {
            name = "test-rg-lnw-recipe",
            localised_name_wrapper = "my-wrapper-key",
            results = {{type = "item", name = "test-rg-lnw-product", amount = 1}}
        }

        Assert.equals(recipe.localised_name[1], "my-wrapper-key")
        Assert.is_false(recipe.show_amount_in_title)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "create localised_name_wrapper wraps an explicit localised_name",
    "lib.recipe-generator",
    function()
        create_test_item("test-rg-lnw2-product")

        local recipe = Tirislib.RecipeGenerator.create {
            name = "test-rg-lnw2-recipe",
            localised_name_wrapper = "my-wrapper-key",
            localised_name = {"item-name.iron-plate"},
            results = {{type = "item", name = "test-rg-lnw2-product", amount = 1}}
        }

        Assert.equals(recipe.localised_name[1], "my-wrapper-key")
        Assert.equals(recipe.localised_name[2][1], "item-name.iron-plate")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << fluid indexing >>

Tirislib.Testing.add_test_case(
    "create do_index_fluid_ingredients assigns fluidbox_index to fluid ingredients",
    "lib.recipe-generator",
    function()
        create_test_item("test-rg-fii-product")
        create_test_fluid("test-rg-fii-fluid")

        local recipe = Tirislib.RecipeGenerator.create {
            name = "test-rg-fii-recipe",
            do_index_fluid_ingredients = true,
            results = {{type = "item", name = "test-rg-fii-product", amount = 1}},
            ingredients = {{type = "fluid", name = "test-rg-fii-fluid", amount = 10}}
        }

        local ingredient = recipe:get_ingredient("test-rg-fii-fluid", "fluid")
        Assert.equals(ingredient.fluidbox_index, 1)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "create do_index_fluid_results assigns fluidbox_index to fluid results",
    "lib.recipe-generator",
    function()
        create_test_item("test-rg-fir-product")
        create_test_fluid("test-rg-fir-fluid")

        local recipe = Tirislib.RecipeGenerator.create {
            name = "test-rg-fir-recipe",
            do_index_fluid_results = true,
            results = {
                {type = "item", name = "test-rg-fir-product", amount = 1},
                {type = "fluid", name = "test-rg-fir-fluid", amount = 10}
            }
        }

        local result = recipe:get_result("test-rg-fir-fluid", "fluid")
        Assert.equals(result.fluidbox_index, 1)
    end,
    setup,
    teardown
)
