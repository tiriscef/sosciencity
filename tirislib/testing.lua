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
        current_test = nil,
        current_test_case = nil,
        current_test_asserts = 0,
        zero_assert_tests = {},
        per_group = {}
    }
end

-- Active results context, set during a test run
local active_results = nil

-- Multi tick runner state
local pending_continuation = nil
local pending_poll = nil
local multi_tick_runner_active = false

---------------------------------------------------------------------------------------------------
-- << logging >>

--- Increments the executed test counter and initialises per-test tracking.
--- @param results table The results context
--- @param test_case table The test case being started
local function log_test_execution(results, test_case)
    results.executed_tests = results.executed_tests + 1
    results.current_test_case = test_case
    results.current_test_asserts = 0
end

--- Records a failed test case.
--- @param results table The results context
--- @param test_case table The test case that failed
--- @param message string The error message or traceback
local function log_failed_test(results, test_case, message)
    results.failed_tests[#results.failed_tests + 1] = {
        name = test_case.name,
        groups = test_case.groups,
        error_message = message
    }
end

--- Increments the executed assert counter.
--- @param results table The results context
local function log_assert_execution(results)
    results.executed_asserts = results.executed_asserts + 1
    results.current_test_asserts = results.current_test_asserts + 1
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
        groups = results.current_test_case and results.current_test_case.groups or {},
        error_message = string.format("%s, line %d:\n%s", info.source, info.currentline, message)
    }
end

--- Records a failed assert with a pre-captured source location.
--- Use when the call site cannot be recovered from the stack at failure time (e.g. async continuations).
--- @param results table The results context
--- @param message string The failure description
--- @param source string The source file captured at registration time
--- @param line integer The line number captured at registration time
local function log_failed_assert_at(results, message, source, line)
    results.failed_asserts[#results.failed_asserts + 1] = {
        test_case = results.current_test,
        groups = results.current_test_case and results.current_test_case.groups or {},
        error_message = string.format("%s, line %d:\n%s", source, line, message)
    }
end

--- Records per-group counts and zero-assert warning for a completed test.
--- Must be called once per test after setup/fn/teardown have all run.
--- @param results table The results context
--- @param test_case table The completed test case
local function finish_test_tracking(results, test_case)
    if results.current_test_asserts == 0 then
        results.zero_assert_tests[#results.zero_assert_tests + 1] = test_case.name
    end
    for group in pairs(test_case.groups) do
        if not results.per_group[group] then
            results.per_group[group] = {tests = 0, asserts = 0}
        end
        results.per_group[group].tests = results.per_group[group].tests + 1
        results.per_group[group].asserts = results.per_group[group].asserts + results.current_test_asserts
    end
    results.current_test_asserts = 0
end

local separator_line = "-------------------------------------------"

--- Formats the accumulated results into a human-readable summary string.
--- @param results table The results context
--- @return string summary The formatted test results
local function get_logged_results(results)
    local crashed_test_count = #results.failed_tests
    local failed_assert_count = #results.failed_asserts
    local zero_assert_count = #results.zero_assert_tests
    local all_passed = crashed_test_count == 0 and failed_assert_count == 0

    local parts = {}
    local function add(s)
        parts[#parts + 1] = s
    end

    local function groups_string(groups)
        local names = {}
        for g in pairs(groups) do
            names[#names + 1] = g
        end
        table.sort(names)
        return table.concat(names, "|")
    end

    -- per-group summary + grand total
    add(separator_line)
    local group_names = {}
    for g in pairs(results.per_group) do
        group_names[#group_names + 1] = g
    end
    table.sort(group_names)
    if #group_names > 0 then
        for _, g in pairs(group_names) do
            local gd = results.per_group[g]
            add(string.format("  %s: %d tests, %d asserts", g, gd.tests, gd.asserts))
        end
        add("")
    end

    if results.executed_tests == 0 then
        add("WARNING: 0 tests were executed")
    elseif all_passed then
        add(string.format("ALL PASSED: %d tests, %d asserts", results.executed_tests, results.executed_asserts))
    else
        -- a test fails if it crashed OR had at least one failed assert
        local failed_test_names = {}
        for _, ft in pairs(results.failed_tests) do
            failed_test_names[ft.name] = true
        end
        for _, fa in pairs(results.failed_asserts) do
            failed_test_names[fa.test_case] = true
        end
        local total_failed_tests = 0
        for _ in pairs(failed_test_names) do
            total_failed_tests = total_failed_tests + 1
        end

        local passed_tests = results.executed_tests - total_failed_tests
        local passed_asserts = results.executed_asserts - failed_assert_count
        add(string.format(
            "FAILED: %d/%d tests passed, %d/%d asserts passed",
            passed_tests, results.executed_tests,
            passed_asserts, results.executed_asserts
        ))
    end
    add(separator_line)

    -- zero-assert warnings
    if zero_assert_count > 0 then
        add("")
        add("Tests with 0 asserts (use Assert.pass() if intentional):")
        for _, name in pairs(results.zero_assert_tests) do
            add(string.format("  [WARN] %s", name))
        end
    end

    -- crashed tests
    if crashed_test_count > 0 then
        add("")
        add("Crashed tests:")
        for _, failed_test in pairs(results.failed_tests) do
            local gs = groups_string(failed_test.groups or {})
            local label = gs ~= "" and string.format("  [CRASH] %s [%s]", failed_test.name, gs)
                or string.format("  [CRASH] %s", failed_test.name)
            add(label)
            for line in failed_test.error_message:gmatch("[^\n]+") do
                add("    " .. line)
            end
        end
    end

    -- failed asserts
    if failed_assert_count > 0 then
        local grouped = Tirislib.Tables.group_by_key(results.failed_asserts, "test_case")
        add("")
        add("Failed asserts:")
        for test_name, test_failed_asserts in pairs(grouped) do
            local gs = groups_string(test_failed_asserts[1].groups or {})
            local label = gs ~= "" and string.format("  [FAIL] %s [%s]", test_name, gs)
                or string.format("  [FAIL] %s", test_name)
            add(label)
            for _, failed_assert in pairs(test_failed_asserts) do
                for line in failed_assert.error_message:gmatch("[^\n]+") do
                    add("    " .. line)
                end
            end
        end
    end

    add(separator_line)
    return table.concat(parts, "\n")
end

---------------------------------------------------------------------------------------------------
-- << running the test cases >>

--- Runs a single test case, handling setup, teardown, and error capture.
--- @param test_case table The test case to run
--- @param results table The results context
local function run_test(test_case, results)
    results.current_test = test_case.name
    log_test_execution(results, test_case)

    if test_case.setup then
        local ok, err = xpcall(test_case.setup, debug.traceback)
        if not ok then
            log_failed_test(results, test_case, "Setup failed:\n" .. err)
            finish_test_tracking(results, test_case)
            return
        end
    end

    local ok, err = xpcall(test_case.fn, debug.traceback)
    if not ok then
        log_failed_test(results, test_case, err)
    end

    if test_case.teardown then
        local tok, terr = xpcall(test_case.teardown, debug.traceback)
        if not tok then
            log_failed_test(results, test_case, "Teardown failed:\n" .. terr)
        end
    end

    finish_test_tracking(results, test_case)
end

--- Runs all the test cases in the given group.
--- @param group_name string The group to run
--- @return string summary The formatted test results
--- @return table results The structured results context
function Tirislib.Testing.run_group_suite(group_name)
    local results = new_results()
    active_results = results

    for _, test_case in pairs(tests) do
        if test_case.groups[group_name] then
            run_test(test_case, results)
        end
    end

    active_results = nil
    return string.format("Group '%s'\n%s", group_name, get_logged_results(results)), results
end

--- Runs all test cases.
--- @return string summary The formatted test results
--- @return table results The structured results context
function Tirislib.Testing.run_all()
    local results = new_results()
    active_results = results

    for _, test_case in pairs(tests) do
        run_test(test_case, results)
    end

    active_results = nil
    return string.format("Running all tests\n%s", get_logged_results(results)), results
end

--- Runs all test cases except those belonging to the given group.
--- @param excluded_group string The group name to exclude
--- @return string summary The formatted test results
--- @return table results The structured results context
function Tirislib.Testing.run_all_except_group(excluded_group)
    local results = new_results()
    active_results = results

    for _, test_case in pairs(tests) do
        if not test_case.groups[excluded_group] then
            run_test(test_case, results)
        end
    end

    active_results = nil
    return string.format("Running all tests (excluding '%s')\n%s", excluded_group, get_logged_results(results)), results
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
        log_failed_assert(results,
            format_failure(message, "> " .. get_string_representation(threshold), get_string_representation(value)))
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
        log_failed_assert(results,
            format_failure(message, "< " .. get_string_representation(threshold), get_string_representation(value)))
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
        log_failed_assert(results,
            message or string.format("Expected table to contain %s", get_string_representation(value)))
    end
end

--- Marks a test as intentionally having no domain assertions.
--- Suppresses the zero-assert warning for tests that only verify the absence of crashes.
function Assert.pass()
    log_assert_execution(get_results())
end

---------------------------------------------------------------------------------------------------
-- << multi-tick runner >>

--- Returns whether a multi-tick test run is currently in progress.
--- @return boolean
function Tirislib.Testing.is_multi_tick_run_active()
    return multi_tick_runner_active
end

--- Registers a continuation to run after n game ticks have passed.
--- Can only be called from within a test that is running under start_multi_tick_run.
--- Nest the next call inside the continuation fn to chain multiple waits.
--- @param n integer Number of ticks to let pass before calling fn (must be >= 1)
--- @param fn function The continuation to run
function Tirislib.Testing.let_n_ticks_pass(n, fn)
    assert(n >= 1, "let_n_ticks_pass requires n >= 1")
    if not multi_tick_runner_active then
        error("let_n_ticks_pass requires the multi-tick runner", 2)
    end
    if pending_continuation or pending_poll then
        error("let_n_ticks_pass called alongside another wait in the same test phase - nest the next call inside a continuation", 2)
    end
    pending_continuation = {n = n, fn = fn}
end

--- Registers a continuation to run after exactly one game tick has passed.
--- Shorthand for let_n_ticks_pass(1, fn).
--- @param fn function The continuation to run
function Tirislib.Testing.let_one_tick_pass(fn)
    Tirislib.Testing.let_n_ticks_pass(1, fn)
end

--- Polls condition_fn each tick until it returns true, then calls fn.
--- If timeout_ticks ticks pass without the condition becoming true, the test fails.
--- Can only be called from within a test that is running under start_multi_tick_run.
--- @param condition_fn function Polled each tick; run is considered done when this returns true
--- @param timeout_ticks integer Maximum number of ticks to wait before failing
--- @param fn function The continuation to run when condition_fn returns true
function Tirislib.Testing.wait_until(condition_fn, timeout_ticks, fn)
    if not multi_tick_runner_active then
        error("wait_until requires the multi-tick runner", 2)
    end
    if pending_continuation or pending_poll then
        error("wait_until called alongside another wait in the same test phase", 2)
    end
    local info = debug.getinfo(2, "Sl")
    pending_poll = {
        condition = condition_fn,
        remaining = timeout_ticks,
        timeout = timeout_ticks,
        fn = fn,
        source = info.source,
        line = info.currentline
    }
end

--- Starts a multi-tick test run and returns a cursor.
--- Drive the run by calling cursor.tick() once per game tick until it returns true,
--- then retrieve results with cursor.get_results().
--- @param test_filter function? Predicate (test_case -> bool) to select tests. nil runs all tests.
--- @return table cursor
function Tirislib.Testing.start_multi_tick_run(test_filter)
    assert(not multi_tick_runner_active, "A multi-tick test run is already in progress")

    local results = new_results()
    active_results = results
    multi_tick_runner_active = true

    local test_index = 0
    local current_test_case = nil
    local current_fn = nil
    local wait_ticks = 0
    local current_poll = nil

    local function protected_call(fn)
        pending_continuation = nil
        pending_poll = nil
        local ok, err = xpcall(fn, debug.traceback)
        local cont = pending_continuation
        local poll = pending_poll
        pending_continuation = nil
        pending_poll = nil
        return ok, err, cont, poll
    end

    local function finish_test()
        if current_test_case and current_test_case.teardown then
            local ok, err = xpcall(current_test_case.teardown, debug.traceback)
            if not ok then
                log_failed_test(results, current_test_case, "Teardown failed:\n" .. err)
            end
        end
        if current_test_case then
            finish_test_tracking(results, current_test_case)
        end
        current_test_case = nil
        current_fn = nil
        wait_ticks = 0
        current_poll = nil
    end

    local function get_next_test()
        while true do
            test_index = test_index + 1
            local tc = tests[test_index]
            if tc == nil then
                return nil
            end
            if test_filter == nil or test_filter(tc) then
                return tc
            end
        end
    end

    local cursor = {}

    --- Advances the test run by one tick. Returns true when all tests have completed.
    --- @return boolean done
    function cursor.tick()
        if current_poll then
            local ok, result = xpcall(current_poll.condition, debug.traceback)
            if not ok then
                log_failed_test(results, current_test_case, "wait_until condition errored:\n" .. result)
                current_poll = nil
                finish_test()
            elseif result then
                current_fn = current_poll.fn
                current_poll = nil
            elseif current_poll.remaining > 0 then
                current_poll.remaining = current_poll.remaining - 1
                return false
            else
                log_assert_execution(results)
                log_failed_assert_at(
                    results,
                    string.format("wait_until: condition not satisfied after %d ticks", current_poll.timeout),
                    current_poll.source,
                    current_poll.line
                )
                current_poll = nil
                finish_test()
            end
        end

        if wait_ticks > 0 then
            wait_ticks = wait_ticks - 1
            return false
        end

        while true do
            if current_fn then
                local ok, err, cont, poll = protected_call(current_fn)
                current_fn = nil

                if not ok then
                    log_failed_test(results, current_test_case, err)
                    finish_test()
                elseif cont then
                    wait_ticks = cont.n - 1
                    current_fn = cont.fn
                    return false
                elseif poll then
                    current_poll = poll
                    return false
                else
                    finish_test()
                end
            else
                current_test_case = get_next_test()
                if current_test_case == nil then
                    multi_tick_runner_active = false
                    active_results = nil
                    return true
                end

                results.current_test = current_test_case.name
                log_test_execution(results, current_test_case)

                if current_test_case.setup then
                    local ok, err = xpcall(current_test_case.setup, debug.traceback)
                    if not ok then
                        log_failed_test(results, current_test_case, "Setup failed:\n" .. err)
                        finish_test_tracking(results, current_test_case)
                        current_test_case = nil
                        -- teardown intentionally skipped (mirrors sync runner)
                    else
                        current_fn = current_test_case.fn
                    end
                else
                    current_fn = current_test_case.fn
                end
            end
        end
    end

    --- Returns the formatted results string and the raw results table.
    --- @return string summary
    --- @return table results
    function cursor.get_results()
        return get_logged_results(results), results
    end

    return cursor
end
