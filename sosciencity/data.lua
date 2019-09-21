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
require("prototypes.hidden-entities.beacon")
require("prototypes.hidden-entities.electric-energy-interface")

Prototype:finish_postponed()
