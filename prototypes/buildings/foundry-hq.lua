-- TODO: actual graphics

Tirislib_Item.create {
    type = "item",
    name = "foundry-hq",
    icon = "__sosciencity-graphics__/graphics/foundry-caste.png",
    icon_size = 256,
    subgroup = "sosciencity-hqs",
    order = "eaa",
    place_result = "foundry-hq",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib_RecipeGenerator.create {
    product = "foundry-hq",
    themes = {{"building", 20}},
    default_theme_level = 3,
    ingredients = {{type = "item", name = "architectural-concept", amount = 1}},
    unlock = "foundry-caste"
}

Tirislib_Entity.create {
    type = "assembling-machine",
    name = "foundry-hq",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "foundry-hq"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "speed"},
    animation = {
        layers = {
            {
                filename = "__sosciencity-graphics__/graphics/placeholder.png",
                priority = "high",
                width = 224,
                height = 224,
                scale = 1,
                frame_count = 1
            },
            {
                filename = "__sosciencity-graphics__/graphics/foundry-caste.png",
                priority = "high",
                width = 256,
                height = 256,
                scale = 0.8,
                frame_count = 1
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-caste-foundry"},
    energy_usage = "190kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 0.25,
        drain = "10kW"
    }
}:set_size(7, 7):copy_localisation_from_item():copy_icon_from_item()
