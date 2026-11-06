if not mods["sosciencity-debug"] then
    return
end

require("tests.tirislib.load-tests")
require("tests.tirislib.datastage.load-tests")
require("tests.content.load-tests")

-- Failures only get logged, the mod keeps loading so that the control stage tests still run.
-- The headless runner (test-setup/tests-entrypoint.sh) fails the run on any "FAILED:" line in the log.
local summary = Tirislib.Testing.run_all()
log("Data stage tests:\n" .. summary)
