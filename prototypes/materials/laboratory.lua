---------------------------------------------------------------------------------------------------
-- << items >>

local laboratory_items = {
    {name = "semipermeable-membrane"},
    {
        name = "glass-instruments",
        sprite_variations = {name = "glass-instruments-on-belt", count = 3},
        distinctions = {subgroup = "sosciencity-laboratory-materials"}
    },
    {
        name = "nucleobases",
        sprite_variations = {name = "nucleobases-on-belt", count = 3},
        distinctions = {subgroup = "sosciencity-laboratory-materials"}
    },
    {
        name = "phospholipids",
        sprite_variations = {name = "phospholipids-on-belt", count = 3},
        distinctions = {subgroup = "sosciencity-laboratory-materials"}
    },
    {
        name = "chloroplasts",
        sprite_variations = {name = "chloroplasts-on-belt", count = 1},
        distinctions = {subgroup = "sosciencity-laboratory-materials"}
    },
    {
        name = "mitochondria",
        sprite_variations = {name = "mitochondria-on-belt", count = 1},
        distinctions = {subgroup = "sosciencity-laboratory-materials"}
    },
    {
        name = "synthetase",
        sprite_variations = {name = "synthetase-on-belt", count = 1},
        distinctions = {subgroup = "sosciencity-laboratory-materials"}
    },
    {
        name = "thermostable-dna-polymerase",
        sprite_variations = {name = "thermostable-dna-polymerase-on-belt", count = 1},
        distinctions = {subgroup = "sosciencity-laboratory-materials"}
    },
    {
        name = "blank-dna-virus",
        sprite_variations = {name = "blank-dna-virus-on-belt", count = 1},
        distinctions = {subgroup = "sosciencity-laboratory-materials"}
    },
    {
        name = "empty-hard-drive",
        distinctions = {subgroup = "sosciencity-data"}
    },
    {
        name = "virus-genome",
        distinctions = {subgroup = "sosciencity-data"}
    },
    {
        name = "plant-genome",
        distinctions = {subgroup = "sosciencity-data"}
    },
    {
        name = "huwan-genome",
        distinctions = {subgroup = "sosciencity-data"}
    },
    {
        name = "edited-huwan-genome",
        distinctions = {subgroup = "sosciencity-data"}
    }
}

Tirislib.Item.batch_create(
    laboratory_items,
    {subgroup = "sosciencity-materials", stack_size = 200}
)

---------------------------------------------------------------------------------------------------
-- << recipes >>

Tirislib.RecipeGenerator.create {
    product = "empty-hard-drive",
    themes = {
        {"electronics", 20},
        {"casing", 1},
        {"wiring", 10}
    },
    energy_required = 4,
    default_theme_level = 3,
    unlock = "sosciencity-computing"
}

Tirislib.RecipeGenerator.create {
    product = "virus-genome",
    ingredients = {
        {type = "item", name = "empty-hard-drive", amount = 1}
    },
    category = "sosciencity-computing-center",
    energy_required = 10,
    unlock = "sosciencity-computing"
}

Tirislib.RecipeGenerator.create {
    product = "plant-genome",
    ingredients = {
        {type = "item", name = "empty-hard-drive", amount = 1}
    },
    category = "sosciencity-computing-center",
    energy_required = 20,
    unlock = "sosciencity-computing"
}

Tirislib.RecipeGenerator.create {
    product = "huwan-genome",
    ingredients = {
        {type = "item", name = "empty-hard-drive", amount = 1}
    },
    category = "sosciencity-computing-center",
    energy_required = 30,
    unlock = "sosciencity-computing"
}

Tirislib.RecipeGenerator.create {
    product = "edited-huwan-genome",
    ingredients = {
        {type = "item", name = "empty-hard-drive", amount = 1}
    },
    category = "sosciencity-computing-center",
    energy_required = 40,
    unlock = "in-situ-gene-editing"
}

Tirislib.RecipeGenerator.create {
    product = "glass-instruments",
    product_min = 1,
    product_max = 5,
    energy_required = 2,
    themes = {{"glass", 5}, {"plastic", 2}},
    default_theme_level = 2,
    unlock = "genetic-neogenesis"
}

Tirislib.RecipeGenerator.create {
    product = "semipermeable-membrane",
    themes = {{"plastic", 5}, {"framework", 1}},
    default_theme_level = 2,
    unlock = "genetic-neogenesis"
}

Tirislib.RecipeGenerator.create {
    product = "nucleobases",
    energy_required = 3.2,
    ingredients = {
        {type = "item", name = "pemtenn-extract", amount = 2},
        {type = "item", name = "glass-instruments", amount = 1},
        {type = "fluid", name = "ethanol", amount = 15}
    },
    category = "chemistry",
    unlock = "genetic-neogenesis"
}

Tirislib.RecipeGenerator.create {
    product = "phospholipids",
    energy_required = 3.2,
    themes = {{"phosphorous_source", 1}},
    ingredients = {
        {type = "item", name = "solid-fat", amount = 1},
        {type = "item", name = "glass-instruments", amount = 1},
        {type = "fluid", name = "flinnum", amount = 10}
    },
    category = "sosciencity-bioreactor",
    unlock = "genetic-neogenesis"
}

Tirislib.RecipeGenerator.create {
    product = "chloroplasts",
    energy_required = 3.2,
    ingredients = {
        {type = "item", name = "glass-instruments", amount = 1},
        {type = "fluid", name = "mynellia", amount = 25}
    },
    category = "chemistry",
    unlock = "genetic-neogenesis"
}

Tirislib.RecipeGenerator.create {
    product = "mitochondria",
    energy_required = 3.2,
    ingredients = {
        {type = "item", name = "glass-instruments", amount = 1},
        {type = "fluid", name = "pemtenn", amount = 25}
    },
    category = "chemistry",
    unlock = "genetic-neogenesis"
}

Tirislib.RecipeGenerator.create {
    product = "synthetase",
    energy_required = 3.2,
    ingredients = {
        {type = "item", name = "glass-instruments", amount = 1},
        {type = "fluid", name = "pemtenn", amount = 10},
        {type = "fluid", name = "ethanol", amount = 10}
    },
    category = "chemistry",
    unlock = "genetic-neogenesis"
}

Tirislib.RecipeGenerator.create {
    product = "thermostable-dna-polymerase",
    ingredients = {
        {type = "fluid", name = "fiicorum", amount = 10},
        {type = "item", name = "glass-instruments", amount = 1}
    },
    category = "chemistry",
    unlock = "genetic-neogenesis"
}

Tirislib.RecipeGenerator.create {
    product = "blank-dna-virus",
    ingredients = {
        {type = "item", name = "proteins", amount = 1},
        {type = "item", name = "nucleobases", amount = 1},
        {type = "item", name = "synthetase", amount = 1},
        {type = "item", name = "glass-instruments", amount = 1},
        {type = "item", name = "virus-genome", amount = 1}
    },
    byproducts = {
        {type = "item", name = "empty-hard-drive", amount = 1, probability = 0.95}
    },
    category = "sosciencity-reproductive-gene-lab",
    unlock = "in-situ-gene-editing"
}
