---------------------------------------------------------------------------------------------------
-- << items >>
local material_items = {
    {name = "lumber"},
    {name = "sawdust", sprite_variations = {name = "sawdust", count = 2, include_icon = true}},
    {name = "screw-set", sprite_variations = {name = "screw-set", count = 2, include_icon = true}},
    {name = "tiriscefing-willow-barrel"},
    {name = "cloth", sprite_variations = {name = "cloth", count = 3, include_icon = true}},
    {name = "yarn", sprite_variations = {name = "yarn-pile", count = 4}},
    {name = "mineral-wool"},
    {name = "rope"},
    {name = "feathers", sprite_variations = {name = "feather-pile", count = 4}},
    {name = "ink"},
    {name = "writing-paper", sprite_variations = {name = "writing-paper-pile", count = 4}},
    {name = "trap", distinctions = {subgroup = "sosciencity-gathering"}},
    {name = "trap-cage", distinctions = {subgroup = "sosciencity-gathering"}},
    {name = "trap-bucket", distinctions = {subgroup = "sosciencity-gathering"}},
    {name = "fishing-net", distinctions = {subgroup = "sosciencity-gathering"}},
    {name = "humus", sprite_variations = {name = "humus", count = 2, include_icon = true}},
    {name = "sewage-sludge", sprite_variations = {name = "sewage-sludge", count = 3, include_icon = true}},
    {name = "ferrous-sulfate"},
    {name = "amylum"}
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
    byproducts = {
        {name = "sawdust", amount = 1}
    },
    allow_productivity = true
}

Tirislib_RecipeGenerator.create_per_theme_level {
    product = "screw-set",
    followed_theme = "screw_material",
    energy_required = 1,
    dynamic_fields = {
        product_amount = function(n) return math.ceil(n / 10) * 2 end
    },
    allow_productivity = true
}

Tirislib_RecipeGenerator.create {
    product = "tiriscefing-willow-barrel",
    energy_required = 1,
    ingredients = {
        {type = "item", name = "tiriscefing-willow-wood", amount = 2}
    }
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
    energy_required = 5,
    ingredients = {
        {name = "yarn", amount = 5}
    },
    allow_productivity = true
}

Tirislib_RecipeGenerator.create {
    product = "writing-paper",
    product_amount = 2,
    energy_required = 5,
    ingredients = {
        {name = "tiriscefing-willow-wood", amount = 5}
    },
    allow_productivity = true,
    unlock = "clockwork-caste"
}

Tirislib_RecipeGenerator.create {
    product = "writing-paper",
    product_amount = 10,
    energy_required = 5,
    category = "chemistry",
    ingredients = {
        {name = "tiriscefing-willow-wood", amount = 5}
    },
    themes = {{"paper_production", 1}},
    allow_productivity = true,
    unlock = "ember-caste"
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
    product = "trap-cage",
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

Tirislib_RecipeGenerator.create {
    product = "amylum",
    product_min = 2,
    product_max = 6,
    ingredients = {
        {type = "item", name = "potato", amount = 5},
        {type = "fluid", name = "clean-water", amount = 80}
    },
    category = "crafting-with-fluid",
    energy_required = 4,
    allow_productivity = true,
    unlock = "hospital"
}
