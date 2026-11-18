--- Details view for cold storage.

-- enums
local Type = require("enums.type")

-- constants
local Buildings = require("constants.buildings")

local DetailsView = require("classes.guis.details-view")
local Elements = require("classes.guis.elements")

local get_building_details = Buildings.get
local Datalist = Elements.Datalist

local function create_cold_storage(container, entry, player_id)
    local tabbed_pane = DetailsView.create_general(container, entry, player_id)

    local general = Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    local definition = get_building_details(entry)
    Datalist.add_kv_pair(
        building_data,
        "spoil-slowdown",
        {"sosciencity.spoil-slowdown"},
        Tirislib.Locales.display_percentage(definition.spoil_slowdown)
    )

    DetailsView.update_general(container, entry, player_id)
end

DetailsView.register_type(
    Type.cold_storage,
    {creater = create_cold_storage, updater = DetailsView.update_general}
)
