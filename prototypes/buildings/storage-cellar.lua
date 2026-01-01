-- TODO: graphics

Tirislib.Item.create {
    type = "item",
    name = "storage-cellar",
    icon = Tirislib.Prototype.placeholder_icon,
    icon_size = 64,
    subgroup = "sosciencity-food-buildings",
    order = "daa",
    place_result = "storage-cellar",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    product = "storage-cellar",
    themes = {{"building", 2}},
    default_theme_level = 1,
    unlock = "open-environment-farming"
}

Tirislib.Entity.create {
    type = "container",
    name = "storage-cellar",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "storage-cellar"},
    max_health = 200,
    inventory_size = 80,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    picture = {
        filename = "__sosciencity-graphics__/graphics/placeholder.png",
        priority = "high",
        width = 224,
        height = 224,
        scale = 4 / 7
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13
}:set_size(4, 4):copy_icon_from_item()
Sosciencity_Config.add_eei("storage-cellar")
