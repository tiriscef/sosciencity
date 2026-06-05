--- Details view for the immigration port.

-- enums
local EK = require("enums.entry-key")
local Type = require("enums.type")

-- constants
local Buildings = require("constants.buildings")
local type_definitions = require("constants.types").definitions

local Gui = Gui
local Locale = Locale
local get_building_details = Buildings.get
local floor = math.floor
local display_time = Tirislib.Locales.display_time
local Datalist = Gui.Elements.Datalist

local function update_immigration_port_details(container, entry, player_id)
    Gui.DetailsView.update_general(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    local ticks_to_next_wave = entry[EK.next_wave] - game.tick
    Datalist.set_kv_pair_value(building_data, "next-wave", display_time(ticks_to_next_wave))

    local immigrants_list = general.immigration
    for caste, immigrants in pairs(storage.immigration) do
        local key = tostring(caste)
        Datalist.set_kv_pair_value(
            immigrants_list,
            key,
            floor(immigrants)
        )
        Datalist.set_kv_pair_visibility(immigrants_list, key, Technologies.caste_is_researched(caste))
    end
end

local function create_immigration_port_details(container, entry, player_id)
    local tabbed_pane = Gui.DetailsView.create_general(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building
    local building_details = get_building_details(entry)

    Datalist.add_kv_pair(building_data, "next-wave", {"sosciencity.next-wave"})
    Datalist.add_kv_pair(
        building_data,
        "materials",
        {"sosciencity.materials"},
        Locale.materials(building_details.materials)
    )
    Datalist.add_kv_pair(
        building_data,
        "capacity",
        {"sosciencity.capacity"},
        {"sosciencity.show-port-capacity", building_details.capacity}
    )

    Gui.Elements.Utils.separator_line(general)

    Gui.Elements.Label.header_label(general, "header-immigration", {"sosciencity.estimated-immigrants"})
    local immigrants_list = Datalist.create(general, "immigration")

    for caste in pairs(storage.immigration) do
        Datalist.add_kv_pair(immigrants_list, tostring(caste), type_definitions[caste].localised_name)
    end

    update_immigration_port_details(container, entry)
end

Gui.DetailsView.register_type(
    Type.immigration_port,
    {creater = create_immigration_port_details, updater = update_immigration_port_details, always_update = true}
)

Gui.BuildingOverview.register_type("immigration-ports", {
    types = {Type.immigration_port},
    layout = "grid",
    stats_creator = function(flow, entry)
        Gui.BuildingOverview.generic_stats_creator(flow, entry)
        local ticks_to_next = math.max(0, entry[EK.next_wave] - game.tick)
        flow.add {type = "label", caption = display_time(ticks_to_next)}
    end
})
