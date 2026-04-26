local EK = require("enums.entry-key")
local Type = require("enums.type")

local Biology = require("constants.biology")
local Castes = require("constants.castes")
local Buildings = require("constants.buildings")
local Diseases = require("constants.diseases")
local TypeGroup = require("constants.type-groups")

local get_building_details = Buildings.get
local get_chest_inventory = Inventories.get_chest_inventory
local disease_values = Diseases.values
local has_power = Subentities.has_power
local evaluate_workforce = Inhabitants.evaluate_workforce
local evaluate_worker_happiness = Inhabitants.evaluate_worker_happiness
local apply_cure_side_effects = Inhabitants.apply_cure_side_effects
local cure = DiseaseGroup.cure
local try_get = Register.try_get
local Table = Tirislib.Tables
local Utils = Tirislib.Utils
local coin_flips_overcrit = Utils.coin_flips_overcrit
local HEALTHY = DiseaseGroup.HEALTHY
local floor = math.floor

--- Returns the LuaInventory of the given hospital and all hospital complement buildings connected to it.
--- @param entry Entry hospital
--- @return LuaInventory[]
function Entity.get_hospital_inventories(entry)
    local ret = {get_chest_inventory(entry)}

    for _, _type in pairs(TypeGroup.hospital_complements) do
        for _, building in Neighborhood.iterate_type(entry, _type) do
            ret[#ret + 1] = get_chest_inventory(building)
        end
    end

    return ret
end

--- Removes exactly one occurrence of hospital_uid from housing[EK.treatment_claims][disease_id].
local function release_claim(housing, disease_id, hospital_uid)
    local claims = housing[EK.treatment_claims]
    local claimers = claims and claims[disease_id]
    if not claimers then return end
    for i = #claimers, 1, -1 do
        if claimers[i] == hospital_uid then
            table.remove(claimers, i)
            break
        end
    end
    if #claimers == 0 then
        claims[disease_id] = nil
    end
end

local function has_facility(hospital, facility_type)
    for _, facility in Neighborhood.iterate_type(hospital, facility_type) do
        if Entity.is_active(facility) then
            return true
        end
    end

    return false
end

--- Returns whether the given hospital can currently treat the given disease.
--- Checks treatability, required facility availability, and treatment permissions.
--- @param hospital Entry
--- @param disease_id integer
--- @return boolean
function Entity.hospital_can_treat(hospital, disease_id)
    local disease = disease_values[disease_id]
    if not disease.is_treatable then return false end
    if hospital[EK.treatment_permissions][disease_id] == false then return false end
    if disease.curing_facility and not has_facility(hospital, disease.curing_facility) then return false end
    return true
end

--- Treats one specific disease in a housing entry using one hospital slot's work budget for one tick.
--- Cure items were consumed when the slot was claimed; this only accumulates work and cures.
--- @param housing Entry
--- @param slot table {uid, disease_id, work_done}
--- @param inventories LuaInventory[]
--- @param available_work number work budget for this slot this tick
--- @param statistics table hospital[EK.treated]
local function treat_disease_slot(housing, slot, inventories, available_work, statistics)
    local disease_id = slot.disease_id
    local disease_group = housing[EK.diseases]
    local count = disease_group[disease_id]
    if not count or count == 0 then return end

    local disease = disease_values[disease_id]
    local work_done = (slot.work_done or 0) + available_work

    if work_done >= disease.curing_workload then
        cure(disease_group, disease_id, 1)

        local reports = coin_flips_overcrit(disease.reports_per_treatment, 1, 5)
        if reports > 0 then
            Inventories.try_insert_into_inventory_range(inventories, "medical-report", reports)
        end

        apply_cure_side_effects(housing, disease_id, 1, true)
        statistics[disease_id] = (statistics[disease_id] or 0) + 1
        Communication.report_treatment(disease_id, 1)

        work_done = work_done - disease.curing_workload
    end

    if work_done > disease.curing_workload then
        work_done = disease.curing_workload
    end
    slot.work_done = work_done
end

--- Processes one in-progress blood donation slot.
--- Medical instruments were consumed when the slot was accepted; this only accumulates work
--- and produces the blood bag when done.
--- @param hospital Entry
--- @param slot table {uid, blood_donation, work_done}
--- @param inventories LuaInventory[]
--- @param available_work number
local function process_blood_donation_slot(hospital, slot, inventories, available_work)
    local work_done = (slot.work_done or 0) + available_work

    if work_done >= Biology.blood_donation_workload then
        Inventories.try_insert_into_inventory_range(inventories, Biology.blood_donation_item, 1)
        hospital[EK.blood_donations] = hospital[EK.blood_donations] + 1
        slot.done = true
    else
        slot.work_done = work_done
    end
end

--- Writes a fake-tooltip custom_status showing bed occupancy.
--- @param entry Entry hospital
--- @param filled integer
--- @param capacity integer
--- @param active boolean
local function set_custom_status(entry, filled, capacity, active)
    local diode, header
    if not active then
        diode = defines.entity_status_diode.red
        header = "sosciencity-custom-status.hospital-inactive"
    elseif filled == 0 then
        diode = defines.entity_status_diode.yellow
        header = "sosciencity-custom-status.hospital-idle"
    else
        diode = defines.entity_status_diode.green
        header = "sosciencity-custom-status.hospital-treating"
    end

    local label = {header}
    Tirislib.Locales.append(label, {"sosciencity-custom-status.hospital-beds", filled, capacity})

    entry[EK.entity].custom_status = {
        diode = diode,
        label = label
    }
end

local function update_hospital(entry, delta_ticks)
    local performance = evaluate_workforce(entry) * evaluate_worker_happiness(entry)
    if not has_power(entry) then
        performance = 0
    end
    entry[EK.performance] = performance
    entry[EK.active] = performance > 0

    local building_details = get_building_details(entry)
    local effective_slots = building_details.slots
    local unit_number = entry[EK.unit_number]
    local slots = entry[EK.slots]

    -- validate existing slots: remove done/stale blood donation slots;
    -- release disease slots whose target is gone, disease resolved, or treatment conditions changed
    for i = #slots, 1, -1 do
        local slot = slots[i]
        if slot.blood_donation then
            if slot.done or not try_get(slot.uid) then
                table.remove(slots, i)
            end
        else
            local target = try_get(slot.uid)
            local disease_count = target and target[EK.diseases][slot.disease_id]
            local still_ours = false
            if disease_count and disease_count > 0 then
                local claimers = target[EK.treatment_claims] and target[EK.treatment_claims][slot.disease_id]
                if claimers then
                    for _, uid in pairs(claimers) do
                        if uid == unit_number then
                            still_ours = true
                            break
                        end
                    end
                end
            end
            if still_ours then
                local disease = disease_values[slot.disease_id]
                if entry[EK.treatment_permissions][slot.disease_id] == false then
                    still_ours = false
                elseif disease.curing_facility and not has_facility(entry, disease.curing_facility) then
                    still_ours = false
                end
            end
            if not still_ours then
                if target then release_claim(target, slot.disease_id, unit_number) end
                table.remove(slots, i)
            end
        end
    end

    -- trim to capacity (guards against unexpected slot count reductions)
    while #slots > effective_slots do
        local slot = slots[#slots]
        slots[#slots] = nil
        if not slot.blood_donation then
            local target = try_get(slot.uid)
            if target then release_claim(target, slot.disease_id, unit_number) end
        end
    end

    if performance > 0 then
        local inventories = Entity.get_hospital_inventories(entry)

        -- claim new (housing, disease) pairs with upfront cure-item consumption
        if #slots < effective_slots then
            local contents = Inventories.get_combined_contents(inventories)

            for _, caste in pairs(Castes.all) do
                if #slots >= effective_slots then break end

                for _, housing in Neighborhood.iterate_type(entry, caste.type) do
                    if #slots >= effective_slots then break end
                    local diseases = housing[EK.diseases]
                    local claims = housing[EK.treatment_claims]

                    for disease_id, count in pairs(diseases) do
                        if #slots >= effective_slots then break end
                        if disease_id == HEALTHY or count == 0 then goto next_disease end

                        if not Entity.hospital_can_treat(entry, disease_id) then goto next_disease end
                        local disease = disease_values[disease_id]

                        local current_claims = (claims and claims[disease_id]) and #claims[disease_id] or 0
                        if current_claims >= count then goto next_disease end

                        local cure_items = disease.cure_items
                        if cure_items and next(cure_items) then
                            local can_afford = true
                            for item_name, item_count in pairs(cure_items) do
                                if (contents[item_name] or 0) < item_count then
                                    can_afford = false
                                    break
                                end
                            end
                            if not can_afford then goto next_disease end

                            Inventories.remove_item_range_from_inventory_range(inventories, cure_items)
                            for item_name, item_count in pairs(cure_items) do
                                contents[item_name] = (contents[item_name] or 0) - item_count
                            end
                        end

                        if not claims then
                            housing[EK.treatment_claims] = {}
                            claims = housing[EK.treatment_claims]
                        end
                        claims[disease_id] = claims[disease_id] or {}
                        claims[disease_id][#claims[disease_id] + 1] = unit_number
                        slots[#slots + 1] = {uid = housing[EK.unit_number], disease_id = disease_id, work_done = 0}
                        ::next_disease::
                    end
                end
            end
        end

        -- treat each claimed slot
        if #slots > 0 then
            local work_per_slot = performance * delta_ticks * building_details.speed
            local statistics = entry[EK.treated]

            for _, slot in pairs(slots) do
                if slot.blood_donation then
                    if not slot.done then
                        process_blood_donation_slot(entry, slot, inventories, work_per_slot)
                    end
                else
                    local housing = try_get(slot.uid)
                    if housing then
                        treat_disease_slot(housing, slot, inventories, work_per_slot, statistics)
                    end
                end
            end
        end
    end

    set_custom_status(entry, #slots, effective_slots, performance > 0)
end

Register.set_entity_updater(Type.hospital, update_hospital)
Register.set_entity_updater(Type.improvised_hospital, update_hospital)

--- Accepts a blood donation from a housing entry if the hospital has capacity and resources.
--- Consumes one surgery-instruments item upfront and claims a slot.
--- Returns true if accepted, false if refused (inactive, at threshold, or missing items).
--- @param hospital Entry
--- @param housing Entry
--- @return boolean
function Entity.try_blood_donation(hospital, housing)
    if not hospital[EK.active] then return false end

    local free_slots = get_building_details(hospital).slots - #hospital[EK.slots]
    if free_slots <= hospital[EK.blood_donation_threshold] then return false end

    local inventories = Entity.get_hospital_inventories(hospital)
    local contents = Inventories.get_combined_contents(inventories)
    local cost = Biology.blood_donation_medical_instruments_cost

    if (contents["surgery-instruments"] or 0) < cost then return false end

    Inventories.remove_item_range_from_inventory_range(inventories, {["surgery-instruments"] = cost})
    hospital[EK.slots][#hospital[EK.slots] + 1] = {uid = housing[EK.unit_number], blood_donation = true, work_done = 0}

    return true
end

local function create_hospital(entry)
    entry[EK.slots] = {}
    entry[EK.treated] = {}
    entry[EK.treatment_permissions] = {}
    -- threshold: minimum free slots required before accepting blood donations (0 = always accept)
    entry[EK.blood_donation_threshold] = 0
    entry[EK.blood_donations] = 0

    local inventory = get_chest_inventory(entry)
    if not inventory.supports_filters() or inventory.is_filtered() then
        return
    end
    inventory.set_filter(1, "medical-report")
end

Register.set_entity_creation_handler(Type.hospital, create_hospital)
Register.set_entity_creation_handler(Type.improvised_hospital, create_hospital)

local function copy_hospital(source, destination)
    destination[EK.treated] = Table.copy(source[EK.treated])
    destination[EK.treatment_permissions] = Table.copy(source[EK.treatment_permissions])
    destination[EK.blood_donations] = source[EK.blood_donations]

    if source[EK.slots] then
        -- current per-disease slot format: deep-copy each record so work_done is owned per-entry
        destination[EK.slots] = Tirislib.Tables.recursive_copy(source[EK.slots])
        destination[EK.blood_donation_threshold] = source[EK.blood_donation_threshold]
    else
        -- migrating from pre-slot or per-house slot save: start fresh
        -- (back-references on housing entries will self-clean on next housing tick)
        destination[EK.blood_donation_threshold] = source[EK.blood_donation_threshold] or 0
    end
end

Register.set_entity_copy_handler(Type.hospital, copy_hospital)
Register.set_entity_copy_handler(Type.improvised_hospital, copy_hospital)

local function paste_hospital_settings(source, destination)
    destination[EK.blood_donation_threshold] = source[EK.blood_donation_threshold]
end

Register.set_settings_paste_handler(Type.hospital, Type.hospital, paste_hospital_settings)
Register.set_settings_paste_handler(Type.hospital, Type.improvised_hospital, paste_hospital_settings)
Register.set_settings_paste_handler(Type.improvised_hospital, Type.hospital, paste_hospital_settings)
Register.set_settings_paste_handler(Type.improvised_hospital, Type.improvised_hospital, paste_hospital_settings)
