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
    local entity, found = Tirislib.Entity.get_by_name(building_name)

    if not found then
        goto continue
    end

    if details.power_usage then
        entity.localised_description = entity:get_localised_description()

        Tirislib.Locales.append(
            entity.localised_description,
            "\n\n",
            {"sosciencity-util.power-usage", tostring(details.power_usage * Time.second / 1000)}
        )
    end

    if details.workforce then
        entity.localised_description = entity:get_localised_description()

        local castes =
            Tirislib.Luaq.from(details.workforce.castes):select(
            function(_, caste_id)
                return Castes.values[caste_id].localised_name_short
            end
        ):call(Tirislib.Locales.create_enumeration, nil, {"sosciencity.or"})

        Tirislib.Locales.append(
            entity.localised_description,
            "\n\n",
            {
                "sosciencity-util.workforce",
                tostring(details.workforce.count),
                castes
            }
        )
    end

    if details.inhabitant_count then
        entity:add_custom_tooltip {
            name = {"sosciencity.inhabitants-needed"},
            value = tostring(details.inhabitant_count)
        }
    end

    if details.range then
        entity.localised_description = entity:get_localised_description()

        Tirislib.Locales.append(
            entity.localised_description,
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
                entity.localised_description,
                "\n",
                {"sosciencity.grey", range_descriptions[details.type]}
            )
        end
    end

    ::continue::
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
