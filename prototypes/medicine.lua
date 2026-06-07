local Diseases = require("constants.diseases")
local Food = require("constants.food")
local InhabitantsConstants = require("constants.inhabitants")

---------------------------------------------------------------------------------------------------
-- << items >>

local medicine_items = {
    {
        name = "medical-report",
        sprite_variations = {name = "medical-report", count = 3, include_icon = true}
    },
    {
        name = "surgery-instruments",
        use_placeholder_icon = true
    },
    {
        name = "activated-carbon",
        sprite_variations = {name = "activated-carbon", count = 3, include_icon = true}
    },
    {name = "artificial-limb"},
    {name = "artificial-heart"},
    {
        name = "bandage",
        sprite_variations = {name = "bandage-pile", count = 3}
    },
    {name = "isotonic-saline-solution"},
    {name = "blood-bag"},
    {name = "engineer-spinal-fluid", use_placeholder_icon = true},
    {
        name = "psychotropics",
        sprite_variations = {name = "psychotropics-pile", count = 3}
    },
    {
        name = "analgesics",
        sprite_variations = {name = "analgesics-pile", count = 3}
    },
    {
        name = "potent-analgesics",
        sprite_variations = {name = "potent-analgesics-pile", count = 3}
    },
    {
        name = "anesthetics",
        sprite_variations = {name = "anesthetics-pile", count = 3}
    },
    {
        name = "antimicrobials",
        sprite_variations = {name = "antimicrobials-pile", count = 3}
    },
    {
        name = "vitamine-supplements",
        use_placeholder_icon = true
    },
    {
        name = "nutritional-supplements",
        use_placeholder_icon = true
    },
    {
        name = "huwan-hormones",
        use_placeholder_icon = true
    },
    {
        name = "antiemetics",
        use_placeholder_icon = true
    },
    {
        name = "antitoxin",
        sprite_variations = {name = "antitoxin-pile", count = 3}
    },
    {
        name = "antihistamines",
        use_placeholder_icon = true
    }
}

Tirislib.Item.batch_create(medicine_items, {subgroup = "sosciencity-medicine", stack_size = 50})

---------------------------------------------------------------------------------------------------
-- << recipes >>

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "surgery-instruments", amount = 1}
    },
    ingredients = {
        {theme = "plating", amount = 2},
        {theme = "plating2", amount = 2},
    },
    category = "sosciencity-handcrafting",
    enabled = true
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "surgery-instruments", amount = 2}
    },
    ingredients = {
        {theme = "plating", amount = 2},
        {theme = "plating2", amount = 2},
        {type = "fluid", name = "steam", amount = 200}
    },
    category = "sosciencity-pharma",
    energy_required = 4,
    do_index_fluid_ingredients = true,
    unlock = "medbay"
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "activated-carbon", amount = 1}
    },
    ingredients = {
        {type = "item", name = "sawdust", amount = 10},
        {type = "item", name = "salt", amount = 10},
        {type = "fluid", name = "steam", amount = 300}
    },
    name = "activated-carbon-from-sawdust",
    category = "sosciencity-pharma",
    energy_required = 5,
    do_index_fluid_ingredients = true,
    unlock = "activated-carbon-filtering",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "activated-carbon", amount = 2}
    },
    ingredients = {
        {type = "item", name = "sugar", amount = 10},
        {type = "item", name = "salt", amount = 10},
        {type = "fluid", name = "steam", amount = 300}
    },
    name = "activated-carbon-from-sugar",
    category = "sosciencity-pharma",
    energy_required = 5,
    do_index_fluid_ingredients = true,
    unlock = "food-processing",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "artificial-limb", amount = 1}
    },
    ingredients = {
        {theme = "framework", amount = 2},
        {theme = "wiring", amount = 1},
        {theme = "electronics", amount = 1}
    },
    category = "sosciencity-pharma",
    energy_required = 10,
    default_theme_level = 1,
    unlock = "medbay"
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "artificial-heart", amount = 1}
    },
    ingredients = {
        {theme = "casing", amount = 1},
        {theme = "wiring", amount = 2},
        {theme = "electronics", amount = 1},
        {theme = "battery", amount = 1}
    },
    category = "sosciencity-pharma",
    energy_required = 20,
    default_theme_level = 4,
    unlock = "intensive-care"
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "bandage", amount = 15}
    },
    ingredients = {
        {type = "item", name = "cloth", amount = 10},
        {type = "fluid", name = "steam", amount = 300}
    },
    category = "sosciencity-pharma",
    energy_required = 10,
    do_index_fluid_ingredients = true,
    unlock = "medbay",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "isotonic-saline-solution", amount = 1}
    },
    ingredients = {
        {type = "fluid", name = "clean-water", amount = 10},
        {type = "item", name = "salt", amount = 1}
    },
    category = "sosciencity-pharma",
    energy_required = 2,
    do_index_fluid_ingredients = true,
    unlock = "medbay",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "psychotropics", amount = 1}
    },
    ingredients = {
        {type = "item", name = "phytofall-blossom", amount = 2},
        {type = "item", name = "amylum", amount = 1},
        {type = "fluid", name = "ethanol", amount = 10}
    },
    category = "sosciencity-pharma",
    energy_required = 3,
    do_index_fluid_ingredients = true,
    unlock = "psychiatry",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "analgesics", amount = 1}
    },
    ingredients = {
        {type = "item", name = "gingil-hemp", amount = 1},
        {type = "item", name = "amylum", amount = 1},
        {type = "fluid", name = "ethanol", amount = 10}
    },
    category = "sosciencity-pharma",
    energy_required = 3,
    do_index_fluid_ingredients = true,
    unlock = "medbay",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "potent-analgesics", amount = 1}
    },
    ingredients = {
        {type = "item", name = "mold", amount = 2},
        {type = "fluid", name = "fatty-oil", amount = 20},
        {type = "fluid", name = "ethanol", amount = 15}
    },
    category = "sosciencity-pharma",
    energy_required = 3,
    do_index_fluid_ingredients = true,
    unlock = "intensive-care",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "anesthetics", amount = 1}
    },
    ingredients = {
        {type = "item", name = "molasses", amount = 5},
        {type = "fluid", name = "pemtenn", amount = 20},
        {type = "fluid", name = "ethanol", amount = 10}
    },
    category = "sosciencity-pharma",
    energy_required = 5,
    do_index_fluid_ingredients = true,
    unlock = "intensive-care",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "antimicrobials", amount = 1}
    },
    ingredients = {
        {type = "item", name = "gingil-hemp", amount = 5},
        {type = "item", name = "salt", amount = 5},
        {type = "fluid", name = "ethanol", amount = 10}
    },
    category = "sosciencity-pharma",
    energy_required = 3,
    do_index_fluid_ingredients = true,
    unlock = "medbay",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "antimicrobials", amount = 1}
    },
    ingredients = {
        {type = "item", name = "amylum", amount = 1},
        {type = "item", name = "sugar", amount = 10},
        {type = "fluid", name = "flinnum", amount = 10}
    },
    category = "sosciencity-pharma",
    energy_required = 3,
    do_index_fluid_ingredients = true,
    unlock = "basic-biotechnology",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "antimicrobials", amount = 2}
    },
    ingredients = {
        {type = "item", name = "nucleobases", amount = 4},
        {type = "fluid", name = "flinnum", amount = 20},
        {type = "fluid", name = "ethanol", amount = 10}
    },
    category = "sosciencity-pharma",
    energy_required = 5,
    do_index_fluid_ingredients = true,
    unlock = "intensive-care",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "nutritional-supplements", amount = 1}
    },
    ingredients = {
        {type = "item", name = "proteins", amount = 1},
        {type = "item", name = "amylum", amount = 2},
        {type = "item", name = "molasses", amount = 1}
    },
    category = "sosciencity-pharma",
    energy_required = 3,
    unlock = "medbay",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "vitamine-supplements", amount = 1}
    },
    ingredients = {
        {type = "item", name = "liontooth", amount = 2},
        {type = "item", name = "wild-algae", amount = 2},
        {type = "fluid", name = "ethanol", amount = 15}
    },
    category = "sosciencity-pharma",
    energy_required = 3,
    do_index_fluid_ingredients = true,
    unlock = "hospital",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "antiemetics", amount = 1}
    },
    ingredients = {
        {type = "item", name = "ignivern", amount = 2},
        {type = "item", name = "amylum", amount = 1},
        {type = "fluid", name = "ethanol", amount = 10}
    },
    category = "sosciencity-pharma",
    energy_required = 3,
    do_index_fluid_ingredients = true,
    unlock = "medbay",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "antihistamines", amount = 1}
    },
    ingredients = {
        {type = "item", name = "wild-algae", amount = 2},
        {type = "item", name = "amylum", amount = 1},
        {type = "fluid", name = "ethanol", amount = 10}
    },
    category = "sosciencity-pharma",
    energy_required = 3,
    do_index_fluid_ingredients = true,
    unlock = "medbay",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "huwan-hormones", amount = 1}
    },
    ingredients = {
        {type = "item", name = "proteins", amount = 2},
        {type = "fluid", name = "pemtenn", amount = 20},
        {type = "fluid", name = "ethanol", amount = 5}
    },
    category = "sosciencity-pharma",
    energy_required = 5,
    do_index_fluid_ingredients = true,
    unlock = "hospital",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "antitoxin", amount = 1}
    },
    ingredients = {
        {type = "item", name = "blood-bag", amount = 1},
        {type = "item", name = "agarose", amount = 2},
        {type = "fluid", name = "ethanol", amount = 15}
    },
    category = "sosciencity-pharma",
    energy_required = 5,
    do_index_fluid_ingredients = true,
    unlock = "hospital",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    name = "donate-blood",
    category = "sosciencity-handcrafting",
    enabled = true,
    energy_required = 3,
    ingredients = {
        {type = "item", name = "surgery-instruments", amount = 1}
    },
    results = {
        {type = "item", name = "blood-bag", amount = 1}
    },
    icon = "__sosciencity-graphics__/graphics/icon/blood-bag.png",
    icon_size = 64,
    subgroup = "sosciencity-medicine",
    main_product = "",
    allow_as_intermediate = false
}

Tirislib.RecipeGenerator.create {
    name = "extract-spinal-fluid",
    category = "sosciencity-handcrafting",
    enabled = false,
    energy_required = 3,
    ingredients = {
        {type = "item", name = "surgery-instruments", amount = 1},
        {type = "item", name = "analgesics", amount = 1}
    },
    results = {
        {type = "item", name = "engineer-spinal-fluid", amount = 5}
    },
    subgroup = "sosciencity-medicine",
    localised_name = {"recipe-name.extract-spinal-fluid"},
    localised_description = {"recipe-description.extract-spinal-fluid", tostring(InhabitantsConstants.spinal_fluid_health_cost)},
    unlock = "ovosynthesis",
    auto_recycle = false,
    allow_as_intermediate = false
}

Tirislib.Prototype.batch_create {
    {
        type = "sticker",
        name = "blood-donation-1",
        duration_in_ticks = 60 * 20, -- 20 seconds at 60 ticks per second
        target_movement_modifier_from = 0.8,
        target_movement_modifier_to = 1
    },
    {
        type = "sticker",
        name = "blood-donation-2",
        duration_in_ticks = 60 * 10,
        target_movement_modifier_from = 0.05,
        target_movement_modifier_to = 1
    },
    {
        type = "sticker",
        name = "blood-donation-3",
        duration_in_ticks = 60 * 150,
        target_movement_modifier_from = 0.5,
        target_movement_modifier_to = 1
    },
    {
        type = "sticker",
        name = "blood-donation-4",
        duration_in_ticks = 60 * 20,
        target_movement_modifier = -1
    },
    {
        type = "sticker",
        name = "blood-donation-5",
        duration_in_ticks = 60 * 30,
        target_movement_modifier_from = 0.05,
        target_movement_modifier_to = 1
    }
}

---------------------------------------------------------------------------------------------------
-- << consumables >>

local sounds = require("__base__.prototypes.entity.sounds")

local consumable_medicine = {
    {
        name = "sosciencity-emergency-ration",
        icon = "__sosciencity-graphics__/graphics/icon/emergency-ration.png",
        capsule_action = {
            type = "use-on-self",
            attack_parameters = {
                type = "projectile",
                activation_type = "consume",
                ammo_category = "capsule",
                cooldown = 15,
                range = 0,
                ammo_type = {
                    category = "capsule",
                    target_type = "position",
                    action = {
                        type = "direct",
                        action_delivery = {
                            type = "instant",
                            target_effects = {
                                {
                                    type = "damage",
                                    damage = {type = "physical", amount = -80}
                                },
                                {
                                    type = "play-sound",
                                    sound = sounds.eat_fish
                                }
                            }
                        }
                    }
                }
            }
        }
    },
    {
        name = "sosciencity-medical-kit",
        icon = "__sosciencity-graphics__/graphics/icon/medical-kit.png",
        capsule_action = {
            type = "use-on-self",
            attack_parameters = {
                type = "projectile",
                activation_type = "consume",
                ammo_category = "capsule",
                cooldown = 15,
                range = 0,
                ammo_type = {
                    category = "capsule",
                    target_type = "position",
                    action = {
                        type = "direct",
                        action_delivery = {
                            type = "instant",
                            target_effects = {
                                {
                                    type = "damage",
                                    damage = {type = "physical", amount = -200}
                                },
                                {
                                    type = "play-sound",
                                    sound = sounds.eat_fish
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

Tirislib.Item.batch_create(
    consumable_medicine,
    {
        type = "capsule",
        subgroup = "sosciencity-consumable-medicine",
        stack_size = 50
    }
)

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "sosciencity-emergency-ration", amount = 1}
    },
    category = "sosciencity-handcrafting",
    localised_description = {
        "recipe-description.sosciencity-emergency-ration",
        tostring(Food.emergency_ration_calories)
    }
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "sosciencity-medical-kit", amount = 1}
    },
    ingredients = {
        {type = "item", name = "blood-bag", amount = 1},
        {type = "item", name = "gingil-hemp", amount = 2}
    },
    category = "sosciencity-pharma",
    auto_recycle = false
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "sosciencity-medical-kit", amount = 5}
    },
    ingredients = {
        {type = "item", name = "blood-bag", amount = 1},
        {type = "item", name = "analgesics", amount = 1},
        {type = "item", name = "bandage", amount = 5}
    },
    category = "sosciencity-pharma",
    unlock = "medbay",
    auto_recycle = false
}
