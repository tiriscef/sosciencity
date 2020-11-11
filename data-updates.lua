require("lib.init")

Sosciencity_ItemOperations = {}
Sosciencity_RecipeOperations = {}

require("datastage-scripts.science-pack-ingredients")
require("datastage-scripts.gunfire-techs")
require("datastage-scripts.handcrafting")
require("datastage-scripts.loot")
require("datastage-scripts.trees")

--<< handcrafting category >>
Tirislib_RecipeCategory("handcrafting"):make_hand_craftable()
Tirislib_RecipeCategory("sosciencity-architecture"):make_hand_craftable()
Tirislib_RecipeCategory("sosciencity-hunting"):make_hand_craftable()
Tirislib_RecipeCategory("sosciencity-slaughter"):pair_with("crafting")

Tirislib_Prototype.finish()
