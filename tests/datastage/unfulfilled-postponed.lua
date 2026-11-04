local Assert = Tirislib.Testing.Assert

--- A postponed call that still can't run at the end of the data stage references a prototype that
--- never got created, e.g. a misspelled technology in a recipe's `unlock`. Tirislib would drop it silently.
Tirislib.Testing.add_test_case(
    "No postponed Tirislib calls stay unfulfilled",
    "content.postponed",
    function()
        Tirislib.Prototype.finish_postponed()
        local unfulfilled = Tirislib.Prototype.describe_postponed()

        Assert.is_table_empty(unfulfilled, "unfulfilled: " .. table.concat(unfulfilled, "; "))
    end
)

--- An add_unlock_with_item request that can't be resolved means no visible recipe produces the item (a mined or
--- scripted item, or a typo). The recipe stays locked for good.
Tirislib.Testing.add_test_case(
    "No unlock_with_item requests stay unresolved",
    "content.postponed",
    function()
        Tirislib.Recipe.resolve_item_unlocks()
        local unresolved = Tirislib.Recipe.describe_unresolved_item_unlocks()

        Assert.is_table_empty(unresolved, "unresolved: " .. table.concat(unresolved, "; "))
    end
)
