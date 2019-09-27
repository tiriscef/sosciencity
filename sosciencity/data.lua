-- initialisation
require("lib.init")
require("integrations")

-- create prototypes
require("prototypes.item-groups")
require("prototypes.recipe-categories")
require("prototypes.technologies")
require("prototypes.housing")
require("prototypes.buildings")
require("prototypes.food")
require("prototypes.ideas")
require("prototypes.hidden.beacon")
require("prototypes.hidden.caste-technologies")
require("prototypes.hidden.electric-energy-interface")

Prototype:finish_postponed()
