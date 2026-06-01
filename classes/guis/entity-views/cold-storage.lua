--- Details view for cold storage.

-- enums
local Type = require("enums.type")

-- constants
local Buildings = require("constants.buildings")

local Gui = Gui
local get_building_details = Buildings.get
local Datalist = Gui.Elements.Datalist

local function create_cold_storage(container, entry, player_id)
    local tabbed_pane = Gui.DetailsView.create_general(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    local definition = get_building_details(entry)
    Datalist.add_kv_pair(
        building_data,
        "spoil-slowdown",
        {"sosciencity.spoil-slowdown"},
        Tirislib.Locales.display_percentage(definition.spoil_slowdown)
    )

    Gui.DetailsView.update_general(container, entry, player_id)
end

Gui.DetailsView.register_type(
    Type.cold_storage,
    {creater = create_cold_storage, updater = Gui.DetailsView.update_general}
)
