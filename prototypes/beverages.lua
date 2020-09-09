---------------------------------------------------------------------------------------------------
-- << items >>
local beverage_items = {
    {name = "tiriscefing-whisky", distinctions = {durability = 300}}
}

Tirislib_Item.batch_create(beverage_items, {type = "tool", subgroup = "sosciencity-beverages"})

Tirislib_RecipeGenerator.create {
    product = "tiriscefing-whisky",
    product_amount = 10,
    category = "sosciencity-brewery",
    ingredients = {
        {type = "fluid", name = "clean-water", amount = 50},
        {type = "item", name = "tiriscefing-willow-barrel", amount = 10},
    }
}
