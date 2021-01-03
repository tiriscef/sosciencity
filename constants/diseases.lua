require("constants.enums")
require("constants.time")
require("constants.types")

--- A disease is a particular abnormal condition that negatively affects the structure or function of all or part of an organism
Diseases = {}

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
        frequency = 100
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
    end
end
