---------------------------------------------------------------------------------------------------
-- << items >>
local furniture_items = {
    {name = "bed"},
    {name = "chair"},
    {name = "table"},
    {name = "cupboard", sprite_variations = {name = "cupboard", count = 1, include_icon = true}},
    {name = "carpet"},
    {name = "sofa"},
    {name = "curtain", sprite_variations = {name = "curtain-on-belt", count = 4}},
    {name = "air-conditioner"},
    {name = "stove"},
    {name = "refrigerator"}
}

Tirislib_Item.batch_create(furniture_items, {subgroup = "sosciencity-furniture", stack_size = 100})

---------------------------------------------------------------------------------------------------
-- << recipes >>
Tirislib_RecipeGenerator.create {
    product = "air-conditioner"
}

Tirislib_RecipeGenerator.create {
    product = "bed"
}

Tirislib_RecipeGenerator.create {
    product = "carpet"
}

Tirislib_RecipeGenerator.create {
    product = "chair"
}

Tirislib_RecipeGenerator.create {
    product = "cupboard"
}

Tirislib_RecipeGenerator.create {
    product = "curtain"
}

Tirislib_RecipeGenerator.create {
    product = "refrigerator"
}

Tirislib_RecipeGenerator.create {
    product = "sofa"
}

Tirislib_RecipeGenerator.create {
    product = "stove"
}

Tirislib_RecipeGenerator.create {
    product = "table"
}
