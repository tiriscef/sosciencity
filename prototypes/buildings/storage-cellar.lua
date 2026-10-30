Tirislib.Item.create {
    type = "item",
    name = "storage-cellar",
    icon = "__sosciencity-graphics__/graphics/icon/storage-cellar.png",
    icon_size = 64,
    subgroup = "sosciencity-food-buildings",
    order = "daa",
    place_result = "storage-cellar",
    stack_size = Sosciencity.Config.building_stacksize,
    pictures = Sosciencity.Config.blueprint_on_belt
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "storage-cellar", amount = 1}
    },
    ingredients = {
        {theme = "building", amount = 2}
    },
    default_theme_level = 1,
    unlock = "open-environment-farming"
}

Tirislib.Entity.create {
    type = "container",
    name = "storage-cellar",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "storage-cellar"},
    max_health = 200,
    inventory_size = 90,
    corpse = "small-remnants",
    impact_category = "wood",
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    picture = Tirislib.Entity.create_standard_picture {
            path = "__sosciencity-graphics__/graphics/entity/storage-cellar/storage-cellar",
            shift = {1.058, -0.331},
            width = 6,
            height = 5,
            shadowmap = true,
            lightmap = true,
            glow = true
        },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13
}:set_size(3, 3):copy_icon_from_item()
Sosciencity.configure_building("storage-cellar")
