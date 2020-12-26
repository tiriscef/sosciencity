local function create_test_container(name)
    Tirislib_Item.create {
        type = "item",
        name = "test-" .. name,
        icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
        icon_size = 64,
        subgroup = "sosciencity-infrastructure",
        order = "aab",
        place_result = "test-" .. name,
        stack_size = 10,
        localised_name = "test-" .. name
    }

    Tirislib_RecipeGenerator.create {
        product = "test-" .. name
    }

    Tirislib_Entity.create {
        type = "container",
        name = "test-" .. name,
        icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
        icon_size = 64,
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.5, result = "test-" .. name},
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
        localised_name = "test-" .. name
    }:set_size(3, 3)
end

create_test_container("composter")
create_test_container("compost-output")
create_test_container("market")
create_test_container("hospital")
create_test_container("night-club")
create_test_container("pharmacy")

local function create_test_assembling_machine(name)
    Tirislib_Item.create {
        type = "item",
        name = "test-" .. name,
        icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
        icon_size = 64,
        subgroup = "sosciencity-infrastructure",
        order = "aab",
        place_result = "test-" .. name,
        stack_size = 10,
        localised_name = "test-" .. name
    }

    Tirislib_RecipeGenerator.create {
        product = "test-" .. name
    }

    Tirislib_Entity.create {
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
        animation = {
            filename = "__sosciencity-graphics__/graphics/entity/placeholder.png",
            priority = "high",
            width = 192,
            height = 192,
            scale = 0.5,
            frame_count = 1
        },
        crafting_speed = 1,
        crafting_categories = {"sosciencity-fishery"},
        energy_usage = "50kW",
        energy_source = {
            type = "electric",
            usage_priority = "secondary-input",
            emissions_per_minute = 1,
            drain = "0W"
        },
        localised_name = "test-" .. name
    }:set_size(3, 3)
end
