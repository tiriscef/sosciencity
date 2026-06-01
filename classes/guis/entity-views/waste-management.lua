--- Details view for waste management buildings.

-- enums
local EK = require("enums.entry-key")
local Type = require("enums.type")
local WasteDumpOperationMode = require("enums.waste-dump-operation-mode")

-- constants
local Buildings = require("constants.buildings")
local Castes = require("constants.castes")
local Food = require("constants.food")
local InhabitantsConstants = require("constants.inhabitants")
local Time = require("constants.time")

local Gui = Gui
local Neighborhood = Neighborhood
local Register = Register
local get_building_details = Buildings.get
local format = string.format
local round_to_step = Tirislib.Utils.round_to_step
local display_item_stack = Tirislib.Locales.display_item_stack
local display_enumeration = Tirislib.Locales.create_enumeration
local Table = Tirislib.Tables
local Luaq_from = Tirislib.Luaq.from
local Datalist = Gui.Elements.Datalist

---------------------------------------------------------------------------------------------------
-- << waste dump >>

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

---------------------------------------------------------------------------------------------------
-- << dumpster >>

local average_calories = Luaq_from(Food.values):select_key("calories"):call(Table.average)

local function analyse_garbage_output(entry)
    local inhabitant_count = 0
    local garbage = 0
    local calorific_demand = 0

    for _, caste in pairs(Castes.all) do
        local caste_inhabitants = 0
        for _, house in Neighborhood.iterate_type(entry, caste.type) do
            caste_inhabitants = caste_inhabitants + house[EK.inhabitants]
        end
        inhabitant_count = inhabitant_count + caste_inhabitants

        garbage = garbage + caste_inhabitants * caste.garbage_coefficient
        calorific_demand = calorific_demand + caste_inhabitants * caste.calorific_demand
    end

    return inhabitant_count, garbage, InhabitantsConstants.food_leftovers_chance * calorific_demand / average_calories
end

local function update_dumpster(container, entry, player_id)
    Gui.DetailsView.update_general(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local building_data = Gui.Elements.Tabs.get_content(tabbed_pane, "general").building

    local inhabitants, garbage, food_leftovers = analyse_garbage_output(entry)
    Datalist.set_kv_pair_value(
        building_data,
        "dependants",
        {
            "sosciencity.value-with-unit",
            inhabitants,
            {"sosciencity.inhabitants"}
        }
    )
    Datalist.set_kv_pair_value(
        building_data,
        "garbage",
        {
            "sosciencity.fraction",
            display_item_stack("garbage", round_to_step(garbage * Time.minute, 0.1)),
            {"sosciencity.minute"}
        }
    )
    Datalist.set_kv_pair_value(
        building_data,
        "food_leftovers",
        {
            "sosciencity.fraction",
            display_item_stack("food-leftovers", round_to_step(food_leftovers * Time.minute, 0.1)),
            {"sosciencity.minute"}
        }
    )
end

local function create_dumpster(container, entry, player_id)
    local tabbed_pane = Gui.DetailsView.create_general(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "dependants", {"sosciencity.dependants"})
    Datalist.add_kv_pair(building_data, "garbage", {"item-name.garbage"})
    Datalist.add_kv_pair(building_data, "food_leftovers")

    update_dumpster(container, entry)
end

Gui.DetailsView.register_type(Type.dumpster, {creater = create_dumpster, updater = update_dumpster})
