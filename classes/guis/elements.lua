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

function Gui.Elements.Utils.get_unused_name(container, name)
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
local get_unused_name = Gui.Elements.Utils.get_unused_name

function Gui.Elements.Utils.create_separator_line(container, name)
    return container.add {
        type = "line",
        name = get_unused_name(name or "line"),
        direction = "horizontal"
    }
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

function Gui.Elements.Datalist.add_kv_checkbox(data_list, key, checkbox_name, key_caption, checkbox_caption, key_font, checkbox_font)
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

function Gui.Elements.Datalist.update_operand_entries(data_list, final_value, summands, summand_enums, factors, factor_enums)
    data_list["sum"].caption = Locale.summand(final_value)

    for name, id in pairs(summand_enums) do
        local value = summands[id]

        if value ~= 0 then
            set_kv_pair_value(data_list, name, Locale.summand(value))
            set_kv_pair_visibility(data_list, name, true)
        else
            set_kv_pair_visibility(data_list, name, false)
        end
    end

    for name, id in pairs(factor_enums) do
        local value = factors[id]

        if value ~= 1. then
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

-- We're stuffing the data and category definitions inside these tables during startup.
-- Otherwise I don't know a way to implement this without stuffing all this in global,
-- which I don't want because the data could get outdated and which I can't without dirty
-- workarounds as the category definitions contain functions.

--- Table with (key, data) pairs.
Gui.Elements.SortableList.linked_data = {}
--- Table with (key, category definition array) pairs.\
--- **Category Definition**\
--- name: anything but nil\
--- localised_name: locale (for the header button)\
--- content: function (gets the caption locale from a data entry)\
--- order: function (creates a comparable value from a data entry)\
--- tooltip: function, optional (gets the tooltip locale from a data entry)\
--- styler: function, optional (gets the name of a style from a data entry)\
--- style: string, optional (when there should always be the same style)\
--- alignment: Alignment, optional (defaults to "left" for the first column and "right" for all others)
Gui.Elements.SortableList.linked_categories = {}

--- Create a sortable list.
--- @param container LuaGuiElement
--- @param link string key to linked data and categories
--- @return LuaGuiElement table that contains the list
function Gui.Elements.SortableList.create(container, link)
    local category_definitions = Gui.Elements.SortableList.linked_categories[link]

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
--- @param selected_category string
--- @param sort_mode string
function Gui.Elements.SortableList.sort_and_rebuild(list, link, selected_category, sort_mode)
    list.clear()

    local category_definitions = Gui.Elements.SortableList.linked_categories[link]
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
        Tirislib.Luaq.from(Gui.Elements.SortableList.linked_data[link]):select_element(
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

    for _, entry in pairs(sorted_data) do
        for _, category in pairs(category_definitions) do
            local row_entry =
                list.add {
                type = "label",
                caption = category.content(entry.data),
                tooltip = category.tooltip and category.tooltip(entry.data) or nil
                --style = "sosciencity_sortable_list_row"
            }

            if category.font then
                row_entry.style.font = category.font(entry)
            end
            if category.constant_font then
                row_entry.style.font = category.constant_font
            end
        end
    end
end

Gui.set_click_handler_tag(
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
end

--- Creates a generic 'heading_1' label.
--- @param container LuaGuiElement
--- @param caption locale
--- @param name string|nil
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
--- @param name string|nil
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
--- @param name string|nil
--- @return LuaGuiElement
function Gui.Elements.Label.heading_3(container, caption, name)
    return container.add {
        type = "label",
        name = name,
        caption = caption,
        style = "sosciencity_heading_3"
    }
end

--- Creates a generic multi-line 'paragraph' label.
--- @param container LuaGuiElement
--- @param caption locale
--- @param name string|nil
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
--- @param name string|nil
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
--- @param marker_caption locale|nil
--- @param name string|nil
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
    Gui.Elements.Label.paragraph(flow, text_caption, name)

    return flow
end

--- Creates a generic list with the given bullet points.
--- @param container LuaGuiElement
--- @param point_captions array of locales
--- @param marker_caption locale|nil
--- @param name string|nil
--- @return LuaGuiElement flow the flow that contains the list
function Gui.Elements.Label.list(container, point_captions, marker_caption, name)
    local list_container = Gui.Elements.Label.list_flow(container, name)

    for _, point in pairs(point_captions) do
        Gui.Elements.Label.bullet_point(list_container, point, marker_caption)
    end

    return list_container
end

---------------------------------------------------------------------------------------------------
-- << Buttons >>
---------------------------------------------------------------------------------------------------

Gui.Elements.Button = {}

function Gui.Elements.Button.page_link(container, category_name, page_name)
    local flow = container.add {
        type = "flow",
        direction = "horizontal",
        style = "sosciencity_page_link_flow"
    }

    local category = Gui.CityView.get_category_definition(category_name)
    local page = Gui.CityView.get_page_definition(category, page_name)

    flow.add {
        type = "button",
        caption = {"", category.localised_name, " / ", page.localised_name},
        tags = {
            category = category_name,
            page = page_name,
            sosciencity_gui_event = "open_page"
        }
    }

    return flow
end
