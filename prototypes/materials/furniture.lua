---------------------------------------------------------------------------------------------------
-- << items >>

local furniture_items = {
    {
        name = "window"
    },
    {
        name = "bed"
    },
    {
        name = "furniture",
        sprite_variations = {name = "furniture", count = 4}
    },
    {
        name = "kitchen-furniture",
        use_placeholder_icon = true
    },
    {
        name = "bathroom-furniture",
        use_placeholder_icon = true
    },
    {
        name = "carpet"
    },
    {
        name = "sofa"
    },
    {
        name = "curtain",
        sprite_variations = {name = "curtain-on-belt", count = 4}
    },
    {
        name = "air-conditioner"
    },
    {
        name = "stove"
    },
    {
        name = "refrigerator"
    }
}

Tirislib.Item.batch_create(
    furniture_items,
    {subgroup = "sosciencity-furniture", stack_size = 100}
)

---------------------------------------------------------------------------------------------------
-- << recipes >>

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "window", amount = 1}
    },
    ingredients = {
        {theme = "glass", amount = 2},
        {type = "item",   name = "lumber",    amount = 1},
        {type = "item",   name = "screw-set", amount = 1}
    },
    unlock = "infrastucture-1"
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "bed", amount = 1}
    },
    ingredients = {
        {type = "item", name = "lumber",          amount = 5},
        {type = "item", name = "cloth",           amount = 2},
        {type = "item", name = "plemnemm-cotton", amount = 10},
        {type = "item", name = "screw-set",       amount = 1}
    },
    unlock = "architecture-1"
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "carpet", amount = 1}
    },
    ingredients = {
        {type = "item", name = "cloth", amount = 2},
        {type = "item", name = "yarn",  amount = 1}
    },
    unlock = "architecture-2"
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "furniture", amount = 1}
    },
    ingredients = {
        {type = "item", name = "lumber",    amount = 5},
        {type = "item", name = "screw-set", amount = 1}
    },
    unlock = "architecture-1"
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "kitchen-furniture", amount = 1}
    },
    ingredients = {
        {theme = "piping", amount = 2},
        {type = "item",    name = "furniture",    amount = 2},
        {type = "item",    name = "refrigerator", amount = 1},
        {type = "item",    name = "stove",        amount = 1}
    },
    unlock = "architecture-3"
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "bathroom-furniture", amount = 1}
    },
    ingredients = {
        {theme = "piping",   amount = 2},
        {theme = "plating2", amount = 2},
        {type = "item",      name = "ceramic", amount = 3}
    },
    unlock = "architecture-2"
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "curtain", amount = 1}
    },
    ingredients = {
        {type = "item", name = "cloth", amount = 2},
        {type = "item", name = "yarn",  amount = 1}
    },
    unlock = "architecture-2"
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "sofa", amount = 1}
    },
    ingredients = {
        {type = "item", name = "lumber",          amount = 5},
        {type = "item", name = "cloth",           amount = 5},
        {type = "item", name = "yarn",            amount = 2},
        {type = "item", name = "plemnemm-cotton", amount = 20},
        {type = "item", name = "screw-set",       amount = 2}
    },
    unlock = "architecture-4"
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "stove", amount = 1}
    },
    ingredients = {
        {theme = "wiring", amount = 5,         level = 0},
        {theme = "casing", amount = 1},
        {type = "item",    name = "screw-set", amount = 1}
    },
    default_theme_level = 2,
    unlock = "architecture-3"
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "refrigerator", amount = 1}
    },
    ingredients = {
        {theme = "electronics",   amount = 1},
        {theme = "casing",        amount = 1},
        {theme = "cooling_fluid", amount = 20}
    },
    category = "crafting-with-fluid",
    default_theme_level = 2,
    unlock = "architecture-3"
}

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "air-conditioner", amount = 1}
    },
    ingredients = {
        {theme = "electronics", amount = 1},
        {theme = "casing",      amount = 1},
        {type = "item",         name = "screw-set", amount = 1},
        {type = "item",         name = "filter",    amount = 2}
    },
    default_theme_level = 3,
    unlock = "architecture-5"
}

---------------------------------------------------------------------------------------------------
-- << tinkering workshop alternatives >>
-- Same ingredients as the crafting recipes, but more yield - trade Clockwork workforce for materials.

Tirislib.RecipeGenerator.create {
    results = {{type = "item", name = "window", amount = 2}},
    ingredients = {
        {theme = "glass", amount = 2},
        {type = "item",   name = "lumber",    amount = 1},
        {type = "item",   name = "screw-set", amount = 1}
    },
    localised_name_wrapper = "recipe-name.tinkering-workshop",
    category = "sosciencity-tinkering-workshop",
    unlock = "tinkering-workshop"
}:add_category_layer("workshop")

Tirislib.RecipeGenerator.create {
    results = {{type = "item", name = "bed", amount = 2}},
    ingredients = {
        {type = "item", name = "lumber",          amount = 5},
        {type = "item", name = "cloth",           amount = 2},
        {type = "item", name = "plemnemm-cotton", amount = 10},
        {type = "item", name = "screw-set",       amount = 1}
    },
    localised_name_wrapper = "recipe-name.tinkering-workshop",
    category = "sosciencity-tinkering-workshop",
    unlock = "architecture-1"
}:add_category_layer("workshop")

Tirislib.RecipeGenerator.create {
    results = {{type = "item", name = "carpet", amount = 2}},
    ingredients = {
        {type = "item", name = "cloth", amount = 2},
        {type = "item", name = "yarn",  amount = 1}
    },
    localised_name_wrapper = "recipe-name.tinkering-workshop",
    category = "sosciencity-tinkering-workshop",
    unlock = "architecture-2"
}:add_category_layer("workshop")

Tirislib.RecipeGenerator.create {
    results = {{type = "item", name = "furniture", amount = 3}},
    ingredients = {
        {type = "item", name = "lumber",    amount = 5},
        {type = "item", name = "screw-set", amount = 1}
    },
    localised_name_wrapper = "recipe-name.tinkering-workshop",
    category = "sosciencity-tinkering-workshop",
    unlock = "architecture-1"
}:add_category_layer("workshop")

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "kitchen-furniture", amount = 2}
    },
    ingredients = {
        {theme = "piping", amount = 2},
        {type = "item",    name = "furniture",    amount = 4},
        {type = "item",    name = "refrigerator", amount = 1},
        {type = "item",    name = "stove",        amount = 1}
    },
    localised_name_wrapper = "recipe-name.tinkering-workshop",
    category = "sosciencity-tinkering-workshop",
    unlock = "architecture-3"
}:add_category_layer("workshop")

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "bathroom-furniture", amount = 2}
    },
    ingredients = {
        {theme = "piping",   amount = 2},
        {theme = "plating2", amount = 2},
        {type = "item",      name = "ceramic", amount = 3}
    },
    localised_name_wrapper = "recipe-name.tinkering-workshop",
    category = "sosciencity-tinkering-workshop",
    unlock = "architecture-2"
}:add_category_layer("workshop")

Tirislib.RecipeGenerator.create {
    results = {{type = "item", name = "curtain", amount = 2}},
    ingredients = {
        {type = "item", name = "cloth", amount = 2},
        {type = "item", name = "yarn",  amount = 1}
    },
    localised_name_wrapper = "recipe-name.tinkering-workshop",
    category = "sosciencity-tinkering-workshop",
    unlock = "architecture-2"
}:add_category_layer("workshop")

Tirislib.RecipeGenerator.create {
    results = {{type = "item", name = "sofa", amount = 2}},
    ingredients = {
        {type = "item", name = "lumber",          amount = 5},
        {type = "item", name = "cloth",           amount = 2},
        {type = "item", name = "yarn",            amount = 1},
        {type = "item", name = "plemnemm-cotton", amount = 10},
        {type = "item", name = "screw-set",       amount = 2}
    },
    localised_name_wrapper = "recipe-name.tinkering-workshop",
    category = "sosciencity-tinkering-workshop",
    unlock = "architecture-4"
}:add_category_layer("workshop")

Tirislib.RecipeGenerator.create {
    results = {{type = "item", name = "stove", amount = 3}},
    ingredients = {
        {theme = "wiring", amount = 5,         level = 0},
        {theme = "casing", amount = 1},
        {type = "item",    name = "screw-set", amount = 1}
    },
    localised_name_wrapper = "recipe-name.tinkering-workshop",
    category = "sosciencity-tinkering-workshop",
    default_theme_level = 2,
    unlock = "architecture-3"
}:add_category_layer("workshop")

Tirislib.RecipeGenerator.create {
    results = {{type = "item", name = "refrigerator", amount = 3}},
    ingredients = {
        {theme = "electronics",   amount = 1},
        {theme = "casing",        amount = 1},
        {theme = "cooling_fluid", amount = 20}
    },
    localised_name_wrapper = "recipe-name.tinkering-workshop",
    category = "sosciencity-tinkering-workshop",
    default_theme_level = 2,
    unlock = "architecture-3"
}:add_category_layer("workshop")

Tirislib.RecipeGenerator.create {
    results = {{type = "item", name = "air-conditioner", amount = 3}},
    ingredients = {
        {theme = "electronics", amount = 1},
        {theme = "casing",      amount = 1},
        {type = "item",         name = "screw-set", amount = 1},
        {type = "item",         name = "filter",    amount = 2}
    },
    localised_name_wrapper = "recipe-name.tinkering-workshop",
    category = "sosciencity-tinkering-workshop",
    default_theme_level = 3,
    unlock = "architecture-5"
}:add_category_layer("workshop")
