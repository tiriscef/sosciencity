local sprites = require("__sosciencity-graphics__.graphics.entity.pharmacy.sprite-data")

Tirislib.Item.create {
    type = "item",
    name = "pharmacy",
    icon = "__sosciencity-graphics__/graphics/icon/pharmacy.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "gaa",
    place_result = "pharmacy",
    stack_size = Sosciencity.Config.building_stacksize,
    pictures = Sosciencity.Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "pharmacy", amount = 1}
    },
    ingredients = {
        {theme = "building", amount = 5},
        {theme = "electronics", amount = 10},
        {type = "item", name = "architectural-concept", amount = 1}
    },
    default_theme_level = 2,
    unlock = "hospital"
}

Tirislib.Entity.create {
    type = "container",
    name = "pharmacy",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "pharmacy"},
    max_health = 200,
    inventory_size = 40,
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
}:set_size(6, 6):copy_icon_from_item()
Sosciencity.configure_building("pharmacy")
