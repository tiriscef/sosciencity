local EK = require("enums.entry-key")
local Type = require("enums.type")

local Helpers = require("tests.integration.helpers")
local DiseaseGroup = require("classes.groups.disease-group")
local Register = require("classes.register")
local Assert = Tirislib.Testing.Assert

-- Disease 99001 (test-disease-simple): treatable, no cure items
local DISEASE = 99001

local test_surface

local function setup()
    test_surface = Helpers.create_test_surface()
    Helpers.reset_inhabitants_state()
    storage.technologies["upbringing"] = 1
end

local function teardown()
    Helpers.clean_up()
end

---------------------------------------------------------------------------------------------------
-- << Register.rebuild_all >>

Tirislib.Testing.add_test_case(
    "rebuild_all registers the entities again",
    "integration|integration.register",
    function()
        local hospital = Helpers.create_and_register(test_surface, "test-hospital-no-workforce", {0, 0})
        local entity = hospital[EK.entity]

        Register.rebuild_all()

        local rebuilt = Register.try_get(entity.unit_number)
        Assert.not_nil(rebuilt, "the hospital should be registered again")
        Assert.unequal(rebuilt, hospital, "the hospital should get a new entry")
        Assert.equals(rebuilt[EK.type], Type.hospital)
    end,
    setup,
    teardown
)

-- An entity can vanish without an event, e.g. when the mod that defines its prototype is removed.
-- Removing the hospital releases its beds and looks the patient up with try_get, which removes the house entry
-- on the way. The rebuild loop then reaches that entry again.
Tirislib.Testing.add_test_case(
    "rebuild_all skips entries that another removal already took out",
    "integration|integration.register",
    function()
        -- created first, so the loop removes the hospital before the house
        local hospital = Helpers.create_and_register(test_surface, "test-hospital-no-workforce", {0, 0})
        local hospital_entity = hospital[EK.entity]
        local house = Helpers.create_inhabited_house(test_surface, {5, 0}, Type.clockwork, 1)
        house[EK.has_food] = true
        house[EK.has_water] = true
        DiseaseGroup.make_sick(house[EK.diseases], DISEASE, 1)
        local house_unit_number = house[EK.unit_number]

        Helpers.update_entry(hospital)
        Assert.equals(#hospital[EK.slots], 1, "precondition: the hospital has a bed for the house")

        house[EK.entity].destroy() -- no event, like a prototype that vanished with its mod

        local ok, err = pcall(Register.rebuild_all)
        Assert.is_true(ok, "rebuild_all should not fail: " .. tostring(err))
        Assert.is_nil(storage.register[house_unit_number], "the house without entity should be gone")
        Assert.not_nil(Register.try_get(hospital_entity.unit_number), "the hospital should be registered again")
    end,
    setup,
    teardown
)
