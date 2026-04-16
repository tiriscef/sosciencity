local function create_test_container(name)
    local full_name = "test-" .. name

    Tirislib.Item.create {
        type = "item",
        name = full_name,
        icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
        icon_size = 64,
        subgroup = "sosciencity-infrastructure",
        order = "aab",
        place_result = full_name,
        stack_size = Sosciencity_Config.building_stacksize,
        localised_name = full_name
    }

    Tirislib.RecipeGenerator.create_from_prototype {
        results = {
            {type = "item", name = full_name, amount = 1}
        }
    }

    Tirislib.Entity.create {
        type = "container",
        name = full_name,
        icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
        icon_size = 64,
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.5, result = full_name},
        max_health = 500,
        corpse = "small-remnants",
        inventory_size = 64,
        vehicle_impact_sound = {
            filename = "__base__/sound/car-metal-impact.ogg",
            volume = 0.65
        },
        picture = {
            filename = "__sosciencity-graphics__/graphics/entity/placeholder.png",
            priority = "high",
            width = 192,
            height = 192,
            scale = 0.5
        },
        circuit_wire_connection_point = circuit_connector_definitions["chest"].points,
        circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
        circuit_wire_max_distance = 13,
        localised_name = full_name
    }:set_size(3, 3)

    Sosciencity_Config.add_eei(full_name)
end

create_test_container("composter")
create_test_container("compost-output")
create_test_container("market")
create_test_container("hospital")
create_test_container("night-club")
create_test_container("pharmacy")
create_test_container("psych-ward")
create_test_container("upbringing-station")
create_test_container("egg-collector")
create_test_container("dumpster")

-- test-water-distributer must be a storage-tank so it can hold fluid for entity.remove_fluid
Tirislib.Item.create {
    type = "item",
    name = "test-water-distributer",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "aab",
    place_result = "test-water-distributer",
    stack_size = Sosciencity_Config.building_stacksize,
    localised_name = "test-water-distributer"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "test-water-distributer", amount = 1}
    }
}

Tirislib.Entity.create {
    type = "storage-tank",
    name = "test-water-distributer",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "test-water-distributer"},
    max_health = 500,
    corpse = "small-remnants",
    fluid_box = {
        volume = 10000,
        pipe_covers = pipecoverspictures(),
        pipe_connections = {
            {position = {0, -1}, direction = defines.direction.north},
            {position = {1,  0}, direction = defines.direction.east},
            {position = {0,  1}, direction = defines.direction.south},
            {position = {-1, 0}, direction = defines.direction.west}
        }
    },
    pictures = {
        picture = {
            filename = "__sosciencity-graphics__/graphics/entity/placeholder.png",
            width = 192,
            height = 192,
            scale = 0.5
        },
        fluid_background = Tirislib.Entity.get_empty_sprite(),
        window_background = Tirislib.Entity.get_empty_sprite(),
        flow_sprite = Tirislib.Entity.get_empty_sprite(),
        gas_flow = Tirislib.Entity.get_empty_animation()
    },
    flow_length_in_ticks = 60,
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    localised_name = "test-water-distributer",
    window_bounding_box = Tirislib.Entity.get_selection_box(0, 0),
}:set_size(3, 3)

local function create_test_assembling_machine(name, categories)
    Tirislib.Item.create {
        type = "item",
        name = "test-" .. name,
        icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
        icon_size = 64,
        subgroup = "sosciencity-infrastructure",
        order = "aab",
        place_result = "test-" .. name,
        stack_size = Sosciencity_Config.building_stacksize,
        localised_name = "test-" .. name
    }

    Tirislib.RecipeGenerator.create_from_prototype {
        results = {
            {type = "item", name = "test-" .. name, amount = 1}
        }
    }

    Tirislib.Entity.create {
        type = "assembling-machine",
        name = "test-" .. name,
        icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
        icon_size = 64,
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.5, result = "arboretum"},
        max_health = 400,
        corpse = "arboretum-remnants",
        vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
        repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
        open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
        close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
        module_specification = {
            module_slots = 2
        },
        allowed_effects = {"productivity", "consumption", "speed", "pollution"},
        graphics_set = {
            animation = {
                filename = "__sosciencity-graphics__/graphics/entity/placeholder.png",
                priority = "high",
                width = 192,
                height = 192,
                scale = 0.5,
                frame_count = 1
            }
        },
        crafting_speed = 1,
        crafting_categories = categories,
        energy_usage = "50kW",
        energy_source = {
            type = "electric",
            usage_priority = "secondary-input",
            emissions_per_minute = {pollution = 1},
            drain = "0W"
        },
        localised_name = "test-" .. name
    }:set_size(3, 3)
end

create_test_assembling_machine("gene-lab", {"sosciencity-reproductive-gene-lab"})
create_test_assembling_machine("kitchen-for-all", {"sosciencity-kitchen-for-all"})

create_test_container("ember-manufactory")
create_test_container("orchid-manufactory")
