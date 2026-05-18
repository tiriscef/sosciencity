local Assert = Tirislib.Testing.Assert

Tirislib.Testing.add_test_case(
    "multi-tick runner: is_multi_tick_run_active returns true during a run",
    "multi-tick-runner",
    function()
        Assert.is_true(Tirislib.Testing.is_multi_tick_run_active())
    end
)

Tirislib.Testing.add_test_case(
    "multi-tick runner: continuation runs after the specified number of ticks",
    "multi-tick-runner",
    function()
        local start_tick = game.tick
        Tirislib.Testing.let_n_ticks_pass(3, function()
            Assert.equals(game.tick, start_tick + 3, "continuation should run exactly 3 ticks after the test body")
        end)
    end
)

Tirislib.Testing.add_test_case(
    "multi-tick runner: continuations can be chained for sequential waits",
    "multi-tick-runner",
    function()
        local start_tick = game.tick
        Tirislib.Testing.let_n_ticks_pass(2, function()
            Assert.equals(game.tick, start_tick + 2, "first continuation: 2 ticks after start")
            Tirislib.Testing.let_n_ticks_pass(3, function()
                Assert.equals(game.tick, start_tick + 5, "second continuation: 5 ticks after start")
            end)
        end)
    end
)

Tirislib.Testing.add_test_case(
    "multi-tick runner: let_one_tick_pass runs continuation exactly 1 tick later",
    "multi-tick-runner",
    function()
        local start_tick = game.tick
        Tirislib.Testing.let_one_tick_pass(function()
            Assert.equals(game.tick, start_tick + 1, "continuation should run 1 tick after the test body")
        end)
    end
)

Tirislib.Testing.add_test_case(
    "multi-tick runner: wait_until runs continuation on the tick the condition becomes true",
    "multi-tick-runner",
    function()
        local checks = 0
        Tirislib.Testing.wait_until(
            function()
                checks = checks + 1
                return checks >= 3
            end,
            10,
            function()
                Assert.equals(checks, 3, "condition should have been polled exactly 3 times before becoming true")
            end
        )
    end
)
