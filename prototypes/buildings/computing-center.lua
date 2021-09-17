-- TODO: actual graphics

Tirislib_Item.create {
    type = "item",
    name = "computing-center",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    subgroup = "sosciencity-production-buildings",
    order = "daa",
    place_result = "computing-center",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib_RecipeGenerator.create {
    product = "computing-center",
    themes = {{"building", 2}, {"machine", 2}, {"electronics", 100}, {"casing", 10}},
    ingredients = {{type = "item", name = "architectural-concept", amount = 1}},
    default_theme_level = 2,
    unlock = "sosciencity-computing"
}

Tirislib_Entity.create {
    type = "assembling-machine",
    name = "computing-center",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "computing-center"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "speed"},    animation = {
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
                filename = "__sosciencity-graphics__/graphics/icon/empty-hard-drive.png",
                priority = "high",
                width = 64,
                height = 64,
                scale = 1,
                frame_count = 1
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-computing-center"},
    energy_usage = "1.9MW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 0.15,
        drain = "100kW"
    }
}:set_size(5, 5):copy_localisation_from_item()
