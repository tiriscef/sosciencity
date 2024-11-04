Tirislib.Item.create {
    type = "item",
    name = "zeppelin-port",
    icon = "__sosciencity-graphics__/graphics/icon/zeppelin-port.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "aab",
    place_result = "zeppelin-port",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

--[[Tirislib.RecipeGenerator.create {
    product = "zeppelin-port",
    themes = {{"building", 3}, {"fabric", 50}, {"rope", 20}, {"framework", 10}},
    default_theme_level = 0
}]]

Tirislib.Entity.create {
    type = "container",
    name = "zeppelin-port",
    icon = "__sosciencity-graphics__/graphics/icon/zeppelin-port.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "zeppelin-port"},
    max_health = 200,
    corpse = "medium-remnants",
    inventory_size = 10,
    vehicle_impact_sound = {
        filename = "__base__/sound/car-metal-impact.ogg",
        volume = 0.65
    },
    picture = {
        layers = {
            {
                filename = "__sosciencity-graphics__/graphics/entity/zeppelin-port/zeppelin-port-hr.png",
                priority = "high",
                width = 1088,
                height = 512,
                shift = {0, -0.5},
                scale = 0.5
            },
            {
                filename = "__sosciencity-graphics__/graphics/entity/zeppelin-port/zeppelin-port-shadowmap-hr.png",
                priority = "high",
                width = 1088,
                height = 512,
                shift = {0, -0.5},
                scale = 0.5,
                draw_as_shadow = true
            }
        }
    }
}:set_size(15, 5):copy_localisation_from_item()

--[[Tirislib.Entity.create {
    type = "corpse",
    name = "zeppelin-port-remnants",
    icon = "__sosciencity-graphics__/graphics/icon/zeppelin-port.png",
    icon_size = 64,
    flags = {"placeable-neutral", "not-on-map"},
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    final_render_layer = "remnants",
    subgroup = "remnants",
    order = "dead-zeppelin-port:(",
    remove_on_tile_placement = false,
    animation = {
        filename = "__sosciencity-graphics__/graphics/entity/zeppelin-port/zeppelin-port-remnants-hr.png",
        direction_count = 1,
        width = 384,
        height = 384,
        shift = {0.5, -0.5},
        scale = 0.5
    }
}:set_size(5, 5)]]
