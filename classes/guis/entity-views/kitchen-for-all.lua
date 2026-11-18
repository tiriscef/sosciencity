--- Details view for the kitchen for all.

-- enums
local EK = require("enums.entry-key")
local Type = require("enums.type")

local BuildingOverview = require("classes.guis.building-overview")
local DetailsView = require("classes.guis.details-view")
local Elements = require("classes.guis.elements")

local Datalist = Elements.Datalist

local function update_kitchen_for_all(container, entry, player_id)
    DetailsView.update_general(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local building_data = Elements.Tabs.get_content(tabbed_pane, "general").building

    Datalist.set_kv_pair_value(building_data, "inhabitants", entry[EK.participating_inhabitants])
end

local function create_kitchen_for_all(container, entry, player_id)
    local tabbed_pane = DetailsView.create_general(container, entry, player_id)

    local general = Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "inhabitants", {"sosciencity.inhabitants"})

    update_kitchen_for_all(container, entry, player_id)
end

DetailsView.register_type(Type.kitchen_for_all, {creater = create_kitchen_for_all, updater = update_kitchen_for_all})

BuildingOverview.register_type("kitchens-for-all", {
    types = {Type.kitchen_for_all},
    layout = "grid",
    stats_creator = function(flow, entry)
        BuildingOverview.generic_stats_creator(flow, entry)
        flow.add {type = "label", caption = {"sosciencity.display-dependants", entry[EK.participating_inhabitants]}}
    end
})
