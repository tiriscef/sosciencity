local EK = require("enums.entry-key")

local DrinkingWater = require("constants.drinking-water")
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
    "Water distributer creation with empty tank sets water_quality to -1000 and water_name to nil",
    "integration|integration.water-distributer",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-water-distributer", {0, 0})

        Assert.equals(entry[EK.water_quality], -1000, "water_quality should be -1000 for empty tank")
        Assert.is_nil(entry[EK.water_name], "water_name should be nil for empty tank")
    end,
    setup,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Water distributer creation with pre-filled recognized water sets correct water_quality and water_name",
    "integration|integration.water-distributer",
    function()
        local entity = Helpers.create_unregistered(test_surface, "test-water-distributer", {0, 0})
        entity.insert_fluid({name = "drinkable-water", amount = 1000})
        local entry = Register.add(entity)

        Assert.equals(
            entry[EK.water_quality],
            DrinkingWater.values["drinkable-water"].healthiness,
            "water_quality should match drinkable-water healthiness on creation"
        )
        Assert.equals(entry[EK.water_name], "drinkable-water", "water_name should be drinkable-water on creation")
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << update >>

Tirislib.Testing.add_test_case(
    "Water distributer update recognizes newly inserted recognized water",
    "integration|integration.water-distributer",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-water-distributer", {0, 0})
        local entity = entry[EK.entity]

        entity.insert_fluid({name = "clean-water", amount = 1000})
        Helpers.update_entry(entry)

        Assert.equals(
            entry[EK.water_quality],
            DrinkingWater.values["clean-water"].healthiness,
            "water_quality should match clean-water healthiness after update"
        )
        Assert.equals(entry[EK.water_name], "clean-water", "water_name should be clean-water after update")
    end,
    setup,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Water distributer update resets water_quality and water_name when tank is drained",
    "integration|integration.water-distributer",
    function()
        local entity = Helpers.create_unregistered(test_surface, "test-water-distributer", {0, 0})
        entity.insert_fluid({name = "drinkable-water", amount = 1000})
        local entry = Register.add(entity)

        entity.clear_fluid_inside()
        Helpers.update_entry(entry)

        Assert.equals(entry[EK.water_quality], -1000, "water_quality should be -1000 after draining")
        Assert.is_nil(entry[EK.water_name], "water_name should be nil after draining")
    end,
    setup,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Water distributer update reflects changed water type",
    "integration|integration.water-distributer",
    function()
        local entity = Helpers.create_unregistered(test_surface, "test-water-distributer", {0, 0})
        entity.insert_fluid({name = "drinkable-water", amount = 1000})
        local entry = Register.add(entity)

        entity.clear_fluid_inside()
        entity.insert_fluid({name = "clean-water", amount = 1000})
        Helpers.update_entry(entry)

        Assert.equals(
            entry[EK.water_quality],
            DrinkingWater.values["clean-water"].healthiness,
            "water_quality should reflect clean-water after swap"
        )
        Assert.equals(entry[EK.water_name], "clean-water", "water_name should be clean-water after swap")
    end,
    setup,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Inactive water distributer clears water_quality and water_name on update",
    "integration|integration.water-distributer",
    function()
        -- test-water-distributer-powered has power_usage set; on the unpowered test surface
        -- the EEI is created fresh during registration (grace period → is_active=true),
        -- then on the next update the EEI has 0 energy → is_active=false
        local entity = Helpers.create_unregistered(test_surface, "test-water-distributer-powered", {0, 0})
        entity.insert_fluid({name = "drinkable-water", amount = 1000})
        local entry = Register.add(entity)

        Helpers.update_entry(entry)

        Assert.equals(entry[EK.water_quality], -1000, "inactive distributer should have water_quality -1000")
        Assert.is_nil(entry[EK.water_name], "inactive distributer should have nil water_name")
    end,
    setup,
    clean_up
)

Tirislib.Testing.add_test_case(
    "Water distributer with unknown fluid is treated as no water",
    "integration|integration.water-distributer",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-water-distributer", {0, 0})
        local entity = entry[EK.entity]

        entity.insert_fluid({name = "petroleum-gas", amount = 100})
        Helpers.update_entry(entry)

        Assert.equals(entry[EK.water_quality], -1000, "water_quality should be -1000 for unknown fluid")
        Assert.is_nil(entry[EK.water_name], "water_name should be nil for unknown fluid")
    end,
    setup,
    clean_up
)
