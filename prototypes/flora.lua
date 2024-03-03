local Humidity = require("enums.humidity")

local Biology = require("constants.biology")
local Unlocks = require("constants.unlocks")
local WeatherLocales = require("constants.weather-locales")

---------------------------------------------------------------------------------------------------
-- << items >>

local flora_items = {
    {
        name = "leafage",
        sprite_variations = {name = "leafage", count = 3, include_icon = true},
        distinctions = {fuel_value = "500kJ", fuel_category = "chemical"}
    },
    {
        name = "hardcorn-punk",
        sprite_variations = {name = "hardcorn-punk-pile", count = 3}
    },
    {name = "plemnemm-cotton", sprite_variations = {name = "plemnemm-cotton-pile", count = 4}},
    {name = "tiriscefing-willow-wood", wood = true, unlock = "open-environment-farming"},
    {name = "cherry-wood", wood = true, unlock = Unlocks.get_tech_name("cherry")},
    {name = "olive-wood", wood = true, unlock = Unlocks.get_tech_name("olive")},
    {name = "ortrot-wood", wood = true, unlock = Unlocks.get_tech_name("ortrot")},
    {name = "avocado-wood", wood = true, unlock = Unlocks.get_tech_name("avocado")},
    {name = "zetorn-wood", wood = true, unlock = Unlocks.get_tech_name("zetorn")},
    {name = "sugar-cane", sprite_variations = {name = "sugar-cane", count = 3, include_icon = true}},
    {name = "gingil-hemp", sprite_variations = {name = "gingil-hemp-pile", count = 3}},
    {name = "necrofall"},
    {name = "phytofall-blossom"}
}

for _, item in pairs(flora_items) do
    local distinctions = Tirislib.Tables.get_subtbl(item, "distinctions")

    if item.wood then
        distinctions.fuel_value = "2MJ"
        distinctions.fuel_category = "chemical"
    end
end

Tirislib.Item.batch_create(flora_items, {subgroup = "sosciencity-flora", stack_size = 200})

---------------------------------------------------------------------------------------------------
-- << farming recipes >>

local humidity_multipliers = {
    [Humidity.dry] = 1 / 4,
    [Humidity.moderate] = 1 / 2,
    [Humidity.humid] = 1
}

local function add_general_growing_attributes(details, plant_details)
    if plant_details.required_module then
        Tirislib.Locales.append(
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
    local product = Tirislib.Item.get_by_name(details.product)
    local plant_details = Biology.flora[product.name]

    local energy_required = 200 / plant_details.growth_coefficient
    local water_required = energy_required * 10 * humidity_multipliers[plant_details.preferred_humidity]

    Tirislib.RecipeGenerator.merge_details(
        details,
        {
            name = "farming-annual-" .. product.name,
            product_min = 0,
            product_max = 100 * (details.output_multiplier or 1),
            energy_required = energy_required,
            expensive_energy_required = energy_required * 1.2,
            themes = {{"water", water_required, water_required * 2}},
            ingredients = {
                {type = "item", name = product.name, amount = 10 * (details.output_multiplier or 1)}
            },
            byproducts = {
                {
                    type = "item",
                    name = product.name,
                    amount_min = 0,
                    amount_max = 100 * (details.output_multiplier or 1),
                    probability = details.product_probability
                },
                {type = "item", name = "leafage", amount_min = 1, amount_max = 40}
            },
            localised_name = {"recipe-name.annual", product:get_localised_name()},
            localised_description = {
                "recipe-description.annual",
                product:get_localised_name(),
                WeatherLocales.climate[plant_details.preferred_climate],
                WeatherLocales.humidity[plant_details.preferred_humidity],
                Tirislib.Locales.display_percentage(plant_details.wrong_climate_coefficient - 1),
                Tirislib.Locales.display_percentage(plant_details.wrong_humidity_coefficient - 1)
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

    return Tirislib.RecipeGenerator.create(details)
end

local function create_perennial_recipe(details)
    local product = Tirislib.Item.get_by_name(details.product)
    local plant_details = Biology.flora[product.name]

    local water_required = 150 * humidity_multipliers[plant_details.preferred_humidity]

    Tirislib.RecipeGenerator.merge_details(
        details,
        {
            name = "farming-perennial-" .. product.name,
            product_min = 5 * (details.output_multiplier or 1),
            product_max = 10 * (details.output_multiplier or 1),
            energy_required = 25,
            expensive_energy_required = 17.5,
            themes = {{"water", water_required, water_required * 2}},
            byproducts = {{type = "item", name = "leafage", amount = 1}},
            localised_name = {"recipe-name.perennial", product:get_localised_name()},
            localised_description = {
                "recipe-description.perennial",
                product:get_localised_name(),
                WeatherLocales.climate[plant_details.preferred_climate],
                WeatherLocales.humidity[plant_details.preferred_humidity],
                Tirislib.Locales.display_percentage(plant_details.wrong_climate_coefficient - 1),
                Tirislib.Locales.display_percentage(plant_details.wrong_humidity_coefficient - 1)
            },
            category = "sosciencity-farming-perennial",
            subgroup = "sosciencity-flora-perennial",
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

    return Tirislib.RecipeGenerator.create(details)
end

local function create_annual_bloomhouse_recipe(details)
    local product = Tirislib.Item.get_by_name(details.product)
    local plant_details = Biology.flora[product.name]

    local energy_required = 200 / plant_details.growth_coefficient
    local water_required = energy_required * 10 * humidity_multipliers[plant_details.preferred_humidity]

    Tirislib.RecipeGenerator.merge_details(
        details,
        {
            name = "farming-annual-bloomhouse-" .. product.name,
            product_min = 50 * (details.output_multiplier or 1),
            product_max = 100 * (details.output_multiplier or 1),
            energy_required = energy_required,
            expensive_energy_required = energy_required * 1.2,
            themes = {{"water", water_required, water_required * 2}},
            ingredients = {
                {type = "item", name = product.name, amount = 10},
                {type = "item", name = "pot", amount = 20}
            },
            byproducts = {
                {
                    type = "item",
                    name = product.name,
                    amount_min = 50 * (details.output_multiplier or 1),
                    amount_max = 100 * (details.output_multiplier or 1),
                    probability = details.product_probability
                },
                {type = "item", name = "leafage", amount_min = 1, amount_max = 40},
                {type = "item", name = "pot", amount_min = 19, amount_max = 20}
            },
            localised_name = {"recipe-name.annual-bloomhouse", product:get_localised_name()},
            localised_description = {
                "recipe-description.annual-bloomhouse",
                product:get_localised_name()
            },
            category = "sosciencity-bloomhouse-annual",
            subgroup = "sosciencity-flora-bloomhouse",
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

    return Tirislib.RecipeGenerator.create(details)
end

local function create_identification_recipe(details)
    local product = Tirislib.Item.get_by_name(details.product)

    Tirislib.RecipeGenerator.merge_details(
        details,
        {
            product_amount = 1,
            energy_required = 8,
            localised_name = {"recipe-name.flora-identification", product:get_localised_name()},
            localised_description = {"recipe-description.flora-identification", product:get_localised_name()},
            category = "sosciencity-caste-ember",
            subgroup = "sosciencity-neogenesis-recipes",
            icons = {
                {icon = product.icon},
                {
                    icon = "__sosciencity-graphics__/graphics/icon/plant-neogenesis.png",
                    scale = 0.3,
                    shift = {-8, -8}
                }
            },
            icon_size = 64
        }
    )

    return Tirislib.RecipeGenerator.create(details)
end

local function create_neogenesis_recipe(details)
    local product = Tirislib.Item.get_by_name(details.product)

    Tirislib.RecipeGenerator.merge_details(
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

    return Tirislib.RecipeGenerator.create(details)
end

-- apple
create_perennial_recipe {
    product = "apple",
    output_multiplier = 1.4,
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
    output_multiplier = 0.8,
    byproducts = {{type = "item", name = "avocado-wood", amount = 1, probability = 0.2}},
    unlock = Unlocks.get_tech_name("avocado")
}

create_neogenesis_recipe {
    product = "avocado"
}

-- bell pepper
create_annual_recipe {
    product = "bell-pepper",
    output_multiplier = 1.5,
    unlock = Unlocks.get_tech_name("bell-pepper")
}

create_neogenesis_recipe {
    product = "bell-pepper",
    unlock = "nightshades"
}

-- blue grapes
create_annual_recipe {
    product = "blue-grapes",
    unlock = "open-environment-farming"
}

-- brutal pumpkin
create_annual_recipe {
    product = "brutal-pumpkin",
    unlock = "explore-alien-flora-2"
}

create_identification_recipe {
    product = "brutal-pumpkin",
    ingredients = {
        {type = "item", name = "wild-edible-plants", amount = 20},
        {type = "item", name = "botanical-study", amount = 20},
        {type = "item", name = "hummus", amount = 40}
    },
    unlock = "explore-alien-flora-2"
}

-- cherry
create_perennial_recipe {
    product = "cherry",
    output_multiplier = 1.6,
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
    output_multiplier = 1.5,
    unlock = Unlocks.get_tech_name("eggplant")
}

create_neogenesis_recipe {
    product = "eggplant",
    unlock = "nightshades"
}

-- gingil hemp
create_annual_recipe {
    product = "gingil-hemp",
    output_multiplier = 1.5
}

-- hardcorn punk
create_annual_recipe {
    product = "hardcorn-punk",
    unlock = "food-processing"
}

create_identification_recipe {
    product = "manok",
    ingredients = {
        {type = "item", name = "wild-edible-plants", amount = 20},
        {type = "item", name = "botanical-study", amount = 10},
        {type = "item", name = "leafage", amount = 200}
    },
    unlock = "food-processing"
}

-- lemon
create_perennial_recipe {
    product = "lemon",
    output_multiplier = 1.6,
    byproducts = {{type = "item", name = "zetorn-wood", amount = 1, probability = 0.2}},
    unlock = Unlocks.get_tech_name("lemon")
}

create_neogenesis_recipe {
    product = "lemon",
    unlock = "zetorn-variations"
}

-- liontooth
create_annual_recipe {
    product = "liontooth",
    output_multiplier = 1.5,
    unlock = "open-environment-farming"
}

-- manok
create_annual_recipe {
    product = "manok",
    unlock = "explore-alien-flora-1"
}

create_identification_recipe {
    product = "manok",
    ingredients = {
        {type = "item", name = "wild-edible-plants", amount = 20},
        {type = "item", name = "botanical-study", amount = 10},
        {type = "item", name = "hummus", amount = 40}
    },
    unlock = "explore-alien-flora-1"
}

-- necrofall
create_annual_recipe {
    product = "necrofall",
    product_probability = 0.5,
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
    unlock = "explore-alien-flora-2"
}

create_identification_recipe {
    product = "ortrot",
    ingredients = {
        {type = "item", name = "wild-edible-plants", amount = 20},
        {type = "item", name = "botanical-study", amount = 20},
        {type = "item", name = "hummus", amount = 40}
    },
    unlock = "explore-alien-flora-2"
}

-- phytofall blossom
create_annual_recipe {
    product = "phytofall-blossom",
    product_probability = 0.5,
    unlock = "orchid-caste"
}

create_annual_bloomhouse_recipe {
    product = "phytofall-blossom",
    unlock = "orchid-caste"
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
create_annual_recipe {
    product = "razha-bean",
    unlock = "open-environment-farming"
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

-- tello
create_annual_recipe {
    product = "tello-fruit",
    unlock = "explore-alien-flora-1"
}

create_identification_recipe {
    product = "tello-fruit",
    ingredients = {
        {type = "item", name = "wild-edible-plants", amount = 20},
        {type = "item", name = "botanical-study", amount = 10},
        {type = "item", name = "hummus", amount = 40}
    },
    unlock = "explore-alien-flora-1"
}

-- tomato
create_annual_recipe {
    product = "tomato",
    output_multiplier = 1.5,
    unlock = Unlocks.get_tech_name("tomato")
}

create_neogenesis_recipe {
    product = "tomato",
    unlock = "nightshades"
}

-- plemnemm cotton
create_annual_recipe {
    product = "plemnemm-cotton",
    output_multiplier = 2
}

-- tiriscefing willow
create_perennial_recipe {
    product = "tiriscefing-willow-wood",
    byproducts = {{type = "item", name = "fawoxylas", amount = 5, probability = 0.5}}
}

-- unnamed fruit
create_annual_recipe {
    product = "unnamed-fruit",
    unlock = "open-environment-farming"
}

-- weird berry
create_annual_recipe {
    product = "weird-berry",
    unlock = "explore-alien-flora-1"
}

create_identification_recipe {
    product = "weird-berry",
    ingredients = {
        {type = "item", name = "wild-edible-plants", amount = 20},
        {type = "item", name = "botanical-study", amount = 10},
        {type = "item", name = "hummus", amount = 40}
    },
    unlock = "explore-alien-flora-1"
}

-- zetorn
create_perennial_recipe {
    product = "zetorn",
    byproducts = {{type = "item", name = "zetorn-wood", amount = 1, probability = 0.2}},
    unlock = "explore-alien-flora-1"
}

create_identification_recipe {
    product = "zetorn",
    ingredients = {
        {type = "item", name = "wild-edible-plants", amount = 20},
        {type = "item", name = "botanical-study", amount = 10},
        {type = "item", name = "hummus", amount = 40}
    },
    unlock = "explore-alien-flora-1"
}

---------------------------------------------------------------------------------------------------
-- << mushroom >>

local function create_mushroom_recipe(details)
    local product = Tirislib.Item.get_by_name(details.product)
    local plant_details = Biology.flora[product.name]

    local energy_required = 30 / plant_details.growth_coefficient
    local water_required = energy_required * 10 * humidity_multipliers[plant_details.preferred_humidity]

    Tirislib.RecipeGenerator.merge_details(
        details,
        {
            name = "farming-mushroom-" .. product.name,
            product_min = 40 * (details.output_multiplier or 1),
            product_max = 60 * (details.output_multiplier or 1),
            product_probability = details.product_probability,
            energy_required = energy_required,
            expensive_energy_required = energy_required * 1.2,
            themes = {{"water", water_required, water_required * 2}},
            byproducts = {
                {
                    type = "item",
                    name = product.name,
                    amount_min = 40 * (details.output_multiplier or 1),
                    amount_max = 60 * (details.output_multiplier or 1),
                    probability = details.product_probability
                }
            },
            localised_name = {"recipe-name.farm-mushroom", product:get_localised_name()},
            localised_description = {
                "recipe-description.annual",
                product:get_localised_name(),
                WeatherLocales.climate[plant_details.preferred_climate],
                WeatherLocales.humidity[plant_details.preferred_humidity],
                Tirislib.Locales.display_percentage(plant_details.wrong_climate_coefficient - 1),
                Tirislib.Locales.display_percentage(plant_details.wrong_humidity_coefficient - 1)
            },
            category = "sosciencity-mushroom-farm",
            subgroup = "sosciencity-mushrooms",
            icons = {
                {icon = product.icon},
                {
                    icon = "__sosciencity-graphics__/graphics/icon/farming.png",
                    scale = 0.3,
                    shift = {-8, -8}
                }
            },
            icon_size = 64,
            unlock = "basic-biotechnology"
        }
    )

    add_general_growing_attributes(details, plant_details)

    return Tirislib.RecipeGenerator.create(details)
end

-- fawoxylas
create_mushroom_recipe {
    product = "fawoxylas",
    ingredients = {{type = "item", name = "tiriscefing-willow-wood", amount = 30}},
    unlock = "mushroom-farming"
}

-- pocelial
create_mushroom_recipe {
    product = "pocelial",
    ingredients = {{type = "item", name = "humus", amount = 20}},
    unlock = "mushroom-farming"
}

-- red hatty
create_mushroom_recipe {
    product = "red-hatty",
    ingredients = {{type = "item", name = "humus", amount = 20}},
    unlock = "mushroom-farming"
}

-- birdsnake
create_mushroom_recipe {
    product = "birdsnake",
    ingredients = {{type = "item", name = "humus", amount = 10}},
    themes = {{"stone", 10}},
    unlock = "mushroom-farming"
}

---------------------------------------------------------------------------------------------------
-- << algae >>

local function create_algae_recipe(details)
    local product = Tirislib.Item.get_by_name(details.product)
    local plant_details = Biology.flora[product.name]

    local energy_required = 120 / plant_details.growth_coefficient
    local water_required = energy_required * 10

    Tirislib.RecipeGenerator.merge_details(
        details,
        {
            name = "farming-algae-" .. product.name,
            product_min = 20 * (details.output_multiplier or 1),
            product_max = 40 * (details.output_multiplier or 1),
            energy_required = energy_required,
            expensive_energy_required = energy_required * 1.2,
            themes = {{"water", water_required, water_required * 2}},
            byproducts = {
                {
                    type = "item",
                    name = product.name,
                    amount_min = 20 * (details.output_multiplier or 1),
                    amount_max = 40 * (details.output_multiplier or 1),
                    probability = details.product_probability
                }
            },
            localised_name = {"recipe-name.farm-algae", product:get_localised_name()},
            localised_description = {
                "recipe-description.farm-algae",
                product:get_localised_name(),
                WeatherLocales.climate[plant_details.preferred_climate],
                Tirislib.Locales.display_percentage(plant_details.wrong_climate_coefficient - 1)
            },
            category = "sosciencity-algae-farm",
            subgroup = "sosciencity-algae",
            icons = {
                {icon = product.icon},
                {
                    icon = "__sosciencity-graphics__/graphics/icon/farming.png",
                    scale = 0.3,
                    shift = {-8, -8}
                }
            },
            icon_size = 64,
            index_fluid_ingredients = true,
            index_fluid_results = true,
            unlock = "basic-biotechnology"
        }
    )

    add_general_growing_attributes(details, plant_details)

    return Tirislib.RecipeGenerator.create(details)
end

-- endower flower
create_algae_recipe {
    product = "endower-flower",
    unlock = "algae-farming"
}

-- pyrifera
create_algae_recipe {
    product = "pyrifera",
    output_multiplier = 2,
    unlock = "algae-farming"
}

-- queen algae
create_algae_recipe {
    product = "queen-algae",
    unlock = "algae-farming"
}

---------------------------------------------------------------------------------------------------
-- << mix sorting recipes >>

Tirislib.Recipe.create {
    name = "sort-edible-plants",
    energy_required = 2,
    ingredients = {
        {type = "item", name = "wild-edible-plants", amount = 4}
    },
    results = {
        {type = "item", name = "leafage", amount = 1},
        {type = "item", name = "liontooth", amount = 5},
        {type = "item", name = "razha-bean", amount = 2},
        {type = "item", name = "unnamed-fruit", amount = 3},
        {type = "item", name = "blue-grapes", amount = 2}
    },
    icons = {
        {icon = "__sosciencity-graphics__/graphics/icon/wild-edible-plants.png"},
        {
            icon = "__sosciencity-graphics__/graphics/icon/plant-neogenesis.png",
            scale = 0.3,
            shift = {-8, -8}
        }
    },
    icon_size = 64,
    subgroup = "sosciencity-neogenesis-recipes",
    main_product = "",
    order = "00001",
    localised_name = {"recipe-name.flora-sorting", {"item-name.wild-edible-plants"}},
    localised_description = {"recipe-description.flora-sorting"}
}:add_unlock("open-environment-farming")

Tirislib.Recipe.create {
    name = "sort-fungi",
    energy_required = 2,
    ingredients = {
        {type = "item", name = "wild-fungi", amount = 4}
    },
    results = {
        {type = "item", name = "leafage", amount = 1},
        {type = "item", name = "fawoxylas", amount = 2},
        {type = "item", name = "pocelial", amount = 2},
        {type = "item", name = "red-hatty", amount = 2},
        {type = "item", name = "birdsnake", amount = 2}
    },
    icons = {
        {icon = "__sosciencity-graphics__/graphics/icon/wild-fungi.png"},
        {
            icon = "__sosciencity-graphics__/graphics/icon/plant-neogenesis.png",
            scale = 0.3,
            shift = {-8, -8}
        }
    },
    icon_size = 64,
    subgroup = "sosciencity-neogenesis-recipes",
    main_product = "",
    order = "00002",
    localised_name = {"recipe-name.flora-sorting", {"item-name.wild-fungi"}},
    localised_description = {"recipe-description.flora-sorting"}
}:add_unlock("mushroom-farming")

Tirislib.Recipe.create {
    name = "sort-algae",
    energy_required = 2,
    ingredients = {
        {type = "item", name = "wild-algae", amount = 4}
    },
    results = {
        {type = "item", name = "leafage", amount = 1},
        {type = "item", name = "queen-algae", amount = 2},
        {type = "item", name = "pyrifera", amount = 2},
        {type = "item", name = "endower-flower", amount_min = 1, amount_max = 2}
    },
    icons = {
        {icon = "__sosciencity-graphics__/graphics/icon/wild-algae.png"},
        {
            icon = "__sosciencity-graphics__/graphics/icon/plant-neogenesis.png",
            scale = 0.3,
            shift = {-8, -8}
        }
    },
    icon_size = 64,
    subgroup = "sosciencity-neogenesis-recipes",
    main_product = "",
    order = "00003",
    localised_name = {"recipe-name.flora-sorting", {"item-name.wild-algae"}},
    localised_description = {"recipe-description.flora-sorting"}
}:add_unlock("algae-farming")

---------------------------------------------------------------------------------------------------
-- << processing recipes >>

for _, item in pairs(flora_items) do
    if item.wood then
        Tirislib.RecipeGenerator.create {
            product = "lumber",
            product_amount = 3,
            category = "sosciencity-wood-processing",
            ingredients = {
                {name = item.name, amount = 1}
            },
            byproducts = {
                {name = "sawdust", amount = 1}
            },
            allow_productivity = true,
            unlock = item.unlock
        }
    end
end

---------------------------------------------------------------------------------------------------
-- << saplings >>

Tirislib.Prototype.create {
    name = "sosciencity-saplings",
    type = "module-category"
}

local saplings = {
    {
        name = "apple-sapling",
        distinctions = {limitation = {"farming-perennial-apple"}, effect = {}}
    },
    {
        name = "avocado-sapling",
        distinctions = {limitation = {"farming-perennial-avocado"}, effect = {}}
    },
    {
        name = "cherry-sapling",
        distinctions = {limitation = {"farming-perennial-cherry"}, effect = {}}
    },
    {
        name = "lemon-sapling",
        distinctions = {limitation = {"farming-perennial-lemon"}, effect = {}}
    },
    {
        name = "orange-sapling",
        distinctions = {limitation = {"farming-perennial-orange"}, effect = {}}
    },
    {
        name = "ortrot-sapling",
        distinctions = {limitation = {"farming-perennial-ortrot"}, effect = {}}
    },
    {
        name = "zetorn-sapling",
        distinctions = {limitation = {"farming-perennial-zetorn"}, effect = {}}
    }
}

for _, sapling in pairs(saplings) do
    local distinctions = Tirislib.Tables.get_subtbl(sapling, "distinctions")

    -- search the flora item that needs this sapling
    for flora_name, details in pairs(Biology.flora) do
        if details.required_module == sapling.name then
            local flora_item = Tirislib.Item.get_by_name(flora_name)
            distinctions.localised_description = {"sosciencity.sapling", flora_item:get_localised_name()}

            distinctions.icons = {
                {
                    icon = "__sosciencity-graphics__/graphics/icon/sapling-1.png"
                },
                {
                    icon = flora_item.icon,
                    scale = 0.3,
                    shift = {-8, 8}
                }
            }
        end
    end

    sapling.sprite_variations = {name = "sapling", count = 3}
end

Tirislib.Item.batch_create(
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

Tirislib.RecipeGenerator.create {
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

Tirislib.RecipeGenerator.create {
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

Tirislib.RecipeGenerator.create {
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

Tirislib.RecipeGenerator.create {
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

Tirislib.RecipeGenerator.create {
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

Tirislib.RecipeGenerator.create {
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

Tirislib.RecipeGenerator.create {
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

local sounds = require("__base__.prototypes.entity.sounds")

Tirislib.Entity.create {
    name = "necrofall-circle",
    type = "simple-entity",
    flags = {"placeable-neutral", "placeable-off-grid"},
    collision_mask = {"item-layer", "object-layer", "water-tile"},
    count_as_rock_for_filtered_deconstruction = true,
    subgroup = "grass",
    minable = {
        mining_particle = "wooden-particle",
        mining_time = 1,
        results = {
            {name = "necrofall", amount_min = 10, amount_max = 15},
            {name = "leafage", amount_min = 10, amount_max = 15}
        }
    },
    mined_sound = sounds.tree_leaves,
    mining_sound = {
        variations = {
            {
                filename = "__core__/sound/mining-wood-1.ogg",
                volume = 0.4
            },
            {
                filename = "__core__/sound/mining-wood-2.ogg",
                volume = 0.4
            },
            {
                filename = "__core__/sound/mining-wood-3.ogg",
                volume = 0.4
            },
            {
                filename = "__core__/sound/mining-wood-4.ogg",
                volume = 0.4
            },
            {
                filename = "__core__/sound/mining-wood-5.ogg",
                volume = 0.4
            },
            {
                filename = "__core__/sound/mining-wood-6.ogg",
                volume = 0.4
            }
        }
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
}:set_size(1.8, 1.8):copy_icon_from_item("necrofall")
