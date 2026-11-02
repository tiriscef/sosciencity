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
