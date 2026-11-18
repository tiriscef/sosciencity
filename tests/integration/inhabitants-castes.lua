local EK = require("enums.entry-key")
local Type = require("enums.type")
local Castes = require("constants.castes")

local Helpers = require("tests.integration.helpers")
local Technologies = require("classes.technologies")
local Inhabitants = require("classes.inhabitants")
local Assert = Tirislib.Testing.Assert

local test_surface

Tirislib.Testing.add_test_case(
    "caste_is_researched returns false when tech is not researched",
    "integration|integration.inhabitants",
    function()
        local original = storage.technologies["upbringing"]
        storage.technologies["upbringing"] = nil

        Assert.is_false(Technologies.caste_is_researched(Type.clockwork))

        storage.technologies["upbringing"] = original
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "caste_is_researched returns true when tech is researched",
    "integration|integration.inhabitants",
    function()
        local original = storage.technologies["upbringing"]
        storage.technologies["upbringing"] = 1

        Assert.is_true(Technologies.caste_is_researched(Type.clockwork) and true or false)

        storage.technologies["upbringing"] = original
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "get_caste_efficiency_level reflects technology level",
    "integration|integration.inhabitants",
    function()
        local original = storage.technologies["clockwork-caste-efficiency"]
        storage.technologies["clockwork-caste-efficiency"] = 3

        Assert.equals(Technologies.get_caste_efficiency_level(Type.clockwork), 3)

        storage.technologies["clockwork-caste-efficiency"] = original
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "get_population_count sums all caste populations",
    "integration|integration.inhabitants",
    function()
        -- save and set known values
        local saved = {}
        for _, caste in pairs(Castes.all) do
            saved[caste.type] = storage.population[caste.type]
            storage.population[caste.type] = 0
        end

        storage.population[Type.clockwork] = 10
        storage.population[Type.orchid] = 20

        Assert.equals(Inhabitants.get_population_count(), 30)

        -- restore
        for caste_type, count in pairs(saved) do
            storage.population[caste_type] = count
        end
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Orchid bonus increases with caste points",
    "integration|integration.inhabitants",
    function()
        -- orchid bonus = floor(sqrt(max(0, points)))
        local original = storage.caste_points[Type.orchid]

        storage.caste_points[Type.orchid] = 0
        Inhabitants.update(game.tick)
        local bonus_zero = storage.caste_bonuses[Type.orchid]

        storage.caste_points[Type.orchid] = 100
        Inhabitants.update(game.tick)
        local bonus_100 = storage.caste_bonuses[Type.orchid]

        Assert.equals(bonus_zero, 0, "bonus should be 0 with 0 points")
        Assert.equals(bonus_100, 10, "bonus should be 10 with 100 points (floor(sqrt(100)))")

        storage.caste_points[Type.orchid] = original
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

local TechEffects = require("constants.tech-effects")

--- Returns the binary value the hidden techs with the given suffix currently encode.
local function read_binary_techs(name)
    local techs = game.forces.player.technologies
    local value = 0
    for strength = 0, TechEffects.binary_tech_count - 1 do
        if techs[strength .. name].researched then
            value = value + 2 ^ strength
        end
    end
    return value
end

Tirislib.Testing.add_test_case(
    "set_binary_techs encodes the value and clamps it to the maximum",
    "integration|integration.inhabitants",
    function()
        local original = read_binary_techs("-foundry-caste")

        Technologies.set_binary_techs(37, "-foundry-caste")
        Assert.equals(read_binary_techs("-foundry-caste"), 37)

        Technologies.set_binary_techs(TechEffects.binary_tech_max_value + 12345, "-foundry-caste")
        Assert.equals(read_binary_techs("-foundry-caste"), TechEffects.binary_tech_max_value)

        Technologies.set_binary_techs(original, "-foundry-caste")
    end
)

Tirislib.Testing.add_test_case(
    "no hidden caste bonus tech has an effect above 1000",
    "integration|integration.inhabitants",
    function()
        for _, name in pairs {"-foundry-caste", "-gleam-caste", "-gunfire-caste"} do
            for strength = 0, TechEffects.binary_tech_count - 1 do
                for _, effect in pairs(prototypes.technology[strength .. name].effects) do
                    Assert.is_true((effect.modifier or 0) <= 1000)
                end
            end
            Assert.is_true(prototypes.technology[TechEffects.binary_tech_count .. name] == nil)
        end
    end
)
