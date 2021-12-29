-- TODO: actual graphics

Tirislib.Item.create {
    type = "item",
    name = "orchid-plant-care-station",
    icon = "__sosciencity-graphics__/graphics/icon/plant-care-station.png",
    icon_size = 64,
    subgroup = "sosciencity-flora-buildings",
    order = "gaa",
    place_result = "orchid-plant-care-station",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "orchid-plant-care-station",
    themes = {{"building", 10}},
    ingredients = {
        {type = "item", name = "silo", amount = 2},
        {type = "item", name = "architectural-concept", amount = 1}
    },
    default_theme_level = 2,
    unlock = "orchid-caste"
}

Tirislib.Entity.create {
    type = "container",
    name = "orchid-plant-care-station",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "orchid-plant-care-station"},
    max_health = 200,
    inventory_size = 40,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    picture = Tirislib.Entity.create_standard_picture {
        path = "__sosciencity-graphics__/graphics/entity/plant-care-station/plant-care-station",
        shift = {0.4, 0.0},
        width = 9,
        height = 6,
        shadowmap = true
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13
}:set_size(6, 4):copy_localisation_from_item():copy_icon_from_item()
Sosciencity_Config.add_eei("orchid-plant-care-station")
