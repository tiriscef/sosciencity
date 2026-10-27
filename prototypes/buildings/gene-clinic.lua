local sprites = require("__sosciencity-graphics__.graphics.entity.gene-clinic.sprite-data")

Tirislib.Item.create {
    type = "item",
    name = "gene-clinic",
    icon = "__sosciencity-graphics__/graphics/icon/gene-clinic.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "fac",
    place_result = "gene-clinic",
    stack_size = Sosciencity.Config.building_stacksize,
    pictures = Sosciencity.Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    results = {{type = "item", name = "gene-clinic", amount = 1}},
    ingredients = {
        {theme = "building", amount = 2}, {theme = "machine", amount = 2}, -- TODO actual themes
        {type = "item", name = "architectural-concept", amount = 1}
    },
    default_theme_level = 4,
    unlock = "in-situ-gene-editing"
}

Tirislib.Entity.create {
    type = "container",
    name = "gene-clinic",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "gene-clinic"},
    max_health = 200,
    inventory_size = 10,
    inventory_type = "with_filters_and_bar",
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    picture = Tirislib.Entity.create_picture_from_sprite_data(sprites.static),
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13
}:set_size(7, 7):copy_icon_from_item()
Sosciencity.configure_building("gene-clinic")
