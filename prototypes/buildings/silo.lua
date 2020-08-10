Tirislib_Item.create {
    type = "item",
    name = "silo",
    icon = "__sosciencity-graphics__/graphics/icon/silo.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "aab",
    place_result = "silo",
    stack_size = 10,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib_RecipeGenerator.create {
    product = "silo"
}

Tirislib_Entity.create {
    type = "container",
    name = "silo",
    icon = "__sosciencity-graphics__/graphics/icon/silo.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "silo"},
    max_health = 500,
    corpse = "small-remnants",
    inventory_size = 64,
    vehicle_impact_sound = {
        filename = "__base__/sound/car-metal-impact.ogg",
        volume = 0.65
    },
    picture = {
        layers = {
            {
                filename = "__sosciencity-graphics__/graphics/entity/silo/silo.png",
                priority = "high",
                width = 160,
                height = 256,
                shift = {1, -2.5},
                hr_version = {
                    filename = "__sosciencity-graphics__/graphics/entity/silo/silo-hr.png",
                    priority = "high",
                    width = 320,
                    height = 512,
                    shift = {1, -2.5},
                    scale = 0.5
                }
            },
            {
                filename = "__sosciencity-graphics__/graphics/entity/silo/silo-shadowmap.png",
                priority = "high",
                width = 160,
                height = 256,
                shift = {1, -2.5},
                draw_as_shadow = true,
                hr_version = {
                    filename = "__sosciencity-graphics__/graphics/entity/silo/silo-shadowmap-hr.png",
                    priority = "high",
                    width = 320,
                    height = 512,
                    shift = {1, -2.5},
                    scale = 0.5,
                    draw_as_shadow = true
                }
            }
        }
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13
}:set_size(3, 3):copy_localisation_from_item()
