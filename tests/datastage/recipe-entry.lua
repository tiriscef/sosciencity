local Assert = Tirislib.Testing.Assert

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
-- << RecipeEntry.add_product_amount >>

Tirislib.Testing.add_test_case(
    "RecipeEntry.add_product_amount adds to fixed amount",
    "lib.recipe-entry",
    function()
        local entry = {name = "test", type = "item", amount = 5}
        Tirislib.RecipeEntry.add_product_amount(entry, 3)
        Assert.equals(entry.amount, 8)
    end
)

Tirislib.Testing.add_test_case(
    "RecipeEntry.add_product_amount with range converts fixed to range",
    "lib.recipe-entry",
    function()
        local entry = {name = "test", type = "item", amount = 5}
        Tirislib.RecipeEntry.add_product_amount(entry, 2, 4)
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
        local entry = {name = "test", type = "item", amount = 10, probability = 0.5}
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
        Assert.equals(entry.probability, 0.25)
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
