local Humidity = require("enums.humidity")

local Biology = require("constants.biology")
local Unlocks = require("constants.unlocks")
local WeatherLocales = require("constants.weather-locales")

require("classes.weather")

---------------------------------------------------------------------------------------------------
-- << items >>

local flora_items = {
    {
        name = "leafage",
        sprite_variations = {name = "leafage", count = 3, include_icon = true},
        distinctions = {fuel_value = "200kJ", fuel_category = "chemical"}
    },
    {name = "plemnemm-cotton", sprite_variations = {name = "plemnemm-cotton-pile", count = 4}},
    {name = "phytofall-blossom"},
    {name = "tiriscefing-willow-wood", wood = true, unlock = "open-environment-farming"},
    {name = "cherry-wood", wood = true, unlock = Unlocks.get_tech_name("cherry")},
    {name = "olive-wood", wood = true, unlock = Unlocks.get_tech_name("olive")},
    {name = "ortrot-wood", wood = true, unlock = Unlocks.get_tech_name("ortrot")},
    {name = "avocado-wood", wood = true, unlock = Unlocks.get_tech_name("avocado")},
    {name = "zetorn-wood", wood = true, unlock = Unlocks.get_tech_name("zetorn")},
    {name = "sugar-cane", sprite_variations = {name = "sugar-cane", count = 3, include_icon = true}},
    {name = "gingil-hemp", sprite_variations = {name = "gingil-hemp-pile", count = 3}},
    {name = "necrofall"}
}

for _, item in pairs(flora_items) do
    local distinctions = Tirislib_Tables.get_subtbl(item, "distinctions")

    if item.wood then
        distinctions.fuel_value = "1MJ"
        distinctions.fuel_category = "chemical"
    end
end

Tirislib_Item.batch_create(flora_items, {subgroup = "sosciencity-flora", stack_size = 200})

---------------------------------------------------------------------------------------------------
-- << farming recipes >>

local humidity_multipliers = {
    [Humidity.dry] = 1 / 4,
    [Humidity.moderate] = 1 / 2,
    [Humidity.humid] = 1
}

local function add_general_growing_attributes(details, plant_details)
    if plant_details.required_module then
        Tirislib_Locales.append(
            details.localised_description,
            "\n\n",
            {
                "sosciencity.module-required",
                {
                    "sosciencity.xitems",
                    1,
                    plant_details.required_module,
                    {"item-name." .. plant_details.required_module}
                }
            }
        )
    end
end

local function create_annual_recipe(details)
    local product = Tirislib_Item.get_by_name(details.product)
    local plant_details = Biology.flora[product.name]

    local energy_required = 200 / plant_details.growth_coefficient
    local water_required = energy_required * 10 * humidity_multipliers[plant_details.preferred_humidity]

    Tirislib_RecipeGenerator.merge_details(
        details,
        {
            name = "farming-annual-" .. product.name,
            product_min = 0,
            product_max = 400,
            energy_required = energy_required,
            expensive_energy_required = energy_required * 1.2,
            themes = {{"water", water_required, water_required * 2}},
            ingredients = {{type = "item", name = product.name, amount = 10}},
            byproducts = {{type = "item", name = "leafage", amount_min = 1, amount_max = 40}},
            localised_name = {"recipe-name.annual", product:get_localised_name()},
            localised_description = {
                "recipe-description.annual",
                product:get_localised_name(),
                WeatherLocales.climate[plant_details.preferred_climate],
                WeatherLocales.humidity[plant_details.preferred_humidity],
                Tirislib_Locales.display_percentage(plant_details.wrong_climate_coefficient - 1),
                Tirislib_Locales.display_percentage(plant_details.wrong_humidity_coefficient - 1)
            },
            category = "sosciencity-farming-annual",
            subgroup = "sosciencity-flora",
            icons = {
                {icon = product.icon},
                {
                    icon = "__sosciencity-graphics__/graphics/icon/farming.png",
                    scale = 0.3,
                    shift = {-8, -8}
                }
            },
            icon_size = 64,
            unlock = "open-environment-farming"
        }
    )

    add_general_growing_attributes(details, plant_details)

    return Tirislib_RecipeGenerator.create(details)
end

local function create_perennial_recipe(details)
    local product = Tirislib_Item.get_by_name(details.product)
    local plant_details = Biology.flora[product.name]

    local water_required = 150 * humidity_multipliers[plant_details.preferred_humidity]

    Tirislib_RecipeGenerator.merge_details(
        details,
        {
            name = "farming-perennial-" .. product.name,
            product_min = 1,
            product_max = 5,
            energy_required = 15,
            expensive_energy_required = 17.5,
            themes = {{"water", water_required, water_required * 2}},
            byproducts = {{type = "item", name = "leafage", amount = 1}},
            localised_name = {"recipe-name.perennial", product:get_localised_name()},
            localised_description = {
                "recipe-description.perennial",
                product:get_localised_name(),
                WeatherLocales.climate[plant_details.preferred_climate],
                WeatherLocales.humidity[plant_details.preferred_humidity],
                Tirislib_Locales.display_percentage(plant_details.wrong_climate_coefficient - 1),
                Tirislib_Locales.display_percentage(plant_details.wrong_humidity_coefficient - 1)
            },
            category = "sosciencity-farming-perennial",
            subgroup = "sosciencity-flora",
            icons = {
                {icon = product.icon},
                {
                    icon = "__sosciencity-graphics__/graphics/icon/farming.png",
                    scale = 0.3,
                    shift = {-8, -8}
                }
            },
            icon_size = 64,
            unlock = "open-environment-farming"
        }
    )

    add_general_growing_attributes(details, plant_details)

    return Tirislib_RecipeGenerator.create(details)
end

local function create_annual_bloomhouse_recipe(details)
    local product = Tirislib_Item.get_by_name(details.product)
    local plant_details = Biology.flora[product.name]

    local energy_required = 200 / plant_details.growth_coefficient
    local water_required = energy_required * 10 * humidity_multipliers[plant_details.preferred_humidity]

    Tirislib_RecipeGenerator.merge_details(
        details,
        {
            name = "farming-annual-bloomhouse-" .. product.name,
            product_min = 150,
            product_max = 250,
            energy_required = energy_required,
            expensive_energy_required = energy_required * 1.2,
            themes = {{"water", water_required, water_required * 2}},
            ingredients = {
                {type = "item", name = product.name, amount = 10},
                {type = "item", name = "pot", amount = 20}
            },
            byproducts = {
                {type = "item", name = "leafage", amount_min = 1, amount_max = 5},
                {type = "item", name = "pot", amount_min = 19, amount_max = 20}
            },
            localised_name = {"recipe-name.annual", product:get_localised_name()},
            localised_description = {
                "recipe-description.annual-bloomhouse",
                product:get_localised_name()
            },
            category = "sosciencity-bloomhouse-annual",
            subgroup = "sosciencity-flora",
            icons = {
                {icon = product.icon},
                {
                    icon = "__sosciencity-graphics__/graphics/icon/farming.png",
                    scale = 0.3,
                    shift = {-8, -8}
                }
            },
            icon_size = 64,
            unlock = "indoor-growing"
        }
    )

    add_general_growing_attributes(details, plant_details)

    return Tirislib_RecipeGenerator.create(details)
end

local function create_neogenesis_recipe(details)
    local product = Tirislib_Item.get_by_name(details.product)

    Tirislib_RecipeGenerator.merge_details(
        details,
        {
            product_amount = 1,
            energy_required = 10,
            themes = {{"genetic_neogenesis", 1}},
            ingredients = {
                {type = "item", name = "chloroplasts", amount = 1},
                {type = "item", name = "plant-genome", amount = 1}
            },
            byproducts = {
                {type = "item", name = "empty-hard-drive", amount = 1, probability = 0.99}
            },
            localised_name = {"recipe-name.neogenesis", product:get_localised_name()},
            localised_description = {"recipe-description.neogenesis", product:get_localised_name()},
            category = "sosciencity-phyto-gene-lab",
            subgroup = "sosciencity-neogenesis-recipes",
            icons = {
                {icon = product.icon},
                {
                    icon = "__sosciencity-graphics__/graphics/icon/plant-neogenesis.png",
                    scale = 0.3,
                    shift = {-8, -8}
                }
            },
            icon_size = 64,
            unlock = "genetic-neogenesis"
        }
    )

    return Tirislib_RecipeGenerator.create(details)
end

-- apple
create_perennial_recipe {
    product = "apple",
    byproducts = {{type = "item", name = "ortrot-wood", amount = 1, probability = 0.2}},
    unlock = Unlocks.get_tech_name("apple")
}

create_neogenesis_recipe {
    product = "apple",
    unlock = "ortrot-variations"
}

-- avocado
create_perennial_recipe {
    product = "avocado",
    byproducts = {{type = "item", name = "avocado-wood", amount = 1, probability = 0.2}},
    unlock = Unlocks.get_tech_name("avocado")
}

create_neogenesis_recipe {
    product = "avocado"
}

-- bell pepper
create_annual_recipe {
    product = "bell-pepper",
    unlock = Unlocks.get_tech_name("bell-pepper")
}

create_neogenesis_recipe {
    product = "bell-pepper",
    unlock = "nightshades"
}

-- blue grapes
create_annual_recipe {
    product = "blue-grapes",
    unlock = Unlocks.get_tech_name("blue-grapes")
}

-- brutal pumpkin
create_annual_recipe {
    product = "brutal-pumpkin",
    unlock = Unlocks.get_tech_name("brutal-pumpkin")
}

-- cherry
create_perennial_recipe {
    product = "cherry",
    byproducts = {{type = "item", name = "cherry-wood", amount = 1, probability = 0.2}},
    unlock = Unlocks.get_tech_name("cherry")
}

create_neogenesis_recipe {
    product = "cherry"
}

-- chickpea
create_annual_recipe {
    product = "chickpea",
    unlock = Unlocks.get_tech_name("chickpea")
}

create_neogenesis_recipe {
    product = "chickpea",
    unlock = "hummus"
}

-- eggplant
create_annual_recipe {
    product = "eggplant",
    unlock = Unlocks.get_tech_name("eggplant")
}

create_neogenesis_recipe {
    product = "eggplant",
    unlock = "nightshades"
}

-- gingil hemp
create_annual_recipe {
    product = "gingil-hemp"
}

-- lemon
create_perennial_recipe {
    product = "lemon",
    byproducts = {{type = "item", name = "zetorn-wood", amount = 1, probability = 0.2}},
    unlock = Unlocks.get_tech_name("lemon")
}

create_neogenesis_recipe {
    product = "lemon",
    unlock = "zetorn-variations"
}

-- liontooth
create_perennial_recipe {
    product = "liontooth",
    unlock = Unlocks.get_tech_name("liontooth")
}

-- manok
create_annual_recipe {
    product = "manok",
    unlock = Unlocks.get_tech_name("manok")
}

-- necrofall
create_annual_recipe {
    product = "necrofall",
    product_probability = 0.25,
    unlock = Unlocks.get_tech_name("necrofall")
}

create_annual_bloomhouse_recipe {
    product = "necrofall",
    unlock = Unlocks.get_tech_name("necrofall")
}

-- olive
create_perennial_recipe {
    product = "olive",
    byproducts = {{type = "item", name = "olive-wood", amount = 1, probability = 0.2}},
    unlock = Unlocks.get_tech_name("olive")
}

create_neogenesis_recipe {
    product = "olive"
}

-- orange
create_perennial_recipe {
    product = "orange",
    byproducts = {{type = "item", name = "zetorn-wood", amount = 1, probability = 0.2}},
    unlock = Unlocks.get_tech_name("orange")
}

create_neogenesis_recipe {
    product = "orange",
    unlock = "zetorn-variations"
}

-- ortrot
create_perennial_recipe {
    product = "ortrot",
    byproducts = {{type = "item", name = "ortrot-wood", amount = 1, probability = 0.2}},
    unlock = Unlocks.get_tech_name("ortrot")
}

-- phytofall blossom
create_annual_recipe {
    product = "phytofall-blossom",
    product_probability = 0.25,
    unlock = Unlocks.get_tech_name("phytofall-blossom")
}

create_annual_bloomhouse_recipe {
    product = "phytofall-blossom",
    unlock = Unlocks.get_tech_name("phytofall-blossom")
}

-- potato
create_annual_recipe {
    product = "potato",
    unlock = Unlocks.get_tech_name("potato")
}

create_neogenesis_recipe {
    product = "potato",
    unlock = "nightshades"
}

-- razha bean
create_perennial_recipe {
    product = "razha-bean",
    unlock = Unlocks.get_tech_name("razha-bean")
}

-- sesame
create_annual_recipe {
    product = "sesame",
    unlock = Unlocks.get_tech_name("sesame")
}

create_neogenesis_recipe {
    product = "sesame",
    unlock = "hummus"
}

-- sugar beet
create_annual_recipe {
    product = "sugar-beet",
    unlock = Unlocks.get_tech_name("sugar-beet")
}

create_neogenesis_recipe {
    product = "sugar-beet"
}

-- sugar cane
create_annual_recipe {
    product = "sugar-cane",
    unlock = Unlocks.get_tech_name("sugar-cane")
}

create_neogenesis_recipe {
    product = "sugar-cane"
}

-- tomato
create_annual_recipe {
    product = "tomato",
    unlock = Unlocks.get_tech_name("tomato")
}

create_neogenesis_recipe {
    product = "tomato",
    unlock = "nightshades"
}

-- plemnemm cotton
create_annual_recipe {
    product = "plemnemm-cotton"
}

-- tiriscefing willow
create_perennial_recipe {
    product = "tiriscefing-willow-wood",
    byproducts = {{type = "item", name = "fawoxylas", amount = 2, probability = 0.5}}
}

-- unnamed fruit
create_annual_recipe {
    product = "unnamed-fruit",
    unlock = Unlocks.get_tech_name("unnamed-fruit")
}

-- weird berry
create_annual_recipe {
    product = "weird-berry",
    unlock = Unlocks.get_tech_name("weird-berry")
}

-- zetorn
create_perennial_recipe {
    product = "zetorn",
    byproducts = {{type = "item", name = "zetorn-wood", amount = 1, probability = 0.2}},
    unlock = Unlocks.get_tech_name("zetorn")
}

---------------------------------------------------------------------------------------------------
-- << processing recipes >>

for _, item in pairs(flora_items) do
    if item.wood then
        Tirislib_RecipeGenerator.create {
            product = "lumber",
            product_amount = 2,
            ingredients = {
                {name = item.name, amount = 1}
            },
            byproducts = {
                {name = "sawdust", amount = 2}
            },
            allow_productivity = true,
            unlock = item.unlock
        }

        Tirislib_RecipeGenerator.create {
            product = "sawdust",
            product_amount = 10,
            ingredients = {
                {name = item.name, amount = 1}
            },
            unlock = item.unlock
        }
    end
end

---------------------------------------------------------------------------------------------------
-- << saplings >>

Tirislib_Prototype.create {
    name = "sosciencity-saplings",
    type = "module-category"
}

local saplings = {
    {
        name = "apple-sapling",
        distinctions = {limitation = {"farming-perennial-apple"}}
    },
    {
        name = "avocado-sapling",
        distinctions = {limitation = {"farming-perennial-avocado"}}
    },
    {
        name = "cherry-sapling",
        distinctions = {limitation = {"farming-perennial-cherry"}}
    },
    {
        name = "lemon-sapling",
        distinctions = {limitation = {"farming-perennial-lemon"}}
    },
    {
        name = "orange-sapling",
        distinctions = {limitation = {"farming-perennial-orange"}}
    },
    {
        name = "ortrot-sapling",
        distinctions = {limitation = {"farming-perennial-ortrot"}}
    },
    {
        name = "zetorn-sapling",
        distinctions = {limitation = {"farming-perennial-zetorn"}}
    }
}

for _, sapling in pairs(saplings) do
    local distinctions = Tirislib_Tables.get_subtbl(sapling, "distinctions")

    -- search the flora item that needs this sapling
    for flora_name, details in pairs(Biology.flora) do
        if details.required_module == sapling.name then
            local flora_item = Tirislib_Item.get_by_name(flora_name)
            distinctions.localised_description = {"sosciencity.sapling", flora_item:get_localised_name()}

            distinctions.icons = {
                {
                    icon = "__sosciencity-graphics__/graphics/icon/sapling-1.png"
                },
                {
                    icon = flora_item.icon,
                    scale = 0.3,
                    shift = {8, 8}
                }
            }
            distinctions.icon = 64
        end
    end

    sapling.sprite_variations = {name = "sapling", count = 3}
end

Tirislib_Item.batch_create(
    saplings,
    {
        type = "module",
        effect = {},
        category = "sosciencity-saplings",
        tier = 1,
        subgroup = "sosciencity-saplings",
        stack_size = 10
    }
)

Tirislib_RecipeGenerator.create {
    product = "apple-sapling",
    themes = {{"soil", 10, 25}},
    ingredients = {
        {type = "item", name = "ortrot-sapling", amount = 1},
        {type = "item", name = "apple", amount = 10}
    },
    category = "sosciencity-plant-upbringing",
    default_theme_level = 2,
    unlock = Unlocks.get_tech_name("apple")
}

Tirislib_RecipeGenerator.create {
    product = "avocado-sapling",
    themes = {{"soil", 10, 25}},
    ingredients = {
        {type = "item", name = "pot", amount = 1},
        {type = "item", name = "avocado", amount = 10}
    },
    category = "sosciencity-plant-upbringing",
    default_theme_level = 1,
    unlock = Unlocks.get_tech_name("avocado")
}

Tirislib_RecipeGenerator.create {
    product = "cherry-sapling",
    themes = {{"soil", 10, 25}},
    ingredients = {
        {type = "item", name = "pot", amount = 1},
        {type = "item", name = "cherry", amount = 10}
    },
    category = "sosciencity-plant-upbringing",
    default_theme_level = 1,
    unlock = Unlocks.get_tech_name("cherry")
}

Tirislib_RecipeGenerator.create {
    product = "lemon-sapling",
    themes = {{"soil", 10, 25}},
    ingredients = {
        {type = "item", name = "zetorn-sapling", amount = 1},
        {type = "item", name = "apple", amount = 10}
    },
    category = "sosciencity-plant-upbringing",
    default_theme_level = 2,
    unlock = Unlocks.get_tech_name("lemon")
}

Tirislib_RecipeGenerator.create {
    product = "orange-sapling",
    themes = {{"soil", 10, 25}},
    ingredients = {
        {type = "item", name = "zetorn-sapling", amount = 1},
        {type = "item", name = "orange", amount = 10}
    },
    category = "sosciencity-plant-upbringing",
    default_theme_level = 2,
    unlock = Unlocks.get_tech_name("orange")
}

Tirislib_RecipeGenerator.create {
    product = "ortrot-sapling",
    themes = {{"soil", 10, 25}},
    ingredients = {
        {type = "item", name = "pot", amount = 1},
        {type = "item", name = "ortrot", amount = 10}
    },
    category = "sosciencity-plant-upbringing",
    default_theme_level = 0,
    unlock = Unlocks.get_tech_name("ortrot")
}

Tirislib_RecipeGenerator.create {
    product = "zetorn-sapling",
    themes = {{"soil", 10, 25}},
    ingredients = {
        {type = "item", name = "pot", amount = 1},
        {type = "item", name = "zetorn", amount = 10}
    },
    category = "sosciencity-plant-upbringing",
    default_theme_level = 0,
    unlock = Unlocks.get_tech_name("zetorn")
}

---------------------------------------------------------------------------------------------------
-- << necrofall decorative >>

Tirislib_Entity.create {
    name = "necrofall-circle",
    type = "simple-entity",
    count_as_rock_for_filtered_deconstruction = true,
    minable = {
        mining_time = 1.5,
        results = {{name = "necrofall", amount_min = 10, amount_max = 15}}
    },
    pictures = {
        {
            filename = "__sosciencity-graphics__/graphics/entity/necrofall-circle/necrofall-circle-1.png",
            width = 256,
            height = 256,
            shift = {0.0, 0.0},
            scale = 0.25
        },
        {
            filename = "__sosciencity-graphics__/graphics/entity/necrofall-circle/necrofall-circle-2.png",
            width = 256,
            height = 256,
            shift = {0.0, 0.0},
            scale = 0.25
        },
        {
            filename = "__sosciencity-graphics__/graphics/entity/necrofall-circle/necrofall-circle-3.png",
            width = 256,
            height = 256,
            shift = {0.0, 0.0},
            scale = 0.25
        }
    }
}:set_size(1.8, 1.8):copy_localisation_from_item("necrofall")
