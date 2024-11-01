Tirislib.Item.create {
    type = "item",
    name = "orchid-hq",
    icon = "__sosciencity-graphics__/graphics/icon/orchid-hq.png",
    icon_size = 64,
    subgroup = "sosciencity-hqs",
    order = "baa",
    place_result = "orchid-hq",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "orchid-hq",
    themes = {{"building", 10}, {"soil", 50}},
    default_theme_level = 1,
    ingredients = {{type = "item", name = "architectural-concept", amount = 1}},
    unlock = "orchid-caste"
}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "orchid-hq",
    flags = {"placeable-neutral", "player-creation", "not-rotatable"},
    minable = {mining_time = 0.5, result = "orchid-hq"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "speed"},
    animation = {
        layers = {
            {
                filename = "__sosciencity-graphics__/graphics/entity/orchid-hq/orchid-hq-lr.png",
                frame_count = 1,
                height = 672,
                hr_version = {
                    filename = "__sosciencity-graphics__/graphics/entity/orchid-hq/orchid-hq.png",
                    frame_count = 1,
                    height = 1344,
                    priority = "high",
                    scale = 0.5,
                    shift = {6.75, -5.0},
                    width = 2304
                },
                priority = "high",
                shift = {6.75, -5.0},
                width = 1152
            },
            {
                draw_as_shadow = true,
                filename = "__sosciencity-graphics__/graphics/entity/orchid-hq/orchid-hq-shadowmap-lr.png",
                frame_count = 1,
                height = 672,
                hr_version = {
                    draw_as_shadow = true,
                    filename = "__sosciencity-graphics__/graphics/entity/orchid-hq/orchid-hq-shadowmap.png",
                    frame_count = 1,
                    height = 1344,
                    priority = "high",
                    scale = 0.5,
                    shift = {6.25, -5.5},
                    width = 2304
                },
                priority = "high",
                shift = {6.25, -5.5},
                width = 1152
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-caste-orchid"},
    energy_usage = "190kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = 0.25},
        drain = "10kW"
    }
}:set_size(11, 8):copy_localisation_from_item():copy_icon_from_item()
