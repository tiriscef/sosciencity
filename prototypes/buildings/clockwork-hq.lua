Tirislib.Item.create {
    type = "item",
    name = "clockwork-hq",
    icon = "__sosciencity-graphics__/graphics/icon/clockwork-hq.png",
    icon_size = 64,
    subgroup = "sosciencity-hqs",
    order = "aaa",
    place_result = "clockwork-hq",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "clockwork-hq",
    themes = {{"building", 10}, {"gear_wheel", 10}, {"furnace", 10}},
    default_theme_level = 2,
    ingredients = {{type = "item", name = "architectural-concept", amount = 1}},
    unlock = "clockwork-caste"
}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "clockwork-hq",
    flags = {"placeable-neutral", "player-creation", "not-rotatable"},
    minable = {mining_time = 0.5, result = "clockwork-hq"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "speed"},
    animation = Tirislib.Entity.create_standard_picture {
        path = "__sosciencity-graphics__/graphics/entity/clockwork-hq/clockwork-hq",
        shift = {6.5, -0.5},
        width = 32,
        height = 21,
        shadowmap = true,
        glow = true,
        lightmap = true
    },
    crafting_speed = 2,
    crafting_categories = {"sosciencity-caste-clockwork"},
    energy_usage = "250kW",
    energy_source = {
        type = "burner",
        usage_priority = "secondary-input",
        emissions_per_minute = 1,
        fuel_inventory_size = 1,
        smoke = {
            {
                name = "turbine-smoke",
                frequency = 15,
                north_position = {3.75, -9.5},
                starting_vertical_speed = 0.08,
                slow_down_factor = 1,
                starting_frame_deviation = 60
            }
        }
    }
}:set_size(17, 14):copy_localisation_from_item():copy_icon_from_item()
