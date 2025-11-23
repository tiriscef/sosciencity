Tirislib.Item.create {
    type = "item",
    name = "burner-water-heater",
    icon = "__sosciencity-graphics__/graphics/icon/burner-water-heater.png",
    icon_size = 64,
    subgroup = "sosciencity-water-buildings",
    order = "aba",
    place_result = "burner-water-heater",
    stack_size = Sosciencity_Config.building_stacksize
}

Tirislib.RecipeGenerator.create {
    product = "burner-water-heater",
    themes = {{"plating", 10}, {"piping", 10}, {"furnace", 2}},
    unlock = "infrastructure-1"
}

local pipe_covers = Tirislib.Entity.get_standard_pipe_cover()
local pipe_pictures = Tirislib.Entity.get_standard_pipe_pictures {"south"}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "burner-water-heater",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "burner-water-heater"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "consumption"},
    graphics_set = {
        animation = Tirislib.Entity.create_standard_picture {
            path = "__sosciencity-graphics__/graphics/entity/burner-water-heater/burner-water-heater",
            center = {3.5, 3.5},
            width = 9,
            height = 8,
            shadowmap = true,
            glow = true,
            lightmap = true
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-water-heater"},
    energy_usage = "1800kW",
    energy_source = {
        type = "burner",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = 1},
        fuel_inventory_size = 1,
        smoke = {
            {
                name = "smoke",
                deviation = {0.1, 0.1},
                frequency = 10,
                position = {-2.1, 1.2},
                starting_vertical_speed = 0.03,
                starting_frame_deviation = 60
            },
            {
                name = "smoke",
                deviation = {0.1, 0.1},
                frequency = 10,
                position = {-2.1, -1.2},
                starting_vertical_speed = 0.03,
                starting_frame_deviation = 60
            }
        }
    },
    fluid_boxes = {
        {
            volume = 2000,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {2, 0}, direction = defines.direction.east}},
            production_type = "input"
        },
        {
            volume = 2000,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-2, 0}, direction = defines.direction.west}},
            production_type = "input"
        },
        {
            volume = 2000,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {0, -2}, direction = defines.direction.north}},
            production_type = "output"
        }
    }
}:set_size(5, 5):copy_localisation_from_item():copy_icon_from_item()
