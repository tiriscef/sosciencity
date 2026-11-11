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
---------------------------------------------------------------------------------------------------
-- << parameterized test cases >>

local create_parameterized = Tirislib.Testing.create_parameterized_test_cases

Tirislib.Testing.add_test_case(
    "create_parameterized_test_cases creates one test case per case",
    "lib.testing",
    function()
        local test_cases = create_parameterized("double(%s) == %s", "a|b", {{1, 2}, {2, 4}, {3, 6}}, function()
        end)

        Assert.equals(#test_cases, 3)
        for _, test_case in pairs(test_cases) do
            Assert.equals(test_case.groups, {a = true, b = true})
        end
    end
)

Tirislib.Testing.add_test_case(
    "create_parameterized_test_cases calls the test function with the values of its case",
    "lib.testing",
    function()
        local received = {}
        local test_cases =
            create_parameterized("%s %s", "x", {{1, "a"}, {2, "b"}}, function(number, letter)
                received[#received + 1] = {number, letter}
            end)

        for _, test_case in pairs(test_cases) do
            test_case.fn()
        end

        Assert.equals(received, {{1, "a"}, {2, "b"}})
    end
)

Tirislib.Testing.add_parameterized_test_case(
    "create_parameterized_test_cases formats the name %s with the values %s",
    "lib.testing",
    {
        {"round(%s) == %s", {2.5, 3}, "round(2.5) == 3 #1"},
        {"is %s", {"text"}, "is text #1"},
        {"sum(%s)", {{1, 2}}, "sum({1, 2}) #1"},
        {"pattern ignored", {1, name = "custom name"}, "custom name #1"}
    },
    function(name_pattern, case, expected)
        local test_cases = create_parameterized(name_pattern, "x", {case}, function()
        end)

        Assert.equals(test_cases[1].name, expected)
    end
)

Tirislib.Testing.add_test_case(
    "create_parameterized_test_cases appends the position of the case to its name",
    "lib.testing",
    function()
        local test_cases = create_parameterized("same name", "x", {{1}, {2}}, function()
        end)

        Assert.equals(test_cases[1].name, "same name #1")
        Assert.equals(test_cases[2].name, "same name #2")
    end
)

Tirislib.Testing.add_test_case(
    "create_parameterized_test_cases passes nil values inside a case",
    "lib.testing",
    function()
        local received_count, received_second
        local test_cases =
            create_parameterized("%s %s %s", "x", {{nil, nil, 3}}, function(...)
                received_count = select("#", ...)
                received_second = select(2, ...)
            end)

        Assert.equals(test_cases[1].name, "nil nil 3 #1")
        test_cases[1].fn()
        Assert.equals(received_count, 3)
        Assert.is_nil(received_second)
    end
)

Tirislib.Testing.add_test_case(
    "create_parameterized_test_cases calls setup and teardown with the values of the case",
    "lib.testing",
    function()
        local calls = {}
        local test_cases =
            create_parameterized(
            "%s",
            "x",
            {{"a"}, {"b"}},
            function(value)
                calls[#calls + 1] = "fn " .. value
            end,
            function(value)
                calls[#calls + 1] = "setup " .. value
            end,
            function(value)
                calls[#calls + 1] = "teardown " .. value
            end
        )

        for _, test_case in pairs(test_cases) do
            test_case.setup()
            test_case.fn()
            test_case.teardown()
        end

        Assert.equals(calls, {"setup a", "fn a", "teardown a", "setup b", "fn b", "teardown b"})
    end
)

Tirislib.Testing.add_test_case(
    "create_parameterized_test_cases leaves out missing setup and teardown",
    "lib.testing",
    function()
        local test_cases = create_parameterized("%s", "x", {{1}}, function()
        end)

        Assert.is_nil(test_cases[1].setup)
        Assert.is_nil(test_cases[1].teardown)
    end
)

Tirislib.Testing.add_parameterized_test_case(
    "create_parameterized_test_cases rejects %s",
    "lib.testing",
    {
        {"a pattern with more placeholders than values", "%s and %s", {{1}}},
        {"a case that isn't a table", "%s", {1}}
    },
    function(_, name_pattern, cases)
        Assert.throws(
            function()
                create_parameterized(name_pattern, "x", cases, function()
                end)
            end
        )
    end
)
