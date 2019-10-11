---------------------------------------------------------------------------------------------------
-- << items >>
local furniture_items = {
    {name = "bed"},
    {name = "stool"},
    {name = "table"},
    {name = "furniture", sprite_variations = {"furniture-2"}},
    {name = "carpet"},
    {name = "sofa"},
    {name = "curtain"}
}

for index, furniture in pairs(furniture_items) do
    local furniture_item =
        Item:create {
        name = furniture.name,
        icon = "__sosciencity__/graphics/icon/" .. furniture.name .. ".png",
        icon_size = 64,
        subgroup = "sosciencity-furniture",
        order = string.format("%03d", index),
        stack_size = 100
    }

    if furniture.sprite_variations then
        furniture_item:add_sprite_variations(64, "__sosciencity__/graphics/icon/", furniture.sprite_variations)
    end
end

---------------------------------------------------------------------------------------------------
-- << recipes >>
