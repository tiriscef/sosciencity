---------------------------------------------------------------------------------------------------
-- << items >>
local furniture_items = {
    {name = "bed"},
    {name = "stool"},
    {name = "table"},
    {name = "furniture", sprite_variations = {name = "furniture", count = 1, include_icon = true}},
    {name = "carpet"},
    {name = "sofa"},
    --    {name = "curtain"}
}

for index, details in pairs(furniture_items) do
    local item_prototype =
        Tirislib_Item.create {
        name = details.name,
        icon = "__sosciencity__/graphics/icon/" .. details.name .. ".png",
        icon_size = 64,
        subgroup = "sosciencity-furniture",
        order = string.format("%03d", index),
        stack_size = 100
    }

    local variations = details.sprite_variations
    if variations then
        item_prototype:add_sprite_variations(64, "__sosciencity__/graphics/icon/" .. variations.name, variations.count)

        if variations.include_icon then
            item_prototype:add_icon_to_sprite_variations()
        end
    end

    Tirislib_Tables.set_fields(item_prototype, details.distinctions)
end

---------------------------------------------------------------------------------------------------
-- << recipes >>
