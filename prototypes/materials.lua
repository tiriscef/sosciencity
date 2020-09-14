---------------------------------------------------------------------------------------------------
-- << items >>
local material_items = {
    {name = "lumber"},
    {name = "tiriscefing-willow-barrel"},
    {name = "cloth", sprite_variations = {name = "cloth", count = 3, include_icon = true}},
    {name = "yarn", sprite_variations = {name = "yarn-pile", count = 4}},
    {name = "mineral-wool"},
    {name = "rope"},
    {name = "feathers", sprite_variations = {name = "feather-pile", count = 4}},
    {name = "trap"},
    {name = "bird-trap"},
    {name = "fishing-net"},
    {name = "offal", sprite_variations = {name = "offal", count = 2, include_icon = true}},
    {name = "ink"},
    {name = "bird-food"},
    {name = "fish-food"},
    {name = "carnivore-food"},
    {name = "herbivore-food"},
    {name = "humus", sprite_variations = {name = "humus", count = 2, include_icon = true}},
    {name = "sewage-sludge", sprite_variations = {name = "sewage-sludge", count = 3, include_icon = true}},
    {name = "ferrous-sulfate"}
}

Tirislib_Item.batch_create(material_items, {subgroup = "sosciencity-materials", stack_size = 200})

---------------------------------------------------------------------------------------------------
-- << recipes >>
Tirislib_RecipeGenerator.create {
    product = "lumber",
    product_amount = 3,
    ingredients = {
        {type = "item", name = "wood", amount = 1}
    },
    allow_productivity = true
}

Tirislib_RecipeGenerator.create {
    product = "lumber",
    product_amount = 2,
    ingredients = {
        {type = "item", name = "tiriscefing-willow-wood", amount = 1}
    },
    allow_productivity = true
}

Tirislib_RecipeGenerator.create {
    product = "yarn",
    product_amount = 10,
    energy_required = 10,
    ingredients = {
        {name = "plemnemm-cotton", amount = 20},
        {name = "lumber", amount = 1}
    },
    allow_productivity = true
}

Tirislib_RecipeGenerator.create {
    product = "cloth",
    energy_required = 10,
    ingredients = {
        {name = "yarn", amount = 5}
    },
    allow_productivity = true
}

Tirislib_RecipeGenerator.create {
    product = "trap",
    themes = {
        {"mechanic", 2, 0}
    },
    energy_required = 1,
    allow_productivity = true
}

Tirislib_RecipeGenerator.create {
    product = "bird-trap",
    themes = {
        {"framework", 1, 0},
        {"grating", 1, 0}
    },
    energy_required = 1,
    allow_productivity = true
}

Tirislib_RecipeGenerator.create {
    product = "fishing-net",
    ingredients = {
        {name = "rope", amount = 5},
        {name = "yarn", amount = 1},
        {name = "lumber", amount = 2}
    },
    energy_required = 1,
    allow_productivity = true
}

Tirislib_RecipeGenerator.create {
    product = "ferrous-sulfate",
    product_amount = 3,
    ingredients = {
        {type = "item", name = "iron-plate", amount = 1},
        {type = "fluid", name = "sulfuric-acid", amount = 10}
    },
    category = "chemistry",
    energy_required = 1,
    allow_productivity = true
}
