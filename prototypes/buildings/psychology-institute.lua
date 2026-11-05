local sprites = require("__sosciencity-graphics__.graphics.entity.psychology-institute.sprite-data")

Tirislib.Item.create {
    type = "item",
    name = "psychology-institute",
    icon = "__sosciencity-graphics__/graphics/icon/psychology-institute.png",
    icon_size = 64,
    subgroup = "sosciencity-buildings",
    order = "fac",
    place_result = "psychology-institute",
    stack_size = Sosciencity.Config.building_stacksize,
    pictures = Sosciencity.Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "psychology-institute", amount = 1}
    },
    ingredients = {
        {theme = "building", amount = 15},
        {theme = "furnishing", amount = 5, level = 5},
        {type = "item", name = "architectural-concept", amount = 1}
    },
    default_theme_level = 4,
    unlock = "gleam-caste"
}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "psychology-institute",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "psychology-institute"},
    max_health = 200,
    corpse = "small-remnants",
    impact_category = "stone",
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "speed"},
    graphics_set = {
        animation = Tirislib.Entity.create_animation_from_sprite_data(sprites.static),
        working_visualisations = {
            -- always drawn, so the rats and pigeons stay visible (frozen) while the institute is idle
            {
                always_draw = true,
                animation = Tirislib.Entity.create_animation_from_sprite_data(sprites.rats)
            },
            {
                always_draw = true,
                animation = Tirislib.Entity.create_animation_from_sprite_data(sprites.pigeons)
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-psychology-institute"},
    energy_usage = "60kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = 0.05},
        drain = "5kW"
    }
}:set_size(7, 7):copy_icon_from_item()
Sosciencity.configure_building("psychology-institute")
