-- Create an eei with a fitting size for every entity that will need one in control stage.
for width, height_table in pairs(Sosciencity_Config.eei_sizes) do
    for height in pairs(height_table) do
        Tirislib_Entity.create {
            type = "electric-energy-interface",
            name = string.format("%d-%d-sosciencity-hidden-eei", width, height),
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
            -- energy_usage is controlled by script, so basicly this value is arbitrary
            energy_usage = "0kW",
            energy_source = {
                type = "electric",
                buffer_capacity = "1MJ",
                usage_priority = "secondary-input"
            },
            icon = "__sosciencity-graphics__/graphics/empty-caste.png",
            icon_size = 256
        }:set_collision_box(width, height)
        -- TODO icon
    end
end
