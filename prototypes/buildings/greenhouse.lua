Tirislib.Item.create {
    type = "item",
    name = "greenhouse",
    icon = "__sosciencity-graphics__/graphics/icon/greenhouse.png",
    icon_size = 64,
    subgroup = "sosciencity-flora-buildings",
    order = "baa",
    place_result = "greenhouse",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "greenhouse",
    themes = {{"plating", 50}, {"piping", 40}, {"lamp", 40}, {"soil", 100}},
    ingredients = {
        {type = "item", name = "window", amount = 50}
    },
    default_theme_level = 4,
    unlock = "controlled-environment-farming"
}

local pipe_pictures = Tirislib.Entity.get_standard_pipe_pictures {"south"}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "greenhouse",
    icon = "__sosciencity-graphics__/graphics/icon/greenhouse.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "greenhouse"},
    max_health = 400,
    corpse = "greenhouse-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "speed"},
    animation = {
        layers = {
            {
                filename = "__sosciencity-graphics__/graphics/entity/greenhouse/greenhouse.png",
                frame_count = 1,
                priority = "high",
                width = 544,
                height = 544,
                shift = {0.0, -1.0},
                hr_version = {
                    filename = "__sosciencity-graphics__/graphics/entity/greenhouse/greenhouse-hr.png",
                    frame_count = 1,
                    priority = "high",
                    width = 1088,
                    height = 1088,
                    scale = 0.5,
                    shift = {0.0, -1.0}
                }
            },
            {
                filename = "__sosciencity-graphics__/graphics/entity/greenhouse/greenhouse-shadowmap.png",
                frame_count = 1,
                width = 544,
                height = 544,
                shift = {0.0, -1.0},
                draw_as_shadow = true,
                hr_version = {
                    filename = "__sosciencity-graphics__/graphics/entity/greenhouse/greenhouse-shadowmap-hr.png",
                    frame_count = 1,
                    width = 1088,
                    height = 1088,
                    scale = 0.5,
                    shift = {0.0, -1.0},
                    draw_as_shadow = true
                }
            }
        }
    },
    crafting_speed = 1.5,
    crafting_categories = {"sosciencity-farming-annual"},
    energy_usage = "195kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = Sosciencity_Config.agriculture_pollutes and 1 or -5,
        drain = "5kW"
    },
    working_sound = {
        -- memo: make sound files louder in the future
        sound = {filename = "__sosciencity-graphics__/sound/greenhouse-watering.ogg", volume = 3},
        apparent_volume = 1.5
    },
    fluid_boxes = {
        {
            base_level = -1,
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {8.0, 0.0}}},
            production_type = "input"
        },
        {
            base_level = -1,
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {8.0, 2.0}}},
            production_type = "input"
        },
        {
            base_level = -1,
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {8.0, -2.0}}},
            production_type = "input"
        },
        {
            base_level = 1,
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-8.0, 0.0}}},
            production_type = "output"
        },
        {
            base_level = 1,
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-8.0, 2.0}}},
            production_type = "output"
        },
        {
            base_level = 1,
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-8.0, -2.0}}},
            production_type = "output"
        },
        off_when_no_fluid_recipe = true
    }
}:set_size(15, 15):copy_localisation_from_item()

Tirislib.Entity.create {
    type = "corpse",
    name = "greenhouse-remnants",
    icon = "__sosciencity-graphics__/graphics/icon/greenhouse.png",
    icon_size = 64,
    flags = {"placeable-neutral", "not-on-map"},
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    final_render_layer = "remnants",
    subgroup = "remnants",
    order = "dead-greenhouse:(",
    remove_on_tile_placement = false,
    tile_width = 15,
    tile_height = 7,
    animation = {
        filename = "__sosciencity-graphics__/graphics/entity/greenhouse/greenhouse-remnants.png",
        direction_count = 1,
        width = 544,
        height = 544,
        shift = {0.0, -1.0},
        hr_version = {
            filename = "__sosciencity-graphics__/graphics/entity/greenhouse/greenhouse-remnants-hr.png",
            direction_count = 1,
            width = 1088,
            height = 1088,
            shift = {0.0, -1.0},
            scale = 0.5
        }
    },
    localised_name = {"item-name.greenhouse"}
}:set_size(15, 15)
