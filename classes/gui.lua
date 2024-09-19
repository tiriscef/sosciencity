--- Static class for all the gui stuff.
Gui = {}

--[[
    Data this class stores in global
    --------------------------------
    global.details_view: table
        [player_id]: unit_number (of the entity whose details are watched by the player)
]]
-- local often used globals for microscopic performance gains

local global
local Register = Register

---------------------------------------------------------------------------------------------------
-- << lua state lifecycle stuff >>

local function set_locals()
    global = _ENV.global
end

--- Initialize the guis for all existing players.
function Gui.init()
    set_locals()
    global.details_view = {}

    for _, player in pairs(game.players) do
        Gui.create_guis(player)
    end
end

function Gui.load()
    set_locals()
end

---------------------------------------------------------------------------------------------------
-- << handlers >>
---------------------------------------------------------------------------------------------------

--- This should be added to every gui element which needs an event handler,
--- because the gui event handlers get fired for every gui in existance.
--- So I need to ensure that I'm not reacting to another mods gui.
--- TODO make all gui elements that use this use the tag system
Gui.unique_prefix_builder = "sosciencity-%s-%s"

--- Generic handler that verifies that the gui element belongs to my mod, looks for an event handler function and calls it.
local function look_for_event_handler(event, lookup)
    local gui_element = event.element
    local name = gui_element.name

    local handler = lookup[name]

    if handler then
        local player_id = event.player_index
        local entry = Register.try_get(global.details_view[player_id])

        handler[1](entry, gui_element, player_id, unpack(handler[2]))
        return true
    end

    return false
end

local function look_for_event_handler_by_tag(event, lookup)
    local tag = event.element.tags.sosciencity_gui_event

    if tag == nil then
        return
    end

    local handler = lookup[tag]
    if handler then
        handler(event)
    end
end

--- Lookup for click event handlers.
--- [element name]: table
---     [1]: function
---     [2]: array of arguments
local click_lookup_name = {}

--- Sets the 'on_gui_click' event handler for a gui element with the given name. Additional arguments for the call can be specified.\
--- Params for the event handler function: (entry, gui_element, player_id, [additional params])
--- @param name string
--- @param fn function
function Gui.set_click_handler(name, fn, ...)
    Tirislib.Utils.desync_protection()
    click_lookup_name[name] = {fn, {...}}
end

--- Lookup for click event handlers by tag.
--- [tag]: function
local click_lookup_tag = {}

--- Sets the 'on_gui_click' event handler for gui elements with the given 'sosciencity_gui_event'-tag.
--- @param tag string
--- @param fn function
function Gui.set_click_handler_tag(tag, fn)
    Tirislib.Utils.desync_protection()
    click_lookup_tag[tag] = fn
end

--- Event handler for Gui click events
function Gui.on_gui_click(event)
    return (look_for_event_handler(event, click_lookup_name) or look_for_event_handler_by_tag(event, click_lookup_tag))
end

--- Lookup for checkbox click event handlers.
--- [element name]: table
---     [1]: function
---     [2]: array of arguments
local checkbox_click_lookup = {}

--- Sets the 'on_gui_checked_state_changed' event handler for a gui element with the given name. Additional arguments for the call can be specified.\
--- Params for the event handler function: (entry, gui_element, player_id, [additional params])
--- @param name string
--- @param fn function
function Gui.set_checked_state_handler(name, fn, ...)
    Tirislib.Utils.desync_protection()
    checkbox_click_lookup[name] = {fn, {...}}
end

--- Event handler for checkbox/radiobuttom click events
function Gui.on_gui_checked_state_changed(event)
    look_for_event_handler(event, checkbox_click_lookup)
end

--- Lookup for slider event handlers.
--- [element name]: table
---     [1]: function
---     [2]: array of arguments
local value_changed_lookup = {}

--- Sets the 'on_gui_value_changed' event handler for a gui element with the given name. Additional arguments for the call can be specified.\
--- Params for the event handler function: (entry, gui_element, player_id, [additional params])
--- @param name string
--- @param fn function
function Gui.set_value_changed_handler(name, fn, ...)
    Tirislib.Utils.desync_protection()
    value_changed_lookup[name] = {fn, {...}}
end

--- Event handler for slider change events
function Gui.on_gui_value_changed(event)
    look_for_event_handler(event, value_changed_lookup)
end

--- Lookup for gui confirmed event handlers.
--- [element name]: table
---     [1]: function
---     [2]: array of arguments
local gui_confirmed_lookup = {}

--- Sets the 'on_gui_confirmed' event handler for a gui element with the given name. Additional arguments for the call can be specified.\
--- Params for the event handler function: (entry, gui_element, player_id, [additional params])
--- @param name string
--- @param fn function
function Gui.set_gui_confirmed_handler(name, fn, ...)
    Tirislib.Utils.desync_protection()
    gui_confirmed_lookup[name] = {fn, {...}}
end

--- Event handler for confirmed guis
function Gui.on_gui_confirmed(event)
    look_for_event_handler(event, gui_confirmed_lookup)
end

--- Array of functions to be called on the on_gui_closed-event.
local gui_closed_handlers = {}

--- Adds a 'on_gui_closed' event handler.
--- @param fn function
function Gui.add_gui_closed_handler(fn)
    Tirislib.Utils.desync_protection()
    gui_closed_handlers[#gui_closed_handlers + 1] = fn
end

--- Event handler for closed guis.
function Gui.on_gui_closed(event)
    local player = game.players[event.player_index]

    for _, fn in pairs(gui_closed_handlers) do
        fn(player, event)
    end
end

--- Array of functions to be called on the on_gui_opened-event.
local gui_opened_handlers = {}

--- Adds a 'on_gui_closed' event handler.
--- @param fn function
function Gui.add_gui_opened_handler(fn)
    Tirislib.Utils.desync_protection()
    gui_opened_handlers[#gui_opened_handlers + 1] = fn
end

--- Event handler for closed guis.
function Gui.on_gui_opened(event)
    local player = game.players[event.player_index]

    for _, fn in pairs(gui_opened_handlers) do
        fn(player, event)
    end
end

--- Initializes the guis for the given player. Has to be called after a new player gets created.
--- @param player Player
function Gui.create_guis(player)
    Gui.CityInfo.create(player)
    Gui.DetailsView.create(player)
end

--- Updates all the guis.
function Gui.update_guis()
    Gui.CityInfo.update()
    Gui.DetailsView.update()
end

--- Resets all the guis for after an update.
function Gui.reset_guis()
    for _, player in pairs(game.players) do
        -- we just destroy the persistent ones, because they get automatically recreated when lost anyway
        Gui.CityInfo.destroy(player)
        Gui.DetailsView.destroy(player)

        Gui.CityView.close(player)
    end
end

require("classes.guis.elements")
require("classes.guis.city-info")
require("classes.guis.city-view")
require("classes.guis.details-view")

return Gui
