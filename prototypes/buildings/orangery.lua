Tirislib_Item.create {
    type = "item",
    name = "orangery",
    icon = "__sosciencity-graphics__/graphics/icon/orangery.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "aaa",
    place_result = "orangery",
    stack_size = 10,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib_RecipeGenerator.create {
    product = "orangery",
    themes = {{"building", 5}, {"machine", 3}, {"piping", 10}, {"lamp", 20}, {"window", 50}},
    default_theme_level = 4,
    category = "sosciencity-architecture"
}

local pipe_pictures = Tirislib_Entity.get_standard_pipe_pictures {"south"}

Tirislib_Entity.create {
    type = "assembling-machine",
    name = "orangery",
    icon = "__sosciencity-graphics__/graphics/icon/orangery.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "orangery"},
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
                filename = "__sosciencity-graphics__/graphics/entity/orangery/orangery.png",
                priority = "high",
                width = 576,
                height = 576,
                shift = {0.5, -0.5},
                hr_version = {
                    filename = "__sosciencity-graphics__/graphics/entity/orangery/orangery-hr.png",
                    priority = "high",
                    width = 1152,
                    height = 1152,
                    shift = {0.5, -0.5},
                    scale = 0.5
                }
            },
            {
                filename = "__sosciencity-graphics__/graphics/entity/orangery/orangery-shadowmap.png",
                priority = "high",
                width = 576,
                height = 576,
                shift = {0.5, -0.5},
                draw_as_shadow = true,
                hr_version = {
                    filename = "__sosciencity-graphics__/graphics/entity/orangery/orangery-shadowmap-hr.png",
                    priority = "high",
                    width = 1152,
                    height = 1152,
                    shift = {0.5, -0.5},
                    scale = 0.5,
                    draw_as_shadow = true
                }
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-orangery"},
    energy_usage = "195kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 1,
        drain = "5kW"
    },
    fluid_boxes = {
        {
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {8.0, 1.0}}},
            production_type = "input"
        },
        {
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-8.0, 1.0}}},
            production_type = "input"
        },
        {
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {8.0, -1.0}}},
            production_type = "output"
        },
        {
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-8.0, -1.0}}},
            production_type = "output"
        }
    },
    working_sound = {
        sound = {filename = "__sosciencity-graphics__/sound/greenhouse-watering.ogg", volume = 3},
        apparent_volume = 1.5
    }
}:set_size(15, 15):copy_localisation_from_item()
