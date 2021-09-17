-- TODO: actual graphics

Tirislib_Item.create {
    type = "item",
    name = "microalgae-farm",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    subgroup = "sosciencity-microorganism-buildings",
    order = "daa",
    place_result = "microalgae-farm",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib_RecipeGenerator.create {
    product = "microalgae-farm",
    themes = {{"building", 2}, {"machine", 2}, {"electronics", 100}, {"casing", 10}}, -- TODO actual themes
    default_theme_level = 2,
    unlock = "basic-biotechnology"
}

Tirislib_Entity.create {
    type = "assembling-machine",
    name = "microalgae-farm",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "microalgae-farm"},
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
                scale = 5/7,
                frame_count = 1
            },
            {
                filename = "__sosciencity-graphics__/graphics/icon/mynellia.png",
                priority = "high",
                width = 64,
                height = 64,
                scale = 1,
                frame_count = 1
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-microalgae-farm"},
    energy_usage = "70kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = -2,
        drain = "5kW"
    }
}:set_size(5, 5):copy_localisation_from_item():copy_icon_from_item()
