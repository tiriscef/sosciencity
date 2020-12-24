require("constants.diseases")

---------------------------------------------------------------------------------------------------
-- << items >>
local medicine_items = {
    {name = "artificial-limp"}
}

local function find_curable_diseases(item_name)
    local ret = {""}
    local first = true

    for _, disease in pairs(Diseases.values) do
        if disease.cure_items[item_name] then
            if not first then
                ret[#ret + 1] = "[color=#FFFFFF] - [/color]"
            end

            ret[#ret + 1] = disease.localised_name
            first = false
        end
    end

    return ret
end

for _, medicine in pairs(medicine_items) do
    medicine.distinctions = medicine.destinctions or {}
    local distinctions = medicine.distinctions

    distinctions.localised_description = {
        "item-description.medicine",
        {"item-description." .. medicine.name},
        find_curable_diseases(medicine.name)
    }
end

Tirislib_Item.batch_create(medicine_items, {subgroup = "sosciencity-medicine", stack_size = 50})

---------------------------------------------------------------------------------------------------
-- << recipes >>
Tirislib_RecipeGenerator.create {
    product = "artificial-limp",
    themes = {
        {"structure", 2, 1},
        {"wiring", 1, 1},
        {"electronics", 1, 1}
    },
    energy_required = 3,
    allow_productivity = true,
    unlock = "plasma-caste"
}
