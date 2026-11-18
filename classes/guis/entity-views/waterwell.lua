--- Details view for the water well.

-- enums
local Type = require("enums.type")

local Waterwell = require("classes.entities.waterwell")
local BuildingOverview = require("classes.guis.building-overview")
local DetailsView = require("classes.guis.details-view")
local Elements = require("classes.guis.elements")

local display_item_stack = Tirislib.Locales.display_item_stack
local Datalist = Elements.Datalist

local function update_waterwell_details(container, entry, player_id)
    DetailsView.update_general(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local building_data = Elements.Tabs.get_content(tabbed_pane, "general").building

    local missing_module = Waterwell.get_missing_module(entry)
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
    local tabbed_pane = DetailsView.create_general(container, entry, player_id)

    local general = Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "module", nil, "")

    update_waterwell_details(container, entry)
end

DetailsView.register_type(Type.waterwell, {creater = create_waterwell_details, updater = update_waterwell_details})

BuildingOverview.register_type("waterwells", {
    types = {Type.waterwell},
    layout = "grid",
    stats_creator = BuildingOverview.generic_stats_creator
})
