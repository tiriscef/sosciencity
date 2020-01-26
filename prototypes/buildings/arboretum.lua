Tirislib_Item.create {
    type = "item",
    name = "arboretum",
    icon = "__sosciencity__/graphics/icon/note.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "aab",
    place_result = "arboretum",
    stack_size = 10
}

local recipe = Tirislib_RecipeGenerator.create_recipe("arboretum")
recipe:add_unlock() --TODO tech

local pipe_pictures = {
    north = Tirislib_Entity.get_empty_sprite(),
    east = Tirislib_Entity.get_empty_sprite(),
    south = Tirislib_Entity.get_south_pipe_picture(),
    west = Tirislib_Entity.get_empty_sprite()
}

Tirislib_Entity.create {
    type = "assembling-machine",
    name = "arboretum",
    icon = "__sosciencity__/graphics/icon/note.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "arboretum"},
    max_health = 400,
    corpse = "medium-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    module_specification = {
        module_slots = 2
    },
    allowed_effects = {"productivity", "consumption", "speed", "pollution"},
    animation = {
        layers = {
            {
                filename = "__sosciencity__/graphics/entity/arboretum/arboretum.png",
                frame_count = 1,
                priority = "extra-high",
                width = 544,
                height = 576,
                shift = {0.0, -0.5},
                hr_version = {
                    filename = "__sosciencity__/graphics/entity/arboretum/arboretum-hr.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = 1088,
                    height = 1152,
                    shift = {0.0, -0.5},
                    scale = 0.5
                }
            },
            {
                filename = "__sosciencity__/graphics/entity/arboretum/arboretum-shadowmap.png",
                frame_count = 1,
                priority = "extra-high",
                width = 544,
                height = 576,
                shift = {0.0, -0.5},
                draw_as_shadow = true,
                hr_version = {
                    filename = "__sosciencity__/graphics/entity/arboretum/arboretum-shadowmap-hr.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = 1088,
                    height = 1152,
                    shift = {0.0, -0.5},
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-arboretum"},
    energy_usage = "50kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 1,
        drain = "0W"
    },
    working_sound = {
        sound = {filename = "__sosciencity__/sound/chainsaw.ogg", volume = 2},
        apparent_volume = 1.5
    },
    fluid_boxes = {
        {
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {8.0, 0.0}}},
            production_type = "input"
        }
    }
}:set_size(15, 15):copy_localisation_from_item()
