Tirislib_Prototype.create {
    type = "fuel-category",
    name = "garbage"
}

local garbage_items = {
    {
        name = "garbage",
        distinctions = {
            fuel_value = "2MJ",
            fuel_category = "garbage"
        },
        sprite_variations = {name = "garbage", count = 3, include_icon = true}
    },
    {
        name = "food-leftovers",
        distinctions = {
            fuel_value = "1MJ",
            fuel_category = "garbage"
        },
        sprite_variations = {name = "food-leftovers", count = 2, include_icon = true}
    },
    {
        name = "slaughter-waste",
        distinctions = {
            fuel_value = "500kJ",
            fuel_category = "garbage"
        },
        sprite_variations = {name = "slaughter-waste", count = 1, include_icon = true}
    }
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
