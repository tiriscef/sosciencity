Tirislib.Item.create {
    type = "item",
    name = "chemical-clarifier",
    icon = "__sosciencity-graphics__/graphics/icon/chemical-clarifier.png",
    icon_size = 64,
    subgroup = "sosciencity-water-buildings",
    order = "bac",
    place_result = "chemical-clarifier",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "chemical-clarifier",
    themes = {{"piping", 10}, {"tank", 2}, {"machine", 1}, {"pump", 5}},
    default_theme_level = 4,
    unlock = "drinking-water-treatment"
}

local sprite_height = 7
local sprite_width = 7
local pipe_covers = Tirislib.Entity.get_standard_pipe_cover()
local pipe_pictures = Tirislib.Entity.get_standard_pipe_pictures {"south"}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "chemical-clarifier",
    icon = "__sosciencity-graphics__/graphics/icon/chemical-clarifier.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "chemical-clarifier"},
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
                    filename = "__sosciencity-graphics__/graphics/entity/chemical-clarifier/chemical-clarifier-idle.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = sprite_width * 32,
                    height = sprite_height * 32,
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/chemical-clarifier/chemical-clarifier-idle-hr.png",
                        frame_count = 1,
                        priority = "extra-high",
                        width = sprite_width * 64,
                        height = sprite_height * 64,
                        scale = 0.5
                    }
                },
                {
                    filename = "__sosciencity-graphics__/graphics/entity/chemical-clarifier/chemical-clarifier-shadowmap.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = sprite_width * 32,
                    height = sprite_height * 32,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/chemical-clarifier/chemical-clarifier-shadowmap-hr.png",
                        frame_count = 1,
                        priority = "extra-high",
                        width = sprite_width * 64,
                        height = sprite_height * 64,
                        scale = 0.5,
                        draw_as_shadow = true
                    }
                }
            }
        }
    },
    working_visualisations = {
        {
            constant_speed = true,
            animation = {
                filename = "__sosciencity-graphics__/graphics/entity/chemical-clarifier/chemical-clarifier-sheet.png",
                frame_count = 60,
                priority = "extra-high",
                width = sprite_width * 32,
                height = sprite_height * 32,
                line_length = 2,
                animation_speed = 12 / 60,
                hr_version = {
                    filename = "__sosciencity-graphics__/graphics/entity/chemical-clarifier/chemical-clarifier-sheet-hr.png",
                    frame_count = 60,
                    priority = "extra-high",
                    width = sprite_width * 64,
                    height = sprite_height * 64,
                    scale = 0.5,
                    line_length = 4,
                    animation_speed = 12 / 60
                }
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-chemical-clarifier"},
    energy_usage = "60kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 0.5,
        drain = "10kW"
    },
    fluid_boxes = {
        {
            base_level = -1,
            height = 2,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-1, 3}}},
            production_type = "input"
        },
        {
            base_level = -1,
            height = 2,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-1, -3}}},
            production_type = "input"
        },
        {
            base_level = 1,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {1, 3}}},
            production_type = "output"
        },
        {
            base_level = 1,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {1, -3}}},
            production_type = "output"
        }
    }
}:set_size(5, 5):copy_localisation_from_item()
