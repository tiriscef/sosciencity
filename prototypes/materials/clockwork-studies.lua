---------------------------------------------------------------------------------------------------
-- << items >>

local clockwork_items = {
    {name = "invention"},
    {name = "technical-drawing", use_placeholder_icon = true},
    {name = "contraption", use_placeholder_icon = true},
    {name = "prototype-component", use_placeholder_icon = true}
}

Tirislib.Item.batch_create(
    clockwork_items,
    {subgroup = "sosciencity-clockwork-studies", stack_size = 100}
)

---------------------------------------------------------------------------------------------------
-- << recipes >>

-- Clockwork HQ

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "invention", amount = 4}
    },
    ingredients = {
        {type = "item", name = "paper", amount = 4},
        {type = "item", name = "rope", amount = 5},
        {type = "item", name = "lumber", amount = 20},
        {type = "item", name = "screw-set", amount = 20}
    },
    name = "paper",
    category = "sosciencity-caste-clockwork",
    energy_required = 4,
    unlock = "clockwork-caste"
}
