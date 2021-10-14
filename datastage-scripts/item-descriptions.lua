local ItemConstants = require("constants.item-constants")

-- Compostable items

for item_name, humus in pairs(ItemConstants.compost_values) do
    local item, found = Tirislib_Item.get_by_name(item_name)

    if found then
        -- XXX: Make sure the description isn't implicit. Not the most beautiful code..
        item.localised_description = item:get_localised_description()
        Tirislib_Locales.append(item.localised_description, "\n", {"sosciencity-util.compostables", humus})
    end
end
