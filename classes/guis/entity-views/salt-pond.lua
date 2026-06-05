--- Details view for the salt pond.

-- enums
local EK = require("enums.entry-key")
local Type = require("enums.type")

-- constants
local Buildings = require("constants.buildings")

local Gui = Gui
local get_building_details = Buildings.get
local Datalist = Gui.Elements.Datalist

local function update_salt_pond(container, entry, player_id)
    Gui.DetailsView.update_general(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local building_data = Gui.Elements.Tabs.get_content(tabbed_pane, "general").building

    local building_details = get_building_details(entry)
    Datalist.set_kv_pair_value(
        building_data,
        "water-tiles",
        {
            "sosciencity.value-with-unit",
            {"sosciencity.fraction", entry[EK.water_tiles], building_details.water_tiles},
            {"sosciencity.tiles"}
        }
    )
end

local function create_salt_pond(container, entry, player_id)
    local tabbed_pane = Gui.DetailsView.create_general(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "water-tiles", {"sosciencity.water"})

    update_salt_pond(container, entry)
end

Gui.DetailsView.register_type(Type.salt_pond, {creater = create_salt_pond, updater = update_salt_pond})

Gui.BuildingOverview.register_type("salt-ponds", {
    types = {Type.salt_pond},
    layout = "grid",
    stats_creator = function(flow, entry)
        Gui.BuildingOverview.generic_stats_creator(flow, entry)
        local building_details = get_building_details(entry)
        flow.add {type = "label", caption = {"sosciencity.fraction", entry[EK.water_tiles], building_details.water_tiles}}
    end
})
