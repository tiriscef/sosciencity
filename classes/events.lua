--- Static class for registering event handlers.
local Events = {}

local on_init_handlers = {}

--- Adds a function to be called during the init-Phase.
--- @param fn function
function Events.set_on_init_handler(fn)
    Tirislib.Utils.desync_protection()
    on_init_handlers[#on_init_handlers + 1] = fn
end

--- Calls every registered init handler, in registration order.
function Events.run_on_init_handlers()
    for _, fn in pairs(on_init_handlers) do
        fn()
    end
end

local on_script_trigger_handlers = {}

--- Adds a function to be called when a script trigger with a specified id is being... triggered.
--- @param id string
--- @param fn function
function Events.set_script_trigger_handler(id, fn)
    Tirislib.Utils.desync_protection()
    if on_script_trigger_handlers[id] then
        error("Duplicate script_trigger handler registration for id '" .. tostring(id) .. "'")
    end
    on_script_trigger_handlers[id] = fn
end

--- Calls the handler registered for the given script trigger event, if there is one.
--- @param event table
function Events.run_script_trigger_handler(event)
    local fn = on_script_trigger_handlers[event.effect_id]

    if fn then
        fn(event)
    end
end

return Events
