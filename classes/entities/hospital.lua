local EK = require("enums.entry-key")
local Type = require("enums.type")

local Castes = require("constants.castes")
local Buildings = require("constants.buildings")
local Diseases = require("constants.diseases")
local InhabitantsConstants = require("constants.inhabitants")
local Types = require("constants.types")

local get_building_details = Buildings.get
local get_chest_inventory = Inventories.get_chest_inventory
local disease_values = Diseases.values
local type_definitions = Types.definitions
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
local max = math.max

--- Static class for hospital-specific mechanics.
Entity.Hospital = {}
local Hospital = Entity.Hospital

local inventory_sharing_types = Types.select("shares_hospital_inventory")
local ward_types = Types.select("is_hospital_ward")

--- Wards that take blood donors (blood donations are general medicine).
local donation_ward_types = {}
for _, _type in pairs(ward_types) do
    if type_definitions[_type].treats_general_medicine then
        donation_ward_types[#donation_ward_types + 1] = _type
    end
end

--- Returns the LuaInventory of the given hospital and all the connected buildings that share their inventory.
--- @param entry Entry hospital
--- @return LuaInventory[]
function Hospital.get_inventories(entry)
    local ret = {get_chest_inventory(entry)}

    for _, _type in pairs(inventory_sharing_types) do
        for _, building in Neighborhood.iterate_type(entry, _type) do
            ret[#ret + 1] = get_chest_inventory(building)
        end
    end

    return ret
end

--- Removes exactly one occurrence of bed_uid from housing[EK.treatment_claims][disease_id].
local function release_claim(housing, disease_id, bed_uid)
    local claims = housing[EK.treatment_claims]
    local claimers = claims and claims[disease_id]
    if not claimers then return end
    for i = #claimers, 1, -1 do
        if claimers[i] == bed_uid then
            table.remove(claimers, i)
            break
        end
    end
    if #claimers == 0 then
        claims[disease_id] = nil
    end
end

--- Returns whether the beds of the given bed building take the given disease:
--- specialised wards take the diseases that need them as curing facility, general beds take the rest.
--- @param entry Entry bed building
--- @param disease_id integer
--- @return boolean
local function bed_accepts(entry, disease_id)
    local facility = disease_values[disease_id].curing_facility
    if facility then
        return entry[EK.type] == facility
    end
    return type_definitions[entry[EK.type]].treats_general_medicine == true
end

--- Returns the bed buildings the given hub admits into: the hub itself first, then its active wards
--- of the given types.
--- @param hub Entry
--- @param ward_types Type[]
--- @return Entry[]
local function get_bed_buildings(hub, ward_types)
    local ret = {hub}
    for _, _type in pairs(ward_types) do
        for _, ward in Neighborhood.iterate_type(hub, _type) do
            if ward[EK.active] then
                ret[#ret + 1] = ward
            end
        end
    end
    return ret
end

--- Returns whether the given hospital can currently treat the given disease.
--- Checks treatability, treatment permissions, and whether the hospital or one of its active wards
--- has the right kind of beds (free or not).
--- @param hospital Entry
--- @param disease_id integer
--- @return boolean
function Hospital.can_treat(hospital, disease_id)
    if not disease_values[disease_id].is_treatable then return false end
    if hospital[EK.treatment_permissions][disease_id] == false then return false end

    for _, bed_building in pairs(get_bed_buildings(hospital, ward_types)) do
        if bed_accepts(bed_building, disease_id) then
            return true
        end
    end
    return false
end

---------------------------------------------------------------------------------------------------
-- << beds >>
-- A bed building owns disease slots (EK.slots) and blood donation slots (EK.donation_slots), one patient
-- per slot, and treats the patients in them. Patients are admitted by a hub, which pays the cure items.

--- @param entry Entry bed building
--- @return integer
local function get_bed_count(entry)
    return get_building_details(entry).slots
end
Hospital.get_bed_count = get_bed_count

--- @param entry Entry bed building
--- @return integer
function Hospital.get_occupied_bed_count(entry)
    return #entry[EK.slots] + #entry[EK.donation_slots]
end

--- @param entry Entry bed building
--- @return integer
local function get_free_bed_count(entry)
    return get_bed_count(entry) - #entry[EK.slots] - #entry[EK.donation_slots]
end

--- Puts a patient into a free bed and marks the disease case as claimed by this bed building.
--- The cure items must already be paid.
--- @param entry Entry bed building
--- @param housing Entry
--- @param disease_id integer
local function admit_patient(entry, housing, disease_id)
    local claims = housing[EK.treatment_claims]
    if not claims then
        claims = {}
        housing[EK.treatment_claims] = claims
    end
    local claimers = claims[disease_id]
    if not claimers then
        claimers = {}
        claims[disease_id] = claimers
    end
    claimers[#claimers + 1] = entry[EK.unit_number]

    local slots = entry[EK.slots]
    slots[#slots + 1] = {uid = housing[EK.unit_number], disease_id = disease_id, work_done = 0}
end

--- Puts a blood donor into a free bed. The medical instruments must already be paid.
--- @param entry Entry bed building
--- @param housing Entry
local function admit_donor(entry, housing)
    local donation_slots = entry[EK.donation_slots]
    donation_slots[#donation_slots + 1] = {uid = housing[EK.unit_number], work_done = 0}
end

--- Empties all beds and releases their claims on the housing entries.
--- @param entry Entry bed building
local function release_all_beds(entry)
    local unit_number = entry[EK.unit_number]
    for _, slot in pairs(entry[EK.slots]) do
        local housing = try_get(slot.uid)
        if housing then release_claim(housing, slot.disease_id, unit_number) end
    end
    entry[EK.slots] = {}
    entry[EK.donation_slots] = {}
end

--- Returns whether a disease slot is still valid for this bed building.
--- Checks: patient exists, disease still present, this bed building is the claimer,
--- the beds take the disease (only fails for patients left over from before the wards had beds).
--- Treatment permissions are not checked: they only matter at admission.
--- @param entry Entry bed building
--- @param slot table {uid, disease_id, work_done}
--- @return boolean
local function disease_slot_is_valid(entry, slot)
    local target = try_get(slot.uid)
    if not target then return false end

    local disease_count = target[EK.diseases][slot.disease_id]
    if not disease_count or disease_count == 0 then return false end

    local claimers = target[EK.treatment_claims] and target[EK.treatment_claims][slot.disease_id]
    if not claimers then return false end
    local unit_number = entry[EK.unit_number]
    local is_ours = false
    for _, uid in pairs(claimers) do
        if uid == unit_number then
            is_ours = true
            break
        end
    end
    if not is_ours then return false end

    return bed_accepts(entry, slot.disease_id)
end

--- Releases all slots that became invalid and trims the slots to the bed count.
--- @param entry Entry bed building
local function validate_beds(entry)
    local unit_number = entry[EK.unit_number]
    local slots = entry[EK.slots]
    local donation_slots = entry[EK.donation_slots]

    for i = #slots, 1, -1 do
        local slot = slots[i]
        if not disease_slot_is_valid(entry, slot) then
            local target = try_get(slot.uid)
            if target then release_claim(target, slot.disease_id, unit_number) end
            table.remove(slots, i)
        end
    end

    -- donation slots are only invalid when the donor's house is gone
    for i = #donation_slots, 1, -1 do
        if not try_get(donation_slots[i].uid) then
            table.remove(donation_slots, i)
        end
    end

    -- trim to capacity (guards against unexpected slot count reductions)
    -- donation slots are trimmed first to preserve treatment capacity
    local bed_count = get_bed_count(entry)
    while #slots + #donation_slots > bed_count do
        if #donation_slots > 0 then
            donation_slots[#donation_slots] = nil
        else
            local slot = slots[#slots]
            slots[#slots] = nil
            local target = try_get(slot.uid)
            if target then release_claim(target, slot.disease_id, unit_number) end
        end
    end
end

--- Treats one patient in a housing entry using one slot's work budget for one update.
--- Cure items were consumed when the patient was admitted; this only accumulates work and cures.
--- @param housing Entry
--- @param slot table {uid, disease_id, work_done}
--- @param inventories LuaInventory[] where the medical reports go
--- @param available_work number work budget for this slot this update
--- @param statistics table bed building's EK.treated
--- @return boolean finished whether the slot is done and should be released
local function treat_disease_slot(housing, slot, inventories, available_work, statistics)
    local disease_id = slot.disease_id
    local disease_group = housing[EK.diseases]
    local count = disease_group[disease_id]
    if not count or count == 0 then return true end

    local disease = disease_values[disease_id]
    local work_done = (slot.work_done or 0) + available_work

    if work_done < disease.curing_workload then
        slot.work_done = work_done
        return false
    end

    cure(disease_group, disease_id, 1)

    local reports = coin_flips_overcrit(disease.reports_per_treatment, 1, 5)
    if reports > 0 then
        Inventories.try_insert_into_inventory_range(inventories, "medical-report", reports)
    end

    apply_cure_side_effects(housing, disease_id, 1, true)
    statistics[disease_id] = (statistics[disease_id] or 0) + 1
    Communication.report_treatment(disease_id, 1)

    return true
end

--- Processes one in-progress blood donation slot.
--- Medical instruments were consumed when the donor was admitted; this only accumulates work
--- and produces the blood bag when done.
--- @param entry Entry bed building
--- @param slot table {uid, work_done}
--- @param inventories LuaInventory[] where the blood bag goes
--- @param available_work number
--- @return boolean finished whether the slot is done and should be released
local function process_blood_donation_slot(entry, slot, inventories, available_work)
    local work_done = (slot.work_done or 0) + available_work

    if work_done < InhabitantsConstants.blood_donation_workload then
        slot.work_done = work_done
        return false
    end

    Inventories.try_insert_into_inventory_range(inventories, InhabitantsConstants.blood_donation_item, 1)
    entry[EK.blood_donations] = entry[EK.blood_donations] + 1
    return true
end

--- Works on every occupied bed and releases the finished ones immediately, so the next patient
--- has to be admitted (and paid for) anew.
--- @param entry Entry bed building
--- @param work_per_bed number
--- @param inventories LuaInventory[] where medical reports and blood bags go
local function treat_beds(entry, work_per_bed, inventories)
    local unit_number = entry[EK.unit_number]
    local slots = entry[EK.slots]
    local statistics = entry[EK.treated]

    for i = #slots, 1, -1 do
        local slot = slots[i]
        local housing = try_get(slot.uid)
        if housing and treat_disease_slot(housing, slot, inventories, work_per_bed, statistics) then
            release_claim(housing, slot.disease_id, unit_number)
            table.remove(slots, i)
        end
    end

    local donation_slots = entry[EK.donation_slots]
    for i = #donation_slots, 1, -1 do
        if process_blood_donation_slot(entry, donation_slots[i], inventories, work_per_bed) then
            table.remove(donation_slots, i)
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << admission >>

--- Removes the given items from the inventories if all of them are available.
--- Keeps `contents` (the combined contents of the inventories) up to date.
--- @param inventories LuaInventory[]
--- @param contents table combined contents of the inventories
--- @param items table? (item name, count)-pairs
--- @return boolean paid
local function try_pay(inventories, contents, items)
    if not items or not next(items) then return true end

    for item_name, item_count in pairs(items) do
        if (contents[item_name] or 0) < item_count then
            return false
        end
    end

    Inventories.remove_item_range_from_inventory_range(inventories, items)
    for item_name, item_count in pairs(items) do
        contents[item_name] = contents[item_name] - item_count
    end
    return true
end

--- Returns the index of the first bed building that takes the given disease and has a free bed.
--- @param bed_buildings Entry[]
--- @param free_beds integer[] free bed count per bed building
--- @param disease_id integer
--- @return integer?
local function find_free_bed(bed_buildings, free_beds, disease_id)
    for i = 1, #bed_buildings do
        if free_beds[i] > 0 and bed_accepts(bed_buildings[i], disease_id) then
            return i
        end
    end
end

--- Scans the hub's neighborhood for unclaimed disease cases and admits them into free beds of the hub
--- and its active wards, paying the cure items upfront. Admits at most one case per (house, disease)
--- pair per update.
--- @param hub Entry
--- @param inventories LuaInventory[] where the cure items are taken from
local function admit_patients(hub, inventories)
    local bed_buildings = get_bed_buildings(hub, ward_types)
    local free_beds = {}
    local total_free_beds = 0
    for i = 1, #bed_buildings do
        local free = max(0, get_free_bed_count(bed_buildings[i]))
        free_beds[i] = free
        total_free_beds = total_free_beds + free
    end
    if total_free_beds == 0 then return end

    local contents = Inventories.get_combined_contents(inventories)
    local permissions = hub[EK.treatment_permissions]

    for _, caste in pairs(Castes.all) do
        for _, housing in Neighborhood.iterate_type(hub, caste.type) do
            for disease_id, count in pairs(housing[EK.diseases]) do
                local disease = disease_values[disease_id]
                if disease_id ~= HEALTHY and count > 0 and disease.is_treatable and permissions[disease_id] ~= false then
                    local claims = housing[EK.treatment_claims]
                    local current_claims = (claims and claims[disease_id]) and #claims[disease_id] or 0
                    local index = current_claims < count and find_free_bed(bed_buildings, free_beds, disease_id)

                    if index and try_pay(inventories, contents, disease.cure_items) then
                        admit_patient(bed_buildings[index], housing, disease_id)
                        free_beds[index] = free_beds[index] - 1
                        total_free_beds = total_free_beds - 1
                        if total_free_beds == 0 then return end
                    end
                end
            end
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << hospital >>

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

--- Returns where a ward puts its medical reports and blood bags: the inventories of a connected hospital,
--- or its own chest if no hospital is connected.
--- @param ward Entry
--- @return LuaInventory[]
local function get_ward_output_inventories(ward)
    for _, hospital in Neighborhood.iterate_type(ward, Type.hospital) do
        return Hospital.get_inventories(hospital)
    end
    return {get_chest_inventory(ward)}
end

--- Updater for every bed building. Hubs also admit new patients; wards only treat the ones they were given.
local function update_bed_building(entry, delta_ticks)
    local performance = evaluate_workforce(entry) * evaluate_worker_happiness(entry)
    if not has_power(entry) then
        performance = 0
    end
    entry[EK.performance] = performance
    entry[EK.active] = performance > 0

    local bed_count = get_bed_count(entry)

    if performance == 0 then
        release_all_beds(entry)
        set_custom_status(entry, 0, bed_count, false)
        return
    end

    validate_beds(entry)

    local inventories
    if type_definitions[entry[EK.type]].admits_patients then
        inventories = Hospital.get_inventories(entry)
        admit_patients(entry, inventories)
    else
        inventories = get_ward_output_inventories(entry)
    end
    treat_beds(entry, performance * delta_ticks * get_building_details(entry).speed, inventories)

    set_custom_status(entry, bed_count - get_free_bed_count(entry), bed_count, true)
end

Register.set_entity_updater(Type.hospital, update_bed_building)
Register.set_entity_updater(Type.improvised_hospital, update_bed_building)
for _, _type in pairs(ward_types) do
    Register.set_entity_updater(_type, update_bed_building)
end

local Comb = require("enums.performance-combination")
local Dim = require("enums.performance-dimension")
local PE = require("enums.performance-effect")
local PK = require("enums.performance-key")

local Communication = require("classes.communication")
local Entity = require("classes.entity")
local Inhabitants = require("classes.inhabitants")
local Inventories = require("classes.inventories")
local Neighborhood = require("classes.neighborhood")
local Register = require("classes.register")
local Subentities = require("classes.subentities")

local function build_hospital_report(entry)
    if not has_power(entry) then
        return {
            [PK.effects] = {{[PK.effect] = PE.power, [PK.value] = 0, [PK.dimension] = Dim.speed, [PK.combination] = Comb.bottleneck}},
            [PK.results] = {[Dim.speed] = 0}
        }
    end

    local worker_performance = evaluate_workforce(entry)
    local worker_happiness = evaluate_worker_happiness(entry)

    return {
        [PK.effects] = {
            {
                [PK.effect] = PE.workforce,
                [PK.value] = worker_performance,
                [PK.dimension] = Dim.speed,
                [PK.combination] = Comb.bottleneck
            },
            {
                [PK.effect] = PE.worker_happiness,
                [PK.value] = worker_happiness,
                [PK.dimension] = Dim.speed,
                [PK.combination] = Comb.multiplier
            }
        },
        [PK.results] = {[Dim.speed] = worker_performance * worker_happiness}
    }
end
Entity.set_performance_report_builder(Type.hospital, build_hospital_report)
Entity.set_performance_report_builder(Type.improvised_hospital, build_hospital_report)
for _, _type in pairs(ward_types) do
    Entity.set_performance_report_builder(_type, build_hospital_report)
end

--- Accepts a blood donation from a housing entry if the hospital and its general wards have capacity
--- and resources. Consumes the medical instruments upfront and puts the donor into a free bed, the
--- hospital's own beds first.
--- Returns true if accepted, false if refused (inactive, at threshold, or missing items).
--- @param hospital Entry
--- @param housing Entry
--- @return boolean
function Hospital.try_blood_donation(hospital, housing)
    if not hospital[EK.active] then return false end

    local bed_buildings = get_bed_buildings(hospital, donation_ward_types)
    local free_beds = 0
    for _, bed_building in pairs(bed_buildings) do
        free_beds = free_beds + max(0, get_free_bed_count(bed_building))
    end
    if free_beds == 0 or free_beds <= hospital[EK.blood_donation_threshold] then return false end

    local inventories = Hospital.get_inventories(hospital)
    local contents = Inventories.get_combined_contents(inventories)
    local cost = InhabitantsConstants.blood_donation_medical_instruments_cost

    if (contents["surgery-instruments"] or 0) < cost then return false end

    Inventories.remove_item_range_from_inventory_range(inventories, {["surgery-instruments"] = cost})
    for _, bed_building in pairs(bed_buildings) do
        if get_free_bed_count(bed_building) > 0 then
            admit_donor(bed_building, housing)
            return true
        end
    end
end

local function create_hospital(entry)
    entry[EK.slots] = {}
    entry[EK.donation_slots] = {}
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

Register.set_entity_destruction_handler(Type.hospital, release_all_beds)
Register.set_entity_destruction_handler(Type.improvised_hospital, release_all_beds)


local function copy_hospital(source, destination)
    destination[EK.treated] = Table.copy(source[EK.treated])
    destination[EK.treatment_permissions] = Table.copy(source[EK.treatment_permissions])
    destination[EK.blood_donations] = source[EK.blood_donations]

    if source[EK.slots] then
        if source[EK.donation_slots] then
            -- current split format: deep-copy each array independently
            destination[EK.slots] = Tirislib.Tables.recursive_copy(source[EK.slots])
            destination[EK.donation_slots] = Tirislib.Tables.recursive_copy(source[EK.donation_slots])
        else
            -- migrating from mixed-slot format: separate disease and donation slots by type
            local new_slots, new_donation_slots = {}, {}
            for _, slot in pairs(source[EK.slots]) do
                if slot.blood_donation then
                    new_donation_slots[#new_donation_slots + 1] = {uid = slot.uid, work_done = slot.work_done or 0}
                else
                    new_slots[#new_slots + 1] = Tirislib.Tables.copy(slot)
                end
            end
            destination[EK.slots] = new_slots
            destination[EK.donation_slots] = new_donation_slots
        end
        destination[EK.blood_donation_threshold] = source[EK.blood_donation_threshold]
    else
        -- migrating from pre-slot save: start fresh
        -- (back-references on housing entries will self-clean on next housing tick)
        destination[EK.slots] = {}
        destination[EK.donation_slots] = {}
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

---------------------------------------------------------------------------------------------------
-- << wards >>

local function create_ward(entry)
    entry[EK.slots] = {}
    entry[EK.donation_slots] = {}
    entry[EK.treated] = {}
    entry[EK.blood_donations] = 0
end

local function copy_ward(source, destination)
    -- wards from before they had beds have nothing to copy; the creation handler's defaults stay
    if not source[EK.slots] then return end

    destination[EK.slots] = Tirislib.Tables.recursive_copy(source[EK.slots])
    destination[EK.donation_slots] = Tirislib.Tables.recursive_copy(source[EK.donation_slots])
    destination[EK.treated] = Table.copy(source[EK.treated])
    destination[EK.blood_donations] = source[EK.blood_donations]
end

for _, _type in pairs(ward_types) do
    Register.set_entity_creation_handler(_type, create_ward)
    Register.set_entity_destruction_handler(_type, release_all_beds)
    Register.set_entity_copy_handler(_type, copy_ward)
end
