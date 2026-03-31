--- Details view for miscellaneous buildings (immigration port, fertilization station,
--- pruning station, cold storage, and all generic building types).

-- enums
local EK = require("enums.entry-key")
local Type = require("enums.type")

-- constants
local Buildings = require("constants.buildings")
local Castes = require("constants.castes")
local Time = require("constants.time")
local type_definitions = require("constants.types").definitions

local castes = Castes.values
local Entity = Entity
local Gui = Gui
local Inhabitants = Inhabitants
local Locale = Locale
local get_building_details = Buildings.get
local floor = math.floor
local display_item_stack = Tirislib.Locales.display_item_stack
local display_time = Tirislib.Locales.display_time
local Datalist = Gui.Elements.Datalist

---------------------------------------------------------------------------------------------------
-- << immigration port >>

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
            {
                "",
                floor(immigrants),
                {"sosciencity.migration", Locale.migration(castes[caste].emigration_coefficient * Time.minute)}
            }
        )
        Datalist.set_kv_pair_visibility(immigrants_list, key, Inhabitants.caste_is_researched(caste))
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

---------------------------------------------------------------------------------------------------
-- << fertilization station >>

local function update_fertilization_station(container, entry, player_id)
    Gui.DetailsView.update_general(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local building_data = Gui.Elements.Tabs.get_content(tabbed_pane, "general").building

    Datalist.set_kv_pair_value(
        building_data,
        "workhours",
        {"sosciencity.display-workhours", floor(entry[EK.workhours])}
    )
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
    Datalist.add_kv_pair(building_data, "workhours", {"sosciencity.workhours"})
    Datalist.add_kv_pair(building_data, "humus-stored", {"item-name.humus"})

    Datalist.add_kv_pair(
        building_data,
        "explain-humus",
        {"sosciencity.humus-fertilization"},
        {
            "sosciencity.explain-humus-fertilization",
            Entity.humus_fertilization_workhours * Time.minute,
            Entity.humus_fertilitation_consumption * Time.minute,
            Entity.humus_fertilization_speed
        }
    )

    update_fertilization_station(container, entry, player_id)
end

Gui.DetailsView.register_type(
    Type.fertilization_station,
    {creater = create_fertilization_station, updater = update_fertilization_station}
)

---------------------------------------------------------------------------------------------------
-- << pruning station >>

local function update_pruning_station(container, entry, player_id)
    Gui.DetailsView.update_general(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local building_data = Gui.Elements.Tabs.get_content(tabbed_pane, "general").building

    Datalist.set_kv_pair_value(
        building_data,
        "workhours",
        {"sosciencity.display-workhours", floor(entry[EK.workhours])}
    )
end

local function create_pruning_station(container, entry, player_id)
    local tabbed_pane = Gui.DetailsView.create_general(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building
    Datalist.add_kv_pair(building_data, "workhours", {"sosciencity.workhours"})

    Datalist.add_kv_pair(
        building_data,
        "explain-pruning",
        {"sosciencity.pruning"},
        {"sosciencity.explain-pruning", Entity.pruning_workhours * Time.minute, Entity.pruning_productivity}
    )

    update_pruning_station(container, entry, player_id)
end

Gui.DetailsView.register_type(
    Type.pruning_station,
    {creater = create_pruning_station, updater = update_pruning_station}
)

---------------------------------------------------------------------------------------------------
-- << cold storage >>

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
