local EK = require("enums.entry-key")
local Type = require("enums.type")

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
local treat_disease_slot = Inhabitants.treat_disease_slot
local try_get = Register.try_get
local Table = Tirislib.Tables
local HEALTHY = DiseaseGroup.HEALTHY

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

    -- validate existing slots: release any whose disease is gone or back-reference is stale
    for i = #slots, 1, -1 do
        local slot = slots[i]
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
        if not still_ours then
            if target then release_claim(target, slot.disease_id, unit_number) end
            table.remove(slots, i)
        end
    end

    -- trim to capacity (guards against unexpected slot count reductions)
    while #slots > effective_slots do
        local slot = slots[#slots]
        slots[#slots] = nil
        local target = try_get(slot.uid)
        if target then release_claim(target, slot.disease_id, unit_number) end
    end

    -- claim new (housing, disease) pairs from the neighborhood
    if #slots < effective_slots then
        for _, caste in pairs(Castes.all) do
            if #slots >= effective_slots then break end

            for _, housing in Neighborhood.iterate_type(entry, caste.type) do
                if #slots >= effective_slots then break end
                local diseases = housing[EK.diseases]
                local claims = housing[EK.treatment_claims]

                for disease_id, count in pairs(diseases) do
                    if #slots >= effective_slots then break end
                    if disease_id == HEALTHY or count == 0 then goto next_disease end
                    if not disease_values[disease_id].is_treatable then goto next_disease end
                    local current_claims = (claims and claims[disease_id]) and #claims[disease_id] or 0
                    if current_claims >= count then goto next_disease end

                    if not claims then
                        housing[EK.treatment_claims] = {}
                        claims = housing[EK.treatment_claims]
                    end
                    claims[disease_id] = claims[disease_id] or {}
                    claims[disease_id][#claims[disease_id] + 1] = unit_number
                    slots[#slots + 1] = {uid = housing[EK.unit_number], disease_id = disease_id}
                    ::next_disease::
                end
            end
        end
    end

    -- treat each claimed (housing, disease) slot
    if performance > 0 and #slots > 0 then
        local work_per_slot = performance * delta_ticks * building_details.speed
        local inventories = Entity.get_hospital_inventories(entry)
        local statistics = entry[EK.treated]

        for _, slot in pairs(slots) do
            local housing = try_get(slot.uid)
            if housing then
                treat_disease_slot(entry, housing, slot.disease_id, inventories, work_per_slot, statistics)
            end
        end
    end
end

Register.set_entity_updater(Type.hospital, update_hospital)
Register.set_entity_updater(Type.improvised_hospital, update_hospital)

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

    if source[EK.slots] and type(source[EK.slots][1]) == "table" then
        -- current per-disease slot format: preserve
        destination[EK.slots] = Table.copy(source[EK.slots])
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
