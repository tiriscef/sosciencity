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

Tirislib.Prototype.finish()
