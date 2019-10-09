--[[ modules ]]
Item:create {
    type = "module",
    name = "sosciencity-speed-penalty-module",
    icon = "__sosciencity__/graphics/empty.png",
    icon_size = 1,
    flags = {"hidden", "hide-from-bonus-gui"},
    subgroup = "module",
    category = "speed",
    tier = 0,
    stack_size = 1,
    effect = {speed = {bonus = -0.80}}
}

Item:create {
    type = "module",
    name = "sosciencity-speed-module",
    icon = "__sosciencity__/graphics/empty.png",
    icon_size = 1,
    flags = {"hidden", "hide-from-bonus-gui"},
    subgroup = "module",
    category = "speed",
    tier = 0,
    stack_size = 1,
    effect = {speed = {bonus = 0.01}}
}

Item:create {
    type = "module",
    name = "sosciencity-speed-module-100",
    icon = "__sosciencity__/graphics/empty.png",
    icon_size = 1,
    flags = {"hidden", "hide-from-bonus-gui"},
    subgroup = "module",
    category = "speed",
    tier = 0,
    stack_size = 1,
    effect = {speed = {bonus = 1}}
}

Item:create {
    type = "module",
    name = "sosciencity-productivity-module",
    icon = "__sosciencity__/graphics/empty.png",
    icon_size = 1,
    flags = {"hidden", "hide-from-bonus-gui"},
    subgroup = "module",
    category = "productivity",
    tier = 0,
    stack_size = 1,
    effect = {productivity = {bonus = 0.01}}
}

Item:create {
    type = "module",
    name = "sosciencity-productivity-module-100",
    icon = "__sosciencity__/graphics/empty.png",
    icon_size = 1,
    flags = {"hidden", "hide-from-bonus-gui"},
    subgroup = "module",
    category = "productivity",
    tier = 0,
    stack_size = 1,
    effect = {productivity = {bonus = 1}}
}

--[[ beacon ]]
Entity:create {
    type = "beacon",
    name = "sosciencity-invisible-beacon",
    energy_usage = "10W",
    flags = {
        "hide-alt-info",
        "not-blueprintable",
        "not-deconstructable",
        "not-on-map",
        "not-flammable",
        "not-repairable",
        "no-automated-item-removal",
        "no-automated-item-insertion"
    },
    animation = {
        filename = "__sosciencity__/graphics/empty.png",
        width = 1,
        height = 1,
        line_length = 8,
        frame_count = 1
    },
    animation_shadow = {
        filename = "__sosciencity__/graphics/empty.png",
        width = 1,
        height = 1,
        line_length = 8,
        frame_count = 1
    },
    energy_source = {
        type = "void"
    },
    base_picture = {
        filename = "__sosciencity__/graphics/empty.png",
        width = 1,
        height = 1
    },
    supply_area_distance = 0,
    radius_visualisation_picture = {
        filename = "__sosciencity__/graphics/empty.png",
        width = 1,
        height = 1
    },
    distribution_effectivity = 1,
    module_specification = {
        module_slots = 65535
    },
    allowed_effects = {
        "consumption",
        "speed",
        "productivity",
        "pollution"
    },
    selection_box = nil,
    collision_box = nil
}
