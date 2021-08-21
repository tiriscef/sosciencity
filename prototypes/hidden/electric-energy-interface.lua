-- Create an eei with a fitting size for every entity that will need one in control stage.
for entity_name in pairs(Sosciencity_Config.eei_needing_buildings) do
    local entity = Tirislib_Entity.get_by_name(entity_name)

    Tirislib_Entity.create {
        type = "electric-energy-interface",
        name = "sosciencity-hidden-eei-" .. entity_name,
        collision_box = entity.collision_box,
        icon = entity.icon,
        icons = entity.icons,
        icon_size = entity.icon_size,
        localised_name = entity:get_localised_name(),
        localised_description = entity:get_localised_description(),
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
        base_picture = {
            filename = "__sosciencity-graphics__/graphics/empty.png",
            width = 1,
            height = 1
        },
        energy_source = {
            type = "electric",
            buffer_capacity = "1MJ",
            usage_priority = "secondary-input"
        },
        is_hack = true
    }
end
