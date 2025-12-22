Tirislib.Item.create {
    type = "item",
    name = "salt-pond",
    icon = "__sosciencity-graphics__/graphics/icon/salt-pond.png",
    icon_size = 64,
    subgroup = "sosciencity-production-buildings",
    order = "daa",
    place_result = "salt-pond",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "salt-pond",
    themes = {{"piping", 5}, {"machine", 1}},
    default_theme_level = 1,
    unlock = "fermentation"
}:add_unlock("medbay")
Sosciencity_Config.remove_quality_multipliers("salt-pond")

local sprite_width = 14
local sprite_height = 14

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "salt-pond",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "salt-pond"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "speed"},
    graphics_set = {
        animation = Tirislib.Entity.create_standard_picture {
            path = "__sosciencity-graphics__/graphics/entity/salt-pond/salt-pond",
            shift = {0.0, 0.0},
            width = 14,
            height = 14,
            shadowmap = true
        },
        working_visualisations = {
            {
                always_draw = true,
                constant_speed = true,
                animation = {
                    filename = "__sosciencity-graphics__/graphics/entity/salt-pond/salt-pond-sheet.png",
                    frame_count = 30,
                    priority = "high",
                    width = sprite_width * 64,
                    height = sprite_height * 64,
                    scale = 0.5,
                    shift = {0.0, 0.0},
                    line_length = 4,
                    animation_speed = 15 / 60
                }
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-salt-pond"},
    energy_usage = "10W",
    energy_source = {
        type = "void",
        emissions_per_minute = {pollution = 0.25}
    }
}:set_size(12, 12):copy_localisation_from_item():copy_icon_from_item()
