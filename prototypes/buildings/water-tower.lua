Tirislib.Item.create {
    type = "item",
    name = "water-tower",
    icon = "__sosciencity-graphics__/graphics/icon/water-tower.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "baa",
    place_result = "water-tower",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "water-tower",
    themes = {{"tank", 1}, {"piping", 15}, {"framework", 10}, {"plating", 10}},
    default_theme_level = 1,
    unlock = "infrastructure-1"
}

local pipe_pictures = Tirislib.Entity.get_standard_pipe_pictures {"south"}
local size_x = 3
local size_y = 3

Tirislib.Entity.create {
    type = "storage-tank",
    name = "water-tower",
    icon = "__sosciencity-graphics__/graphics/icon/water-tower.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "water-tower"},
    max_health = 500,
    corpse = "water-tower-remnants",
    two_direction_only = true,
    fluid_box = {
        volume = 5000,
        pipe_covers = pipecoverspictures(),
        pipe_picture = pipe_pictures,
        pipe_connections = {
            {position = {0, -1}, direction = defines.direction.north},
            {position = {1, 0}, direction = defines.direction.east},
            {position = {0, 1}, direction = defines.direction.south},
            {position = {-1, 0}, direction = defines.direction.west}
        }
    },
    vehicle_impact_sound = Tirislib.Entity.get_standard_impact_sound(),
    pictures = {
        picture = {
            sheets = {
                {
                    filename = "__sosciencity-graphics__/graphics/entity/water-tower/water-tower-hr.png",
                    width = 320,
                    height = 448,
                    frames = 1,
                    shift = {0, -2},
                    scale = 0.5
                },
                {
                    filename = "__sosciencity-graphics__/graphics/entity/water-tower/water-tower-shadowmap-hr.png",
                    width = 320,
                    height = 448,
                    frames = 1,
                    shift = {0, -2},
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        },
        fluid_background = Tirislib.Entity.get_empty_sprite(),
        window_background = Tirislib.Entity.get_empty_sprite(),
        flow_sprite = Tirislib.Entity.get_empty_sprite(),
        gas_flow = Tirislib.Entity.get_empty_animation()
    },
    flow_length_in_ticks = 360,
    window_bounding_box = Tirislib.Entity.get_selection_box(0, 0),
    circuit_wire_connection_points = circuit_connector_definitions["storage-tank"].points,
    circuit_connector_sprites = circuit_connector_definitions["storage-tank"].sprites,
    circuit_wire_max_distance = 13
}:set_size(size_x, size_y):copy_localisation_from_item()

Tirislib.Entity.create {
    type = "corpse",
    name = "water-tower-remnants",
    icon = "__sosciencity-graphics__/graphics/icon/water-tower.png",
    icon_size = 64,
    flags = {"placeable-neutral", "not-on-map"},
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    final_render_layer = "remnants",
    subgroup = "remnants",
    order = "dead-water-tower:(",
    remove_on_tile_placement = false,
    animation = {
        filename = "__sosciencity-graphics__/graphics/entity/water-tower/water-tower-remnants-hr.png",
        direction_count = 1,
        width = 320,
        height = 320,
        shift = {0, -1},
        scale = 0.5
    },
    localised_name = {"item-name.water-tower"}
}:set_size(size_x, size_y)
