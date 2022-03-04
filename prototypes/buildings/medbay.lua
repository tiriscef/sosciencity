-- TODO: actual graphics

Tirislib.Item.create {
    type = "item",
    name = "medbay",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "daa",
    place_result = "medbay",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "medbay",
    themes = {{"building", 2}, {"machine", 2}},
    ingredients = {{type = "item", name = "architectural-concept", amount = 1}},
    default_theme_level = 1,
    unlock = "medbay"
}

Tirislib.Entity.create {
    type = "container",
    name = "medbay",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "medbay"},
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
                scale = 5/7
            }
        }
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13
}:set_size(5, 5):copy_localisation_from_item():copy_icon_from_item()
Sosciencity_Config.add_eei("medbay")
