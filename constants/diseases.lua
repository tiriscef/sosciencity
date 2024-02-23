local DiseaseCategory = require("enums.disease-category")
local Type = require("enums.type")

local Time = require("constants.time")
local Types = require("constants.types")

--- A disease is a particular abnormal condition that negatively affects the structure or function of all or part of an organism
local Diseases = {}

Diseases.not_curable = 1000000000

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
--- **categories:** table with (disease category, frequency)-pairs of this disease\
--- **escalation:** the disease that this disease can escalate to when it doesn't get cured\
--- **escalation_probability:** the probability that the disease escalates\
--- **complication:** the disease that this disease can transform to, even if it gets cured\
--- **complication_probability:** the probability of a complication\
--- **complication_lethality:** the probability that the person doesn't survive the disease when it gets cured\
--- **work_effectivity:** The percentage of the normal points the inhabitants provide\
--- \
--- *XXX lazy implementation: not-curable diseases have a curing_workload of 1 billion.*
Diseases.values = {
    -- 1+: primarily accidents
    [1] = {
        name = "limp-loss",
        cure_items = {
            ["artificial-limp"] = 1
        },
        curing_workload = 4,
        categories = {
            [DiseaseCategory.accident] = 100,
            [DiseaseCategory.birth_defect] = 100
        },
        work_effectivity = 0.5
    },
    [2] = {
        name = "broken-bone",
        cure_items = {
            ["bandage"] = 1,
            ["analgesics"] = 1
        },
        curing_workload = 3,
        natural_recovery = 3 * Time.nauvis_week,
        categories = {[DiseaseCategory.accident] = 150},
        work_effectivity = 0
    },
    [3] = {
        name = "burnt-skin",
        cure_items = {
            ["bandage"] = 2
        },
        curing_workload = 1,
        natural_recovery = 1 * Time.nauvis_week,
        categories = {[DiseaseCategory.accident] = 300},
        work_effectivity = 0
    },
    [4] = {
        name = "deep-cuts",
        cure_items = {
            ["bandage"] = 1
        },
        curing_workload = 1,
        lethality = 0.15,
        natural_recovery = 1 * Time.nauvis_week,
        categories = {[DiseaseCategory.accident] = 300},
        work_effectivity = 0
    },
    [5] = {
        name = "biter-bite",
        cure_items = {
            ["bandage"] = 1,
            ["antibiotics"] = 1
        },
        curing_workload = 1,
        lethality = 0.1,
        natural_recovery = 1 * Time.nauvis_week,
        categories = {[DiseaseCategory.accident] = 50},
        escalation = "necrosis",
        escalation_probability = 0.25,
        work_effectivity = 0
    },
    [6] = {
        name = "joint-dislocation",
        curing_workload = 1,
        natural_recovery = 1 * Time.nauvis_day,
        categories = {[DiseaseCategory.accident] = 400},
        escalation = "limp-loss",
        escalation_probability = 0.1,
        work_effectivity = 0
    },
    [7] = {
        name = "hematoma",
        curing_workload = Diseases.not_curable,
        natural_recovery = 2 * Time.nauvis_day,
        categories = {[DiseaseCategory.accident] = 400},
        work_effectivity = 0.5
    },
    -- 1000+: primarily mental health related
    [1000] = {
        name = "depression",
        cure_items = {
            ["psychotropics"] = 1
        },
        curing_workload = 15,
        curing_facility = Type.psych_ward,
        lethality = 0.1,
        categories = {[DiseaseCategory.sanity] = 50},
        work_effectivity = 0.5
    },
    [1001] = {
        name = "schizophrenia",
        cure_items = {
            ["psychotropics"] = 1
        },
        curing_workload = 15,
        curing_facility = Type.psych_ward,
        lethality = 0.2,
        categories = {[DiseaseCategory.sanity] = 50},
        work_effectivity = 0.3
    },
    [1002] = {
        name = "reality-loss",
        cure_items = {
            ["psychotropics"] = 1
        },
        curing_workload = 10,
        curing_facility = Type.psych_ward,
        natural_recovery = 1 * Time.nauvis_week,
        categories = {[DiseaseCategory.sanity] = 100},
        work_effectivity = 0.3
    },
    [1003] = {
        name = "factorio-addiction",
        curing_workload = 5,
        curing_facility = Type.psych_ward,
        natural_recovery = 2 * Time.nauvis_week,
        categories = {[DiseaseCategory.sanity] = 100},
        work_effectivity = 0.5
    },
    [1004] = {
        name = "burnout",
        curing_workload = 5,
        curing_facility = Type.psych_ward,
        natural_recovery = 3 * Time.nauvis_week,
        categories = {[DiseaseCategory.sanity] = 100},
        work_effectivity = 0.25
    },
    -- 2000+: primarily health related
    [2000] = {
        name = "rare-cold",
        curing_workload = 1,
        contagiousness = 0.1,
        natural_recovery = 2 * Time.nauvis_day,
        categories = {[DiseaseCategory.health] = 100},
        escalation = "lung-infection",
        escalation_probability = 0.1,
        work_effectivity = 0.25
    },
    [2001] = {
        name = "yeast-infection",
        cure_items = {
            ["antimycotics"] = 1
        },
        curing_workload = 2,
        natural_recovery = 3 * Time.nauvis_day,
        categories = {[DiseaseCategory.health] = 100},
        escalation = "lung-infection",
        escalation_probability = 0.1,
        work_effectivity = 0.5
    },
    [2002] = {
        name = "riverhorse-like-flu",
        cure_items = {
            ["antibiotics"] = 1
        },
        curing_workload = 1,
        lethality = 0.01,
        natural_recovery = 3 * Time.nauvis_day,
        categories = {[DiseaseCategory.health] = 100},
        escalation = "lung-infection",
        escalation_probability = 0.1,
        work_effectivity = 0.5
    },
    [2003] = {
        name = "headaches",
        cure_items = {
            ["analgesics"] = 1
        },
        curing_workload = 1,
        natural_recovery = 1 * Time.nauvis_day,
        categories = {[DiseaseCategory.health] = 100},
        work_effectivity = 0.5
    },
    [2004] = {
        name = "diarrhea",
        cure_items = {
            ["isotonic-saline-solution"] = 1,
            ["activated-carbon"] = 1
        },
        curing_workload = 1,
        natural_recovery = 2 * Time.nauvis_day,
        categories = {[DiseaseCategory.health] = 100},
        work_effectivity = 0
    },
    [2005] = {
        name = "exhaustion",
        curing_workload = Diseases.not_curable,
        natural_recovery = 2 * Time.nauvis_day,
        categories = {
            [DiseaseCategory.health] = 500,
            [DiseaseCategory.sanity] = 200,
            [DiseaseCategory.accident] = 200
        },
        work_effectivity = 0
    },
    [2006] = {
        name = "kidney-stone",
        curing_workload = 3,
        natural_recovery = 1 * Time.nauvis_week,
        categories = {
            [DiseaseCategory.health] = 300
        },
        work_effectivity = 0.2
    },
    -- 3000+: primarily escalation diseases
    [3000] = {
        name = "lung-infection",
        cure_items = {
            ["antibiotics"] = 1,
            ["analgesics"] = 1
        },
        curing_workload = 5,
        lethality = 0.1,
        natural_recovery = 2 * Time.nauvis_week,
        categories = {[DiseaseCategory.health] = 10},
        work_effectivity = 0
    },
    [3001] = {
        name = "necrosis",
        cure_items = {
            ["antibiotics"] = 2,
            ["potent-analgesics"] = 1,
            ["bandage"] = 1
        },
        curing_workload = 10,
        lethality = 0.35,
        natural_recovery = 2 * Time.nauvis_week,
        categories = {[DiseaseCategory.health] = 10},
        work_effectivity = 0
    },
    -- 4000+: primarily birth defects
    [4000] = {
        name = "weak-heart",
        cure_items = {
            ["artificial-heart"] = 1,
            ["anesthetics"] = 1,
            ["potent-analgesics"] = 1,
            ["bandage"] = 2
        },
        curing_workload = 10,
        curing_facility = Type.intensive_care_unit,
        lethality = 0.7,
        complication = "lung-infection",
        complication_probability = 0.1,
        complication_lethality = 0.1,
        natural_recovery = 2 * Time.nauvis_month,
        categories = {
            [DiseaseCategory.health] = 5,
            [DiseaseCategory.birth_defect] = 100
        },
        work_effectivity = 0.4
    },
    [4001] = {
        name = "gender-dysphoria",
        cure_items = {
            ["edited-huwan-genome"] = 1,
            ["blank-dna-virus"] = 1,
            ["nucleobases"] = 1,
            ["thermostable-dna-polymerase"] = 1
        },
        curing_workload = 10,
        --curing_facility = Type.gene_clinic,
        categories = {[DiseaseCategory.birth_defect] = 50},
        work_effectivity = 0.7
    },
    [4002] = {
        name = "lack-of-purple-blood-cells",
        cure_items = {
            ["blood-bag"] = 1
        },
        curing_workload = 1,
        categories = {
            [DiseaseCategory.birth_defect] = 600
        },
        work_effectivity = 0.3
    },
    [4003] = {
        name = "huntingtons",
        cure_items = {
            ["edited-huwan-genome"] = 1,
            ["blank-dna-virus"] = 1,
            ["nucleobases"] = 1,
            ["thermostable-dna-polymerase"] = 1
        },
        curing_workload = 4,
        categories = {[DiseaseCategory.birth_defect] = 100},
        natural_recovery = 3 * Time.nauvis_month,
        lethality = 1,
        work_effectivity = 0.6
    },
    -- 5000+: primarily zoonoses
    [5001] = {
        name = "real-riverhorse-flu",
        --cure_items = {
        --["antibiotics"] = 1
        --},
        curing_workload = 2,
        lethality = 0.03,
        contagiousness = 0.15,
        natural_recovery = 6 * Time.nauvis_day,
        categories = {[DiseaseCategory.zoonosis] = 100},
        escalation = "lung-infection",
        escalation_probability = 0.2,
        work_effectivity = 0
    }
}

--- table with (disease category, table of diseases)-pairs
Diseases.by_category = {}
--- table with (disease category, sum of frequencies)-pairs for efficient random choosing
Diseases.frequency_sums = {}

for _, category in pairs(DiseaseCategory) do
    Diseases.by_category[category] = {}
    Diseases.frequency_sums[category] = 0
end

-- postprocessing
do
    local function get_percentage(n)
        return math.ceil(n * 100)
    end

    local function get_localised_cure(disease)
        if disease.curing_workload == Diseases.not_curable then
            return {"sosciencity.not-curable"}
        end

        local points = {{"sosciencity.cure-workload", disease.curing_workload}}

        if disease.cure_items then
            points[#points + 1] = {
                "sosciencity.cure-medicine",
                Tirislib.Locales.create_enumeration(
                    Tirislib.Luaq.from(disease.cure_items):select(
                        function(item, count)
                            return Tirislib.Locales.display_item_stack_datastage(item, count)
                        end
                    ):to_array(),
                    ", "
                )
            }
        end

        if disease.curing_facility then
            points[#points + 1] = {
                "sosciencity.cure-facility",
                Types.definitions[disease.curing_facility].localised_name
            }
        end

        if disease.complication_disease then
            points[#points + 1] = {
                "sosciencity.complication",
                {"disease-name." .. disease.complication_disease},
                get_percentage(disease.complication_probability)
            }
        end

        return Tirislib.Locales.create_enumeration(points, "\n")
    end

    local function get_localised_properties(disease)
        local points = {
            disease.natural_recovery and
                {
                    "sosciencity.natural-recovery",
                    Tirislib.Locales.display_ingame_time(disease.natural_recovery),
                    Tirislib.Locales.display_time(math.ceil(disease.natural_recovery / 3600) * 3600)
                } or
                {"sosciencity.no-natural-recovery"}
        }

        if disease.lethality and disease.complication_lethality then
            points[#points + 1] =
                disease.lethality == disease.complication_lethality and
                {"sosciencity.lethality", get_percentage(disease.lethality)} or
                {
                    "sosciencity.lethality-cure",
                    get_percentage(disease.lethality),
                    get_percentage(disease.complication_lethality)
                }
        elseif disease.lethality or disease.complication_lethality then
            points[#points + 1] = {
                "sosciencity.lethality",
                get_percentage(disease.lethality or disease.complication_lethality)
            }
        end

        if disease.contagiousness then
            points[#points + 1] = {"sosciencity.contagious", get_percentage(disease.contagiousness)}
        end

        if disease.escalation then
            points[#points + 1] = {
                "sosciencity.escalation",
                {"disease-name." .. disease.escalation},
                get_percentage(disease.escalation_probability)
            }
        end

        return Tirislib.Locales.create_enumeration(points, "\n")
    end

    local function get_localised_description(disease)
        return Tirislib.Locales.create_enumeration(
            {
                {"sosciencity.bold", disease.localised_name},
                {"sosciencity.grey", {"disease-description." .. disease.name}},
                get_localised_properties(disease),
                {"sosciencity.work-effectivity", disease.work_effectivity * 100},
                get_localised_cure(disease)
            },
            "\n",
            "\n\n"
        )
    end

    local function get_disease_id(disease_name)
        for id, disease in pairs(Diseases.values) do
            if disease_name == disease.name then
                return id
            end
        end
        error("Diseases looked for the ID of a nonexistant disease: " .. disease_name)
    end

    for id, disease in pairs(Diseases.values) do
        disease.localised_name = {"disease-name." .. disease.name}
        disease.localised_description = get_localised_description(disease)

        -- convert recovery from ticks till recovery to progress per tick
        disease.natural_recovery = disease.natural_recovery and 1 / disease.natural_recovery or nil

        -- exchange escalation and complication diseases with their ID for efficient lookups
        disease.escalation = disease.escalation and get_disease_id(disease.escalation) or nil
        disease.complication = disease.complication and get_disease_id(disease.complication) or nil

        -- add to lookup-tables
        for category, frequency in pairs(disease.categories or {}) do
            Diseases.by_category[category][id] = disease
            Diseases.frequency_sums[category] = Diseases.frequency_sums[category] + frequency
            disease["frequency" .. category] = frequency
        end
    end
end

return Diseases
