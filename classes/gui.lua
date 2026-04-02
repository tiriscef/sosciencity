--- Static class for all the gui stuff.
Gui = {}

--[[
    Data this class stores in storage
    --------------------------------
    storage.details_view: table
        [player_id]: unit_number (of the entity whose details are being watched by the player)
    storage.gui_elements: table
        [context]: table  (any value that groups related elements, e.g. a unit_number or a string)
            [key]: table
                [player_id]: LuaGuiElement
]]
-- local often used globals for microscopic performance gains

local storage

---------------------------------------------------------------------------------------------------
-- << lua state lifecycle stuff >>

local function set_locals()
    storage = _ENV.storage
end

--- Initialize the guis for all existing players.
function Gui.init()
    set_locals()
    storage.details_view = {}
    storage.gui_elements = {}

    for _, player in pairs(game.players) do
        Gui.create_guis(player)
    end
end

function Gui.load()
    set_locals()
end

---------------------------------------------------------------------------------------------------
-- << element registry >>
---------------------------------------------------------------------------------------------------

--- Registers a gui element so it can be retrieved by e.g. event handlers.
--- context can be any value that groups related elements, e.g. a unit_number or a specific string.
--- @param element LuaGuiElement
--- @param context any
--- @param key string
--- @param player_id integer
function Gui.register_element(element, context, key, player_id)
    local by_context = storage.gui_elements[context]
    if not by_context then
        by_context = {}
        storage.gui_elements[context] = by_context
    end
    local by_key = by_context[key]
    if not by_key then
        by_key = {}
        by_context[key] = by_key
    end
    by_key[player_id] = element
end

--- Returns all registered elements for the given context and key, keyed by player_id.
--- @param context any
--- @param key string
--- @return table
function Gui.get_elements(context, key)
    local by_context = storage.gui_elements[context]
    if not by_context then
        return {}
    end
    return by_context[key] or {}
end

--- Removes all registered elements for the given player.
--- Should be called when the player's gui is closed or rebuilt.
--- @param player_id integer
function Gui.unregister_player(player_id)
    for _, by_context in pairs(storage.gui_elements) do
        for _, by_key in pairs(by_context) do
            by_key[player_id] = nil
        end
    end
end

--- Removes all registered elements for the given context.
--- @param context any
function Gui.unregister_context(context)
    storage.gui_elements[context] = nil
end

---------------------------------------------------------------------------------------------------
-- << handlers >>
---------------------------------------------------------------------------------------------------

--- Unique prefix used for naming gui elements to avoid conflicts with other mods.
Gui.unique_prefix_builder = "sosciencity-%s-%s"

local function set_gui_handler(lookup, key, fn, name)
    Tirislib.Utils.desync_protection()
    if lookup[key] then
        error("Duplicate " .. name .. " handler registration for tag '" .. tostring(key) .. "'")
    end
    lookup[key] = fn
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

--- Lookup for click event handlers by tag.
--- [tag]: function
local click_lookup_tag = {}

--- Sets the 'on_gui_click' event handler for gui elements with the given 'sosciencity_gui_event'-tag.
--- @param tag string
--- @param fn function
function Gui.set_click_handler(tag, fn)
    set_gui_handler(click_lookup_tag, tag, fn, "click")
end

--- Event handler for Gui click events
function Gui.on_gui_click(event)
    look_for_event_handler_by_tag(event, click_lookup_tag)
end

--- Lookup for checked state event handlers by tag.
--- [tag]: function
local checked_state_lookup_tag = {}

--- Sets the 'on_gui_checked_state_changed' event handler for gui elements with the given 'sosciencity_gui_event'-tag.
--- @param tag string
--- @param fn function
function Gui.set_checked_state_handler(tag, fn)
    set_gui_handler(checked_state_lookup_tag, tag, fn, "checked_state")
end

--- Event handler for checkbox/radiobutton click events
function Gui.on_gui_checked_state_changed(event)
    look_for_event_handler_by_tag(event, checked_state_lookup_tag)
end

--- Lookup for value changed event handlers by tag.
--- [tag]: function
local value_changed_lookup_tag = {}

--- Sets the 'on_gui_value_changed' event handler for gui elements with the given 'sosciencity_gui_event'-tag.
--- @param tag string
--- @param fn function
function Gui.set_value_changed_handler(tag, fn)
    set_gui_handler(value_changed_lookup_tag, tag, fn, "value_changed")
end

--- Event handler for slider change events
function Gui.on_gui_value_changed(event)
    look_for_event_handler_by_tag(event, value_changed_lookup_tag)
end

--- Lookup for gui confirmed event handlers by tag.
--- [tag]: function
local gui_confirmed_lookup_tag = {}

--- Sets the 'on_gui_confirmed' event handler for gui elements with the given 'sosciencity_gui_event'-tag.
--- @param tag string
--- @param fn function
function Gui.set_gui_confirmed_handler(tag, fn)
    set_gui_handler(gui_confirmed_lookup_tag, tag, fn, "gui_confirmed")
end

--- Event handler for confirmed guis
function Gui.on_gui_confirmed(event)
    look_for_event_handler_by_tag(event, gui_confirmed_lookup_tag)
end

--- Lookup for text changed event handlers by tag.
--- [tag]: function
local text_changed_lookup_tag = {}

--- Sets the 'on_gui_text_changed' event handler for gui elements with the given 'sosciencity_gui_event'-tag.
--- @param tag string
--- @param fn function
function Gui.set_text_changed_handler(tag, fn)
    set_gui_handler(text_changed_lookup_tag, tag, fn, "text_changed")
end

--- Event handler for text changed events
function Gui.on_gui_text_changed(event)
    look_for_event_handler_by_tag(event, text_changed_lookup_tag)
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
    local player = game.get_player(event.player_index)

    for _, fn in pairs(gui_closed_handlers) do
        fn(player, event)
    end
end

--- Array of functions to be called on the on_gui_opened-event.
local gui_opened_handlers = {}

--- Adds a 'on_gui_opened' event handler.
--- @param fn function
function Gui.add_gui_opened_handler(fn)
    Tirislib.Utils.desync_protection()
    gui_opened_handlers[#gui_opened_handlers + 1] = fn
end

--- Event handler for opened guis.
function Gui.on_gui_opened(event)
    local player = game.get_player(event.player_index)

    for _, fn in pairs(gui_opened_handlers) do
        fn(player, event)
    end
end

--- Initializes the guis for the given player. Has to be called after a new player gets created.
--- @param player LuaPlayer
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
