---------------------------------------------------------------------------------------------------
-- << items >>
local material_items = {
    {name = "lumber"},
    {name = "tiriscefing-willow-wood"},
    {name = "tiriscefing-willow-barrel"},
    {name = "plemnemm-cotton", sprite_variations = {name = "plemnemm-cotton-pile", count = 4}},
    {name = "cloth", sprite_variations = {name = "cloth", count = 3, include_icon = true}},
    {name = "yarn", sprite_variations = {name = "yarn-pile", count = 4}},
    {name = "mineral-wool"},
    {name = "rope"}
}

for index, details in pairs(material_items) do
    local item_prototype =
        Tirislib_Item.create {
        name = details.name,
        icon = "__sosciencity-graphics__/graphics/icon/" .. details.name .. ".png",
        icon_size = 64,
        subgroup = "sosciencity-materials",
        order = string.format("%03d", index),
        stack_size = 200
    }

    local variations = details.sprite_variations
    if variations then
        item_prototype:add_sprite_variations(64, "__sosciencity-graphics__/graphics/icon/" .. variations.name, variations.count)

        if variations.include_icon then
            item_prototype:add_icon_to_sprite_variations()
        end
    end

    Tirislib_Tables.set_fields(item_prototype, details.distinctions)
end

---------------------------------------------------------------------------------------------------
-- << recipes >>
Tirislib_Recipe.create {
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

Tirislib_Recipe.create {
    name = "yarn-from-plemnemm",
    category = "crafting",
    enabled = true,
    energy_required = 2,
    ingredients = {
        {type = "item", name = "plemnemm-cotton", amount = 2}
    },
    results = {
        {type = "item", name = "yarn", amount = 1}
    },
    subgroup = "sosciencity-materials",
    order = "aac",
}

Tirislib_RecipeGenerator.create_agriculture_recipe("plemnemm-cotton", 40)
Tirislib_RecipeGenerator.create_greenhouse_recipe("plemnemm-cotton", 50)

Tirislib_RecipeGenerator.create_arboretum_recipe("tiriscefing-willow-wood", 10)
