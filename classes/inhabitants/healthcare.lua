local DiseaseCategory = require("enums.disease-category")
local DiseasedCause = require("enums.diseased-cause")
local EK = require("enums.entry-key")
local Type = require("enums.type")

local Biology = require("constants.biology")
local Buildings = require("constants.buildings")
local Castes = require("constants.castes")
local Diseases = require("constants.diseases")

local castes = Castes.values
local disease_values = Diseases.values
local get_building_details = Buildings.get
local try_get = Register.try_get
local Tables = Tirislib.Tables
local Arrays = Tirislib.Arrays
local Utils = Tirislib.Utils
local Luaq_from = Tirislib.Luaq.from
local coin_flips = Utils.coin_flips
local occurence_probability = Utils.occurrence_probability
local update_progress = Utils.update_progress
local table_copy = Tables.copy
local table_multiply = Tables.multiply
local HEALTHY = DiseaseGroup.HEALTHY
local make_sick = DiseaseGroup.make_sick
local make_sick_randomly = DiseaseGroup.make_sick_randomly
local cure = DiseaseGroup.cure
local not_healthy = DiseaseGroup.not_healthy
local take_specific_inhabitants = InhabitantGroup.take_specific
local floor = math.floor
local min = math.min

local unemploy_inhabitants -- set during load

function Inhabitants.load_healthcare()
    unemploy_inhabitants = Inhabitants.unemploy_inhabitants
end

---------------------------------------------------------------------------------------------------
-- << disease side effects >>

-- XXX: this part has magic numbers - but at the moment I don't know how to avoid them without overcomplicating stuff
local special_sideeffect_fns = {
    [4001] = function(entry, count, _)
        local gender_group = entry[EK.genders]

        for _ = 1, count do
            local gender_before = Utils.weighted_random(gender_group)
            local gender_after = Utils.random_different(1, 4, gender_before)

            gender_group[gender_before] = gender_group[gender_before] - 1
            gender_group[gender_after] = gender_group[gender_after] + 1
        end
    end
}

--- Determines the side effects of a cured disease.
--- @param entry Entry
--- @param disease_id DiseaseID
--- @param count integer
--- @param cured boolean
--- @param new_diseases table Holds the escalation or complication diseases that are to be added.
local function cure_side_effects(entry, disease_id, count, cured, new_diseases)
    local disease = disease_values[disease_id]

    local lethal_probability = cured and disease.complication_lethality or disease.lethality
    local dead_count = 0
    if lethal_probability then
        dead_count = coin_flips(lethal_probability, count)
        if dead_count > 0 then
            take_specific_inhabitants(entry, dead_count, {[HEALTHY] = dead_count})
            Communication.report_disease_death(dead_count, disease_id)
        end
    end

    -- the following effects cannot occur when the persons died
    count = count - dead_count

    local escalation_disease = disease.escalation
    local escalation_count = 0
    if not cured and escalation_disease then
        escalation_count = coin_flips(disease.escalation_probability, count, 5)
        if escalation_count > 0 then
            new_diseases[escalation_disease] = (new_diseases[escalation_disease] or 0) + escalation_count
            Communication.report_diseased(escalation_disease, escalation_count, DiseasedCause.escalation)
        end
    end

    local complication_disease = disease.complication
    if complication_disease then
        local complication_count = coin_flips(disease.complication_probability, count - escalation_count, 5)
        if complication_count > 0 then
            new_diseases[complication_disease] = (new_diseases[complication_disease] or 0) + complication_count
            Communication.report_diseased(complication_disease, complication_count, DiseasedCause.complication)
        end
    end

    local fn = special_sideeffect_fns[disease_id]
    if fn then
        fn(entry, count, cured)
    end
end

---------------------------------------------------------------------------------------------------
-- << disease progress >>

--- Returns the probability of getting birth defects based on the current tech level.
--- @return number
function Inhabitants.get_birth_defect_probability()
    return 0.25 * 0.8 ^ storage.technologies["improved-reproductive-healthcare"]
end

--- Returns the disease progress for accident-type diseases.
--- @param entry Entry
--- @param delta_ticks integer
--- @return number
function Inhabitants.get_accident_disease_progress(entry, delta_ticks)
    return entry[EK.inhabitants] * delta_ticks / 100000 / (entry[EK.health] + entry[EK.sanity] + 1) *
        castes[entry[EK.type]].accident_disease_resilience
end

--- Returns the disease progress for health-based diseases.
--- @param entry Entry
--- @param delta_ticks integer
--- @return number
function Inhabitants.get_health_disease_progress(entry, delta_ticks)
    return entry[EK.inhabitants] * delta_ticks / 100000 / (entry[EK.health] + 1) *
        castes[entry[EK.type]].health_disease_resilience
end

--- Returns the disease progress for sanity-based diseases.
--- @param entry Entry
--- @param delta_ticks integer
--- @return number
function Inhabitants.get_sanity_disease_progress(entry, delta_ticks)
    return entry[EK.inhabitants] * delta_ticks / 100000 / (entry[EK.sanity] + 1) *
        castes[entry[EK.type]].sanity_disease_resilience
end

--- Returns the disease progress for zoonosis (from animal farms).
--- @param entry Entry
--- @param delta_ticks integer
--- @return number
function Inhabitants.get_zoonosis_disease_progress(entry, delta_ticks)
    return entry[EK.inhabitants] * delta_ticks * (storage.active_animal_farms ^ 0.5) / 5000000
end

--- Returns the disease progress from workplace accidents of the given category.
--- @param entry Entry
--- @param delta_ticks integer
--- @param disease_category DiseaseCategory
--- @return number
local function get_workplace_accident_progress(entry, delta_ticks, disease_category)
    local progress = 0
    for unit_number, count in pairs(entry[EK.employments]) do
        local workplace_entry = try_get(unit_number)

        if workplace_entry then
            local building_details = get_building_details(workplace_entry)
            local workforce = building_details.workforce
            if workforce and workforce.disease_category == disease_category then
                progress = progress + count * workforce.disease_frequency * delta_ticks
            end
        end
    end

    return progress
end

function Inhabitants.get_hard_work_accident_progress(entry, delta_ticks)
    return get_workplace_accident_progress(entry, delta_ticks, DiseaseCategory.hard_work)
end

function Inhabitants.get_office_accident_progress(entry, delta_ticks)
    return get_workplace_accident_progress(entry, delta_ticks, DiseaseCategory.office_work)
end

function Inhabitants.get_moderate_work_accident_progress(entry, delta_ticks)
    return get_workplace_accident_progress(entry, delta_ticks, DiseaseCategory.moderate_work)
end

function Inhabitants.get_fishing_hut_accident_progress(entry, delta_ticks)
    return get_workplace_accident_progress(entry, delta_ticks, DiseaseCategory.fishing_hut)
end

function Inhabitants.get_hunting_hut_accident_progress(entry, delta_ticks)
    return get_workplace_accident_progress(entry, delta_ticks, DiseaseCategory.hunting_hut)
end

--- Table mapping disease categories to their progress functions.
Inhabitants.disease_progress_updaters = {
    [DiseaseCategory.accident] = Inhabitants.get_accident_disease_progress,
    [DiseaseCategory.health] = Inhabitants.get_health_disease_progress,
    [DiseaseCategory.sanity] = Inhabitants.get_sanity_disease_progress,
    [DiseaseCategory.zoonosis] = Inhabitants.get_zoonosis_disease_progress,
    [DiseaseCategory.hard_work] = Inhabitants.get_hard_work_accident_progress,
    [DiseaseCategory.office_work] = Inhabitants.get_office_accident_progress,
    [DiseaseCategory.moderate_work] = Inhabitants.get_moderate_work_accident_progress,
    [DiseaseCategory.fishing_hut] = Inhabitants.get_fishing_hut_accident_progress,
    [DiseaseCategory.hunting_hut] = Inhabitants.get_hunting_hut_accident_progress
}
local disease_progress_updaters = Inhabitants.disease_progress_updaters

---------------------------------------------------------------------------------------------------
-- << disease case creation and treatment >>

local function create_disease_cases(entry, disease_group, delta_ticks)
    local progresses = entry[EK.disease_progress]

    for disease_category, updater in pairs(disease_progress_updaters) do
        local progress = (progresses[disease_category] or 0) + updater(entry, delta_ticks) -- DELETEME fix for old maps

        if progress >= 1 then
            local new_diseases = floor(progress)

            make_sick_randomly(disease_group, disease_category, new_diseases)

            progress = progress - new_diseases
        end

        progresses[disease_category] = progress
    end
end

local function is_recoverable(id)
    return disease_values[id].natural_recovery ~= nil
end

local function has_facility(hospital, facility_type)
    for _, facility in Neighborhood.iterate_type(hospital, facility_type) do
        if Entity.is_active(facility) then
            return true
        end
    end

    return false
end

local function try_treat_disease(hospital, hospital_contents, inventories, disease_group, disease_id, count)
    -- check if the player disallowed treating this disease
    if hospital[EK.treatment_permissions][disease_id] == false then
        return 0
    end

    local disease = disease_values[disease_id]
    local necessary_facility = disease.curing_facility

    if necessary_facility and not has_facility(hospital, necessary_facility) then
        return 0
    end

    local operations = hospital[EK.workhours]
    local workload_per_case = disease.curing_workload
    local items_per_case = disease.cure_items or {}

    -- determine the number of treated cases
    local to_treat = min(count, floor(operations / workload_per_case))

    for item_name, item_count in pairs(items_per_case) do
        to_treat = min(to_treat, floor((hospital_contents[item_name] or 0) / item_count))
    end

    if to_treat > 0 then
        to_treat = cure(disease_group, disease_id, to_treat)

        -- consume operations and items
        hospital[EK.workhours] = operations - to_treat * workload_per_case

        local items = table_copy(items_per_case)
        table_multiply(items, to_treat)
        Inventories.remove_item_range_from_inventory_range(inventories, items)
    end

    return to_treat
end

local function treat_diseases(entry, hospitals, diseases, disease_group, new_diseases)
    if not diseases then
        return
    end

    for disease_id, count in pairs(diseases) do
        for _, hospital in pairs(hospitals) do
            local inventories = Entity.get_hospital_inventories(hospital)
            local contents = Inventories.get_combined_contents(inventories)

            local treated = try_treat_disease(hospital, contents, inventories, disease_group, disease_id, count)

            if treated > 0 then
                local disease_data = disease_values[disease_id]
                local reports_generated = Utils.coin_flips_overcrit(disease_data.reports_per_treatment, treated, 5)
                if reports_generated > 0 then
                    Inventories.try_insert_into_inventory_range(inventories, "medical-report", reports_generated)
                end

                cure_side_effects(entry, disease_id, treated, true, new_diseases)
                local statistics = hospital[EK.treated]
                statistics[disease_id] = (statistics[disease_id] or 0) + treated
                Communication.report_treatment(disease_id, treated)
            end

            count = count - treated
            if count == 0 then
                break
            end
        end
    end
end

local function update_disease_cases(entry, disease_group, delta_ticks)
    -- check if there are diseased people in the first place, because this function is moderately expensive
    if disease_group[HEALTHY] == entry[EK.inhabitants] then
        return
    end

    -- A table with all the diseases which happen as a side effect of the treatments/recoveries.
    -- They have to be added later to avoid problems with instantly treated-diseases and to avoid
    -- mixing removing and adding keys to the DiseaseGroup (which can break the pairs-loop).
    local new_diseases = {}

    -- treat disease cases in hospitals
    local hospitals = Neighborhood.get_by_type(entry, Type.hospital)
    Arrays.merge(hospitals, Neighborhood.get_by_type(entry, Type.improvised_hospital))

    local grouped = Luaq_from(disease_group):where(not_healthy):group(is_recoverable):to_table()
    treat_diseases(entry, hospitals, grouped[false], disease_group, new_diseases)
    treat_diseases(entry, hospitals, grouped[true], disease_group, new_diseases)

    for disease_id, count in pairs(disease_group) do
        if disease_id ~= HEALTHY then
            local natural_recovery = disease_values[disease_id].natural_recovery
            if natural_recovery then
                local recovered = coin_flips(occurence_probability(natural_recovery, delta_ticks), count, 5)
                recovered = cure(disease_group, disease_id, recovered)

                if recovered > 0 then
                    cure_side_effects(entry, disease_id, recovered, false, new_diseases)
                    Communication.report_recovery(disease_id, recovered)
                end
            end
        end
    end

    for disease_id, count in pairs(new_diseases) do
        make_sick(disease_group, disease_id, count)
    end
end

---------------------------------------------------------------------------------------------------
-- << main disease update >>

--- Updates diseases for a housing entry: creates new cases, treats existing ones, and adjusts employment.
--- @param entry Entry
--- @param delta_ticks integer
local function update_diseases(entry, delta_ticks)
    local disease_group = entry[EK.diseases]

    create_disease_cases(entry, disease_group, delta_ticks)
    update_disease_cases(entry, disease_group, delta_ticks)

    -- check employments
    local healthy_count = disease_group[HEALTHY]
    local employed_count = entry[EK.employed]

    if employed_count > healthy_count then
        unemploy_inhabitants(entry, employed_count - healthy_count)
    end
end
Inhabitants.update_diseases = update_diseases

---------------------------------------------------------------------------------------------------
-- << blood donations >>

--- Returns the blood donation progress for a housing entry.
--- @param entry Entry
--- @param delta_ticks integer
--- @return number
local function get_blood_donation_progress(entry, delta_ticks)
    return entry[EK.diseases][HEALTHY] * (entry[EK.health] ^ 0.5) * delta_ticks / 1000000
end
Inhabitants.get_blood_donation_progress = get_blood_donation_progress

--- Updates blood donations for a housing entry: accumulates progress and inserts blood items into nearby hospitals.
--- @param entry Entry
--- @param delta_ticks integer
local function update_blood_donations(entry, delta_ticks)
    if not storage.technologies["transfusion-medicine"] then
        return
    end

    local donations =
        update_progress(entry, EK.blood_donation_progress, get_blood_donation_progress(entry, delta_ticks))

    if donations > 0 then
        local hospitals = Neighborhood.get_by_type(entry, Type.improvised_hospital)
        Arrays.merge(hospitals, Neighborhood.get_by_type(entry, Type.hospital))

        for _, hospital in pairs(hospitals) do
            if hospital[EK.workhours] >= hospital[EK.blood_donation_threshold] then
                local max_donations = min(donations, floor(hospital[EK.workhours] / Biology.blood_donation_workload))
                donations = donations - max_donations

                local actual_donations =
                    Inventories.try_insert(
                    Inventories.get_chest_inventory(hospital),
                    Biology.blood_donation_item,
                    max_donations
                )
                hospital[EK.blood_donations] = hospital[EK.blood_donations] + actual_donations
                hospital[EK.workhours] = hospital[EK.workhours] - actual_donations * Biology.blood_donation_workload

                if donations < 1 then
                    return
                end
            end
        end
    end
end
Inhabitants.update_blood_donations = update_blood_donations
