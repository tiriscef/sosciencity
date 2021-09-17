-- initialisation
require("lib.init")
Tirislib_Prototype.modname = "sosciencity"

require("recipe-generator")
require("integrations")
require("datastage-configuration")

-- create prototypes
require("prototypes.item-groups")
require("prototypes.recipe-categories")
require("prototypes.technologies")

require("prototypes.inhabitant-prototypes")
require("prototypes.animal-food")
require("prototypes.beverages")
require("prototypes.garbage")
require("prototypes.growth-media")
require("prototypes.materials")
require("prototypes.medicine")
require("prototypes.microorganisms")
require("prototypes.drinking-water")
require("prototypes.ideas")
require("prototypes.fauna")
require("prototypes.food")
require("prototypes.flora")

require("prototypes.hunting-gathering")

require("prototypes.housing")
require("prototypes.buildings")
require("prototypes.unlocking-technologies")

require("prototypes.hidden.beacon")
require("prototypes.hidden.caste-technologies")
require("prototypes.hidden.electric-energy-interface")
require("prototypes.hidden.sprites")

Tirislib_Prototype:finish()
