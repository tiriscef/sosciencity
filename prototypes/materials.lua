---------------------------------------------------------------------------------------------------
-- << items >>
local material_items = {
    {name = "lumber"},
    {name = "tiriscefing-willow-wood"},
    {name = "pemtenn-cotton", sprite_variations = {name = "pemtenn-cotton-pile", count = 4}},
    {name = "cloth", sprite_variations = {name = "cloth", count = 3, include_icon = true}}
}

for index, details in pairs(material_items) do
    local item_prototype =
        Tirislib_Item.create {
        name = details.name,
        icon = "__sosciencity__/graphics/icon/" .. details.name .. ".png",
        icon_size = 64,
        subgroup = "sosciencity-materials",
        order = string.format("%03d", index),
        stack_size = 200
    }

    if details.sprite_variations then
        item_prototype:add_sprite_variations(64, "__sosciencity__/graphics/icon/", details.sprite_variations)

        if details.sprite_variations.include_icon then
            item_prototype:add_icon_to_sprite_variations()
        end
    end

    Tirislib_Tables.set_fields(item_prototype, details.distinctions)
end

---------------------------------------------------------------------------------------------------
-- << recipes >>
Tirislib_Recipe.create {
    type = "recipe",
    name = "lumber-from-wood",
    category = "crafting",
    enabled = true,
    energy_required = 0.5,
    ingredients = {
        {type = "item", name = "wood", amount = 1}
    },
    results = {
        {type = "item", name = "lumber", amount = 3}
    },
    subgroup = "sosciencity-materials",
    order = "aaa",
}

Tirislib_Recipe.create {
    type = "recipe",
    name = "lumber-from-tiris",
    category = "crafting",
    enabled = true,
    energy_required = 0.5,
    ingredients = {
        {type = "item", name = "tiriscefing-willow-wood", amount = 1}
    },
    results = {
        {type = "item", name = "lumber", amount = 2}
    },
    subgroup = "sosciencity-materials",
    order = "aab",
}

Tirislib_RecipeGenerator.create_agriculture_recipe("pemtenn-cotton", 20)
Tirislib_RecipeGenerator.create_greenhouse_recipe("pemtenn-cotton", 30)
