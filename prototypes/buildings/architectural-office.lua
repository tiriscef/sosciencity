Tirislib_Item.create {
    type = "item",
    name = "architectural-office",
    icon = "__sosciencity-graphics__/graphics/icon/architectural-office.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "aaa",
    place_result = "architectural-office",
    stack_size = 10,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib_RecipeGenerator.create {
    product = "architectural-office",
    themes = {{"building", 5}, {"machine", 3}, {"lamp", 10}},
    default_theme_level = 1,
    unlock = "architecture-1",
    category = "sosciencity-architecture"
}

Tirislib_Entity.create {
    type = "assembling-machine",
    name = "architectural-office",
    icon = "__sosciencity-graphics__/graphics/icon/architectural-office.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "architectural-office"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "consumption", "speed", "pollution"},
    animation = {
        layers = {
            {
                filename = "__sosciencity-graphics__/graphics/entity/architectural-office/architectural-office.png",
                priority = "high",
                width = 224,
                height = 224,
                hr_version = {
                    filename = "__sosciencity-graphics__/graphics/entity/architectural-office/architectural-office-hr.png",
                    priority = "high",
                    width = 448,
                    height = 448,
                    scale = 0.5
                }
            },
            {
                filename = "__sosciencity-graphics__/graphics/entity/architectural-office/architectural-office-shadowmap.png",
                priority = "high",
                width = 224,
                height = 224,
                draw_as_shadow = true,
                hr_version = {
                    filename = "__sosciencity-graphics__/graphics/entity/architectural-office/architectural-office-shadowmap-hr.png",
                    priority = "high",
                    width = 448,
                    height = 448,
                    scale = 0.5,
                    draw_as_shadow = true
                }
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-architecture"},
    energy_usage = "95kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 0.25,
        drain = "5kW"
    }
}:set_size(5, 5):copy_localisation_from_item()
