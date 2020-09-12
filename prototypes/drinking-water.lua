local fluids = {
    {name = "clean-water"}
}

Tirislib_Fluid.batch_create(
    fluids,
    {
        default_temperature = 10,
        max_temperature = 100,
        base_color = {r = 0.151, g = 0.483, b = 0.933},
        flow_color = {r = 0.151, g = 0.483, b = 0.933},
        subgroup = "sosciencity-drinking-water"
    }
)

Tirislib_RecipeGenerator.create {
    product = "clean-water",
    product_type = "fluid",
    product_min = 80,
    product_max = 160,
    category = "sosciencity-groundwater-pump",
    energy_required = 1
}
