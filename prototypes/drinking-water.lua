local fluids = {
    {name = "drinkable-water"},
    {name = "clean-water"},
    {name = "mechanically-cleaned-water"},
    {name = "biologically-cleaned-water"},
    {name = "ultra-pure-water"}
}

Tirislib.Fluid.batch_create(
    fluids,
    {
        default_temperature = 10,
        max_temperature = 100,
        base_color = {r = 0.151, g = 0.483, b = 0.933},
        flow_color = {r = 0.151, g = 0.483, b = 0.933},
        subgroup = "sosciencity-drinking-water"
    }
)

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "fluid", name = "drinkable-water", amount = 50}
    },
    ingredients = {
        {type = "fluid", name = "water", amount = 50}
    },
    name = "boiled-water",
    category = "sosciencity-water-heater",
    energy_required = 10,
    unlock = "infrastructure-1"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "fluid", name = "drinkable-water", amount = 80}
    },
    name = "drinkable-water-from-ground",
    category = "sosciencity-groundwater-pump",
    energy_required = 8,
    unlock = "infrastructure-1"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "fluid", name = "clean-water", amount = 80}
    },
    name = "clean-water-from-ground",
    category = "sosciencity-groundwater-pump",
    energy_required = 8,
    unlock = "activated-carbon-filtering"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "fluid", name = "water", amount_min = 250, amount_max = 350}
    },
    name = "water-from-ground",
    category = "sosciencity-groundwater-pump",
    energy_required = 1,
    subgroup = "sosciencity-drinking-water",
    unlock = "infrastructure-1"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "fluid", name = "mechanically-cleaned-water", amount = 600, product = true},
        {theme = "sediment", amount = 1}
    },
    ingredients = {
        {theme = "sediment", amount = 1},
        {type = "fluid", name = "water", amount = 600}
    },
    name = "water",
    category = "sosciencity-sedimentation-clarifier",
    energy_required = 10,
    unlock = "drinking-water-treatment"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "fluid", name = "biologically-cleaned-water", amount = 600, product = true},
        {type = "item", name = "sewage-sludge", amount = 1}
    },
    ingredients = {
        {type = "fluid", name = "mechanically-cleaned-water", amount = 600}
    },
    name = "mechanically-cleaned-water",
    category = "sosciencity-biological-clarifier",
    energy_required = 10,
    unlock = "drinking-water-treatment"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "fluid", name = "clean-water", amount = 600}
    },
    ingredients = {
        {type = "fluid", name = "biologically-cleaned-water", amount = 600},
        {type = "item", name = "ferrous-sulfate", amount = 1}
    },
    name = "biologically-cleaned-water",
    category = "sosciencity-chemical-clarifier",
    energy_required = 20,
    unlock = "drinking-water-treatment"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "fluid", name = "ultra-pure-water", amount = 50, product = true},
        {type = "item", name = "semipermeable-membrane", amount = 1, probability = 0.8}
    },
    ingredients = {
        {type = "fluid", name = "clean-water", amount = 70},
        {type = "item", name = "semipermeable-membrane", amount = 1}
    },
    name = "clean-water",
    energy_required = 4,
    unlock = "genetic-neogenesis"
}:add_catalyst("semipermeable-membrane", "item", 1, 0.8)
