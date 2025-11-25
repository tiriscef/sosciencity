Tirislib.Item.create {
    type = "item",
    name = "egg-collecting-station",
    icon = "__sosciencity-graphics__/graphics/icon/egg-collecting-station.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "dab",
    place_result = "egg-collecting-station",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "egg-collecting-station",
    themes = {{"plating", 20}, {"framework", 20}, {"brick", 20}},
    ingredients = {
        {type = "item", name = "hehe", amount = 72},
        {type = "item", name = "architectural-concept", amount = 1}
    },
    default_theme_level = 0,
    unlock = "infrastructure-1"
}

Tirislib.Entity.create {
    type = "container",
    name = "egg-collecting-station",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "egg-collecting-station"},
    max_health = 200,
    inventory_size = 20,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    picture = Tirislib.Entity.create_standard_picture {
        path = "__sosciencity-graphics__/graphics/entity/egg-collecting-station/egg-collecting-station",
        shift = {2.0 * 5 / 6, -0.5 * 5 / 6},
        width = 12,
        height = 9,
        scale = 5 / 6,
        shadowmap = true,
        glow = true
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13
}:set_size(5, 5):copy_localisation_from_item():copy_icon_from_item()
