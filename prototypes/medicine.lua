local Diseases = require("constants.diseases")
local Food = require("constants.food")

---------------------------------------------------------------------------------------------------
-- << items >>

local medicine_items = {
    {name = "activated-carbon", sprite_variations = {name = "activated-carbon", count = 3, include_icon = true}},
    {name = "artificial-limb"},
    {name = "artificial-heart"},
    {name = "bandage", sprite_variations = {name = "bandage-pile", count = 3}},
    {name = "isotonic-saline-solution"},
    {name = "blood-bag"},
    {name = "psychotropics", sprite_variations = {name = "psychotropics-pile", count = 3}},
    {name = "analgesics", sprite_variations = {name = "analgesics-pile", count = 3}},
    {name = "potent-analgesics", sprite_variations = {name = "potent-analgesics-pile", count = 3}},
    {name = "anesthetics", sprite_variations = {name = "anesthetics-pile", count = 3}},
    {name = "antibiotics", sprite_variations = {name = "antibiotics-pile", count = 3}},
    {name = "antimycotics", sprite_variations = {name = "antimycotics-pile", count = 3}},
    {name = "vitamine-supplements", use_placeholder_icon = true},
    {name = "nutritional-supplements", use_placeholder_icon = true}
}

Tirislib.Item.batch_create(medicine_items, {subgroup = "sosciencity-medicine", stack_size = 50})

---------------------------------------------------------------------------------------------------
-- << recipes >>

Tirislib.RecipeGenerator.create {
    name = "activated-carbon-from-sawdust",
    product = "activated-carbon",
    ingredients = {
        {type = "item", name = "sawdust", amount = 10},
        {type = "item", name = "salt", amount = 10},
        {type = "fluid", name = "steam", amount = 300}
    },
    index_fluid_ingredients = true,
    category = "sosciencity-pharma",
    energy_required = 5,
    allow_productivity = true,
    unlock = "activated-carbon-filtering"
}

Tirislib.RecipeGenerator.create {
    name = "activated-carbon-from-sugar",
    product = "activated-carbon",
    product_amount = 2,
    ingredients = {
        {type = "item", name = "sugar", amount = 10},
        {type = "item", name = "salt", amount = 10},
        {type = "fluid", name = "steam", amount = 300}
    },
    index_fluid_ingredients = true,
    category = "sosciencity-pharma",
    energy_required = 5,
    allow_productivity = true,
    unlock = "food-processing"
}

Tirislib.RecipeGenerator.create {
    product = "artificial-limb",
    themes = {
        {"framework", 2},
        {"wiring", 1},
        {"electronics", 1}
    },
    category = "sosciencity-pharma",
    default_theme_level = 1,
    energy_required = 10,
    allow_productivity = true,
    unlock = "medbay"
}

Tirislib.RecipeGenerator.create {
    product = "artificial-heart",
    themes = {
        {"casing", 1},
        {"wiring", 2},
        {"electronics", 1},
        {"battery", 1}
    },
    category = "sosciencity-pharma",
    default_theme_level = 4,
    energy_required = 20,
    allow_productivity = true,
    unlock = "intensive-care"
}

Tirislib.RecipeGenerator.create {
    product = "bandage",
    product_amount = 15,
    ingredients = {
        {type = "item", name = "cloth", amount = 10},
        {type = "fluid", name = "steam", amount = 300}
    },
    index_fluid_ingredients = true,
    category = "sosciencity-pharma",
    energy_required = 10,
    allow_productivity = true,
    unlock = "medbay"
}

Tirislib.RecipeGenerator.create {
    product = "isotonic-saline-solution",
    ingredients = {
        {type = "fluid", name = "clean-water", amount = 10},
        {type = "item", name = "salt", amount = 1}
    },
    index_fluid_ingredients = true,
    category = "sosciencity-pharma",
    energy_required = 2,
    unlock = "medbay"
}

Tirislib.RecipeGenerator.create {
    product = "psychotropics",
    ingredients = {
        {type = "item", name = "phytofall-blossom", amount = 2},
        {type = "item", name = "amylum", amount = 1},
        {type = "fluid", name = "ethanol", amount = 10}
    },
    index_fluid_ingredients = true,
    category = "sosciencity-pharma",
    energy_required = 3,
    allow_productivity = true,
    unlock = "psychiatry"
}

Tirislib.RecipeGenerator.create {
    product = "analgesics",
    ingredients = {
        {type = "item", name = "gingil-hemp", amount = 1},
        {type = "item", name = "amylum", amount = 1},
        {type = "fluid", name = "ethanol", amount = 10}
    },
    index_fluid_ingredients = true,
    category = "sosciencity-pharma",
    energy_required = 3,
    allow_productivity = true,
    unlock = "medbay"
}

Tirislib.RecipeGenerator.create {
    product = "potent-analgesics",
    ingredients = {
        {type = "item", name = "necrofall", amount = 1},
        {type = "item", name = "amylum", amount = 1},
        {type = "fluid", name = "ethanol", amount = 10}
    },
    index_fluid_ingredients = true,
    category = "sosciencity-pharma",
    energy_required = 3,
    allow_productivity = true,
    unlock = "intensive-care"
}

Tirislib.RecipeGenerator.create {
    product = "anesthetics",
    ingredients = {
        {type = "item", name = "necrofall", amount = 5},
        {type = "fluid", name = "ethanol", amount = 10}
    },
    index_fluid_ingredients = true,
    category = "sosciencity-pharma",
    energy_required = 3,
    allow_productivity = true,
    unlock = "intensive-care"
}

Tirislib.RecipeGenerator.create {
    product = "antibiotics",
    ingredients = {
        {type = "item", name = "amylum", amount = 1},
        {type = "item", name = "sugar", amount = 3},
        {type = "fluid", name = "flinnum", amount = 10}
    },
    index_fluid_ingredients = true,
    category = "sosciencity-pharma",
    energy_required = 3,
    allow_productivity = true,
    unlock = "hospital"
}

Tirislib.RecipeGenerator.create {
    product = "antimycotics",
    ingredients = {
        {type = "item", name = "zetorn", amount = 5},
        {type = "fluid", name = "ethanol", amount = 10},
        {type = "fluid", name = "clean-water", amount = 10},
        {type = "fluid", name = "fatty-oil", amount = 10}
    },
    index_fluid_ingredients = true,
    category = "sosciencity-pharma",
    energy_required = 3,
    allow_productivity = true,
    unlock = "hospital"
}

Tirislib.Recipe.create {
    name = "donate-blood",
    category = "sosciencity-handcrafting",
    enabled = true,
    energy_required = 5,
    ingredients = {},
    results = {
        {type = "item", name = "blood-bag", amount = 1}
    },
    icon = "__sosciencity-graphics__/graphics/icon/blood-bag.png",
    icon_size = 64,
    subgroup = "sosciencity-medicine",
    main_product = ""
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
        distinctions = {
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
        }
    },
    {
        name = "sosciencity-medical-kit",
        distinctions = {
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
    product = "sosciencity-emergency-ration",
    name = "sosciencity-emergency-ration",
    category = "sosciencity-handcrafting",
    localised_description = {"recipe-description.sosciencity-emergency-ration", tostring(Food.emergency_ration_calories)}
}

-- TODO: emergency ration needs a non-handcrafting recipe because I want to use it as a medicine item

Tirislib.RecipeGenerator.create {
    product = "sosciencity-medical-kit",
    product_amount = 1,
    ingredients = {
        {type = "item", name = "blood-bag", amount = 1},
        {type = "item", name = "gingil-hemp", amount = 2}
    },
    category = "sosciencity-pharma"
}

Tirislib.RecipeGenerator.create {
    product = "sosciencity-medical-kit",
    product_amount = 5,
    ingredients = {
        {type = "item", name = "blood-bag", amount = 1},
        {type = "item", name = "analgesics", amount = 1},
        {type = "item", name = "bandage", amount = 5}
    },
    category = "sosciencity-pharma",
    unlock = "medbay"
}
