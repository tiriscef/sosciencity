Tirislib.Item.create {
    type = "item",
    name = "algae-farm",
    icon = "__sosciencity-graphics__/graphics/icon/algae-farm.png",
    icon_size = 64,
    subgroup = "sosciencity-microorganism-buildings",
    order = "daa",
    place_result = "algae-farm",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "algae-farm",
    themes = {{"piping", 30}, {"machine", 2}, {"glass", 30}},
    default_theme_level = 1,
    unlock = "algae-farming"
}
Sosciencity_Config.remove_quality_multipliers("algae-farm")

local pipe_covers = Tirislib.Entity.get_standard_pipe_cover()
local pipe_pictures = Tirislib.Entity.get_standard_pipe_pictures {"south", "north"}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "algae-farm",
    flags = {"placeable-neutral", "player-creation", "not-rotatable"},
    minable = {mining_time = 0.5, result = "algae-farm"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "speed"},
    graphics_set = {
        animation = Tirislib.Entity.create_standard_picture {
            path = "__sosciencity-graphics__/graphics/entity/algae-farm/algae-farm",
            center = {2.5, 3.0},
            width = 8,
            height = 5,
            scale = 1.5,
            shadowmap = true,
            glow = true,
            lightmap = true
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-algae-farm"},
    energy_usage = "20kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = -10},
        drain = "5kW"
    },
    fluid_boxes = {
        {
            volume = 1000,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {
                {position = {-3.0, -1.0}, flow_direction = "input", direction = defines.direction.north}
            },
            production_type = "input"
        },
        {
            volume = 1000,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {2.0, -1.0}, flow_direction = "input", direction = defines.direction.north}},
            production_type = "input"
        },
        {
            volume = 1000,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {
                {position = {3.0, -1.0}, flow_direction = "output", direction = defines.direction.north}
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
}:set_size(9, 3):copy_icon_from_item()
