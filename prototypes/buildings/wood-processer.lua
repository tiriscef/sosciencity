Tirislib.Item.create {
    type = "item",
    name = "wood-processer",
    icon = "__sosciencity-graphics__/graphics/icon/wood-processer.png",
    icon_size = 64,
    subgroup = "sosciencity-production-buildings",
    order = "aaa",
    place_result = "wood-processer",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "wood-processer",
    themes = {{"machine", 4}, {"gear_wheel", 8}},
    default_theme_level = 0,
    unlock = "composting-silo"
}

Tirislib.Entity.create {
    type = "furnace",
    name = "wood-processer",
    flags = {"placeable-neutral", "player-creation", "not-rotatable"},
    minable = {mining_time = 0.5, result = "wood-processer"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    module_specification = {
        module_slots = 2
    },
    allowed_effects = {"productivity", "consumption", "speed", "pollution"},
    graphics_set = {
        animation = Tirislib.Entity.create_standard_picture {
            path = "__sosciencity-graphics__/graphics/entity/wood-processer/wood-processer",
            center = {4.0, 4.0},
            width = 12.5,
            height = 7,
            shadowmap = true,
            glow = true,
            lightmap = true
        }
    },
    crafting_speed = 2,
    crafting_categories = {"sosciencity-wood-processing"},
    source_inventory_size = 1,
    result_inventory_size = 2,
    energy_usage = "145kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = 0.1},
        drain = "5kW"
    },
    working_sound = {
        -- TODO: better fitting sound
        sound = {
            {
                filename = "__base__/sound/assembling-machine-t1-1.ogg",
                volume = 0.5
            }
        },
        audible_distance_modifier = 0.5,
        fade_in_ticks = 4,
        fade_out_ticks = 20
    }
}:set_size(7, 4):copy_icon_from_item()
