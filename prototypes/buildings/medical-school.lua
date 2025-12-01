-- TODO: graphics, most everything

Tirislib.Item.create {
    type = "item",
    name = "medical-school",
    icon = Tirislib.Prototype.placeholder_icon,
    icon_size = 64,
    subgroup = "sosciencity-education-buildings",
    order = "aaa",
    place_result = "medical-school",
    stack_size = Sosciencity_Config.building_stacksize
}

Tirislib.RecipeGenerator.create {
    product = "medical-school",
    themes = {{"building", 1}},
    default_theme_level = 0,
    ingredients = {{type = "item", name = "architectural-concept", amount = 1}},
    unlock = "plasma-caste"
}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "medical-school",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "medical-school"},
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
                    filename = "__sosciencity-graphics__/graphics/plasma-caste.png",
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
    crafting_categories = {"sosciencity-medical-school"},
    energy_usage = "60kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = 0.15},
        drain = "0W"
    }
}:set_size(6, 6):copy_localisation_from_item():copy_icon_from_item()
