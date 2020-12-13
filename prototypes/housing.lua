require("constants.housing")
require("constants.castes")

-- things that are needed to create the prototype, but shouldn't be in memory during the control stage
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
        tech_level = 0,
        main_entity = "test-house"
    },
    ["improvised-hut"] = {
        picture = {
            layers = {
                {
                    filename = "__sosciencity-graphics__/graphics/entity/improvised-hut/improvised-hut-1.png",
                    priority = "high",
                    width = 128,
                    height = 128,
                    shift = {0.5, -0.5},
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/improvised-hut/improvised-hut-hr-1.png",
                        priority = "high",
                        width = 256,
                        height = 256,
                        shift = {0.5, -0.5},
                        scale = 0.5
                    }
                },
                {
                    filename = "__sosciencity-graphics__/graphics/entity/improvised-hut/improvised-hut-shadowmap-1.png",
                    priority = "high",
                    width = 128,
                    height = 128,
                    shift = {0.5, -0.5},
                    draw_as_shadow = true,
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/improvised-hut/improvised-hut-shadowmap-hr-1.png",
                        priority = "high",
                        width = 256,
                        height = 256,
                        shift = {0.5, -0.5},
                        scale = 0.5,
                        draw_as_shadow = true
                    }
                }
            }
        },
        width = 3,
        height = 3,
        tech_level = 0,
        main_entity = "improvised-hut"
    },
    ["improvised-hut-2"] = {
        picture = {
            layers = {
                {
                    filename = "__sosciencity-graphics__/graphics/entity/improvised-hut/improvised-hut-2.png",
                    priority = "high",
                    width = 128,
                    height = 128,
                    shift = {0.5, -0.5},
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/improvised-hut/improvised-hut-hr-2.png",
                        priority = "high",
                        width = 256,
                        height = 256,
                        shift = {0.5, -0.5},
                        scale = 0.5
                    }
                },
                {
                    filename = "__sosciencity-graphics__/graphics/entity/improvised-hut/improvised-hut-shadowmap-2.png",
                    priority = "high",
                    width = 128,
                    height = 128,
                    shift = {0.5, -0.5},
                    draw_as_shadow = true,
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/improvised-hut/improvised-hut-shadowmap-hr-2.png",
                        priority = "high",
                        width = 256,
                        height = 256,
                        shift = {0.5, -0.5},
                        scale = 0.5,
                        draw_as_shadow = true
                    }
                }
            }
        },
        width = 3,
        height = 3,
        tech_level = 0,
        icon = "improvised-hut",
        main_entity = "improvised-hut"
    },
    ["boring-brick-house"] = {
        picture = {
            layers = {
                {
                    filename = "__sosciencity-graphics__/graphics/entity/house/house-1.png",
                    priority = "high",
                    width = 320,
                    height = 256,
                    shift = {1, -1},
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/house/house-1-hr.png",
                        priority = "high",
                        width = 640,
                        height = 512,
                        shift = {1, -1},
                        scale = 0.5
                    }
                },
                {
                    filename = "__sosciencity-graphics__/graphics/entity/house/house-1-shadowmap.png",
                    priority = "high",
                    width = 320,
                    height = 256,
                    shift = {1, -1},
                    draw_as_shadow = true,
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/house/house-1-shadowmap-hr.png",
                        priority = "high",
                        width = 640,
                        height = 512,
                        shift = {1, -1},
                        scale = 0.5,
                        draw_as_shadow = true
                    }
                }
            }
        },
        width = 8,
        height = 6,
        tech_level = 2,
        main_entity = "boring-brick-house"
    },
    ["khrushchyovka"] = {
        picture = {
            layers = {
                {
                    filename = "__sosciencity-graphics__/graphics/entity/khrushchyovka/khrushchyovka.png",
                    priority = "high",
                    width = 256,
                    height = 320,
                    shift = {0.5, -2.5},
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/khrushchyovka/khrushchyovka-hr.png",
                        priority = "high",
                        width = 512,
                        height = 640,
                        shift = {0.5, -2.5},
                        scale = 0.5
                    }
                },
                {
                    filename = "__sosciencity-graphics__/graphics/entity/khrushchyovka/khrushchyovka-shadowmap.png",
                    priority = "high",
                    width = 256,
                    height = 320,
                    shift = {0.5, -2.5},
                    draw_as_shadow = true,
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/khrushchyovka/khrushchyovka-shadowmap-hr.png",
                        priority = "high",
                        width = 512,
                        height = 640,
                        shift = {0.5, -2.5},
                        scale = 0.5,
                        draw_as_shadow = true
                    }
                }
            }
        },
        width = 5,
        height = 3,
        tech_level = 1,
        main_entity = "khrushchyovka"
    },
    ["sheltered-house"] = {
        picture = {
            layers = {
                {
                    filename = "__sosciencity-graphics__/graphics/entity/sheltered-house/sheltered-house-hr.png",
                    priority = "high",
                    width = 576,
                    height = 448,
                    shift = {0.0, 0.0},
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/sheltered-house/sheltered-house-hr.png",
                        priority = "high",
                        width = 576,
                        height = 448,
                        shift = {0.0, 0.0},
                        scale = 0.5
                    }
                },
                {
                    filename = "__sosciencity-graphics__/graphics/entity/sheltered-house/sheltered-house-shadowmap-hr.png",
                    priority = "high",
                    width = 576,
                    height = 448,
                    shift = {0.0, 0.0},
                    draw_as_shadow = true,
                    hr_version = {
                        filename = "__sosciencity-graphics__/graphics/entity/sheltered-house/sheltered-house-shadowmap-hr.png",
                        priority = "high",
                        width = 576,
                        height = 448,
                        shift = {0.0, 0.0},
                        scale = 0.5,
                        draw_as_shadow = true
                    }
                }
            }
        },
        width = 7,
        height = 5,
        tech_level = 1,
        main_entity = "sheltered-house"
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
    return 5 * math.ceil(math.log(house.room_count, 10))
end

local function get_order(house)
    return string.format("%02d", house.comfort) .. string.format("%09d", house.room_count)
end

local function get_localised_qualities(house)
    local ret = {""}

    for _, quality in pairs(house.qualities) do
        ret[#ret+1] = {"housing-quality." .. quality}
        ret[#ret+1] = "  "
    end

    return ret
end

local function create_item(house_name, house, details)
    local item_prototype =
        Tirislib_Item.create {
        type = "item",
        name = house_name,
        icon = "__sosciencity-graphics__/graphics/icon/" .. (details.icon or house_name) .. ".png",
        icon_size = 64,
        subgroup = "sosciencity-housing",
        order = get_order(house),
        stack_size = details.stack_size or 20,
        place_result = house_name,
        pictures = Sosciencity_Config.blueprint_on_belt,
        localised_description = {
            "item-description.housing",
            house.room_count,
            {"color-scale." .. house.comfort, {"comfort-scale." .. house.comfort}},
            {"description.sos-details", house.comfort},
            get_localised_qualities(house)
        }
    }

    Tirislib_Tables.set_fields(item_prototype, details.distinctions)
end

local function create_recipe(house_name, house, details)
    local tech_level = details.tech_level
    local ingredient_themes = {
        {"building", house.room_count, tech_level}, 
        {"furnishing", house.room_count, house.comfort}
    }

    Tirislib_RecipeGenerator.create {
        product = house_name,
        themes = ingredient_themes,
        unlock = housing_unlocking_tech[tech_level],
        category = "sosciencity-architecture"
    }
end

local function create_entity(house_name, house, details)
    local entity =
        Tirislib_Entity.create {
        type = "container",
        name = house_name,
        order = get_order(house),
        icon = "__sosciencity-graphics__/graphics/icon/" .. (details.icon or house_name) .. ".png",
        icon_size = 64,
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.5},
        max_health = 500,
        corpse = "small-remnants",
        open_sound = details.open_sound or {filename = "__base__/sound/metallic-chest-open.ogg", volume = 0.65},
        close_sound = details.close_sound or {filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7},
        inventory_size = get_inventory_size(house),
        vehicle_impact_sound = {
            filename = "__base__/sound/car-metal-impact.ogg",
            volume = 0.65
        },
        picture = details.picture,
        circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
        circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
        circuit_wire_max_distance = 13,
        enable_inventory_bar = false,
        localised_name = {"entity-name." .. details.main_entity},
        localised_description = {"entity-description." .. details.main_entity}
    }:set_size(details.width, details.height)

    Sosciencity_Config.add_eei_size(details.width, details.height)

    if details.main_entity ~= "improvised-hut" then
        entity:add_mining_result({name = details.main_entity, amount = 1})
        entity:copy_localisation_from_item(details.main_entity)
    end
end

for house_name, house in pairs(Housing.values) do
    local details = data_details[house_name]

    if details.main_entity == house_name and house_name ~= "improvised-hut" then
        create_item(house_name, house, details)
        create_recipe(house_name, house, details)
    end

    create_entity(house_name, house, details)
end
