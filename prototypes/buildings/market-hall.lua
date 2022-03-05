Tirislib.Item.create {
    type = "item",
    name = "market-hall",
    icon = "__sosciencity-graphics__/graphics/icon/market-hall.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "aaa",
    place_result = "market-hall",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "market-hall",
    themes = {{"building", 2}},
    ingredients = {
        {type = "item", name = "window", amount = 20},
        {type = "item", name = "architectural-concept", amount = 1}
    },
    default_theme_level = 1,
    unlock = "infrastructure-1"
}

Tirislib.Entity.create {
    type = "container",
    name = "market-hall",
    icon = "__sosciencity-graphics__/graphics/icon/market-hall.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "market-hall"},
    max_health = 500,
    corpse = "small-remnants",
    inventory_size = 30,
    vehicle_impact_sound = {
        filename = "__base__/sound/car-metal-impact.ogg",
        volume = 0.65
    },
    picture = Tirislib.Entity.create_standard_picture {
        path = "__sosciencity-graphics__/graphics/entity/market-hall/market-hall",
        shift = {1.0, 0.0},
        width = 11,
        height = 9,
        shadowmap = true
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13
}:set_size(7, 7):copy_localisation_from_item()
Sosciencity_Config.add_eei("market-hall")
