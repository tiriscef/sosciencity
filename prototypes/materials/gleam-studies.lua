---------------------------------------------------------------------------------------------------
-- << items >>

local gleam_items = {
    {name = "published-paper"},
    {name = "survey", use_placeholder_icon = true}
}

Tirislib.Item.batch_create(
    gleam_items,
    {subgroup = "sosciencity-gleam-studies", stack_size = 100}
)

---------------------------------------------------------------------------------------------------
-- << recipes >>

-- Gleam HQ

Tirislib.RecipeGenerator.create {
    product = "published-paper",
    product_amount = 4,
    category = "sosciencity-caste-gleam",
    energy_required = 2,
    ingredients = {
        {type = "item", name = "complex-scientific-data", amount = 2}
    },
    unlock = "gleam-caste"
}
