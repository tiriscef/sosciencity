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
    },
    ["purple-pox-vaccine"] = {
        diseases = {"purple-pox"}
    },
    ["whooping-cough-vaccine"] = {
        diseases = {"whooping-cough"}
    },
    ["tetanus-vaccine"] = {
        diseases = {"tetanus"}
    },
    -- combined vaccines
    ["flu-vaccine"] = {
        diseases = {"real-riverhorse-flu", "riverhorse-like-flu"}
    },
    ["tetanus-whooping-cough-vaccine"] = {
        diseases = {"tetanus", "whooping-cough"}
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

-- every disease that promises vaccine immunity needs a vaccine
do
    local covered = {}
    for _, vaccine in pairs(Vaccines.values) do
        for _, disease_id in pairs(vaccine.diseases) do
            covered[disease_id] = true
        end
    end

    for disease_id, disease in pairs(Diseases.values) do
        if disease.vaccine_immunity_waning_rate and not covered[disease_id] then
            error("Disease " .. disease.name .. " has a vaccine_immunity_duration, but no vaccine covers it.")
        end
    end
end

return Vaccines
