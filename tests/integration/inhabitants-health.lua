local EK = require("enums.entry-key")
local Type = require("enums.type")
local SubentityType = require("enums.subentity-type")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface

---------------------------------------------------------------------------------------------------
-- << disease group basics >>

Tirislib.Testing.add_test_case(
    "Making inhabitants sick reduces healthy count",
    "integration|integration.inhabitants",
    function()
        local original_upbringing = storage.technologies["upbringing"]
        storage.technologies["upbringing"] = 1

        local entry = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 20)
        local diseases = entry[EK.diseases]

        DiseaseGroup.make_sick(diseases, 1, 5)

        Assert.equals(diseases[DiseaseGroup.HEALTHY], 15, "healthy count should be 15 after sickening 5")
        Assert.equals(diseases[1], 5, "disease 1 count should be 5")

        storage.technologies["upbringing"] = original_upbringing
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Curing inhabitants restores healthy count",
    "integration|integration.inhabitants",
    function()
        local original_upbringing = storage.technologies["upbringing"]
        storage.technologies["upbringing"] = 1

        local entry = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 20)
        local diseases = entry[EK.diseases]

        DiseaseGroup.make_sick(diseases, 1, 5)
        DiseaseGroup.cure(diseases, 1, 3)

        Assert.equals(diseases[DiseaseGroup.HEALTHY], 18, "healthy count should be 18 after curing 3 of 5")
        Assert.equals(diseases[1], 2, "disease 1 count should be 2 after curing 3 of 5")

        storage.technologies["upbringing"] = original_upbringing
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "get_nominal_health returns a number",
    "integration|integration.inhabitants",
    function()
        local original_upbringing = storage.technologies["upbringing"]
        storage.technologies["upbringing"] = 1

        local entry = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 10)

        local health = Inhabitants.get_nominal_health(entry)
        Assert.not_nil(health, "get_nominal_health should return a value")
        Assert.equals(type(health), "number", "get_nominal_health should return a number")

        storage.technologies["upbringing"] = original_upbringing
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

---------------------------------------------------------------------------------------------------
-- << hospital >>

Tirislib.Testing.add_test_case(
    "Hospital accumulates workhours when staffed",
    "integration|integration.inhabitants",
    function()
        local original_upbringing = storage.technologies["upbringing"]
        local original_plasma = storage.technologies["plasma-caste"]
        storage.technologies["upbringing"] = 1
        storage.technologies["plasma-caste"] = 1

        -- create hospital and a plasma house nearby to supply workforce
        local hospital_entry = Helpers.create_and_register(test_surface, "test-hospital", {0, 0})
        Helpers.create_inhabited_house(test_surface, {3, 0}, Type.plasma, 20)

        -- fill the EEI energy buffer so the hospital has power
        local eei = hospital_entry[EK.subentities][SubentityType.eei]
        eei.energy = eei.electric_buffer_size

        -- hire workers
        Register.update_entry(hospital_entry, game.tick + 100)

        Assert.greater_than(hospital_entry[EK.workhours], 0, "hospital should have accumulated workhours")

        storage.technologies["upbringing"] = original_upbringing
        storage.technologies["plasma-caste"] = original_plasma
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

---------------------------------------------------------------------------------------------------
-- << multiple diseases >>

Tirislib.Testing.add_test_case(
    "Disease group tracks multiple diseases independently",
    "integration|integration.inhabitants",
    function()
        local original_upbringing = storage.technologies["upbringing"]
        storage.technologies["upbringing"] = 1

        local entry = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 20)
        local diseases = entry[EK.diseases]

        -- make 3 sick with disease 1 and 2 sick with disease 2
        DiseaseGroup.make_sick(diseases, 1, 3)
        DiseaseGroup.make_sick(diseases, 2, 2)

        Assert.equals(diseases[DiseaseGroup.HEALTHY], 15, "healthy should be 15 after sickening 3+2")
        Assert.equals(diseases[1], 3, "disease 1 count should be 3")
        Assert.equals(diseases[2], 2, "disease 2 count should be 2")

        -- cure all of disease 1
        DiseaseGroup.cure(diseases, 1, 3)

        Assert.is_nil(diseases[1], "disease 1 should be nil after full cure")
        Assert.equals(diseases[2], 2, "disease 2 should still be 2")
        Assert.equals(diseases[DiseaseGroup.HEALTHY], 18, "healthy should be 18 after curing disease 1")

        storage.technologies["upbringing"] = original_upbringing
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)
