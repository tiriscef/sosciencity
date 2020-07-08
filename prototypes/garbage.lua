Tirislib_Item.create {
    name = "garbage",
    icon = "__sosciencity-graphics__/graphics/icon/garbage-1.png",
    icon_size = 64,
    subgroup = "sosciencity-garbage",
    stack_size = 200
}:add_sprite_variations(64, "__sosciencity-graphics__/graphics/icon/garbage", 4)

Tirislib_Item.create {
    name = "food-leftovers",
    icon = "__sosciencity-graphics__/graphics/icon/food-leftovers-1.png",
    icon_size = 64,
    subgroup = "sosciencity-garbage",
    stack_size = 200
}:add_sprite_variations(64, "__sosciencity-graphics__/graphics/icon/food-leftovers", 3)

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
