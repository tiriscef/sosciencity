if not mods["sosciencity-debug"] then
    return
end

require("tests.tirislib.load-tests")
require("tests.tirislib.datastage.load-tests")
require("tests.content.load-tests")

local summary, results = Tirislib.Testing.run_all()
log(summary)

if #results.failed_tests > 0 or #results.failed_asserts > 0 then
    error("Data stage tests failed:\n" .. summary)
end
