-- TODO: actual graphics

Tirislib_Item.create {
    type = "item",
    name = "reproductive-gene-lab",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    subgroup = "sosciencity-food-buildings",
    order = "daa",
    place_result = "reproductive-gene-lab",
    stack_size = 10,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib_RecipeGenerator.create {
    product = "reproductive-gene-lab",
    themes = {{"building", 2}, {"machine", 2}, {"lamp", 5}, {"window", 5}},
    default_theme_level = 2,
    category = "sosciencity-architecture",
    unlock = "huwan-genetic-neogenesis"
}

Tirislib_Entity.create {
    type = "assembling-machine",
    name = "reproductive-gene-lab",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "reproductive-gene-lab"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "speed"},
    animation = {
        filename = "__sosciencity-graphics__/graphics/entity/placeholder.png",
        priority = "high",
        width = 192,
        height = 192,
        scale = 0.5,
        frame_count = 1
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-reproductive-gene-lab"},
    energy_usage = "190kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 0.25,
        drain = "10kW"
    }
}:set_size(3, 3):copy_localisation_from_item()
