local EK = require("enums.entry-key")
local SubentityType = require("enums.subentity-type")
local Type = require("enums.type")

local Buildings = require("constants.buildings")
local Time = require("constants.time")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local Table = Tirislib.Tables
local upbringing_time = Entity.Upbringing.time

local test_surface

local function setup()
    test_surface = Helpers.create_test_surface()
    Helpers.reset_inhabitants_state()
    storage.technologies["upbringing"] = 1
end

local function teardown()
    Helpers.clean_up()
end

local function make_station(position)
    return Helpers.create_and_register(test_surface, "test-upbringing-station", position)
end

--- Runs an update bypassing the power check so tests can focus on class logic.
--- After any update that sets power_usage > 0, the test entity has no power supply,
--- so subsequent updates would early-return at the is_active guard without this reset.
local function do_update(entry)
    entry[EK.power_usage] = 0
    Helpers.update_entry(entry)
end

local function add_eggs(entry, count)
    local inventory = Inventories.get_chest_inventory(entry)
    inventory.insert {name = "huwan-egg", count = count}
end

local function class_student_count(class)
    return Table.sum(class[2])
end

--- Fills the EEI buffer so has_power returns true on the next update.
--- Needed because Subentities.add_all_for sets entry[EK.power_usage] = details.power_usage
--- at registration, which causes has_power to check eei.energy (0 in tests with no grid).
local function fill_eei(entry)
    local eei = Subentities.get_or_create(entry, SubentityType.eei)
    eei.energy = eei.electric_buffer_size
end

---------------------------------------------------------------------------------------------------
-- << creation >>

Tirislib.Testing.add_test_case(
    "upbringing station: creation initializes education_mode, classes, graduates",
    "integration|integration.upbringing",
    function()
        local entry = make_station(Helpers.next_position())
        Assert.equals(entry[EK.education_mode], Type.null, "education_mode should default to null")
        Assert.equals(#entry[EK.classes], 0, "classes should be empty on creation")
        Assert.equals(entry[EK.graduates], 0, "graduates should be 0 on creation")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << tech gate >>

Tirislib.Testing.add_test_case(
    "upbringing station: update does nothing without upbringing tech",
    "integration|integration.upbringing",
    function()
        local entry = make_station(Helpers.next_position())
        storage.technologies["upbringing"] = nil
        add_eggs(entry, 5)
        do_update(entry)
        Assert.equals(#entry[EK.classes], 0, "no class without the tech")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << class creation >>

Tirislib.Testing.add_test_case(
    "upbringing station: eggs in inventory create a class and are consumed",
    "integration|integration.upbringing",
    function()
        local entry = make_station(Helpers.next_position())
        add_eggs(entry, 5)
        do_update(entry)

        Assert.equals(#entry[EK.classes], 1, "one class should be created")
        Assert.equals(class_student_count(entry[EK.classes][1]), 5, "class should have 5 students")

        local inventory = Inventories.get_chest_inventory(entry)
        Assert.equals(inventory.get_item_count("huwan-egg"), 0, "eggs should be consumed")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "upbringing station: no class created when no eggs present",
    "integration|integration.upbringing",
    function()
        local entry = make_station(Helpers.next_position())
        do_update(entry)
        Assert.equals(#entry[EK.classes], 0, "no class without eggs")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << interval gate >>

Tirislib.Testing.add_test_case(
    "upbringing station: second class not created within 10 seconds of first",
    "integration|integration.upbringing",
    function()
        local entry = make_station(Helpers.next_position())
        add_eggs(entry, 5)
        do_update(entry)  -- creates first class, stamps creation tick as game.tick

        add_eggs(entry, 5)
        do_update(entry)  -- game.tick unchanged: current_tick - most_recent_class = 0 < 600

        Assert.equals(#entry[EK.classes], 1, "second class should not be created within 10 seconds")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << capacity gate >>

Tirislib.Testing.add_test_case(
    "upbringing station: no class created when at capacity",
    "integration|integration.upbringing",
    function()
        local entry = make_station(Helpers.next_position())
        local details = Buildings.get(entry)

        -- plant a class old enough to pass the interval gate but not yet due to graduate
        entry[EK.classes] = {{game.tick - 11 * Time.second, {["huwan-egg"] = details.capacity}}}

        add_eggs(entry, 5)
        do_update(entry)

        Assert.equals(#entry[EK.classes], 1, "no new class when at capacity")
        Assert.equals(entry[EK.graduates], 0, "class should not have graduated yet")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << class maturation >>

Tirislib.Testing.add_test_case(
    "upbringing station: class graduates after upbringing_time and is removed",
    "integration|integration.upbringing",
    function()
        local entry = make_station(Helpers.next_position())
        entry[EK.classes] = {{game.tick - upbringing_time, {["huwan-egg"] = 3}}}

        do_update(entry)

        Assert.equals(#entry[EK.classes], 0, "graduating class should be removed")
        Assert.equals(entry[EK.graduates], 3, "graduates should be incremented by class size")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "upbringing station: class not removed before upbringing_time",
    "integration|integration.upbringing",
    function()
        local entry = make_station(Helpers.next_position())
        entry[EK.classes] = {{game.tick - upbringing_time + 10, {["huwan-egg"] = 3}}}

        do_update(entry)

        Assert.equals(#entry[EK.classes], 1, "class should remain if not yet mature")
        Assert.equals(entry[EK.graduates], 0, "graduates should not change")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << circuit mode control >>

--- Creates a constant combinator next to the station and connects it via red wire.
--- If caste_type is given, the combinator emits that caste's signal at count 1.
--- Cleaned up automatically when teardown calls Helpers.clean_up() / surface.clear().
local function connect_combinator_with_signal(entry, caste_type)
    local entity_pos = entry[EK.entity].position
    local combinator = test_surface.create_entity({
        name = "constant-combinator",
        position = {entity_pos.x + 3, entity_pos.y},
        force = "player"
    })
    if caste_type then
        local signal = Entity.caste_signals[caste_type]
        local behavior = combinator.get_or_create_control_behavior()
        behavior.enabled = true
        local section = behavior.get_section(1) or behavior.add_section()
        section.filters = {{value = {type = signal.type, name = signal.name, quality = "normal"}, min = 1}}
        section.active = true
    end
    local station_connector = entry[EK.entity].get_wire_connector(defines.wire_connector_id.circuit_red, true)
    local combinator_connector = combinator.get_wire_connector(defines.wire_connector_id.circuit_red, true)
    station_connector.connect_to(combinator_connector, false)
    return combinator
end

Tirislib.Testing.add_test_case(
    "upbringing station: circuit signal > 0 sets education_mode after tick propagation",
    "integration|integration.upbringing",
    function()
        local entry = make_station(Helpers.next_position())
        connect_combinator_with_signal(entry, Type.clockwork)

        Tirislib.Testing.let_n_ticks_pass(1, function()
            do_update(entry)
            Assert.equals(entry[EK.education_mode], Type.clockwork, "circuit signal should set education_mode after tick propagation")
        end)
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "upbringing station: circuit connected but no caste signal resets education_mode to null",
    "integration|integration.upbringing",
    function()
        local entry = make_station(Helpers.next_position())
        entry[EK.education_mode] = Type.clockwork
        connect_combinator_with_signal(entry, nil)  -- connected but no signals set
        do_update(entry)
        Assert.equals(entry[EK.education_mode], Type.null, "education_mode should reset to null when circuit has no active signal")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "upbringing station: no circuit connection preserves player-set education_mode",
    "integration|integration.upbringing",
    function()
        local entry = make_station(Helpers.next_position())
        entry[EK.education_mode] = Type.clockwork
        -- no combinator connected - player-set mode should survive
        do_update(entry)
        Assert.equals(entry[EK.education_mode], Type.clockwork, "education_mode should be preserved when no circuit is connected")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << mode validation >>

Tirislib.Testing.add_test_case(
    "upbringing station: update resets education_mode to null when the caste is not researched",
    "integration|integration.upbringing",
    function()
        -- gunfire-caste tech is not set in storage, so Type.gunfire is unresearched
        local entry = make_station(Helpers.next_position())
        entry[EK.education_mode] = Type.gunfire
        do_update(entry)
        Assert.equals(entry[EK.education_mode], Type.null, "unresearched caste mode should be reset to null")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << multiple graduations >>

Tirislib.Testing.add_test_case(
    "upbringing station: two mature classes both graduate in the same update",
    "integration|integration.upbringing",
    function()
        local entry = make_station(Helpers.next_position())
        entry[EK.classes] = {
            {game.tick - upbringing_time, {["huwan-egg"] = 3}},
            {game.tick - upbringing_time, {["huwan-egg"] = 2}}
        }

        do_update(entry)

        Assert.equals(#entry[EK.classes], 0, "both classes should be removed after graduating")
        Assert.equals(entry[EK.graduates], 5, "graduates should be the sum of both classes")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << copy >>

Tirislib.Testing.add_test_case(
    "upbringing station: clone copies education_mode, classes, and graduates",
    "integration|integration.upbringing",
    function()
        local source = make_station(Helpers.next_position())
        source[EK.education_mode] = Type.clockwork
        source[EK.classes] = {{game.tick - 10, {["huwan-egg"] = 4}}}
        source[EK.graduates] = 7

        local dest_entity = Helpers.create_unregistered(test_surface, "test-upbringing-station", Helpers.next_position())
        local dest = Register.clone(source, dest_entity)

        Assert.equals(dest[EK.education_mode], Type.clockwork, "education_mode should be copied")
        Assert.equals(#dest[EK.classes], 1, "classes should be copied")
        Assert.equals(dest[EK.graduates], 7, "graduates should be copied")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "upbringing station: clone produces an independent classes array - adding to source does not affect destination",
    "integration|integration.upbringing",
    function()
        local source = make_station(Helpers.next_position())
        source[EK.classes] = {{game.tick - 10, {["huwan-egg"] = 2}}}

        local dest_entity = Helpers.create_unregistered(test_surface, "test-upbringing-station", Helpers.next_position())
        local dest = Register.clone(source, dest_entity)

        source[EK.classes][#source[EK.classes] + 1] = {game.tick - 5, {["huwan-egg"] = 3}}
        Assert.equals(#dest[EK.classes], 1, "adding a class to source should not affect destination")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << paste >>

Tirislib.Testing.add_test_case(
    "upbringing station: pasting settings copies education_mode to destination",
    "integration|integration.upbringing",
    function()
        local source = make_station(Helpers.next_position())
        local dest = make_station(Helpers.next_position())
        source[EK.education_mode] = Type.clockwork
        dest[EK.education_mode] = Type.null

        Register.on_settings_pasted(Type.upbringing_station, source, Type.upbringing_station, dest, {})

        Assert.equals(dest[EK.education_mode], Type.clockwork, "education_mode should be pasted to destination")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << power usage >>
-- Power tests use fill_eei so has_power passes despite no grid. add_all_for sets
-- entry[EK.power_usage] = details.power_usage at registration, so the initial update
-- would otherwise stall at the is_active guard.

Tirislib.Testing.add_test_case(
    "upbringing station: power usage is 0 when no classes are in progress",
    "integration|integration.upbringing",
    function()
        local entry = make_station(Helpers.next_position())
        fill_eei(entry)
        Helpers.update_entry(entry)  -- no eggs, no classes -> set_power_usage(entry, 0)
        Assert.equals(entry[EK.power_usage], 0, "power usage should be 0 when idle")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "upbringing station: power usage set to details.power_usage when class is in progress",
    "integration|integration.upbringing",
    function()
        local entry = make_station(Helpers.next_position())
        local details = Buildings.get(entry)

        add_eggs(entry, 1)
        -- do_update resets power_usage to 0, then code sets it back to details.power_usage
        do_update(entry)

        Assert.equals(entry[EK.power_usage], details.power_usage, "power usage should match details when class active")
    end,
    setup,
    teardown
)
