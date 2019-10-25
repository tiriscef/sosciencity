---------------------------------------------------------------------------------------------------
-- << items >>
local furniture_items = {
    {name = "bed"},
    {name = "stool"},
    {name = "table"},
    {name = "furniture", sprite_variations = {"furniture", "furniture-2"}},
    {name = "carpet"},
--    {name = "sofa"},
--    {name = "curtain"}
}

for index, details in pairs(furniture_items) do
    local furniture_item =
        Item:create {
        name = details.name,
        icon = "__sosciencity__/graphics/icon/" .. details.name .. ".png",
        icon_size = 64,
        subgroup = "sosciencity-furniture",
        order = string.format("%03d", index),
        stack_size = 100
    }

    if details.sprite_variations then
        furniture_item:add_sprite_variations(64, "__sosciencity__/graphics/icon/", details.sprite_variations)
    end
end

---------------------------------------------------------------------------------------------------
-- << recipes >>
