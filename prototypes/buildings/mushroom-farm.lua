Tirislib.Item.create {
    type = "item",
    name = "mushroom-farm",
    icon = "__sosciencity-graphics__/graphics/icon/mushroom-farm.png",
    icon_size = 64,
    subgroup = "sosciencity-microorganism-buildings",
    order = "daa",
    place_result = "mushroom-farm",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "mushroom-farm",
    themes = {{"piping", 30}, {"machine", 2}, {"soil", 30}},
    default_theme_level = 1,
    unlock = "mushroom-farming"
}

local pipe_covers = Tirislib.Entity.get_standard_pipe_cover()
local pipe_pictures = Tirislib.Entity.get_standard_pipe_pictures {"south"}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "mushroom-farm",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "mushroom-farm"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "speed"},
    animation = Tirislib.Entity.create_standard_picture {
        path = "__sosciencity-graphics__/graphics/entity/mushroom-farm/mushroom-farm",
        shift = {0.0, 0.5},
        width = 7,
        height = 6,
        shadowmap = true,
        glow = true
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-mushroom-farm"},
    energy_usage = "23kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = -2},
        drain = "2kW"
    },
    fluid_boxes = {
        {
            base_level = -1,
            height = 2,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {0.0, 3.0}}},
            production_type = "input"
        },
        {
            base_level = -1,
            height = 2,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {0.0, -3.0}}},
            production_type = "input"
        }
    },
    working_sound = {
        sound = {filename = "__sosciencity-graphics__/sound/greenhouse-watering.ogg", volume = 3},
        apparent_volume = 1.5
    }
}:set_size(5, 5):copy_localisation_from_item():copy_icon_from_item()
