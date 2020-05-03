---------------------------------------------------------------------------------------------------
-- << items >>
local flora_items = {
    {name = "humus", sprite_variations = {name = "humus", count = 2, include_icon = true}},
    {name = "plemnemm-cotton", sprite_variations = {name = "plemnemm-cotton-pile", count = 4}},
    {name = "tiriscefing-willow-wood"},
    {name = "cherry-wood"}
}

Tirislib_Item.batch_create(flora_items, {subgroup = "sosciencity-flora", stack_size = 200})

---------------------------------------------------------------------------------------------------
-- << gathering recipes >>

---------------------------------------------------------------------------------------------------
-- << farming recipes >>
--- Table with (product, table of recipe specification) pairs
local farmables = {
    potato = {
        agriculture = {
            product_min = 10,
            product_max = 50,
            product_probability = 0.5,
            unlock = "nightshades"
        }
    }
}

-- generation code that should minimize repeating
local function get_category_theme(category, specification)
    return {{category, specification.energy_required or 0.5, specification.level}}
end

local function get_general_table(product)
    return farmables[product]["general"]
end

local function create_farming_recipe(product, category, specification)
    local general = get_general_table(product)
    Tirislib_Tables.set_fields(specification, general)

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
