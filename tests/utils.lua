require("tirislib.init")

local Assert = Tirislib.Testing.Assert
local Utils = Tirislib.Utils

---------------------------------------------------------------------------------------------------
-- << clamp >>

Tirislib.Testing.add_test_case(
    "clamp returns the value when inside the interval",
    "lib.utils",
    function()
        Assert.equals(Utils.clamp(5, 0, 10), 5)
        Assert.equals(Utils.clamp(0, 0, 10), 0)
        Assert.equals(Utils.clamp(10, 0, 10), 10)
    end
)

Tirislib.Testing.add_test_case(
    "clamp clamps to the interval bounds",
    "lib.utils",
    function()
        Assert.equals(Utils.clamp(-1, 0, 10), 0)
        Assert.equals(Utils.clamp(11, 0, 10), 10)
        Assert.equals(Utils.clamp(-100, -5, 5), -5)
    end
)

---------------------------------------------------------------------------------------------------
-- << map_range >>

Tirislib.Testing.add_test_case(
    "map_range maps proportionally between intervals",
    "lib.utils",
    function()
        Assert.equals(Utils.map_range(0, 0, 10, 0, 100), 0)
        Assert.equals(Utils.map_range(5, 0, 10, 0, 100), 50)
        Assert.equals(Utils.map_range(10, 0, 10, 0, 100), 100)
        Assert.equals(Utils.map_range(0.5, 0, 1, 100, 200), 150)
    end
)

Tirislib.Testing.add_test_case(
    "map_range clamps values outside the from interval",
    "lib.utils",
    function()
        Assert.equals(Utils.map_range(-5, 0, 10, 0, 100), 0)
        Assert.equals(Utils.map_range(15, 0, 10, 0, 100), 100)
    end
)

Tirislib.Testing.add_test_case(
    "map_range returns to_min when from interval is a single point",
    "lib.utils",
    function()
        Assert.equals(Utils.map_range(5, 5, 5, 0, 100), 0)
    end
)

---------------------------------------------------------------------------------------------------
-- << round >>

Tirislib.Testing.add_test_case(
    "round rounds whole numbers unchanged",
    "lib.utils",
    function()
        Assert.equals(Utils.round(3), 3)
        Assert.equals(Utils.round(-3), -3)
        Assert.equals(Utils.round(0), 0)
    end
)

Tirislib.Testing.add_test_case(
    "round rounds half away from zero",
    "lib.utils",
    function()
        Assert.equals(Utils.round(0.5), 1)
        Assert.equals(Utils.round(-0.5), -1)
        Assert.equals(Utils.round(2.5), 3)
        Assert.equals(Utils.round(-2.5), -3)
    end
)

Tirislib.Testing.add_test_case(
    "round rounds fractional values to nearest integer",
    "lib.utils",
    function()
        Assert.equals(Utils.round(1.4), 1)
        Assert.equals(Utils.round(1.6), 2)
        Assert.equals(Utils.round(-1.4), -1)
        Assert.equals(Utils.round(-1.6), -2)
    end
)

---------------------------------------------------------------------------------------------------
-- << round_to_step / floor_to_step / ceil_to_step >>

Tirislib.Testing.add_test_case(
    "round_to_step rounds to the nearest multiple of step",
    "lib.utils",
    function()
        Assert.equals(Utils.round_to_step(7, 5), 5)
        Assert.equals(Utils.round_to_step(8, 5), 10)
        Assert.equals(Utils.round_to_step(10, 5), 10)
        Assert.equals(Utils.round_to_step(0.3, 0.25), 0.25)
    end
)

Tirislib.Testing.add_test_case(
    "floor_to_step floors to the nearest lower multiple of step",
    "lib.utils",
    function()
        Assert.equals(Utils.floor_to_step(9, 5), 5)
        Assert.equals(Utils.floor_to_step(10, 5), 10)
        Assert.equals(Utils.floor_to_step(4, 5), 0)
    end
)

Tirislib.Testing.add_test_case(
    "ceil_to_step ceils to the nearest higher multiple of step",
    "lib.utils",
    function()
        Assert.equals(Utils.ceil_to_step(6, 5), 10)
        Assert.equals(Utils.ceil_to_step(10, 5), 10)
        Assert.equals(Utils.ceil_to_step(1, 5), 5)
    end
)

---------------------------------------------------------------------------------------------------
-- << weighted_average >>

Tirislib.Testing.add_test_case(
    "weighted_average returns correct weighted average",
    "lib.utils",
    function()
        Assert.equals(Utils.weighted_average(0, 1, 10, 1), 5)
        Assert.equals(Utils.weighted_average(0, 1, 10, 3), 7.5)
        Assert.equals(Utils.weighted_average(5, 1, 5, 1), 5)
    end
)

Tirislib.Testing.add_test_case(
    "weighted_average returns 0 when both weights are 0",
    "lib.utils",
    function()
        Assert.equals(Utils.weighted_average(100, 0, 200, 0), 0)
    end
)

---------------------------------------------------------------------------------------------------
-- << sgn >>

Tirislib.Testing.add_test_case(
    "sgn returns the correct sign",
    "lib.utils",
    function()
        Assert.equals(Utils.sgn(5), 1)
        Assert.equals(Utils.sgn(-5), -1)
        Assert.equals(Utils.sgn(0), 0)
        Assert.equals(Utils.sgn(0.001), 1)
        Assert.equals(Utils.sgn(-0.001), -1)
    end
)

---------------------------------------------------------------------------------------------------
-- << weighted_random >>

Tirislib.Testing.add_test_case(
    "weighted_random returns a valid index",
    "lib.utils",
    function()
        local weights = {1, 2, 3, 4}
        for _ = 1, 20 do
            local idx = Utils.weighted_random(weights)
            Assert.greater_than(idx, 0)
            Assert.less_than(idx, 5)
            Assert.is_integer(idx)
        end
    end
)

Tirislib.Testing.add_test_case(
    "weighted_random always returns the only non-zero index",
    "lib.utils",
    function()
        local weights = {0, 0, 1, 0}
        for _ = 1, 10 do
            Assert.equals(Utils.weighted_random(weights), 3)
        end
    end
)

Tirislib.Testing.add_test_case(
    "weighted_random throws when all weights are zero",
    "lib.utils",
    function()
        Assert.throws(function()
            Utils.weighted_random({0, 0, 0})
        end)
    end
)

---------------------------------------------------------------------------------------------------
-- << coin_flips >>

Tirislib.Testing.add_test_case(
    "coin_flips with probability 0 always returns 0",
    "lib.utils",
    function()
        Assert.equals(Utils.coin_flips(0, 100), 0)
    end
)

Tirislib.Testing.add_test_case(
    "coin_flips with probability 1 always returns count",
    "lib.utils",
    function()
        Assert.equals(Utils.coin_flips(1, 100), 100)
        Assert.equals(Utils.coin_flips(1, 7), 7)
    end
)

---------------------------------------------------------------------------------------------------
-- << random_different >>

Tirislib.Testing.add_test_case(
    "random_different never returns n",
    "lib.utils",
    function()
        for _ = 1, 30 do
            local result = Utils.random_different(1, 5, 3)
            Assert.greater_than(result, 0)
            Assert.less_than(result, 6)
            Assert.is_integer(result)
            Assert.unequal(result, 3)
        end
    end
)

Tirislib.Testing.add_test_case(
    "random_different returns value_min when range has only one value",
    "lib.utils",
    function()
        Assert.equals(Utils.random_different(4, 4, 9), 4)
    end
)

---------------------------------------------------------------------------------------------------
-- << occurrence_probability >>

Tirislib.Testing.add_test_case(
    "occurrence_probability computes correctly",
    "lib.utils",
    function()
        Assert.equals(Utils.occurrence_probability(0, 100), 0)
        Assert.equals(Utils.occurrence_probability(1, 1), 1)
        Assert.equals(Utils.occurrence_probability(0.5, 1), 0.5)
        -- P(at least one in 2 tries with p=0.5) = 1 - 0.5^2 = 0.75
        Assert.equals(Utils.occurrence_probability(0.5, 2), 0.75)
    end
)

---------------------------------------------------------------------------------------------------
-- << greatest_common_divisor / lowest_common_multiple >>

Tirislib.Testing.add_test_case(
    "greatest_common_divisor computes correctly",
    "lib.utils",
    function()
        Assert.equals(Utils.greatest_common_divisor(12, 8), 4)
        Assert.equals(Utils.greatest_common_divisor(7, 3), 1)
        Assert.equals(Utils.greatest_common_divisor(100, 25), 25)
        Assert.equals(Utils.greatest_common_divisor(0, 5), 5)
    end
)

Tirislib.Testing.add_test_case(
    "lowest_common_multiple computes correctly",
    "lib.utils",
    function()
        Assert.equals(Utils.lowest_common_multiple(4, 6), 12)
        Assert.equals(Utils.lowest_common_multiple(7, 3), 21)
        Assert.equals(Utils.lowest_common_multiple(5, 5), 5)
        Assert.equals(Utils.lowest_common_multiple(0, 5), 0)
    end
)

---------------------------------------------------------------------------------------------------
-- << maximum_metric_distance >>

Tirislib.Testing.add_test_case(
    "maximum_metric_distance returns the Chebyshev distance",
    "lib.utils",
    function()
        Assert.equals(Utils.maximum_metric_distance(0, 0, 3, 5), 5)
        Assert.equals(Utils.maximum_metric_distance(0, 0, 5, 3), 5)
        Assert.equals(Utils.maximum_metric_distance(1, 1, 4, 4), 3)
        Assert.equals(Utils.maximum_metric_distance(0, 0, 0, 0), 0)
    end
)

---------------------------------------------------------------------------------------------------
-- << n_metric_distance >>

Tirislib.Testing.add_test_case(
    "n_metric_distance returns Euclidean distance for n=2",
    "lib.utils",
    function()
        Assert.equals(Utils.n_metric_distance(2, 0, 0, 3, 4), 5)
        Assert.equals(Utils.n_metric_distance(2, 0, 0, 0, 0), 0)
    end
)

Tirislib.Testing.add_test_case(
    "n_metric_distance works with negative coordinates",
    "lib.utils",
    function()
        -- same distance as (0,0) to (3,4) - the fix for negative differences
        Assert.equals(Utils.n_metric_distance(2, 0, 0, -3, -4), 5)
        Assert.equals(Utils.n_metric_distance(3, 0, 0, -1, -1), Utils.n_metric_distance(3, 0, 0, 1, 1))
    end
)

---------------------------------------------------------------------------------------------------
-- << version_is_smaller_than >>

Tirislib.Testing.add_test_case(
    "version_is_smaller_than compares equal-length versions",
    "lib.utils",
    function()
        Assert.is_true(Utils.version_is_smaller_than("1.0.0", "2.0.0"))
        Assert.is_true(Utils.version_is_smaller_than("1.0.0", "1.1.0"))
        Assert.is_true(Utils.version_is_smaller_than("1.0.0", "1.0.1"))
        Assert.is_false(Utils.version_is_smaller_than("2.0.0", "1.0.0"))
        Assert.is_false(Utils.version_is_smaller_than("1.0.0", "1.0.0"))
    end
)

Tirislib.Testing.add_test_case(
    "version_is_smaller_than handles different-length versions",
    "lib.utils",
    function()
        Assert.is_true(Utils.version_is_smaller_than("1.2", "1.2.3"))
        Assert.is_false(Utils.version_is_smaller_than("1.2.3", "1.2"))
        Assert.is_false(Utils.version_is_smaller_than("1.2.0", "1.2"))
    end
)

---------------------------------------------------------------------------------------------------
-- << update_progress >>

Tirislib.Testing.add_test_case(
    "update_progress accumulates progress and returns full counts",
    "lib.utils",
    function()
        local tbl = {progress = 0}
        Assert.equals(Utils.update_progress(tbl, "progress", 0.4), 0)
        Assert.equals(Utils.update_progress(tbl, "progress", 0.4), 0)
        Assert.equals(Utils.update_progress(tbl, "progress", 0.4), 1)
        -- remainder should be close to 0.2
        Assert.greater_than(tbl.progress, 0.19)
        Assert.less_than(tbl.progress, 0.21)
    end
)

Tirislib.Testing.add_test_case(
    "update_progress handles whole number deltas",
    "lib.utils",
    function()
        local tbl = {p = 0}
        Assert.equals(Utils.update_progress(tbl, "p", 3), 3)
        Assert.equals(tbl.p, 0)
    end
)

---------------------------------------------------------------------------------------------------
-- << dice_rolls >>

Tirislib.Testing.add_test_case(
    "dice_rolls returns the correct number of rolls",
    "lib.utils",
    function()
        local dice = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}

        -- count > actual count, modulo == 0
        local rolls = Tirislib.Utils.dice_rolls(dice, 500, 20)
        Assert.equals(Tirislib.Tables.sum(rolls), 500)

        -- count > actual count, modulo ~= 0
        rolls = Tirislib.Utils.dice_rolls(dice, 37, 20)
        Assert.equals(Tirislib.Tables.sum(rolls), 37)

        -- count == actual count
        rolls = Tirislib.Utils.dice_rolls(dice, 20, 20)
        Assert.equals(Tirislib.Tables.sum(rolls), 20)

        -- count < actual count
        rolls = Tirislib.Utils.dice_rolls(dice, 20, 100)
        Assert.equals(Tirislib.Tables.sum(rolls), 20)

        -- count == 0
        rolls = Tirislib.Utils.dice_rolls(dice, 0)
        Assert.equals(Tirislib.Tables.sum(rolls), 0)
    end
)

Tirislib.Testing.add_test_case(
    "dice_rolls returns a table with the dice's keys",
    "lib.utils",
    function()
        local dice = {[1] = 1, ["a string"] = 1, [true] = 1, [false] = 1, [{}] = 1}
        local rolls = Tirislib.Utils.dice_rolls(dice, 10, 10)

        for key in pairs(rolls) do
            Assert.not_nil(dice[key])
        end
        for key in pairs(dice) do
            Assert.not_nil(rolls[key])
        end
    end
)

