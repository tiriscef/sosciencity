---------------------------------------------------------------------------------------------------
-- << items >>
local furniture_items = {
    "bed", "stool", "table", "wardrobe"
}

for _, furniture_name in pairs(furniture_items) do
    Item:create {
        name = furniture_name,
        icon = "__sosciencity__/graphics/icon/" .. furniture_name .. ".png",
        icon_size = 64,
        subgroup = "sosciencity-furniture",
        order = furniture_name,
        stack_size = 100
    }
end

---------------------------------------------------------------------------------------------------
-- << recipes >>
