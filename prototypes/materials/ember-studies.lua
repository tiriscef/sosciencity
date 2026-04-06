---------------------------------------------------------------------------------------------------
-- << items >>

local ember_items = {
    {name = "artistic-insight"},
    {name = "sketch", use_placeholder_icon = true},
    {name = "mosaic", use_placeholder_icon = true},
    {name = "painting", sprite_variations = {name = "painting-on-belt", count = 7}},
    {name = "statue"},
    {name = "jewellery", use_placeholder_icon = true}
}

Tirislib.Item.batch_create(
    ember_items,
    {subgroup = "sosciencity-ember-studies", stack_size = 100}
)

---------------------------------------------------------------------------------------------------
-- << recipes >>

-- Handcraft

Tirislib.Recipe.create {
    type = "recipe",
    name = "brainstorm",
    category = "sosciencity-handcrafting",
    enabled = true,
    energy_required = 5,
    ingredients = {{type = "item", name = "paper", amount = 2}},
    results = {
        {type = "item", name = "artistic-insight", amount_min = 2, amount_max = 4}
    },
    icon = "__sosciencity-graphics__/graphics/icon/artistic-insight.png",
    icon_size = 64,
    subgroup = "sosciencity-ideas-per-hand",
    order = "00000",
    main_product = ""
}:add_unlock("automation-science-pack")

-- Atelier

Tirislib.RecipeGenerator.create {
    product = "sketch",
    ingredients = {
        {type = "item", name = "paper", amount = 1},
        {type = "item", name = "dye", amount = 1}
    },
    category = "sosciencity-atelier"
    --unlock = "ember-caste"
}

Tirislib.RecipeGenerator.create {
    product = "mosaic",
    ingredients = {
        {type = "item", name = "sketch", amount = 1},
        {type = "item", name = "ceramic", amount = 1},
        {type = "item", name = "glass", amount = 1},
        {type = "item", name = "dye", amount = 1}
    },
    category = "sosciencity-atelier"
    --unlock = "ember-caste"
}

Tirislib.RecipeGenerator.create {
    product = "statue",
    ingredients = {
        {type = "item", name = "sketch", amount = 1},
        {type = "item", name = "marble", amount = 1},
        {type = "item", name = "tools", amount = 1}
    },
    category = "sosciencity-atelier"
    --unlock = "ember-caste"
}

Tirislib.RecipeGenerator.create {
    product = "statue",
    ingredients = {
        {type = "item", name = "sketch", amount = 1},
        {type = "item", name = "marble", amount = 1},
        {type = "item", name = "tools", amount = 1}
    },
    category = "sosciencity-atelier"
    --unlock = "ember-caste"
}

Tirislib.RecipeGenerator.create {
    product = "jewellery",
    ingredients = {
        -- TODO: ingredients :)
    },
    category = "sosciencity-atelier"
    --unlock = "ember-caste"
}

Tirislib.RecipeGenerator.create {
    product = "painting",
    ingredients = {
        {type = "item", name = "lumber", amount = 1},
        {type = "item", name = "cloth", amount = 1},
        {type = "item", name = "dye", amount = 1}
    },
    category = "sosciencity-caste-ember"
}

-- Ember HQ

Tirislib.RecipeGenerator.create {
    product = "artistic-insight",
    product_amount = 2,
    category = "sosciencity-caste-ember",
    energy_required = 4,
    ingredients = {
        {type = "item", name = "paper", amount = 2},
        {type = "item", name = "gingil-hemp", amount = 2}
    },
    unlock = "ember-caste"
}

Tirislib.RecipeGenerator.create {
    product = "artistic-insight",
    product_amount = 8,
    category = "sosciencity-caste-ember",
    energy_required = 8,
    ingredients = {
        {type = "item", name = "sketch", amount = 4},
        {type = "item", name = "paper", amount = 4},
        {type = "item", name = "gingil-hemp", amount = 4}
    },
    unlock = "ember-caste"
}
