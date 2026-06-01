require("tirislib.init")
Tirislib.Prototype.modname = "sosciencity"
Tirislib.Prototype.placeholder_icon = "__sosciencity-graphics__/graphics/icon/placeholder.png"
Tirislib.Prototype.default_icon_path = "__sosciencity-graphics__/graphics/icon/"

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

if mods["sosciencity-debug"] or mods["sosciencity-balancing"] then
    -- Enumerate utility sprite names for the debug sprite browser.
    -- Stored as a mod-data prototype so control stage can read it via prototypes.mod_data.
    local util_sprites = data.raw["utility-sprites"] and data.raw["utility-sprites"]["default"]
    if util_sprites then
        local names = {}
        for key, val in pairs(util_sprites) do
            if key ~= "type" and key ~= "name" and key ~= "owner" and type(val) == "table" then
                names[key] = true
            end
        end
        Tirislib.Prototype.create {
            type = "mod-data",
            name = "sosciencity-utility-sprite-names",
            data_type = "sosciencity.utility-sprite-names",
            data = names
        }
    end
end

if mods["sosciencity-debug"] then
    require("tests.load-tests")
    require("tests.datastage.load-tests")

    local summary, results = Tirislib.Testing.run_all()
    log(summary)

    if #results.failed_tests > 0 or #results.failed_asserts > 0 then
        error("Data stage tests failed:\n" .. summary)
    end
end

Tirislib.Prototype.finish()
