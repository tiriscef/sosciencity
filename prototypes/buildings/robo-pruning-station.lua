Tirislib.Item.create {
    type = "item",
    name = "robo-pruning-station",
    icon = "__sosciencity-graphics__/graphics/icon/robo-pruning-station.png",
    icon_size = 64,
    subgroup = "sosciencity-flora-buildings",
    order = "hba",
    place_result = "robo-pruning-station",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "robo-pruning-station",
    themes = {{"machine", 1}, {"robo_parts", 20}},
    ingredients = {
        {type = "item", name = "silo", amount = 2},
        {type = "item", name = "architectural-concept", amount = 1}
    },
    default_theme_level = 3,
    unlock = "robo-plant-care"
}

Tirislib.Entity.create {
    type = "container",
    name = "robo-pruning-station",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "robo-pruning-station"},
    max_health = 200,
    inventory_size = 40,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    picture = Tirislib.Entity.create_standard_picture {
        path = "__sosciencity-graphics__/graphics/entity/robo-pruning-station/robo-pruning-station",
        center = {4.2, 3.5},
        width = 9,
        height = 6,
        shadowmap = true,
        glow = true
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13,
    working_sound = { -- the one of the vanilla roboports
        sound = {filename = "__base__/sound/roboport-working.ogg", volume = 0.4},
        max_sounds_per_type = 3,
        audible_distance_modifier = 0.75
    }
}:set_size(5, 3):copy_icon_from_item()
Sosciencity_Config.add_eei("robo-pruning-station")
