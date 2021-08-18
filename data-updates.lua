require("lib.init")
Tirislib_Prototype.modname = "sosciencity"

require("datastage-scripts.crafting-categories")
require("datastage-scripts.science-pack-ingredients")
require("datastage-scripts.gunfire-techs")
require("datastage-scripts.handcrafting")
require("datastage-scripts.loot")
require("datastage-scripts.trees")
require("datastage-scripts.furniture-unlocks")

if Sosciencity_Config.BALANCING then
    require("datastage-scripts.balancing")
end

Tirislib_Prototype.finish()
