--- Details view for the fertilization station.

-- enums
local EK = require("enums.entry-key")
local Type = require("enums.type")

-- constants
local Time = require("constants.time")

local Entity = Entity
local Gui = Gui
local Fertilization = Entity.Fertilization
local floor = math.floor
local display_item_stack = Tirislib.Locales.display_item_stack
local Datalist = Gui.Elements.Datalist

local function update_fertilization_station(container, entry, player_id)
    Gui.DetailsView.update_general(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local building_data = Gui.Elements.Tabs.get_content(tabbed_pane, "general").building

    Datalist.set_kv_pair_value(
        building_data,
        "humus-stored",
        display_item_stack("humus", floor(entry[EK.humus_stored]))
    )
end

local function create_fertilization_station(container, entry, player_id)
    local tabbed_pane = Gui.DetailsView.create_general(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building
    Datalist.add_kv_pair(building_data, "humus-stored", {"item-name.humus"})

    Datalist.add_kv_pair(
        building_data,
        "explain-humus",
        {"sosciencity.humus-fertilization"},
        {
            "sosciencity.explain-humus-fertilization",
            Fertilization.workhours * Time.minute,
            Fertilization.consumption * Time.minute,
            Fertilization.speed_bonus
        }
    )

    update_fertilization_station(container, entry, player_id)
end

Gui.DetailsView.register_type(
    Type.fertilization_station,
    {creater = create_fertilization_station, updater = update_fertilization_station}
)

Gui.BuildingOverview.register_type("fertilization-stations", {
    types = {Type.fertilization_station},
    layout = "list",
    stats_creator = Gui.BuildingOverview.generic_stats_creator
})
