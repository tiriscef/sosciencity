Item:create {
    type = "item",
    name = "club",
    icon = "__sosciencity__/graphics/icon/note.png", --TODO icon
    icon_size = 64,
    flags = {},
    subgroup = "sosciencity-infrastructure",
    order = "aaa",
    place_result = "club",
    stack_size = 10
}

Entity:create {
    type = "container",
    name = "club",
    order = "aaa",
    icon = "__sosciencity__/graphics/icon/note.png", --TODO icon
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "club"},
    max_health = 500,
    corpse = "small-remnants",
    open_sound = {filename = "__base__/sound/metallic-chest-open.ogg", volume = 0.65},
    close_sound = {filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7},
    resistances = {
        {
            type = "fire",
            percent = 90
        }
    },
    collision_box = {{-2.3, -2.3}, {2.3, 2.1}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    inventory_size = 64,
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    picture = {
        filename = "__sosciencity__/graphics/entity/club.png",
        width = 405,
        height = 425,
        scale = 0.5,
        shift = util.by_pixel(32.5 / 2, -51.5 / 2)
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points,
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13,
    enable_inventory_bar = false
}
