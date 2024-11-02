--- Static class for planning actions in the future.
Scheduler = {}

--[[
    Data this class stores in storage
    --------------------------------
    storage.schedule: table
        [tick]: array of planned events
]]
--[[
    Structure of a planned event: table
        [1]: name
        [2]: arguments
]]
-- local often used globals for heavy performance gains

local ceil = math.ceil
local schedule

---------------------------------------------------------------------------------------------------
-- << lua state lifecycle stuff >>

local function set_locals()
    schedule = storage.schedule
end

function Scheduler.init()
    storage.schedule = {}
    set_locals()
end

function Scheduler.load()
    set_locals()
end

---------------------------------------------------------------------------------------------------
-- << schedule implementation >>

local event_lookup = {}

--- Sets the function that gets called when the event of the given name is fired.
--- @param name any
--- @param fn function
function Scheduler.set_event(name, fn)
    Tirislib.Utils.desync_protection()
    event_lookup[name] = fn
end

local function fire_event(event)
    local fn = event_lookup[event[1]]

    if fn then
        fn(unpack(event[2]))
    end
end

-- Sosciencity updates once every 10 frames.
local function get_update_index(tick)
    return ceil(tick / 10)
end

--- Schedules an event of the given name after the given amount of ticks.
--- (or up to 9 ticks later because the system checks once every 10 ticks).
--- @param name any
--- @param ticks integer
function Scheduler.plan_event_in(name, ticks, ...)
    local tick = game.tick + ticks
    local index = get_update_index(tick)
    local schedule_table = schedule[index]

    if not schedule_table then
        schedule[index] = {}
        schedule_table = schedule[index]
    end

    schedule_table[#schedule_table + 1] = {name, {...}}
end
local schedule_in = Scheduler.plan_event_in

--- Schedules an event of the given name for the given tick
--- (or up to 9 ticks later because the system checks once every 10 ticks).
--- @param name any
--- @param tick integer
function Scheduler.plan_event(name, tick, ...)
    local current_tick = game.tick
    local ticks = tick - current_tick
    if ticks <= 0 then
        error("Sosciencity got confused with its grasp on linear time and tried to schedule an event for the past.")
    end

    schedule_in(name, ticks, ...)
end

--- Looks for and fires all planned events for this update cycle.
function Scheduler.update(current_tick)
    local index = get_update_index(current_tick)
    local events = schedule[index]

    if events then
        -- fire them all
        for i = 1, #events do
            fire_event(events[i])
        end

        -- delete the evidence
        schedule[index] = nil
    end
end

return Scheduler
