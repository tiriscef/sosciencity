-- TODO: graphics, most everything

Tirislib.Item.create {
    type = "item",
    name = "huwanities-faculty",
    icon = Tirislib.Prototype.placeholder_icon,
    icon_size = 64,
    subgroup = "sosciencity-education-buildings",
    order = "aaa",
    place_result = "huwanities-faculty",
    stack_size = Sosciencity_Config.building_stacksize
}

Tirislib.RecipeGenerator.create {
    product = "huwanities-faculty",
    themes = {{"building", 1}},
    default_theme_level = 0,
    ingredients = {{type = "item", name = "architectural-concept", amount = 1}},
    unlock = "gleam-caste"
}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "huwanities-faculty",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "huwanities-faculty"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "consumption"},
    graphics_set = {
        animation = {
            layers = {
                {
                    filename = "__sosciencity-graphics__/graphics/placeholder.png",
                    priority = "high",
                    width = 224,
                    height = 224,
                    scale = 6/7
                },
                {
                    filename = "__sosciencity-graphics__/graphics/gleam-caste.png",
                    priority = "high",
                    width = 256,
                    height = 256,
                    scale = 0.5,
                    frame_count = 1
                }
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-huwanities-faculty"},
    energy_usage = "60kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = 0.15},
        drain = "0W"
    }
}:set_size(6, 6):copy_icon_from_item()
