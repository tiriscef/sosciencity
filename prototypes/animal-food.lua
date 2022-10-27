---------------------------------------------------------------------------------------------------
-- << items >>
local animal_food_items = {
    {name = "bird-food"},
    {name = "fish-food"},
    {name = "carnivore-food"},
    {name = "herbivore-food"}
}

Tirislib.Item.batch_create(animal_food_items, {subgroup = "sosciencity-animal-food", stack_size = 200})

---------------------------------------------------------------------------------------------------
-- << recipes >>

Tirislib.RecipeGenerator.create {
    product = "bird-food",
    product_amount = 2,
    ingredients = {{type = "item", name = "hardcorn-punk", amount = 4}},
    allow_productivity = true,
    unlock = "animal-husbandry"
}

Tirislib.RecipeGenerator.create {
    product = "bird-food",
    product_amount = 2,
    ingredients = {
        {type = "item", name = "hardcorn-punk", amount = 2},
        {type = "item", name = "slaughter-waste", amount = 2}
    },
    allow_productivity = true,
    unlock = "animal-husbandry"
}

Tirislib.RecipeGenerator.create {
    product = "fish-food",
    product_amount = 2,
    ingredients = {{type = "item", name = "dried-solfaen", amount = 6}},
    allow_productivity = true,
    unlock = "animal-husbandry"
}

Tirislib.RecipeGenerator.create {
    product = "fish-food",
    product_amount = 4,
    ingredients = {
        {type = "item", name = "queen-algae", amount = 3},
        {type = "item", name = "pyrifera", amount = 3}
    },
    allow_productivity = true,
    unlock = "animal-husbandry"
}

Tirislib.RecipeGenerator.create {
    product = "carnivore-food",
    product_amount = 2,
    ingredients = {{type = "item", name = "slaughter-waste", amount = 3}},
    allow_productivity = true,
    unlock = "animal-husbandry"
}

Tirislib.RecipeGenerator.create {
    product = "carnivore-food",
    product_amount = 2,
    ingredients = {{type = "item", name = "offal", amount = 2}},
    allow_productivity = true,
    unlock = "animal-husbandry"
}

Tirislib.RecipeGenerator.create {
    product = "herbivore-food",
    product_amount = 2,
    ingredients = {
        {type = "item", name = "leafage", amount = 2},
        {type = "item", name = "razha-bean", amount = 2}
    },
    allow_productivity = true,
    unlock = "animal-husbandry"
}

Tirislib.RecipeGenerator.create {
    product = "herbivore-food",
    product_amount = 2,
    ingredients = {
        {type = "item", name = "hardcorn-punk", amount = 2},
        {type = "item", name = "razha-bean", amount = 2}
    },
    allow_productivity = true,
    unlock = "animal-husbandry"
}
