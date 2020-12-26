Tirislib_Item.create {
    type = "item",
    name = "industrial-animal-farm",
    icon = "__sosciencity-graphics__/graphics/icon/industrial-animal-farm.png",
    icon_size = 64,
    subgroup = "sosciencity-fauna-buildings",
    order = "caa",
    place_result = "industrial-animal-farm",
    stack_size = 10,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib_RecipeGenerator.create {
    product = "industrial-animal-farm",
    themes = {{"silo", 2}, {"piping", 20}, {"building", 10}, {"machine", 5}, {"lamp", 40}},
    default_theme_level = 3,
    unlock = "animal-husbandry"
}

local pipe_pictures = Tirislib_Entity.get_standard_pipe_pictures {"south"}

Tirislib_Entity.create {
    type = "assembling-machine",
    name = "industrial-animal-farm",
    icon = "__sosciencity-graphics__/graphics/icon/industrial-animal-farm.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "industrial-animal-farm"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "consumption", "speed", "pollution"},
    animation = {
        north = {
            layers = {
                {
                    filename = "__sosciencity-graphics__/graphics/entity/industrial-animal-farm/industrial-animal-farm-north.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = 736,
                    height = 288,
                    shift = {0.5, -1.0},
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/industrial-animal-farm/industrial-animal-farm-north-hr.png",
                        frame_count = 1,
                        priority = "extra-high",
                        width = 1472,
                        height = 576,
                        scale = 0.5,
                        shift = {0.5, -1.0}
                    }
                },
                {
                    filename = "__sosciencity-graphics__/graphics/entity/industrial-animal-farm/industrial-animal-farm-north-shadowmap.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = 736,
                    height = 288,
                    shift = {0.5, -1.0},
                    draw_as_shadow = true,
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/industrial-animal-farm/industrial-animal-farm-north-shadowmap-hr.png",
                        frame_count = 1,
                        priority = "extra-high",
                        width = 1472,
                        height = 576,
                        scale = 0.5,
                        shift = {0.5, -1.0},
                        draw_as_shadow = true
                    }
                }
            }
        },
        east = {
            layers = {
                {
                    filename = "__sosciencity-graphics__/graphics/entity/industrial-animal-farm/industrial-animal-farm-east.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = 224,
                    height = 736,
                    shift = {0.0, -0.5},
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/industrial-animal-farm/industrial-animal-farm-east-hr.png",
                        frame_count = 1,
                        priority = "extra-high",
                        width = 448,
                        height = 1472,
                        scale = 0.5,
                        shift = {0.0, -0.5}
                    }
                },
                {
                    filename = "__sosciencity-graphics__/graphics/entity/industrial-animal-farm/industrial-animal-farm-east-shadowmap.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = 224,
                    height = 736,
                    shift = {0.0, -0.5},
                    draw_as_shadow = true,
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/industrial-animal-farm/industrial-animal-farm-east-shadowmap-hr.png",
                        frame_count = 1,
                        priority = "extra-high",
                        width = 448,
                        height = 1472,
                        scale = 0.5,
                        shift = {0.0, -0.5},
                        draw_as_shadow = true
                    }
                }
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-animal-farming"},
    energy_usage = "495kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 5,
        drain = "5kW"
    },
    fluid_boxes = {
        {
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {7.5, 3.0}}},
            production_type = "input"
        },
        {
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {7.5, -3.0}}},
            production_type = "input"
        },
        {
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-7.5, 3.0}}},
            production_type = "output"
        },
        {
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-7.5, -3.0}}},
            production_type = "output"
        },
        off_when_no_fluid_recipe = true
    }
}:set_size(20, 5):copy_localisation_from_item()
