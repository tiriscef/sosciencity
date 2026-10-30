local sprites = require("__sosciencity-graphics__.graphics.entity.psych-ward.sprite-data")

Tirislib.Item.create {
    type = "item",
    name = "psych-ward",
    icon = "__sosciencity-graphics__/graphics/icon/psych-ward.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "faa",
    place_result = "psych-ward",
    stack_size = Sosciencity.Config.building_stacksize,
    pictures = Sosciencity.Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "psych-ward", amount = 1}
    },
    ingredients = {
        {theme = "building", amount = 10},
        {theme = "furnishing", amount = 5, level = 5},
        {type = "item", name = "architectural-concept", amount = 1}
    },
    default_theme_level = 2,
    unlock = "psychiatry"
}

Tirislib.Entity.create {
    type = "container",
    name = "psych-ward",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "psych-ward"},
    max_health = 200,
    inventory_size = 10,
    inventory_type = "with_filters_and_bar",
    corpse = "small-remnants",
    impact_category = "metal",
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    picture = Tirislib.Entity.create_picture_from_sprite_data(sprites.static),
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13
}:set_size(9, 7):copy_icon_from_item()
Sosciencity.configure_building("psych-ward")
