Tirislib.Item.create {
    type = "item",
    name = "composting-silo",
    icon = "__sosciencity-graphics__/graphics/icon/composting-silo.png",
    icon_size = 64,
    subgroup = "sosciencity-flora-buildings",
    order = "gaa",
    place_result = "composting-silo",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "composting-silo",
    themes = {{"plating", 20, 30}, {"framework", 10, 15}},
    default_theme_level = 1,
    unlock = "open-environment-farming"
}

Tirislib.Entity.create {
    type = "container",
    name = "composting-silo",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "composting-silo"},
    max_health = 200,
    inventory_size = 20,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    picture = Tirislib.Entity.create_standard_picture {
        path = "__sosciencity-graphics__/graphics/entity/composting-silo/composting-silo",
        width = 10,
        height = 8,
        shift = {1.0, 0.0},
        shadowmap = true
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13
}:set_size(6, 6):copy_localisation_from_item():copy_icon_from_item()
