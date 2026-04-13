---------------------------------------------------------------------------------------------------
-- << items >>

local art_material_items = {
    {
        name = "paper",
        distinctions = {subgroup = "sosciencity-art-materials"},
        sprite_variations = {name = "paper-pile", count = 4}
    },
    {
        name = "dye",
        distinctions = {subgroup = "sosciencity-art-materials"},
        sprite_variations = {name = "dye", count = 3, include_icon = true}
    },
    {
        name = "wax",
        use_placeholder_icon = true,
        distinctions = {fuel_value = "1MJ", fuel_category = "chemical"}
    },
    {
        name = "crayons",
        distinctions = {subgroup = "sosciencity-art-materials"},
        sprite_variations = {name = "crayons", count = 4}
    },
    {
        name = "military-grade-crayons",
        distinctions = {subgroup = "sosciencity-art-materials"}
    },
    {
        name = "musical-instruments",
        use_placeholder_icon = true,
        distinctions = {subgroup = "sosciencity-art-materials"}
    }
}

Tirislib.Item.batch_create(
    art_material_items,
    {subgroup = "sosciencity-materials", stack_size = 200}
)

---------------------------------------------------------------------------------------------------
-- << recipes >>

Tirislib.RecipeGenerator.create {
    product = "dye",
    ingredients = {
        {type = "item", name = "wild-flowers", amount = 10}
    },
    unlock = "ember-caste"
}

Tirislib.RecipeGenerator.create {
    product = "dye",
    ingredients = {
        {type = "item", name = "chromafall", amount = 2}
    },
    unlock = "orchid-caste"
}

Tirislib.RecipeGenerator.create {
    product = "dye",
    product_amount = 5,
    ingredients = {
        {type = "fluid", name = "water", amount = 10},
        {type = "item", name = "ferrous-sulfate", amount = 1},
        {type = "item", name = "chromafall", amount = 2}
    },
    category = "chemistry",
    unlock = "clockwork-caste"
}

Tirislib.RecipeGenerator.create {
    product = "crayons",
    ingredients = {
        {type = "item", name = "wax", amount = 1},
        {type = "item", name = "dye", amount = 1}
    }
    --unlock = "ember-caste"
}

Tirislib.RecipeGenerator.create_from_prototype {
    category = "sosciencity-tinkering-workshop",
    results = {{type = "item", name = "musical-instruments", amount = 1}},
    ingredients = {
        {type = "item", name = "lumber", amount = 5},
        {type = "item", name = "copper-plate", amount = 5},
        {type = "item", name = "rope", amount = 2}
    },
    unlock = "clockwork-caste"
}

Tirislib.RecipeGenerator.create {
    product = "military-grade-crayons",
    ingredients = {
        {type = "item", name = "crayons", amount = 1},
        {type = "item", name = "wax", amount = 1},
        {type = "item", name = "sugar", amount = 1}
    },
    unlock = "gunfire-caste"
}

Tirislib.RecipeGenerator.create {
    product = "paper",
    product_amount = 1,
    energy_required = 5,
    ingredients = {
        {type = "item", name = "lumber", amount = 2},
        {type = "item", name = "gingil-hemp", amount = 2}
    },
    allow_productivity = true,
    unlock = "automation-science-pack"
}

Tirislib.RecipeGenerator.create {
    product = "paper",
    product_amount = 10,
    energy_required = 5,
    category = "chemistry",
    ingredients = {
        {type = "item", name = "sawdust", amount = 5},
        {type = "item", name = "gingil-hemp", amount = 5}
    },
    themes = {{"paper_production", 1}},
    allow_productivity = true,
    unlock = "clockwork-caste"
}:add_unlock("gunfire-caste")
