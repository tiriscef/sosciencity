local fluids = {
    {
        name = "solfaen",
        distinctions = {
            base_color = {r = 0.944, g = 0.180, b = 0.063},
            flow_color = {r = 0.944, g = 0.383, b = 0.178}
        }
    },
    {
        name = "fiicorum",
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
    }
}

Tirislib_Fluid.batch_create(
    fluids,
    {
        default_temperature = 10,
        max_temperature = 100,
        base_color = {r = 0.151, g = 0.483, b = 0.933},
        flow_color = {r = 0.151, g = 0.483, b = 0.933},
        subgroup = "sosciencity-microorganisms"
    }
)

local function create_enrichment_recipe(details)
    local product = Tirislib_Fluid.get_by_name(details.product)

    Tirislib_RecipeGenerator.merge_details(
        details,
        {
            product_amount = 10,
            energy_required = 4,
            localised_name = {"recipe-name.enrichment", product:get_localised_name()},
            localised_description = {"recipe-description.enrichment", product:get_localised_name()},
            icons = {
                {icon = product.icon},
                {
                    icon = "__sosciencity-graphics__/graphics/icon/enrichment.png",
                    scale = 0.3,
                    shift = {-8, -8}
                }
            },
            icon_size = 64
        }
    )

    return Tirislib_RecipeGenerator.create(details)
end

local function create_pure_culture_recipe(details)
    local product = Tirislib_Fluid.get_by_name(details.product)

    Tirislib_RecipeGenerator.merge_details(
        details,
        {
            product_amount = 20,
            energy_required = 0.8,
            localised_name = {"recipe-name.pure-culture", product:get_localised_name()},
            localised_description = {"recipe-description.pure-culture", product:get_localised_name()},
            icons = {
                {icon = product.icon},
                {
                    icon = "__sosciencity-graphics__/graphics/icon/pure-culture.png",
                    scale = 0.3,
                    shift = {-8, -8}
                }
            },
            ingredients = {
                {type = "fluid", name = product.name, amount = 10}
            },
            icon_size = 64
        }
    )

    return Tirislib_RecipeGenerator.create(details)
end

create_enrichment_recipe {
    product = "solfaen",
    product_type = "fluid",
    ingredients = {
        {type = "fluid", name = "clean-water", amount = 10}
    },
    category = "sosciencity-microalgae-farm",
    unlock = "basic-biotechnology"
}

create_pure_culture_recipe {
    product = "solfaen",
    product_type = "fluid",
    ingredients = {
        {type = "fluid", name = "clean-water", amount = 10}
    },
    category = "sosciencity-microalgae-farm",
    unlock = "basic-biotechnology"
}

create_enrichment_recipe {
    product = "fiicorum",
    product_type = "fluid",
    ingredients = {
        {type = "fluid", name = "clean-water", amount = 10}
    },
    category = "sosciencity-bioreactor",
    unlock = "genetic-neogenesis"
}

create_pure_culture_recipe {
    product = "fiicorum",
    product_type = "fluid",
    ingredients = {
        {type = "fluid", name = "clean-water", amount = 10}
    },
    category = "sosciencity-bioreactor",
    unlock = "genetic-neogenesis"
}

create_enrichment_recipe {
    product = "pemtenn",
    product_type = "fluid",
    ingredients = {
        {type = "fluid", name = "clean-water", amount = 10}
    },
    category = "sosciencity-fermentation-tank",
    unlock = "fermentation"
}

create_pure_culture_recipe {
    product = "pemtenn",
    product_type = "fluid",
    ingredients = {
        {type = "fluid", name = "clean-water", amount = 10}
    },
    category = "sosciencity-fermentation-tank",
    unlock = "fermentation"
}