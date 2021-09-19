-- TODO: actual graphics

Tirislib_Item.create {
    type = "item",
    name = "waste-dump",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    subgroup = "sosciencity-buildings",
    order = "daa",
    place_result = "waste-dump",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib_RecipeGenerator.create {
    product = "waste-dump",
    themes = {{"building", 1}},
    default_theme_level = 2,
    unlock = "infrastructure-2"
}

Tirislib_Entity.create {
    type = "container",
    name = "waste-dump",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "waste-dump"},
    max_health = 200,
    inventory_size = 50,
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
                filename = "__sosciencity-graphics__/graphics/icon/garbage.png",
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
}:set_size(6, 6):copy_localisation_from_item()
Sosciencity_Config.add_eei("waste-dump")
