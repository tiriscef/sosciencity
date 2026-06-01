--- Details view for the water well.

-- enums
local EK = require("enums.entry-key")
local Type = require("enums.type")

local Gui = Gui
local display_item_stack = Tirislib.Locales.display_item_stack
local Datalist = Gui.Elements.Datalist

local function update_waterwell_details(container, entry, player_id)
    Gui.DetailsView.update_general(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local building_data = Gui.Elements.Tabs.get_content(tabbed_pane, "general").building

    Datalist.set_kv_pair_visibility(building_data, "module", not entry[EK.active])
end

local function create_waterwell_details(container, entry, player_id)
    local tabbed_pane = Gui.DetailsView.create_general(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(
        building_data,
        "module",
        nil,
        {"sosciencity.module-missing", display_item_stack("water-filter", 1)}
    )

    update_waterwell_details(container, entry)
end

Gui.DetailsView.register_type(Type.waterwell, {creater = create_waterwell_details, updater = update_waterwell_details})

Gui.BuildingOverview.register_type("waterwells", {
    types = {Type.waterwell},
    layout = "list",
    stats_creator = Gui.BuildingOverview.generic_stats_creator
})
