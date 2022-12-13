Tirislib.Item.create {
    type = "item",
    name = "orchid-food-factory",
    icon = "__sosciencity-graphics__/graphics/icon/orchid-food-factory.png",
    icon_size = 64,
    subgroup = "sosciencity-food-buildings",
    order = "daa",
    place_result = "orchid-food-factory",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "orchid-food-factory",
    themes = {{"building", 10}, {"machine", 20}, {"piping", 50}},
    ingredients = {
        {type = "item", name = "groundwater-pump", amount = 1},
        {type = "item", name = "silo", amount = 2},
        {type = "item", name = "architectural-concept", amount = 1}
    },
    default_theme_level = 2,
    unlock = "food-processing"
}

local pipe_covers = Tirislib.Entity.get_standard_pipe_cover()
local pipe_pictures = Tirislib.Entity.get_standard_pipe_pictures {"south"}

Tirislib.Entity.create {
    type = "assembling-machine",
    name = "orchid-food-factory",
    flags = {"placeable-neutral", "player-creation", "not-rotatable"},
    minable = {mining_time = 0.5, result = "orchid-food-factory"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    allowed_effects = {"productivity", "speed"},
    animation = Tirislib.Entity.create_standard_picture{
        path = "__sosciencity-graphics__/graphics/entity/orchid-food-factory/orchid-food-factory",
        center = {16.0, 11.0},
        width = 34,
        height = 18,
        shadowmap = true,
        lightmap = true,
        glow = true
    },
    crafting_speed = 1,
    crafting_categories = {"sosciencity-orchid-food-processing"},
    energy_usage = "190kW",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 0.25,
        drain = "10kW"
    },
    fluid_boxes = {
        {
            base_level = -1,
            pipe_covers = pipe_covers,
            pipe_picture = pipe_pictures,
            pipe_connections = {{position = {2.5, 3.5}}},
            production_type = "input"
        },
        off_when_no_fluid_recipe = true
    }
}:set_size(24, 6):copy_localisation_from_item():copy_icon_from_item()
