-- initialisation
require("lib.init")
require("recipe-generator")
require("integrations")
require("datastage-configuration")

-- create prototypes
require("prototypes.item-groups")
require("prototypes.recipe-categories")
require("prototypes.technologies")

require("prototypes.beverages")
require("prototypes.furniture")
require("prototypes.garbage")
require("prototypes.materials")
require("prototypes.food")
require("prototypes.drinking-water")
require("prototypes.ideas")
require("prototypes.flora")
require("prototypes.fauna")

require("prototypes.housing")
require("prototypes.buildings")

require("prototypes.hidden.beacon")
require("prototypes.hidden.caste-technologies")
require("prototypes.hidden.electric-energy-interface")
require("prototypes.hidden.sprites")

Tirislib_Prototype:finish()
