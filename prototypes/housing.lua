local Housing = require("constants.housing")

-- things that are needed to create the prototype, but shouldn't be in memory during the control stage
local housing_prototype_details = {
    ["improvised-hut"] = {
        picture = Tirislib.Entity.create_standard_picture {
            path = "__sosciencity-graphics__/graphics/entity/improvised-hut/improvised-hut-1",
            width = 6,
            height = 6,
            shift = {1.0, 0.0},
            shadowmap = true
        },
        width = 4,
        height = 4,
        tech_level = 0,
        main_entity = "improvised-hut"
    },
    ["improvised-hut-2"] = {
        picture = Tirislib.Entity.create_standard_picture {
            path = "__sosciencity-graphics__/graphics/entity/improvised-hut/improvised-hut-2",
            width = 6,
            height = 6,
            shift = {1.0, 0.0},
            shadowmap = true
        },
        width = 4,
        height = 4,
        tech_level = 0,
        icon = "improvised-hut",
        main_entity = "improvised-hut"
    },
    --[[["boring-brick-house"] = {
        picture = {
            layers = {
                {
                    filename = "__sosciencity-graphics__/graphics/entity/house/house-1-hr.png",
                    priority = "high",
                    width = 640,
                    height = 512,
                    shift = {1, -1},
                    scale = 0.5
                },
                {
                    filename = "__sosciencity-graphics__/graphics/entity/house/house-1-shadowmap-hr.png",
                    priority = "high",
                    width = 640,
                    height = 512,
                    shift = {1, -1},
                    scale = 0.5,
                    draw_as_shadow = true
                }
            }
        },
        width = 8,
        height = 6,
        tech_level = 3,
        main_entity = "boring-brick-house"
    },]]
    ["khrushchyovka"] = {
        picture = Tirislib.Entity.create_standard_picture {
            path = "__sosciencity-graphics__/graphics/entity/khrushchyovka/khrushchyovka",
            width = 13,
            height = 13,
            shift = {3.0, -3.5},
            shadowmap = true,
            glow = true
        },
        width = 7,
        height = 4,
        tech_level = 2,
        main_entity = "khrushchyovka"
    },
    ["sheltered-house"] = {
        picture = Tirislib.Entity.create_standard_picture {
            path = "__sosciencity-graphics__/graphics/entity/sheltered-house/sheltered-house",
            width = 29,
            height = 20,
            shift = {1.75, 0.3},
            scale = 0.65,
            shadowmap = true,
            lightmap = true,
            glow = true
        },
        width = 11,
        height = 7,
        tech_level = 4,
        main_entity = "sheltered-house"
    },
    ["small-prefabricated-house"] = {
        picture = Tirislib.Entity.create_standard_picture {
            path = "__sosciencity-graphics__/graphics/entity/small-prefabricated-house/small-prefabricated-house",
            width = 14,
            height = 10,
            center = {3.5, 6.5},
            --scale = 0.625,
            shadowmap = true,
            glow = true
        },
        width = 5,
        height = 5,
        tech_level = 2
    },
    ["bunkerhouse"] = {
        picture = {
            layers = {
                {
                    filename = "__sosciencity-graphics__/graphics/entity/bunkerhouse/bunkerhouse-hr.png",
                    priority = "high",
                    width = 768,
                    height = 576,
                    shift = {2.0, -0.5},
                    scale = 0.5
                },
                {
                    filename = "__sosciencity-graphics__/graphics/entity/bunkerhouse/bunkerhouse-shadowmap-hr.png",
                    priority = "high",
                    width = 768,
                    height = 576,
                    shift = {2.0, -0.5},
                    scale = 0.5,
                    draw_as_shadow = true
                }
            }
        },
        width = 8,
        height = 6,
        tech_level = 2
    },
    ["huwanic-mansion"] = {
        picture = Tirislib.Entity.create_standard_picture {
            path = "__sosciencity-graphics__/graphics/entity/huwanic-mansion/huwanic-mansion",
            width = 22,
            height = 20,
            shift = {5.5, -3.0},
            shadowmap = true,
            lightmap = true,
            glow = true
        },
        width = 9,
        height = 8,
        tech_level = 5
    },
    ["house5"] = {
        picture = Tirislib.Entity.create_standard_picture {
            path = "__sosciencity-graphics__/graphics/entity/house5/house5",
            width = 27,
            height = 21,
            shift = {7.75, -6.0},
            shadowmap = true,
            lightmap = true,
            glow = true
        },
        width = 10,
        height = 8,
        tech_level = 6
    },
    ["house1"] = {
        picture = Tirislib.Entity.create_standard_picture {
            path = "__sosciencity-graphics__/graphics/entity/house1/house1",
            width = 13,
            height = 10,
            center = {4.0, 6.0},
            shadowmap = true,
            glow = true
        },
        width = 6,
        height = 6,
        tech_level = 1
    },
    ["big-living-container"] = {
        picture = Tirislib.Entity.create_standard_picture {
            path = "__sosciencity-graphics__/graphics/entity/big-living-container/big-living-container",
            width = 14,
            height = 8,
            center = {5.0, 4.0},
            shadowmap = true,
            lightmap = true,
            glow = true
        },
        width = 8,
        height = 6,
        tech_level = 1
    },
    ["living-container"] = {
        picture = Tirislib.Entity.create_standard_picture {
            path = "__sosciencity-graphics__/graphics/entity/living-container/living-container",
            width = 8,
            height = 7,
            shift = {0.5, 0.0},
            shadowmap = true,
            glow = true
        },
        width = 5,
        height = 5,
        tech_level = 0
    },
    ["barrack-container"] = {
        picture = Tirislib.Entity.create_standard_picture {
            path = "__sosciencity-graphics__/graphics/entity/barrack-container/barrack-container",
            width = 19,
            height = 12,
            shift = {-0.25, 1.25},
            scale = 1.2,
            shadowmap = true,
            lightmap = true,
            glow = true
        },
        width = 8,
        height = 5,
        tech_level = 2
    },
    ["balcony-house"] = {
        picture = Tirislib.Entity.create_standard_picture {
            path = "__sosciencity-graphics__/graphics/entity/balcony-house/balcony-house",
            width = 22.390625,
            height = 18.796875,
            shift = {4.9, 0.0},
            scale = 0.8,
            shadowmap = true,
            lightmap = true,
            glow = true
        },
        width = 7,
        height = 6,
        tech_level = 3
    },
    ["octopus-complex"] = {
        picture = Tirislib.Entity.create_standard_picture {
            path = "__sosciencity-graphics__/graphics/entity/octopus-complex/octopus-complex",
            width = 24,
            height = 17,
            shift = {0.0, 0.0},
            shadowmap = true,
            lightmap = true,
            glow = true
        },
        width = 12,
        height = 10,
        tech_level = 6
    },
    ["spring-house"] = {
        picture = Tirislib.Entity.create_standard_picture {
            path = "__sosciencity-graphics__/graphics/entity/summer-house/summer-house",
            width = 13,
            height = 9,
            shift = {1.5, 0.6},
            shadowmap = true,
            lightmap = true,
            glow = true
        },
        width = 8,
        height = 6,
        tech_level = 1
    },
    ["summer-house"] = {
        picture = Tirislib.Entity.create_standard_picture {
            path = "__sosciencity-graphics__/graphics/entity/spring-house/spring-house",
            width = 16,
            height = 14,
            shift = {1.7, 0.0},
            scale = 0.8,
            shadowmap = true,
            lightmap = true,
            glow = true
        },
        width = 8,
        height = 5,
        tech_level = 3
    },
    ["barrack"] = {
        picture = Tirislib.Entity.create_standard_picture {
            path = "__sosciencity-graphics__/graphics/entity/barrack/barrack",
            width = 9,
            height = 10,
            center = {3.0, 5.5},
            shadowmap = true,
            glow = true
        },
        width = 4,
        height = 7,
        tech_level = 3
    }
}

if Sosciencity_Config.DEBUG then
    housing_prototype_details["test-house"] = {
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
    }
end

local unlocks = {
    [0] = "infrastructure-1",
    [1] = "architecture-1",
    [2] = "architecture-2",
    [3] = "architecture-3",
    [4] = "architecture-4",
    [5] = "architecture-5",
    [6] = "architecture-6",
    [7] = "architecture-7"
}

local function get_inventory_size(house)
    return 5 * math.ceil(1 + math.log(house.room_count, 10))
end

local function get_order(house)
    return string.format("%02d", house.comfort) .. string.format("%09d", house.room_count)
end

local function get_localised_qualities(house)
    local ret = {""}

    for _, quality in pairs(house.qualities) do
        ret[#ret + 1] = {"housing-quality." .. quality}
        ret[#ret + 1] = "  "
    end

    return ret
end

local function get_localised_description(house_name, house)
    local ret = {""}

    if Tirislib.String.begins_with(house_name, "improvised-hut") then
        ret[#ret + 1] = {"entity-description.improvised-hut"}
    end

    Tirislib.Locales.append(
        ret,
        {
            "sosciencity-util.housing",
            tostring(house.room_count),
            {"color-scale." .. house.comfort, {"comfort-scale." .. house.comfort}},
            {"description.sos-details", tostring(house.comfort)},
            get_localised_qualities(house)
        },
        "\n\n",
        {
            "sosciencity-util.official-looking-point",
            {"sosciencity.range"},
            {"sosciencity.show-range", tostring(100)} -- 2 times the "by foot"-range (50)
        },
        "\n",
        {"sosciencity.grey", {"range-description.housing"}}
    )

    return ret
end

local function create_item(house_name, house, details)
    local item_prototype =
        Tirislib.Item.create {
        type = "item",
        name = house_name,
        icon = "__sosciencity-graphics__/graphics/icon/" .. (details.icon or house_name) .. ".png",
        icon_size = 64,
        subgroup = "sosciencity-housing",
        order = get_order(house),
        stack_size = details.stack_size or Sosciencity_Config.building_stacksize,
        place_result = house_name,
        pictures = Sosciencity_Config.blueprint_on_belt
    }

    Tirislib.Tables.set_fields(item_prototype, details.distinctions)
end

local quality_effect_on_recipe = {
    sheltered = function(details, house, tech_level)
        table.insert(details.themes, {"housing_sheltered", house.room_count, tech_level})
    end,
    green = function(details, house, tech_level)
        table.insert(details.themes, {"housing_green", house.room_count, tech_level})
    end,
    technical = function(details, house, tech_level)
        table.insert(details.themes, {"housing_technical", house.room_count, tech_level})
    end,
    spacey = function(details, house, tech_level)
        -- increase the "building" theme amount
        details.themes[1][2] = details.themes[1][2] * 1.25
    end,
    compact = function(details, house, tech_level)
        -- decrease the "building" theme amount
        details.themes[1][2] = details.themes[1][2] * 0.8
    end,
    decorated = function(details, house, tech_level)
        table.insert(details.themes, {"furnishing_decorated", house.room_count, tech_level})
    end,
    simple = function(details, house, tech_level)
        -- change the normal "furnishing" theme to the simple one
        details.themes[2][1] = "simple_furnishing"
    end,
    individualistic = function(details, house, tech_level)
        details.energy_required = details.energy_required * 3
    end,
    ["copy-paste"] = function(details, house, tech_level)
        details.energy_required = details.energy_required / 2
    end,
    pompous = function(details, house, tech_level)
        details.themes[1][1] = "pompous_building"
    end,
    cheap = function(details, house, tech_level)
        details.themes[1][1] = "cheap_building"
    end,
    tall = function(details, house, tech_level)
        table.insert(details.themes, {"tall_building_structure", house.room_count, tech_level})
    end,
    low = function(details, house, tech_level)
        -- no idea
    end
}

local function create_recipe(house_name, house, details)
    local tech_level = details.tech_level
    local ingredient_themes = {
        {"building", house.room_count * 0.5, tech_level},
        {"furnishing", house.room_count, house.comfort}
    }

    local recipe_details = {
        product = house_name,
        themes = ingredient_themes,
        unlock = unlocks[tech_level],
        energy_required = house.room_count / 5,
        ingredients = {{type = "item", name = "architectural-concept", amount = 1}}
    }

    for _, quality in pairs(house.qualities) do
        quality_effect_on_recipe[quality](recipe_details, house, tech_level)
    end

    Tirislib.RecipeGenerator.create(recipe_details)
end

local function create_entity(house_name, house, details)
    local entity =
        Tirislib.Entity.create {
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
        localised_description = get_localised_description(house_name, house)
    }:set_size(details.width, details.height)

    if details.main_entity ~= "improvised-hut" then
        entity:add_mining_result({type = "item", name = details.main_entity, amount = 1})
    else
        entity:add_mining_result(
            {
                type = "item",
                name = "lumber",
                amount_min = 2,
                amount_max = 5
            }
        )
    end
end

for house_name, details in pairs(housing_prototype_details) do
    local house = Housing.values[house_name]

    -- if the main_entity isn't set, then this house is its own
    details.main_entity = details.main_entity or house_name

    if details.main_entity == house_name and house_name ~= "improvised-hut" then
        create_item(house_name, house, details)
        create_recipe(house_name, house, details)
    end

    create_entity(house_name, house, details)
    Sosciencity_Config.add_eei(house_name)
end

if Sosciencity_Config.DEBUG then
    Tirislib.Recipe.get_by_name("test-house"):clear_ingredients()
end

-- I don't understand why, but the mere existence of these items make the improvised huts deconstructable by bots
Tirislib.Item.create {
    type = "item",
    name = "improvised-placer",
    icon = "__sosciencity-graphics__/graphics/icon/improvised-hut.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "zzy",
    place_result = "improvised-hut",
    stack_size = Sosciencity_Config.building_stacksize,
    localised_name = {"entity-name.improvised-hut"}
}

Tirislib.Item.create {
    type = "item",
    name = "improvised-placer-2",
    icon = "__sosciencity-graphics__/graphics/icon/improvised-hut.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "zzz",
    place_result = "improvised-hut-2",
    stack_size = Sosciencity_Config.building_stacksize,
    localised_name = {"entity-name.improvised-hut"}
}
