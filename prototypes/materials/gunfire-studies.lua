---------------------------------------------------------------------------------------------------
-- << items >>

Tirislib.Item.batch_create(
    {{name = "strategic-considerations"}},
    {subgroup = "sosciencity-gunfire-studies", stack_size = 100}
)

---------------------------------------------------------------------------------------------------
-- << recipes >>

-- Gunfire HQ

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "strategic-considerations", amount = 4}
    },
    ingredients = {
        {type = "item", name = "sketch", amount = 4},
        {type = "item", name = "paper", amount = 4},
        {type = "item", name = "military-grade-crayons", amount = 4}
    },
    name = "sketch",
    category = "sosciencity-caste-gunfire",
    energy_required = 2,
    unlock = "gunfire-caste"
}
