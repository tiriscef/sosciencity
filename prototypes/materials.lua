---------------------------------------------------------------------------------------------------
-- << items >>
local material_items = {
    {name = "timber"},
    {name = "tiriscefing-willow-wood"},
    --{name = "pemtenn-cotton"},
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
