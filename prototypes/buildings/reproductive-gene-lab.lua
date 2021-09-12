Tirislib_Item.create {
    type = "item",
    name = "reproductive-gene-lab",
    icon = "__sosciencity-graphics__/graphics/icon/reproductive-gene-lab.png",
    icon_size = 64,
    subgroup = "sosciencity-production-buildings",
    order = "daa",
    place_result = "reproductive-gene-lab",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib_RecipeGenerator.create {
    product = "reproductive-gene-lab",
    themes = {{"machine", 10}},
    default_theme_level = 3,
    unlock = "huwan-genetic-neogenesis"
}

Tirislib_Entity.create {
    type = "assembling-machine",
    name = "reproductive-gene-lab",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "reproductive-gene-lab"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "speed"},
    animation = Tirislib_Entity.create_standard_picture {
        path = "__sosciencity-graphics__/graphics/entity/reproductive-gene-lab/reproductive-gene-lab",
        width = 12,
        height = 8,
        shift = {2.5, 0.5},
        shadowmap = true,
        lightmap = true,
        glow = true
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-reproductive-gene-lab"},
    energy_usage = "230kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 0.25,
        drain = "20kW"
    }
}:set_size(5, 5):copy_localisation_from_item():copy_icon_from_item()
