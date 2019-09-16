Item:create {
    type = "item",
    name = "clockwork-housing-1",
    icon = "__sosciencity__/graphics/icon/note.png",
    icon_size = 64,
    flags = {},
    subgroup = "sosciencity-clockwork-housing",
    order = "aaa",
    place_result = "clockwork-housing-1",
    stack_size = 10
}

Recipe:create {
    type = "recipe",
    name = "clockwork-housing-1",
    category = "crafting",
    enabled = false,
    energy_required = 5,
    ingredients = {},
    results = {
        {type = "item", name = "clockwork-housing-1", amount = 1}
    },
    icon = "__sosciencity__/graphics/icon/note.png",
    icon_size = 64,
    subgroup = "sosciencity-clockwork-housing",
    order = "aaa"
}--:add_unlock("clockwork-caste") --TODO

Entity:create {
    type = "container",
    name = "clockwork-housing-1",
    order = "aaa",
    icon = "__sosciencity__/graphics/icon/note.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "clockwork-housing-1"},
    max_health = 500,
    corpse = "small-remnants",
    open_sound = {filename = "__base__/sound/metallic-chest-open.ogg", volume = 0.65},
    close_sound = {filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7},
    resistances = {
        {
            type = "fire",
            percent = 90
        }
    },
    collision_box = {{-0.8, -1.3}, {0.8, 1.3}},
    selection_box = {{-1.0, -1.5}, {1.0, 1.5}},
    inventory_size = 64,
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    picture = {
        layers = {
            {
                filename = "__sosciencity__/graphics/entity/clockwork-single-container/nr.png",
                priority = "extra-high",
                width = 64,
                height = 132,
                shift = util.by_pixel(0, 36),
                hr_version = {
                    filename = "__sosciencity__/graphics/entity/clockwork-single-container/hr.png",
                    priority = "extra-high",
                    width = 128,
                    height = 264,
                    shift = util.by_pixel(0, 36),
                    scale = 0.5
                }
            },
            {
                filename = "__sosciencity__/graphics/entity/clockwork-single-container/shadow-nr.png",
                priority = "extra-high",
                width = 83,
                height = 112,
                shift = util.by_pixel(12, 7.5),
                draw_as_shadow = true,
                hr_version = {
                    filename = "__sosciencity__/graphics/entity/clockwork-single-container/shadow-hr.png",
                    priority = "extra-high",
                    width = 165,
                    height = 223,
                    shift = util.by_pixel(12.25, 8),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        }
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points,
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 9,
    enable_inventory_bar = false
}
