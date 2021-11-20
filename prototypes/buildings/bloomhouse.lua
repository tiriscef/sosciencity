Tirislib_Item.create {
    type = "item",
    name = "bloomhouse",
    icon = "__sosciencity-graphics__/graphics/icon/bloomhouse.png",
    icon_size = 64,
    subgroup = "sosciencity-flora-buildings",
    order = "bab",
    place_result = "bloomhouse",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib_RecipeGenerator.create {
    product = "bloomhouse",
    themes = {{"piping", 20}, {"soil", 50}, {"machine", 2}},
    ingredients = {
        {type = "item", name = "window", amount = 20},
        {type = "item", name = "architectural-concept", amount = 1}
    },
    default_theme_level = 2,
    unlock = "indoor-growing"
}

local height = 7
local width = 7
local sprite_height = height + 2
local sprite_width = width + 2
local pipe_covers = Tirislib_Entity.get_standard_pipe_cover()
local pipe_pictures = Tirislib_Entity.get_standard_pipe_pictures {"south"}

Tirislib_Entity.create {
    type = "assembling-machine",
    name = "bloomhouse",
    icon = "__sosciencity-graphics__/graphics/icon/bloomhouse.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "bloomhouse"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "speed"},
    animation = {
        north = {
            layers = {
                {
                    filename = "__sosciencity-graphics__/graphics/entity/bloomhouse/bloomhouse.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = sprite_width * 32,
                    height = sprite_height * 32,
                    shift = {0.0, 0.0},
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/bloomhouse/bloomhouse-hr.png",
                        frame_count = 1,
                        priority = "extra-high",
                        width = sprite_width * 64,
                        height = sprite_height * 64,
                        scale = 0.5,
                        shift = {0.0, 0.0}
                    }
                },
                {
                    filename = "__sosciencity-graphics__/graphics/entity/bloomhouse/bloomhouse-shadowmap.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = sprite_width * 32,
                    height = sprite_height * 32,
                    shift = {0.0, 0.0},
                    draw_as_shadow = true,
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/bloomhouse/bloomhouse-shadowmap-hr.png",
                        frame_count = 1,
                        priority = "extra-high",
                        width = sprite_width * 64,
                        height = sprite_height * 64,
                        scale = 0.5,
                        shift = {0.0, 0.0},
                        draw_as_shadow = true
                    }
                }
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-bloomhouse-annual", "sosciencity-bloomhouse-perennial"},
    energy_usage = "95kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = Sosciencity_Config.agriculture_pollutes and 1 or -5,
        drain = "5kW"
    },
    fluid_boxes = {
        {
            base_level = -1,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {0.0, 4.0}}},
            production_type = "input"
        },
        {
            base_level = -1,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {0.0, -4.0}}},
            production_type = "input"
        },
        {
            base_level = 1,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {4.0, 0.0}}},
            production_type = "output"
        },
        {
            base_level = 1,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-4.0, 0.0}}},
            production_type = "output"
        }
    },
    working_sound = {
        sound = {filename = "__sosciencity-graphics__/sound/greenhouse-watering.ogg", volume = 3},
        apparent_volume = 1.5
    }
}:set_size(width, height):copy_localisation_from_item()
