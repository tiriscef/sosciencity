Tirislib.Item.create {
    type = "item",
    name = "foundry-hq",
    icon = "__sosciencity-graphics__/graphics/icon/foundry-hq.png",
    icon_size = 64,
    subgroup = "sosciencity-hqs",
    order = "eaa",
    place_result = "foundry-hq",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "foundry-hq",
    themes = {{"building", 20}},
    default_theme_level = 3,
    ingredients = {{type = "item", name = "architectural-concept", amount = 1}},
    unlock = "foundry-caste"
}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "foundry-hq",
    flags = {"placeable-neutral", "player-creation", "not-rotatable"},
    minable = {mining_time = 0.5, result = "foundry-hq"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "speed"},
    animation = Tirislib.Entity.create_standard_picture {
        path = "__sosciencity-graphics__/graphics/entity/foundry-hq/foundry-hq",
        width = 25,
        height = 17,
        center = {9.0, 8.0},
        shadowmap = true,
        lightmap = true,
        glow = true
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-caste-foundry"},
    energy_usage = "190kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = 0.25},
        drain = "10kW"
    }
}:set_size(16, 12):copy_localisation_from_item():copy_icon_from_item()
