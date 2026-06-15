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

Tirislib.Testing.add_test_case(
    "Assert.is_table_empty passes for empty tables",
    "lib.testing",
    function()
        local results = Tirislib.Testing.run_isolated(function()
            Assert.is_table_empty({})
        end)

        Assert.equals(#results.failed_asserts, 0)
    end
)

Tirislib.Testing.add_test_case(
    "Assert.is_table_empty fails for non-empty tables",
    "lib.testing",
    function()
        local results = Tirislib.Testing.run_isolated(function()
            Assert.is_table_empty({1, 2, 3}, "table should be empty")
        end)

        Assert.equals(#results.failed_asserts, 1)
    end
)

Tirislib.Testing.add_test_case(
    "Assert.is_table_empty fails for non-tables",
    "lib.testing",
    function()
        local results = Tirislib.Testing.run_isolated(function()
            Assert.is_table_empty("hello")
        end)

        Assert.equals(#results.failed_asserts, 1)
    end
)

Tirislib.Testing.add_test_case(
    "Assert.does_not_throw passes when function succeeds",
    "lib.testing",
    function()
        local results = Tirislib.Testing.run_isolated(function()
            Assert.does_not_throw(function() return 42 end)
        end)

        Assert.equals(#results.failed_asserts, 0)
    end
)

Tirislib.Testing.add_test_case(
    "Assert.does_not_throw fails when function errors",
    "lib.testing",
    function()
        local results = Tirislib.Testing.run_isolated(function()
            Assert.does_not_throw(function() error("oops") end, "should not throw")
        end)

        Assert.equals(#results.failed_asserts, 1)
    end
)

Tirislib.Testing.add_test_case(
    "Assert.is_instance_of passes for matching type",
    "lib.testing",
    function()
        local results = Tirislib.Testing.run_isolated(function()
            Assert.is_instance_of({type = "furnace"}, "furnace")
        end)

        Assert.equals(#results.failed_asserts, 0)
    end
)

Tirislib.Testing.add_test_case(
    "Assert.is_instance_of fails for non-matching type",
    "lib.testing",
    function()
        local results = Tirislib.Testing.run_isolated(function()
            Assert.is_instance_of({type = "furnace"}, "mining_drill")
        end)

        Assert.equals(#results.failed_asserts, 1)
    end
)

Tirislib.Testing.add_test_case(
    "Assert.is_instance_of fails for non-tables",
    "lib.testing",
    function()
        local results = Tirislib.Testing.run_isolated(function()
            Assert.is_instance_of("not a table", "furnace")
        end)

        Assert.equals(#results.failed_asserts, 1)
    end
)

Tirislib.Testing.add_test_case(
    "Assert.is_number_close passes within epsilon",
    "lib.testing",
    function()
        local results = Tirislib.Testing.run_isolated(function()
            Assert.is_number_close(0.0001, 0.0, 0.01)
        end)

        Assert.equals(#results.failed_asserts, 0)
    end
)

Tirislib.Testing.add_test_case(
    "Assert.is_number_close fails outside epsilon",
    "lib.testing",
    function()
        local results = Tirislib.Testing.run_isolated(function()
            Assert.is_number_close(1.5, 0.0, 0.01)
        end)

        Assert.equals(#results.failed_asserts, 1)
    end
)