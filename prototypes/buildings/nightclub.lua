Tirislib.Item.create {
    type = "item",
    name = "nightclub",
    icon = "__sosciencity-graphics__/graphics/icon/nightclub.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "haa",
    place_result = "nightclub",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "nightclub",
    themes = {{"building", 7.5}, {"electronics", 10}, {"lamp", 20}},
    ingredients = {
        {type = "item", name = "architectural-concept", amount = 1}
    },
    default_theme_level = 2,
    unlock = "infrastructure-2"
}

local size_x = 20
local size_y = 9
Tirislib.Entity.create {
    type = "container",
    name = "nightclub",
    icon = "__sosciencity-graphics__/graphics/icon/nightclub.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "nightclub"},
    max_health = 500,
    corpse = "small-remnants",
    inventory_size = 30,
    vehicle_impact_sound = {
        filename = "__base__/sound/car-metal-impact.ogg",
        volume = 0.65
    },
    picture = {
        layers = {
            {
                filename = "__sosciencity-graphics__/graphics/entity/nightclub/nightclub-hr.png",
                priority = "high",
                width = 1408,
                height = 896,
                scale = 0.5,
                shift = {0.0, -2.5}
            },
            {
                filename = "__sosciencity-graphics__/graphics/entity/nightclub/nightclub-shadowmap-hr.png",
                priority = "high",
                width = 1408,
                height = 896,
                scale = 0.5,
                shift = {1.0, -2.5},
                draw_as_shadow = true
            },
            {
                filename = "__sosciencity-graphics__/graphics/entity/nightclub/nightclub-lightmap-hr.png",
                priority = "high",
                width = 1472,
                height = 1024,
                scale = 0.5,
                shift = {0.5, -0.5},
                draw_as_light = true
            },
            {
                filename = "__sosciencity-graphics__/graphics/entity/nightclub/nightclub-emission-hr.png",
                priority = "high",
                width = 1472,
                height = 1024,
                scale = 0.5,
                shift = {0.5, -0.5},
                draw_as_glow = true
            }
        }
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13,
    working_sound = {
        filename = "__sosciencity-graphics__/sound/nightclub.ogg",
        volume = 2.5
    }
}:set_size(size_x, size_y):copy_localisation_from_item()
Sosciencity_Config.add_eei("nightclub")
