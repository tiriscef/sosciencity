require("lib.prototypes")
require("integrations")

require("prototypes.item-groups")
require("prototypes.recipe-categories")

require("prototypes.technologies")
require("prototypes.buildings") -- TODO
require("prototypes.food")
require("prototypes.ideas")
require("prototypes.hidden-entities.beacon")
require("prototypes.hidden-entities.electric-energy-interface")

Prototype:finish_postponed()
