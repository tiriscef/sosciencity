require("utils")

Tiristest = {}

Tiristest.tests = {}
local tests = Tiristest.tests

---------------------------------------------------------------------------------------------------
-- << adding test cases >>
local function new_test_case(name, groups, testfunction)
    return {name = name, fn = testfunction, groups = Tirislib_String.split(groups, "|")}
end

--- Adds a new test case to the collection.
--- @param name string
--- @param groups string
--- @param fn function
function Tiristest.add_test_case(name, groups, fn)
    tests[#tests + 1] = new_test_case(name, groups, fn)
end

---------------------------------------------------------------------------------------------------
-- << logging >>
local function prepare_log()
    Tiristest.executed_tests = 0
    Tiristest.failed_tests = {}

    Tiristest.executed_asserts = 0
    Tiristest.failed_asserts = {}
end

local function log_test_execution()
    Tiristest.executed_tests = Tiristest.executed_tests + 1
end

local function log_failed_test(test_case, message)
    table.insert(
        Tiristest.failed_tests,
        {
            name = test_case.name,
            error_message = message
        }
    )
end

local function log_assert_execution()
    Tiristest.executed_asserts = Tiristest.executed_asserts + 1
end

local function log_failed_assert(message)
    local info = debug.getinfo(3, "Sl")

    table.insert(
        Tiristest.failed_asserts,
        {
            test_case = Tiristest.current_test,
            error_message = string.format("%s, line %d: %s", info.source, info.currentline, message)
        }
    )
end

local function get_logged_results()
    local failed_test_count = #Tiristest.failed_tests
    local failed_assert_count = #Tiristest.failed_asserts

    local head =
        string.format(
        "%d tests with %d asserts were run - of which %d tests and %d asserts failed.",
        Tiristest.executed_tests,
        Tiristest.executed_asserts,
        failed_test_count,
        failed_assert_count
    )

    local test_messages = {}
    for _, failed_test in pairs(Tiristest.failed_tests) do
        table.insert(test_messages, string.format("Test '%s' failed:\n%s", failed_test.name, failed_test.error_message))
    end

    local assert_messages = {}
    local grouped = Tirislib_Tables.group_by_key(Tiristest.failed_asserts, "test_case")
    for test_name, failed_asserts in pairs(grouped) do
        table.insert(assert_messages, string.format("In Test '%s':", test_name))
        for _, failed_assert in pairs(failed_asserts) do
            table.insert(assert_messages, failed_assert.error_message)
        end
    end

    return Tirislib_String.join(
        "\n\n",
        head,
        Tirislib_String.join("\n", test_messages),
        Tirislib_String.join("\n", assert_messages)
    )
end

---------------------------------------------------------------------------------------------------
-- << running the test cases >>
local function run_test(test_case, suppress_exceptions)
    Tiristest.current_test = test_case.name
    log_test_execution()

    if suppress_exceptions then
        local ok, error = xpcall(test_case.fn, debug.traceback)

        if not ok then
            log_failed_test(test_case, error)
        end
    else
        test_case.fn()
    end
end

--- Runs all the test cases in the given group.
--- @param group_name string
function Tiristest.run_group_suite(group_name, suppress_exceptions)
    prepare_log()

    for _, test_case in pairs(tests) do
        if Tirislib_Tables.contains(test_case.groups, group_name) then
            run_test(test_case, suppress_exceptions)
        end
    end

    return string.format("Group '%s'\n%s", group_name, get_logged_results())
end

--- Runs all test cases.
function Tiristest.run_all(suppress_exceptions)
    prepare_log()

    for _, test_case in pairs(tests) do
        run_test(test_case, suppress_exceptions)
    end

    return string.format("Running all tests\n%s", get_logged_results())
end

---------------------------------------------------------------------------------------------------
-- << asserts >>
Tiristest.Assert = {}
local Assert = Tiristest.Assert

local function equals(lh, rh)
    local type_lh = type(lh)
    local type_rh = type(rh)

    if type_lh ~= type_rh then
        return false
    end
    if type_lh == "table" then
        return Tirislib_Tables.equal(lh, rh)
    else
        return lh == rh
    end
end

local function get_string_representation(v)
    if type(v) == "table" then
        return serpent.line(v)
    else
        return tostring(v)
    end
end

function Assert.equals(lh, rh, message)
    log_assert_execution()

    if not equals(lh, rh) then
        lh = get_string_representation(lh)
        rh = get_string_representation(rh)

        log_failed_assert(string.format(message or "%s ~= %s", lh, rh))
    end
end

function Assert.not_nil(value, message)
    log_assert_execution()

    if value == nil then
        log_failed_assert(message or "value is nil")
    end
end
