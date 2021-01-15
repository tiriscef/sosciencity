require("constants.food")

---------------------------------------------------------------------------------------------------
-- << items >>
local idea_items = {
    {name = "egg"},
    {name = "infertile-egg"}
}

Tirislib_Item.batch_create(idea_items, {subgroup = "sosciencity-inhabitants", stack_size = 10})

Tirislib_Recipe.create {
    name = "infertile-egg",
    category = "handcrafting",
    enabled = true,
    energy_required = 5,
    ingredients = {},
    results = {
        {type = "item", name = "infertile-egg", amount = 1}
    },
    icon = "__sosciencity-graphics__/graphics/icon/infertile-egg.png",
    icon_size = 64,
    subgroup = "sosciencity-inhabitants",
    main_product = "",
    localised_name = {"item-name.infertile-egg"},
    localised_description = {"", {"item-description.infertile-egg"}, {"sosciencity-gui.egg-cost", Food.egg_calories}}
}
