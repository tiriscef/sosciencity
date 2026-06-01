--- Details view for the pruning station.

-- enums
local EK = require("enums.entry-key")
local Type = require("enums.type")

-- constants
local Buildings = require("constants.buildings")

local Entity = Entity
local Gui = Gui
local Pruning = Entity.Pruning
local Register = Register
local get_building_details = Buildings.get
local floor = math.floor
local Datalist = Gui.Elements.Datalist

local function update_pruning_slots(general, entry)
    local slots_list = general.pruning_slots
    slots_list.clear()

    local slots = entry[EK.slots]
    for i, target_uid in pairs(slots) do
        local farm = Register.try_get(target_uid)
        if farm then
            local farm_entity = farm[EK.entity]
            local pos = farm_entity.position
            slots_list.add {
                type = "label",
                name = "farm-" .. i,
                caption = {"sosciencity.slot-farm", farm_entity.localised_name, floor(pos.x), floor(pos.y)}
            }
        end
    end
end

local function update_pruning_station(container, entry, player_id)
    Gui.DetailsView.update_general(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    local building_details = get_building_details(entry)
    local max_slots = building_details.slots
    local performance = entry[EK.performance] or 0
    local effective_slots = Pruning.effective_slots(performance, max_slots)
    Datalist.set_kv_pair_value(
        building_data,
        "capacity",
        {"sosciencity.show-slots-capped", #entry[EK.slots], effective_slots, max_slots}
    )

    update_pruning_slots(general, entry)
end

local function create_pruning_station(container, entry, player_id)
    local tabbed_pane = Gui.DetailsView.create_general(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "capacity", {"sosciencity.capacity"})
    Datalist.set_kv_pair_tooltip(building_data, "capacity", {"sosciencity.show-slots-capped-tooltip"})

    Datalist.add_kv_pair(
        building_data,
        "explain-pruning",
        {"sosciencity.pruning"},
        {"sosciencity.explain-pruning", Pruning.productivity}
    )

    Gui.Elements.Label.header_label(general, "header-pruning-slots", {"sosciencity.pruned-farms"})
    Datalist.create(general, "pruning_slots", 1)

    update_pruning_station(container, entry, player_id)
end

Gui.DetailsView.register_type(
    Type.pruning_station,
    {creater = create_pruning_station, updater = update_pruning_station}
)

Gui.BuildingOverview.register_type("pruning-stations", {
    types = {Type.pruning_station},
    layout = "list",
    stats_creator = Gui.BuildingOverview.generic_stats_creator
})
