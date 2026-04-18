local Castes = require("constants.castes")

Gui.Elements = {}

---------------------------------------------------------------------------------------------------
-- << Utils >>
---------------------------------------------------------------------------------------------------

Gui.Elements.Utils = {}

function Gui.Elements.Utils.is_confirmed(button)
    local caption = button.caption[1]
    if caption == "sosciencity.confirm" then
        return true
    else
        button.caption = {"sosciencity.confirm"}
        button.tooltip = {"sosciencity.confirm-tooltip"}
        return false
    end
end

function Gui.Elements.Utils.separator_line(container, name)
    return container.add {
        type = "line",
        name = name,
        direction = "horizontal"
    }
end

---------------------------------------------------------------------------------------------------
-- << Tables >>
---------------------------------------------------------------------------------------------------

--- A table with 2 rows. Left row has some locales, right row some numbers.\
--- I have no better idea how to call these.
Gui.Elements.CalculationTable = {}

--- Creates a new CalculationTable.\
--- container: LuaGuiElement (where it should be added)\
--- groups: array of GroupSpecifications\
--- left_head: locale, optional (of the left header)
--- @param details table
--- @return LuaGuiElement calctable
function Gui.Elements.CalculationTable.create(details)
    local calctable =
        details.container.add {
        type = "table",
        name = details.name,
        column_count = 2,
        style = "sosciencity_calculation_table"
    }

    details.table = calctable
    Gui.Elements.CalculationTable.rebuild(details)

    return calctable
end

function Gui.Elements.CalculationTable.rebuild(details)
    local calctable = details.table
    calctable.clear()

    if details.left_head then
        calctable.add {
            type = "label",
            caption = details.left_head,
            style = "sosciencity_calculation_table_left_head"
        }
        calctable.add {
            type = "label",
            caption = details.right_head,
            style = "sosciencity_calculation_table_right_head"
        }
    end

    for _, group in pairs(details.groups) do
        for key, value in pairs(group.values) do
            calctable.add {
                type = "label",
                caption = group.left_content and group.left_content(key) or group.left_lookup[key],
                tooltip = group.left_tooltip and group.left_tooltip(key) or nil,
                style = group.left_style or "sosciencity_calculation_table_left"
            }
            calctable.add {
                type = "label",
                caption = group.right_content and group.right_content(value) or group.right_lookup[value],
                style = group.right_style or "sosciencity_calculation_table_right"
            }
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << Datalist >>
---------------------------------------------------------------------------------------------------

--- Class for generic lists
Gui.Elements.Datalist = {}

function Gui.Elements.Datalist.create(container, name, columns)
    local datatable =
        container.add {
        type = "table",
        name = name or "datalist",
        column_count = columns or 2,
        style = "sosciencity_datalist"
    }

    return datatable
end

function Gui.Elements.Datalist.add_key_label(data_list, key, key_caption, key_font)
    local key_label =
        data_list.add {
        type = "label",
        name = "key-" .. key,
        caption = key_caption
    }
    key_label.style.font = key_font or "default-bold"
end
local add_key_label = Gui.Elements.Datalist.add_key_label

function Gui.Elements.Datalist.add_kv_pair(data_list, key, key_caption, value_caption, key_font, value_font)
    add_key_label(data_list, key, key_caption, key_font)

    local value_label =
        data_list.add {
        type = "label",
        name = key,
        caption = value_caption,
        style = "sosciencity_datalist_value"
    }

    if value_font then
        value_label.style.font = value_font
    end
end

function Gui.Elements.Datalist.add_kv_flow(data_list, key, key_caption, key_font, direction)
    add_key_label(data_list, key, key_caption, key_font)

    local value_flow =
        data_list.add {
        type = "flow",
        name = key,
        direction = direction or "vertical"
    }

    return value_flow
end
local add_kv_flow = Gui.Elements.Datalist.add_kv_flow

function Gui.Elements.Datalist.add_kv_checkbox(
    data_list,
    key,
    checkbox_name,
    key_caption,
    checkbox_caption,
    initial_state,
    key_font,
    checkbox_font)
    local flow = add_kv_flow(data_list, key, key_caption, key_font, "horizontal")
    flow.style.vertical_align = "center"

    local checkbox =
        flow.add {
        type = "checkbox",
        name = checkbox_name,
        state = initial_state ~= nil and initial_state or true
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

function Gui.Elements.Datalist.add_kv_textfield(data_list, key, textfield_name, params, key_caption, key_font)
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

function Gui.Elements.Datalist.get_checkbox(data_list, key)
    local children = data_list[key].children
    return children[1], children[2]
end

function Gui.Elements.Datalist.get_kv_pair(data_list, key)
    return data_list["key-" .. key], data_list[key]
end
local get_kv_pair = Gui.Elements.Datalist.get_kv_pair

function Gui.Elements.Datalist.get_kv_value_element(data_list, key)
    return data_list[key]
end

function Gui.Elements.Datalist.set_key(data_list, key, key_caption)
    data_list["key-" .. key].caption = key_caption
end

function Gui.Elements.Datalist.set_kv_pair_value(data_list, key, value_caption)
    data_list[key].caption = value_caption
end
local set_kv_pair_value = Gui.Elements.Datalist.set_kv_pair_value

function Gui.Elements.Datalist.set_datalist_value_tooltip(datalist, key, tooltip)
    datalist[key].tooltip = tooltip
end

function Gui.Elements.Datalist.set_kv_pair_tooltip(datalist, key, tooltip)
    local key_element, value_element = get_kv_pair(datalist, key)
    key_element.tooltip = tooltip
    value_element.tooltip = tooltip
end

function Gui.Elements.Datalist.set_kv_pair_visibility(datalist, key, visibility)
    datalist["key-" .. key].visible = visibility
    datalist[key].visible = visibility
end
local set_kv_pair_visibility = Gui.Elements.Datalist.set_kv_pair_visibility

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

function Gui.Elements.Datalist.add_operand_entry(data_list, key, key_caption, value_caption, description)
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
local add_operand_entry = Gui.Elements.Datalist.add_operand_entry

local function add_entries(data_list, enum_table, names, descriptions)
    for name, id in pairs(enum_table) do
        add_operand_entry(data_list, name, names[id], nil, descriptions[id])
    end
end

function Gui.Elements.Datalist.create_operand_entries(
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

function Gui.Elements.Datalist.update_operand_entries(
    data_list,
    final_value,
    summands,
    summand_enums,
    factors,
    factor_enums)
    data_list["sum"].caption = Locale.summand(final_value)

    for name, id in pairs(summand_enums) do
        local value = summands[id]

        if value ~= nil and value ~= 0 then
            set_kv_pair_value(data_list, name, Locale.summand(value))
            set_kv_pair_visibility(data_list, name, true)
        else
            set_kv_pair_visibility(data_list, name, false)
        end
    end

    for name, id in pairs(factor_enums) do
        local value = factors[id]

        if value ~= nil and value ~= 1. then
            set_kv_pair_value(data_list, name, Locale.factor(value))
            set_kv_pair_visibility(data_list, name, true)
        else
            set_kv_pair_visibility(data_list, name, false)
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << Sortable List >>
---------------------------------------------------------------------------------------------------

--- Class for lists that can be sorted by their columns.
Gui.Elements.SortableList = {}

-- We're stuffing the data and category definitions inside the 'linked' table during startup.
-- Otherwise I don't know a way to implement this without stuffing all this in storage,
-- which I don't want because the data could get outdated and which I can't without dirty
-- workarounds as the category definitions contain functions.

--- Table with (key, list definition) pairs.\
--- \
--- **List defintion**\
--- data: table\
--- categories: array of category definitions\
--- \
--- **Category Definition**
--- > name: anything but nil\
--- > localised_name: locale (for the header button)\
--- > content: function (gets the caption locale from a data entry)\
--- > order: function (creates a comparable value from a data entry)\
--- > tooltip: function, optional (gets the tooltip locale from a data entry)\
--- > style: function, optional (gets the name of a style from a data entry)\
--- > constant_style: string, optional (when there should always be the same style)\
--- > font: function, optional (gets the name of a font from a data entry)\
--- > constant_font: string, optional (when there should always be the same font)\
--- > alignment: Alignment, optional (defaults to "left" for the first column and "right" for all others)
Gui.Elements.SortableList.linked = {}

--- Create a sortable list.
--- @param container LuaGuiElement
--- @param link string key to linked data and categories
--- @return LuaGuiElement table that contains the list
function Gui.Elements.SortableList.create(container, link)
    local category_definitions = Gui.Elements.SortableList.linked[link].categories

    local list =
        container.add {
        type = "table",
        column_count = #category_definitions,
        style = "sosciencity_sortable_list"
    }

    local style = list.style
    for i = 1, #category_definitions do
        style.column_alignments[i] = category_definitions[i].alignment or (i == 1 and "left" or "right")
    end

    Gui.Elements.SortableList.sort_and_rebuild(list, link, nil, "unsorted")

    return list
end

local function get_selected_category(category_definitions, name)
    for _, category in pairs(category_definitions) do
        if category.name == name then
            return category
        end
    end
end

function Gui.Elements.SortableList.comparator_ascending(a, b)
    return a.order < b.order
end

function Gui.Elements.SortableList.comparator_descending(a, b)
    return a.order > b.order
end

Gui.Elements.SortableList.next_sort_modes = {
    unsorted = "ascending",
    ascending = "descending",
    descending = "ascending"
}

Gui.Elements.SortableList.sort_mode_symbols = {
    ascending = "↑",
    descending = "↓"
}

--- Rebuilds the SortableList with the given sorting mode and category.
--- @param list LuaGuiElement
--- @param link string  key to linked data and categories
--- @param selected_category string?
--- @param sort_mode string
function Gui.Elements.SortableList.sort_and_rebuild(list, link, selected_category, sort_mode)
    list.clear()

    local definition = Gui.Elements.SortableList.linked[link]
    local category_definitions = definition.categories
    local selected_category_definition = get_selected_category(category_definitions, selected_category)

    for _, category in pairs(category_definitions) do
        local button =
            list.add {
            type = "button",
            caption = {
                "",
                category.localised_name,
                (category.name == selected_category and sort_mode ~= "unsorted") and
                    Gui.Elements.SortableList.sort_mode_symbols[sort_mode] or
                    nil
            },
            tags = {
                category = category.name,
                sort_mode = Gui.Elements.SortableList.next_sort_modes[
                    (category.name == selected_category) and sort_mode or "unsorted"
                ],
                link = link,
                sosciencity_gui_event = "sort_list"
            },
            style = "sosciencity_sortable_list_head"
        }
        if category.name == selected_category then
            button.toggled = true
        end
    end

    local sorted_data =
        Tirislib.Luaq.from(definition.data):select_element(
        function(entry)
            return {
                data = entry,
                order = sort_mode ~= "unsorted" and selected_category_definition.order(entry) or nil
            }
        end
    ):to_array()

    if sort_mode ~= "unsorted" then
        table.sort(
            sorted_data,
            sort_mode == "ascending" and Gui.Elements.SortableList.comparator_ascending or
                Gui.Elements.SortableList.comparator_descending
        )
    end

    for i = 1, #sorted_data do
        local entry = sorted_data[i]
        for _, category in pairs(category_definitions) do
            local row_entry =
                list.add {
                type = "label",
                caption = category.content(entry.data),
                tooltip = category.tooltip and category.tooltip(entry.data) or nil,
                style = category.style and category.style(entry.data) or category.constant_style
            }

            if category.font then
                row_entry.style.font = category.font(entry.data)
            end
            if category.constant_font then
                row_entry.style.font = category.constant_font
            end
        end
    end
end

Gui.set_click_handler(
    "sort_list",
    function(event)
        local button = event.element
        local tags = button.tags
        Gui.Elements.SortableList.sort_and_rebuild(button.parent, tags.link, tags.category, tags.sort_mode)
    end
)

---------------------------------------------------------------------------------------------------
-- << Sprites >>
---------------------------------------------------------------------------------------------------

Gui.Elements.Sprite = {}

function Gui.Elements.Sprite.create_caste_sprite(container, caste_id, size)
    local caste = Castes.values[caste_id]

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

---------------------------------------------------------------------------------------------------
-- << Tabs >>
---------------------------------------------------------------------------------------------------

Gui.Elements.Tabs = {}

function Gui.Elements.Tabs.create(tabbed_pane, name, caption)
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
        direction = "vertical",
        style = "sosciencity_generic_tab_flow"
    }

    tabbed_pane.add_tab(tab, scrollpane)

    return flow
end

function Gui.Elements.Tabs.get_content(tabbed_pane, name)
    return tabbed_pane[name].flow
end

---------------------------------------------------------------------------------------------------
-- << Labels >>
---------------------------------------------------------------------------------------------------

Gui.Elements.Label = {}

-- XXX: I guess there is a better way to do this with just one label
function Gui.Elements.Label.header_label(container, name, caption)
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

    return header
end

--- Creates a generic 'heading_1' label.
--- @param container LuaGuiElement
--- @param caption locale
--- @param name string?
--- @return LuaGuiElement
function Gui.Elements.Label.heading_1(container, caption, name)
    return container.add {
        type = "label",
        name = name,
        caption = caption,
        style = "sosciencity_heading_1"
    }
end

--- Creates a generic 'heading_2' label.
--- @param container LuaGuiElement
--- @param caption locale
--- @param name string?
--- @return LuaGuiElement
function Gui.Elements.Label.heading_2(container, caption, name)
    return container.add {
        type = "label",
        name = name,
        caption = caption,
        style = "sosciencity_heading_2"
    }
end

--- Creates a generic 'heading_3' label.
--- @param container LuaGuiElement
--- @param caption locale
--- @param name string?
--- @return LuaGuiElement
function Gui.Elements.Label.heading_3(container, caption, name)
    return container.add {
        type = "label",
        name = name,
        caption = caption,
        style = "sosciencity_heading_3"
    }
end

function Gui.Elements.Label.heading_1_compact(container, caption, name)
    return container.add {type = "label", name = name, caption = caption, style = "sosciencity_heading_1_compact"}
end

function Gui.Elements.Label.heading_2_compact(container, caption, name)
    return container.add {type = "label", name = name, caption = caption, style = "sosciencity_heading_2_compact"}
end

function Gui.Elements.Label.heading_3_compact(container, caption, name)
    return container.add {type = "label", name = name, caption = caption, style = "sosciencity_heading_3_compact"}
end

--- Creates a generic multi-line 'paragraph' label.
--- @param container LuaGuiElement
--- @param caption locale
--- @param name string?
--- @return LuaGuiElement
function Gui.Elements.Label.paragraph(container, caption, name)
    return container.add {
        type = "label",
        name = name,
        caption = caption,
        style = "sosciencity_paragraph"
    }
end

--- Creates a flow stylised for a list.
--- @param container LuaGuiElement
--- @param name string?
--- @return LuaGuiElement
function Gui.Elements.Label.list_flow(container, name)
    return container.add {
        type = "flow",
        name = name,
        direction = "vertical",
        style = "sosciencity_list_flow"
    }
end

--- Creates a generic bullet point with a marker in front.
--- @param container LuaGuiElement
--- @param text_caption locale
--- @param marker_caption locale?
--- @param name string?
--- @return LuaGuiElement flow the flow that contains marker and text
function Gui.Elements.Label.bullet_point(container, text_caption, marker_caption, name)
    local flow =
        container.add {
        type = "flow",
        name = name,
        direction = "horizontal",
        style = "sosciencity_list_point_flow"
    }

    flow.add {
        type = "label",
        caption = marker_caption or ">",
        style = "sosciencity_list_marker"
    }
    Gui.Elements.Label.paragraph(flow, text_caption)

    return flow
end

--- Creates a generic list with the given bullet points.
--- @param container LuaGuiElement
--- @param point_captions array of locales
--- @param marker_caption locale?
--- @param name string?
--- @return LuaGuiElement flow the flow that contains the list
function Gui.Elements.Label.list(container, point_captions, marker_caption, name)
    local list_container = Gui.Elements.Label.list_flow(container, name)

    for _, point in pairs(point_captions) do
        Gui.Elements.Label.bullet_point(list_container, point, marker_caption)
    end

    return list_container
end

---------------------------------------------------------------------------------------------------
-- << Numeric Expression Textfield >>
---------------------------------------------------------------------------------------------------

--- A textfield that accepts arithmetic expressions and suffixes (k, M) and evaluates them on Enter.
Gui.Elements.NumericTextField = {}

local suffix_multipliers = {
    k = 1e3,
    K = 1e3,
    m = 1e6,
    M = 1e6
}

--- Evaluates a numeric expression string, supporting suffixes.
--- @param text string
--- @return number? result
local function evaluate_numeric_expression(text)
    if text == "" then
        return
    end

    -- Replace suffix notation before evaluating, e.g. "10k" -> "10000", "2.5M" -> "2500000"
    text = text:gsub("(%d+%.?%d*)([kKmM])", function(num, suffix)
        return tostring(tonumber(num) * suffix_multipliers[suffix])
    end)

    -- Evaluate using load() with an empty environment so no globals are accessible
    local chunk = load("return " .. text, "expression", "t", {})
    if not chunk then
        return nil
    end

    local ok, result = pcall(chunk)
    if not ok then
        return nil
    end

    if type(result) ~= "number" then
        return nil
    end

    return result
end

local function format_number(n)
    -- Show integers without a decimal point
    if n == math.floor(n) then
        return tostring(math.floor(n))
    else
        return tostring(n)
    end
end

--- Lookup for post-evaluation confirmed handlers by tag.
--- Registered via Gui.Elements.NumericTextField.set_confirmed_handler.
local numeric_confirmed_handlers = {}

--- Registers a handler to be called after a NumericTextField successfully evaluates its expression.
--- The textfield must have been created with a matching 'numeric_confirmed_event' tag.
--- The handler receives (event, result) where result is the evaluated number.
--- @param tag string
--- @param fn function(event, result)
function Gui.Elements.NumericTextField.set_confirmed_handler(tag, fn)
    Tirislib.Utils.desync_protection()
    if numeric_confirmed_handlers[tag] then
        error("Handler already registered for tag: " .. tag)
    end
    numeric_confirmed_handlers[tag] = fn
end

--- Creates a textfield that evaluates arithmetic expressions on Enter.
--- Supports suffixes: k/K (×1000), m/M (×1000000).
--- Pass 'numeric_confirmed_event = "tag"' in extra_tags to hook into post-evaluation via
--- Gui.Elements.NumericTextField.set_confirmed_handler.
--- @param container LuaGuiElement
--- @param name string?
--- @param extra_tags table? additional tags
--- @return LuaGuiElement textfield
function Gui.Elements.NumericTextField.create(container, name, extra_tags)
    local tags = {sosciencity_gui_event = "evaluate_numeric_expression"}
    if extra_tags then
        for k, v in pairs(extra_tags) do
            tags[k] = v
        end
    end

    local textfield = container.add {
        type = "textfield",
        name = name,
        tags = tags,
        style = "sosciencity_numeric_textfield"
    }

    return textfield
end

Gui.set_gui_confirmed_handler(
    "evaluate_numeric_expression",
    function(event)
        local textfield = event.element
        local text = textfield.text

        local result = evaluate_numeric_expression(text)

        if not result then
            textfield.style = "sosciencity_numeric_textfield_error"
            textfield.tooltip = {"sosciencity.invalid-expression"}
            return
        end

        textfield.style = "sosciencity_numeric_textfield"
        textfield.tooltip = ""
        textfield.text = format_number(result)

        local secondary_tag = textfield.tags.numeric_confirmed_event
        if secondary_tag then
            local handler = numeric_confirmed_handlers[secondary_tag]
            if handler then
                handler(event, result)
            end
        end
    end
)

Gui.set_text_changed_handler(
    "evaluate_numeric_expression",
    function(event)
        local textfield = event.element
        textfield.style = "sosciencity_numeric_textfield"
        textfield.tooltip = ""
    end
)

---------------------------------------------------------------------------------------------------
-- << Buttons >>
---------------------------------------------------------------------------------------------------

Gui.Elements.Button = {}

--- Creates a button that when clicked brings the player to the given city view page.
--- @param container LuaGuiElement
--- @param category_name string
--- @param page_name string
--- @return LuaGuiElement button
function Gui.Elements.Button.page_link(container, category_name, page_name)
    local flow =
        container.add {
        type = "flow",
        direction = "horizontal",
        style = "sosciencity_page_link_flow"
    }

    local category = Gui.CityView.get_category_definition(category_name)
    local page = Gui.CityView.get_page_definition(category, page_name)

    flow.add {
        type = "button",
        caption = {"city-view.link", category.localised_name, page.localised_name},
        tags = {
            category = category_name,
            page = page_name,
            sosciencity_gui_event = "open_page"
        }
    }

    return flow
end

--- Creates a button that when clicked opens the technology GUI for the given technology.
--- @param container LuaGuiElement
--- @param technology_name string
--- @return LuaGuiElement flow
function Gui.Elements.Button.technology_link(container, technology_name)
    local flow =
        container.add {
        type = "flow",
        direction = "horizontal",
        style = "sosciencity_page_link_flow"
    }

    local proto = prototypes.technology[technology_name]
    if not proto then
        error("Invalid technology name: " .. technology_name)
    end

    flow.add {
        type = "button",
        caption = {"city-view.technology-link", proto.localised_name},
        elem_tooltip = {type = "technology", name = technology_name},
        tags = {
            technology = technology_name,
            sosciencity_gui_event = "open_technology"
        }
    }

    return flow
end

Gui.set_click_handler(
    "open_technology",
    function(event)
        local player = game.get_player(event.player_index)
        player.open_technology_gui(event.element.tags.technology)
    end
)

---------------------------------------------------------------------------------------------------
-- << Flows >>
---------------------------------------------------------------------------------------------------

Gui.Elements.Flow = {}

--- Creates a simple horizontal flow that centers its children.
--- @param container LuaGuiElement
--- @param name string?
--- @return LuaGuiElement
function Gui.Elements.Flow.horizontal_center(container, name)
    return container.add {
        type = "flow",
        name = name,
        direction = "horizontal",
        style = "sosciencity_horizontal_center_flow"
    }
end

--- Creates a simple horizontal flow that orders its children to the right.
--- @param container LuaGuiElement
--- @param name string?
--- @return LuaGuiElement
function Gui.Elements.Flow.horizontal_right(container, name)
    return container.add {
        type = "flow",
        name = name,
        direction = "horizontal",
        style = "sosciencity_horizontal_right_flow"
    }
end

---------------------------------------------------------------------------------------------------
-- << PerformanceReport >>
---------------------------------------------------------------------------------------------------

--- Reusable GUI component that renders a standardised performance breakdown.
--- Entity update functions populate an entry's performance_report (EK.performance_report),
--- and this component renders it grouped by dimension with pre-computed results.
Gui.Elements.PerformanceReport = {}

local Comb = require("enums.performance-combination")
local Dim = require("enums.performance-dimension")
local EK_report = require("enums.entry-key").performance_report
local PK = require("enums.performance-key")
local PerfEffects = require("constants.performance-effects")

local ceil = math.ceil
local floor = math.floor

local effect_labels = PerfEffects.labels
local effect_descriptions = PerfEffects.descriptions
local dimension_labels = PerfEffects.dimension_labels

-- ordered list of dimensions to render
local dimension_order = {Dim.speed, Dim.productivity}

local function format_ratio(value)
    local pct = ceil(value * 100)
    if pct >= 100 then
        return "[color=0,1,0]" .. pct .. "%[/color]"
    elseif pct >= 50 then
        return "[color=0.9,0.8,0]" .. pct .. "%[/color]"
    else
        return "[color=1,0,0]" .. pct .. "%[/color]"
    end
end

local function format_flat(value)
    local v = floor(value)
    if v > 0 then
        return "[color=0,1,0]+" .. v .. "%[/color]"
    elseif v < 0 then
        return "[color=1,0,0]" .. v .. "%[/color]"
    else
        return "[color=0.8,0.8,0.8]0%[/color]"
    end
end

local format_by_combination = {
    [Comb.bottleneck] = format_ratio,
    [Comb.multiplier] = function(value) return "×" .. format_ratio(value) end,
    [Comb.flat] = format_flat
}

local function render_effect(tbl, effect, is_limiting)
    local effect_id = effect[PK.effect]
    local label = effect_labels[effect_id]
    local description = effect_descriptions[effect_id]
    local format_fn = format_by_combination[effect[PK.combination]]

    local key_label = tbl.add {
        type = "label",
        caption = label,
        tooltip = description
    }
    key_label.style.font = "default-semibold"
    key_label.style.left_padding = 8

    local value_text = format_fn(effect[PK.value])
    if is_limiting then
        value_text = value_text .. " [color=1,0.6,0]◄[/color]"
    end
    tbl.add {
        type = "label",
        caption = value_text,
        tooltip = description
    }

    local detail = effect[PK.detail]
    if detail then
        local detail_label = tbl.add {
            type = "label",
            caption = detail
        }
        local detail_style = detail_label.style
        detail_style.font = "default-small"
        detail_style.font_color = {0.7, 0.7, 0.7}
        detail_style.left_padding = 16
        tbl.add {type = "empty-widget"}
    end
end

--- Creates the performance report GUI elements inside the given container.
--- @param container LuaGuiElement
--- @param name string? unique name for this report within the parent
function Gui.Elements.PerformanceReport.create(container, name)
    return container.add {
        type = "flow",
        name = name or "performance-report",
        direction = "vertical"
    }
end

--- Updates (rebuilds) the performance report from the entry's report data.
--- @param report_flow LuaGuiElement the flow created by PerformanceReport.create
--- @param entry Entry
function Gui.Elements.PerformanceReport.update(report_flow, entry)
    report_flow.clear()

    local report = entry[EK_report]
    if not report then
        return
    end

    local effects = report[PK.effects]
    local results = report[PK.results]
    if not effects or not results then
        return
    end

    -- Group effects into: by_dimension[dimension_id][group_number] = effect[]
    local by_dimension = {}
    for _, eff in pairs(effects) do
        local dim = eff[PK.dimension]
        if not by_dimension[dim] then
            by_dimension[dim] = {}
        end

        local group = eff[PK.group] or 1
        if not by_dimension[dim][group] then
            by_dimension[dim][group] = {}
        end

        local group_effects = by_dimension[dim][group]
        group_effects[#group_effects + 1] = eff
    end

    -- For each group that has multiple bottleneck effects, find the lowest one.
    -- Uses effect table identity as key to avoid mutating stored data.
    -- limiting_effects[effect_table] = true for the effect(s) with the lowest value.
    local limiting_effects = {}
    for _, groups in pairs(by_dimension) do
        for _, group_effects in pairs(groups) do
            local bottleneck_min = nil
            local bottleneck_count = 0

            for _, eff in pairs(group_effects) do
                if eff[PK.combination] == Comb.bottleneck then
                    bottleneck_count = bottleneck_count + 1
                    local val = eff[PK.value]
                    if not bottleneck_min or val < bottleneck_min then
                        bottleneck_min = val
                    end
                end
            end

            if bottleneck_count > 1 then
                for _, eff in pairs(group_effects) do
                    if eff[PK.combination] == Comb.bottleneck and eff[PK.value] <= bottleneck_min then
                        limiting_effects[eff] = true
                    end
                end
            end
        end
    end

    -- render each dimension in order
    for _, dim in pairs(dimension_order) do
        local result = results[dim]
        if result and by_dimension[dim] then
            local dim_label = dimension_labels[dim]
            local format_fn = (dim == Dim.productivity) and format_flat or format_ratio

            local header = report_flow.add {
                type = "label",
                caption = {"", dim_label, "  ", format_fn(result)}
            }
            header.style.font = "default-bold"

            local effects_table = report_flow.add {
                type = "table",
                column_count = 2,
                style = "sosciencity_datalist"
            }

            -- render groups in order
            local groups = by_dimension[dim]
            local group_numbers = {}
            for grp in pairs(groups) do
                group_numbers[#group_numbers + 1] = grp
            end
            table.sort(group_numbers)

            for _, grp in pairs(group_numbers) do
                for _, eff in pairs(groups[grp]) do
                    render_effect(effects_table, eff, limiting_effects[eff])
                end
            end
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << CollapsibleSection >>
---------------------------------------------------------------------------------------------------

Gui.Elements.CollapsibleSection = {}

local function create_collapsible_section(container, caption, options, style)
    options = options or {}
    local collapsed = options.collapsed or false

    local section_flow = container.add {
        type = "flow",
        direction = "vertical"
    }

    section_flow.add {
        type = "button",
        name = "heading",
        caption = {"", collapsed and "▶ " or "▼ ", caption},
        elem_tooltip = options.elem_tooltip,
        tooltip = options.tooltip,
        tags = {
            sosciencity_gui_event = "collapsible_section_toggle",
            collapsed = collapsed
        },
        style = style
    }

    return section_flow.add {
        type = "flow",
        name = "content",
        direction = "vertical",
        visible = not collapsed
    }
end

--- @param container LuaGuiElement
--- @param caption locale
--- @param options table? { collapsed: bool, elem_tooltip: ElemID?, tooltip: locale? }
--- @return LuaGuiElement content_flow
function Gui.Elements.CollapsibleSection.heading_1(container, caption, options)
    return create_collapsible_section(container, caption, options, "sosciencity_heading_1_button")
end

--- @param container LuaGuiElement
--- @param caption locale
--- @param options table? { collapsed: bool, elem_tooltip: ElemID?, tooltip: locale? }
--- @return LuaGuiElement content_flow
function Gui.Elements.CollapsibleSection.heading_2(container, caption, options)
    return create_collapsible_section(container, caption, options, "sosciencity_heading_2_button")
end

--- @param container LuaGuiElement
--- @param caption locale
--- @param options table? { collapsed: bool, elem_tooltip: ElemID?, tooltip: locale? }
--- @return LuaGuiElement content_flow
function Gui.Elements.CollapsibleSection.heading_3(container, caption, options)
    return create_collapsible_section(container, caption, options, "sosciencity_heading_3_button")
end

function Gui.Elements.CollapsibleSection.heading_1_compact(container, caption, options)
    return create_collapsible_section(container, caption, options, "sosciencity_heading_1_button_compact")
end

function Gui.Elements.CollapsibleSection.heading_2_compact(container, caption, options)
    return create_collapsible_section(container, caption, options, "sosciencity_heading_2_button_compact")
end

function Gui.Elements.CollapsibleSection.heading_3_compact(container, caption, options)
    return create_collapsible_section(container, caption, options, "sosciencity_heading_3_button_compact")
end

Gui.set_click_handler(
    "collapsible_section_toggle",
    function(event)
        local button = event.element
        local tags = button.tags
        local now_collapsed = not tags.collapsed

        tags.collapsed = now_collapsed
        button.tags = tags

        -- Swap the indicator (index 2 in the {"", indicator, original_caption} structure)
        local caption = button.caption
        caption[2] = now_collapsed and "▶ " or "▼ "
        button.caption = caption

        -- heading and content are siblings inside section_flow
        button.parent.content.visible = not now_collapsed
    end
)

---------------------------------------------------------------------------------------------------
-- << IntStepper >>
---------------------------------------------------------------------------------------------------

--- A reusable ◄ [value] ► control for stepping an integer within a bounded range.
--- The caller registers the event handler separately via Gui.set_click_handler(event_tag, ...).
--- Both buttons carry `delta = -1` / `delta = 1` plus any extra_tags in their tags table.
Gui.Elements.IntStepper = {}

--- Creates an IntStepper inside parent.
--- options:
---   event_tag     string   sosciencity_gui_event for both buttons (required)
---   extra_tags    table?   merged into button tags alongside delta
---   value         integer  initial value
---   min           integer  decrease button disabled when value == min
---   max           integer  increase button disabled when value == max
---   tooltip       locale?  applied to both buttons and the label
--- @return LuaGuiElement the stepper flow
function Gui.Elements.IntStepper.create(parent, name, options)
    local flow = parent.add {
        type = "flow",
        name = name,
        direction = "horizontal",
        style = "sosciencity_horizontal_center_flow"
    }
    flow.style.vertical_align = "center"

    local extra = options.extra_tags or {}
    local decrease_tags = {sosciencity_gui_event = options.event_tag, delta = -1}
    local increase_tags = {sosciencity_gui_event = options.event_tag, delta = 1}
    for k, v in pairs(extra) do
        decrease_tags[k] = v
        increase_tags[k] = v
    end

    flow.add {
        type = "sprite-button",
        name = "decrease",
        sprite = "utility/backward_arrow_black",
        style = "sosciencity_small_button",
        mouse_button_filter = {"left"},
        tooltip = options.tooltip,
        tags = decrease_tags,
        enabled = options.value > options.min
    }

    local val_label = flow.add {
        type = "label",
        name = "val",
        caption = options.value,
        tooltip = options.tooltip
    }
    val_label.style.minimal_width = 16
    val_label.style.horizontal_align = "center"

    flow.add {
        type = "sprite-button",
        name = "increase",
        sprite = "utility/forward_arrow_black",
        style = "sosciencity_small_button",
        mouse_button_filter = {"left"},
        tooltip = options.tooltip,
        tags = increase_tags,
        enabled = options.value < options.max
    }

    return flow
end

--- Updates an existing IntStepper: caption and button enabled states.
--- @param flow LuaGuiElement the flow returned by IntStepper.create
--- @param value integer current value
--- @param min integer lower bound
--- @param max integer upper bound
function Gui.Elements.IntStepper.update(flow, value, min, max)
    flow["decrease"].enabled = value > min
    flow["val"].caption = value
    flow["increase"].enabled = value < max
end

---------------------------------------------------------------------------------------------------
-- << MessageBox >>
---------------------------------------------------------------------------------------------------

--- A modal dialog shown on the player's screen with a message and one or more buttons.
--- Buttons may carry roles:
---   "confirm" → green style, Escape triggers it if it also has "cancel"
---   "cancel"  → red style, Escape always triggers it
--- A button with both roles is rendered green (confirm trumps cancel visually).
Gui.Elements.MessageBox = {}

local MESSAGEBOX_FRAME_NAME = "sosciencity_messagebox"

--- Lookup for button handlers by tag.
local messagebox_button_handlers = {}

--- Registers a handler called when a MessageBox button with the given tag is clicked or
--- triggered by keyboard. Call at load time (subject to desync protection).
--- @param tag string
--- @param fn function(event)
function Gui.Elements.MessageBox.set_button_handler(tag, fn)
    Tirislib.Utils.desync_protection()
    if messagebox_button_handlers[tag] then
        error("Handler already registered for messagebox button tag: " .. tag)
    end
    messagebox_button_handlers[tag] = fn
end

local function messagebox_has_role(roles, role)
    if not roles then return false end
    for _, r in pairs(roles) do
        if r == role then return true end
    end
    return false
end

local function messagebox_button_style(roles)
    -- confirm trumps cancel when both are present
    if messagebox_has_role(roles, "confirm") then
        return "confirm_button"
    elseif messagebox_has_role(roles, "cancel") then
        return "back_button"
    else
        return "dialog_button"
    end
end

local function messagebox_invoke_handler(tag, event)
    if not tag then return end
    local handler = messagebox_button_handlers[tag]
    if handler then
        handler(event)
    end
end

local function messagebox_close(player)
    local frame = player.gui.screen[MESSAGEBOX_FRAME_NAME]
    if frame and frame.valid then
        frame.destroy()
    end
end

--- Shows a message box to the given player, closing any existing one first.
--- @param player_index integer
--- @param options table
---   message: locale (required)
---   title: locale (optional)
---   buttons: array of button specs:
---     caption: locale (required)
---     roles: string[]? — subset of {"confirm", "cancel"}
---     tag: string? — key for a handler registered via set_button_handler
---     style: string? — Factorio button style override
function Gui.Elements.MessageBox.show(player_index, options)
    local player = game.get_player(player_index)
    messagebox_close(player)

    local buttons = options.buttons
    local cancel_tag = nil

    for _, btn in pairs(buttons) do
        if messagebox_has_role(btn.roles, "cancel") then
            if cancel_tag ~= nil then
                error("MessageBox: only one button may have the 'cancel' role")
            end
            cancel_tag = btn.tag or false
        end
    end

    local frame = player.gui.screen.add {
        type = "frame",
        name = MESSAGEBOX_FRAME_NAME,
        caption = options.title,
        direction = "vertical",
        tags = {cancel_tag = cancel_tag}
    }
    frame.auto_center = true

    local content_flow = frame.add {
        type = "flow",
        direction = "vertical",
        style = "sosciencity_messagebox_content_flow"
    }

    content_flow.add {
        type = "label",
        caption = options.message,
        style = "sosciencity_paragraph"
    }

    local button_flow = content_flow.add {
        type = "flow",
        direction = "horizontal",
        style = "sosciencity_messagebox_button_flow"
    }

    for _, btn in pairs(buttons) do
        button_flow.add {
            type = "button",
            caption = btn.caption,
            style = btn.style or messagebox_button_style(btn.roles),
            tags = {
                sosciencity_gui_event = "messagebox_button",
                messagebox_tag = btn.tag,
            }
        }
    end

    player.opened = frame
end

Gui.set_click_handler(
    "messagebox_button",
    function(event)
        local tag = event.element.tags.messagebox_tag
        local player = game.get_player(event.player_index)
        messagebox_close(player)
        messagebox_invoke_handler(tag, event)
    end
)

Gui.add_gui_closed_handler(
    function(player, event)
        local element = event.element
        if not element or not element.valid then return end
        if element.name ~= MESSAGEBOX_FRAME_NAME then return end

        local cancel_tag = element.tags.cancel_tag
        element.destroy()
        messagebox_invoke_handler(cancel_tag, event)
    end
)
