Tirislib.Item.create {
    type = "item",
    name = "electric-water-heater",
    icon = "__sosciencity-graphics__/graphics/icon/electric-water-heater.png",
    icon_size = 64,
    subgroup = "sosciencity-water-buildings",
    order = "abb",
    place_result = "electric-water-heater",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "electric-water-heater",
    ingredients = {
        {type = "item", name = "burner-water-heater", amount = 1}
    },
    themes = {{"plating", 10}, {"piping", 10}, {"wiring", 10}},
    unlock = "infrastructure-3",
    default_theme_level = 3
}

local pipe_covers = Tirislib.Entity.get_standard_pipe_cover()
local pipe_pictures = Tirislib.Entity.get_standard_pipe_pictures {"south"}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "electric-water-heater",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "electric-water-heater"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "consumption"},
    graphics_set = {
        animation = Tirislib.Entity.create_standard_picture {
            path = "__sosciencity-graphics__/graphics/entity/electric-water-heater/electric-water-heater",
            center = {2.5, 2.5},
            width = 6,
            height = 5,
            shadowmap = true,
            glow = true
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-water-heater"},
    energy_usage = "1200kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = 0.15},
        drain = "0W"
    },
    fluid_boxes = {
        {
            volume = 2000,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {1, 0}, direction = defines.direction.east}},
            production_type = "input"
        },
        {
            volume = 2000,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-1, 0}, direction = defines.direction.west}},
            production_type = "input"
        },
        {
            volume = 2000,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {0, -1}, direction = defines.direction.north}},
            production_type = "output"
        }
    }
}:set_size(3, 3):copy_icon_from_item()
