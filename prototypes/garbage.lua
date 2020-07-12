local garbage_items = {
    {name = "garbage", sprite_variations = {name = "garbage", count = 3, include_icon = true}},
    {name = "food-leftovers", sprite_variations = {name = "food-leftovers", count = 2, include_icon = true}},
    {name = "slaughter-waste"}
}

Tirislib_Item.batch_create(garbage_items, {subgroup = "sosciencity-garbage", stack_size = 200})

Tirislib_Recipe.create {
    name = "garbage-to-landfill",
    energy_required = 1,
    category = "crafting",
    ingredients = {
        {"garbage", 20}
    },
    results = {
        {"landfill", 1}
    }
}:add_unlock("landfill")
