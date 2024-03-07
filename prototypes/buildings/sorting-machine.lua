Tirislib.Item.create {
    type = "item",
    name = "sorting-machine",
    icon = "__sosciencity-graphics__/graphics/icon/sorting-machine.png",
    icon_size = 64,
    subgroup = "sosciencity-production-buildings",
    order = "aaa",
    place_result = "sorting-machine",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "sorting-machine",
    themes = {{"machine", 2}},
    default_theme_level = 1,
    unlock = "open-environment-farming"
}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "sorting-machine",
    icon = "__sosciencity-graphics__/graphics/icon/sorting-machine.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "sorting-machine"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "speed"},
    animation = Tirislib.Entity.create_standard_picture {
        path = "__sosciencity-graphics__/graphics/entity/sorting-machine/sorting-machine",
        center = {2.5, 2.5},
        width = 6,
        height = 5,
        shadowmap = true,
        lightmap = true,
        glow = true
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-sorting-machine"},
    energy_usage = "30kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 0.1,
        drain = "5kW"
    },
    working_sound = {
        sound = {
            {
                filename = "__base__/sound/assembling-machine-t1-1.ogg",
                volume = 0.4
            }
        },
        audible_distance_modifier = 0.5,
        fade_in_ticks = 4,
        fade_out_ticks = 20
    }
}:set_size(3, 3):copy_localisation_from_item()
