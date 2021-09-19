-- TODO: actual graphics

Tirislib_Item.create {
    type = "item",
    name = "composting-silo",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    subgroup = "sosciencity-flora-buildings",
    order = "gaa",
    place_result = "composting-silo",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib_RecipeGenerator.create {
    product = "composting-silo",
    themes = {{"plating", 20}, {"framework", 2}},
    default_theme_level = 1,
    unlock = "open-environment-farming"
}

Tirislib_Entity.create {
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
    picture = {
        layers = {
            {
                filename = "__sosciencity-graphics__/graphics/placeholder.png",
                priority = "high",
                width = 224,
                height = 224,
                scale = 6/7
            },
            {
                filename = "__sosciencity-graphics__/graphics/icon/humus.png",
                priority = "high",
                width = 64,
                height = 64,
                scale = 1
            }
        }
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13
}:set_size(6, 6):copy_localisation_from_item():copy_icon_from_item()
