local Building = require("constants.buildings")
local Castes = require("constants.castes")
local Time = require("constants.time")
local Type = require("enums.type")

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

local function apply_building_description(name, def)
    local entity, found = Tirislib.Entity.get_by_name(name)
    if not found then return end

    if def.power_usage then
        entity.localised_description = entity:get_localised_description()

        Tirislib.Locales.append(
            entity.localised_description,
            "\n\n",
            {"sosciencity-util.power-usage", tostring(def.power_usage * Time.second / 1000)}
        )
    end

    if def.workforce then
        entity.localised_description = entity:get_localised_description()

        local castes =
            Tirislib.Luaq.from(def.workforce.castes):select(
            function(_, caste_id)
                return Castes.values[caste_id].localised_name_short
            end
        ):call(Tirislib.Locales.create_enumeration, nil, {"sosciencity.or"})

        Tirislib.Locales.append(
            entity.localised_description,
            "\n\n",
            {
                "sosciencity-util.workforce",
                tostring(def.workforce.count),
                castes
            }
        )
    end

    if def.inhabitant_count then
        entity:add_custom_tooltip {
            name = {"sosciencity.inhabitants-needed"},
            value = tostring(def.inhabitant_count)
        }
    end

    if def.range then
        entity.localised_description = entity:get_localised_description()

        Tirislib.Locales.append(
            entity.localised_description,
            "\n\n",
            {
                "sosciencity-util.official-looking-point",
                {"sosciencity.range"},
                def.range == "global" and {"sosciencity.global-range"} or
                    {"sosciencity.show-range", tostring(def.range * 2)}
            }
        )

        if range_descriptions[def.type] then
            Tirislib.Locales.append(
                entity.localised_description,
                "\n",
                {"sosciencity.grey", range_descriptions[def.type]}
            )
        end
    end
end

--- Applies sosciencity-specific configuration to an already-registered building entity:
--- description fields (power usage, workforce, range) and EEI registration.
--- For sosciencity's own buildings the name must already be in constants/buildings.lua.
--- For external buildings pass the definition explicitly; it will be stored in Building.values
--- after postprocessing (disease_frequency_fully_staffed per-minute-fully-staffed → disease_frequency per-tick-per-worker).
--- power_usage must be in J/tick; use Unit.kW to express in kilowatts (e.g. 50 * Unit.kW).
--- @param name string Entity name
--- @param def BuildingDefinition? Building definition; looked up in constants/buildings.lua by name if nil
function Sosciencity.configure_building(name, def)
    if def then
        Building.postprocess(def)
        Building.values[name] = def
    else
        def = Building.values[name]
        if not def then
            error("Sosciencity.configure_building: no building definition found for '" .. name .. "'")
        end
    end

    apply_building_description(name, def)

    if def.eei then
        Sosciencity.Config.add_eei(name)
    end
end
