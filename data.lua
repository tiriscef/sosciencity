-- initialisation
require("tirislib.init")
Tirislib.Prototype.modname = "sosciencity"
Tirislib.Prototype.placeholder_icon = "__sosciencity-graphics__/graphics/icon/placeholder.png"

require("datastage-configuration")
require("recipe-generator-config")
require("integrations")

-- create prototypes
require("prototypes.item-groups")
require("prototypes.recipe-categories")
require("prototypes.technologies")

require("prototypes.inhabitant-prototypes")
require("prototypes.animal-food")
--require("prototypes.beverages")
require("prototypes.circuitry")
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
require("prototypes.education")

require("prototypes.hunting-gathering")

require("prototypes.housing")
require("prototypes.buildings")
require("prototypes.unlocking-technologies")

require("prototypes.alerts")
require("prototypes.tips")

require("prototypes.hidden.beacon")
require("prototypes.hidden.caste-technologies")
require("prototypes.hidden.electric-energy-interface")
require("prototypes.hidden.gunfire-turret")
require("prototypes.hidden.sprites")

require("prototypes.styles")

Tirislib.Prototype.finish()
