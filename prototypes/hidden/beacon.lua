--<< modules >>
Tirislib_Item.create {
    type = "module",
    name = "sosciencity-penalty",
    icon = "__sosciencity-graphics__/graphics/empty.png",
    icon_size = 1,
    flags = {"hidden", "hide-from-bonus-gui"},
    subgroup = "module",
    category = "speed",
    tier = 0,
    stack_size = 1,
    effect = {speed = {bonus = -0.80}}
}

for i = 0, 14 do
    local strength = 2 ^ i * 0.01

    Tirislib_Item.create {
        type = "module",
        name = i .. "-sosciencity-speed",
        icon = "__sosciencity-graphics__/graphics/empty.png",
        icon_size = 1,
        flags = {"hidden", "hide-from-bonus-gui"},
        subgroup = "module",
        category = "speed",
        tier = 0,
        stack_size = 1,
        effect = {speed = {bonus = strength}}
    }

    Tirislib_Item.create {
        type = "module",
        name = i .. "-sosciencity-productivity",
        icon = "__sosciencity-graphics__/graphics/empty.png",
        icon_size = 1,
        flags = {"hidden", "hide-from-bonus-gui"},
        subgroup = "module",
        category = "productivity",
        tier = 0,
        stack_size = 1,
        effect = {productivity = {bonus = strength}}
    }
end

--<< beacon >>
Tirislib_Entity.create {
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
    module_specification = {
        module_slots = 40
    },
    allowed_effects = {
        "consumption",
        "speed",
        "productivity",
        "pollution"
    },
    selection_box = nil,
    collision_box = nil,
    icon = "__sosciencity-graphics__/graphics/empty-caste.png",
    icon_size = 256
}
