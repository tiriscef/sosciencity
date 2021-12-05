Tirislib_Item.create {
    type = "item",
    name = "waste-dump",
    icon = "__sosciencity-graphics__/graphics/icon/waste-dump.png",
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
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "waste-dump"},
    max_health = 200,
    inventory_size = 50,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    picture = Tirislib_Entity.create_standard_picture {
        path = "__sosciencity-graphics__/graphics/entity/waste-dump/waste-dump",
        shift = {1.0, 0.0},
        width = 16,
        height = 8,
        shadowmap = true,
        glow = true
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13
}:set_size(12, 6):copy_localisation_from_item():copy_icon_from_item()
Sosciencity_Config.add_eei("waste-dump")
