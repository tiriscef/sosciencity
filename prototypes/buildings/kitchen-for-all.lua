-- TODO: recipe, unlock
Tirislib.Item.create {
    type = "item",
    name = "kitchen-for-all",
    icon = "__sosciencity-graphics__/graphics/icon/kitchen-for-all.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "aab",
    place_result = "kitchen-for-all",
    stack_size = Sosciencity_Config.building_stacksize
}

Tirislib.RecipeGenerator.create {
    product = "kitchen-for-all",
    themes = {{"building", 1}},
    default_theme_level = 0,
    ingredients = {{type = "item", name = "architectural-concept", amount = 1}},
    unlock = "ember-caste"
}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "kitchen-for-all",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "kitchen-for-all"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "consumption"},
    graphics_set = {
        animation = Tirislib.Entity.create_standard_picture {
            path = "__sosciencity-graphics__/graphics/entity/kitchen-for-all/kitchen-for-all",
            center = {3.5, 4.5},
            width = 10,
            height = 8,
            shadowmap = true,
            glow = true,
            lightmap = true
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-kitchen-for-all"},
    energy_usage = "60kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = 0.15},
        drain = "0W"
    }
}:set_size(5, 5):copy_icon_from_item()
