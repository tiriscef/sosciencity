Tirislib.Item.create {
    type = "item",
    name = "fishing-hut",
    icon = "__sosciencity-graphics__/graphics/icon/fishing-hut.png",
    icon_size = 64,
    subgroup = "sosciencity-fauna-buildings",
    order = "bab",
    place_result = "fishing-hut",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "fishing-hut",
    themes = {{"building", 3}},
    default_theme_level = 0,
    ingredients = {{type = "item", name = "architectural-concept", amount = 1}},
    unlock = "infrastructure-1"
}
Sosciencity_Config.remove_quality_multipliers("fishing-hut")

local shift = {0.25, -0.5}
local width = 160
local height = 160

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "fishing-hut",
    icon = "__sosciencity-graphics__/graphics/icon/fishing-hut.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "fishing-hut"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "consumption", "speed", "pollution"},
    graphics_set = {
        animation = {
            layers = {
                {
                    filename = "__sosciencity-graphics__/graphics/entity/fishing-hut/fishing-hut-hr.png",
                    priority = "high",
                    width = width * 2,
                    height = height * 2,
                    shift = shift,
                    scale = 0.625
                },
                {
                    filename = "__sosciencity-graphics__/graphics/entity/fishing-hut/fishing-hut-shadowmap-hr.png",
                    priority = "high",
                    width = width * 2,
                    height = height * 2,
                    shift = shift,
                    scale = 0.625,
                    draw_as_shadow = true
                }
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-fishery", "sosciencity-fishery-hand"},
    energy_usage = "65kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = 0.25},
        drain = "10kW"
    }
}:set_size(5, 5):copy_localisation_from_item()
