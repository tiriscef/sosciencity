-- TODO: actual graphics

Tirislib.Item.create {
    type = "item",
    name = "intensive-care-unit",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "fab",
    place_result = "intensive-care-unit",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "intensive-care-unit",
    themes = {{"building", 20}, {"piping", 100}, {"electronics", 50}},
    ingredients = {
        {type = "item", name = "bed", amount = 120},
        {type = "item", name = "architectural-concept", amount = 1}
    },
    default_theme_level = 3,
    unlock = "intensive-care"
}

Tirislib.Entity.create {
    type = "container",
    name = "intensive-care-unit",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "intensive-care-unit"},
    max_health = 200,
    inventory_size = 10,
    inventory_type = "with_filters_and_bar",
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    picture = {
        layers = {
            {
                filename = "__sosciencity-graphics__/graphics/placeholder.png",
                priority = "high",
                width = 224,
                height = 224,
                scale = 3/7
            }
        }
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13
}:set_size(3, 3)
Sosciencity_Config.add_eei("intensive-care-unit")
