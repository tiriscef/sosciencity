require("lib.init")
Tirislib_Prototype.modname = "sosciencity"

require("datastage-scripts.science-pack-ingredients")
require("datastage-scripts.gunfire-techs")
require("datastage-scripts.handcrafting")
require("datastage-scripts.loot")
require("datastage-scripts.trees")
require("datastage-scripts.furniture-unlocks")

--<< handcrafting category >>
Tirislib_RecipeCategory("sosciencity-handcrafting"):make_hand_craftable()
Tirislib_RecipeCategory("sosciencity-architecture"):make_hand_craftable()
Tirislib_RecipeCategory("sosciencity-hunting"):make_hand_craftable()
Tirislib_RecipeCategory("sosciencity-slaughter"):pair_with("crafting")

Tirislib_Prototype.finish()
