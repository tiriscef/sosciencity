local EK = require("enums.entry-key")
local Type = require("enums.type")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface

local function setup()
    test_surface = Helpers.create_test_surface()
end

local function clean_up()
    Helpers.clean_up()
end

---------------------------------------------------------------------------------------------------
-- << creation >>

Tirislib.Testing.add_test_case(
    "Kitchen creation initializes participating_inhabitants to 0",
    "integration|integration.kitchen",
    function()
        local kitchen = Helpers.create_and_register(test_surface, "test-kitchen-for-all", {0, 0})

        Assert.equals(kitchen[EK.participating_inhabitants], 0)
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << update_kitchen_for_all >>

Tirislib.Testing.add_test_case(
    "Kitchen update with no houses in range keeps participating_inhabitants at 0",
    "integration|integration.kitchen",
    function()
        local kitchen = Helpers.create_and_register(test_surface, "test-kitchen-for-all", {0, 0})
        Helpers.update_entry(kitchen)

        Assert.equals(kitchen[EK.participating_inhabitants], 0)
    end,
    setup,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Kitchen counts inhabitants from neighboring houses",
    "integration|integration.kitchen",
    function()
        local kitchen = Helpers.create_and_register(test_surface, "test-kitchen-for-all", {0, 0})
        Helpers.create_inhabited_house(test_surface, {5, 0}, Type.ember, 10)
        Helpers.update_entry(kitchen)

        Assert.equals(kitchen[EK.participating_inhabitants], 10)
    end,
    setup,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Two active kitchens in range split inhabitants equally between them",
    "integration|integration.kitchen",
    function()
        local kitchen1 = Helpers.create_and_register(test_surface, "test-kitchen-for-all", {0, 0})
        local kitchen2 = Helpers.create_and_register(test_surface, "test-kitchen-for-all", {5, 0})
        Helpers.create_inhabited_house(test_surface, {10, 0}, Type.ember, 10)

        kitchen2[EK.active] = true  -- kitchen2 is already active this cycle
        Helpers.update_entry(kitchen1)

        Assert.equals(kitchen1[EK.participating_inhabitants], 5)
    end,
    setup,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Inactive other kitchen does not reduce participating_inhabitants",
    "integration|integration.kitchen",
    function()
        local kitchen1 = Helpers.create_and_register(test_surface, "test-kitchen-for-all", {0, 0})
        local kitchen2 = Helpers.create_and_register(test_surface, "test-kitchen-for-all", {5, 0})
        Helpers.create_inhabited_house(test_surface, {10, 0}, Type.ember, 10)

        kitchen2[EK.active] = false
        Helpers.update_entry(kitchen1)

        Assert.equals(kitchen1[EK.participating_inhabitants], 10)
    end,
    setup,
    clean_up
)
