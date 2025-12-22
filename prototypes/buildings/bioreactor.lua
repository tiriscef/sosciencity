Tirislib.Item.create {
    type = "item",
    name = "sosciencity-bioreactor",
    icon = "__sosciencity-graphics__/graphics/icon/bioreactor.png",
    icon_size = 64,
    subgroup = "sosciencity-microorganism-buildings",
    order = "daa",
    place_result = "sosciencity-bioreactor",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "sosciencity-bioreactor",
    themes = {{"machine", 2}, {"piping", 20}, {"tank", 3}},
    default_theme_level = 2,
    unlock = "basic-biotechnology"
}

local pipe_covers = Tirislib.Entity.get_standard_pipe_cover()
local pipe_pictures = Tirislib.Entity.get_standard_pipe_pictures {"south"}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "sosciencity-bioreactor",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "sosciencity-bioreactor"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "speed"},
    graphics_set = {
        animation = Tirislib.Entity.create_standard_picture {
            path = "__sosciencity-graphics__/graphics/entity/bioreactor/bioreactor",
            width = 15,
            height = 11,
            shift = {2.0, 0.0},
            shadowmap = true,
            glow = true
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-bioreactor"},
    energy_usage = "100kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = 0.15},
        drain = "0kW"
    },
    fluid_boxes = {
        {
            volume = 1000,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-1.0, 4.0}, flow_direction = "input", direction = defines.direction.south}},
            production_type = "input"
        },
        {
            volume = 1000,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {0.0, 4.0}, flow_direction = "input", direction = defines.direction.south}},
            production_type = "input"
        },
        {
            volume = 1000,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {1.0, 4.0}, flow_direction = "input", direction = defines.direction.south}},
            production_type = "input"
        },
        {
            volume = 1000,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {
                {position = {-1.0, -4.0}, flow_direction = "output", direction = defines.direction.north}
            },
            production_type = "output"
        },
        {
            volume = 1000,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {
                {position = {0.0, -4.0}, flow_direction = "output", direction = defines.direction.north}
            },
            production_type = "output"
        },
        {
            volume = 1000,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {
                {position = {1.0, -4.0}, flow_direction = "output", direction = defines.direction.north}
            },
            production_type = "output"
        }
    },
    working_sound = {
        sound = {
            {
                filename = "__base__/sound/chemical-plant-1.ogg",
                volume = 0.5
            },
            {
                filename = "__base__/sound/chemical-plant-2.ogg",
                volume = 0.5
            },
            {
                filename = "__base__/sound/chemical-plant-3.ogg",
                volume = 0.5
            }
        },
        apparent_volume = 1.5,
        fade_in_ticks = 4,
        fade_out_ticks = 20
    }
}:set_size(9, 9):copy_icon_from_item()
