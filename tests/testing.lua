local Assert = Tirislib.Testing.Assert

Tirislib.Testing.add_test_case(
    "failing asserts get reported",
    "lib.testing",
    function()
        local results = Tirislib.Testing.run_isolated(function()
            Assert.equals(1, 2, "This 'equals' assert is supposed to fail.")
            Assert.not_nil(nil, "This 'not nil' assert is supposed to fail.")
        end)

        Assert.equals(results.executed_asserts, 2)
        Assert.equals(#results.failed_asserts, 2)
    end
)

Tirislib.Testing.add_test_case(
    "passing asserts are not reported as failures",
    "lib.testing",
    function()
        local results = Tirislib.Testing.run_isolated(function()
            Assert.equals(1, 1)
            Assert.not_nil("hello")
            Assert.is_true(true)
        end)

        Assert.equals(results.executed_asserts, 3)
        Assert.equals(#results.failed_asserts, 0)
    end
)

Tirislib.Testing.add_test_case(
    "test errors are captured in isolated runs",
    "lib.testing",
    function()
        local results = Tirislib.Testing.run_isolated(function()
            error("This is supposed to fail.")
        end)

        Assert.not_nil(results.test_error)
    end
)