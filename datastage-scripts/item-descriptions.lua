local Buildings = require("constants.buildings")
local Castes = require("constants.castes")
local Diseases = require("constants.diseases")
local ItemConstants = require("constants.item-constants")
local Time = require("constants.time")
local Type = require("enums.type")

-- Compostable items

for item_name, humus in pairs(ItemConstants.compost_values) do
    local item, found = Tirislib.Item.get_by_name(item_name)

    if found then
        -- This ensures the description isn't implicit.
        item.localised_description = item:get_localised_description()
        Tirislib.Locales.append(
            item.localised_description,
            "\n\n",
            {"sosciencity-util.compostables", Tirislib.Locales.display_item_stack_datastage("humus", humus)}
        )
        if ItemConstants.mold_producers[item_name] then
            Tirislib.Locales.append(
                item.localised_description,
                ", ",
                Tirislib.Locales.display_item_stack_datastage("mold", 1)
            )
        end
    end
end

-- Custom Building Behaviour

local range_descriptions = {
    [Type.manufactory] = {"range-description.manufactory"},
    [Type.animal_farm] = {"range-description.animal-farm"},
    [Type.hunting_hut] = {"range-description.hunting-hut"},
    [Type.fishery] = {"range-description.fishery"},
    [Type.dumpster] = {"range-description.dumpster"},
    [Type.market] = {"range-description.market"},
    [Type.water_distributer] = {"range-description.water-distributer"},
    [Type.nightclub] = {"range-description.nightclub"},
    [Type.waterwell] = {"range-description.waterwell"},
    [Type.fertilization_station] = {"range-description.plant-care-station"},
    [Type.pruning_station] = {"range-description.plant-care-station"},
    [Type.salt_pond] = {"range-description.fishery"},
    [Type.hospital] = {"range-description.hospital"},
    [Type.improvised_hospital] = {"range-description.hospital"},
    [Type.composter_output] = {"range-description.composter-output"},
    [Type.pharmacy] = {"range-description.pharmacy"},
    [Type.egg_collector] = {"range-description.egg-collector"},
    [Type.caste_education_building] = {"range-description.caste-education-building"},
    [Type.kitchen_for_all] = {"range-description.kitchen-for-all"},
    [Type.empty_house] = {"range-description.housing"}
}

for building_name, details in pairs(Buildings.values) do
    local item, found = Tirislib.Item.get_by_name(building_name)
    local entity = Tirislib.Entity.get_by_name(item.place_result)

    if found then
        if details.power_usage then
            item.localised_description = item:get_localised_description()

            Tirislib.Locales.append(
                item.localised_description,
                "\n\n",
                {"sosciencity-util.power-usage", tostring(details.power_usage * Time.second / 1000)}
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
                    tostring(details.workforce.count),
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
                        {"sosciencity.show-range", tostring(details.range * 2)}
                }
            )

            if range_descriptions[details.type] then
                Tirislib.Locales.append(
                    item.localised_description,
                    "\n",
                    {"sosciencity.grey", range_descriptions[details.type]}
                )
            end

            entity:copy_localisation_from_item()
        end

        if details.inhabitant_count then
            item.custom_tooltip_fields = item.custom_tooltip_fields or {}

            item.custom_tooltip_fields[#item.custom_tooltip_fields+1] = {
                name = {"sosciencity.inhabitants-needed"},
                value = tostring(details.inhabitant_count)
            }
        end
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
        item.custom_tooltip_fields = item.custom_tooltip_fields or {}

        item.custom_tooltip_fields[#item.custom_tooltip_fields + 1] = {
            name = {"sosciencity-util.used-to-cure"},
            value = Tirislib.Locales.create_enumeration(diseases, ", ")
        }
    end
end
