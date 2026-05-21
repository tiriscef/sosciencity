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

local function make_virtual_signal(name)
    return {value = {type = "virtual", name = name, quality = "normal"}, min = 0, max = 0}
end

---------------------------------------------------------------------------------------------------
-- << creation >>

Tirislib.Testing.add_test_case(
    "City combinator creation registers the entity",
    "integration|integration.city-combinator",
    function()
        local entry = Helpers.create_and_register(test_surface, "city-combinator", Helpers.next_position())

        Helpers.assert_is_registered(entry)
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << basic population write >>

Tirislib.Testing.add_test_case(
    "City combinator writes ember population to signal-ember slot after update",
    "integration|integration.city-combinator",
    function()
        storage.population[Type.ember] = 42

        local entry = Helpers.create_and_register(test_surface, "city-combinator", Helpers.next_position())
        local section = entry[EK.entity].get_control_behavior().add_section()
        section.set_slot(1, make_virtual_signal("signal-ember"))

        Helpers.update_entry(entry)

        local slot = section.get_slot(1)
        Assert.equals(slot.min, 42, "min should equal ember population")
        Assert.equals(slot.max, 42, "max should equal ember population")
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << all seven caste signals >>

Tirislib.Testing.add_test_case(
    "City combinator updates all seven caste population signals independently",
    "integration|integration.city-combinator",
    function()
        local caste_signals = {
            {signal = "signal-ember",     caste = Type.ember,     count = 10},
            {signal = "signal-orchid",    caste = Type.orchid,    count = 20},
            {signal = "signal-clockwork", caste = Type.clockwork, count = 30},
            {signal = "signal-gunfire",   caste = Type.gunfire,   count = 40},
            {signal = "signal-foundry",   caste = Type.foundry,   count = 50},
            {signal = "signal-gleam",     caste = Type.gleam,     count = 60},
            {signal = "signal-plasma",    caste = Type.plasma,    count = 70},
        }

        for _, data in pairs(caste_signals) do
            storage.population[data.caste] = data.count
        end

        local entry = Helpers.create_and_register(test_surface, "city-combinator", Helpers.next_position())
        local section = entry[EK.entity].get_control_behavior().add_section()

        for i, data in pairs(caste_signals) do
            section.set_slot(i, make_virtual_signal(data.signal))
        end

        Helpers.update_entry(entry)

        for i, data in pairs(caste_signals) do
            local slot = section.get_slot(i)
            Assert.equals(slot.min, data.count, data.signal .. " min should match population")
            Assert.equals(slot.max, data.count, data.signal .. " max should match population")
        end
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << non-population signal untouched >>

Tirislib.Testing.add_test_case(
    "City combinator does not modify non-population signal slots",
    "integration|integration.city-combinator",
    function()
        local entry = Helpers.create_and_register(test_surface, "city-combinator", Helpers.next_position())
        local section = entry[EK.entity].get_control_behavior().add_section()
        section.set_slot(1, {value = {type = "virtual", name = "signal-red", quality = "normal"}, min = 99, max = 99})

        Helpers.update_entry(entry)

        local slot = section.get_slot(1)
        Assert.equals(slot.min, 99, "min should be unchanged for non-population signal")
        Assert.equals(slot.max, 99, "max should be unchanged for non-population signal")
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << population zero >>

Tirislib.Testing.add_test_case(
    "City combinator overwrites existing slot value with zero when caste population is zero",
    "integration|integration.city-combinator",
    function()
        -- storage.population[Type.clockwork] is 0 after reset_inhabitants_state; use non-zero
        -- initial slot values to confirm the updater actively writes zero rather than skipping
        local entry = Helpers.create_and_register(test_surface, "city-combinator", Helpers.next_position())
        local section = entry[EK.entity].get_control_behavior().add_section()
        section.set_slot(1, {value = {type = "virtual", name = "signal-clockwork", quality = "normal"}, min = 99, max = 99})

        Helpers.update_entry(entry)

        local slot = section.get_slot(1)
        Assert.equals(slot.min, 0, "min should be 0 when clockwork population is 0")
        Assert.equals(slot.max, 0, "max should be 0 when clockwork population is 0")
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << population change reflected >>

Tirislib.Testing.add_test_case(
    "City combinator reflects updated population on subsequent updates",
    "integration|integration.city-combinator",
    function()
        storage.population[Type.ember] = 10

        local entry = Helpers.create_and_register(test_surface, "city-combinator", Helpers.next_position())
        local section = entry[EK.entity].get_control_behavior().add_section()
        section.set_slot(1, make_virtual_signal("signal-ember"))

        Helpers.update_entry(entry)
        Assert.equals(section.get_slot(1).min, 10, "should show initial population of 10")

        storage.population[Type.ember] = 25
        Helpers.update_entry(entry)
        Assert.equals(section.get_slot(1).min, 25, "should show updated population of 25")
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << second section >>

Tirislib.Testing.add_test_case(
    "City combinator updates population signals in a second section",
    "integration|integration.city-combinator",
    function()
        storage.population[Type.orchid] = 77

        local entry = Helpers.create_and_register(test_surface, "city-combinator", Helpers.next_position())
        local cb = entry[EK.entity].get_control_behavior()
        cb.add_section()  -- first added section - left empty
        local section2 = cb.add_section()
        section2.set_slot(1, make_virtual_signal("signal-orchid"))

        Helpers.update_entry(entry)

        local slot = section2.get_slot(1)
        Assert.equals(slot.min, 77, "signal-orchid min in second section should equal orchid population")
        Assert.equals(slot.max, 77, "signal-orchid max in second section should equal orchid population")
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << slot 10 boundary >>

Tirislib.Testing.add_test_case(
    "City combinator updates population signal placed in slot 10",
    "integration|integration.city-combinator",
    function()
        storage.population[Type.gleam] = 55

        local entry = Helpers.create_and_register(test_surface, "city-combinator", Helpers.next_position())
        local section = entry[EK.entity].get_control_behavior().add_section()
        section.set_slot(10, make_virtual_signal("signal-gleam"))

        Helpers.update_entry(entry)

        local slot = section.get_slot(10)
        Assert.equals(slot.min, 55, "slot 10 min should equal gleam population")
        Assert.equals(slot.max, 55, "slot 10 max should equal gleam population")
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << empty slots skipped >>

Tirislib.Testing.add_test_case(
    "City combinator update does not crash when combinator has no sections",
    "integration|integration.city-combinator",
    function()
        local entry = Helpers.create_and_register(test_surface, "city-combinator", Helpers.next_position())
        -- no sections added - updater should be a no-op

        Helpers.update_entry(entry)

        Helpers.assert_is_registered(entry)
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << slot index beyond old hardcoded limit >>

Tirislib.Testing.add_test_case(
    "City combinator updates population signal placed beyond the old slot-10 limit",
    "integration|integration.city-combinator",
    function()
        storage.population[Type.plasma] = 88

        local entry = Helpers.create_and_register(test_surface, "city-combinator", Helpers.next_position())
        local section = entry[EK.entity].get_control_behavior().add_section()
        section.set_slot(20, make_virtual_signal("signal-plasma"))

        Helpers.update_entry(entry)

        local slot = section.get_slot(20)
        Assert.equals(slot.min, 88, "slot 20 min should equal plasma population")
        Assert.equals(slot.max, 88, "slot 20 max should equal plasma population")
    end,
    setup,
    clean_up
)

---------------------------------------------------------------------------------------------------
-- << empty slots skipped >>

Tirislib.Testing.add_test_case(
    "City combinator update does not crash with sparsely filled section",
    "integration|integration.city-combinator",
    function()
        storage.population[Type.foundry] = 33

        local entry = Helpers.create_and_register(test_surface, "city-combinator", Helpers.next_position())
        local section = entry[EK.entity].get_control_behavior().add_section()
        -- only slot 1 filled; slots 2-10 are empty
        section.set_slot(1, make_virtual_signal("signal-foundry"))

        Helpers.update_entry(entry)

        local slot = section.get_slot(1)
        Assert.equals(slot.min, 33, "slot 1 should be updated even when slots 2-10 are empty")
    end,
    setup,
    clean_up
)
