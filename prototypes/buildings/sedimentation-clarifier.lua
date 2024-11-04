Tirislib.Item.create {
    type = "item",
    name = "sedimentation-clarifier",
    icon = "__sosciencity-graphics__/graphics/icon/sedimentation-clarifier.png",
    icon_size = 64,
    subgroup = "sosciencity-water-buildings",
    order = "baa",
    place_result = "sedimentation-clarifier",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "sedimentation-clarifier",
    themes = {{"piping", 30}, {"tank", 3}, {"machine", 1}, {"pump", 5}},
    default_theme_level = 4,
    unlock = "drinking-water-treatment"
}

local sprite_height = 9
local sprite_width = 9
local pipe_covers = Tirislib.Entity.get_standard_pipe_cover()
local pipe_pictures = Tirislib.Entity.get_standard_pipe_pictures {"south"}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "sedimentation-clarifier",
    icon = "__sosciencity-graphics__/graphics/icon/sedimentation-clarifier.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "sedimentation-clarifier"},
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
                    filename = "__sosciencity-graphics__/graphics/entity/sedimentation-clarifier/sedimentation-clarifier-idle-hr.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = sprite_width * 64,
                    height = sprite_height * 64,
                    scale = 0.5
                },
                {
                    filename = "__sosciencity-graphics__/graphics/entity/sedimentation-clarifier/sedimentation-clarifier-shadowmap-hr.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = sprite_width * 64,
                    height = sprite_height * 64,
                    scale = 0.5,
                    draw_as_shadow = true
                }
            }
        }
    },
    working_visualisations = {
        {
            constant_speed = true,
            animation = {
                filename = "__sosciencity-graphics__/graphics/entity/sedimentation-clarifier/sedimentation-clarifier-sheet-hr.png",
                frame_count = 60,
                priority = "extra-high",
                width = sprite_width * 64,
                height = sprite_height * 64,
                scale = 0.5,
                line_length = 7,
                animation_speed = 12 / 60
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-sedimentation-clarifier"},
    energy_usage = "200kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = 0.5},
        drain = "0kW"
    },
    fluid_boxes = {
        {
            volume = 2000,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-2, 3}, direction = defines.direction.south}},
            production_type = "input"
        },
        {
            volume = 2000,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-2, -3}, direction = defines.direction.north}},
            production_type = "input"
        },
        {
            volume = 2000,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {2, 3}, direction = defines.direction.south}},
            production_type = "output"
        },
        {
            volume = 2000,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {2, -3}, direction = defines.direction.north}},
            production_type = "output"
        }
    }
}:set_size(7, 7):copy_localisation_from_item()
