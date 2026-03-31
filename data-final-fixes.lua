require("tirislib.init")
Tirislib.Prototype.modname = "sosciencity"
Tirislib.Prototype.placeholder_icon = "__sosciencity-graphics__/graphics/icon/placeholder.png"

-- Call scripts that make changes to prototypes that belong to other mods.

require("datastage-scripts.allowed-effects")
require("datastage-scripts.biters")
require("datastage-scripts.science-pack-ingredients")
require("datastage-scripts.gunfire-techs")
require("datastage-scripts.trees")
require("datastage-scripts.rocks")
require("datastage-scripts.fish")
require("datastage-scripts.lumber")
require("datastage-scripts.quality-modifiers")
require("datastage-scripts.missing-feature-flags")

require("integrations-updates")

if mods["sosciencity-debug"] then
    require("tests.load-tests")
    require("tests.datastage.load-tests")

    local summary, results = Tirislib.Testing.run_all(true)
    log(summary)

    if #results.failed_tests > 0 or #results.failed_asserts > 0 then
        error("Data stage tests failed:\n" .. summary)
    end
end

Tirislib.Prototype.finish()
