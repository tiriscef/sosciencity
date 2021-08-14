Tirislib_Item.create {
    type = "item",
    name = "market-hall",
    icon = "__sosciencity-graphics__/graphics/icon/market-hall.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "aab",
    place_result = "market-hall",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib_RecipeGenerator.create {
    product = "market-hall",
    themes = {{"building", 2}},
    ingredients = {
        {type = "item", name = "window", amount = 20},
        {type = "item", name = "architectural-concept", amount = 1}
    },
    default_theme_level = 1,
    unlock = "architecture-1"
}

Tirislib_Entity.create {
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
    picture = {
        layers = {
            {
                filename = "__sosciencity-graphics__/graphics/entity/market-hall/market-hall.png",
                priority = "high",
                width = 224,
                height = 224,
                hr_version = {
                    filename = "__sosciencity-graphics__/graphics/entity/market-hall/market-hall-hr.png",
                    priority = "high",
                    width = 448,
                    height = 448,
                    scale = 0.5
                }
            },
            {
                filename = "__sosciencity-graphics__/graphics/entity/market-hall/market-hall-shadowmap.png",
                priority = "high",
                width = 224,
                height = 224,
                draw_as_shadow = true,
                hr_version = {
                    filename = "__sosciencity-graphics__/graphics/entity/market-hall/market-hall-shadowmap-hr.png",
                    priority = "high",
                    width = 448,
                    height = 448,
                    scale = 0.5,
                    draw_as_shadow = true
                }
            }
        }
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13
}:set_size(5, 5):copy_localisation_from_item()
