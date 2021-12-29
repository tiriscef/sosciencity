Tirislib.Item.create {
    type = "item",
    name = "trash-site",
    icon = "__sosciencity-graphics__/graphics/icon/trash-site.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "aab",
    place_result = "trash-site",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "trash-site",
    themes = {{"building", 2}},
    ingredients = {{type = "item", name = "architectural-concept", amount = 1}},
    unlock = "infrastructure-1"
}

Tirislib.Entity.create {
    type = "container",
    name = "trash-site",
    icon = "__sosciencity-graphics__/graphics/icon/trash-site.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "trash-site"},
    max_health = 500,
    corpse = "trash-site-remnants",
    inventory_size = 20,
    vehicle_impact_sound = {
        filename = "__base__/sound/car-metal-impact.ogg",
        volume = 0.65
    },
    picture = {
        layers = {
            -- TODO low res sprites
            {
                filename = "__sosciencity-graphics__/graphics/entity/trash-site/trash-site-hr.png",
                priority = "high",
                width = 384,
                height = 384,
                shift = {0.5, -0.5},
                scale = 0.5 * 0.8
            },
            {
                filename = "__sosciencity-graphics__/graphics/entity/trash-site/trash-site-shadowmap-hr.png",
                priority = "high",
                width = 384,
                height = 384,
                shift = {0.5, -0.5},
                scale = 0.5 * 0.8,
                draw_as_shadow = true
            }
        }
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13
}:set_size(4, 4):copy_localisation_from_item()

Tirislib.Entity.create {
    type = "corpse",
    name = "trash-site-remnants",
    icon = "__sosciencity-graphics__/graphics/icon/trash-site.png",
    icon_size = 64,
    flags = {"placeable-neutral", "not-on-map"},
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    final_render_layer = "remnants",
    subgroup = "remnants",
    order = "dead-trash-site:(",
    remove_on_tile_placement = false,
    animation = {
        filename = "__sosciencity-graphics__/graphics/entity/trash-site/trash-site-remnants.png",
        direction_count = 1,
        width = 192,
        height = 192,
        shift = {0.5, -0.5},
        scale = 0.8,
        hr_version = {
            filename = "__sosciencity-graphics__/graphics/entity/trash-site/trash-site-remnants-hr.png",
            direction_count = 1,
            width = 384,
            height = 384,
            shift = {0.5, -0.5},
            scale = 0.5 * 0.8
        }
    },
    localised_name = {"item-name.trash-site"}
}:set_size(4, 4)
