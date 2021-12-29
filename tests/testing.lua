local Assert = Tirislib.Testing.Assert

Tirislib.Testing.add_test_case(
    "failing asserts get reported",
    "testing",
    function()
        Assert.equals(1, 2, "This 'equals' assert is supposed to fail.")
        Assert.not_nil(nil, "This 'not nil' assert is supposed to fail.")
    end
)

Tirislib.Testing.add_test_case(
    "failing tests get reported",
    "testing",
    function()
        error("This is supposed to fail.")
    end
)
