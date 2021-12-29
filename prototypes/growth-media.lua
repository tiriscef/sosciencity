local growth_media = {
    {
        name = "sugar-medium",
        distinctions = {
            icon = "__sosciencity-graphics__/graphics/icon/medium.png"
        }
    }
}

Tirislib.Fluid.batch_create(
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

Tirislib.RecipeGenerator.create {
    product = "sugar-medium",
    product_type = "fluid",
    product_amount = 100,
    energy_required = 3.2,
    ingredients = {
        {type = "item", name = "hardcorn-punk", amount = 20},
        {type = "fluid", name = "clean-water", amount = 100}
    },
    category = Tirislib.RecipeGenerator.category_alias.dissolving,
    unlock = "fermentation"
}

Tirislib.RecipeGenerator.create {
    product = "sugar-medium",
    product_type = "fluid",
    product_amount = 100,
    energy_required = 0.8,
    ingredients = {
        {type = "item", name = "sugar", amount = 5},
        {type = "fluid", name = "clean-water", amount = 100}
    },
    category = Tirislib.RecipeGenerator.category_alias.dissolving,
    unlock = "basic-biotechnology"
}

Tirislib.RecipeGenerator.create {
    product = "sugar-medium",
    product_type = "fluid",
    product_amount = 100,
    energy_required = 0.8,
    ingredients = {
        {type = "item", name = "molasses", amount = 5},
        {type = "fluid", name = "clean-water", amount = 100}
    },
    category = Tirislib.RecipeGenerator.category_alias.dissolving,
    unlock = "basic-biotechnology"
}
