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
        stack_size = Sosciencity.Config.building_stacksize,
        localised_name = full_name
    }

    Tirislib.RecipeGenerator.create_from_prototype {
        results = {
            {type = "item", name = full_name, amount = 1}
        }
    }

    local entity = Tirislib.Entity.create {
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

    Sosciencity.configure_building(full_name)
    return entity
end

create_test_container("composter")
create_test_container("compost-output")
create_test_container("cold-storage")
create_test_container("cold-storage-powered")
create_test_container("market")
create_test_container("hospital")
create_test_container("hospital-no-workforce")
create_test_container("night-club")
create_test_container("pharmacy")
create_test_container("psych-ward")
create_test_container("upbringing-station")
create_test_container("egg-collector")
create_test_container("dumpster")
create_test_container("fertilization-station")
create_test_container("pruning-station")
create_test_container("waste-dump")
create_test_container("immigration-port")
create_test_container("ember-manufactory")
create_test_container("orchid-manufactory")
create_test_container("mining-manufactory")

-- test-water-distributer must be a storage-tank so it can hold fluid for entity.remove_fluid
Tirislib.Item.create {
    type = "item",
    name = "test-water-distributer",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "aab",
    place_result = "test-water-distributer",
    stack_size = Sosciencity.Config.building_stacksize,
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
            {position = {1, 0},  direction = defines.direction.east},
            {position = {0, 1},  direction = defines.direction.south},
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

Sosciencity.configure_building("test-water-distributer")

Tirislib.Item.create {
    type = "item",
    name = "test-water-distributer-powered",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "aab",
    place_result = "test-water-distributer-powered",
    stack_size = Sosciencity.Config.building_stacksize,
    localised_name = "test-water-distributer-powered"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "test-water-distributer-powered", amount = 1}
    }
}

Tirislib.Entity.create {
    type = "storage-tank",
    name = "test-water-distributer-powered",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "test-water-distributer-powered"},
    max_health = 500,
    corpse = "small-remnants",
    fluid_box = {
        volume = 10000,
        pipe_covers = pipecoverspictures(),
        pipe_connections = {
            {position = {0, -1}, direction = defines.direction.north},
            {position = {1, 0},  direction = defines.direction.east},
            {position = {0, 1},  direction = defines.direction.south},
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
    localised_name = "test-water-distributer-powered",
    window_bounding_box = Tirislib.Entity.get_selection_box(0, 0),
}:set_size(3, 3)

Sosciencity.configure_building("test-water-distributer-powered")

local electric_energy_source = {
    type = "electric",
    usage_priority = "secondary-input",
    emissions_per_minute = {pollution = 1},
    drain = "0W"
}

local function create_test_assembling_machine(name, categories, energy_source)
    Tirislib.Item.create {
        type = "item",
        name = "test-" .. name,
        icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
        icon_size = 64,
        subgroup = "sosciencity-infrastructure",
        order = "aab",
        place_result = "test-" .. name,
        stack_size = Sosciencity.Config.building_stacksize,
        localised_name = "test-" .. name
    }

    Tirislib.RecipeGenerator.create_from_prototype {
        results = {
            {type = "item", name = "test-" .. name, amount = 1}
        }
    }

    local entity = Tirislib.Entity.create {
        type = "assembling-machine",
        name = "test-" .. name,
        icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
        icon_size = 64,
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.5, result = "test-" .. name},
        max_health = 400,
        --corpse = "arboretum-remnants",
        vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
        repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
        open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
        close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
        module_slots = 2,
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
        energy_source = energy_source or electric_energy_source,
        localised_name = "test-" .. name
    }:set_size(3, 3)
    return entity
end

create_test_assembling_machine("gene-lab", {"sosciencity-reproductive-gene-lab"})
create_test_assembling_machine("kitchen-for-all", {"sosciencity-kitchen-for-all"})
Sosciencity.configure_building("test-kitchen-for-all")
create_test_assembling_machine("assembling-machine", {"crafting"})
create_test_assembling_machine("farm", {"sosciencity-farming-annual", "sosciencity-farming-perennial"})
Sosciencity.configure_building("test-farm")

-- Void energy so entity.status == working as soon as a recipe is set, without needing
-- a power network on the test surface.
create_test_assembling_machine("animal-farm", {"sosciencity-animal-farming"}, {type = "void"})
Sosciencity.configure_building("test-animal-farm")

-- No ingredients so the machine is always working once the recipe is set.
Tirislib.RecipeGenerator.create_from_prototype {
    name = "sos-husbandry-null",
    category = "sosciencity-animal-farming",
    results = {{type = "item", name = "raw-fish", amount = 1}}
}

-- Test farming recipes for integration tests: no unlock so they're enabled by default,
-- which set_recipe / get_recipe require. Their names are wired into Biology.flora so
-- Biology.get_species maps them back to the right species.
Tirislib.RecipeGenerator.create_from_prototype {
    name = "test-farming-annual-bell-pepper",
    category = "sosciencity-farming-annual",
    results = {{type = "item", name = "bell-pepper", amount = 1}}
}
Tirislib.RecipeGenerator.create_from_prototype {
    name = "test-farming-perennial-olive",
    category = "sosciencity-farming-perennial",
    results = {{type = "item", name = "olive", amount = 1}}
}

-- A spoilable item that is NOT in Food.values, used by cold storage tests to verify
-- that non-food items with spoil timers are not affected by cold storage.
Tirislib.Item.create {
    type = "item",
    name = "test-spoilable-nonfood",
    icon = "__sosciencity-graphics__/graphics/icon/placeholder.png",
    icon_size = 64,
    subgroup = "sosciencity-food",
    stack_size = 50,
    spoil_ticks = 600,
    spoil_result = "expired-food",
    localised_name = "test-spoilable-nonfood"
}

create_test_assembling_machine("fishery", {"sosciencity-fishery"}, {type = "void"})
Sosciencity.configure_building("test-fishery")
create_test_assembling_machine("hunting-hut", {"sosciencity-hunting"}, {type = "void"})
Sosciencity.configure_building("test-hunting-hut")
create_test_assembling_machine("salt-pond", {"sosciencity-salt-pond"}, {type = "void"})
Sosciencity.configure_building("test-salt-pond")

-- Test fishing recipes for integration tests: no unlock so enabled by default,
-- which set_recipe / get_recipe require. Two distinct names let competition tests
-- distinguish same-recipe vs different-recipe neighbors.
Tirislib.RecipeGenerator.create_from_prototype {
    name = "test-fishing-carp",
    category = "sosciencity-fishery",
    results = {{type = "item", name = "raw-fish", amount = 1}}
}
Tirislib.RecipeGenerator.create_from_prototype {
    name = "test-fishing-salmon",
    category = "sosciencity-fishery",
    results = {{type = "item", name = "raw-fish", amount = 2}}
}

create_test_assembling_machine("social-observatory", {"sosciencity-social-observatory"}, {type = "void"})
Sosciencity.configure_building("test-social-observatory")

-- Fluid output box required so entity.set_recipe() accepts groundwater-pump recipes with fluid outputs.
local test_waterwell = create_test_assembling_machine("waterwell", {"sosciencity-groundwater-pump"}, {type = "void"})
test_waterwell.fluid_boxes = {
    {
        production_type = "output",
        volume = 1000,
        pipe_covers = pipecoverspictures(),
        pipe_connections = {{position = {0, 1}, flow_direction = "output", direction = defines.direction.south}}
    }
}
Sosciencity.configure_building("test-waterwell")

-- No-unlock recipe for normal-path tests (real groundwater-pump recipes require tech)
Tirislib.RecipeGenerator.create_from_prototype {
    name = "test-groundwater-pump-basic",
    category = "sosciencity-groundwater-pump",
    results = {{type = "fluid", name = "drinkable-water", amount = 10}}
}
