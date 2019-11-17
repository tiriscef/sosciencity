---------------------------------------------------------------------------------------------------
-- << items >>
local idea_items = {
    {name = "note"},
    {name = "essay"},
    {name = "strategic-considerations"},
    {name = "data-collection"},
    {name = "complex-scientific-data"},
    {name = "published-paper"},
    {name = "well-funded-scientific-thesis"}
}

for index, details in pairs(idea_items) do
    local item_prototype =
        Item:create {
        name = details.name,
        icon = "__sosciencity__/graphics/icon/" .. details.name .. ".png",
        icon_size = 64,
        subgroup = "sosciencity-ideas",
        order = string.format("%02d", index),
        stack_size = 100
    }

    if details.sprite_variations then
        item_prototype:add_sprite_variations(64, "__sosciencity__/graphics/icon/", details.sprite_variations)

        if details.sprite_variations.include_icon then
            item_prototype:add_icon_to_sprite_variations()
        end
    end

    Tables.set_fields(item_prototype, details.distinctions)
end

---------------------------------------------------------------------------------------------------
-- << recipes >>
Recipe:create {
    type = "recipe",
    name = "brainstorm",
    category = "handcrafting",
    enabled = true,
    energy_required = 10,
    ingredients = {},
    results = {
        {type = "item", name = "note", amount_min = 2, amount_max = 4}
    },
    icon = "__sosciencity__/graphics/icon/note.png",
    icon_size = 64,
    subgroup = "sosciencity-ideas",
    order = "aaa",
    main_product = ""
}

Recipe:create {
    type = "recipe",
    name = "write-essay",
    category = "handcrafting",
    enabled = false,
    energy_required = 90,
    ingredients = {},
    results = {
        {type = "item", name = "essay", amount = 1}
    },
    icon = "__sosciencity__/graphics/icon/essay.png",
    icon_size = 64,
    subgroup = "sosciencity-ideas",
    order = "aab",
    main_product = ""
}:add_unlock("ember-caste")
