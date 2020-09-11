Tirislib_Item.create {
    type = "item",
    name = "slaughter-pit",
    icon = "__sosciencity-graphics__/graphics/icon/slaughter-pit.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "aaa",
    place_result = "slaughter-pit",
    stack_size = 10,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib_RecipeGenerator.create {
    product = "slaughter-pit",
    themes = {{"machine", 2}},
    default_theme_level = 1
}

Tirislib_Entity.create {
    type = "furnace",
    name = "slaughter-pit",
    icon = "__sosciencity-graphics__/graphics/icon/slaughter-pit.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "slaughter-pit"},
    max_health = 400,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    module_specification = {
        module_slots = 2
    },
    allowed_effects = {"productivity", "consumption", "speed", "pollution"},
    animation = {
        layers = {
            {
                filename = "__sosciencity-graphics__/graphics/entity/slaughter-pit/slaughter-pit.png",
                frame_count = 1,
                priority = "high",
                width = 128,
                height = 128,
                shift = {0.5, -0.5},
                hr_version = {
                    filename = "__sosciencity-graphics__/graphics/entity/slaughter-pit/slaughter-pit-hr.png",
                    frame_count = 1,
                    priority = "high",
                    width = 256,
                    height = 256,
                    scale = 0.5,
                    shift = {0.5, -0.5}
                }
            },
            {
                filename = "__sosciencity-graphics__/graphics/entity/slaughter-pit/slaughter-pit-shadowmap.png",
                frame_count = 1,
                width = 128,
                height = 128,
                shift = {0.5, -0.5},
                draw_as_shadow = true,
                hr_version = {
                    filename = "__sosciencity-graphics__/graphics/entity/slaughter-pit/slaughter-pit-shadowmap-hr.png",
                    frame_count = 1,
                    width = 256,
                    height = 256,
                    scale = 0.5,
                    shift = {0.5, -0.5},
                    draw_as_shadow = true
                }
            }
        }
    },
    crafting_speed = 1.5,
    crafting_categories = {"sosciencity-slaughter"},
    source_inventory_size = 1,
    result_inventory_size = 6,
    energy_usage = "95kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 1.5,
        drain = "5kW"
    },
    working_sound = {
        filename = "__sosciencity-graphics__/sound/slaughter-pit.ogg",
        volume = 0.5
    }
}:set_size(3, 3):copy_localisation_from_item()
