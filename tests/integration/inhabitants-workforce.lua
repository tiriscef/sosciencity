local EK = require("enums.entry-key")
local Type = require("enums.type")
local Buildings = require("constants.buildings")
local Castes = require("constants.castes")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface

Tirislib.Testing.add_test_case(
    "update_workforce hires workers from nearby housing",
    "integration|integration.inhabitants",
    function()
        local original_tech = storage.technologies["plasma-caste"]
        storage.technologies["plasma-caste"] = 1

        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.plasma, 20)
        local hospital = Helpers.create_and_register(test_surface, "test-hospital", {5, 0})
        local workforce = Buildings.get(hospital).workforce

        Inhabitants.update_workforce(hospital, workforce)

        Assert.greater_than(hospital[EK.worker_count], 0, "hospital should have hired workers")

        storage.technologies["plasma-caste"] = original_tech
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "evaluate_workforce returns 0 with no workers",
    "integration|integration.inhabitants",
    function()
        local original_tech = storage.technologies["plasma-caste"]
        storage.technologies["plasma-caste"] = 1

        local hospital = Helpers.create_and_register(test_surface, "test-hospital", {0, 0})

        local ratio = Inhabitants.evaluate_workforce(hospital)

        Assert.equals(ratio, 0, "workforce ratio should be 0 with no workers")

        storage.technologies["plasma-caste"] = original_tech
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "evaluate_workforce reflects partial workforce",
    "integration|integration.inhabitants",
    function()
        local original_tech = storage.technologies["plasma-caste"]
        storage.technologies["plasma-caste"] = 1

        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.plasma, 5)
        local hospital = Helpers.create_and_register(test_surface, "test-hospital", {5, 0})
        local workforce = Buildings.get(hospital).workforce

        Inhabitants.update_workforce(hospital, workforce)

        local ratio = Inhabitants.evaluate_workforce(hospital)

        Assert.greater_than(ratio, 0, "workforce ratio should be above 0")
        Assert.less_than(ratio, 1, "workforce ratio should be below 1 with only 5 of 20 workers")

        storage.technologies["plasma-caste"] = original_tech
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "unemploy_all_workers clears all employment",
    "integration|integration.inhabitants",
    function()
        local original_tech = storage.technologies["plasma-caste"]
        storage.technologies["plasma-caste"] = 1

        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.plasma, 20)
        local hospital = Helpers.create_and_register(test_surface, "test-hospital", {5, 0})
        local workforce = Buildings.get(hospital).workforce

        Inhabitants.update_workforce(hospital, workforce)
        Assert.greater_than(hospital[EK.worker_count], 0, "should have hired workers before clearing")

        Inhabitants.unemploy_all_workers(hospital)

        Assert.equals(hospital[EK.worker_count], 0, "worker_count should be 0 after unemploy_all")
        Assert.equals(Tirislib.Tables.count(hospital[EK.workers]), 0, "workers table should be empty")
        Assert.equals(house[EK.employed], 0, "house employed count should be 0")

        storage.technologies["plasma-caste"] = original_tech
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "get_employable_count decreases after employment",
    "integration|integration.inhabitants",
    function()
        local original_tech = storage.technologies["plasma-caste"]
        storage.technologies["plasma-caste"] = 1

        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.plasma, 10)

        local before = Inhabitants.get_employable_count(house)
        Assert.equals(before, 10, "all 10 inhabitants should be employable before hiring")

        local hospital = Helpers.create_and_register(test_surface, "test-hospital", {5, 0})
        local workforce = Buildings.get(hospital).workforce

        Inhabitants.update_workforce(hospital, workforce)

        local after = Inhabitants.get_employable_count(house)
        Assert.less_than(after, before, "employable count should decrease after hiring")

        storage.technologies["plasma-caste"] = original_tech
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Workers are not hired from wrong caste",
    "integration|integration.inhabitants",
    function()
        local original_plasma = storage.technologies["plasma-caste"]
        local original_upbringing = storage.technologies["upbringing"]
        storage.technologies["plasma-caste"] = 1
        storage.technologies["upbringing"] = 1

        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 20)
        local hospital = Helpers.create_and_register(test_surface, "test-hospital", {5, 0})
        local workforce = Buildings.get(hospital).workforce

        Inhabitants.update_workforce(hospital, workforce)

        Assert.equals(hospital[EK.worker_count], 0, "hospital should not hire clockwork workers (needs plasma)")

        storage.technologies["plasma-caste"] = original_plasma
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
-- << strike >>

Tirislib.Testing.add_test_case(
    "get_employable_count returns 0 for fully striking Ember house",
    "integration|integration.inhabitants",
    function()
        local original_tech = storage.technologies["upbringing"]
        storage.technologies["upbringing"] = 1

        -- Ember has full_strike_worker_fraction = 0, so no one works at full strike
        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.ember, 10)
        house[EK.strike_level] = 1

        Assert.equals(Inhabitants.get_employable_count(house), 0,
            "fully striking Ember house should have 0 employable inhabitants")

        storage.technologies["upbringing"] = original_tech
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "get_employable_count keeps minimum fraction for fully striking Orchid house",
    "integration|integration.inhabitants",
    function()
        local original_tech = storage.technologies["upbringing"]
        storage.technologies["upbringing"] = 1

        -- Orchid has full_strike_worker_fraction = 0.2, so 20% still work at full strike
        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.orchid, 10)
        house[EK.strike_level] = 1

        local employable = Inhabitants.get_employable_count(house)
        Assert.greater_than(employable, 0, "fully striking Orchid house should still have some willing workers")
        Assert.less_than(employable, 10, "fully striking Orchid house should not have all inhabitants willing")

        storage.technologies["upbringing"] = original_tech
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Employed Ember workers are fully fired when house goes on full strike",
    "integration|integration.inhabitants",
    function()
        local original_tech = storage.technologies["upbringing"]
        storage.technologies["upbringing"] = 1

        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.ember, 10)
        local manufactory = Helpers.create_and_register(test_surface, "test-ember-manufactory", {5, 0})
        local workforce = Buildings.get(manufactory).workforce

        Inhabitants.update_workforce(manufactory, workforce)
        Assert.greater_than(manufactory[EK.worker_count], 0, "should have hired workers before strike")

        -- force happiness below full_strike_threshold (Ember: 2) and run update
        local caste = Castes.values[Type.ember]
        house[EK.happiness] = caste.full_strike_threshold - 1
        Register.update_entry(house, game.tick + 100)

        Assert.equals(house[EK.strike_level], 1, "strike level should be 1 at full strike")
        Assert.equals(manufactory[EK.worker_count], 0, "building should lose all Ember workers at full strike")
        Assert.equals(house[EK.employed], 0, "house employed count should be 0 after full Ember strike")

        storage.technologies["upbringing"] = original_tech
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Orchid minimum fraction workers remain employed during full strike",
    "integration|integration.inhabitants",
    function()
        local original_tech = storage.technologies["upbringing"]
        storage.technologies["upbringing"] = 1

        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.orchid, 10)
        local manufactory = Helpers.create_and_register(test_surface, "test-orchid-manufactory", {5, 0})
        local workforce = Buildings.get(manufactory).workforce

        Inhabitants.update_workforce(manufactory, workforce)
        Assert.greater_than(manufactory[EK.worker_count], 0, "should have hired workers before strike")

        -- force happiness below full_strike_threshold (Orchid: 1) and run update
        local caste = Castes.values[Type.orchid]
        house[EK.happiness] = caste.full_strike_threshold - 1
        Register.update_entry(house, game.tick + 100)

        Assert.equals(house[EK.strike_level], 1, "strike level should be 1 at full strike")
        Assert.greater_than(manufactory[EK.worker_count], 0, "building should keep some Orchid workers (min fraction)")
        Assert.greater_than(house[EK.employed], 0, "house should still have some employed at Orchid min fraction")

        storage.technologies["upbringing"] = original_tech
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)
