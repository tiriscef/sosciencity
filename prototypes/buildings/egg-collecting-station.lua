-- TODO: actual graphics

Tirislib_Item.create {
    type = "item",
    name = "egg-collecting-station",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    subgroup = "sosciencity-food-buildings",
    order = "daa",
    place_result = "egg-collecting-station",
    stack_size = 10,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib_RecipeGenerator.create {
    product = "egg-collecting-station",
    themes = {{"building", 2}, {"machine", 2}, {"lamp", 5}, {"window", 5}},
    default_theme_level = 2,
    category = "sosciencity-architecture",
    unlock = "huwan-genetic-neogenesis"
}

Tirislib_Entity.create {
    type = "container",
    name = "egg-collecting-station",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "egg-collecting-station"},
    max_health = 200,
    inventory_size = 20,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    picture = {
        filename = "__sosciencity-graphics__/graphics/entity/placeholder.png",
        priority = "high",
        width = 192,
        height = 192,
        scale = 0.5,
        frame_count = 1
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13
}:set_size(3, 3):copy_localisation_from_item()
