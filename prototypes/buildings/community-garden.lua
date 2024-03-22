Tirislib.Item.create {
    type = "item",
    name = "community-garden",
    icon = "__sosciencity-graphics__/graphics/icon/community-garden.png",
    icon_size = 64,
    subgroup = "sosciencity-flora-buildings",
    order = "gaa",
    place_result = "community-garden",
    stack_size = Sosciencity_Config.building_stacksize
}

Tirislib.Entity.create {
    type = "container",
    name = "community-garden",
    flags = {"placeable-neutral", "player-creation"},
    collision_mask = {"item-layer", "object-layer", "water-tile"},
    minable = {mining_time = 0.5, result = "community-garden"},
    max_health = 200,
    inventory_size = 20,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    picture = Tirislib.Entity.create_standard_picture {
        path = "__sosciencity-graphics__/graphics/entity/community-garden/community-garden",
        width = 6,
        height = 6,
        center = {2.5, 3.5},
        shadowmap = true
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13
}:set_size(3, 3):copy_localisation_from_item():copy_icon_from_item()
