if not (mods["sosciencity-debug"] or mods["sosciencity-balancing"]) then
    return
end

-- Enumerate utility sprite names for the debug sprite browser.
-- Stored as a mod-data prototype so control stage can read it via prototypes.mod_data.
local util_sprites = data.raw["utility-sprites"] and data.raw["utility-sprites"]["default"]
if util_sprites then
    local names = {}
    for key, val in pairs(util_sprites) do
        if key ~= "type" and key ~= "name" and key ~= "owner" and type(val) == "table" then
            names[key] = true
        end
    end
    Tirislib.Prototype.create {
        type = "mod-data",
        name = "sosciencity-utility-sprite-names",
        data_type = "sosciencity.utility-sprite-names",
        data = names
    }
end
