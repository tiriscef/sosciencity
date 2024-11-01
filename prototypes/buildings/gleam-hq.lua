-- TODO: actual graphics

Tirislib.Item.create {
    type = "item",
    name = "gleam-hq",
    icon = "__sosciencity-graphics__/graphics/gleam-caste.png",
    icon_size = 256,
    subgroup = "sosciencity-hqs",
    order = "faa",
    place_result = "gleam-hq",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "gleam-hq",
    themes = {{"building", 30}},
    default_theme_level = 4,
    ingredients = {{type = "item", name = "architectural-concept", amount = 1}},
    unlock = "gleam-caste"
}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "gleam-hq",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "gleam-hq"},
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
                filename = "__sosciencity-graphics__/graphics/placeholder.png",
                priority = "high",
                width = 224,
                height = 224,
                scale = 1,
                frame_count = 1
            },
            {
                filename = "__sosciencity-graphics__/graphics/gleam-caste.png",
                priority = "high",
                width = 256,
                height = 256,
                scale = 0.8,
                frame_count = 1
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-caste-gleam"},
    energy_usage = "190kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = 0.25},
        drain = "10kW"
    }
}:set_size(7, 7):copy_localisation_from_item():copy_icon_from_item()
