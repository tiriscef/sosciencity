---------------------------------------------------------------------------------------------------
-- << items >>
local flora_items = {
    {name = "humus", sprite_variations = {name = "humus", count = 2, include_icon = true}},
    {name = "plemnemm-cotton", sprite_variations = {name = "plemnemm-cotton-pile", count = 4}},
    {name = "tiriscefing-willow-wood", distinctions = {fuel_value = "1MJ"}},
    {name = "cherry-wood", distinctions = {fuel_value = "1MJ"}}
}

Tirislib_Item.batch_create(flora_items, {subgroup = "sosciencity-flora", stack_size = 200})

---------------------------------------------------------------------------------------------------
-- << gathering recipes >>

---------------------------------------------------------------------------------------------------
-- << farming recipes >>
--- Table with (product, table of recipe specification) pairs
local farmables = {
    ["potato"] = {
        general = {
            energy_required = 100,
            unlock = "nightshades"
        },
        agriculture = {
            product_min = 5,
            product_max = 50,
            product_probability = 0.5
        },
        greenhouse = {
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
            product_min = 5,
            product_max = 50,
            product_probability = 0.5
        },
        greenhouse = {
            product_min = 40,
            product_max = 60
        }
    },
    ["plemnemm-cotton"] = {
        general = {
            energy_required = 60
        },
        agriculture = {
            product_min = 10,
            product_max = 20,
            product_probability = 0.5
        },
        greenhouse = {
            product_min = 20,
            product_max = 30
        }
    }
}

-- generation code that should minimize repeating
local function get_category_theme(category, specification)
    return {{category, specification.energy_required or 0.5, specification.level}}
end

local function get_general_table(product)
    return farmables[product]["general"] or {}
end

local function create_farming_recipe(product, category, specification)
    Tirislib_Tables.set_fields(specification, get_general_table(product))

    specification.product = product
    specification.category = "sosciencity-" .. category
    specification.themes =
        Tirislib_Tables.merge_arrays(specification.themes or {}, get_category_theme(category, specification))

    Tirislib_RecipeGenerator.create(specification)
end

-- create the recipes
for product, details in pairs(farmables) do
    for category, specification in pairs(details) do
        if category ~= "general" then
            create_farming_recipe(product, category, specification)
        end
    end
end
