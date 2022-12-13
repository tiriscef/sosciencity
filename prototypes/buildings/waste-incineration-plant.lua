Tirislib.Item.create {
    type = "item",
    name = "waste-incineration-plant",
    icon = "__sosciencity-graphics__/graphics/icon/waste-incineration-plant.png",
    icon_size = 64,
    subgroup = "sosciencity-buildings",
    order = "daa",
    place_result = "waste-incineration-plant",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "waste-incineration-plant",
    themes = {{"machine", 10}},
    default_theme_level = 4,
    unlock = "infrastructure-4"
}

Tirislib.Entity.create {
    type = "burner-generator",
    name = "waste-incineration-plant",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "waste-incineration-plant"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    animation = Tirislib.Entity.create_standard_picture {
        path = "__sosciencity-graphics__/graphics/entity/waste-incineration-plant/waste-incineration-plant",
        shift = {2.0, 0.5},
        width = 21,
        height = 16,
        shadowmap = true,
        glow = true,
        lightmap = true
    },
    energy_source = {
        type = "electric",
        usage_priority = "primary-output"
    },
    burner = {
        type = "burner",
        fuel_category = "garbage",
        fuel_inventory_size = 3,
        effectivity = 1,
        emissions_per_minute = 10,
        smoke = {
            {
                name = "turbine-smoke",
                frequency = 10,
                north_position = {-0.30, -5.9},
                starting_vertical_speed = 0.08,
                slow_down_factor = 0.5
            },
            {
                name = "turbine-smoke",
                frequency = 10,
                north_position = {-0.25, -5.6},
                starting_vertical_speed = 0.08,
                slow_down_factor = 0.5
            },
            {
                name = "smoke",
                frequency = 15,
                north_position = {2.5, 0.4},
                starting_vertical_speed = 0.08,
                slow_down_factor = 0.5
            }
        }
    },
    max_power_output = "2.5MW"
}:set_size(13, 7):copy_localisation_from_item():copy_icon_from_item()
