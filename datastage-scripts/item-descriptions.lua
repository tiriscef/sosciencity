local Buildings = require("constants.buildings")
local Castes = require("constants.castes")
local ItemConstants = require("constants.item-constants")
local Time = require("constants.time")

-- Compostable items

for item_name, humus in pairs(ItemConstants.compost_values) do
    local item, found = Tirislib.Item.get_by_name(item_name)

    if found then
        -- XXX: Make sure the description isn't implicit. Not the most beautiful code..
        item.localised_description = item:get_localised_description()
        Tirislib.Locales.append(item.localised_description, "\n\n", {"sosciencity-util.compostables", humus})
    end
end

-- Custom Building Behaviour

for building_name, details in pairs(Buildings.values) do
    local item, found = Tirislib.Item.get_by_name(building_name)
    local entity = Tirislib.Entity.get_by_name(item.place_result)

    if found then
        if details.power_usage then
            item.localised_description = item:get_localised_description()

            Tirislib.Locales.append(
                item.localised_description,
                "\n\n",
                {"sosciencity-util.power-usage", details.power_usage * Time.second / 1000}
            )

            entity:copy_localisation_from_item()
        end

        if details.workforce then
            item.localised_description = item:get_localised_description()

            local castes =
                Tirislib.Luaq.from(details.workforce.castes):select(
                function(_, caste_id)
                    return Castes.values[caste_id].localised_name_short
                end
            ):call(Tirislib.Locales.create_enumeration, nil, {"sosciencity.or"})

            Tirislib.Locales.append(
                item.localised_description,
                "\n\n",
                {
                    "sosciencity-util.workforce",
                    details.workforce.count,
                    castes
                }
            )

            entity:copy_localisation_from_item()
        end

        if details.range then
            item.localised_description = item:get_localised_description()

            Tirislib.Locales.append(
                item.localised_description,
                "\n\n",
                {
                    "sosciencity-util.official-looking-point",
                    {"sosciencity.range"},
                    details.range == "global" and {"sosciencity.global-range"} or
                        {"sosciencity.show-range", details.range * 2}
                }
            )

            entity:copy_localisation_from_item()
        end
    end
end
