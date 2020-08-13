Tirislib_Item.create {
    type = "item",
    name = "nightclub",
    icon = "__sosciencity-graphics__/graphics/icon/nightclub.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "aab",
    place_result = "nightclub",
    stack_size = 10,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib_RecipeGenerator.create {
    product = "nightclub"
}

local size_x = 11
local size_y = 5
Tirislib_Entity.create {
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
                filename = "__sosciencity-graphics__/graphics/entity/nightclub/nightclub.png",
                priority = "high",
                width = 416,
                height = 288,
                shift = {0.0, -1.0},
                hr_version = {
                    filename = "__sosciencity-graphics__/graphics/entity/nightclub/nightclub-hr.png",
                    priority = "high",
                    width = 832,
                    height = 576,
                    scale = 0.5,
                    shift = {0.0, -1.0}
                }
            },
            {
                filename = "__sosciencity-graphics__/graphics/entity/nightclub/nightclub-shadowmap.png",
                priority = "high",
                width = 224,
                height = 224,
                shift = {0.0, -1.0},
                draw_as_shadow = true,
                hr_version = {
                    filename = "__sosciencity-graphics__/graphics/entity/nightclub/nightclub-shadowmap-hr.png",
                    priority = "high",
                    width = 448,
                    height = 448,
                    scale = 0.5,
                    shift = {0.0, -1.0},
                    draw_as_shadow = true
                }
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
Sosciencity_Config.add_eei_size(size_x, size_y)
