local growth_media = {
    {
        name = "sugar-medium",
        distinctions = {
            icon = "__sosciencity-graphics__/graphics/icon/medium.png"
        }
    }
}

Tirislib_Fluid.batch_create(
    growth_media,
    {
        default_temperature = 10,
        max_temperature = 100,
        base_color = {r = 0.151, g = 0.483, b = 0.933},
        flow_color = {r = 0.151, g = 0.483, b = 0.933},
        subgroup = "sosciencity-growth-media",
        unlock = ""
    }
)

Tirislib_RecipeGenerator.create {
    product = "sugar-medium",
    product_type = "fluid",
    product_amount = 100,
    energy_required = 0.8,
    ingredients = {
        {type = "item", name = "blue-grapes", amount = 15},
        {type = "fluid", name = "clean-water", amount = 100}
    },
    category = Tirislib_RecipeGenerator.category_alias.dissolving,
    unlock = "fermentation"
}

Tirislib_RecipeGenerator.create {
    product = "sugar-medium",
    product_type = "fluid",
    product_amount = 100,
    energy_required = 0.8,
    ingredients = {
        {type = "item", name = "sugar", amount = 10},
        {type = "fluid", name = "clean-water", amount = 100}
    },
    category = Tirislib_RecipeGenerator.category_alias.dissolving,
    unlock = "basic-biotechnology"
}

Tirislib_RecipeGenerator.create {
    product = "sugar-medium",
    product_type = "fluid",
    product_amount = 100,
    energy_required = 0.8,
    ingredients = {
        {type = "item", name = "molasses", amount = 10},
        {type = "fluid", name = "clean-water", amount = 100}
    },
    category = Tirislib_RecipeGenerator.category_alias.dissolving,
    unlock = "basic-biotechnology"
}
