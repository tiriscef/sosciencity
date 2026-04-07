local EK = require("enums.entry-key")
local Type = require("enums.type")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface

Tirislib.Testing.add_test_case(
    "caste_is_researched returns false when tech is not researched",
    "integration|integration.inhabitants",
    function()
        local original = storage.technologies["upbringing"]
        storage.technologies["upbringing"] = nil

        Assert.is_false(Inhabitants.caste_is_researched(Type.clockwork))

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

        Assert.is_true(Inhabitants.caste_is_researched(Type.clockwork) and true or false)

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

        Assert.equals(Inhabitants.get_caste_efficiency_level(Type.clockwork), 3)

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
        for _, caste in pairs(require("constants.castes").all) do
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
