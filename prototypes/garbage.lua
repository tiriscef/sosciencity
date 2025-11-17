Tirislib.Prototype.create {
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
    },
    {
        name = "expired-food"
    }
}

Tirislib.Item.batch_create(garbage_items, {subgroup = "sosciencity-garbage", stack_size = 200})

Tirislib.Recipe.create {
    name = "burn-garbage",
    emissions_multiplier = 2.5,
    energy_required = 0.8,
    category = "smelting",
    ingredients = {
        {type = "item", name = "garbage", amount = 1}
    },
    subgroup = "sosciencity-garbage"
}:add_unlock("infrastructure-2"):copy_icon_from_item("garbage"):add_icon_layer(
    "__sosciencity-graphics__/graphics/utility/flame.png",
    "topleft",
    0.25,
    {a = 0.7, r = 1, g = 1, b = 1}
)

Tirislib.Recipe.create {
    name = "burn-food-leftovers",
    emissions_multiplier = 1.5,
    energy_required = 1.6,
    category = "smelting",
    ingredients = {
        {type = "item", name = "food-leftovers", amount = 1}
    },
    subgroup = "sosciencity-garbage"
}:add_unlock("infrastructure-2"):copy_icon_from_item("food-leftovers"):add_icon_layer(
    "__sosciencity-graphics__/graphics/utility/flame.png",
    "topleft",
    0.25,
    {a = 0.7, r = 1, g = 1, b = 1}
)

Tirislib.Recipe.create {
    name = "burn-slaughter-waste",
    emissions_multiplier = 1.5,
    energy_required = 1.6,
    category = "smelting",
    ingredients = {
        {type = "item", name = "slaughter-waste", amount = 1}
    },
    subgroup = "sosciencity-garbage"
}:add_unlock("infrastructure-2"):copy_icon_from_item("slaughter-waste"):add_icon_layer(
    "__sosciencity-graphics__/graphics/utility/flame.png",
    "topleft",
    0.25,
    {a = 0.7, r = 1, g = 1, b = 1}
)
