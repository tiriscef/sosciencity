Tirislib_Item.create {
    type = "item",
    name = "test-market",
    icon = "__sosciencity__/graphics/icon/test-house.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "aab",
    place_result = "test-market",
    stack_size = 10
}

Tirislib_RecipeGenerator.create_recipe("test-market")

Tirislib_Entity.create {
    type = "container",
    name = "test-market",
    icon = "__sosciencity__/graphics/icon/test-house.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "test-market"},
    max_health = 500,
    corpse = "small-remnants", -- TODO
    inventory_size = 64,
    vehicle_impact_sound = {
        filename = "__base__/sound/car-metal-impact.ogg",
        volume = 0.65
    },
    picture = {
        filename = "__sosciencity__/graphics/entity/placeholder.png",
        priority = "high",
        width = 192,
        height = 192,
        scale = 0.5
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13
}:set_size(3, 3)

Tirislib_Item.create {
    type = "item",
    name = "test-dumpster",
    icon = "__sosciencity__/graphics/icon/test-house.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "aab",
    place_result = "test-dumpster",
    stack_size = 10
}

Tirislib_RecipeGenerator.create_recipe("test-dumpster")

Tirislib_Entity.create {
    type = "container",
    name = "test-dumpster",
    icon = "__sosciencity__/graphics/icon/test-house.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "test-dumpster"},
    max_health = 500,
    corpse = "small-remnants", -- TODO
    inventory_size = 64,
    vehicle_impact_sound = {
        filename = "__base__/sound/car-metal-impact.ogg",
        volume = 0.65
    },
    picture = {
        filename = "__sosciencity__/graphics/entity/placeholder.png",
        priority = "high",
        width = 192,
        height = 192,
        scale = 0.5
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13
}:set_size(3, 3)