-- TODO: actual graphics

Tirislib.Item.create {
    type = "item",
    name = "salt-pond",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    subgroup = "sosciencity-production-buildings",
    order = "daa",
    place_result = "salt-pond",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "salt-pond",
    themes = {{"piping", 5}, {"machine", 1}},
    default_theme_level = 1,
    unlock = "food-processing"
}

local pipe_covers = Tirislib.Entity.get_standard_pipe_cover()
local pipe_pictures = Tirislib.Entity.get_standard_pipe_pictures {"south"}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "salt-pond",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "salt-pond"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "speed"},
    animation = {
        filename = "__sosciencity-graphics__/graphics/entity/placeholder.png",
        priority = "high",
        width = 192,
        height = 192,
        scale = 0.5,
        frame_count = 1
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-salt-pond"},
    energy_usage = "10W",
    energy_source = {
        type = "void",
        emissions_per_minute = 0.25
    },
    fluid_boxes = {
        {
            base_level = -1,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {0, -2}}},
            production_type = "input"
        },
        {
            base_level = -1,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {0, 2}}},
            production_type = "input"
        }
    }
}:set_size(3, 3):copy_localisation_from_item()
