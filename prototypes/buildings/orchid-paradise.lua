Tirislib_Item.create {
    type = "item",
    name = "orchid-paradise",
    icon = "__sosciencity-graphics__/graphics/icon/orchid-paradise.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "aaa",
    place_result = "orchid-paradise",
    stack_size = 10,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib_RecipeGenerator.create {
    product = "orchid-paradise",
    themes = {{"building", 10, 2}, {"lamp", 40, 2}, {"window", 30, 2}},
    category = "sosciencity-architecture"
}

Tirislib_Entity.create {
    type = "assembling-machine",
    name = "orchid-paradise",
    icon = "__sosciencity-graphics__/graphics/icon/orchid-paradise.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "orchid-paradise"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "consumption", "speed", "pollution"},
    animation = {
        north = {
            layers = {
                {
                    filename = "__sosciencity-graphics__/graphics/entity/orchid-paradise/orchid-paradise.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = 224,
                    height = 256,
                    shift = {0.0, -0.5},
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/orchid-paradise/orchid-paradise-hr.png",
                        frame_count = 1,
                        priority = "extra-high",
                        width = 448,
                        height = 512,
                        scale = 0.5,
                        shift = {0.0, -0.5}
                    }
                },
                {
                    filename = "__sosciencity-graphics__/graphics/entity/orchid-paradise/orchid-paradise-shadowmap.png",
                    frame_count = 1,
                    priority = "extra-high",
                    width = 224,
                    height = 256,
                    shift = {0.0, -0.5},
                    draw_as_shadow = true,
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/orchid-paradise/orchid-paradise-shadowmap-hr.png",
                        frame_count = 1,
                        priority = "extra-high",
                        width = 448,
                        height = 512,
                        scale = 0.5,
                        shift = {0.0, -0.5},
                        draw_as_shadow = true
                    }
                }
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-caste-orchid"},
    energy_usage = "75kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 0.5,
        drain = "25kW"
    }
}:set_size(5, 5):copy_localisation_from_item()
