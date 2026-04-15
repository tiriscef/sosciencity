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

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "fluid", name = "sugar-medium", amount = 100}
    },
    ingredients = {
        {type = "item", name = "blue-grapes", amount = 10},
        {type = "fluid", name = "drinkable-water", amount = 100}
    },
    name = "blue-grapes",
    energy_required = 3.2,
    unlock = "fermentation"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "fluid", name = "sugar-medium", amount = 100}
    },
    ingredients = {
        {type = "item", name = "sugar", amount = 5},
        {type = "fluid", name = "clean-water", amount = 100}
    },
    name = "sugar",
    energy_required = 0.8,
    unlock = "basic-biotechnology"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "fluid", name = "sugar-medium", amount = 100}
    },
    ingredients = {
        {type = "item", name = "molasses", amount = 5},
        {type = "fluid", name = "clean-water", amount = 100}
    },
    name = "molasses",
    energy_required = 0.8,
    unlock = "basic-biotechnology"
}
