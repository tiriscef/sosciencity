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
        main_entity = "improvised-hut",
        entity_only = true,
        mining_result = {type = "item", name = "lumber", amount_min = 2, amount_max = 5},
        description_prefix = {"entity-description.improvised-hut"}
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
        main_entity = "improvised-hut",
        mining_result = {type = "item", name = "lumber", amount_min = 2, amount_max = 5},
        description_prefix = {"entity-description.improvised-hut"}
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
        tech_level = 2
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
        tech_level = 4
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

if Sosciencity.Config.DEBUG then
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
        tech_level = 0
    }

    housing_prototype_details["test-house-2"] = {
        picture = {
            filename = "__sosciencity-graphics__/graphics/entity/placeholder.png",
            priority = "high",
            width = 192,
            height = 192,
            scale = 0.5
        },
        icon = "placeholder",
        width = 3,
        height = 3,
        tech_level = 0
    }

    housing_prototype_details["test-house-3"] = {
        picture = {
            filename = "__sosciencity-graphics__/graphics/entity/placeholder.png",
            priority = "high",
            width = 192,
            height = 192,
            scale = 0.5
        },
        icon = "placeholder",
        width = 3,
        height = 3,
        tech_level = 0
    }
end

for house_name, details in pairs(housing_prototype_details) do
    details.main_entity = details.main_entity or house_name
    local house_def = Housing.values[house_name] or Housing.values[details.main_entity]

    if details.entity_only or details.main_entity ~= house_name then
        Sosciencity.create_house_entity(house_name, details, house_def)
    else
        Sosciencity.create_house(house_name, details, house_def)
    end
end

if Sosciencity.Config.DEBUG then
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
    stack_size = Sosciencity.Config.building_stacksize,
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
    stack_size = Sosciencity.Config.building_stacksize,
    localised_name = {"entity-name.improvised-hut"}
}
