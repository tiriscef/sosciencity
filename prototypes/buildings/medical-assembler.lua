Tirislib.Item.create {
    type = "item",
    name = "medical-assembler",
    icon = "__sosciencity-graphics__/graphics/icon/medical-assembler.png",
    icon_size = 64,
    subgroup = "sosciencity-production-buildings",
    order = "waa",
    place_result = "medical-assembler",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "medical-assembler",
    themes = {{"machine", 2}, {"glass", 10}},
    default_theme_level = 1,
    unlock = "medbay"
}

local pipe_covers = Tirislib.Entity.get_standard_pipe_cover()
local pipe_pictures = Tirislib.Entity.get_standard_pipe_pictures {"south"}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "medical-assembler",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "medical-assembler"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    module_specification = {
        module_slots = 4
    },
    allowed_effects = {"productivity", "consumption", "speed", "pollution"},
    animation = Tirislib.Entity.create_standard_picture {
        path = "__sosciencity-graphics__/graphics/entity/medical-assembler/medical-assembler",
        center = {3.0, 3.0},
        width = 7,
        height = 6,
        shadowmap = true
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-pharma"},
    energy_usage = "190kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = -2,
        drain = "10kW"
    },
    working_sound = {
        sound = {
            {
                filename = "__base__/sound/assembling-machine-t1-1.ogg",
                volume = 0.4
            }
        },
        audible_distance_modifier = 0.5,
        fade_in_ticks = 4,
        fade_out_ticks = 20
    },
    fluid_boxes = {
        {
            base_level = -1,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {0.5, 2.5}}},
            production_type = "input"
        },
        {
            base_level = -1,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-0.5, 2.5}}},
            production_type = "input"
        },
        {
            base_level = -1,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {0.5, -2.5}}},
            production_type = "input"
        },
        {
            base_level = -1,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-0.5, -2.5}}},
            production_type = "input"
        },
        off_when_no_fluid_recipe = true
    }
}:set_size(4, 4):copy_localisation_from_item():copy_icon_from_item()
