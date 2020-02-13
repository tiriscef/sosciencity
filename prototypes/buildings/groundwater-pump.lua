Tirislib_Item.create {
    type = "item",
    name = "groundwater-pump",
    icon = "__sosciencity__/graphics/icon/groundwater-pump.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "aab",
    place_result = "groundwater-pump",
    stack_size = 50
}

Tirislib_RecipeGenerator.create_recipe("groundwater-pump")

local pipe_pictures = Tirislib_Entity.get_standard_pipe_pictures{"south"}

Tirislib_Entity.create {
    type = "storage-tank",
    name = "groundwater-pump",
    icon = "__sosciencity__/graphics/icon/groundwater-pump.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "groundwater-pump"},
    max_health = 150,
    corpse = "groundwater-pump-remnants",
    fluid_box = {
        base_area = 2,
        filter = "groundwater",
        pipe_covers = pipecoverspictures(),
        pipe_picture = pipe_pictures,
        pipe_connections = {
            {position = {0, -2}}
        }
    },
    vehicle_impact_sound = Tirislib_Entity.get_standard_impact_sound(),
    pictures = {
        picture = {
            sheets = {
                {
                    filename = "__sosciencity__/graphics/entity/groundwater-pump/groundwater-pump.png",
                    width = 128,
                    height = 160,
                    frames = 1,
                    shift = {0.5, -1},
                    hr_version = {
                        filename = "__sosciencity__/graphics/entity/groundwater-pump/groundwater-pump-hr.png",
                        width = 256,
                        height = 320,
                        frames = 1,
                        shift = {0.5, -1},
                        scale = 0.5
                    }
                },
                {
                    filename = "__sosciencity__/graphics/entity/groundwater-pump/groundwater-pump-shadowmap.png",
                    width = 128,
                    height = 160,
                    frames = 1,
                    shift = {0.5, -1},
                    draw_as_shadow = true,
                    hr_version = {
                        filename = "__sosciencity__/graphics/entity/groundwater-pump/groundwater-pump-shadowmap-hr.png",
                        width = 256,
                        height = 320,
                        frames = 1,
                        shift = {0.5, -1},
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

Tirislib_Entity.create {
    type = "corpse",
    name = "groundwater-pump-remnants",
    icon = "__sosciencity__/graphics/icon/groundwater-pump.png",
    icon_size = 64,
    flags = {"placeable-neutral", "not-on-map"},
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    final_render_layer = "remnants",
    subgroup = "remnants",
    order = "dead-groundwater-pump:(",
    remove_on_tile_placement = false,
    animation = {
        filename = "__sosciencity__/graphics/entity/groundwater-pump/groundwater-pump-remnants.png",
        direction_count = 1,
        width = 128,
        height = 160,
        shift = {0.5, -1},
        hr_version = {
            filename = "__sosciencity__/graphics/entity/groundwater-pump/groundwater-pump-remnants-hr.png",
            direction_count = 1,
            width = 256,
            height = 320,
            shift = {0.5, -1},
            scale = 0.5
        }
    }
}:set_size(3, 3)
