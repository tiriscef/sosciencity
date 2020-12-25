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
    allow_productivity = true
}

Tirislib_RecipeGenerator.create {
    product = "fish-food",
    allow_productivity = true
}

Tirislib_RecipeGenerator.create {
    product = "carnivore-food",
    allow_productivity = true
}

Tirislib_RecipeGenerator.create {
    product = "herbivore-food",
    allow_productivity = true
}
