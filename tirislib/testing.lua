--- tiriscef's small testing framework.
Tirislib.Testing = {}

Tirislib.Testing.tests = {}
local tests = Tirislib.Testing.tests

---------------------------------------------------------------------------------------------------
-- << adding test cases >>

--- Creates a new test case table.
--- @param name string The display name of the test case
--- @param groups string Group names separated by "|"
--- @param testfunction function The test function to execute
--- @param setup function? Optional function to run before the test
--- @param teardown function? Optional function to run after the test (runs even on failure)
--- @return table test_case The constructed test case
local function new_test_case(name, groups, testfunction, setup, teardown)
    local group_set = {}

    for _, g in pairs(Tirislib.String.split(groups, "|")) do
        group_set[g] = true
    end
    
    return {name = name, fn = testfunction, groups = group_set, setup = setup, teardown = teardown}
end

--- Adds a new test case to the collection.
--- @param name string The display name of the test case
--- @param groups string Group names separated by "|"
--- @param fn function The test function to execute
--- @param setup function? Optional function to run before the test
--- @param teardown function? Optional function to run after the test (runs even on failure)
function Tirislib.Testing.add_test_case(name, groups, fn, setup, teardown)
    tests[#tests + 1] = new_test_case(name, groups, fn, setup, teardown)
end

---------------------------------------------------------------------------------------------------
-- << results context >>

--- Creates a fresh results context for a test run.
--- @return table results The results context table
local function new_results()
    return {
        executed_tests = 0,
        failed_tests = {},
        executed_asserts = 0,
        failed_asserts = {},
        current_test = nil
    }
end

-- Active results context, set during a test run
local active_results = nil

---------------------------------------------------------------------------------------------------
-- << logging >>

--- Increments the executed test counter.
--- @param results table The results context
local function log_test_execution(results)
    results.executed_tests = results.executed_tests + 1
end

--- Records a failed test case.
--- @param results table The results context
--- @param test_case table The test case that failed
--- @param message string The error message or traceback
local function log_failed_test(results, test_case, message)
    results.failed_tests[#results.failed_tests + 1] = {
        name = test_case.name,
        error_message = message
    }
end

--- Increments the executed assert counter.
--- @param results table The results context
local function log_assert_execution(results)
    results.executed_asserts = results.executed_asserts + 1
end

--- Walks the call stack to find the source location of the calling test code.
--- Skips frames inside testing.lua to report the actual test file and line.
--- @return debuginfo info The debug info of the caller frame
local function find_caller_info()
    -- Walk the stack to find the first frame outside testing.lua
    for level = 3, 10 do
        local info = debug.getinfo(level, "Sl")
        if not info then
            break
        end
        if not string.find(info.source, "testing%.lua$") then
            return info
        end
    end
    return debug.getinfo(3, "Sl")
end

--- Records a failed assert with source location information.
--- @param results table The results context
--- @param message string The failure description
local function log_failed_assert(results, message)
    local info = find_caller_info()

    results.failed_asserts[#results.failed_asserts + 1] = {
        test_case = results.current_test,
        error_message = string.format("%s, line %d: %s", info.source, info.currentline, message)
    }
end

--- Formats the accumulated results into a human-readable summary string.
--- @param results table The results context
--- @return string summary The formatted test results
local function get_logged_results(results)
    local failed_test_count = #results.failed_tests
    local failed_assert_count = #results.failed_asserts

    local head =
        string.format(
        "%d tests with %d asserts were run - of which %d tests and %d asserts failed.",
        results.executed_tests,
        results.executed_asserts,
        failed_test_count,
        failed_assert_count
    )

    local test_messages = {}
    for _, failed_test in pairs(results.failed_tests) do
        test_messages[#test_messages + 1] = string.format("Test '%s' failed:\n%s", failed_test.name, failed_test.error_message)
    end

    local assert_messages = {}
    local grouped = Tirislib.Tables.group_by_key(results.failed_asserts, "test_case")
    for test_name, failed_asserts in pairs(grouped) do
        assert_messages[#assert_messages + 1] = string.format("In Test '%s':", test_name)
        for _, failed_assert in pairs(failed_asserts) do
            assert_messages[#assert_messages + 1] = failed_assert.error_message
        end
    end

    return Tirislib.String.join(
        "\n\n",
        head,
        Tirislib.String.join("\n", test_messages),
        Tirislib.String.join("\n", assert_messages)
    )
end

---------------------------------------------------------------------------------------------------
-- << running the test cases >>

--- Runs a single test case, handling setup, teardown, and exception suppression.
--- @param test_case table The test case to run
--- @param results table The results context
--- @param suppress_exceptions boolean Whether to catch errors via xpcall
local function run_test(test_case, results, suppress_exceptions)
    results.current_test = test_case.name
    log_test_execution(results)

    if suppress_exceptions then
        -- Run setup if present
        if test_case.setup then
            local ok, err = xpcall(test_case.setup, debug.traceback)
            if not ok then
                log_failed_test(results, test_case, "Setup failed:\n" .. err)
                return
            end
        end

        local ok, err = xpcall(test_case.fn, debug.traceback)
        if not ok then
            log_failed_test(results, test_case, err)
        end

        -- Run teardown even on failure
        if test_case.teardown then
            local tok, terr = xpcall(test_case.teardown, debug.traceback)
            if not tok then
                log_failed_test(results, test_case, "Teardown failed:\n" .. terr)
            end
        end
    else
        if test_case.setup then
            test_case.setup()
        end
        test_case.fn()
        if test_case.teardown then
            test_case.teardown()
        end
    end
end

--- Runs all the test cases in the given group.
--- @param group_name string The group to run
--- @param suppress_exceptions boolean Whether to catch errors via xpcall
--- @return string summary The formatted test results
--- @return table results The structured results context
function Tirislib.Testing.run_group_suite(group_name, suppress_exceptions)
    local results = new_results()
    active_results = results

    for _, test_case in pairs(tests) do
        if test_case.groups[group_name] then
            run_test(test_case, results, suppress_exceptions)
        end
    end

    active_results = nil
    return string.format("Group '%s'\n%s", group_name, get_logged_results(results)), results
end

--- Runs all test cases.
--- @param suppress_exceptions boolean Whether to catch errors via xpcall
--- @return string summary The formatted test results
--- @return table results The structured results context
function Tirislib.Testing.run_all(suppress_exceptions)
    local results = new_results()
    active_results = results

    for _, test_case in pairs(tests) do
        run_test(test_case, results, suppress_exceptions)
    end

    active_results = nil
    return string.format("Running all tests\n%s", get_logged_results(results)), results
end

--- Runs a function in an isolated results context.
--- Useful for meta-testing: the function can call asserts and even fail,
--- without affecting the outer test run's results.
--- @param fn function The function to run
--- @return table results The isolated results context
function Tirislib.Testing.run_isolated(fn)
    local results = new_results()
    local old_active = active_results
    active_results = results
    results.current_test = "isolated"

    local ok, err = xpcall(fn, debug.traceback)
    if not ok then
        results.test_error = err
    end

    active_results = old_active
    return results
end

---------------------------------------------------------------------------------------------------
-- << asserts >>
Tirislib.Testing.Assert = {}
local Assert = Tirislib.Testing.Assert

--- Checks deep equality between two values, using table comparison for tables.
--- @param lh any The left-hand value
--- @param rh any The right-hand value
--- @return boolean equal Whether the values are deeply equal
local function equals(lh, rh)
    local type_lh = type(lh)
    local type_rh = type(rh)

    if type_lh ~= type_rh then
        return false
    end
    if type_lh == "table" then
        return Tirislib.Tables.equal(lh, rh)
    else
        return lh == rh
    end
end

--- Returns a human-readable string representation of a value.
--- Uses serpent for tables and tostring for everything else.
--- @param v any The value to represent
--- @return string representation
local function get_string_representation(v)
    if type(v) == "table" then
        return serpent.line(v)
    else
        return tostring(v)
    end
end

--- Formats a failure message with expected/actual values.
--- @param message string? Optional custom message to prepend
--- @param expected string The expected value representation
--- @param actual string The actual value representation
--- @return string formatted The formatted failure message
local function format_failure(message, expected, actual)
    if message then
        return string.format("%s\n  Expected: %s\n    Actual: %s", message, expected, actual)
    else
        return string.format("Expected: %s\n    Actual: %s", expected, actual)
    end
end

--- Returns the currently active results context.
--- @return table results The active results context
local function get_results()
    return active_results
end

--- Asserts that two values are deeply equal.
--- @param lh any The actual value
--- @param rh any The expected value
--- @param message string? Optional failure message
function Assert.equals(lh, rh, message)
    local results = get_results()
    log_assert_execution(results)

    if not equals(lh, rh) then
        log_failed_assert(results, format_failure(message, get_string_representation(rh), get_string_representation(lh)))
    end
end

--- Asserts that two values are not deeply equal.
--- @param lh any The first value
--- @param rh any The second value
--- @param message string? Optional failure message
function Assert.unequal(lh, rh, message)
    local results = get_results()
    log_assert_execution(results)

    if equals(lh, rh) then
        local repr = get_string_representation(lh)
        log_failed_assert(results, message or string.format("Expected values to differ, but both are: %s", repr))
    end
end

--- Asserts that a value is strictly true (not just truthy).
--- @param value any The value to check
--- @param message string? Optional failure message
function Assert.is_true(value, message)
    local results = get_results()
    log_assert_execution(results)

    if value ~= true then
        log_failed_assert(results, format_failure(message, "true", get_string_representation(value)))
    end
end

--- Asserts that a value is strictly false (not just falsy).
--- @param value any The value to check
--- @param message string? Optional failure message
function Assert.is_false(value, message)
    local results = get_results()
    log_assert_execution(results)

    if value ~= false then
        log_failed_assert(results, format_failure(message, "false", get_string_representation(value)))
    end
end

--- Asserts that a value is nil.
--- @param value any The value to check
--- @param message string? Optional failure message
function Assert.is_nil(value, message)
    local results = get_results()
    log_assert_execution(results)

    if value ~= nil then
        log_failed_assert(results, format_failure(message, "nil", get_string_representation(value)))
    end
end

--- Asserts that a value is not nil.
--- @param value any The value to check
--- @param message string? Optional failure message
function Assert.not_nil(value, message)
    local results = get_results()
    log_assert_execution(results)

    if value == nil then
        log_failed_assert(results, message or "Expected non-nil value, got nil")
    end
end

--- Asserts that a value is an integer number.
--- @param value any The value to check
--- @param message string? Optional failure message
function Assert.is_integer(value, message)
    local results = get_results()
    log_assert_execution(results)

    if type(value) ~= "number" or math.floor(value) ~= value then
        log_failed_assert(results, format_failure(message, "an integer", get_string_representation(value)))
    end
end

--- Asserts that a value is a positive number (strictly greater than zero).
--- @param value any The value to check
--- @param message string? Optional failure message
function Assert.is_positive(value, message)
    local results = get_results()
    log_assert_execution(results)

    if type(value) ~= "number" or value <= 0 then
        log_failed_assert(results, format_failure(message, "a positive number", get_string_representation(value)))
    end
end

--- Asserts that a value is a negative number (strictly less than zero).
--- @param value any The value to check
--- @param message string? Optional failure message
function Assert.is_negative(value, message)
    local results = get_results()
    log_assert_execution(results)

    if type(value) ~= "number" or value >= 0 then
        log_failed_assert(results, format_failure(message, "a negative number", get_string_representation(value)))
    end
end

--- Asserts that a value is strictly greater than a threshold.
--- @param value number The actual value
--- @param threshold number The threshold to compare against
--- @param message string? Optional failure message
function Assert.greater_than(value, threshold, message)
    local results = get_results()
    log_assert_execution(results)

    if value <= threshold then
        log_failed_assert(results, format_failure(message, "> " .. get_string_representation(threshold), get_string_representation(value)))
    end
end

--- Asserts that a value is strictly less than a threshold.
--- @param value number The actual value
--- @param threshold number The threshold to compare against
--- @param message string? Optional failure message
function Assert.less_than(value, threshold, message)
    local results = get_results()
    log_assert_execution(results)

    if value >= threshold then
        log_failed_assert(results, format_failure(message, "< " .. get_string_representation(threshold), get_string_representation(value)))
    end
end

--- Asserts that a function throws an error when called.
--- @param fn function The function that should error
--- @param message string? Optional failure message
function Assert.throws(fn, message)
    local results = get_results()
    log_assert_execution(results)

    local ok, _ = pcall(fn)
    if ok then
        log_failed_assert(results, message or "Expected function to throw an error, but it returned successfully")
    end
end

--- Asserts that a table contains a given value.
--- @param tbl table The table to search
--- @param value any The value to look for
--- @param message string? Optional failure message
function Assert.contains(tbl, value, message)
    local results = get_results()
    log_assert_execution(results)

    if not Tirislib.Tables.contains(tbl, value) then
        log_failed_assert(results, message or string.format("Expected table to contain %s", get_string_representation(value)))
    end
end
