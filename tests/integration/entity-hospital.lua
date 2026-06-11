local EK = require("enums.entry-key")
local Type = require("enums.type")

local Diseases = require("constants.diseases")
local InhabitantsConstants = require("constants.inhabitants")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local Hospital = Entity.Hospital

-- Disease 99001 (test-disease-simple): treatable, no cure items, workload 1
-- Disease 99002 (test-disease-with-items): treatable, cure_items = {bandage = 1}, workload 1
-- Disease 99003 (test-disease-untreatable): is_treatable = false
local DISEASE_NO_ITEMS = 99001
local DISEASE_WITH_ITEMS = 99002
local DISEASE_UNTREATABLE = 99003

local disease_no_items = Diseases.values[DISEASE_NO_ITEMS]
local disease_with_items = Diseases.values[DISEASE_WITH_ITEMS]

local test_surface

local function setup()
    test_surface = Helpers.create_test_surface()
    Helpers.reset_inhabitants_state()
    storage.technologies["upbringing"] = 1
end

local function teardown()
    Helpers.clean_up()
end

local function make_hospital(position)
    return Helpers.create_and_register(test_surface, "test-hospital-no-workforce", position)
end

local function make_sick_house(position, disease_id, count)
    local entry = Helpers.create_inhabited_house(test_surface, position, Type.clockwork, count or 1)
    entry[EK.has_food] = true
    entry[EK.has_water] = true
    DiseaseGroup.make_sick(entry[EK.diseases], disease_id, count or 1)
    return entry
end

---------------------------------------------------------------------------------------------------
-- << Hospital.can_treat >>

Tirislib.Testing.add_test_case(
    "can_treat returns true for a treatable disease with no facility requirement",
    "integration|integration.hospital",
    function()
        local hospital = make_hospital({0, 0})
        Assert.is_true(Hospital.can_treat(hospital, DISEASE_NO_ITEMS), "treatable disease with no facility")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "can_treat returns false for an untreatable disease",
    "integration|integration.hospital",
    function()
        local hospital = make_hospital({0, 0})
        Assert.is_false(Hospital.can_treat(hospital, DISEASE_UNTREATABLE), "untreatable disease")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "can_treat returns false when treatment_permissions explicitly disables a disease",
    "integration|integration.hospital",
    function()
        local hospital = make_hospital({0, 0})
        hospital[EK.treatment_permissions][DISEASE_NO_ITEMS] = false
        Assert.is_false(Hospital.can_treat(hospital, DISEASE_NO_ITEMS), "disabled via permissions")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << slot claiming >>

Tirislib.Testing.add_test_case(
    "hospital claims a sick citizen and sets treatment_claims on the house",
    "integration|integration.hospital",
    function()
        local hospital = make_hospital({0, 0})
        local house = make_sick_house({5, 0}, DISEASE_NO_ITEMS, 1)

        Helpers.update_entry(hospital)

        local slots = hospital[EK.slots]
        Assert.equals(#slots, 1, "one slot should be claimed")
        Assert.equals(slots[1].uid, house[EK.unit_number], "slot should reference the house")
        Assert.equals(slots[1].disease_id, DISEASE_NO_ITEMS, "slot disease_id should match")

        local claims = house[EK.treatment_claims]
        Assert.not_nil(claims, "treatment_claims should be set on house")
        Assert.not_nil(claims[DISEASE_NO_ITEMS], "claims for the disease should exist")
        Assert.equals(#claims[DISEASE_NO_ITEMS], 1, "exactly one claim")
        Assert.equals(claims[DISEASE_NO_ITEMS][1], hospital[EK.unit_number], "claim references hospital uid")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "hospital does not claim more slots than its capacity",
    "integration|integration.hospital",
    function()
        local hospital = make_hospital({0, 0})
        -- test-hospital-no-workforce has 5 slots; create 6 sick houses
        for i = 1, 6 do
            make_sick_house({5 * i, 0}, DISEASE_NO_ITEMS, 1)
        end

        Helpers.update_entry(hospital)

        Assert.equals(#hospital[EK.slots], 5, "should not exceed 5 slots")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "hospital skips disease disabled via treatment_permissions",
    "integration|integration.hospital",
    function()
        local hospital = make_hospital({0, 0})
        hospital[EK.treatment_permissions][DISEASE_NO_ITEMS] = false
        make_sick_house({5, 0}, DISEASE_NO_ITEMS, 1)

        Helpers.update_entry(hospital)

        Assert.equals(#hospital[EK.slots], 0, "disabled disease should not be claimed")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "hospital does not claim disease when cure items are missing",
    "integration|integration.hospital",
    function()
        local hospital = make_hospital({0, 0})
        make_sick_house({5, 0}, DISEASE_WITH_ITEMS, 1)
        -- hospital inventory is empty - no bandages

        Helpers.update_entry(hospital)

        Assert.equals(#hospital[EK.slots], 0, "no slot without cure items")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "hospital claims disease and consumes cure items upfront",
    "integration|integration.hospital",
    function()
        local hospital = make_hospital({0, 0})
        make_sick_house({5, 0}, DISEASE_WITH_ITEMS, 1)
        local inv = hospital[EK.entity].get_inventory(defines.inventory.chest)
        inv.insert({name = "bandage", count = 5})

        Helpers.update_entry(hospital)

        Assert.equals(#hospital[EK.slots], 1, "slot should be claimed")
        local bandages_remaining = inv.get_item_count("bandage")
        local expected = 5 - disease_with_items.cure_items["bandage"]
        Assert.equals(bandages_remaining, expected, "cure items consumed on claim")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << stale slot pruning >>

Tirislib.Testing.add_test_case(
    "stale slot is released when the citizen has been cured externally",
    "integration|integration.hospital",
    function()
        local hospital = make_hospital({0, 0})
        local house = make_sick_house({5, 0}, DISEASE_NO_ITEMS, 1)
        Helpers.update_entry(hospital)
        Assert.equals(#hospital[EK.slots], 1, "slot should exist after first update")

        -- cure the disease externally (simulate natural recovery or another cure)
        DiseaseGroup.cure(house[EK.diseases], DISEASE_NO_ITEMS, 1)

        Helpers.update_entry(hospital)

        Assert.equals(#hospital[EK.slots], 0, "stale slot should be pruned on next update")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "stale slot is released when the housing entry is destroyed",
    "integration|integration.hospital",
    function()
        local hospital = make_hospital({0, 0})
        local house = make_sick_house({5, 0}, DISEASE_NO_ITEMS, 1)
        Helpers.update_entry(hospital)
        Assert.equals(#hospital[EK.slots], 1, "slot should exist after first update")

        Helpers.destroy_entry(house)

        Helpers.update_entry(hospital)

        Assert.equals(#hospital[EK.slots], 0, "slot for destroyed house should be pruned")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << treatment / work accumulation >>

Tirislib.Testing.add_test_case(
    "work accumulates across ticks and cures disease when workload is reached",
    "integration|integration.hospital",
    function()
        -- disease_no_items has curing_workload = 1; test-hospital-no-workforce speed = 20/60 per tick
        -- ceil(1 / (20/60)) = 3 update calls needed to reach workload
        local hospital = make_hospital({0, 0})
        local house = make_sick_house({5, 0}, DISEASE_NO_ITEMS, 1)

        Helpers.update_entry(hospital) -- claims slot, first work increment
        local count_after_one = house[EK.diseases][DISEASE_NO_ITEMS] or 0
        Assert.equals(count_after_one, 1, "disease still present after one tick")

        Helpers.update_entry(hospital)
        Helpers.update_entry(hospital)

        local count_after_cure = house[EK.diseases][DISEASE_NO_ITEMS] or 0
        Assert.equals(count_after_cure, 0, "disease should be cured after workload reached")
        Assert.equals(#hospital[EK.slots], 0, "slot released immediately on cure, within the same update")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "treated statistics counter increments when a disease is cured",
    "integration|integration.hospital",
    function()
        local hospital = make_hospital({0, 0})
        make_sick_house({5, 0}, DISEASE_NO_ITEMS, 1)

        Helpers.update_entry(hospital)
        Helpers.update_entry(hospital)
        Helpers.update_entry(hospital)

        local treated = hospital[EK.treated]
        Assert.not_nil(treated[DISEASE_NO_ITEMS], "treated counter should exist for the disease")
        Assert.equals(treated[DISEASE_NO_ITEMS], 1, "one cure should be recorded")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << Hospital.try_blood_donation >>

Tirislib.Testing.add_test_case(
    "try_blood_donation returns false when hospital is inactive",
    "integration|integration.hospital",
    function()
        local hospital = make_hospital({0, 0})
        local house = Helpers.create_and_register(test_surface, "test-house", {5, 0})
        -- active is nil after creation; do not call update_entry so it stays falsy
        Assert.is_false(Hospital.try_blood_donation(hospital, house), "inactive hospital should refuse")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "try_blood_donation returns false when no surgery-instruments available",
    "integration|integration.hospital",
    function()
        local hospital = make_hospital({0, 0})
        local house = Helpers.create_and_register(test_surface, "test-house", {5, 0})
        Helpers.update_entry(hospital) -- sets active = true
        Assert.is_false(Hospital.try_blood_donation(hospital, house), "should refuse without instruments")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "try_blood_donation accepts, adds slot, and consumes surgery-instruments",
    "integration|integration.hospital",
    function()
        local hospital = make_hospital({0, 0})
        local house = Helpers.create_and_register(test_surface, "test-house", {5, 0})
        Helpers.update_entry(hospital)
        local inv = hospital[EK.entity].get_inventory(defines.inventory.chest)
        inv.insert({name = "surgery-instruments", count = 3})

        local accepted = Hospital.try_blood_donation(hospital, house)

        Assert.is_true(accepted, "should accept when active and instruments available")
        Assert.equals(#hospital[EK.donation_slots], 1, "one blood donation slot should be added")
        Assert.equals(hospital[EK.donation_slots][1].uid, house[EK.unit_number], "slot uid should match house")
        local cost = InhabitantsConstants.blood_donation_medical_instruments_cost
        Assert.equals(inv.get_item_count("surgery-instruments"), 3 - cost, "surgery-instruments should be consumed")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "try_blood_donation returns false when free slots do not exceed blood_donation_threshold",
    "integration|integration.hospital",
    function()
        -- test-hospital-no-workforce has 5 slots
        -- threshold = 2 means the hospital needs > 2 free slots to accept; with 3 slots occupied,
        -- free_slots = 2 which is not > 2
        local hospital = make_hospital({0, 0})
        local house = Helpers.create_and_register(test_surface, "test-house", {5, 0})
        Helpers.update_entry(hospital)
        local inv = hospital[EK.entity].get_inventory(defines.inventory.chest)
        inv.insert({name = "surgery-instruments", count = 5})

        hospital[EK.blood_donation_threshold] = 2
        hospital[EK.donation_slots][1] = {work_done = 0, uid = 0}
        hospital[EK.donation_slots][2] = {work_done = 0, uid = 0}
        hospital[EK.donation_slots][3] = {work_done = 0, uid = 0}

        Assert.is_false(Hospital.try_blood_donation(hospital, house), "should refuse when free_slots <= threshold")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << blood donation slot processing >>

Tirislib.Testing.add_test_case(
    "blood donation slot produces blood bag and is removed when workload is reached",
    "integration|integration.hospital",
    function()
        -- workload = 10, speed = 20/60 per tick -> 30 update calls to complete
        local hospital = make_hospital({0, 0})
        local house = Helpers.create_and_register(test_surface, "test-house", {5, 0})
        Helpers.update_entry(hospital) -- sets active = true
        local inv = hospital[EK.entity].get_inventory(defines.inventory.chest)
        inv.insert({name = "surgery-instruments", count = 1})

        Hospital.try_blood_donation(hospital, house)
        Assert.equals(#hospital[EK.donation_slots], 1, "blood donation slot should exist before processing")

        for _ = 1, 30 do
            Helpers.update_entry(hospital)
        end

        Assert.equals(#hospital[EK.donation_slots], 0, "completed slot should be removed immediately on completion")
        Assert.equals(hospital[EK.blood_donations], 1, "blood_donations counter should be incremented")
        local item = InhabitantsConstants.blood_donation_item
        Assert.is_true(inv.get_item_count(item) > 0, "blood bag should be produced into hospital inventory")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << copy_hospital >>

Tirislib.Testing.add_test_case(
    "clone copies treated, permissions, blood_donations, blood_donation_threshold, and slots",
    "integration|integration.hospital",
    function()
        local source = make_hospital({0, 0})
        source[EK.treated] = {[DISEASE_NO_ITEMS] = 3}
        source[EK.treatment_permissions] = {[DISEASE_WITH_ITEMS] = false}
        source[EK.blood_donations] = 7
        source[EK.blood_donation_threshold] = 2
        source[EK.donation_slots] = {{work_done = 0, uid = 0}}

        local dest_entity = Helpers.create_unregistered(test_surface, "test-hospital-no-workforce", {10, 0})
        local dest = Register.clone(source, dest_entity)

        Assert.equals(dest[EK.treated][DISEASE_NO_ITEMS], 3, "treated counter should be copied")
        Assert.is_false(dest[EK.treatment_permissions][DISEASE_WITH_ITEMS], "permission should be copied")
        Assert.equals(dest[EK.blood_donations], 7, "blood_donations should be copied")
        Assert.equals(dest[EK.blood_donation_threshold], 2, "blood_donation_threshold should be copied")
        Assert.equals(#dest[EK.donation_slots], 1, "donation slots should be copied")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "clone produces an independent copy - mutating source does not affect destination",
    "integration|integration.hospital",
    function()
        local source = make_hospital({0, 0})
        source[EK.treated] = {[DISEASE_NO_ITEMS] = 1}

        local dest_entity = Helpers.create_unregistered(test_surface, "test-hospital-no-workforce", {10, 0})
        local dest = Register.clone(source, dest_entity)

        source[EK.treated][DISEASE_NO_ITEMS] = 99
        Assert.equals(dest[EK.treated][DISEASE_NO_ITEMS], 1, "mutation of source should not affect destination")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << paste_hospital_settings >>

Tirislib.Testing.add_test_case(
    "pasting settings copies blood_donation_threshold to destination",
    "integration|integration.hospital",
    function()
        local source = make_hospital({0, 0})
        local dest = make_hospital({10, 0})
        source[EK.blood_donation_threshold] = 3
        dest[EK.blood_donation_threshold] = 0

        Register.on_settings_pasted(Type.hospital, source, Type.hospital, dest, {})

        Assert.equals(dest[EK.blood_donation_threshold], 3, "blood_donation_threshold should be pasted")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << claim lifecycle: hospital destruction and inactivity >>

local function make_hospital_with_workforce(position)
    return Helpers.create_and_register(test_surface, "test-hospital-workforce-no-power", position)
end

Tirislib.Testing.add_test_case(
    "destroying the hospital releases its claims from the housing entry",
    "integration|integration.hospital",
    function()
        local hospital = make_hospital({0, 0})
        local house = make_sick_house({5, 0}, DISEASE_NO_ITEMS, 1)
        Helpers.update_entry(hospital)

        Assert.not_nil(house[EK.treatment_claims], "claims should exist before destruction")

        Helpers.destroy_entry(hospital)

        local claims = house[EK.treatment_claims]
        local disease_claims = claims and claims[DISEASE_NO_ITEMS]
        Assert.is_true(
            disease_claims == nil or #disease_claims == 0,
            "destroyed hospital should no longer appear in housing claims"
        )
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "hospital going inactive drops its slots on the next update",
    "integration|integration.hospital",
    function()
        local hospital = make_hospital_with_workforce({0, 0})
        local house = make_sick_house({5, 0}, DISEASE_NO_ITEMS, 1)

        hospital[EK.worker_count] = 20
        Helpers.update_entry(hospital)
        Assert.equals(#hospital[EK.slots], 1, "slot should be claimed while active")

        hospital[EK.worker_count] = 0
        Helpers.update_entry(hospital)
        Assert.equals(#hospital[EK.slots], 0, "slots should be cleared when hospital goes inactive")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "hospital going inactive releases its claims from housing",
    "integration|integration.hospital",
    function()
        local hospital = make_hospital_with_workforce({0, 0})
        local house = make_sick_house({5, 0}, DISEASE_NO_ITEMS, 1)

        hospital[EK.worker_count] = 20
        Helpers.update_entry(hospital)
        Assert.not_nil(house[EK.treatment_claims], "claims should be set before inactivity")

        hospital[EK.worker_count] = 0
        Helpers.update_entry(hospital)

        local claims = house[EK.treatment_claims]
        local disease_claims = claims and claims[DISEASE_NO_ITEMS]
        Assert.is_true(
            disease_claims == nil or #disease_claims == 0,
            "inactive hospital should no longer appear in housing claims"
        )
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "hospital re-claims after recovering from inactivity",
    "integration|integration.hospital",
    function()
        local hospital = make_hospital_with_workforce({0, 0})
        local house = make_sick_house({5, 0}, DISEASE_NO_ITEMS, 1)

        hospital[EK.worker_count] = 20
        Helpers.update_entry(hospital)
        Assert.equals(#hospital[EK.slots], 1, "slot claimed while active")

        hospital[EK.worker_count] = 0
        Helpers.update_entry(hospital)
        Assert.equals(#hospital[EK.slots], 0, "slots dropped while inactive")

        hospital[EK.worker_count] = 20
        Helpers.update_entry(hospital)
        Assert.equals(#hospital[EK.slots], 1, "slot re-claimed after recovering from inactivity")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << trim-to-capacity >>

Tirislib.Testing.add_test_case(
    "slots exceeding building capacity are trimmed on the next update",
    "integration|integration.hospital",
    function()
        -- test-hospital-no-workforce has 5 slots; stuff 7 to simulate an unexpected excess
        -- blood donation slots survive stale validation as long as the target is registered
        local hospital = make_hospital({0, 0})
        local house = Helpers.create_and_register(test_surface, "test-house", {5, 0})
        local uid = house[EK.unit_number]

        for i = 1, 7 do
            hospital[EK.donation_slots][i] = {work_done = 0, uid = uid}
        end

        Helpers.update_entry(hospital)

        Assert.equals(#hospital[EK.donation_slots], 5, "donation slots should be trimmed to building capacity")
    end,
    setup,
    teardown
)
