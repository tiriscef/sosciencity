Tirislib_Item.create {
    type = "item",
    name = "farm",
    icon = "__sosciencity__/graphics/icon/greenhouse.png", -- TODO icon
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "aaa",
    place_result = "farm",
    stack_size = 10
}

local recipe = Tirislib_RecipeGenerator.create_recipe("farm")
recipe:add_unlock() --TODO tech

local pipe_pictures = {
    north = Tirislib_Entity.get_empty_pipe_picture(),
    east = Tirislib_Entity.get_empty_pipe_picture(),
    south = Tirislib_Entity.get_south_pipe_picture(),
    west = Tirislib_Entity.get_empty_pipe_picture()
}

Tirislib_Entity.create {
    type = "assembling-machine",
    name = "farm",
    icon = "__sosciencity__/graphics/icon/greenhouse.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "farm"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "consumption", "speed", "pollution"},
    animation = {
        layers = {
            north = {
                filename = "__sosciencity__/graphics/entity/farm/farm-north.png",
                frame_count = 1,
                priority = "high",
                width = 544,
                height = 288,
                shift = {0.0, 0.0},
            },
            east = {
                filename = "__sosciencity__/graphics/empty.png",
                width = 1,
                height = 1,
                frame_count = 1
            },
            south = {
                filename = "__sosciencity__/graphics/empty.png",
                width = 1,
                height = 1,
                frame_count = 1
            },
            west = {
                filename = "__sosciencity__/graphics/empty.png",
                width = 1,
                height = 1,
                frame_count = 1
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-agriculture"},
    energy_usage = "10W",
    energy_source = {
        type = "void",
        emissions_per_minute = 1
    },
    working_sound = {
        -- memo: make sound files louder in the future
        sound = {filename = "__sosciencity__/sound/greenhouse-watering.ogg", volume = 3},
        apparent_volume = 1.5
    },
    fluid_boxes = {
        {
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {6.0, 4.0}}},
            production_type = "input"
        },
        {
            pipe_covers = pipecoverspictures(),
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {8.0, 2.0}}},
            production_type = "input"
        },
        off_when_no_fluid_recipe = true
    }
}:set_size(15, 7)
