require("utils")

Tiristest = {}

Tiristest.tests = {}
local tests = Tiristest.tests

local function new_test_case(name, testfunction)
    return {name = name, fn = testfunction}
end

--- Adds a new test case to the collection.
--- @param name string
--- @param group string
--- @param fn function
function Tiristest.add_test_case(name, group, fn)
    local group_suite = Tirislib_Tables.get_inner_table(tests, group)
    group_suite[#group_suite+1] = new_test_case(name, fn)
end

local function run_test(test_case)
    local ok, error = pcall(test_case.fn)

    if ok then
        return true
    else
        log(string.format("Failed Test: %s\n%s\n", test_case.name, error))

        return false
    end
end

--- Runs all the test cases in the given group and prints the results.
--- @param group string
function Tiristest.run_group_suite(group)
    local group_suite = Tirislib_Tables.get_inner_table(tests, group)

    log(string.format("Running Test Group %s", group))
    local failed_tests = 0
    for _, test_case in pairs(group_suite) do
        local success = run_test(test_case)

        if not success then
            failed_tests = failed_tests + 1
        end
    end

    if failed_tests == 0 then
        log("OK!\n")
    else
        log(string.format("%d out of %d tests failed :(", failed_tests, #group_suite))
    end
end

--- Runs all test cases.
function Tiristest.run_all()
    for group in pairs(tests) do
        Tiristest.run_group_suite(group)
    end
end

Assert = {}

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

function Assert.equals(lh, rh)
    if not equals(lh, rh) then
        lh = get_string_representation(lh)
        rh = get_string_representation(rh)

        error(string.format("Assert failed: %s ~= %s", lh, rh))
    end
end
