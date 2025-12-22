Tirislib.Item.create {
    type = "item",
    name = "medbay",
    icon = "__sosciencity-graphics__/graphics/icon/medbay.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "eaa",
    place_result = "medbay",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "medbay",
    themes = {{"building", 2}},
    ingredients = {
        {type = "item", name = "cloth", amount = 10},
        {type = "item", name = "bed", amount = 10},
        {type = "item", name = "architectural-concept", amount = 1}
    },
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
    inventory_type = "with_filters_and_bar",
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    picture = Tirislib.Entity.create_standard_picture {
        path = "__sosciencity-graphics__/graphics/entity/medbay/medbay",
        center = {3.0, 3.0},
        width = 9,
        height = 7,
        shadowmap = true,
        glow = true
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13
}:set_size(6, 6):copy_icon_from_item()
Sosciencity_Config.add_eei("medbay")
