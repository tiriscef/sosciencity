require("constants.enums")
require("constants.time")
require("constants.types")

--- A disease is a particular abnormal condition that negatively affects the structure or function of all or part of an organism
Diseases = {}

--- Disease definitions\
--- **name:** prototype name of the disease\
--- **localised_name:** localised name for this disease\
--- **localised_description:** localised description for this disease\
--- **cure_items:** items needed to cure the disease\
--- **curing_workload:** operations needed to cure the disease\
--- **curing_facility:** facility needed to cure the disease\
--- **contagiousness:** probability that the disease infects someone else during a social meeting\
--- **lethality:** probability that the person doesn't survive the disease\
--- **natural_recovery:** average time till recovery - will be translated to the probability per tick during runtime\
--- **category:** disease category of this disease\
--- **frequency:** the probability weight that the disease gets chosen when distributing diseases\
--- **escalation:** the disease that this disease can escalate to when it doesn't get cured\
--- **escalation_probability:** the probability that the disease escalates\
--- **complication:** the disease that this disease can transform to\
--- **complication_probability:** the probability of a complication
Diseases.values = {
    [0] = {
        name = "limp-loss",
        cure_items = {
            ["artificial-limp"] = 1
        },
        curing_workload = 2,
        contagiousness = 0,
        lethality = 0,
        natural_recovery = 0,
        category = DiseaseCategory.accident,
        frequency = 100
    },
    [100] = {
        name = "depression",
        cure_items = {
            ["psychotropics"] = 1
        },
        curing_workload = 5,
        curing_facility = Type.psych_ward,
        contagiousness = 0,
        lethality = 0.1,
        natural_recovery = 0,
        category = DiseaseCategory.sanity,
        frequency = 100
    },
    [101] = {
        name = "reality-loss",
        cure_items = {
            ["psychotropics"] = 1
        },
        curing_workload = 5,
        curing_facility = Type.psych_ward,
        contagiousness = 0,
        lethality = 0,
        natural_recovery = 1,
        category = DiseaseCategory.sanity,
        frequency = 100
    },
    [200] = {
        name = "rare-cold",
        curing_workload = 1,
        contagiousness = 0.1,
        lethality = 0,
        natural_recovery = 2 * Time.nauvis_day,
        category = DiseaseCategory.health,
        frequency = 100,
        escalation = "lung-infection",
        escalation_probability = 0.1
    },
    [201] = {
        name = "lung-infection",
        curing_workload = 5,
        contagiousness = 0,
        lethality = 0.1,
        natural_recovery = Time.nauvis_week,
        category = DiseaseCategory.health,
        frequency = 1
    }
}

-- postprocessing
do
    local function get_localised_cure(disease)
        local ret = {"", {"sosciencity-gui.cure-workload", disease.curing_workload}}

        if disease.cure_items then
            local items = {""}
            for item, count in pairs(disease.cure_items) do
                items[#items + 1] = {"sosciencity-gui.multiplier", count, string.format("[item=%s] ", item)}
                items[#items + 1] = {string.format("item-name.%s", item)}
            end

            ret[#ret + 1] = "\n"
            ret[#ret + 1] = {"sosciencity-gui.cure-medicine", items}
        end

        if disease.curing_facility then
            ret[#ret + 1] = "\n"
            ret[#ret + 1] = {
                "sosciencity-gui.cure-facility",
                Types.definitions[disease.curing_facility].localised_name
            }
        end

        return ret
    end

    local function get_localised_description(disease)
        local ret = {
            "",
            {"sosciencity-gui.bold", disease.localised_name},
            "\n",
            {"disease-description." .. disease.name},
            "\n\n",
            get_localised_cure(disease)
        }
        -- TODO add info about lethality and contagiousness

        return ret
    end

    local function get_disease_id(disease_name)
        for id, disease in pairs(Diseases.values) do
            if disease_name == disease.name then
                return id
            end
        end
        error("Diseases looked for the ID of a nonexistant disease: " .. disease_name)
    end

    Diseases.by_category = {}
    Diseases.frequency_sums = {}
    for _, category in pairs(DiseaseCategory) do
        Diseases.by_category[category] = {}
        Diseases.frequency_sums[category] = 0
    end

    for id, disease in pairs(Diseases.values) do
        disease.localised_name = {"disease-name." .. disease.name}
        disease.localised_description = get_localised_description(disease)

        -- group per category
        Diseases.by_category[disease.category][id] = disease
        Diseases.frequency_sums[disease.category] = Diseases.frequency_sums[disease.category] + disease.frequency

        -- convert recovery from ticks till recovery to progress per tick
        if disease.natural_recovery > 0 then
            disease.natural_recovery = 1 / disease.natural_recovery
        end

        disease.escalation = disease.escalation and get_disease_id(disease.escalation) or nil
        disease.complication = disease.complication and get_disease_id(disease.complication) or nil
    end
end
