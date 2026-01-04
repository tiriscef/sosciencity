-- TODO: recipe
Tirislib.Item.create {
    type = "item",
    name = "orchid-paradise",
    icon = "__sosciencity-graphics__/graphics/icon/orchid-paradise.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "aab",
    place_result = "orchid-paradise",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "orchid-paradise",
    themes = {{"building", 1}},
    default_theme_level = 1,
    ingredients = {{type = "item", name = "architectural-concept", amount = 1}},
    unlock = "orchid-caste"
}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "orchid-paradise",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "orchid-paradise"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "consumption"},
    graphics_set = {
        animation = Tirislib.Entity.create_standard_picture {
            path = "__sosciencity-graphics__/graphics/entity/orchid-paradise/orchid-paradise",
            center = {4.5, 6.5},
            width = 14,
            height = 11,
            shadowmap = true,
            glow = true
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-orchid-paradise"},
    energy_usage = "60kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = 0.15},
        drain = "0W"
    }
}:set_size(7, 7):copy_icon_from_item()
