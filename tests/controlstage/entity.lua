local Assert = Tirislib.Testing.Assert

---------------------------------------------------------------------------------------------------
-- << get_speed_from_performance >>

Tirislib.Testing.add_test_case(
    "get_speed_from_performance: full performance 1.0 gives no bonus",
    "entity|entity.math",
    function()
        Assert.equals(Entity.get_speed_from_performance(1.0), 0)
    end
)

Tirislib.Testing.add_test_case(
    "get_speed_from_performance: the minimum active performance stays above the engine's floor",
    "entity|entity.math",
    function()
        Assert.greater_than(Entity.get_speed_from_performance(Entity.MINIMUM_PERFORMANCE), -100)
    end
)

Tirislib.Testing.add_test_case(
    "get_speed_from_performance: maps linearly across the range",
    "entity|entity.math",
    function()
        Assert.equals(Entity.get_speed_from_performance(0.0), -100)
        Assert.equals(Entity.get_speed_from_performance(0.5), -50)
        Assert.equals(Entity.get_speed_from_performance(1.5), 50)
    end
)

---------------------------------------------------------------------------------------------------
-- << multiply_percentages >>

Tirislib.Testing.add_test_case(
    "multiply_percentages: no arguments returns 0",
    "entity|entity.math",
    function()
        Assert.equals(Entity.multiply_percentages(), 0)
    end
)

Tirislib.Testing.add_test_case(
    "multiply_percentages: zero bonus returns 0",
    "entity|entity.math",
    function()
        Assert.equals(Entity.multiply_percentages(0), 0)
        Assert.equals(Entity.multiply_percentages(0, 0), 0)
    end
)

Tirislib.Testing.add_test_case(
    "multiply_percentages: single 100% bonus returns 100",
    "entity|entity.math",
    function()
        Assert.equals(Entity.multiply_percentages(100), 100)
    end
)

Tirislib.Testing.add_test_case(
    "multiply_percentages: two 100% bonuses combine to 300 not 200",
    "entity|entity.math",
    function()
        Assert.equals(Entity.multiply_percentages(100, 100), 300)
    end
)

Tirislib.Testing.add_test_case(
    "multiply_percentages: combines multiplicatively not additively",
    "entity|entity.math",
    function()
        -- additive 10+10 = 20; multiplicative 1.1*1.1 = 1.21 -> 21
        Assert.equals(Entity.multiply_percentages(10, 10), 21)
    end
)
