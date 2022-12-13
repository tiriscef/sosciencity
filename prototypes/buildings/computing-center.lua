Tirislib.Item.create {
    type = "item",
    name = "computing-center",
    icon = "__sosciencity-graphics__/graphics/icon/computing-center.png",
    icon_size = 64,
    subgroup = "sosciencity-production-buildings",
    order = "daa",
    place_result = "computing-center",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "computing-center",
    themes = {{"building", 2}, {"electronics", 100}, {"casing", 20}},
    ingredients = {{type = "item", name = "architectural-concept", amount = 1}},
    default_theme_level = 2,
    unlock = "sosciencity-computing"
}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "computing-center",
    icon = "__sosciencity-graphics__/graphics/icon/computing-center.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "computing-center"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "speed"},
    animation = Tirislib.Entity.create_standard_picture {
        path = "__sosciencity-graphics__/graphics/entity/computing-center/computing-center",
        width = 10,
        height = 7,
        shift = {0.5, -0.2},
        shadowmap = true,
        lightmap = true,
        glow = true
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
