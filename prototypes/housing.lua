require("constants.housing")
require("constants.castes")

local data_details = {
    ["test-house"] = {
        picture = {
            filename = "__sosciencity-graphics__/graphics/entity/placeholder.png",
            priority = "high",
            width = 192,
            height = 192,
            scale = 0.5
        },
        width = 5,
        height = 3,
        tech_level = 0
    },
    ["improvised-hut"] = {
        picture = {
            layers = {
                {
                    filename = "__sosciencity-graphics__/graphics/entity/improvised-hut/improvised-hut-1.png",
                    priority = "high",
                    width = 96,
                    height = 96,
                    shift = {0.5, -0.5},
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/improvised-hut/improvised-hut-hr-1.png",
                        priority = "high",
                        width = 192,
                        height = 192,
                        shift = {0.5, -0.5},
                        scale = 0.5
                    }
                },
                {
                    filename = "__sosciencity-graphics__/graphics/entity/improvised-hut/improvised-hut-shadowmap-1.png",
                    priority = "high",
                    width = 96,
                    height = 96,
                    shift = {0.5, -0.5},
                    draw_as_shadow = true,
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/improvised-hut/improvised-hut-shadowmap-hr-1.png",
                        priority = "high",
                        width = 192,
                        height = 192,
                        shift = {0.5, -0.5},
                        scale = 0.5,
                        draw_as_shadow = true
                    }
                }
            }
        },
        width = 2,
        height = 2,
        tech_level = 0,
        improvised = true
    }
}

local housing_unlocking_tech = {
    [0] = nil,
    [1] = "architecture-1",
    [2] = "architecture-2",
    [3] = "architecture-3",
    [4] = "architecture-4",
    [5] = "architecture-5",
    [6] = "architecture-6",
    [7] = "architecture-7"
}

local function get_inventory_size(house)
    return 10 * math.floor(math.log(house.room_count, 10))
end

for house_name, house in pairs(Housing.values) do
    local orderstring = string.format("%02d", house.comfort) .. string.format("%09d", house.room_count)
    local details = data_details[house_name]

    local item_prototype =
        Tirislib_Item.create {
        type = "item",
        name = house_name,
        icon = "__sosciencity-graphics__/graphics/icon/" .. house_name .. ".png",
        icon_size = 64,
        subgroup = "sosciencity-housing",
        order = orderstring,
        stack_size = details.stack_size or 20,
        place_result = house_name,
        localised_description = {
            "item-description.housing",
            {"item-description." .. house_name},
            house.room_count,
            {"color-scale." .. house.comfort, {"comfort-scale." .. house.comfort}},
            {"description.sos-details", house.comfort},
            {"caste-name." .. Castes(house.caste).name}
        }
    }

    local tech_level = details.tech_level
    Tirislib_Tables.set_fields(item_prototype, details.distinctions)

    local ingredient_themes = {{"buildinger", house.room_count, tech_level}}

    Tirislib_RecipeGenerator.create {
        product = house_name,
        themes = ingredient_themes,
        unlock = housing_unlocking_tech[tech_level],
        category = "sosciencity-architecture"
    }

    Tirislib_Entity.create {
        type = "container",
        name = house_name,
        order = orderstring,
        icon = "__sosciencity-graphics__/graphics/icon/" .. house_name .. ".png",
        icon_size = 64,
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.5, result = house_name},
        max_health = 500,
        corpse = "small-remnants", -- TODO
        open_sound = details.open_sound or {filename = "__base__/sound/metallic-chest-open.ogg", volume = 0.65}, -- TODO sounds
        close_sound = details.close_sound or {filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7}, -- TODO
        inventory_size = get_inventory_size(house),
        vehicle_impact_sound = {
            filename = "__base__/sound/car-metal-impact.ogg",
            volume = 0.65
        },
        picture = details.picture,
        circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
        circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
        circuit_wire_max_distance = 13
    }:set_size(details.width, details.height)
end
