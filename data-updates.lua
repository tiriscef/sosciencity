require("tirislib.init")
Tirislib.Prototype.modname = "sosciencity"

-- Call scripts that make changes mostly to Sosciencity's prototypes.

require("datastage-scripts.crafting-categories")
require("datastage-scripts.garbage-to-landfill")
require("datastage-scripts.item-descriptions")
require("datastage-scripts.technology-descriptions")
require("datastage-scripts.handcrafting")
require("datastage-scripts.furniture-unlocks")
require("datastage-scripts.placement-range-highlights")

require("integrations-updates")

Tirislib.Prototype.finish()
