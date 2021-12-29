---------------------------------------------------------------------------------------------------
-- << items >>
local beverage_items = {
    {name = "tiriscefing-whisky", distinctions = {durability = 300}}
}

Tirislib.Item.batch_create(beverage_items, {type = "tool", subgroup = "sosciencity-beverages"})

Tirislib.RecipeGenerator.create {
    product = "tiriscefing-whisky",
    product_amount = 10,
    energy_required = 20,
    category = "sosciencity-fermentation-tank",
    ingredients = {
        {type = "fluid", name = "clean-water", amount = 50},
        {type = "item", name = "tiriscefing-willow-barrel", amount = 10},
        {type = "item", name = "hardcorn-punk", amount = 20}
    },
    unlock = "fermentation"
}
