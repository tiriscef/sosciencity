Tirislib_Item.create {
    type = "item",
    name = "trash-site",
    icon = "__sosciencity__/graphics/icon/trash-site.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "aab",
    place_result = "trash-site",
    stack_size = 10
}

Tirislib_RecipeGenerator.create_recipe("trash-site")

Tirislib_Entity.create {
    type = "container",
    name = "trash-site",
    icon = "__sosciencity__/graphics/icon/trash-site.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "trash-site"},
    max_health = 500,
    corpse = "small-remnants", -- TODO
    inventory_size = 64,
    vehicle_impact_sound = {
        filename = "__base__/sound/car-metal-impact.ogg",
        volume = 0.65
    },
    picture = {
        layers = {
            {
                filename = "__sosciencity__/graphics/entity/trash-site/trash-site-hr.png",
                priority = "high",
                width = 384,
                height = 384,
                shift = {0.5, -0.5},
                scale = 0.5
            },
            {
                filename = "__sosciencity__/graphics/entity/trash-site/trash-site-shadowmap-hr.png",
                priority = "high",
                width = 384,
                height = 384,
                shift = {0.5, -0.5},
                scale = 0.5,
                draw_as_shadow = true
            }
        }
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13
}:set_size(5, 5):copy_localisation_from_item()
