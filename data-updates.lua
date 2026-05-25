require("tirislib.init")
Tirislib.Prototype.modname = "sosciencity"
Tirislib.Prototype.placeholder_icon = "__sosciencity-graphics__/graphics/icon/placeholder.png"
Tirislib.Prototype.default_icon_path = "__sosciencity-graphics__/graphics/icon/"

-- Call scripts that make changes mostly to Sosciencity's prototypes.

require("datastage-scripts.crafting-categories")
require("datastage-scripts.garbage-to-landfill")
require("datastage-scripts.item-descriptions")
require("datastage-scripts.technology-descriptions")
require("datastage-scripts.handcrafting")
require("datastage-scripts.placement-range-highlights")
require("datastage-scripts.recycling-result-cleanup")

Tirislib.Prototype.finish()
