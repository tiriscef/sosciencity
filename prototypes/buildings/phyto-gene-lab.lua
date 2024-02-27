Tirislib.Item.create {
    type = "item",
    name = "phyto-gene-lab",
    icon = "__sosciencity-graphics__/graphics/icon/phyto-gene-lab.png",
    icon_size = 64,
    subgroup = "sosciencity-production-buildings",
    order = "daa",
    place_result = "phyto-gene-lab",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "phyto-gene-lab",
    themes = {{"machine", 2}, {"lamp", 5}, {"piping", 20}},
    default_theme_level = 3,
    unlock = "genetic-neogenesis"
}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "phyto-gene-lab",
    icon = "__sosciencity-graphics__/graphics/icon/phyto-gene-lab.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "phyto-gene-lab"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "speed"},
    animation = Tirislib.Entity.create_standard_picture {
        path = "__sosciencity-graphics__/graphics/entity/phyto-gene-lab/phyto-gene-lab",
        center = {3.5, 4.5},
        width = 10,
        height = 8,
        shadowmap = true,
        glow = true
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-phyto-gene-lab"},
    energy_usage = "190kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 0.25,
        drain = "10kW"
    }
}:set_size(7, 7):copy_localisation_from_item()
