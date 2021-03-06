Tirislib_Item.create {
    type = "item",
    name = "fermentation-tank",
    icon = "__sosciencity-graphics__/graphics/icon/fermentation-tank.png",
    icon_size = 64,
    subgroup = "sosciencity-food-buildings",
    order = "aaa",
    place_result = "fermentation-tank",
    stack_size = 10,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib_RecipeGenerator.create {
    product = "fermentation-tank",
    themes = {{"piping", 10}, {"tank", 2}, {"machine", 1}},
    default_theme_level = 2
}

local sprite_height = 6
local sprite_width = 6
local pipe_covers = Tirislib_Entity.get_standard_pipe_cover()
local pipe_pictures = Tirislib_Entity.get_standard_pipe_pictures {"south"}

Tirislib_Entity.create {
    type = "assembling-machine",
    name = "fermentation-tank",
    icon = "__sosciencity-graphics__/graphics/icon/fermentation-tank.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "fermentation-tank"},
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
                    filename = "__sosciencity-graphics__/graphics/entity/fermentation-tank/fermentation-tank.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = sprite_width * 32,
                    height = sprite_height * 32,
                    shift = {0.0, 0.0},
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/fermentation-tank/fermentation-tank-hr.png",
                        frame_count = 1,
                        priority = "extra-high",
                        width = sprite_width * 64,
                        height = sprite_height * 64,
                        scale = 0.5,
                        shift = {0.0, 0.0}
                    }
                },
                {
                    filename = "__sosciencity-graphics__/graphics/entity/fermentation-tank/fermentation-tank-shadowmap.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = sprite_width * 32,
                    height = sprite_height * 32,
                    shift = {0.0, 0.0},
                    draw_as_shadow = true,
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/fermentation-tank/fermentation-tank-shadowmap-hr.png",
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
    crafting_categories = {"sosciencity-fermentation-tank"},
    energy_usage = "60kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 0.5,
        drain = "0kW"
    },
    fluid_boxes = {
        {
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-0.5, 2.5}}},
            production_type = "input"
        },
        {
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {0.5, -2.5}}},
            production_type = "output"
        }
    }
}:set_size(4, 4):copy_localisation_from_item()
