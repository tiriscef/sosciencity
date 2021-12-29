Tirislib.Item.create {
    type = "item",
    name = "composting-silo-output",
    icon = "__sosciencity-graphics__/graphics/icon/composting-silo-output.png",
    icon_size = 64,
    subgroup = "sosciencity-flora-buildings",
    order = "gab",
    place_result = "composting-silo-output",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "composting-silo-output",
    themes = {{"plating", 2}, {"framework", 2}},
    default_theme_level = 1,
    unlock = "open-environment-farming"
}

Tirislib.Entity.create {
    type = "container",
    name = "composting-silo-output",
    icon = "__sosciencity-graphics__/graphics/icon/composting-silo-output.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "composting-silo-output"},
    max_health = 200,
    inventory_size = 20,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    picture = Tirislib.Entity.create_standard_picture {
        path = "__sosciencity-graphics__/graphics/entity/composting-silo-output/composting-silo-output",
        width = 7,
        height = 5,
        shift = {1.0, 0.0},
        shadowmap = true
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13
}:set_size(3, 3):copy_localisation_from_item()
