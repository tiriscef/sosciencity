local Diseases = require("constants.diseases")

--- Vaccine definitions, keyed by the name of the vaccine item.
local Vaccines = {}

--- @class VaccineDefinition
--- @field diseases DiseaseID[] the diseases the vaccine makes immune against (names, translated to IDs during postprocessing)

--- **diseases:** the diseases a dose makes immune against. Every one of them needs a vaccine_immunity_duration.<br>
--- @type table<string, VaccineDefinition>
Vaccines.values = {
    ["riverhorse-flu-vaccine"] = {
        diseases = {"real-riverhorse-flu"}
    }
}

-- test vaccines: only present when sosciencity-debug is active
if DEBUG then
    Vaccines.values["test-vaccine"] = {
        diseases = {"test-disease-immunity", "test-disease-immunity-2"}
    }
end

-- postprocessing: exchange the disease names with their IDs
for vaccine_name, vaccine in pairs(Vaccines.values) do
    local disease_ids = {}

    for _, disease_name in pairs(vaccine.diseases) do
        local disease_id = Diseases.get_id(disease_name)
        if not Diseases.values[disease_id].vaccine_immunity_waning_rate then
            error("Vaccine " .. vaccine_name .. " covers " .. disease_name .. ", which has no vaccine_immunity_duration.")
        end
        disease_ids[#disease_ids + 1] = disease_id
    end

    vaccine.diseases = disease_ids
end

return Vaccines
