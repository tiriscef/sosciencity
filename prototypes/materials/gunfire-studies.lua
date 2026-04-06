---------------------------------------------------------------------------------------------------
-- << items >>

Tirislib.Item.batch_create(
    {{name = "strategic-considerations"}},
    {subgroup = "sosciencity-gunfire-studies", stack_size = 100}
)

---------------------------------------------------------------------------------------------------
-- << recipes >>

-- Gunfire HQ

Tirislib.RecipeGenerator.create {
    product = "strategic-considerations",
    product_amount = 4,
    category = "sosciencity-caste-gunfire",
    energy_required = 2,
    ingredients = {
        {type = "item", name = "sketch", amount = 4},
        {type = "item", name = "paper", amount = 4},
        {type = "item", name = "military-grade-crayons", amount = 4}
    },
    unlock = "gunfire-caste"
}
