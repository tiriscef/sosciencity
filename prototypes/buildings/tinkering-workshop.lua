Tirislib.Item.create {
    type = "item",
    name = "tinkering-workshop",
    icon = "__sosciencity-graphics__/graphics/icon/tinkering-workshop.png",
    icon_size = 64,
    subgroup = "sosciencity-production-buildings",
    order = "aaa",
    place_result = "tinkering-workshop",
    stack_size = Sosciencity.Config.building_stacksize,
    pictures = Sosciencity.Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "tinkering-workshop", amount = 1}
    },
    ingredients = {
        {theme = "building", amount = 5},
        {theme = "gear_wheel", amount = 5},
        {type = "item", name = "architectural-concept", amount = 1}
    },
    default_theme_level = 2,
    unlock = "tinkering-workshop"
}

local pipe_covers = Tirislib.Entity.get_standard_pipe_cover()
local pipe_pictures = Tirislib.Entity.get_standard_pipe_pictures()
local sprites = require("__sosciencity-graphics__.graphics.entity.tinkering-workshop.sprite-data")

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "tinkering-workshop",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "tinkering-workshop"},
    max_health = 200,
    corpse = "small-remnants",
    impact_category = "metal",
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "speed"},
    graphics_set = {
        animation = Tirislib.Entity.create_animation_from_sprite_data(sprites.static),
        -- constant_speed: the animations don't speed up with the crafting speed (modules, maintenance bonus)
        working_visualisations = {
            -- flywheel and the smoker's clockwork: always drawn, so they stay visible while idle
            Tirislib.Entity.create_working_visualisation_from_sprite_data(
                sprites.drive, {always_draw = true, constant_speed = true}),
            Tirislib.Entity.create_working_visualisation_from_sprite_data(
                sprites.smoker, {always_draw = true, constant_speed = true}),
            -- the furnace only burns while the workshop crafts
            Tirislib.Entity.create_working_visualisation_from_sprite_data(sprites.fire, {constant_speed = true})
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-tinkering-workshop"},
    fluid_boxes = {
        {
            volume = 200,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {-2.5, 0}, flow_direction = "input", direction = defines.direction.west}},
            production_type = "input"
        },
        {
            volume = 200,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {2.5, 0}, flow_direction = "input", direction = defines.direction.east}},
            production_type = "input"
        }
    },
    fluid_boxes_off_when_no_fluid_recipe = true,
    energy_usage = "60kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = 0.15},
        drain = "0W"
    }
}:set_size(6, 6):copy_icon_from_item()
Sosciencity.configure_building("tinkering-workshop")
