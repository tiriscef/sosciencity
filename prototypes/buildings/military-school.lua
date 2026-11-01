
Tirislib.Item.create {
    type = "item",
    name = "military-school",
    icon = Tirislib.Prototype.placeholder_icon,
    icon_size = 64,
    subgroup = "sosciencity-education-buildings",
    order = "aaa",
    place_result = "military-school",
    stack_size = Sosciencity.Config.building_stacksize,
    pictures = Sosciencity.Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "military-school", amount = 1}
    },
    ingredients = {
        {theme = "building", amount = 1},
        {type = "item", name = "architectural-concept", amount = 1}
    },
    unlock = "gunfire-caste"
}

local sprites = require("__sosciencity-graphics__.graphics.entity.military-school.sprite-data")

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "military-school",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "military-school"},
    max_health = 200,
    corpse = "small-remnants",
    impact_category = "metal",
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"speed"},
    graphics_set = {
        animation = Tirislib.Entity.create_animation_from_sprite_data(sprites.static),
        -- constant_speed: the animations don't speed up with the crafting speed (modules, maintenance bonus)
        working_visualisations = {
            -- flags wave and the pop-up targets stay visible (frozen) while the school is idle
            Tirislib.Entity.create_working_visualisation_from_sprite_data(
                sprites["school-flag"], {always_draw = true, constant_speed = true}),
            Tirislib.Entity.create_working_visualisation_from_sprite_data(
                sprites["tower-flag"], {always_draw = true, constant_speed = true}),
            Tirislib.Entity.create_working_visualisation_from_sprite_data(
                sprites.popups, {always_draw = true, constant_speed = true}),
            -- shooting (muzzle flashes, dust on the berm) only while the school trains recruits
            Tirislib.Entity.create_working_visualisation_from_sprite_data(sprites.muzzles, {constant_speed = true}),
            Tirislib.Entity.create_working_visualisation_from_sprite_data(sprites.impacts, {constant_speed = true})
        }
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-military-school"},
    energy_usage = "60kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = 0.15},
        drain = "0W"
    }
}:set_size(8, 8):copy_icon_from_item()
Sosciencity.configure_building("military-school")
