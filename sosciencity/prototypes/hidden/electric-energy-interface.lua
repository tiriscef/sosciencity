Entity:create {
    type = "electric-energy-interface",
    name = "sosciencity-invisible-eei",
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
    base_picture = {
        filename = "__sosciencity__/graphics/icon/empty.png",
        width = 1,
        height = 1
    },
    selection_box = nil,
    collision_box = nil,
    -- energy_usage is controlled by script, so basicly this value is arbitrary
    energy_usage = "10kW", 
    energy_source = {
        type = "electric",
        buffer_capacity = "1MW",
        usage_priority = "secondary-input"
    },
    icon = "__sosciencity__/graphics/icon/eei.png",
    icon_size = 64
}
-- TODO icon