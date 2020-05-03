---------------------------------------------------------------------------------------------------
-- << items >>
local material_items = {
    {name = "lumber"},
    {name = "tiriscefing-willow-barrel"},
    {name = "cloth", sprite_variations = {name = "cloth", count = 3, include_icon = true}},
    {name = "yarn", sprite_variations = {name = "yarn-pile", count = 4}},
    {name = "mineral-wool"},
    {name = "rope"},
    {name = "feather", sprite_variations = {name = "feather-pile", count = 4}}
}

Tirislib_Item.batch_create(material_items, {subgroup = "sosciencity-materials", stack_size = 200})

---------------------------------------------------------------------------------------------------
-- << recipes >>
Tirislib_Recipe.create {
    name = "lumber-from-wood",
    category = "crafting",
    enabled = true,
    energy_required = 0.5,
    ingredients = {
        {type = "item", name = "wood", amount = 1}
    },
    results = {
        {type = "item", name = "lumber", amount = 3}
    },
    subgroup = "sosciencity-materials",
    order = "aaa",
}

Tirislib_Recipe.create {
    name = "lumber-from-tiris",
    category = "crafting",
    enabled = true,
    energy_required = 0.5,
    ingredients = {
        {type = "item", name = "tiriscefing-willow-wood", amount = 1}
    },
    results = {
        {type = "item", name = "lumber", amount = 2}
    },
    subgroup = "sosciencity-materials",
    order = "aab",
}

Tirislib_Recipe.create {
    name = "yarn-from-plemnemm",
    category = "crafting",
    enabled = true,
    energy_required = 2,
    ingredients = {
        {type = "item", name = "plemnemm-cotton", amount = 2}
    },
    results = {
        {type = "item", name = "yarn", amount = 1}
    },
    subgroup = "sosciencity-materials",
    order = "aac",
}

Tirislib_RecipeGenerator.create {
    product = "plemnemm-cotton",
    product_min = 1,
    product_max = 40,
    product_probability = 0.5,
    category = "sosciencity-agriculture"
}--[[
Tirislib_RecipeGenerator.create_agriculture_recipe("plemnemm-cotton", 40)
Tirislib_RecipeGenerator.create_greenhouse_recipe("plemnemm-cotton", 50)

Tirislib_RecipeGenerator.create_arboretum_recipe("tiriscefing-willow-wood", 10)
]]