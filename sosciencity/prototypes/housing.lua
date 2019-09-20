require("constants.housing")

for house_name, house in pairs(housing_values) do
    Item:create {
        type = "item",
        name = house_name,
        icon = "__sosciencity__/graphics/icon/" .. house_name .. ".png",
        icon_size = 64,
        subgroup = "sosciencity-housing",
        order = "aaa", -- TODO think about a good way to order them
        stack_size = 20,
        place_result = house_name
    }

    -- blank entity
    Entity:create {
        type = "container",
        name = house_name,
        order = "aaa",
        icon = "__sosciencity__/graphics/icon/" .. house_name .. ".png",
        icon_size = 64,
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.25, result = house_name},
        max_health = 500,
        corpse = "small-remnants",
        open_sound = {filename = "__base__/sound/metallic-chest-open.ogg", volume = 0.65}, -- TODO sounds
        close_sound = {filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7}, -- TODO
        collision_box = {{-2.3, -2.3}, {2.3, 2.1}},
        selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
        inventory_size = 64,
        vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
        picture = {
            filename = "__sosciencity__/graphics/entity/club.png",
            width = 405,
            height = 425,
            scale = 0.5,
            shift = util.by_pixel(32.5 / 2, -51.5 / 2)
        },
        circuit_wire_connection_point = circuit_connector_definitions["chest"].points,
        circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
        circuit_wire_max_distance = 13
    }

    -- inhabited entities
    for caste, details in pairs(house.castes) do
        Entity:create {
            type = "container",
            name = house_name .. "-" .. TYPES:get_caste_name(caste),
            order = "aaa",
            icon = "__sosciencity__/graphics/icon/" .. house_name .. ".png",
            icon_size = 64,
            flags = {"placeable-neutral", "player-creation"},
            minable = {mining_time = 2, result = house_name},
            max_health = 100 + house.capacity * 10,
            corpse = "small-remnants",
            open_sound = {filename = "__base__/sound/metallic-chest-open.ogg", volume = 0.65}, -- TODO sounds
            close_sound = {filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7}, -- TODO
            collision_box = {{-2.3, -2.3}, {2.3, 2.1}},
            selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
            inventory_size = 64,
            vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
            picture = {
                filename = "__sosciencity__/graphics/entity/club.png",
                width = 405,
                height = 425,
                scale = 0.5,
                shift = util.by_pixel(32.5 / 2, -51.5 / 2)
            },
            circuit_wire_connection_point = circuit_connector_definitions["chest"].points,
            circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
            circuit_wire_max_distance = 13
        }
    end
end
