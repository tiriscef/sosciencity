local Diseases = require("constants.diseases")
local ItemConstants = require("constants.item-constants")

-- Compostable items

for item_name, humus in pairs(ItemConstants.compost_values) do
    local item, found = Tirislib.Item.get_by_name(item_name)

    if found then
        local localised_output = Tirislib.Locales.display_item_stack_datastage("humus", humus)
        local produces_mold = ItemConstants.mold_producers[item_name]
        if produces_mold then
            localised_output =
                Tirislib.Locales.create_enumeration(
                {localised_output, Tirislib.Locales.display_item_stack_datastage("mold", 1)},
                ", "
            )
        end

        item:add_custom_tooltip {
            name = {"sosciencity-util.compostable"},
            value = localised_output
        }
    end
end

-- Medicine items that are used to cure diseases

local medicine_items = {}

for _, disease in pairs(Diseases.values) do
    for item in pairs(disease.cure_items or {}) do
        local tbl = Tirislib.Tables.get_subtbl(medicine_items, item)
        tbl[#tbl + 1] = {"sosciencity-util.in-green", disease.localised_name}
    end
end

for medicine_item, diseases in pairs(medicine_items) do
    local item, found = Tirislib.Item.get_by_name(medicine_item)

    if found then
        item:add_custom_tooltip {
            name = {"sosciencity-util.used-to-cure"},
            value = Tirislib.Locales.create_enumeration(diseases, ", ")
        }
    end
end
