-- TODO: actual graphics

Tirislib_Item.create {
    type = "item",
    name = "waste-incineration-plant",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    subgroup = "sosciencity-buildings",
    order = "daa",
    place_result = "waste-incineration-plant",
    stack_size = Sosciencity_Config.building_stacksize,
    pictures = Sosciencity_Config.blueprint_on_belt
}

Tirislib_RecipeGenerator.create {
    product = "waste-incineration-plant",
    themes = {{"machine", 2}},
    default_theme_level = 4,
    unlock = "architecture-4"
}

Tirislib_Entity.create {
    type = "burner-generator",
    name = "waste-incineration-plant",
    icon = "__sosciencity-graphics__/graphics/icon/test-house.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "waste-incineration-plant"},
    max_health = 200,
    corpse = "small-remnants",
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    animation = {
        filename = "__sosciencity-graphics__/graphics/entity/placeholder.png",
        priority = "high",
        width = 192,
        height = 192,
        scale = 0.5,
        frame_count = 1
    },
    energy_source = {
        type = "electric",
        usage_priority = "primary-output"
    },
    burner =
    {
      type = "burner",
      fuel_category = "garbage",
      fuel_inventory_size = 2,
      effectivity = 1,
      emissions_per_minute = 10,
      smoke =
      {
        {
          name = "smoke",
          frequency = 10,
          north_position = {0.0, 0.0},
          east_position = {0.0, 0.0},
          starting_vertical_speed = 0.05,
        }
      }
    },
    max_power_output = "2.5MW"
}:set_size(3, 3):copy_localisation_from_item()
