-- initialisation
require("tirislib.init")
Tirislib.Prototype.modname = "sosciencity"
Tirislib.Prototype.placeholder_icon = "__sosciencity-graphics__/graphics/icon/placeholder.png"
Tirislib.BasePrototype.register_category_icon("handcrafting", {
    path = "__sosciencity-graphics__/graphics/utility/hand.png",
})
Tirislib.BasePrototype.register_category_icon("workshop", {
    path = "__sosciencity-graphics__/graphics/utility/tinkering.png",
})
Tirislib.BasePrototype.register_category_icon("enrichment", {
    path = "__sosciencity-graphics__/graphics/icon/enrichment.png",
    scale = 0.3,
    no_tint = true,
})
Tirislib.BasePrototype.register_category_icon("pure-culture", {
    path = "__sosciencity-graphics__/graphics/icon/pure-culture.png",
    scale = 0.3,
    no_tint = true,
})
Tirislib.BasePrototype.register_category_icon("farming", {
    path = "__sosciencity-graphics__/graphics/icon/farming.png",
    scale = 0.3,
    no_tint = true,
})
Tirislib.BasePrototype.register_category_icon("plant-neogenesis", {
    path = "__sosciencity-graphics__/graphics/icon/plant-neogenesis.png",
    scale = 0.3,
    no_tint = true,
})
Tirislib.BasePrototype.register_category_icon("slaughter", {
    path = "__sosciencity-graphics__/graphics/icon/slaughter.png",
    scale = 0.3,
    tint = {r = 1, g = 0.2, b = 0.2},
})
Tirislib.BasePrototype.register_category_icon("breeding", {
    path = "__sosciencity-graphics__/graphics/icon/breeding.png",
    scale = 0.3,
    no_tint = true,
})
Tirislib.BasePrototype.register_category_icon("keeping", {
    path = "__sosciencity-graphics__/graphics/icon/keeping.png",
    scale = 0.3,
    no_tint = true,
})

require("datastage-api.load")
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
require("prototypes.fauna")
require("prototypes.food")
require("prototypes.flora")
require("prototypes.education")

require("prototypes.hunting-gathering")

require("prototypes.housing")
require("prototypes.housing-upgrade-info")
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
