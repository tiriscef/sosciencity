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
    {name = "tiriscefing-willow-wood", wood = true},
    {name = "cherry-wood", wood = true},
    {name = "olive-wood", wood = true},
    {name = "ortrot-wood", wood = true},
    {name = "avocado-wood", wood = true},
    {name = "zetorn-wood", wood = true}
}

for _, item in pairs(flora_items) do
    local distinctions = Tirislib_Tables.get_inner_table(item, "distinctions")

    if item.wood then
        distinctions.fuel_value = "1MJ"
        distinctions.fuel_category = "chemical"
    end
end

Tirislib_Item.batch_create(flora_items, {subgroup = "sosciencity-flora", stack_size = 200})

---------------------------------------------------------------------------------------------------
-- << gathering recipes >>

---------------------------------------------------------------------------------------------------
-- << farming recipes >>
--- Table with (product, table of recipe specification) pairs
local farmables = {
    ["apple"] = {
        general = {
            energy_required = 30,
            byproducts = {{type = "item", name = "ortrot-wood", amount = 1, probability = 0.2}}
        },
        arboretum = {
            category = "sosciencity-arboretum"
        },
        orangery = {
            category = "sosciencity-orangery"
        }
    },
    ["avocado"] = {
        general = {
            energy_required = 30,
            byproducts = {{type = "item", name = "avocado-wood", amount = 1, probability = 0.2}}
        },
        arboretum = {
            category = "sosciencity-arboretum"
        },
        orangery = {
            category = "sosciencity-orangery"
        }
    },
    ["bell-pepper"] = {
        general = {
            energy_required = 100,
            unlock = "nightshades"
        },
        agriculture = {
            category = "sosciencity-agriculture"
        },
        greenhouse = {
            category = "sosciencity-greenhouse"
        }
    },
    ["brutal-pumpkin"] = {
        general = {
            energy_required = 100
        },
        agriculture = {
            category = "sosciencity-agriculture",
            product_min = 5,
            product_max = 50,
            product_probability = 0.5
        },
        greenhouse = {
            category = "sosciencity-greenhouse",
            product_min = 40,
            product_max = 60
        }
    },
    ["cherry"] = {
        general = {
            energy_required = 20,
            byproducts = {{type = "item", name = "cherry-wood", amount = 1, probability = 0.2}}
        },
        arboretum = {
            category = "sosciencity-arboretum"
        },
        orangery = {
            category = "sosciencity-orangery"
        }
    },
    ["lemon"] = {
        general = {
            energy_required = 20,
            byproducts = {{type = "item", name = "zetorn-wood", amount = 1, probability = 0.1}}
        },
        arboretum = {
            category = "sosciencity-arboretum"
        },
        orangery = {
            category = "sosciencity-orangery"
        }
    },
    ["olive"] = {
        general = {
            energy_required = 20,
            byproducts = {{type = "item", name = "olive-wood", amount = 1, probability = 0.2}}
        },
        arboretum = {
            category = "sosciencity-arboretum"
        },
        orangery = {
            category = "sosciencity-orangery"
        }
    },
    ["orange"] = {
        general = {
            energy_required = 20,
            byproducts = {{type = "item", name = "zetorn-wood", amount = 1, probability = 0.1}}
        },
        arboretum = {
            category = "sosciencity-arboretum"
        },
        orangery = {
            category = "sosciencity-orangery"
        }
    },
    ["phytofall-blossom"] = {
        bloomhouse = {
            category = "sosciencity-bloomhouse",
            energy_required = 20,
            product_min = 10,
            product_max = 30
        }
    },
    ["potato"] = {
        general = {
            energy_required = 100,
            unlock = "nightshades"
        },
        agriculture = {
            category = "sosciencity-agriculture",
            product_min = 5,
            product_max = 50
        },
        greenhouse = {
            category = "sosciencity-greenhouse",
            product_min = 40,
            product_max = 60
        }
    },
    ["tomato"] = {
        general = {
            energy_required = 150,
            unlock = "nightshades"
        },
        agriculture = {
            category = "sosciencity-agriculture",
            product_min = 5,
            product_max = 50
        },
        greenhouse = {
            category = "sosciencity-greenhouse",
            product_min = 40,
            product_max = 60
        }
    },
    ["eggplant"] = {
        general = {
            energy_required = 150,
            unlock = "nightshades"
        },
        agriculture = {
            category = "sosciencity-agriculture",
            product_min = 5,
            product_max = 50
        },
        greenhouse = {
            category = "sosciencity-greenhouse",
            product_min = 40,
            product_max = 60
        }
    },
    ["plemnemm-cotton"] = {
        general = {
            energy_required = 60
        },
        agriculture = {
            category = "sosciencity-agriculture",
            product_min = 10,
            product_max = 20
        },
        greenhouse = {
            category = "sosciencity-greenhouse",
            product_min = 20,
            product_max = 30
        }
    },
    ["tiriscefing-willow-wood"] = {
        arboretum = {
            category = "sosciencity-arboretum",
            energy_required = 20,
            product_probability = 1,
            product_min = 5,
            product_max = 15,
            byproducts = {{type = "item", name = "fawoxylas", amount = 2, probability = 0.5}}
        }
    },
    ["unnamed-fruit"] = {
        general = {
            energy_required = 100
        },
        agriculture = {
            category = "sosciencity-agriculture",
            product_min = 5,
            product_max = 50
        },
        greenhouse = {
            category = "sosciencity-greenhouse",
            product_min = 40,
            product_max = 60
        }
    },
    ["weird-berry"] = {
        general = {
            energy_required = 80
        },
        agriculture = {
            category = "sosciencity-agriculture",
            product_min = 5,
            product_max = 50
        },
        greenhouse = {
            category = "sosciencity-greenhouse",
            product_min = 40,
            product_max = 60
        }
    },
    ["zetorn"] = {
        general = {
            energy_required = 20,
            byproducts = {{type = "item", name = "zetorn-wood", amount = 1, probability = 0.1}}
        },
        arboretum = {
            category = "sosciencity-arboretum"
        },
        orangery = {
            category = "sosciencity-orangery"
        }
    }
}

local farm_specific_defaults = {
    ["sosciencity-agriculture"] = {
        product_probability = 0.5,
        unlock = "open-environment-farming"
    },
    ["sosciencity-arboretum"] = {
        product_probability = 0.5,
        byproducts = {{type = "item", name = "leafage", amount = 1}},
        unlock = "open-environment-farming"
    },
    ["sosciencity-bloomhouse"] = {
        unlock = "indoor-farming"
    },
    ["sosciencity-greenhouse"] = {
        unlock = "controlled-environment-farming"
    },
    ["sosciencity-orangery"] = {
        byproducts = {{type = "item", name = "leafage", amount = 1}},
        unlock = "controlled-environment-farming"
    }
}

-- generation code that should minimize dublications and enforce invariants
local attributes = {"product_probability", "unlock"}
local function merge_specification_details(lh, rh)
    for _, attribute in pairs(attributes) do
        lh[attribute] = lh[attribute] or rh[attribute] or nil
    end

    if rh.byproducts then
        local byproducts = Tirislib_Tables.get_inner_table(lh, "byproducts")
        Tirislib_Tables.merge_arrays(byproducts, rh.byproducts)
    end
end

local function merge_with_general_product_specification(specification, product)
    local general = farmables[product]["general"]

    if general then
        merge_specification_details(specification, general)
    end
end

local function merge_with_category_specification(specification)
    local category_table = farm_specific_defaults[specification.category]
    merge_specification_details(specification, category_table)
end

local function create_farming_recipe(product, specification)
    merge_with_general_product_specification(specification, product)
    merge_with_category_specification(specification)

    specification.product = product

    Tirislib_RecipeGenerator.create(specification)
end

-- create the recipes
for product, details in pairs(farmables) do
    for recipe_entry, specification in pairs(details) do
        if recipe_entry ~= "general" then
            create_farming_recipe(product, specification)
        end
    end
end

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
                {name = "sawdust", amount = 1}
            }
        }

        Tirislib_RecipeGenerator.create {
            product = "sawdust",
            product_amount = 10,
            ingredients = {
                {name = item.name, amount = 1}
            }
        }
    end
end
