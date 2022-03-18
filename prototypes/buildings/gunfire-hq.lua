Tirislib.Item.create {
    type = "item",
    name = "gunfire-hq",
    icon = "__sosciencity-graphics__/graphics/icon/gunfire-hq.png",
    icon_size = 64,
    subgroup = "sosciencity-hqs",
    order = "caa",
    place_result = "gunfire-hq",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "gunfire-hq",
    themes = {{"building", 20}, {"housing_sheltered", 20}, {"gun_turret", 4}},
    default_theme_level = 2,
    ingredients = {{type = "item", name = "architectural-concept", amount = 1}},
    unlock = "gunfire-caste"
}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "gunfire-hq",
    flags = {"placeable-neutral", "player-creation", "not-rotatable"},
    minable = {mining_time = 0.5, result = "gunfire-hq"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "speed"},
    animation = Tirislib.Entity.create_standard_picture {
        path = "__sosciencity-graphics__/graphics/entity/gunfire-hq/gunfire-hq",
        shift = {1.5, 0.0},
        width = 20,
        height = 14,
        shadowmap = true,
        glow = true,
        lightmap = true
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-caste-gunfire"},
    energy_usage = "190kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 0.25,
        drain = "10kW"
    }
}:set_size(15, 12):copy_localisation_from_item():copy_icon_from_item()
