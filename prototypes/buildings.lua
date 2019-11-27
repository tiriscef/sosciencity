Item.create {
    type = "item",
    name = "automatic-greenhouse",
    icon = "__sosciencity__/graphics/icon/automatic-greenhouse.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "aab",
    place_result = "automatic-greenhouse",
    stack_size = 10
}

Entity.create {
    type = "assembling-machine",
    name = "automatic-greenhouse",
    icon = "__sosciencity__/graphics/icon/automatic-greenhouse.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "automatic-greenhouse"},
    max_health = 400,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    collision_box = Entity.get_collision_box(6, 9),
    selection_box = Entity.get_selection_box(6, 9),
    module_specification = {
        module_slots = 2
    },
    allowed_effects = {"productivity", "consumption", "speed", "pollution"},
    animation = {
        layers = {
            {
                filename = "__sosciencity__/graphics/entity/automatic-greenhouse.png",
                frame_count = 1,
                priority = "high",
                width = 640,
                height = 448,
                scale = 0.5,
                shift = {0.5, -0.5}
            },
            {
                filename = "__sosciencity__/graphics/entity/automatic-greenhouse-shadowmap.png",
                frame_count = 1,
                priority = "high",
                width = 640,
                height = 448,
                scale = 0.5,
                shift = {0.5, -0.5},
                draw_as_shadow = true
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-greenhouse"},
    energy_usage = "100kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 1
    },
    working_sound = {
        sound = {filename = "__sosciencity__/sound/greenhouse-watering.ogg", volume = 0.6},
        apparent_volume = 1.5
    }
}
