-- Automated test runner scenario.

script.on_event(defines.events.on_tick, function()
    script.on_event(defines.events.on_tick, nil)
    remote.call("sosciencity_tests", "run")
end)
