-- TODO: actual graphics

Tirislib_Item.create {
    type = "item",
    name = "egg-collecting-station",
    icon = "__sosciencity-graphics__/graphics/icon/egg-collecting-station.png",
    icon_size = 64,
    subgroup = "sosciencity-infrastructure",
    order = "daa",
    place_result = "egg-collecting-station",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib_RecipeGenerator.create {
    product = "egg-collecting-station",
    themes = {{"building", 2}, {"machine", 2}},
    ingredients = {{type = "item", name = "architectural-concept", amount = 1}},
    default_theme_level = 2,
    unlock = "infrastructure-3"
}

Tirislib_Entity.create {
    type = "container",
    name = "egg-collecting-station",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "egg-collecting-station"},
    max_health = 200,
    inventory_size = 20,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    picture = Tirislib_Entity.create_standard_picture {
        path = "__sosciencity-graphics__/graphics/entity/egg-collecting-station/egg-collecting-station",
        width = 10,
        height = 7,
        shift = {0.5, -0.2},
        shadowmap = true,
        lightmap = true,
        glow = true
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 13
}:set_size(5, 5):copy_localisation_from_item():copy_icon_from_item()

Sosciencity_Config.add_eei("egg-collecting-station")
