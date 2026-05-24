--- Housing overview and balancing page

local Housing = require("constants.housing")
local Castes = require("constants.castes")
local HousingTrait = require("enums.housing-trait")

local CONTEXT = "housing-balancing"

---------------------------------------------------------------------------------------------------
-- << Constants >>
---------------------------------------------------------------------------------------------------

local COL_NAME_WIDTH = 180
local COL_NUM_WIDTH = 55
local CASTE_NAME_WIDTH = 140
local CASTE_DATA_WIDTH = 46

local EDITOR_FIELD_WIDTH = 45
local EDITOR_CASTE_NAME_WIDTH = 120
local EDITOR_TRAIT_COLS = 7
local EDITOR_FONT_COLOR = {r = 0.65, g = 0.28, b = 0.0}

-- Reverse lookup: HousingTrait integer -> string name (used for locale key lookup)
local TRAIT_NAMES = {}
for name, value in pairs(HousingTrait) do
    TRAIT_NAMES[value] = name
end

-- All trait IDs in ascending order
local ALL_TRAIT_IDS = {}
for _, id in pairs(HousingTrait) do
    ALL_TRAIT_IDS[#ALL_TRAIT_IDS + 1] = id
end
table.sort(ALL_TRAIT_IDS)

-- Purchasable traits sorted for consistent display order
local PURCHASABLE_TRAITS = {}
for trait in pairs(Housing.tag_costs) do
    PURCHASABLE_TRAITS[#PURCHASABLE_TRAITS + 1] = trait
end
table.sort(PURCHASABLE_TRAITS)

-- Lazily-built sorted list of house prototype names for the picker
local house_picker_names

local function get_house_picker_names()
    if house_picker_names then return house_picker_names end
    house_picker_names = {}
    for name in pairs(Housing.values) do
        if prototypes.entity[name] then
            house_picker_names[#house_picker_names + 1] = name
        end
    end
    table.sort(house_picker_names)
    return house_picker_names
end

---------------------------------------------------------------------------------------------------
-- << Data helpers >>
---------------------------------------------------------------------------------------------------

local function get_arch_level(house_name)
    for i = 1, 7 do
        local tech = prototypes.technology["architecture-" .. i]
        if tech then
            for _, effect in pairs(tech.effects) do
                if effect.recipe == house_name then return i end
            end
        end
    end
    return 0
end

local function get_sorted_houses(house_overrides)
    house_overrides = house_overrides or {}
    local result = {}
    for name, housing in pairs(Housing.values) do
        local proto = prototypes.entity[name]
        if proto then
            local override = house_overrides[name] or {}
            local size = proto.tile_height * proto.tile_width
            result[#result + 1] = {
                name = name,
                housing = housing,
                size = size,
                arch_level = get_arch_level(name),
                override = override
            }
        end
    end
    table.sort(result, function(a, b)
        if a.arch_level ~= b.arch_level then return a.arch_level < b.arch_level end
        local a_comfort = a.override.max_comfort or a.housing.max_comfort
        local b_comfort = b.override.max_comfort or b.housing.max_comfort
        if a_comfort ~= b_comfort then return a_comfort < b_comfort end
        return a.name < b.name
    end)
    return result
end

---------------------------------------------------------------------------------------------------
-- << State collection >>
---------------------------------------------------------------------------------------------------

local function collect_state(player_index)
    local slider = Gui.get_element(CONTEXT, "comfort_slider", player_index)
    local comfort_level = slider and math.floor(slider.slider_value) or Housing.max_level

    local checked_traits = {}
    for _, trait in pairs(PURCHASABLE_TRAITS) do
        local cb = Gui.get_element(CONTEXT, "trait_" .. trait, player_index)
        if cb and cb.state then
            checked_traits[#checked_traits + 1] = trait
        end
    end

    return {comfort_level = comfort_level, checked_traits = checked_traits}
end

---------------------------------------------------------------------------------------------------
-- << Overrides store >>
---------------------------------------------------------------------------------------------------
-- Tags use string keys for integer-keyed subtables (caste_id, trait_id) because Factorio
-- serializes non-sequential integer-keyed tables to JSON objects with string keys.

local function get_overrides(player_index)
    local store = Gui.get_element(CONTEXT, "overrides_store", player_index)
    if not store then return {house_overrides = {}, caste_overrides = {}} end
    local tags = store.tags
    return {
        current_house = tags.current_house,
        house_overrides = tags.house_overrides or {},
        caste_overrides = tags.caste_overrides or {}
    }
end

local function set_overrides(player_index, overrides)
    local store = Gui.get_element(CONTEXT, "overrides_store", player_index)
    if store then store.tags = overrides end
end

---------------------------------------------------------------------------------------------------
-- << Computation >>
---------------------------------------------------------------------------------------------------

local function compute_caste_data(housing, caste, state, house_override, caste_override)
    house_override = house_override or {}
    caste_override = caste_override or {}

    local room_count = house_override.room_count or housing.room_count
    local max_comfort = house_override.max_comfort or housing.max_comfort
    local traits = house_override.traits or housing.traits
    local required_room_count = caste_override.required_room_count or caste.required_room_count
    local pref_overrides = caste_override.preferences or {}

    local eligible = housing.is_improvised or (room_count >= required_room_count)
    if not eligible then return nil end

    local eff_comfort = math.min(max_comfort, state.comfort_level)
    local happiness = eff_comfort
    for _, trait in pairs(traits) do
        happiness = happiness + (pref_overrides[tostring(trait)] or caste.housing_preferences[trait] or 0)
    end
    for _, trait in pairs(state.checked_traits) do
        happiness = happiness + (pref_overrides[tostring(trait)] or caste.housing_preferences[trait] or 0)
    end

    local capacity
    if housing.one_room_per_inhabitant then
        capacity = room_count
    else
        capacity = math.floor(room_count / required_room_count)
    end

    return {happiness = happiness, capacity = capacity}
end

---------------------------------------------------------------------------------------------------
-- << Table building >>
---------------------------------------------------------------------------------------------------

local function add_header_label(tbl, caption, width)
    local lbl = tbl.add {type = "label", caption = caption}
    lbl.style.font = "default-bold"
    lbl.style.width = width
end

local function add_cell(tbl, caption, width)
    local lbl = tbl.add {type = "label", caption = caption}
    lbl.style.width = width
end

local function build_static_table(container, sorted_houses, state)
    local tbl = container.add {type = "table", column_count = 7, style = "sosciencity_datalist"}

    add_header_label(tbl, {"city-view.housing-balancing-col-name"}, COL_NAME_WIDTH)
    add_header_label(tbl, {"city-view.housing-balancing-col-size"}, COL_NUM_WIDTH)
    add_header_label(tbl, {"city-view.housing-balancing-col-rooms"}, COL_NUM_WIDTH)
    add_header_label(tbl, {"city-view.housing-balancing-col-rt"}, COL_NUM_WIDTH)
    add_header_label(tbl, {"city-view.housing-balancing-col-comfort"}, COL_NUM_WIDTH)
    add_header_label(tbl, {"city-view.housing-balancing-col-max-comfort"}, COL_NUM_WIDTH)
    add_header_label(tbl, {"city-view.housing-balancing-col-level"}, COL_NUM_WIDTH)

    for _, hd in pairs(sorted_houses) do
        local housing = hd.housing
        local proto = prototypes.entity[hd.name]
        local override = hd.override
        local room_count = override.room_count or housing.room_count
        local max_comfort = override.max_comfort or housing.max_comfort
        local eff_comfort = math.min(max_comfort, state.comfort_level)

        local name_lbl = tbl.add {
            type = "label",
            caption = {"", string.format("[entity=%s] ", hd.name), proto.localised_name},
            elem_tooltip = {type = "entity", name = hd.name}
        }
        name_lbl.style.width = COL_NAME_WIDTH

        add_cell(tbl, tostring(hd.size), COL_NUM_WIDTH)
        add_cell(tbl, tostring(room_count), COL_NUM_WIDTH)
        add_cell(tbl, string.format("%.2f", room_count / hd.size), COL_NUM_WIDTH)
        add_cell(tbl, tostring(eff_comfort), COL_NUM_WIDTH)
        add_cell(tbl, tostring(max_comfort), COL_NUM_WIDTH)
        add_cell(tbl, hd.arch_level > 0 and tostring(hd.arch_level) or "-", COL_NUM_WIDTH)
    end
end

local function build_caste_table(container, sorted_houses, state, overrides)
    local house_overrides = overrides.house_overrides
    local caste_overrides = overrides.caste_overrides
    local castes = Castes.all
    local col_count = 1 + #castes * 2

    local tbl = container.add {type = "table", column_count = col_count, style = "sosciencity_datalist"}

    -- Header row 1: caste icon above the H column of each pair, empty above C column
    add_header_label(tbl, "", CASTE_NAME_WIDTH)
    for _, caste in pairs(castes) do
        local icon_lbl = tbl.add {
            type = "label",
            caption = string.format("[technology=%s-caste]", caste.name),
            elem_tooltip = {type = "technology", name = caste.name .. "-caste"}
        }
        icon_lbl.style.font = "default-bold"
        icon_lbl.style.width = CASTE_DATA_WIDTH
        local spacer = tbl.add {type = "label", caption = ""}
        spacer.style.width = CASTE_DATA_WIDTH
    end

    -- Header row 2: column labels (H = happiness, C = capacity)
    add_header_label(tbl, {"city-view.housing-balancing-col-name"}, CASTE_NAME_WIDTH)
    for i = 1, #castes do
        add_header_label(tbl, "H", CASTE_DATA_WIDTH)
        add_header_label(tbl, "C", CASTE_DATA_WIDTH)
    end

    -- Data rows
    for _, hd in pairs(sorted_houses) do
        local proto = prototypes.entity[hd.name]
        local name_lbl = tbl.add {
            type = "label",
            caption = {"", string.format("[entity=%s] ", hd.name), proto.localised_name},
            elem_tooltip = {type = "entity", name = hd.name}
        }
        name_lbl.style.width = CASTE_NAME_WIDTH

        for _, caste in pairs(castes) do
            local house_override = house_overrides[hd.name]
            local caste_override = caste_overrides[tostring(caste.type)]
            local data = compute_caste_data(hd.housing, caste, state, house_override, caste_override)
            if data then
                add_cell(tbl, tostring(data.happiness), CASTE_DATA_WIDTH)
                add_cell(tbl, tostring(data.capacity), CASTE_DATA_WIDTH)
            else
                add_cell(tbl, "-", CASTE_DATA_WIDTH)
                add_cell(tbl, "-", CASTE_DATA_WIDTH)
            end
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << Rebuild >>
---------------------------------------------------------------------------------------------------

local function rebuild_tables(player_index)
    local static_flow = Gui.get_element(CONTEXT, "static_flow", player_index)
    local caste_flow = Gui.get_element(CONTEXT, "caste_flow", player_index)
    static_flow.clear()
    caste_flow.clear()
    local state = collect_state(player_index)
    local overrides = get_overrides(player_index)
    local sorted_houses = get_sorted_houses(overrides.house_overrides)
    build_static_table(static_flow, sorted_houses, state)
    build_caste_table(caste_flow, sorted_houses, state, overrides)
end

---------------------------------------------------------------------------------------------------
-- << House override editor >>
---------------------------------------------------------------------------------------------------

local function build_house_editor_fields(fields_flow, house_name, overrides, player_index)
    fields_flow.clear()
    local housing = Housing.values[house_name]
    if not housing then return end
    local override = overrides.house_overrides[house_name] or {}

    -- Room count
    local room_row = fields_flow.add {type = "flow", direction = "horizontal"}
    room_row.style.vertical_align = "center"
    room_row.add {type = "label", caption = {"city-view.housing-balancing-edit-room-count"}}
    local room_field = Gui.Elements.NumericTextField.create(room_row, nil, {
        min = 0,
        step = 1,
        normal_font_color = EDITOR_FONT_COLOR,
        numeric_confirmed_event = "hbal_house_roomcount_confirmed"
    })
    room_field.text = tostring(override.room_count or housing.room_count)
    Gui.register_element(room_field, CONTEXT, "house_room_count", player_index)

    -- Max comfort slider
    local comfort_row = fields_flow.add {type = "flow", direction = "horizontal"}
    comfort_row.style.vertical_align = "center"
    comfort_row.add {type = "label", caption = {"city-view.housing-balancing-edit-max-comfort"}}
    local comfort_val = override.max_comfort or housing.max_comfort
    local comfort_slider = comfort_row.add {
        type = "slider",
        minimum_value = 0,
        maximum_value = Housing.max_level,
        value = comfort_val,
        value_step = 1,
        tags = {sosciencity_gui_event = "hbal_house_comfort_changed"}
    }
    comfort_slider.style.width = 150
    Gui.register_element(comfort_slider, CONTEXT, "house_comfort_slider", player_index)
    local comfort_label = comfort_row.add {type = "label", caption = tostring(comfort_val)}
    Gui.register_element(comfort_label, CONTEXT, "house_comfort_label", player_index)

    -- Trait checkboxes (all 14, pre-filled from housing.traits or override)
    fields_flow.add {type = "label", caption = {"city-view.housing-balancing-edit-traits"}}
    local active_traits = {}
    if override.traits then
        for _, t in pairs(override.traits) do active_traits[t] = true end
    else
        for _, t in pairs(housing.traits or {}) do active_traits[t] = true end
    end
    local traits_tbl = fields_flow.add {type = "table", column_count = EDITOR_TRAIT_COLS, style = "sosciencity_datalist"}
    for _, trait_id in pairs(ALL_TRAIT_IDS) do
        local trait_name = TRAIT_NAMES[trait_id]
        local cb = traits_tbl.add {
            type = "checkbox",
            state = active_traits[trait_id] or false,
            caption = {"housing-trait." .. trait_name},
            tooltip = {"housing-trait-description." .. trait_name},
            tags = {sosciencity_gui_event = "hbal_house_trait_toggle", trait = trait_id}
        }
        Gui.register_element(cb, CONTEXT, "house_trait_" .. trait_id, player_index)
    end
end

local function build_house_editor(container, player_index)
    local content = Gui.Elements.CollapsibleSection.heading_2(
        container,
        {"city-view.housing-balancing-house-editor"},
        {collapsed = true}
    )

    local names = get_house_picker_names()
    if #names == 0 then return end

    local picker_row = content.add {type = "flow", direction = "horizontal"}
    picker_row.style.vertical_align = "center"
    picker_row.add {type = "label", caption = {"city-view.housing-balancing-edit-select-house"}}
    local picker = picker_row.add {
        type = "drop-down",
        items = names,
        selected_index = 1,
        tags = {sosciencity_gui_event = "hbal_house_picker_changed"}
    }
    Gui.register_element(picker, CONTEXT, "house_picker", player_index)

    local fields_flow = content.add {type = "flow", direction = "vertical"}
    Gui.register_element(fields_flow, CONTEXT, "house_editor_fields", player_index)

    local overrides = get_overrides(player_index)
    overrides.current_house = names[1]
    set_overrides(player_index, overrides)
    build_house_editor_fields(fields_flow, names[1], overrides, player_index)
end

---------------------------------------------------------------------------------------------------
-- << Caste override editor >>
---------------------------------------------------------------------------------------------------

local function build_caste_editor(container, player_index)
    local content = Gui.Elements.CollapsibleSection.heading_2(
        container,
        {"city-view.housing-balancing-caste-editor"},
        {collapsed = true}
    )

    local castes = Castes.all
    local col_count = 1 + 1 + #ALL_TRAIT_IDS  -- name + required_room_count + 14 traits
    local tbl = content.add {type = "table", column_count = col_count, style = "sosciencity_datalist"}

    -- Header row
    add_header_label(tbl, {"city-view.housing-balancing-col-name"}, EDITOR_CASTE_NAME_WIDTH)
    add_header_label(tbl, {"city-view.housing-balancing-caste-col-room-req"}, EDITOR_FIELD_WIDTH)
    for _, trait_id in pairs(ALL_TRAIT_IDS) do
        local trait_name = TRAIT_NAMES[trait_id]
        local lbl = tbl.add {
            type = "label",
            caption = string.sub(trait_name, 1, 4),
            tooltip = {"housing-trait." .. trait_name}
        }
        lbl.style.font = "default-bold"
        lbl.style.width = EDITOR_FIELD_WIDTH
    end

    -- Data rows: one per caste
    local overrides = get_overrides(player_index)
    for _, caste in pairs(castes) do
        local caste_override = overrides.caste_overrides[tostring(caste.type)] or {}
        local prefs = caste_override.preferences or {}

        local name_lbl = tbl.add {
            type = "label",
            caption = {"", string.format("[technology=%s-caste] ", caste.name), {"caste-name." .. caste.name}},
            elem_tooltip = {type = "technology", name = caste.name .. "-caste"}
        }
        name_lbl.style.width = EDITOR_CASTE_NAME_WIDTH

        local rrc_field = Gui.Elements.NumericTextField.create(tbl, nil, {
            min = 0,
            normal_font_color = EDITOR_FONT_COLOR,
            numeric_confirmed_event = "hbal_caste_field_confirmed",
            caste_id = caste.type,
            is_room_count = true
        })
        rrc_field.text = tostring(caste_override.required_room_count or caste.required_room_count)
        rrc_field.style.width = EDITOR_FIELD_WIDTH

        for _, trait_id in pairs(ALL_TRAIT_IDS) do
            local pref_field = Gui.Elements.NumericTextField.create(tbl, nil, {
                step = 1,
                normal_font_color = EDITOR_FONT_COLOR,
                numeric_confirmed_event = "hbal_caste_field_confirmed",
                caste_id = caste.type,
                trait_id = trait_id
            })
            pref_field.text = tostring(prefs[tostring(trait_id)] or caste.housing_preferences[trait_id] or 0)
            pref_field.style.width = EDITOR_FIELD_WIDTH
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << Event handlers >>
---------------------------------------------------------------------------------------------------

Gui.set_checked_state_handler(
    "hbal_trait_toggle",
    function(event)
        rebuild_tables(event.player_index)
    end
)

Gui.set_value_changed_handler(
    "hbal_slider_changed",
    function(event)
        local player_index = event.player_index
        local label = Gui.get_element(CONTEXT, "comfort_label", player_index)
        label.caption = tostring(math.floor(event.element.slider_value))
        rebuild_tables(player_index)
    end
)

Gui.set_selection_state_changed_handler(
    "hbal_house_picker_changed",
    function(event)
        local player_index = event.player_index
        local names = get_house_picker_names()
        local new_house = names[event.element.selected_index]

        local overrides = get_overrides(player_index)
        overrides.current_house = new_house
        set_overrides(player_index, overrides)

        local fields_flow = Gui.get_element(CONTEXT, "house_editor_fields", player_index)
        build_house_editor_fields(fields_flow, new_house, overrides, player_index)
        rebuild_tables(player_index)
    end
)

Gui.set_value_changed_handler(
    "hbal_house_comfort_changed",
    function(event)
        local player_index = event.player_index
        local val = math.floor(event.element.slider_value)

        local label = Gui.get_element(CONTEXT, "house_comfort_label", player_index)
        if label then label.caption = tostring(val) end

        local overrides = get_overrides(player_index)
        local current_house = overrides.current_house
        if not current_house then return end
        if not overrides.house_overrides[current_house] then
            overrides.house_overrides[current_house] = {}
        end
        overrides.house_overrides[current_house].max_comfort = val
        set_overrides(player_index, overrides)
        rebuild_tables(player_index)
    end
)

Gui.set_checked_state_handler(
    "hbal_house_trait_toggle",
    function(event)
        local player_index = event.player_index
        local overrides = get_overrides(player_index)
        local current_house = overrides.current_house
        if not current_house then return end

        local new_traits = {}
        for _, trait_id in pairs(ALL_TRAIT_IDS) do
            local cb = Gui.get_element(CONTEXT, "house_trait_" .. trait_id, player_index)
            if cb and cb.state then
                new_traits[#new_traits + 1] = trait_id
            end
        end

        if not overrides.house_overrides[current_house] then
            overrides.house_overrides[current_house] = {}
        end
        overrides.house_overrides[current_house].traits = new_traits
        set_overrides(player_index, overrides)
        rebuild_tables(player_index)
    end
)

Gui.Elements.NumericTextField.set_confirmed_handler(
    "hbal_house_roomcount_confirmed",
    function(event, result)
        local player_index = event.player_index
        local overrides = get_overrides(player_index)
        local current_house = overrides.current_house
        if not current_house then return end
        if not overrides.house_overrides[current_house] then
            overrides.house_overrides[current_house] = {}
        end
        overrides.house_overrides[current_house].room_count = math.floor(result)
        set_overrides(player_index, overrides)
        rebuild_tables(player_index)
    end
)

Gui.Elements.NumericTextField.set_confirmed_handler(
    "hbal_caste_field_confirmed",
    function(event, result)
        local player_index = event.player_index
        local tags = event.element.tags
        local caste_key = tostring(tags.caste_id)
        local overrides = get_overrides(player_index)

        if not overrides.caste_overrides[caste_key] then
            overrides.caste_overrides[caste_key] = {}
        end
        local co = overrides.caste_overrides[caste_key]

        if tags.is_room_count then
            co.required_room_count = result
        else
            if not co.preferences then co.preferences = {} end
            co.preferences[tostring(tags.trait_id)] = math.floor(result)
        end

        set_overrides(player_index, overrides)
        rebuild_tables(player_index)
    end
)

---------------------------------------------------------------------------------------------------
-- << Page registration >>
---------------------------------------------------------------------------------------------------

Gui.CityView.add_page {
    name = "housing-balancing",
    category = "debug",
    localised_name = {"city-view.housing-balancing"},
    creator = function(container)
        local player_index = container.player_index
        local main_flow = container.add {type = "flow", name = "main_flow", direction = "vertical"}

        -- Hidden element that stores override state in its tags (no storage access needed)
        local overrides_store = main_flow.add {type = "flow", visible = false}
        overrides_store.tags = {house_overrides = {}, caste_overrides = {}}
        Gui.register_element(overrides_store, CONTEXT, "overrides_store", player_index)

        -- Static house stats table
        local static_flow = main_flow.add {type = "flow", direction = "vertical"}
        Gui.register_element(static_flow, CONTEXT, "static_flow", player_index)

        Gui.Elements.Utils.separator_line(main_flow)

        -- Purchasable trait toggles (placed here because they affect the caste table below)
        local traits_row = main_flow.add {type = "flow", direction = "horizontal"}
        traits_row.style.vertical_align = "center"
        traits_row.add {type = "label", caption = {"city-view.housing-balancing-purchasable-traits"}}
        for _, trait in pairs(PURCHASABLE_TRAITS) do
            local trait_name = TRAIT_NAMES[trait]
            local cb = traits_row.add {
                type = "checkbox",
                state = false,
                caption = {"housing-trait." .. trait_name},
                tooltip = {"housing-trait-description." .. trait_name},
                tags = {sosciencity_gui_event = "hbal_trait_toggle", trait = trait}
            }
            Gui.register_element(cb, CONTEXT, "trait_" .. trait, player_index)
        end

        -- Comfort level slider
        local slider_row = main_flow.add {type = "flow", direction = "horizontal"}
        slider_row.style.vertical_align = "center"
        slider_row.add {type = "label", caption = {"city-view.housing-balancing-comfort-level"}}
        local slider = slider_row.add {
            type = "slider",
            minimum_value = 0,
            maximum_value = Housing.max_level,
            value = Housing.max_level,
            value_step = 1,
            tags = {sosciencity_gui_event = "hbal_slider_changed"}
        }
        slider.style.width = 200
        Gui.register_element(slider, CONTEXT, "comfort_slider", player_index)
        local comfort_label = slider_row.add {type = "label", caption = tostring(Housing.max_level)}
        Gui.register_element(comfort_label, CONTEXT, "comfort_label", player_index)

        -- Caste happiness/capacity table
        local caste_flow = main_flow.add {type = "flow", direction = "vertical"}
        Gui.register_element(caste_flow, CONTEXT, "caste_flow", player_index)

        rebuild_tables(player_index)

        Gui.Elements.Utils.separator_line(main_flow)
        build_house_editor(main_flow, player_index)

        Gui.Elements.Utils.separator_line(main_flow)
        build_caste_editor(main_flow, player_index)
    end
}
