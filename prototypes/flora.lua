require("constants.food")
require("constants.unlocks")
require("constants.biology")

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
    {name = "sugar-cane", sprite_variations = {name = "sugar-cane", count = 3, include_icon = true}}
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

local function create_annual_recipe(details)
    local product = Tirislib_Item.get_by_name(details.product)
    local plant_details = Biology.flora[product.name]

    Tirislib_RecipeGenerator.merge_details(
        details,
        {
            name = "farming-annual-" .. product.name,
            product_amount = 110,
            energy_required = 100,
            expensive_energy_required = 120,
            themes = {{"farming_annual", 1, 2}},
            ingredients = {{type = "item", name = product.name, amount = 10}},
            byproducts = {{type = "item", name = "leafage", amount = 20}},
            localised_name = {"recipe-name.annual", product:get_localised_name()},
            localised_description = {
                "recipe-description.annual",
                product:get_localised_name(),
                Weather.climate_locales[plant_details.preferred_climate],
                Weather.humidity_locales[plant_details.preferred_humidity],
                Tirislib_Locales.display_percentage(plant_details.wrong_climate_coefficient - 1),
                Tirislib_Locales.display_percentage(plant_details.wrong_humidity_coefficient - 1)
            },
            category = "sosciencity-farming-annual",
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

    return Tirislib_RecipeGenerator.create(details)
end

local function create_perennial_recipe(details)
    local product = Tirislib_Item.get_by_name(details.product)
    local plant_details = Biology.flora[product.name]

    Tirislib_RecipeGenerator.merge_details(
        details,
        {
            name = "farming-perennial-" .. product.name,
            product_amount = 5,
            energy_required = 15,
            expensive_energy_required = 17.5,
            themes = {{"farming_perennial", 1, 2}},
            byproducts = {{type = "item", name = "leafage", amount = 1}},
            localised_name = {"recipe-name.perennial", product:get_localised_name()},
            localised_description = {
                "recipe-description.perennial",
                product:get_localised_name(),
                Weather.climate_locales[plant_details.preferred_climate],
                Weather.humidity_locales[plant_details.preferred_humidity],
                Tirislib_Locales.display_percentage(plant_details.wrong_climate_coefficient - 1),
                Tirislib_Locales.display_percentage(plant_details.wrong_humidity_coefficient - 1)
            },
            category = "sosciencity-farming-perennial",
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
            byproducts = {{type = "item", name = "empty-hard-drive", amount = 1}},
            localised_name = {"recipe-name.neogenesis", product:get_localised_name()},
            localised_description = {"recipe-description.neogenesis", product:get_localised_name()},
            category = "sosciencity-phyto-gene-lab",
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
    product = "apple"
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

-- potato
create_annual_recipe {
    product = "potato",
    unlock = Unlocks.get_tech_name("potato")
}

create_neogenesis_recipe {
    product = "potato",
    unlock = "nightshades"
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
create_annual_recipe {
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

--- Table with (product, table of recipe specification) pairs
local farmables = {
    ["phytofall-blossom"] = {
        general = {
            energy_required = 20,
            product_min = 10,
            product_max = 30,
            unlock = "orchid-caste"
        },
        bloomhouse = {
            category = "sosciencity-bloomhouse"
        }
    }
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
