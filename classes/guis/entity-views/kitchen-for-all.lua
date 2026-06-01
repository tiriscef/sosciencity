--- Details view for the kitchen for all.

-- enums
local EK = require("enums.entry-key")
local Type = require("enums.type")

local Gui = Gui
local Datalist = Gui.Elements.Datalist

local function update_kitchen_for_all(container, entry, player_id)
    Gui.DetailsView.update_general(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local building_data = Gui.Elements.Tabs.get_content(tabbed_pane, "general").building

    Datalist.set_kv_pair_value(building_data, "inhabitants", entry[EK.participating_inhabitants])
end

local function create_kitchen_for_all(container, entry, player_id)
    local tabbed_pane = Gui.DetailsView.create_general(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "inhabitants", {"sosciencity.inhabitants"})

    update_kitchen_for_all(container, entry, player_id)
end

Gui.DetailsView.register_type(Type.kitchen_for_all, {creater = create_kitchen_for_all, updater = update_kitchen_for_all})

Gui.BuildingOverview.register_type("kitchens-for-all", {
    types = {Type.kitchen_for_all},
    layout = "list",
    stats_creator = Gui.BuildingOverview.generic_stats_creator
})
