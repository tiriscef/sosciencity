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

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "empty-hard-drive", amount = 1}
    },
    ingredients = {
        {theme = "electronics", amount = 20},
        {theme = "casing", amount = 1},
        {theme = "wiring", amount = 10}
    },
    energy_required = 4,
    default_theme_level = 3,
    unlock = "sosciencity-computing"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "virus-genome", amount = 1}
    },
    ingredients = {
        {type = "item", name = "empty-hard-drive", amount = 1}
    },
    category = "sosciencity-computing-center",
    energy_required = 10,
    unlock = "sosciencity-computing"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "plant-genome", amount = 1}
    },
    ingredients = {
        {type = "item", name = "empty-hard-drive", amount = 1}
    },
    category = "sosciencity-computing-center",
    energy_required = 20,
    unlock = "sosciencity-computing"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "huwan-genome", amount = 1}
    },
    ingredients = {
        {type = "item", name = "empty-hard-drive", amount = 1}
    },
    category = "sosciencity-computing-center",
    energy_required = 30,
    unlock = "sosciencity-computing"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "edited-huwan-genome", amount = 1}
    },
    ingredients = {
        {type = "item", name = "empty-hard-drive", amount = 1}
    },
    category = "sosciencity-computing-center",
    energy_required = 40,
    unlock = "in-situ-gene-editing"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "glass-instruments", amount_min = 1, amount_max = 5}
    },
    ingredients = {
        {theme = "glass", amount = 5},
        {theme = "plastic", amount = 2}
    },
    energy_required = 2,
    default_theme_level = 2,
    unlock = "genetic-neogenesis"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "semipermeable-membrane", amount = 1}
    },
    ingredients = {
        {theme = "plastic", amount = 5},
        {theme = "framework", amount = 1}
    },
    default_theme_level = 2,
    unlock = "genetic-neogenesis"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "nucleobases", amount = 1}
    },
    ingredients = {
        {type = "item", name = "pemtenn-extract", amount = 2},
        {type = "item", name = "glass-instruments", amount = 1},
        {type = "fluid", name = "ethanol", amount = 15}
    },
    category = "chemistry",
    energy_required = 3.2,
    unlock = "genetic-neogenesis"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "phospholipids", amount = 1}
    },
    ingredients = {
        {theme = "phosphorous_source", amount = 1},
        {type = "item", name = "solid-fat", amount = 1},
        {type = "item", name = "glass-instruments", amount = 1},
        {type = "fluid", name = "flinnum", amount = 10}
    },
    category = "sosciencity-bioreactor",
    energy_required = 3.2,
    unlock = "genetic-neogenesis"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "chloroplasts", amount = 1}
    },
    ingredients = {
        {type = "item", name = "glass-instruments", amount = 1},
        {type = "fluid", name = "mynellia", amount = 25}
    },
    category = "chemistry",
    energy_required = 3.2,
    unlock = "genetic-neogenesis"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "mitochondria", amount = 1}
    },
    ingredients = {
        {type = "item", name = "glass-instruments", amount = 1},
        {type = "fluid", name = "pemtenn", amount = 25}
    },
    category = "chemistry",
    energy_required = 3.2,
    unlock = "genetic-neogenesis"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "synthetase", amount = 1}
    },
    ingredients = {
        {type = "item", name = "glass-instruments", amount = 1},
        {type = "fluid", name = "pemtenn", amount = 10},
        {type = "fluid", name = "ethanol", amount = 10}
    },
    category = "chemistry",
    energy_required = 3.2,
    unlock = "genetic-neogenesis"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "thermostable-dna-polymerase", amount = 1}
    },
    ingredients = {
        {type = "fluid", name = "fiicorum", amount = 10},
        {type = "item", name = "glass-instruments", amount = 1}
    },
    category = "chemistry",
    unlock = "genetic-neogenesis"
}

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "blank-dna-virus", amount = 1, product = true},
        {type = "item", name = "empty-hard-drive", amount = 1, probability = 0.95}
    },
    ingredients = {
        {type = "item", name = "proteins", amount = 1},
        {type = "item", name = "nucleobases", amount = 1},
        {type = "item", name = "synthetase", amount = 1},
        {type = "item", name = "glass-instruments", amount = 1},
        {type = "item", name = "virus-genome", amount = 1}
    },
    category = "sosciencity-reproductive-gene-lab",
    unlock = "in-situ-gene-editing"
}
