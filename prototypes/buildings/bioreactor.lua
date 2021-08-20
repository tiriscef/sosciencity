Tirislib_Item.create {
    type = "item",
    name = "sosciencity-bioreactor",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    subgroup = "sosciencity-food-buildings",
    order = "daa",
    place_result = "sosciencity-bioreactor",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib_RecipeGenerator.create {
    product = "sosciencity-bioreactor",
    themes = {{"machine", 2}, {"piping", 20}, {"tank", 3}},
    default_theme_level = 2,
    unlock = "basic-biotechnology"
}

local pipe_covers = Tirislib_Entity.get_standard_pipe_cover()
local pipe_pictures = Tirislib_Entity.get_standard_pipe_pictures {"south"}

Tirislib_Entity.create {
    type = "assembling-machine",
    name = "sosciencity-bioreactor",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "sosciencity-bioreactor"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "speed"},
    animation = Tirislib_Entity.create_standard_picture{
        path = "__sosciencity-graphics__/graphics/entity/bioreactor/bioreactor",
        width = 12,
        height = 8,
        shift = {1.5, 0.5},
        shadowmap = true,
        glow = true
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-bioreactor"},
    energy_usage = "100kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 0.15,
        drain = "0kW"
    },
    fluid_boxes = {
        {
            base_level = -1,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-1.0, 4.0}}},
            production_type = "input"
        },
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
            pipe_connections = {{position = {1.0, 4.0}}},
            production_type = "input"
        },
        {
            base_level = 1,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-1.0, -4.0}}},
            production_type = "output"
        },
        {
            base_level = 1,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {0.0, -4.0}}},
            production_type = "output"
        },
        {
            base_level = 1,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {1.0, -4.0}}},
            production_type = "output"
        }
    }
}:set_size(7, 7):copy_localisation_from_item()
