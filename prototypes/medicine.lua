local Diseases = require("constants.diseases")
local Food = require("constants.food")

---------------------------------------------------------------------------------------------------
-- << items >>

local medicine_items = {
    {name = "artificial-limp"},
    {name = "artificial-heart"},
    {name = "bandage", sprite_variations = {name = "bandage-pile", count = 3}},
    {name = "blood-bag"},
    {name = "psychotropics", sprite_variations = {name = "psychotropics-pile", count = 3}},
    {name = "analgesics", sprite_variations = {name = "analgesics-pile", count = 3}},
    {name = "potent-analgesics", sprite_variations = {name = "potent-analgesics-pile", count = 3}},
    {name = "anesthetics", sprite_variations = {name = "anesthetics-pile", count = 3}},
    {name = "antibiotics", sprite_variations = {name = "antibiotics-pile", count = 3}},
    {name = "antimycotics", sprite_variations = {name = "antimycotics-pile", count = 3}}
}

local function find_curable_diseases(item_name)
    local ret = {}

    for _, disease in pairs(Diseases.values) do
        if disease.cure_items and disease.cure_items[item_name] then
            ret[#ret + 1] = disease.localised_name
        end
    end

    return ret
end

for _, medicine in pairs(medicine_items) do
    medicine.distinctions = medicine.destinctions or {}
    local distinctions = medicine.distinctions

    distinctions.localised_description = {
        "sosciencity-util.medicine",
        {"item-description." .. medicine.name},
        Tirislib_Locales.create_enumeration(find_curable_diseases(medicine.name), "[color=#FFFFFF], [/color]")
    }
end

Tirislib_Item.batch_create(medicine_items, {subgroup = "sosciencity-medicine", stack_size = 50})

---------------------------------------------------------------------------------------------------
-- << recipes >>

Tirislib_RecipeGenerator.create {
    product = "artificial-limp",
    themes = {
        {"framework", 2},
        {"wiring", 1},
        {"electronics", 1}
    },
    default_theme_level = 1,
    energy_required = 3,
    allow_productivity = true,
    unlock = "hospital"
}

Tirislib_RecipeGenerator.create {
    product = "artificial-heart",
    themes = {
        {"casing", 1},
        {"wiring", 2},
        {"electronics", 1},
        {"battery", 1}
    },
    default_theme_level = 4,
    energy_required = 10,
    allow_productivity = true,
    unlock = "intensive-care"
}

Tirislib_RecipeGenerator.create {
    product = "bandage",
    product_amount = 15,
    ingredients = {
        {name = "cloth", amount = 10},
        {name = "steam", amount = 300, type = "fluid"}
    },
    category = "crafting-with-fluid",
    energy_required = 5,
    allow_productivity = true,
    unlock = "hospital"
}

Tirislib_RecipeGenerator.create {
    product = "psychotropics",
    themes = {{"tablet_ingredients", 1}},
    ingredients = {
        {type = "item", name = "phytofall-blossom", amount = 5}
    },
    category = "sosciencity-pharma",
    energy_required = 3,
    allow_productivity = true,
    unlock = "psychiatry"
}

Tirislib_RecipeGenerator.create {
    product = "analgesics",
    themes = {{"tablet_ingredients", 1}},
    ingredients = {
        {type = "item", name = "gingil-hemp", amount = 5},
        {type = "fluid", name = "ethanol", amount = 10}
    },
    category = "sosciencity-pharma",
    energy_required = 3,
    allow_productivity = true,
    unlock = "hospital"
}

Tirislib_RecipeGenerator.create {
    product = "potent-analgesics",
    themes = {{"tablet_ingredients", 1}},
    ingredients = {
        {type = "item", name = "necrofall", amount = 2},
        {type = "fluid", name = "ethanol", amount = 10}
    },
    category = "sosciencity-pharma",
    energy_required = 3,
    allow_productivity = true,
    unlock = "intensive-care"
}

Tirislib_RecipeGenerator.create {
    product = "anesthetics",
    ingredients = {
        {type = "item", name = "necrofall", amount = 5},
        {type = "fluid", name = "ethanol", amount = 10}
    },
    category = "sosciencity-pharma",
    energy_required = 3,
    allow_productivity = true,
    unlock = "intensive-care"
}

Tirislib_RecipeGenerator.create {
    product = "antibiotics",
    themes = {{"tablet_ingredients", 1}},
    ingredients = {
        {type = "fluid", name = "flinnum", amount = 10},
        {type = "item", name = "sugar", amount = 3}
    },
    category = "sosciencity-pharma",
    energy_required = 3,
    allow_productivity = true,
    unlock = "hospital"
}

Tirislib_RecipeGenerator.create {
    product = "antimycotics",
    themes = {{"cream_ingredients", 1}},
    ingredients = {
        {type = "item", name = "zetorn", amount = 5},
        -- at the moment I don't have a building for pharmaceuticals and am limited to the 2 fluid boxes of chem plants
        --{type = "fluid", name = "ethanol", amount = 10}
    },
    category = "sosciencity-pharma",
    energy_required = 3,
    allow_productivity = true,
    unlock = "hospital"
}

Tirislib_Recipe.create {
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

Tirislib_Prototype.batch_create {
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
        duration_in_ticks = 60 * 90,
        target_movement_modifier_from = 0.5,
        target_movement_modifier_to = 1
    },
    {
        type = "sticker",
        name = "blood-donation-3",
        duration_in_ticks = 60 * 7,
        target_movement_modifier = 0.05
    },
    {
        type = "sticker",
        name = "blood-donation-4",
        duration_in_ticks = 60 * 80,
        target_movement_modifier = -1
    },
    {
        type = "sticker",
        name = "blood-donation-5",
        duration_in_ticks = 60 * 45,
        target_movement_modifier = 0.05
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

Tirislib_Item.batch_create(
    consumable_medicine,
    {
        type = "capsule",
        subgroup = "sosciencity-medicine",
        stack_size = 50
    }
)

Tirislib_RecipeGenerator.create {
    product = "sosciencity-emergency-ration",
    name = "sosciencity-emergency-ration",
    category = "sosciencity-handcrafting",
    localised_description = {"recipe-description.sosciencity-emergency-ration", Food.emergency_ration_calories}
}

Tirislib_RecipeGenerator.create {
    product = "sosciencity-medical-kit",
    product_amount = 1,
    ingredients = {
        {type = "item", name = "blood-bag", amount = 1},
        {type = "item", name = "gingil-hemp", amount = 2}
    }
}

Tirislib_RecipeGenerator.create {
    product = "sosciencity-medical-kit",
    product_amount = 5,
    ingredients = {
        {type = "item", name = "blood-bag", amount = 1},
        {type = "item", name = "analgesics", amount = 1},
        {type = "item", name = "bandage", amount = 5}
    },
    unlock = "hospital"
}
