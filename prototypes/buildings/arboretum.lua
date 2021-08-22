Tirislib_Item.create {
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

Tirislib_RecipeGenerator.create {
    product = "arboretum",
    themes = {{"soil", 20}, {"tank", 1}, {"piping", 10}},
    default_theme_level = 0,
    unlock = "open-environment-farming"
}

local pipe_pictures = Tirislib_Entity.get_standard_pipe_pictures {"south"}
local pipe_covers = Tirislib_Entity.get_standard_pipe_cover {"south"}

Tirislib_Entity.create {
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
        module_slots = 2
    },
    allowed_effects = {"productivity", "consumption", "speed", "pollution"},
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
    energy_usage = "50kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 1,
        drain = "0W"
    },
    working_sound = {
        sound = {filename = "__sosciencity-graphics__/sound/chainsaw.ogg", volume = 3},
        apparent_volume = 1.5
    },
    fluid_boxes = {
        {
            base_level = -1,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {8.0, 0.0}}},
            production_type = "input"
        },
        {
            base_level = -1,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-8.0, 0.0}}},
            production_type = "input"
        },
        {
            base_level = 1,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {0.0, 8.0}}},
            production_type = "output"
        },
        {
            base_level = 1,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {0.0, -8.0}}},
            production_type = "output"
        },
        off_when_no_fluid_recipe = true
    }
}:set_size(15, 15):copy_localisation_from_item()

Tirislib_Entity.create {
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
