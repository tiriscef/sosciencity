---------------------------------------------------------------------------------------------------
-- << items >>
local material_items = {
    {name = "bspmaterial"}
}

for index, material in pairs(material_items) do
    local material_item =
        Item:create {
        name = material.name,
        icon = "__sosciencity__/graphics/icon/" .. material.name .. ".png",
        icon_size = 64,
        subgroup = "sosciencity-materials",
        order = string.format("%03d", index),
        stack_size = 200
    }

    if material.sprite_variations then
        material_item:add_sprite_variations(64, "__sosciencity__/graphics/icon/", material.sprite_variations)
    end
end

---------------------------------------------------------------------------------------------------
-- << recipes >>
