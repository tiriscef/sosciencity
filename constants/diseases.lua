require("constants.enums")

--- A disease is a particular abnormal condition that negatively affects the structure or function of all or part of an organism
Diseases = {}

Diseases.values = {
    [1] = {
        name = "limp-loss",
        cure_items = {
            ["artificial-limp"] = 1
        },
        curing_workload = 2,
        contagiousness = 0,
        lethality = 0,
        category = DiseaseCategory.accident,
        frequency = 100
    },
    [2] = {
        name = "depression",
        curing_workload = 5,
        curing_facility = "psych-ward",
        contagiousness = 0,
        lethality = 0.1,
        category = DiseaseCategory.sanity,
        frequency = 100
    },
    [3] = {
        name = "rare-cold",
        curing_workload = 1,
        contagiousness = 0.1,
        lethality = 0,
        category = DiseaseCategory.health,
        frequency = 100
    }
}

do
    local function get_localised_cure(disease)
        local ret = {"", {"sosciencity-gui.cure-workload", disease.curing_workload}}

        if disease.cure_items then
            local items = {""}
            for item, count in pairs(disease.cure_items) do
                items[#items+1] = {"sosciencity-gui.multiplier", count, string.format("[item=%s] ", item)}
                items[#items+1] = {string.format("item-name.%s", item)}
            end

            ret[#ret+1] = "\n"
            ret[#ret+1] = {"sosciencity-gui.cure-medicine", items}
        end

        if disease.curing_facility then
            ret[#ret+1] = "\n"
            ret[#ret+1] = {"sosciencity-gui.cure-facility", {"sosciencity-gui." .. disease.curing_facility}}
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
    for _, category in pairs(DiseaseCategory) do
        Diseases.by_category[category] = {}
    end

    for id, disease in pairs(Diseases.values) do
        disease.localised_name = {"disease-name." .. disease.name}
        disease.localised_description = get_localised_description(disease)

        Diseases.by_category[disease.category][id] = disease
    end
end
