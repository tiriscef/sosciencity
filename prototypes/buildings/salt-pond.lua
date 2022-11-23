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
    unlock = "food-processing"
}

local sprite_width = 9
local sprite_height = 9

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
    animation = Tirislib.Entity.create_standard_picture {
        path = "__sosciencity-graphics__/graphics/entity/salt-pond/salt-pond",
        center = {4.0, 5.0},
        width = 9,
        height = 9,
        shadowmap = true
    },
    working_visualisations = {
        {
            always_draw = true,
            constant_speed = true,
            animation = {
                filename = "__sosciencity-graphics__/graphics/entity/salt-pond/salt-pond-sheet-lr.png",
                frame_count = 60,
                priority = "high",
                width = sprite_width * 32,
                height = sprite_height * 32,
                shift = {0.5, -0.5},
                line_length = 7,
                animation_speed = 20 / 60,
                hr_version = {
                    filename = "__sosciencity-graphics__/graphics/entity/salt-pond/salt-pond-sheet.png",
                    frame_count = 60,
                    priority = "high",
                    width = sprite_width * 64,
                    height = sprite_height * 64,
                    scale = 0.5,
                    shift = {0.5, -0.5},
                    line_length = 7,
                    animation_speed = 20 / 60
                }
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-salt-pond"},
    energy_usage = "10W",
    energy_source = {
        type = "void",
        emissions_per_minute = 0.25
    },
    fixed_recipe = "salty-water-evaporation"
}:set_size(8, 8):copy_localisation_from_item():copy_icon_from_item()
