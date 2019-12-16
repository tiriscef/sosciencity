Tirislib_Item.create {
    type = "item",
    name = "greenhouse",
    icon = "__sosciencity__/graphics/icon/greenhouse.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "aab",
    place_result = "greenhouse",
    stack_size = 10
}

local recipe = Tirislib_RecipeGenerator.create_recipe("greenhouse")
recipe:add_unlock() --TODO tech

local pipe_pictures = {
    north = Tirislib_Entity.get_empty_pipe_picture(),
    east = Tirislib_Entity.get_empty_pipe_picture(),
    south = {
        filename = "__base__/graphics/entity/assembling-machine-1/assembling-machine-1-pipe-S.png",
        width = 44,
        height = 31,
        shift = util.by_pixel(0, -31.5),
        hr_version = {
            filename = "__base__/graphics/entity/assembling-machine-1/hr-assembling-machine-1-pipe-S.png",
            width = 88,
            height = 61,
            shift = util.by_pixel(0, -31.25),
            scale = 0.5
        }
    },
    west = Tirislib_Entity.get_empty_pipe_picture()
}

Tirislib_Entity.create {
    type = "assembling-machine",
    name = "greenhouse",
    icon = "__sosciencity__/graphics/icon/greenhouse.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "greenhouse"},
    max_health = 400,
    corpse = "greenhouse-remnants",
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
                filename = "__sosciencity__/graphics/entity/greenhouse/greenhouse.png",
                frame_count = 1,
                priority = "high",
                width = 544,
                height = 544,
                shift = {0.0, -1.0},
                hr_version = {
                    filename = "__sosciencity__/graphics/entity/greenhouse/greenhouse-hr.png",
                    frame_count = 1,
                    priority = "high",
                    width = 1088,
                    height = 1088,
                    scale = 0.5,
                    shift = {0.0, -1.0}
                }
            },
            {
                filename = "__sosciencity__/graphics/entity/greenhouse/greenhouse-shadowmap.png",
                frame_count = 1,
                width = 544,
                height = 544,
                shift = {0.0, -1.0},
                draw_as_shadow = true,
                hr_version = {
                    filename = "__sosciencity__/graphics/entity/greenhouse/greenhouse-shadowmap-hr.png",
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
    crafting_speed = 1,
    crafting_categories = {"sosciencity-greenhouse"},
    energy_usage = "100kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 1
    },
    working_sound = {
        -- memo: make sound files louder in the future
        sound = {filename = "__sosciencity__/sound/greenhouse-watering.ogg", volume = 3},
        apparent_volume = 1.5
    },
    fluid_boxes = {
        {
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {8.0, 0.0}}},
            production_type = "input"
        },
        {
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {8.0, 2.0}}},
            production_type = "input"
        },
        {
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {8.0, -2.0}}},
            production_type = "input"
        },
        {
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-8.0, 0.0}}},
            production_type = "output"
        },
        {
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-8.0, 2.0}}},
            production_type = "output"
        },
        {
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-8.0, -2.0}}},
            production_type = "output"
        },
        off_when_no_fluid_recipe = true
    }
}:set_size(15, 15)

Tirislib_Entity.create {
    type = "corpse",
    name = "greenhouse-remnants",
    icon = "__sosciencity__/graphics/icon/greenhouse.png",
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
        filename = "__sosciencity__/graphics/entity/greenhouse/greenhouse-remnants.png",
        direction_count = 1,
        width = 544,
        height = 544,
        shift = {0.0, -1.0},
        hr_version = {
            filename = "__sosciencity__/graphics/entity/greenhouse/greenhouse-remnants-hr.png",
            direction_count = 1,
            width = 1088,
            height = 1088,
            shift = {0.0, -1.0},
            scale = 0.5,
        }
    }
}:set_size(15, 15)
