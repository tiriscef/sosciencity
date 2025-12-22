Tirislib.Item.create {
    type = "item",
    name = "upbringing-station",
    icon = "__sosciencity-graphics__/graphics/icon/upbringing-station.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "daa",
    place_result = "upbringing-station",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "upbringing-station",
    themes = {{"building", 2}, {"machine", 2}},
    ingredients = {
        {type = "item", name = "hehe", amount = 25},
        {type = "item", name = "architectural-concept", amount = 1}
    },
    default_theme_level = 0,
    unlock = "upbringing"
}

Tirislib.Entity.create {
    type = "container",
    name = "upbringing-station",
    icon = "__sosciencity-graphics__/graphics/icon/upbringing-station.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "upbringing-station"},
    max_health = 200,
    inventory_size = 20,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    picture = Tirislib.Entity.create_standard_picture {
        path = "__sosciencity-graphics__/graphics/entity/upbringing-station/upbringing-station",
        shift = {1.0, 0.0},
        width = 10,
        height = 10,
        shadowmap = true,
        glow = true,
        lightmap = true
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13
}:set_size(6, 6)
Sosciencity_Config.add_eei("upbringing-station")
