---------------------------------------------------------------------------------------------------
-- << items >>

local gleam_items = {
    {name = "metastudy", use_placeholder_icon = true},
    {name = "study-design", use_placeholder_icon = true},
    {name = "survey", use_placeholder_icon = true}
}

Tirislib.Item.batch_create(
    gleam_items,
    {subgroup = "sosciencity-gleam-studies", stack_size = 50}
)

---------------------------------------------------------------------------------------------------
-- << recipes >>

-- Gleam HQ

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "metastudy", amount = 4}
    },
    ingredients = {
        {type = "item", name = "complex-scientific-data", amount = 2}
    },
    name = "complex-scientific-data",
    category = "sosciencity-caste-gleam",
    energy_required = 2,
    unlock = "gleam-caste"
}
