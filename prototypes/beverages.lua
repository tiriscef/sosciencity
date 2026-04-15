---------------------------------------------------------------------------------------------------
-- << items >>
local beverage_items = {
    {name = "tiriscefing-whisky", distinctions = {durability = 300}}
}

Tirislib.Item.batch_create(beverage_items, {type = "tool", subgroup = "sosciencity-beverages"})

Tirislib.RecipeGenerator.create_from_prototype {
    results = {
        {type = "item", name = "tiriscefing-whisky", amount = 10}
    },
    ingredients = {
        {type = "fluid", name = "clean-water", amount = 50},
        {type = "item", name = "tiriscefing-willow-barrel", amount = 10},
        {type = "item", name = "hardcorn-punk", amount = 20}
    },
    name = "clean-water",
    category = "sosciencity-fermentation-tank",
    energy_required = 20,
    unlock = "fermentation"
}
