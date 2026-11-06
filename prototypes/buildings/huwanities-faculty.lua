-- TODO: most everything besides the graphics
local sprites = require("__sosciencity-graphics__.graphics.entity.huwanities-faculty.sprite-data")

Tirislib.Item.create {
    type = "item",
    name = "huwanities-faculty",
    icon = "__sosciencity-graphics__/graphics/icon/huwanities-faculty.png",
    icon_size = 64,
    subgroup = "sosciencity-education-buildings",
    order = "aaa",
    place_result = "huwanities-faculty",
    stack_size = Sosciencity.Config.building_stacksize,
    pictures = Sosciencity.Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "huwanities-faculty", amount = 1}
    },
    ingredients = {
        {theme = "building", amount = 1},
        {type = "item", name = "architectural-concept", amount = 1}
    },
    unlock = "gleam-caste"
}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "huwanities-faculty",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "huwanities-faculty"},
    max_health = 200,
    corpse = "small-remnants",
    impact_category = "stone",
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"speed"},
    graphics_set = {
        animation = Tirislib.Entity.create_animation_from_sprite_data(sprites.static)
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-huwanities-faculty"},
    energy_usage = "60kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = 0.15},
        drain = "0W"
    }
}:set_size(10, 10):copy_icon_from_item()
Sosciencity.configure_building("huwanities-faculty")
