Tirislib.Item.create {
    type = "item",
    name = "groundwater-pump",
    icon = "__sosciencity-graphics__/graphics/icon/groundwater-pump.png",
    icon_size = 64,
    subgroup = "sosciencity-water-buildings",
    order = "aaa",
    place_result = "groundwater-pump",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "groundwater-pump",
    themes = {{"boring", 1}, {"piping", 5}, {"machine", 1}},
    default_theme_level = 1,
    unlock = "infrastructure-1"
}

local pipe_pictures = Tirislib.Entity.get_standard_pipe_pictures {"south"}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "groundwater-pump",
    icon = "__sosciencity-graphics__/graphics/icon/groundwater-pump.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "groundwater-pump"},
    max_health = 400,
    corpse = "groundwater-pump-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    module_specification = {
        module_slots = 1
    },
    allowed_effects = {"productivity", "speed"}, -- try to disallow player craftable modules
    animation = {
        north = {
            layers = {
                {
                    filename = "__sosciencity-graphics__/graphics/entity/groundwater-pump/groundwater-pump.png",
                    width = 128,
                    height = 160,
                    frames = 1,
                    shift = {0.5, -1},
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/groundwater-pump/groundwater-pump-hr.png",
                        width = 256,
                        height = 320,
                        frames = 1,
                        shift = {0.5, -1},
                        scale = 0.5
                    }
                },
                {
                    filename = "__sosciencity-graphics__/graphics/entity/groundwater-pump/groundwater-pump-shadowmap.png",
                    width = 128,
                    height = 160,
                    frames = 1,
                    shift = {0.5, -1},
                    draw_as_shadow = true,
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/groundwater-pump/groundwater-pump-shadowmap-hr.png",
                        width = 256,
                        height = 320,
                        frames = 1,
                        shift = {0.5, -1},
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                }
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-groundwater-pump"},
    energy_usage = "250kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = 1},
        drain = "0W"
    },
    fluid_boxes = {
        {
            volume = 1000,
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {0, -2}, type = "output"}},
            production_type = "output"
        }
    }
}:set_size(3, 3):copy_localisation_from_item()

Tirislib.Entity.create {
    type = "corpse",
    name = "groundwater-pump-remnants",
    icon = "__sosciencity-graphics__/graphics/icon/groundwater-pump.png",
    icon_size = 64,
    flags = {"placeable-neutral", "not-on-map"},
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    final_render_layer = "remnants",
    subgroup = "remnants",
    order = "dead-groundwater-pump:(",
    remove_on_tile_placement = false,
    animation = {
        filename = "__sosciencity-graphics__/graphics/entity/groundwater-pump/groundwater-pump-remnants.png",
        direction_count = 1,
        width = 128,
        height = 160,
        shift = {0.5, -1},
        hr_version = {
            filename = "__sosciencity-graphics__/graphics/entity/groundwater-pump/groundwater-pump-remnants-hr.png",
            direction_count = 1,
            width = 256,
            height = 320,
            shift = {0.5, -1},
            scale = 0.5
        }
    },
    localised_name = {"item-name.groundwater-pump"}
}:set_size(3, 3)
