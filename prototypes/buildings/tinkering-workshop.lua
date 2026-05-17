-- TODO: graphics

Tirislib.Item.create {
    type = "item",
    name = "tinkering-workshop",
    icon = Tirislib.Prototype.placeholder_icon,
    icon_size = 64,
    subgroup = "sosciencity-production-buildings",
    order = "aaa",
    place_result = "tinkering-workshop",
    stack_size = Sosciencity.Config.building_stacksize,
    pictures = Sosciencity.Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "tinkering-workshop", amount = 1}
    },
    ingredients = {
        {theme = "building", amount = 5},
        {theme = "gear_wheel", amount = 5},
        {type = "item", name = "architectural-concept", amount = 1}
    },
    default_theme_level = 2,
    unlock = "tinkering-workshop"
}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "tinkering-workshop",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "tinkering-workshop"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "speed"},
    graphics_set = {
        animation = {
            layers = {
                {
                    filename = "__sosciencity-graphics__/graphics/placeholder.png",
                    priority = "high",
                    width = 224,
                    height = 224,
                    scale = 6/7
                },
                {
                    filename = "__sosciencity-graphics__/graphics/clockwork-caste.png",
                    priority = "high",
                    width = 256,
                    height = 256,
                    scale = 0.5,
                    frame_count = 1
                }
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-tinkering-workshop"},
    fluid_boxes = {
        {
            volume = 200,
            pipe_connections = {{position = {-2.5, 0}, flow_direction = "input", direction = defines.direction.west}},
            production_type = "input"
        },
        {
            volume = 200,
            pipe_connections = {{position = {2.5, 0}, flow_direction = "input", direction = defines.direction.east}},
            production_type = "input"
        }
    },
    fluid_boxes_off_when_no_fluid_recipe = true,
    energy_usage = "60kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = 0.15},
        drain = "0W"
    }
}:set_size(6, 6):copy_icon_from_item()
Sosciencity.configure_building("tinkering-workshop")
