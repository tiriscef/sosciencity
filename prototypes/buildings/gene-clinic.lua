-- TODO: actual graphics

Tirislib.Item.create {
    type = "item",
    name = "gene-clinic",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "fac",
    place_result = "gene-clinic",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "gene-clinic",
    themes = {{"building", 2}, {"machine", 2}}, -- TODO actual themes
    ingredients = {{type = "item", name = "architectural-concept", amount = 1}},
    default_theme_level = 4,
    unlock = "in-situ-gene-editing"
}

Tirislib.Entity.create {
    type = "container",
    name = "gene-clinic",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "gene-clinic"},
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
Sosciencity_Config.add_eei("gene-clinic")
