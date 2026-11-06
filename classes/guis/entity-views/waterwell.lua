--- Details view for the water well.

-- enums
local Type = require("enums.type")

local Entity = Entity
local Gui = Gui
local display_item_stack = Tirislib.Locales.display_item_stack
local Datalist = Gui.Elements.Datalist

local function update_waterwell_details(container, entry, player_id)
    Gui.DetailsView.update_general(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local building_data = Gui.Elements.Tabs.get_content(tabbed_pane, "general").building

    local missing_module = Entity.Waterwell.get_missing_module(entry)
    Datalist.set_kv_pair_visibility(building_data, "module", missing_module ~= nil)
    if missing_module then
        Datalist.set_kv_pair_value(
            building_data,
            "module",
            {"sosciencity.module-missing", display_item_stack(missing_module, 1)}
        )
    end
end

local function create_waterwell_details(container, entry, player_id)
    local tabbed_pane = Gui.DetailsView.create_general(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "module", nil, "")

    update_waterwell_details(container, entry)
end

Gui.DetailsView.register_type(Type.waterwell, {creater = create_waterwell_details, updater = update_waterwell_details})

Gui.BuildingOverview.register_type("waterwells", {
    types = {Type.waterwell},
    layout = "grid",
    stats_creator = Gui.BuildingOverview.generic_stats_creator
})
