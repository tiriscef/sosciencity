Tirislib.Item.create {
    type = "item",
    name = "ember-hq",
    icon = "__sosciencity-graphics__/graphics/icon/ember-hq.png",
    icon_size = 64,
    subgroup = "sosciencity-hqs",
    order = "daa",
    place_result = "ember-hq",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "ember-hq",
    themes = {{"building", 10}},
    default_theme_level = 0,
    ingredients = {{type = "item", name = "architectural-concept", amount = 1}},
    unlock = "ember-caste"
}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "ember-hq",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "ember-hq"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "speed"},
    animation = Tirislib.Entity.create_standard_picture {
        path = "__sosciencity-graphics__/graphics/entity/ember-hq/ember-hq",
        shift = {3.5, -1.6},
        width = 22,
        height = 17,
        shadowmap = true,
        glow = true,
        lightmap = true
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-caste-ember"},
    energy_usage = "190kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = 0.25},
        drain = "10kW"
    }
}:set_size(11, 11):copy_localisation_from_item():copy_icon_from_item()
