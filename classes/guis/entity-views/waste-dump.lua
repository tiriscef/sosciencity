--- Details view for the waste dump.

-- enums
local EK = require("enums.entry-key")
local Type = require("enums.type")
local WasteDumpOperationMode = require("enums.waste-dump-operation-mode")

-- constants
local Buildings = require("constants.buildings")

local Gui = Gui
local Register = Register
local get_building_details = Buildings.get
local format = string.format
local display_item_stack = Tirislib.Locales.display_item_stack
local display_enumeration = Tirislib.Locales.create_enumeration
local Table = Tirislib.Tables
local Luaq_from = Tirislib.Luaq.from
local Datalist = Gui.Elements.Datalist

local function update_waste_dump_mode_radiobuttons(entry, mode_flow)
    local active_mode = entry[EK.waste_dump_mode]
    for mode_name, mode_id in pairs(WasteDumpOperationMode) do
        local radiobutton = mode_flow[format(Gui.unique_prefix_builder, "waste-dump-mode", mode_name)]
        radiobutton.state = (active_mode == mode_id)
    end
end

local function update_waste_dump(container, entry, player_id)
    Gui.DetailsView.update_general(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local building_data = Gui.Elements.Tabs.get_content(tabbed_pane, "general").building

    local stored_garbage = entry[EK.stored_garbage]
    local capacity = get_building_details(entry).capacity
    Datalist.set_kv_pair_value(
        building_data,
        "capacity",
        {
            "sosciencity.value-with-unit",
            {"sosciencity.fraction", Table.sum(stored_garbage), capacity},
            {"sosciencity.items"}
        }
    )

    Datalist.set_kv_pair_value(
        building_data,
        "stored_garbage",
        Luaq_from(stored_garbage):select(display_item_stack):call(display_enumeration, "\n")
    )

    update_waste_dump_mode_radiobuttons(entry, Datalist.get_kv_value_element(building_data, "mode"))

    local checkbox = Datalist.get_checkbox(building_data, "press")
    checkbox.state = entry[EK.press_mode]
end

local function create_waste_dump(container, entry, player_id)
    local tabbed_pane = Gui.DetailsView.create_general(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "capacity", {"sosciencity.capacity"})
    Datalist.add_kv_pair(building_data, "stored_garbage", {"sosciencity.content"})

    local mode_flow = Datalist.add_kv_flow(building_data, "mode", {"sosciencity.mode"})
    for mode_name, mode_id in pairs(WasteDumpOperationMode) do
        mode_flow.add {
            name = format(Gui.unique_prefix_builder, "waste-dump-mode", mode_name),
            type = "radiobutton",
            caption = {"sosciencity." .. mode_name},
            state = true,
            tags = {sosciencity_gui_event = "waste_dump_mode_radiobutton", mode_id = mode_id}
        }
    end

    local press_checkbox, _ =
        Datalist.add_kv_checkbox(
        building_data,
        "press",
        format(Gui.unique_prefix_builder, "waste-dump-press", ""),
        {"sosciencity.press"},
        {"sosciencity.active"}
    )
    press_checkbox.tags = {sosciencity_gui_event = "waste_dump_press_checkbox"}

    update_waste_dump(container, entry)
end

Gui.set_checked_state_handler(
    "waste_dump_mode_radiobutton",
    function(event)
        if event.element.state then
            local player_id = event.player_index
            local entry = Register.try_get(storage.details_view[player_id])
            entry[EK.waste_dump_mode] = event.element.tags.mode_id
            update_waste_dump_mode_radiobuttons(entry, event.element.parent)
        end
    end
)

Gui.set_checked_state_handler(
    "waste_dump_press_checkbox",
    function(event)
        local entry = Register.try_get(storage.details_view[event.player_index])
        entry[EK.press_mode] = event.element.state
    end
)

Gui.DetailsView.register_type(Type.waste_dump, {creater = create_waste_dump, updater = update_waste_dump})

Gui.BuildingOverview.register_type("waste-dumps", {
    types = {Type.waste_dump},
    layout = "list",
    stats_creator = Gui.BuildingOverview.generic_stats_creator
})
