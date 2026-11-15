Tirislib.Item.create {
    type = "item",
    name = "smokehouse",
    use_placeholder_icon = true,
    icon_size = 64,
    subgroup = "sosciencity-food-buildings",
    order = "dab",
    place_result = "smokehouse",
    stack_size = Sosciencity.Config.building_stacksize,
    pictures = Sosciencity.Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "smokehouse", amount = 1}
    },
    ingredients = {
        {theme = "building", amount = 4},
        {theme = "piping", amount = 5},
        {type = "item", name = "architectural-concept", amount = 1}
    },
    default_theme_level = 2,
    unlock = "smokehouse"
}

-- TODO: sprite. The placeholder picture is stretched to the size of the building.
local placeholder_picture = Tirislib.Entity.get_placeholder_picture()
placeholder_picture.scale = 4 * 32 / placeholder_picture.width

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "smokehouse",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "smokehouse"},
    max_health = 200,
    corpse = "small-remnants",
    impact_category = "wood",
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "consumption", "speed", "pollution"},
    graphics_set = {
        animation = placeholder_picture
    },
    crafting_speed = 2,
    crafting_categories = {"sosciencity-smoking"},
    energy_usage = "50kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {pollution = 1},
        drain = "0W"
    }
}:set_size(4, 4):copy_icon_from_item()
