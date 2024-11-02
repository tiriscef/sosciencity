--<< modules >>
Tirislib.Item.create {
    type = "module",
    name = "sosciencity-penalty",
    icon = "__sosciencity-graphics__/graphics/empty.png",
    icon_size = 1,
    flags = {"hide-from-bonus-gui"},
    hidden = true,
    subgroup = "module",
    category = "speed",
    tier = 0,
    stack_size = 1,
    effect = {speed = -0.80},
    localised_name = {"item-name.hidden-module"},
    localised_description = {"item-description.hidden-module"},
    is_hack = true
}

for i = 0, 14 do
    local strength = 2 ^ i * 0.01

    Tirislib.Item.create {
        type = "module",
        name = i .. "-sosciencity-speed",
        icon = "__sosciencity-graphics__/graphics/empty.png",
        icon_size = 1,
        flags = {"hide-from-bonus-gui"},
        hidden = true,
        subgroup = "module",
        category = "speed",
        tier = 0,
        stack_size = 1,
        effect = {speed = strength},
        localised_name = {"item-name.hidden-module"},
        localised_description = {"item-description.hidden-module"},
        is_hack = true
    }

    Tirislib.Item.create {
        type = "module",
        name = i .. "-sosciencity-productivity",
        icon = "__sosciencity-graphics__/graphics/empty.png",
        icon_size = 1,
        flags = {"hide-from-bonus-gui"},
        hidden = true,
        subgroup = "module",
        category = "productivity",
        tier = 0,
        stack_size = 1,
        effect = {productivity = strength},
        localised_name = {"item-name.hidden-module"},
        localised_description = {"item-description.hidden-module"},
        is_hack = true
    }
end

--<< beacon >>
Tirislib.Entity.create {
    type = "beacon",
    name = "sosciencity-hidden-beacon",
    energy_usage = "10W",
    flags = {
        "hide-alt-info",
        "not-blueprintable",
        "not-deconstructable",
        "not-on-map",
        "not-flammable",
        "not-repairable",
        "no-automated-item-removal",
        "no-automated-item-insertion",
        "placeable-off-grid"
    },
    hidden = true,
    animation = {
        filename = "__sosciencity-graphics__/graphics/empty.png",
        width = 1,
        height = 1,
        line_length = 8,
        frame_count = 1
    },
    animation_shadow = {
        filename = "__sosciencity-graphics__/graphics/empty.png",
        width = 1,
        height = 1,
        line_length = 8,
        frame_count = 1
    },
    energy_source = {
        type = "void"
    },
    base_picture = {
        filename = "__sosciencity-graphics__/graphics/empty.png",
        width = 1,
        height = 1
    },
    supply_area_distance = 0,
    radius_visualisation_picture = {
        filename = "__sosciencity-graphics__/graphics/empty.png",
        width = 1,
        height = 1
    },
    distribution_effectivity = 1,
    module_slots = 41,
    allowed_effects = {
        "speed",
        "productivity"
    },
    collision_mask = {layers = {}},
    --collision_mask = {}, TODO: check if this updated collision mask works as intended once I get the mod to run
    icon = "__sosciencity-graphics__/graphics/empty-caste.png",
    icon_size = 256,
    localised_name = {"entity-name.hidden-entity"},
    localised_description = {"entity-description.hidden-entity"},
    is_hack = true
}
