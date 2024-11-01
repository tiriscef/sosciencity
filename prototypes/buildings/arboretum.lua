Tirislib.Item.create {
    type = "item",
    name = "arboretum",
    icon = "__sosciencity-graphics__/graphics/icon/arboretum.png",
    icon_size = 64,
    subgroup = "sosciencity-flora-buildings",
    order = "aab",
    place_result = "arboretum",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "arboretum",
    themes = {{"soil", 20}, {"tank", 1}, {"piping", 10}},
    default_theme_level = 0,
    unlock = "open-environment-farming"
}

local pipe_pictures = Tirislib.Entity.get_standard_pipe_pictures {"south"}
local pipe_covers = Tirislib.Entity.get_standard_pipe_cover {"south"}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "arboretum",
    icon = "__sosciencity-graphics__/graphics/icon/arboretum.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "arboretum"},
    max_health = 400,
    corpse = "arboretum-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    module_specification = {
        module_slots = 3
    },
    allowed_effects = {"productivity", "speed"},
    animation = {
        layers = {
            {
                filename = "__sosciencity-graphics__/graphics/entity/arboretum/arboretum.png",
                frame_count = 1,
                priority = "extra-high",
                width = 544,
                height = 576,
                shift = {0.0, -0.5},
                hr_version = {
                    filename = "__sosciencity-graphics__/graphics/entity/arboretum/arboretum-hr.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = 1088,
                    height = 1152,
                    shift = {0.0, -0.5},
                    scale = 0.5
                }
            },
            {
                filename = "__sosciencity-graphics__/graphics/entity/arboretum/arboretum-shadowmap.png",
                frame_count = 1,
                priority = "extra-high",
                width = 544,
                height = 576,
                shift = {0.0, -0.5},
                draw_as_shadow = true,
                hr_version = {
                    filename = "__sosciencity-graphics__/graphics/entity/arboretum/arboretum-shadowmap-hr.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = 1088,
                    height = 1152,
                    shift = {0.0, -0.5},
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-farming-perennial"},
    energy_usage = "10W",
    energy_source = {
        type = "void",
        emissions_per_minute = Sosciencity_Config.agriculture_pollutes and 1 or -5
    },
    working_sound = {
        sound = {
            {
                filename = "__sosciencity-graphics__/sound/chainsaw.ogg",
                volume = 0.5
            },
            {
                filename = "__sosciencity-graphics__/sound/greenhouse-watering.ogg",
                volume = 3
            }
        },
        apparent_volume = 1.5,
        probability = 1 / (60 * 60) -- average 60 seconds between sounds
    },
    fluid_boxes = {
        {
            volume = 1000,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {8.0, 0.0}}},
            production_type = "input"
        },
        {
            volume = 1000,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-8.0, 0.0}}},
            production_type = "input"
        },
        {
            volume = 1000,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {0.0, 8.0}, type = "output"}},
            production_type = "output"
        },
        {
            volume = 1000,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {0.0, -8.0}, type = "output"}},
            production_type = "output"
        }
    },
    off_when_no_fluid_recipe = true
}:set_size(15, 15):copy_localisation_from_item()

Tirislib.Entity.create {
    type = "corpse",
    name = "arboretum-remnants",
    icon = "__sosciencity-graphics__/graphics/icon/arboretum.png",
    icon_size = 64,
    flags = {"placeable-neutral", "not-on-map"},
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    final_render_layer = "remnants",
    subgroup = "remnants",
    order = "dead-arboretum:(",
    remove_on_tile_placement = false,
    tile_width = 15,
    tile_height = 7,
    animation = {
        filename = "__sosciencity-graphics__/graphics/entity/arboretum/arboretum-remnants.png",
        direction_count = 1,
        width = 544,
        height = 576,
        shift = {0.0, -1.0},
        hr_version = {
            filename = "__sosciencity-graphics__/graphics/entity/arboretum/arboretum-remnants-hr.png",
            direction_count = 1,
            width = 1088,
            height = 1152,
            shift = {0.0, -1.0},
            scale = 0.5
        }
    },
    localised_name = {"item-name.arboretum"}
}:set_size(15, 15)
