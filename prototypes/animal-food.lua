---------------------------------------------------------------------------------------------------
-- << items >>
local animal_food_items = {
    {name = "bird-food"},
    {name = "fish-food"},
    {name = "carnivore-food"},
    {name = "herbivore-food"}
}

Tirislib_Item.batch_create(animal_food_items, {subgroup = "sosciencity-animal-food", stack_size = 200})

---------------------------------------------------------------------------------------------------
-- << recipes >>

Tirislib_RecipeGenerator.create {
    product = "bird-food",
    ingredients = {{type = "item", name = "sesame", amount = 1}},
    allow_productivity = true,
    unlock = "animal-husbandry"
}

Tirislib_RecipeGenerator.create {
    product = "fish-food",
    ingredients = {{type = "item", name = "leafage", amount = 1}},
    allow_productivity = true,
    unlock = "animal-husbandry"
}

Tirislib_RecipeGenerator.create {
    product = "carnivore-food",
    ingredients = {{type = "item", name = "slaughter-waste", amount = 1}},
    allow_productivity = true,
    unlock = "animal-husbandry"
}

Tirislib_RecipeGenerator.create {
    product = "herbivore-food",
    ingredients = {{type = "item", name = "leafage", amount = 1}},
    allow_productivity = true,
    unlock = "animal-husbandry"
}
