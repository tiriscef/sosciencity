---------------------------------------------------------------------------------------------------
-- << items >>
local idea_items = {
    {name = "egg"},
    {name = "infertile-egg"}
}

Tirislib_Item.batch_create(idea_items, {subgroup = "sosciencity-inhabitants", stack_size = 10})

Tirislib_RecipeGenerator.create {
    product = "infertile-egg",
    product_min = 1,
    product_max = 3
}
