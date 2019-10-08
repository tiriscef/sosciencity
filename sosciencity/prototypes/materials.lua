---------------------------------------------------------------------------------------------------
-- << items >>
local material_items = {
    "bspmaterial"
}

for _, material_name in pairs(material_items) do
    Item:create {
        name = material_name,
        icon = "__sosciencity__/graphics/icon/" .. material_name .. ".png",
        icon_size = 64,
        subgroup = "sosciencity-materials",
        order = material_name,
        stack_size = 100
    }
end

---------------------------------------------------------------------------------------------------
-- << recipes >>
