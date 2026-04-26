--- The gui that pops up when the player opens a entity.
Gui.DetailsView = {}

local DETAILS_VIEW_NAME = "sosciencity-details"

-- enums

local EK = require("enums.entry-key")
local Type = require("enums.type")

-- constants

local Buildings = require("constants.buildings")
local Time = require("constants.time")
local Types = require("constants.types")

-- local often used globals for microscopic performance gains

local Communication = Communication
local Gui = Gui
local Inhabitants = Inhabitants
local Locale = Locale
local Register = Register
local get_building_details = Buildings.get
local type_definitions = Types.definitions

local ceil = math.ceil
local floor = math.floor
local min = math.min
local max = math.max
local round = Tirislib.Utils.round
local round_to_step = Tirislib.Utils.round_to_step
local tonumber = tonumber
local tostring = tostring

local Luaq_from = Tirislib.Luaq.from

local display_enumeration = Tirislib.Locales.create_enumeration

local Datalist = Gui.Elements.Datalist

local function update_details_header(container, entry)
    local display_flow = container.parent.header.display_flow
    display_flow.name_label.caption = Locale.entry(entry)
    display_flow.reset_button.visible = entry[EK.custom_name] ~= nil
end

local function get_or_create_tabbed_pane(container) -- TODO this doesn't belong to this file
    local tabpane = container.tabpane
    if container.tabpane then
        return tabpane
    else
        return container.add {
            type = "tabbed-pane",
            name = "tabpane"
        }
    end
end

Gui.DetailsView.update_header = update_details_header
Gui.DetailsView.get_or_create_tabbed_pane = get_or_create_tabbed_pane

-- Per-player flag: true while the player is typing in the staff target textfield.
-- Prevents the tick-based update from overwriting their input.
-- TODO: test if such a pattern can cause desyncs
local editing_staff_target = {}

---------------------------------------------------------------------------------------------------
-- << general building details >>

local function update_worker_list(list, entry)
    local workers = entry[EK.workers]

    list.clear()

    local at_least_one = false
    for unit_number, count in pairs(workers) do
        local house = Register.try_get(unit_number)
        if house then
            Datalist.add_operand_entry(list, unit_number, Locale.entry_with_coords(house), count)

            at_least_one = true
        end
    end

    if not at_least_one then
        Datalist.add_operand_entry(list, "no-one", {"sosciencity.no-employees"}, "-")
    end
end

local function update_general_building_details(container, entry, player_id)
    local tabbed_pane = container.tabpane
    local tab = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = tab.building

    local building_details = get_building_details(entry)
    local type_details = type_definitions[entry[EK.type]]

    local active = entry[EK.active]
    if active ~= nil then
        Datalist.set_kv_pair_value(
            building_data,
            "active",
            active and {"sosciencity.active"} or {"sosciencity.inactive"}
        )
        Datalist.set_kv_pair_visibility(building_data, "active", true)
    else
        Datalist.set_kv_pair_visibility(building_data, "active", false)
    end

    local worker_specification = get_building_details(entry).workforce
    if worker_specification then
        local target_count = entry[EK.target_worker_count]
        Datalist.set_kv_pair_value(
            building_data,
            "staff",
            {"sosciencity.show-staff", entry[EK.worker_count], target_count}
        )

        building_data["staff-target"].slider_value = target_count

        if not editing_staff_target[player_id] then
            building_data["staff-target-input"].text = tostring(target_count)
        end

        local staff_performance = Inhabitants.evaluate_workforce(entry)
        Datalist.set_kv_pair_value(
            building_data,
            "staff-performance",
            staff_performance >= 0.2 and {"sosciencity.staff-performance", ceil(staff_performance * 100)} or
                {"sosciencity.not-enough-staff", ceil(0.2 * worker_specification.count)}
        )

        local worker_data = tab.workers
        update_worker_list(worker_data, entry)
    end

    local performance = entry[EK.performance]
    if building_details.speed then
        -- convert to x / minute
        local speed = round(building_details.speed * Time.minute * (entry[EK.performance] or 1))
        Datalist.set_kv_pair_value(building_data, "speed", {type_details.localised_speed_key, speed})
    elseif performance then
        Datalist.set_kv_pair_value(
            building_data,
            "general-performance",
            performance > 0.19999 and {"sosciencity.percentage", ceil(performance * 100)} or {"sosciencity.not-working"}
        )
    end

    if type_details.affected_by_clockwork then
        local clockwork_value = storage.caste_bonuses[Type.clockwork]
        Datalist.set_kv_pair_value(
            building_data,
            "maintenance",
            clockwork_value >= 0 and {"sosciencity.display-good-maintenance", clockwork_value} or
                {"sosciencity.display-bad-maintenance", clockwork_value}
        )
    end

    local report_flow = tab["performance-report"]
    if report_flow then
        Gui.Elements.PerformanceReport.update(report_flow, entry)
    end
end

local function create_general_building_details(container, entry, player_id)
    update_details_header(container, entry)

    local building_details = get_building_details(entry)
    local type_details = type_definitions[entry[EK.type]]

    local tabbed_pane = get_or_create_tabbed_pane(container)
    local tab = Gui.Elements.Tabs.create(tabbed_pane, "general", {"sosciencity.general"})

    if type_details.has_subscriptions then
        local flow =
            tab.add {
            type = "flow",
            name = "notification-flow",
            direction = "horizontal"
        }
        local style = flow.style
        style.horizontal_align = "right"
        style.horizontally_stretchable = true
        style.vertical_align = "center"
        style.right_padding = 10

        local notify_button =
            flow.add {
            type = "label",
            name = "notification-label",
            caption = {"sosciencity.notify-me"},
            tooltip = {"sosciencity.explain-notify-me"}
        }
        notify_button.style.font = "default-bold"

        flow.add {
            type = "checkbox",
            name = "notification",
            state = Communication.check_subscription(entry, player_id),
            tooltip = {"sosciencity.explain-notify-me"},
            tags = {sosciencity_gui_event = "notification_checkbox"}
        }
    end

    local building_data = Datalist.create(tab, "building")

    Datalist.add_kv_pair(building_data, "building-type", {"sosciencity.type"}, type_details.localised_name)
    Datalist.add_kv_pair(building_data, "description", "", type_details.localised_description)
    Datalist.add_kv_pair(building_data, "active", {"sosciencity.active"})

    if building_details.range then
        local range = building_details.range
        Datalist.add_kv_pair(
            building_data,
            "range",
            {"sosciencity.range"},
            (range ~= "global" and {"sosciencity.show-range", building_details.range * 2}) or
                {"sosciencity.global-range"}
        )
    end

    if building_details.power_usage then
        -- convert to kW
        local power = round_to_step(building_details.power_usage * Time.second / 1000, 0.1)
        Datalist.add_kv_pair(
            building_data,
            "power",
            {"sosciencity.power-demand"},
            {"sosciencity.current-power-demand", power}
        )
    end

    -- display for the main performance metric
    if building_details.speed then
        Datalist.add_kv_pair(building_data, "speed", type_details.localised_speed_name)
    elseif entry[EK.performance] then
        Datalist.add_kv_pair(building_data, "general-performance", {"sosciencity.general-performance"})
    end

    local worker_specification = building_details.workforce
    if worker_specification then
        Datalist.add_kv_pair(building_data, "staff", {"sosciencity.staff"})

        Datalist.add_key_label(building_data, "staff-target-label", {"sosciencity.target-staff"})
        local staff_input = building_data.add {
            type = "textfield",
            name = "staff-target-input",
            numeric = true,
            allow_negative = false,
            text = tostring(entry[EK.target_worker_count]),
            tags = {sosciencity_gui_event = "staff_target_input"}
        }
        staff_input.style.width = 60

        Datalist.add_key_label(building_data, "staff-target-slider-label", "")
        building_data.add {
            type = "slider",
            name = "staff-target",
            minimum_value = 0,
            maximum_value = worker_specification.count,
            value = entry[EK.target_worker_count],
            value_step = 1,
            tags = {sosciencity_gui_event = "staff_target_slider"}
        }

        editing_staff_target[player_id] = nil

        Datalist.add_kv_pair(building_data, "staff-performance")

        local castes_needed =
            Luaq_from(worker_specification.castes):select_element(Locale.caste, true):call(
            display_enumeration,
            nil,
            {"sosciencity.or"}
        )
        Datalist.add_kv_pair(building_data, "castes", {"sosciencity.caste"}, castes_needed)

        Gui.Elements.Label.header_label(tab, "worker-header", {"sosciencity.staff"})
        Datalist.create(tab, "workers")
    end

    if type_details.affected_by_clockwork then
        Datalist.add_kv_pair(building_data, "maintenance", {"sosciencity.maintenance"})
    end

    if entry[EK.performance_report] then
        Gui.Elements.Utils.separator_line(tab)
        Gui.Elements.Label.header_label(tab, "header-performance", {"sosciencity.performance-breakdown"})
        Gui.Elements.PerformanceReport.create(tab, "performance-report")
    end

    update_general_building_details(container, entry, player_id)

    return tabbed_pane
end

Gui.DetailsView.update_general = update_general_building_details
Gui.DetailsView.create_general = create_general_building_details

Gui.set_value_changed_handler(
    "staff_target_slider",
    function(event)
        local entry = Register.try_get(storage.details_view[event.player_index])
        local value = event.element.slider_value
        entry[EK.target_worker_count] = value

        -- sync the textfield
        local building_data = event.element.parent
        local input = building_data["staff-target-input"]
        if input then
            input.text = tostring(value)
        end
        editing_staff_target[event.player_index] = nil
    end
)

Gui.set_gui_confirmed_handler(
    "staff_target_input",
    function(event)
        local entry = Register.try_get(storage.details_view[event.player_index])
        if not entry then return end

        local workforce = get_building_details(entry).workforce
        local value = tonumber(event.element.text)
        if not value then
            -- reset to current value if the input is invalid
            event.element.text = tostring(entry[EK.target_worker_count])
            return
        end

        value = max(0, min(floor(value), workforce.count))

        entry[EK.target_worker_count] = value
        event.element.text = tostring(value)

        -- sync the slider
        local building_data = event.element.parent
        local slider = building_data["staff-target"]
        if slider then
            slider.slider_value = value
        end
        editing_staff_target[event.player_index] = nil
    end
)

Gui.set_text_changed_handler(
    "staff_target_input",
    function(event)
        editing_staff_target[event.player_index] = true
    end
)

Gui.set_checked_state_handler(
    "notification_checkbox",
    function(event)
        local player_id = event.player_index
        local entry = Register.try_get(storage.details_view[player_id])
        Communication.set_subscription(entry, player_id, event.element.state)
    end
)

---------------------------------------------------------------------------------------------------
-- << name editing >>

local function apply_name_edit(player_index)
    local frame = game.get_player(player_index).gui.screen[DETAILS_VIEW_NAME]
    if not frame or not frame.valid then return end
    local entry = Register.try_get(storage.details_view[player_index])
    if not entry then return end

    local new_name = frame.header.edit_flow.name_input.text
    entry[EK.custom_name] = (new_name ~= "") and new_name or nil

    frame.header.edit_flow.visible = false
    frame.header.display_flow.visible = true

    Gui.DetailsView.update_header_for_entry(entry)
end

Gui.set_click_handler(
    "details_name_edit",
    function(event)
        local player_index = event.player_index
        local entry = Register.try_get(storage.details_view[player_index])
        if not entry then return end

        local frame = game.get_player(player_index).gui.screen[DETAILS_VIEW_NAME]
        local header = frame.header
        header.display_flow.visible = false
        header.edit_flow.visible = true
        local input = header.edit_flow.name_input
        input.text = entry[EK.custom_name] or ""
        input.focus()
    end
)

Gui.set_click_handler("details_name_confirm", function(event)
    apply_name_edit(event.player_index)
end)

Gui.set_gui_confirmed_handler("details_name_input", function(event)
    apply_name_edit(event.player_index)
end)

Gui.set_click_handler(
    "details_name_cancel",
    function(event)
        local frame = game.get_player(event.player_index).gui.screen[DETAILS_VIEW_NAME]
        if not frame or not frame.valid then return end
        frame.header.edit_flow.visible = false
        frame.header.display_flow.visible = true
    end
)

Gui.set_click_handler(
    "details_name_reset",
    function(event)
        local player_index = event.player_index
        local entry = Register.try_get(storage.details_view[player_index])
        if not entry then return end

        entry[EK.custom_name] = nil
        Gui.DetailsView.update_header_for_entry(entry)
    end
)

---------------------------------------------------------------------------------------------------
-- << type registry >>

local type_gui_specifications = {}

--- Registers the gui specification for a type.
--- @param type_id integer
--- @param spec table (creater, updater optional, always_update optional)
function Gui.DetailsView.register_type(type_id, spec)
    type_gui_specifications[type_id] = spec
end

-- generic building types that only need the general view
local generic_spec = {creater = Gui.DetailsView.create_general, updater = Gui.DetailsView.update_general}
Gui.DetailsView.register_type(Type.mining_drill, generic_spec)
Gui.DetailsView.register_type(Type.assembling_machine, generic_spec)
Gui.DetailsView.register_type(Type.furnace, generic_spec)
Gui.DetailsView.register_type(Type.rocket_silo, generic_spec)
Gui.DetailsView.register_type(Type.caste_education_building, generic_spec)
Gui.DetailsView.register_type(Type.composter_output, generic_spec)
Gui.DetailsView.register_type(Type.egg_collector, generic_spec)
Gui.DetailsView.register_type(Type.pharmacy, generic_spec)
Gui.DetailsView.register_type(Type.psych_ward, generic_spec)
Gui.DetailsView.register_type(Type.manufactory, generic_spec)
Gui.DetailsView.register_type(Type.social_observatory, generic_spec)
Gui.DetailsView.register_type(Type.nightclub, generic_spec)

---------------------------------------------------------------------------------------------------
-- << general details view functions >>

function Gui.DetailsView.create(player)
    local frame = player.gui.screen[DETAILS_VIEW_NAME]
    if frame and frame.valid then
        return
    end

    frame = player.gui.screen.add {
        type = "frame",
        name = DETAILS_VIEW_NAME,
        direction = "vertical",
        style = "sosciencity_details_view_frame"
    }
    frame.location = {x = 10, y = 120}

    local header = frame.add {
        type = "flow",
        name = "header",
        direction = "horizontal",
        style = "sosciencity_city_view_header_flow"
    }
    header.drag_target = frame

    local display_flow = header.add {
        type = "flow",
        name = "display_flow",
        direction = "horizontal"
    }
    display_flow.style.horizontally_stretchable = true
    display_flow.drag_target = frame

    display_flow.add {
        type = "label",
        name = "name_label",
        ignored_by_interaction = true,
        style = "frame_title"
    }
    display_flow.add {
        type = "empty-widget",
        ignored_by_interaction = true,
        style = "sosciencity_details_header_drag"
    }
    display_flow.add {
        type = "sprite-button",
        name = "reset_button",
        sprite = "utility/reset_white",
        style = "frame_action_button",
        visible = false,
        tooltip = {"sosciencity.reset-name"},
        tags = {sosciencity_gui_event = "details_name_reset"}
    }
    display_flow.add {
        type = "sprite-button",
        name = "edit_button",
        sprite = "utility/rename_icon",
        style = "frame_action_button",
        tooltip = {"sosciencity.edit-name"},
        tags = {sosciencity_gui_event = "details_name_edit"}
    }

    local edit_flow = header.add {
        type = "flow",
        name = "edit_flow",
        direction = "horizontal",
        visible = false
    }
    edit_flow.style.horizontally_stretchable = true

    local name_input = edit_flow.add {
        type = "textfield",
        name = "name_input",
        tags = {sosciencity_gui_event = "details_name_input"}
    }
    name_input.style.horizontally_stretchable = true

    edit_flow.add {
        type = "sprite-button",
        name = "confirm_button",
        sprite = "utility/check_mark_white",
        style = "frame_action_button",
        tooltip = {"sosciencity.confirm-name-edit"},
        tags = {sosciencity_gui_event = "details_name_confirm"}
    }
    edit_flow.add {
        type = "sprite-button",
        name = "cancel_button",
        sprite = "utility/close",
        style = "frame_action_button",
        tooltip = {"sosciencity.cancel-name-edit"},
        tags = {sosciencity_gui_event = "details_name_cancel"}
    }

    frame.add {
        type = "frame",
        name = "nested",
        direction = "horizontal",
        style = "inside_deep_frame"
    }

    frame.visible = false
end

--- Returns the DetailsView for the given player.
--- @param player LuaPlayer
--- @return LuaGuiElement
local function get_details_view(player)
    local details_view = player.gui.screen[DETAILS_VIEW_NAME]

    -- we check if the gui still exists, as other mods can delete it
    if details_view ~= nil and details_view.valid then
        return details_view
    else
        -- recreate it otherwise
        Gui.DetailsView.create(player)
        return get_details_view(player)
    end
end

Gui.DetailsView.get = get_details_view

--- Returns the nested content-part of the DetailView for the given player.
--- @param player LuaPlayer
--- @return LuaGuiElement
local function get_nested_details_view(player)
    return get_details_view(player).nested
end

Gui.DetailsView.get_nested = get_nested_details_view

--- Updates the details guis for every player.
function Gui.DetailsView.update()
    local current_tick = game.tick

    for player_id, unit_number in pairs(storage.details_view) do
        local entry = Register.try_get(unit_number)
        local player = game.get_player(player_id)

        -- check if the entity hasn't been unregistered in the meantime
        if not entry then
            Gui.DetailsView.close(player)
        else
            local gui_spec = type_gui_specifications[entry[EK.type]]
            local updater = gui_spec and gui_spec.updater

            if updater and (entry[EK.last_update] == current_tick or gui_spec.always_update) then
                updater(get_nested_details_view(player), entry, player_id)
            end
        end
    end
end

--- Builds a details gui for the given player and the given entity.
--- @param player LuaPlayer
--- @param unit_number integer
function Gui.DetailsView.open(player, unit_number)
    local entry = Register.try_get(unit_number)
    if not entry then
        return
    end

    local gui_spec = type_gui_specifications[entry[EK.type]]
    local creater = gui_spec and gui_spec.creater
    if not creater then
        return
    end

    local details_view = get_details_view(player)
    local player_id = player.index
    local nested = details_view.nested

    local previous = storage.details_view[player_id]
    if previous then
        Gui.unregister_context(previous)
    end
    nested.clear()

    local header = details_view.header
    header.edit_flow.visible = false
    header.display_flow.visible = true

    creater(nested, entry, player_id)
    details_view.visible = true
    storage.details_view[player_id] = unit_number
end

--- Closes the details view for the given player.
--- @param player LuaPlayer
function Gui.DetailsView.close(player)
    local details_view = get_details_view(player)
    local previous = storage.details_view[player.index]
    if previous then
        Gui.unregister_context(previous)
    end
    details_view.visible = false
    storage.details_view[player.index] = nil
    details_view.nested.clear()
end

--- Closes and reopens all the Guis related to the given entry.
--- @param entry Entry
function Gui.DetailsView.rebuild_for_entry(entry)
    local unit_number = entry[EK.unit_number]

    for player_index, viewed_unit_number in pairs(storage.details_view) do
        if unit_number == viewed_unit_number then
            local player = game.get_player(player_index)
            Gui.DetailsView.close(player)
            Gui.DetailsView.open(player, unit_number)
        end
    end
end

--- Calls the updater for all open detail views showing the given entry, without rebuilding.
--- Preserves scroll position and selected tab.
--- @param entry Entry
function Gui.DetailsView.update_for_entry(entry)
    local unit_number = entry[EK.unit_number]

    for player_id, viewed_unit_number in pairs(storage.details_view) do
        if unit_number == viewed_unit_number then
            local player = game.get_player(player_id)
            local gui_spec = type_gui_specifications[entry[EK.type]]
            local updater = gui_spec and gui_spec.updater
            if updater then
                updater(get_nested_details_view(player), entry, player_id)
            end
        end
    end
end

--- Updates the name label and reset button for all players currently viewing entry.
--- @param entry Entry
function Gui.DetailsView.update_header_for_entry(entry)
    local unit_number = entry[EK.unit_number]
    for player_id, viewed_unit_number in pairs(storage.details_view) do
        if unit_number == viewed_unit_number then
            update_details_header(
                get_details_view(game.get_player(player_id)).nested,
                entry
            )
        end
    end
end

--- Destroys the city info gui.
--- @param player LuaPlayer
function Gui.DetailsView.destroy(player)
    local details_view_gui = player.gui.screen[DETAILS_VIEW_NAME]

    if details_view_gui ~= nil and details_view_gui.valid then
        details_view_gui.destroy()
    end
end

Gui.add_gui_opened_handler(
    function(player, event)
        if event.gui_type == defines.gui_type.entity then
            Gui.DetailsView.open(player, event.entity.unit_number)
        end
    end
)

Gui.add_gui_closed_handler(
    function(player, event)
        if event.gui_type == defines.gui_type.entity then
            Gui.DetailsView.close(player)
        end
    end
)

require("classes.guis.details-view-types.housing")
require("classes.guis.details-view-types.food-production")
require("classes.guis.details-view-types.hospital")
require("classes.guis.details-view-types.upbringing-station")
require("classes.guis.details-view-types.waste-management")
require("classes.guis.details-view-types.supply")
require("classes.guis.details-view-types.misc")
