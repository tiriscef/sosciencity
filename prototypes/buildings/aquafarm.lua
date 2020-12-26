Tirislib_Item.create {
    type = "item",
    name = "aquafarm",
    icon = "__sosciencity-graphics__/graphics/icon/aquafarm.png",
    icon_size = 64,
    subgroup = "sosciencity-fauna-buildings",
    order = "cac",
    place_result = "aquafarm",
    stack_size = 10,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib_RecipeGenerator.create {
    product = "aquafarm",
    themes = {{"tank", 2}, {"piping", 50}, {"building", 3}, {"machine", 5}, {"lamp", 20}},
    default_theme_level = 3,
    unlock = "animal-husbandry"
}

local sprite_height = 14
local sprite_width = 12
local pipe_pictures = Tirislib_Entity.get_standard_pipe_pictures {"south"}

Tirislib_Entity.create {
    type = "assembling-machine",
    name = "aquafarm",
    icon = "__sosciencity-graphics__/graphics/icon/aquafarm.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "aquafarm"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "consumption", "speed", "pollution"},
    animation = {
        layers = {
            {
                filename = "__sosciencity-graphics__/graphics/entity/aquafarm/aquafarm-sheet.png",
                frame_count = 1,
                width = sprite_width * 32,
                height = sprite_height * 32,
                shift = {0.0, -1.0},
                hr_version = {
                    filename = "__sosciencity-graphics__/graphics/entity/aquafarm/aquafarm-sheet-hr.png",
                    frame_count = 1,
                    width = sprite_width * 64,
                    height = sprite_height * 64,
                    scale = 0.5,
                    shift = {0.0, -1.0}
                }
            },
            {
                filename = "__sosciencity-graphics__/graphics/entity/aquafarm/aquafarm-shadowmap.png",
                frame_count = 1,
                width = sprite_width * 32,
                height = sprite_height * 32,
                shift = {0.0, -1.0},
                draw_as_shadow = true,
                hr_version = {
                    filename = "__sosciencity-graphics__/graphics/entity/aquafarm/aquafarm-shadowmap-hr.png",
                    frame_count = 1,
                    width = sprite_width * 64,
                    height = sprite_height * 64,
                    scale = 0.5,
                    shift = {0.0, -1.0},
                    draw_as_shadow = true
                }
            }
        }
    },
    working_visualisations = {
        {
            always_draw = true,
            constant_speed = true,
            animation = {
                filename = "__sosciencity-graphics__/graphics/entity/aquafarm/aquafarm-sheet.png",
                frame_count = 60,
                priority = "extra-high",
                width = sprite_width * 32,
                height = sprite_height * 32,
                shift = {0.0, -1.0},
                line_length = 20,
                animation_speed = 12 / 60,
                hr_version = {
                    filename = "__sosciencity-graphics__/graphics/entity/aquafarm/aquafarm-sheet-hr.png",
                    frame_count = 60,
                    priority = "extra-high",
                    width = sprite_width * 64,
                    height = sprite_height * 64,
                    scale = 0.5,
                    shift = {0.0, -1.0},
                    line_length = 10,
                    animation_speed = 12 / 60
                }
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-water-agriculture", "sosciencity-water-animal-farming"},
    energy_usage = "395kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 4,
        drain = "5kW"
    },
    fluid_boxes = {
        {
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {1.5, 5.5}}},
            production_type = "input"
        },
        {
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {3.5, 5.5}}},
            production_type = "input"
        },
        {
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {1.5, -5.5}}},
            production_type = "output"
        },
        {
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {3.5, -5.5}}},
            production_type = "output"
        },
        off_when_no_fluid_recipe = true
    }
}:set_size(10, 10):copy_localisation_from_item()
