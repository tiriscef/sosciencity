require("tirislib.init")
Tirislib.Prototype.modname = "sosciencity"

-- Call scripts that make changes to prototypes that belong to other mods.

require("datastage-scripts.allowed-effects")
require("datastage-scripts.biters")
require("datastage-scripts.science-pack-ingredients")
require("datastage-scripts.gunfire-techs")
require("datastage-scripts.trees")
require("datastage-scripts.rocks")
require("datastage-scripts.fish")
require("datastage-scripts.lumber")

require("integrations-updates")

Tirislib.Prototype.finish()
