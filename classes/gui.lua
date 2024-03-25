-- enums
local EK = require("enums.entry-key")

-- constants
local Castes = require("constants.castes")

--- Static class for all the gui stuff.
Gui = {}

--[[
    Data this class stores in global
    --------------------------------
    global.details_view: table
        [player_id]: unit_number (of the entity whose details are watched by the player)
]]
-- local often used globals for microscopic performance gains

local castes = Castes.values
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
    end
end

--- Lookup for click event handlers.
--- [element name]: table
---     [1]: function
---     [2]: array of arguments
local click_lookup = {}

--- Sets the 'on_gui_click' event handler for a gui element with the given name. Additional arguments for the call can be specified.\
--- Params for the event handler function: (entry, gui_element, player_id, [additional params])
--- @param name string
--- @param fn function
function Gui.set_click_handler(name, fn, ...)
    Tirislib.Utils.desync_protection()
    click_lookup[name] = {fn, {...}}
end

--- Event handler for Gui click events
function Gui.on_gui_click(event)
    look_for_event_handler(event, click_lookup)
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

---------------------------------------------------------------------------------------------------
-- << gui elements >>
---------------------------------------------------------------------------------------------------

local DATA_LIST_DEFAULT_NAME = "datalist"
function Gui.create_data_list(container, name, columns)
    local datatable =
        container.add {
        type = "table",
        name = name or DATA_LIST_DEFAULT_NAME,
        column_count = columns or 2,
        style = "bordered_table"
    }
    local style = datatable.style
    style.horizontally_stretchable = true
    style.right_cell_padding = 6
    style.left_cell_padding = 6

    return datatable
end

function Gui.add_key_label(data_list, key, key_caption, key_font)
    local key_label =
        data_list.add {
        type = "label",
        name = "key-" .. key,
        caption = key_caption
    }
    key_label.style.font = key_font or "default-bold"
end
local add_key_label = Gui.add_key_label

function Gui.add_kv_pair(data_list, key, key_caption, value_caption, key_font, value_font)
    add_key_label(data_list, key, key_caption, key_font)

    local value_label =
        data_list.add {
        type = "label",
        name = key,
        caption = value_caption
    }
    local style = value_label.style
    style.horizontally_stretchable = true
    style.single_line = false

    if value_font then
        style.font = value_font
    end
end

function Gui.add_kv_flow(data_list, key, key_caption, key_font, direction)
    add_key_label(data_list, key, key_caption, key_font)

    local value_flow =
        data_list.add {
        type = "flow",
        name = key,
        direction = direction or "vertical"
    }

    return value_flow
end
local add_kv_flow = Gui.add_kv_flow

function Gui.add_kv_checkbox(data_list, key, checkbox_name, key_caption, checkbox_caption, key_font, checkbox_font)
    local flow = add_kv_flow(data_list, key, key_caption, key_font, "horizontal")
    flow.style.vertical_align = "center"

    local checkbox =
        flow.add {
        type = "checkbox",
        name = checkbox_name,
        state = true
    }

    local label =
        flow.add {
        type = "label",
        name = "label",
        caption = checkbox_caption
    }
    local style = label.style
    style.left_padding = 6
    style.horizontally_stretchable = true

    if checkbox_font then
        style.font = checkbox_font
    end

    return checkbox, label
end

function Gui.add_kv_textfield(data_list, key, textfield_name, params, key_caption, key_font)
    add_key_label(data_list, key, key_caption, key_font)

    local textfield_params = {
        type = "textfield",
        name = textfield_name
    }
    Tirislib.Tables.merge(textfield_params, params or {})

    local textfield = data_list.add(textfield_params)
    textfield.style.width = 150

    return textfield
end

function Gui.get_checkbox(data_list, key)
    local children = data_list[key].children
    return children[1], children[2]
end

local function get_kv_pair(data_list, key)
    return data_list["key-" .. key], data_list[key]
end

function Gui.get_kv_value_element(data_list, key)
    return data_list[key]
end

local function set_key(data_list, key, key_caption)
    data_list["key-" .. key].caption = key_caption
end

function Gui.set_kv_pair_value(data_list, key, value_caption)
    data_list[key].caption = value_caption
end
local set_kv_pair_value = Gui.set_kv_pair_value

function Gui.set_datalist_value_tooltip(datalist, key, tooltip)
    datalist[key].tooltip = tooltip
end

function Gui.set_kv_pair_tooltip(datalist, key, tooltip)
    local key_element, value_element = get_kv_pair(datalist, key)
    key_element.tooltip = tooltip
    value_element.tooltip = tooltip
end

function Gui.set_kv_pair_visibility(datalist, key, visibility)
    datalist["key-" .. key].visible = visibility
    datalist[key].visible = visibility
end
local set_kv_pair_visibility = Gui.set_kv_pair_visibility

local function add_final_value_entry(data_list, caption)
    local sum_key =
        data_list.add {
        type = "label",
        name = "key-sum",
        caption = caption
    }
    local style = sum_key.style
    style.font = "default-bold"
    style.horizontally_stretchable = true

    local sum_value =
        data_list.add {
        type = "label",
        name = "sum"
    }
    style = sum_value.style
    style.width = 50
    style.font = "default-bold"
    style.horizontal_align = "right"
end

function Gui.add_operand_entry(data_list, key, key_caption, value_caption, description)
    local key_label =
        data_list.add {
        type = "label",
        name = "key-" .. key,
        caption = key_caption,
        tooltip = description
    }
    local key_style = key_label.style
    key_style.horizontally_stretchable = true
    key_style.single_line = false

    local value_label =
        data_list.add {
        type = "label",
        name = key,
        caption = value_caption
    }
    local value_style = value_label.style
    value_style.horizontal_align = "right"
    value_style.width = 50
end
local add_operand_entry = Gui.add_operand_entry

local function add_entries(data_list, enum_table, names, descriptions)
    for name, id in pairs(enum_table) do
        add_operand_entry(data_list, name, names[id], nil, descriptions[id])
    end
end

function Gui.create_operand_entries(
    data_list,
    final_caption,
    summands_enums,
    summand_localised,
    summand_descriptions,
    factor_enums,
    factor_localised,
    factor_descriptions)
    add_final_value_entry(data_list, final_caption)
    add_entries(data_list, summands_enums, summand_localised, summand_descriptions)
    add_entries(data_list, factor_enums, factor_localised, factor_descriptions)
end

function Gui.update_operand_entries(data_list, final_value, summands, summand_enums, factors, factor_enums)
    data_list["sum"].caption = Gui.display_summand(final_value)

    for name, id in pairs(summand_enums) do
        local value = summands[id]

        if value ~= 0 then
            set_kv_pair_value(data_list, name, Gui.display_summand(value))
            set_kv_pair_visibility(data_list, name, true)
        else
            set_kv_pair_visibility(data_list, name, false)
        end
    end

    for name, id in pairs(factor_enums) do
        local value = factors[id]

        if value ~= 1. then
            set_kv_pair_value(data_list, name, Gui.display_factor(value))
            set_kv_pair_visibility(data_list, name, true)
        else
            set_kv_pair_visibility(data_list, name, false)
        end
    end
end

local function is_confirmed(button)
    local caption = button.caption[1]
    if caption == "sosciencity.confirm" then
        return true
    else
        button.caption = {"sosciencity.confirm"}
        button.tooltip = {"sosciencity.confirm-tooltip"}
        return false
    end
end

function Gui.create_caste_sprite(container, caste_id, size)
    local caste = castes[caste_id]

    local sprite =
        container.add {
        type = "sprite",
        name = "caste-sprite",
        sprite = "technology/" .. caste.name .. "-caste"
    }
    local style = sprite.style
    style.height = size
    style.width = size
    style.stretch_image_to_widget_size = true

    return sprite
end

function Gui.create_tab(tabbed_pane, name, caption)
    local tab =
        tabbed_pane.add {
        type = "tab",
        name = name .. "tab",
        caption = caption
    }
    local scrollpane =
        tabbed_pane.add {
        type = "scroll-pane",
        name = name
    }
    local flow =
        scrollpane.add {
        type = "flow",
        name = "flow",
        direction = "vertical"
    }
    make_stretchable(flow)

    tabbed_pane.add_tab(tab, scrollpane)

    return flow
end

function Gui.get_tab_contents(tabbed_pane, name)
    return tabbed_pane[name].flow
end

local function get_unused_name(container, name)
    if not container[name] then
        return name
    end

    local i = 1
    while true do
        local possible_name = name .. i
        if not container[possible_name] then
            return possible_name
        end
        i = i + 1
    end
end

function Gui.create_separator_line(container, name)
    return container.add {
        type = "line",
        name = get_unused_name(name or "line"),
        direction = "horizontal"
    }
end

function Gui.add_header_label(container, name, caption)
    local flow =
        container.add {
        type = "flow",
        name = name,
        direction = "horizontal"
    }
    flow.style.horizontally_stretchable = true
    flow.style.horizontal_align = "center"

    local header =
        flow.add {
        type = "label",
        name = name,
        caption = caption
    }
    header.style.font = "default-bold"
end

--- Initializes the guis for the given player. Gets called after a new player gets created.
--- @param player Player
function Gui.create_guis_for_player(player)
    Gui.create_city_info_for_player(player)
    Gui.create_details_view_for_player(player)
end

---------------------------------------------------------------------------------------------------
-- << city view / wiki >>
---------------------------------------------------------------------------------------------------

local CITY_VIEW_NAME = "sosciencity-city-view"

local function create_city_view(player)
    local city_view_frame =
        player.gui.screen.add {
        type = "frame",
        name = CITY_VIEW_NAME,
        direction = "vertical"
    }

    local header =
        city_view_frame.add {
        type = "flow",
        name = "header",
        direction = "horizontal"
    }
    header.drag_target = city_view_frame

    header.add {
        type = "label",
        ignored_by_interaction = true,
        caption = {"sosciencity.city"}
    }
    header.add {
        type = "empty-widget",
        ignored_by_interaction = true,
        style = "sosciencity_header_drag"
    }
    header.add {
        type = "sprite-button",
        name = "sosciencity-close-city-view",
        sprite = "utility/close_white",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black",
        style = "close_button"
    }

    local content_flow = city_view_frame.add {
        type = "flow",
        name = "content-flow",
        direction = "horizontal",
    }

    local pages_frame = content_flow.add {
        type = "frame",
        name = "pages-frame",
        direction = "vertical",
        style = "inside_deep_frame"
    }
    local pages_scroll_pane = pages_frame.add {
        type = "scroll-pane",
        name = "pages-scroll-pane",
        direction = "vertical",
        vertical_scroll_policy = "auto",
        style = "sosciencity_pages_scroll_pane"
    }
    -- populate it with pages here

    local content_frame = content_flow.add {
        type = "frame",
        name = "content-frame",
        direction = "vertical",
        style = "inside_shallow_frame"
    }
    local content_scroll_pane = content_frame.add {
        type = "scroll-pane",
        name = "content-scroll-pane",
        style = "naked_scroll_pane"
    }

    city_view_frame.force_auto_center()
end

local function toggle_city_view_opened(player)
    local gui = player.gui.screen[CITY_VIEW_NAME]
    if gui then
        gui.destroy()
    else
        create_city_view(player)
    end
end

local function get_city_view(player)
    return player.gui.screen[CITY_VIEW_NAME]
end

local function handle_toggle_events(_, _, player_id)
    toggle_city_view_opened(game.players[player_id])
end

-- events that should open or close the city view
Gui.set_click_handler("sosciencity-open-city-view", handle_toggle_events)
Gui.set_click_handler("sosciencity-close-city-view", handle_toggle_events)

require("classes.guis.city-info")
require("classes.guis.city-view")
require("classes.guis.details-view")

return Gui
