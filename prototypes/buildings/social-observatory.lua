local sprites = require("__sosciencity-graphics__.graphics.entity.social-observatory.sprite-data")

--- A sprite-data part played at its own speed instead of the export's (the sanity dial swings twice per loop).
local function with_speed(part, speed)
    local copy = Tirislib.Tables.copy(part)
    copy.animation_speed = speed
    return copy
end

Tirislib.Item.create {
    type = "item",
    name = "social-observatory",
    icon = "__sosciencity-graphics__/graphics/icon/social-observatory.png",
    icon_size = 64,
    subgroup = "sosciencity-buildings",
    order = "fab",
    place_result = "social-observatory",
    stack_size = Sosciencity.Config.building_stacksize,
    pictures = Sosciencity.Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "social-observatory", amount = 1}
    },
    ingredients = {
        {theme = "building", amount = 15},
        {type = "item", name = "architectural-concept", amount = 1}
    },
    default_theme_level = 4,
    unlock = "gleam-caste"
}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "social-observatory",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "social-observatory"},
    max_health = 200,
    corpse = "small-remnants",
    impact_category = "stone",
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "speed"},
    graphics_set = {
        animation = Tirislib.Entity.create_animation_from_sprite_data(sprites.static),
        -- constant speed: the ticker stays readable with speed modules
        working_visualisations = {
            -- only while working: the static sprite shows the ticker off and the activity LEDs dark
            {
                constant_speed = true,
                animation = Tirislib.Entity.create_animation_from_sprite_data(sprites.ticker)
            },
            {
                constant_speed = true,
                animation = Tirislib.Entity.create_animation_from_sprite_data(sprites["server-leds"])
            },
            {
                constant_speed = true,
                animation = Tirislib.Entity.create_animation_from_sprite_data(sprites["hut-leds"])
            },
            -- the static sprite has no hands, so the dials are always drawn (frozen while idle)
            {
                always_draw = true,
                constant_speed = true,
                animation = Tirislib.Entity.create_animation_from_sprite_data(sprites["hand-happiness"])
            },
            {
                always_draw = true,
                constant_speed = true,
                animation = Tirislib.Entity.create_animation_from_sprite_data(sprites["hand-health"])
            },
            {
                always_draw = true,
                constant_speed = true,
                animation = Tirislib.Entity.create_animation_from_sprite_data(with_speed(sprites["hand-sanity"], 0.2))
            }
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-social-observatory"},
    energy_usage = "60kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = 0.05},
        drain = "5kW"
    }
}:set_size(6, 6):copy_icon_from_item()
Sosciencity.configure_building("social-observatory")
