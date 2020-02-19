Tirislib_Item.create {
    type = "item",
    name = "farm",
    icon = "__sosciencity-graphics__/graphics/icon/farm.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "aaa",
    place_result = "farm",
    stack_size = 10
}

Tirislib_RecipeGenerator.create_recipe("farm", {{"soil", 50}, {"tank_small", 1}, {"piping", 2}})

local pipe_pictures = Tirislib_Entity.get_standard_pipe_pictures {"south"}

Tirislib_Entity.create {
    type = "assembling-machine",
    name = "farm",
    icon = "__sosciencity-graphics__/graphics/icon/farm.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "farm"},
    max_health = 200,
    corpse = "farm-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "consumption", "speed", "pollution"},
    animation = {
        north = {
            layers = {
                {
                    filename = "__sosciencity-graphics__/graphics/entity/farm/farm-north.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = 544,
                    height = 288,
                    shift = {0.0, 0.0},
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/farm/farm-north-hr.png",
                        frame_count = 1,
                        priority = "extra-high",
                        width = 1088,
                        height = 576,
                        scale = 0.5,
                        shift = {0.0, 0.0}
                    }
                },
                {
                    filename = "__sosciencity-graphics__/graphics/entity/farm/farm-north-shadowmap.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = 544,
                    height = 288,
                    shift = {0.0, 0.0},
                    draw_as_shadow = true,
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/farm/farm-north-shadowmap-hr.png",
                        frame_count = 1,
                        priority = "extra-high",
                        width = 1088,
                        height = 576,
                        scale = 0.5,
                        shift = {0.0, 0.0},
                        draw_as_shadow = true
                    }
                }
            }
        },
        east = {
            layers = {
                {
                    filename = "__sosciencity-graphics__/graphics/entity/farm/farm-east.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = 288,
                    height = 544,
                    shift = {0.0, 0.0},
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/farm/farm-east-hr.png",
                        frame_count = 1,
                        priority = "extra-high",
                        width = 576,
                        height = 1088,
                        scale = 0.5,
                        shift = {0.0, 0.0}
                    }
                },
                {
                    filename = "__sosciencity-graphics__/graphics/entity/farm/farm-east-shadowmap.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = 288,
                    height = 544,
                    shift = {0.0, 0.0},
                    draw_as_shadow = true,
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/farm/farm-east-shadowmap-hr.png",
                        frame_count = 1,
                        priority = "extra-high",
                        width = 576,
                        height = 1088,
                        scale = 0.5,
                        shift = {0.0, 0.0},
                        draw_as_shadow = true
                    }
                }
            }
        },
        south = {
            layers = {
                {
                    filename = "__sosciencity-graphics__/graphics/entity/farm/farm-south.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = 544,
                    height = 320,
                    shift = {0.0, -0.5},
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/farm/farm-south-hr.png",
                        frame_count = 1,
                        priority = "extra-high",
                        width = 1088,
                        height = 640,
                        scale = 0.5,
                        shift = {0.0, -0.5}
                    }
                },
                {
                    filename = "__sosciencity-graphics__/graphics/entity/farm/farm-south-shadowmap.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = 544,
                    height = 320,
                    shift = {0.0, -0.5},
                    draw_as_shadow = true,
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/farm/farm-south-shadowmap-hr.png",
                        frame_count = 1,
                        priority = "extra-high",
                        width = 1088,
                        height = 640,
                        scale = 0.5,
                        shift = {0.0, -0.5},
                        draw_as_shadow = true
                    }
                }
            }
        },
        west = {
            layers = {
                {
                    filename = "__sosciencity-graphics__/graphics/entity/farm/farm-west.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = 288,
                    height = 576,
                    shift = {0.0, -0.5},
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/farm/farm-west-hr.png",
                        frame_count = 1,
                        priority = "extra-high",
                        width = 576,
                        height = 1152,
                        scale = 0.5,
                        shift = {0.0, -0.5}
                    }
                },
                {
                    filename = "__sosciencity-graphics__/graphics/entity/farm/farm-west-shadowmap.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = 288,
                    height = 576,
                    shift = {0.0, -0.5},
                    draw_as_shadow = true,
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/farm/farm-west-shadowmap-hr.png",
                        frame_count = 1,
                        priority = "extra-high",
                        width = 576,
                        height = 1152,
                        scale = 0.5,
                        shift = {0.0, -0.5},
                        draw_as_shadow = true
                    }
                }
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-agriculture"},
    energy_usage = "10W",
    energy_source = {
        type = "void",
        emissions_per_minute = 1
    },
    working_sound = {
        -- memo: make sound files louder in the future
        sound = {filename = "__sosciencity-graphics__/sound/greenhouse-watering.ogg", volume = 3},
        apparent_volume = 1.5
    },
    fluid_boxes = {
        {
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {6.0, 4.0}}},
            production_type = "input"
        },
        {
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {8.0, 2.0}}},
            production_type = "input"
        }
    }
}:set_size(15, 7):copy_localisation_from_item()

Tirislib_Entity.create {
    type = "corpse",
    name = "farm-remnants",
    icon = "__sosciencity-graphics__/graphics/icon/farm.png",
    icon_size = 64,
    flags = {"placeable-neutral", "not-on-map"},
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    final_render_layer = "remnants",
    subgroup = "remnants",
    order = "dead-farm:(",
    remove_on_tile_placement = false,
    tile_width = 15,
    tile_height = 7,
    animation = {
        direction_count = 4,
        width = 544,
        height = 544,
        stripes = {
            {
                filename = "__sosciencity-graphics__/graphics/entity/farm/farm-north-remnants.png",
                width_in_frames = 1,
                height_in_frames = 1
            },
            {
                filename = "__sosciencity-graphics__/graphics/entity/farm/farm-east-remnants.png",
                width_in_frames = 1,
                height_in_frames = 1
            },
            {
                filename = "__sosciencity-graphics__/graphics/entity/farm/farm-south-remnants.png",
                width_in_frames = 1,
                height_in_frames = 1
            },
            {
                filename = "__sosciencity-graphics__/graphics/entity/farm/farm-west-remnants.png",
                width_in_frames = 1,
                height_in_frames = 1
            }
        },
        hr_version = {
            direction_count = 4,
            width = 1088,
            height = 1088,
            scale = 0.5,
            stripes = {
                {
                    filename = "__sosciencity-graphics__/graphics/entity/farm/farm-north-remnants-hr.png",
                    width_in_frames = 1,
                    height_in_frames = 1
                },
                {
                    filename = "__sosciencity-graphics__/graphics/entity/farm/farm-east-remnants-hr.png",
                    width_in_frames = 1,
                    height_in_frames = 1
                },
                {
                    filename = "__sosciencity-graphics__/graphics/entity/farm/farm-south-remnants-hr.png",
                    width_in_frames = 1,
                    height_in_frames = 1
                },
                {
                    filename = "__sosciencity-graphics__/graphics/entity/farm/farm-west-remnants-hr.png",
                    width_in_frames = 1,
                    height_in_frames = 1
                }
            }
        }
    }
}:set_size(15, 7):copy_localisation_from_item()
