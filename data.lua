-- initialisation
require("lib.init")
require("integrations")

-- require the pipe stuff functions, just in case another mod deletes or modifies it
require("__base__.prototypes.entity.demo-pipecovers")

-- create prototypes
require("prototypes.item-groups")
require("prototypes.recipe-categories")
require("prototypes.technologies")
require("prototypes.furniture")
require("prototypes.garbage")
require("prototypes.materials")
require("prototypes.housing")
require("prototypes.buildings")
require("prototypes.food")
require("prototypes.drinking-water")
require("prototypes.ideas")
require("prototypes.hidden.beacon")
require("prototypes.hidden.caste-technologies")
require("prototypes.hidden.electric-energy-interface")
require("prototypes.hidden.sprites")

Tirislib_Prototype:finish()
