Tirislib_Item.create {
    type = "item",
    name = "water-tower",
    icon = "__sosciencity__/graphics/icon/water-tower.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "aab",
    place_result = "water-tower",
    stack_size = 10
}

Tirislib_RecipeGenerator.create_recipe("water-tower")

local pipe_pictures = {
    north = Tirislib_Entity.get_empty_sprite(),
    east = Tirislib_Entity.get_empty_sprite(),
    south = Tirislib_Entity.get_south_pipe_picture(),
    west = Tirislib_Entity.get_empty_sprite()
}

Tirislib_Entity.create {
    type = "storage-tank",
    name = "water-tower",
    icon = "__sosciencity__/graphics/icon/water-tower.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "water-tower"},
    max_health = 500,
    corpse = "medium-remnants", -- TODO
    two_direction_only = true,
    fluid_box = {
        base_area = 50,
        pipe_covers = pipecoverspictures(),
        pipe_picture = pipe_pictures,
        pipe_connections = {
            {position = {0, -2}},
            {position = {2, 0}},
            {position = {0, 2}},
            {position = {-2, 0}}
        }
    },
    vehicle_impact_sound = Tirislib_Entity.get_standard_impact_sound(),
    pictures = {
        picture = {
            sheets = {
                {
                    filename = "__sosciencity__/graphics/entity/water-tower/water-tower.png",
                    width = 160,
                    height = 224,
                    frames = 1,
                    shift = {0, -2},
                    hr_version = {
                        filename = "__sosciencity__/graphics/entity/water-tower/water-tower-hr.png",
                        width = 320,
                        height = 448,
                        frames = 1,
                        shift = {0, -2},
                        scale = 0.5
                    }
                },
                {
                    filename = "__sosciencity__/graphics/entity/water-tower/water-tower-shadowmap.png",
                    width = 160,
                    height = 224,
                    frames = 1,
                    shift = {0, -2},
                    draw_as_shadow = true,
                    hr_version = {
                        filename = "__sosciencity__/graphics/entity/water-tower/water-tower-shadowmap-hr.png",
                        width = 320,
                        height = 448,
                        frames = 1,
                        shift = {0, -2},
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                }
            }
        },
        fluid_background = Tirislib_Entity.get_empty_sprite(),
        window_background = Tirislib_Entity.get_empty_sprite(),
        flow_sprite = Tirislib_Entity.get_empty_sprite(),
        gas_flow = Tirislib_Entity.get_empty_animation()
    },
    flow_length_in_ticks = 360,
    window_bounding_box = Tirislib_Entity.get_selection_box(0, 0),
    circuit_wire_connection_points = circuit_connector_definitions["storage-tank"].points,
    circuit_connector_sprites = circuit_connector_definitions["storage-tank"].sprites,
    circuit_wire_max_distance = 13
}:set_size(3, 3):copy_localisation_from_item()
