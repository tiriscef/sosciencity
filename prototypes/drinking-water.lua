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

Tirislib.RecipeGenerator.create {
    name = "drinkable-water-from-ground",
    product = "drinkable-water",
    product_type = "fluid",
    product_amount = 80,
    category = "sosciencity-groundwater-pump",
    energy_required = 8,
    unlock = "infrastructure-1"
}

Tirislib.RecipeGenerator.create {
    name = "clean-water-from-ground",
    product = "clean-water",
    product_type = "fluid",
    product_amount = 80,
    category = "sosciencity-groundwater-pump",
    energy_required = 8,
    unlock = "activated-carbon-filtering",
    localised_description = {"sosciencity.module-required", {"item-name.water-filter"}}
}

Tirislib.RecipeGenerator.create {
    name = "water-from-ground",
    product = "water",
    product_type = "fluid",
    product_min = 250,
    product_max = 350,
    category = "sosciencity-groundwater-pump",
    subgroup = "sosciencity-drinking-water",
    energy_required = 1,
    unlock = "infrastructure-1"
}

Tirislib.RecipeGenerator.create {
    product = "mechanically-cleaned-water",
    product_type = "fluid",
    product_amount = 600,
    ingredients = {
        {type = "fluid", name = "water", amount = 600}
    },
    result_themes = {{"sediment", 1, 1, 0}},
    category = "sosciencity-sedimentation-clarifier",
    energy_required = 10,
    unlock = "drinking-water-treatment"
}

Tirislib.RecipeGenerator.create {
    product = "biologically-cleaned-water",
    product_type = "fluid",
    product_amount = 600,
    ingredients = {
        {type = "fluid", name = "mechanically-cleaned-water", amount = 600}
    },
    byproducts = {
        {type = "item", name = "sewage-sludge", amount = 1}
    },
    category = "sosciencity-biological-clarifier",
    energy_required = 10,
    unlock = "drinking-water-treatment"
}

Tirislib.RecipeGenerator.create {
    product = "clean-water",
    product_type = "fluid",
    product_amount = 600,
    ingredients = {
        {type = "fluid", name = "biologically-cleaned-water", amount = 600},
        {type = "item", name = "ferrous-sulfate", amount = 1}
    },
    category = "sosciencity-chemical-clarifier",
    energy_required = 20,
    unlock = "drinking-water-treatment"
}

Tirislib.RecipeGenerator.create {
    product = "ultra-pure-water",
    product_type = "fluid",
    product_amount = 50,
    ingredients = {
        {type = "fluid", name = "clean-water", amount = 70},
        {type = "item", name = "semipermeable-membrane", amount = 1}
    },
    byproducts = {
        {type = "item", name = "semipermeable-membrane", amount = 1, probability = 0.8}
    },
    category = Tirislib.RecipeGenerator.category_alias.filtration,
    energy_required = 4,
    unlock = "genetic-neogenesis"
}:add_catalyst("semipermeable-membrane", "item", 1, 0.8)
