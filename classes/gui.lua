-- enums
local EK = require("enums.entry-key")

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
local format = string.format

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
        Gui.create_guis_for_player(player)
    end
end

function Gui.load()
    set_locals()
end

---------------------------------------------------------------------------------------------------
-- << formatting functions >>
---------------------------------------------------------------------------------------------------

function Gui.get_reasonable_number(number)
    return format("%.1f", number) -- TODO maybe make this a round_to_step
end

function Gui.display_integer_summand(number)
    if number > 0 then
        return format("[color=0,1,0]%+d[/color]", number)
    elseif number < 0 then
        return format("[color=1,0,0]%+d[/color]", number)
    else -- number equals 0
        return "[color=0.8,0.8,0.8]0[/color]"
    end
end

function Gui.display_summand(number)
    if number > 0 then
        return format("[color=0,1,0]%+.1f[/color]", number)
    elseif number < 0 then
        return format("[color=1,0,0]%+.1f[/color]", number)
    else -- number equals 0
        return "[color=0.8,0.8,0.8]0.0[/color]"
    end
end

function Gui.display_factor(number)
    if number > 1 then
        return format("[color=0,1,0]×%.1f[/color]", number)
    elseif number < 1 then
        return format("[color=1,0,0]×%.1f[/color]", number)
    else -- number equals 1
        return "[color=0.8,0.8,0.8]1.0[/color]"
    end
end

function Gui.display_comfort(comfort)
    return {"", comfort, "  -  ", {"comfort-scale." .. comfort}}
end

function Gui.display_migration(number)
    return format("%+.1f", number)
end

function Gui.get_entry_representation(entry)
    local entity = entry[EK.entity]
    local position = entity.position
    return {"sosciencity.entry-representation", entity.localised_name, position.x, position.y}
end

function Gui.display_convergence(current, target)
    return {"sosciencity.convergenting-value", Gui.get_reasonable_number(current), Gui.get_reasonable_number(target)}
end

local mult = " × "
function Gui.display_materials(materials)
    local ret = {""}
    local first = true
    local item_prototypes = game.item_prototypes

    for material, count in pairs(materials) do
        local entry = {""}

        if not first then
            entry[#entry + 1] = "\n"
        end
        first = false

        entry[#entry + 1] = count
        entry[#entry + 1] = mult

        entry[#entry + 1] = format("[item=%s] ", material)
        entry[#entry + 1] = item_prototypes[material].localised_name

        ret[#ret + 1] = entry
    end

    return ret
end

---------------------------------------------------------------------------------------------------
-- << style functions >>
---------------------------------------------------------------------------------------------------

function Gui.set_padding(element, padding)
    local style = element.style
    style.left_padding = padding
    style.right_padding = padding
    style.top_padding = padding
    style.bottom_padding = padding
end

local function make_stretchable(element)
    element.style.horizontally_stretchable = true
    element.style.vertically_stretchable = true
end
Gui.make_stretchable = make_stretchable

function Gui.make_squashable(element)
    element.style.horizontally_squashable = true
    element.style.vertically_squashable = true
end

---------------------------------------------------------------------------------------------------
-- << handlers >>
---------------------------------------------------------------------------------------------------

--- This should be added to every gui element which needs an event handler,
--- because the gui event handlers get fired for every gui in existance.
--- So I need to ensure that I'm not reacting to another mods gui.
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

--- Initializes the guis for the given player. Gets called after a new player gets created.
--- @param player Player
function Gui.create_guis_for_player(player)
    Gui.create_city_info_for_player(player)
    Gui.create_details_view_for_player(player)
end

require("classes.guis.elements")
require("classes.guis.city-info")
require("classes.guis.city-view")
require("classes.guis.details-view")

return Gui
