local EK = require("enums.entry-key")

local Buildings = require("constants.buildings")
local Types = require("constants.types")
local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface

local function setup()
    test_surface = Helpers.create_test_surface()
end

local function teardown()
    Helpers.clean_up()
end

local function create_machine()
    return Helpers.create_and_register(test_surface, "test-assembling-machine", Helpers.next_position())
end

---------------------------------------------------------------------------------------------------
-- << applying >>

Tirislib.Testing.add_test_case(
    "Effects.set applies percentages as local effect values",
    "integration|integration.effects",
    function()
        local entry = create_machine()

        Effects.set(entry, {speed = 40, productivity = 15})

        local effect = entry[EK.entity].local_effect
        Assert.equals(effect.speed, 0.4, "40% speed should become 0.4")
        Assert.equals(effect.productivity, 0.15, "15% productivity should become 0.15")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Effects.set overwrites its own previous contribution instead of stacking it",
    "integration|integration.effects",
    function()
        local entry = create_machine()

        Effects.set(entry, {speed = 40})
        Effects.set(entry, {speed = 10})

        Assert.equals(entry[EK.entity].local_effect.speed, 0.1, "only the newest contribution should remain")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Repeated Effects.set calls don't drift",
    "integration|integration.effects",
    function()
        local entry = create_machine()

        for _ = 1, 100 do
            Effects.set(entry, {speed = 33, productivity = 17})
        end

        local effect = entry[EK.entity].local_effect
        Assert.equals(effect.speed, 0.33, "speed should be unchanged after many updates")
        Assert.equals(effect.productivity, 0.17, "productivity should be unchanged after many updates")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Effects.set applies every kind of effect",
    "integration|integration.effects",
    function()
        local entry = create_machine()

        Effects.set(entry, {speed = 10, productivity = 20, consumption = -30, pollution = -40, quality = 50})

        local effect = entry[EK.entity].local_effect
        Assert.equals(effect.speed, 0.1, "speed should be applied")
        Assert.equals(effect.productivity, 0.2, "productivity should be applied")
        Assert.equals(effect.consumption, -0.3, "consumption should be applied")
        Assert.equals(effect.pollution, -0.4, "pollution should be applied")
        Assert.equals(effect.quality, 0.5, "quality should be applied")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Effects.set takes back an effect it stops asking for",
    "integration|integration.effects",
    function()
        local entry = create_machine()

        Effects.set(entry, {speed = 20, consumption = 30})
        Effects.set(entry, {speed = 20})

        local effect = entry[EK.entity].local_effect
        Assert.equals(effect.speed, 0.2, "the effect we still ask for should remain")
        -- the engine leaves zeroed values out of the effect it hands back
        Assert.equals(effect.consumption or 0, 0, "the omitted effect should be gone")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << effect receiver setup >>

local machine_types = {
    ["assembling-machine"] = true,
    ["furnace"] = true,
    ["mining-drill"] = true,
    ["rocket-silo"] = true
}

Tirislib.Testing.add_test_case(
    "Citizen-run buildings refuse beacons and can be slowed past the default -80% floor",
    "integration|integration.effects",
    function()
        for name, def in pairs(Buildings.values) do
            local prototype = prototypes.entity[name]

            -- catch-all types are ordinary machines and keep vanilla beacon behaviour
            if prototype and machine_types[prototype.type] and not Types.definitions[def.type].is_catch_all then
                local receiver = prototype.effect_receiver

                Assert.is_false(receiver.uses_beacon_effects, name .. " should not be affected by beacons")
                Assert.is_false(receiver.uses_surface_effects, name .. " should not be affected by surfaces")
                Assert.equals(receiver.speed_limits.low, -0.9999, name .. " should be able to crawl")
                Assert.equals(receiver.productivity_limits.low, -0.9999, name .. " should be able to crawl")
            end
        end
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "A citizen-run building can be slowed down beyond the default -80% floor",
    "integration|integration.effects",
    function()
        local entry = Helpers.create_and_register(test_surface, "test-farm", Helpers.next_position())

        Effects.set(entry, {speed = -94})

        Assert.equals(entry[EK.entity].effects.speed, -0.94, "the raised speed limit should let the malus through")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << sharing local_effect with other mods >>

Tirislib.Testing.add_test_case(
    "Effects.set keeps a contribution that another mod made before us",
    "integration|integration.effects",
    function()
        local entry = create_machine()
        entry[EK.entity].local_effect = {speed = 0.5, productivity = 0.5}

        Effects.set(entry, {speed = 20, productivity = 10})

        local effect = entry[EK.entity].local_effect
        Assert.equals(effect.speed, 0.7, "our 20% should add to the foreign 50%")
        Assert.equals(effect.productivity, 0.6, "our 10% should add to the foreign 50%")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Effects.set picks up a change another mod made after us",
    "integration|integration.effects",
    function()
        local entry = create_machine()
        Effects.set(entry, {speed = 20})

        -- another mod adds its own 50% on top of the 20% we already applied
        local entity = entry[EK.entity]
        entity.local_effect = {speed = entity.local_effect.speed + 0.5}

        Effects.set(entry, {speed = 30})

        Assert.equals(entity.local_effect.speed, 0.8, "our contribution should change, the foreign one shouldn't")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Effects.set keeps foreign contributions in the effects it isn't asked for",
    "integration|integration.effects",
    function()
        local entry = create_machine()
        entry[EK.entity].local_effect = {consumption = 0.3, pollution = -0.2}

        Effects.set(entry, {speed = 20, productivity = 10})

        local effect = entry[EK.entity].local_effect
        Assert.equals(effect.consumption, 0.3, "foreign consumption should survive")
        Assert.equals(effect.pollution, -0.2, "foreign pollution should survive")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "A cloned machine doesn't inherit our contribution as a foreign one",
    "integration|integration.effects",
    function()
        local entry = create_machine()
        Effects.set(entry, {speed = 50})

        local clone = entry[EK.entity].clone {position = Helpers.next_position(), surface = test_surface}
        local clone_entry = Register.clone(entry, clone)

        Effects.set(clone_entry, {speed = 20})

        Assert.equals(clone.local_effect.speed, 0.2, "the clone should only carry our new contribution")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << clearing >>

Tirislib.Testing.add_test_case(
    "Effects.clear removes our contribution and leaves the foreign one",
    "integration|integration.effects",
    function()
        local entry = create_machine()
        entry[EK.entity].local_effect = {speed = 0.5}

        Effects.set(entry, {speed = 20, productivity = 10})
        Effects.clear(entry)

        local effect = entry[EK.entity].local_effect
        Assert.equals(effect.speed, 0.5, "the foreign contribution should remain")
        -- the engine leaves zeroed values out of the effect it hands back
        Assert.equals(effect.productivity or 0, 0, "our productivity should be gone")
        Assert.is_nil(entry[EK.written_effect], "bookkeeping should be reset")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Deregistering an entity takes its effects back",
    "integration|integration.effects",
    function()
        local entry = create_machine()
        local entity = entry[EK.entity]
        entity.local_effect = {speed = 0.5}

        Effects.set(entry, {speed = 25})
        Register.remove_entry(entry, nil, nil, true)

        Assert.equals(entity.local_effect.speed, 0.5, "only the foreign contribution should be left behind")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Effects.clear does nothing when we never applied anything",
    "integration|integration.effects",
    function()
        local entry = create_machine()
        entry[EK.entity].local_effect = {speed = 0.5}

        Effects.clear(entry)

        Assert.equals(entry[EK.entity].local_effect.speed, 0.5, "a foreign contribution should be untouched")
    end,
    setup,
    teardown
)
