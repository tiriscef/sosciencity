local Assert = Tirislib.Testing.Assert

---------------------------------------------------------------------------------------------------
-- << RecipeEntry.get_field >>

Tirislib.Testing.add_test_case(
    "RecipeEntry.get_field returns the explicit value when set",
    "lib.recipe-entry",
    function()
        local entry = {name = "iron-plate", type = "item", independent_probability = 0.5}
        Assert.equals(Tirislib.RecipeEntry.get_field(entry, "independent_probability"), 0.5)
    end
)

Tirislib.Testing.add_test_case(
    "RecipeEntry.get_field falls back to the field default when absent",
    "lib.recipe-entry",
    function()
        local entry = {name = "iron-plate", type = "item"}
        Assert.equals(Tirislib.RecipeEntry.get_field(entry, "independent_probability"), 1)
        Assert.equals(Tirislib.RecipeEntry.get_field(entry, "spoil_weight"), 1)
        Assert.is_true(Tirislib.RecipeEntry.get_field(entry, "affected_by_quality"))
    end
)

Tirislib.Testing.add_test_case(
    "RecipeEntry.get_field returns nil for a field without a default",
    "lib.recipe-entry",
    function()
        local entry = {name = "iron-plate", type = "item"}
        Assert.is_nil(Tirislib.RecipeEntry.get_field(entry, "quality_min"))
    end
)

---------------------------------------------------------------------------------------------------
-- << RecipeEntry.set_product_amount >>

Tirislib.Testing.add_test_case(
    "RecipeEntry.set_product_amount sets a fixed amount",
    "lib.recipe-entry",
    function()
        local entry = {name = "test", type = "item", amount = 5}
        Tirislib.RecipeEntry.set_product_amount(entry, 10)
        Assert.equals(entry.amount, 10)
        Assert.is_nil(entry.amount_min)
        Assert.is_nil(entry.amount_max)
    end
)

Tirislib.Testing.add_test_case(
    "RecipeEntry.set_product_amount sets a min/max range",
    "lib.recipe-entry",
    function()
        local entry = {name = "test", type = "item", amount = 5}
        Tirislib.RecipeEntry.set_product_amount(entry, 2, 8)
        Assert.is_nil(entry.amount)
        Assert.equals(entry.amount_min, 2)
        Assert.equals(entry.amount_max, 8)
    end
)

---------------------------------------------------------------------------------------------------
-- << RecipeEntry.add_amount >>

Tirislib.Testing.add_test_case(
    "RecipeEntry.add_amount adds to fixed amount",
    "lib.recipe-entry",
    function()
        local entry = {name = "test", type = "item", amount = 5}
        Tirislib.RecipeEntry.add_amount(entry, 3)
        Assert.equals(entry.amount, 8)
    end
)

Tirislib.Testing.add_test_case(
    "RecipeEntry.add_amount with range converts fixed to range",
    "lib.recipe-entry",
    function()
        local entry = {name = "test", type = "item", amount = 5}
        Tirislib.RecipeEntry.add_amount(entry, 2, 4)
        Assert.equals(entry.amount_min, 7)
        Assert.equals(entry.amount_max, 9)
    end
)

---------------------------------------------------------------------------------------------------
-- << RecipeEntry.get_average_yield >>

Tirislib.Testing.add_test_case(
    "RecipeEntry.get_average_yield with fixed amount",
    "lib.recipe-entry",
    function()
        local entry = {name = "test", type = "item", amount = 10}
        Assert.equals(Tirislib.RecipeEntry.get_average_yield(entry), 10)
    end
)

Tirislib.Testing.add_test_case(
    "RecipeEntry.get_average_yield with range",
    "lib.recipe-entry",
    function()
        local entry = {name = "test", type = "item", amount_min = 4, amount_max = 8}
        Assert.equals(Tirislib.RecipeEntry.get_average_yield(entry), 6)
    end
)

Tirislib.Testing.add_test_case(
    "RecipeEntry.get_average_yield with probability",
    "lib.recipe-entry",
    function()
        local entry = {name = "test", type = "item", amount = 10, independent_probability = 0.5}
        Assert.equals(Tirislib.RecipeEntry.get_average_yield(entry), 5)
    end
)

---------------------------------------------------------------------------------------------------
-- << RecipeEntry.can_be_merged >>

Tirislib.Testing.add_test_case(
    "RecipeEntry.can_be_merged identifies matching entries",
    "lib.recipe-entry",
    function()
        local a = {name = "iron-plate", type = "item", amount = 5}
        local b = {name = "iron-plate", type = "item", amount = 3}
        Assert.is_true(Tirislib.RecipeEntry.can_be_merged(a, b))
    end
)

Tirislib.Testing.add_test_case(
    "RecipeEntry.can_be_merged rejects different names",
    "lib.recipe-entry",
    function()
        local a = {name = "iron-plate", type = "item", amount = 5}
        local b = {name = "copper-plate", type = "item", amount = 3}
        Assert.is_false(Tirislib.RecipeEntry.can_be_merged(a, b))
    end
)

Tirislib.Testing.add_test_case(
    "RecipeEntry.can_be_merged rejects entries differing in quality or freshness fields",
    "lib.recipe-entry",
    function()
        local function merges_with(overrides)
            local base = {name = "iron-plate", type = "item", amount = 5}
            local other = {name = "iron-plate", type = "item", amount = 3}
            for key, value in pairs(overrides) do
                other[key] = value
            end
            return Tirislib.RecipeEntry.can_be_merged(base, other)
        end

        Assert.is_false(merges_with {quality_min = "uncommon"})
        Assert.is_false(merges_with {quality_change = 1})
        Assert.is_false(merges_with {affected_by_quality = false})
        Assert.is_false(merges_with {always_fresh = true})
        Assert.is_false(merges_with {reset_freshness_on_craft = true})
        Assert.is_false(merges_with {spoil_weight = 10})
        Assert.is_false(merges_with {percent_spoiled = 0.5})
        Assert.is_false(merges_with {shared_probability = {min = 0, max = 0.5}})
    end
)

Tirislib.Testing.add_test_case(
    "RecipeEntry.can_be_merged deep-compares shared_probability ranges",
    "lib.recipe-entry",
    function()
        local function merges(lh_range, rh_range)
            local lh = {name = "iron-plate", type = "item", amount = 5, shared_probability = lh_range}
            local rh = {name = "iron-plate", type = "item", amount = 3, shared_probability = rh_range}
            return Tirislib.RecipeEntry.can_be_merged(lh, rh)
        end

        -- value-equal ranges (distinct table instances) merge
        Assert.is_true(merges({min = 0, max = 0.8}, {min = 0, max = 0.8}))
        -- differing ranges (the exclusive-catalyst pattern) do not merge
        Assert.is_false(merges({min = 0, max = 0.8}, {min = 0.8, max = 1}))
    end
)

Tirislib.Testing.add_test_case(
    "RecipeEntry.can_be_merged treats explicit defaults as equal to absent fields",
    "lib.recipe-entry",
    function()
        local bare = {name = "iron-plate", type = "item", amount = 5}
        local explicit_defaults = {
            name = "iron-plate",
            type = "item",
            amount = 3,
            independent_probability = 1,
            percent_spoiled = 0,
            quality_change = 0,
            affected_by_quality = true,
            always_fresh = false,
            reset_freshness_on_craft = false,
            spoil_weight = 1
        }
        Assert.is_true(Tirislib.RecipeEntry.can_be_merged(bare, explicit_defaults))
    end
)

Tirislib.Testing.add_test_case(
    "RecipeEntry.can_be_merged treats a nil fluidbox_index as don't-care",
    "lib.recipe-entry",
    function()
        local indexed = {type = "fluid", name = "water", amount = 5, fluidbox_index = 1}
        local other_index = {type = "fluid", name = "water", amount = 3, fluidbox_index = 2}
        local same_index = {type = "fluid", name = "water", amount = 3, fluidbox_index = 1}
        local no_index = {type = "fluid", name = "water", amount = 3}

        -- one side doesn't care about the index -> mergeable
        Assert.is_true(Tirislib.RecipeEntry.can_be_merged(indexed, no_index))
        Assert.is_true(Tirislib.RecipeEntry.can_be_merged(no_index, indexed))
        -- both pin the same index -> mergeable
        Assert.is_true(Tirislib.RecipeEntry.can_be_merged(indexed, same_index))
        -- both pin different indices -> conflict
        Assert.is_false(Tirislib.RecipeEntry.can_be_merged(indexed, other_index))
    end
)

---------------------------------------------------------------------------------------------------
-- << RecipeEntry.merge >>

Tirislib.Testing.add_test_case(
    "RecipeEntry.merge adds amounts together",
    "lib.recipe-entry",
    function()
        local a = {name = "iron-plate", type = "item", amount = 5}
        local b = {name = "iron-plate", type = "item", amount = 3}
        Tirislib.RecipeEntry.merge(a, b)
        Assert.equals(a.amount, 8)
    end
)

---------------------------------------------------------------------------------------------------
-- << RecipeEntry.create_product_prototype >>

Tirislib.Testing.add_test_case(
    "RecipeEntry.create_product_prototype with integer amount",
    "lib.recipe-entry",
    function()
        local entry = Tirislib.RecipeEntry.create_product_prototype("iron-plate", 5)
        Assert.equals(entry.name, "iron-plate")
        Assert.equals(entry.type, "item")
        Assert.equals(entry.amount, 5)
    end
)

Tirislib.Testing.add_test_case(
    "RecipeEntry.create_product_prototype with fractional amount uses extra_count_fraction",
    "lib.recipe-entry",
    function()
        local entry = Tirislib.RecipeEntry.create_product_prototype("iron-plate", 3.5)
        Assert.equals(entry.amount, 3)
        Assert.equals(entry.extra_count_fraction, 0.5)
    end
)

Tirislib.Testing.add_test_case(
    "RecipeEntry.create_product_prototype with sub-1 amount uses probability",
    "lib.recipe-entry",
    function()
        local entry = Tirislib.RecipeEntry.create_product_prototype("iron-plate", 0.25)
        Assert.equals(entry.amount, 1)
        Assert.equals(entry.independent_probability, 0.25)
    end
)

Tirislib.Testing.add_test_case(
    "RecipeEntry.create_product_prototype returns nil for zero amount",
    "lib.recipe-entry",
    function()
        local entry = Tirislib.RecipeEntry.create_product_prototype("iron-plate", 0)
        Assert.is_nil(entry)
    end
)
