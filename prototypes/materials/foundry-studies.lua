---------------------------------------------------------------------------------------------------
-- << items >>

local foundry_items = {
    {name = "scientific-theory", use_placeholder_icon = true},
    {name = "complex-scientific-data"},
    {name = "experimental-data", use_placeholder_icon = true},
    {name = "computing-model", use_placeholder_icon = true}
}

Tirislib.Item.batch_create(
    foundry_items,
    {subgroup = "sosciencity-foundry-studies", stack_size = 50}
)

---------------------------------------------------------------------------------------------------
-- << recipes >>

-- Foundry HQ

Tirislib.RecipeGenerator.create {
    product = "complex-scientific-data",
    product_amount = 4,
    category = "sosciencity-caste-foundry",
    energy_required = 2,
    ingredients = {
        {type = "item", name = "empty-hard-drive", amount = 4}
    },
    unlock = "foundry-caste"
}
