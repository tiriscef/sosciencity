local EK = require("enums.entry-key")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface

local function setup()
    test_surface = Helpers.create_test_surface()
    storage.active_animal_farms = 0
end

local function clean_up()
    Helpers.clean_up()
    storage.active_animal_farms = 0
end

---------------------------------------------------------------------------------------------------
-- << animal farm creation >>

Tirislib.Testing.add_test_case(
    "Animal farm creation initializes houses_animals to false",
    "integration|integration.animal-farm",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-animal-farm", {0, 0})

        Assert.equals(entry[EK.houses_animals], false)
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << update_animal_farm: counter transitions >>

Tirislib.Testing.add_test_case(
    "Update with no recipe: houses_animals stays false and counter unchanged",
    "integration|integration.animal-farm",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-animal-farm", {0, 0})
        Helpers.update_entry(entry)

        Assert.equals(entry[EK.houses_animals], false)
        Assert.equals(storage.active_animal_farms, 0)
    end,
    setup,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Active husbandry recipe transitions houses_animals to true and increments counter",
    "integration|integration.animal-farm",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-animal-farm", {0, 0})
        entry[EK.entity].set_recipe("sos-husbandry-null")
        Helpers.update_entry(entry)

        Assert.equals(entry[EK.houses_animals], true)
        Assert.equals(storage.active_animal_farms, 1)
    end,
    setup,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Removing recipe transitions houses_animals from true to false and decrements counter",
    "integration|integration.animal-farm",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-animal-farm", {0, 0})
        -- simulate a previously active state
        entry[EK.houses_animals] = true
        storage.active_animal_farms = 1

        Helpers.update_entry(entry)

        Assert.equals(entry[EK.houses_animals], false)
        Assert.equals(storage.active_animal_farms, 0)
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << remove_animal_farm: destruction >>

Tirislib.Testing.add_test_case(
    "Destruction while housing animals decrements counter",
    "integration|integration.animal-farm",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-animal-farm", {0, 0})
        entry[EK.houses_animals] = true
        storage.active_animal_farms = 1

        Helpers.destroy_entry(entry)

        Assert.equals(storage.active_animal_farms, 0)
    end,
    setup,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Destruction while not housing animals leaves counter unchanged",
    "integration|integration.animal-farm",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-animal-farm", {0, 0})
        storage.active_animal_farms = 3

        Helpers.destroy_entry(entry)

        Assert.equals(storage.active_animal_farms, 3)
    end,
    setup,
    clean_up
)
