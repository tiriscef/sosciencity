local microorganisms = {
    {
        name = "mynellia",
        distinctions = {
            base_color = {r = 0.164, g = 0.813, b = 0.411},
            flow_color = {r = 0.164, g = 0.813, b = 0.411}
        }
    },
    {
        name = "solfaen",
        distinctions = {
            base_color = {r = 0.944, g = 0.180, b = 0.063},
            flow_color = {r = 0.944, g = 0.383, b = 0.178}
        }
    },
    {
        name = "pemtenn",
        distinctions = {
            base_color = {r = 0.000, g = 0.800, b = 1.000},
            flow_color = {r = 0.000, g = 0.478, b = 0.600}
        }
    },
    {
        name = "flinnum",
        distinctions = {
            base_color = {r = 0.117, g = 0.667, b = 0.231},
            flow_color = {r = 0.273, g = 0.782, b = 0.632}
        }
    },
    {
        name = "fiicorum",
        distinctions = {
            base_color = {r = 0.944, g = 0.180, b = 0.063},
            flow_color = {r = 0.944, g = 0.383, b = 0.178}
        }
    },
}

Tirislib.Fluid.batch_create(
    microorganisms,
    {
        default_temperature = 10,
        max_temperature = 100,
        base_color = {r = 0.151, g = 0.483, b = 0.933},
        flow_color = {r = 0.151, g = 0.483, b = 0.933},
        subgroup = "sosciencity-microorganisms"
    }
)

local function create_enrichment_recipe(details)
    local product_name = details.product
    local product = Tirislib.Fluid.get_by_name(product_name)

    local result = {type = "fluid", name = product_name, amount = details.product_amount or 10}
    if details.product_probability then
        result.probability = details.product_probability
    end

    local ingredients = {}
    if details.ingredients then
        Tirislib.Tables.merge(ingredients, details.ingredients)
    end

    local prototype = {
        results = {result},
        ingredients = ingredients,
        energy_required = details.energy_required or 4,
        category = details.category,
        localised_name = details.localised_name or {"recipe-name.enrichment", product:get_localised_name()},
        localised_description = details.localised_description or {"recipe-description.enrichment", product:get_localised_name()},
        icons = details.icons or {
            {icon = product.icon},
            {
                icon = "__sosciencity-graphics__/graphics/icon/enrichment.png",
                scale = 0.3,
                shift = {-8, -8}
            }
        },
        icon_size = details.icon_size or 64,
        do_index_fluid_ingredients = true,
        do_index_fluid_results = true,
        unlock = details.unlock
    }

    return Tirislib.RecipeGenerator.create_from_prototype(prototype)
end

local function create_pure_culture_recipe(details)
    local product_name = details.product
    local product = Tirislib.Fluid.get_by_name(product_name)

    local ingredients = {
        {type = "fluid", name = product_name, amount = 10}
    }
    if details.ingredients then
        Tirislib.Tables.merge(ingredients, details.ingredients)
    end

    local prototype = {
        results = {
            {type = "fluid", name = product_name, amount = details.product_amount or 100}
        },
        ingredients = ingredients,
        energy_required = details.energy_required or 4,
        category = details.category,
        localised_name = details.localised_name or {"recipe-name.pure-culture", product:get_localised_name()},
        localised_description = details.localised_description or {"recipe-description.pure-culture", product:get_localised_name()},
        icons = details.icons or {
            {icon = product.icon},
            {
                icon = "__sosciencity-graphics__/graphics/icon/pure-culture.png",
                scale = 0.3,
                shift = {-8, -8}
            }
        },
        icon_size = details.icon_size or 64,
        do_index_fluid_ingredients = true,
        do_index_fluid_results = true,
        unlock = details.unlock
    }

    return Tirislib.RecipeGenerator.create_from_prototype(prototype)
end

create_enrichment_recipe {
    product = "mynellia",
    product_type = "fluid",
    ingredients = {
        {type = "fluid", name = "water", amount = 10}
    },
    category = "sosciencity-algae-farm",
    unlock = "basic-biotechnology"
}

create_pure_culture_recipe {
    product = "mynellia",
    product_type = "fluid",
    ingredients = {
        {type = "fluid", name = "water", amount = 90}
    },
    category = "sosciencity-algae-farm",
    unlock = "basic-biotechnology"
}

create_enrichment_recipe {
    product = "solfaen",
    product_type = "fluid",
    product_probability = 0.2,
    ingredients = {
        {type = "fluid", name = "clean-water", amount = 10}
    },
    category = "sosciencity-algae-farm",
    unlock = "basic-biotechnology"
}

create_pure_culture_recipe {
    product = "solfaen",
    product_type = "fluid",
    ingredients = {
        {type = "fluid", name = "clean-water", amount = 90}
    },
    category = "sosciencity-algae-farm",
    unlock = "basic-biotechnology"
}

create_enrichment_recipe {
    product = "pemtenn",
    product_type = "fluid",
    ingredients = {
        {type = "fluid", name = "clean-water", amount = 10},
        {type = "item", name = "blue-grapes", amount = 2}
    },
    category = "sosciencity-fermentation-tank",
    unlock = "fermentation"
}

create_pure_culture_recipe {
    product = "pemtenn",
    product_type = "fluid",
    ingredients = {
        {type = "fluid", name = "sugar-medium", amount = 90}
    },
    category = "sosciencity-fermentation-tank",
    unlock = "fermentation"
}

create_enrichment_recipe {
    product = "flinnum",
    product_type = "fluid",
    product_probability = 0.2,
    ingredients = {
        {type = "fluid", name = "sugar-medium", amount = 10},
        {type = "item", name = "mold", amount = 2}
    },
    category = "sosciencity-bioreactor",
    unlock = "basic-biotechnology"
}

create_pure_culture_recipe {
    product = "flinnum",
    product_type = "fluid",
    ingredients = {
        {type = "fluid", name = "sugar-medium", amount = 90}
    },
    category = "sosciencity-bioreactor",
    unlock = "basic-biotechnology"
}

create_enrichment_recipe {
    product = "fiicorum",
    product_type = "fluid",
    product_probability = 0.2,
    themes = {{"soil", 2}},
    ingredients = {
        {type = "fluid", name = "sugar-medium", amount = 10},
        {type = "fluid", name = "steam", amount = 50},
        {type = "item", name = "pemtenn-extract", amount = 1},
        {type = "item", name = "mold", amount = 2}
    },
    category = "sosciencity-bioreactor",
    unlock = "genetic-neogenesis"
}

create_pure_culture_recipe {
    product = "fiicorum",
    product_type = "fluid",
    ingredients = {
        {type = "fluid", name = "sugar-medium", amount = 90},
        {type = "fluid", name = "steam", amount = 50},
        {type = "item", name = "pemtenn-extract", amount = 1}
    },
    category = "sosciencity-bioreactor",
    unlock = "genetic-neogenesis"
}
