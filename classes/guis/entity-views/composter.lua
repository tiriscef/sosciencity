--- Details view for the composter.

-- enums
local EK = require("enums.entry-key")
local Type = require("enums.type")

-- constants
local Buildings = require("constants.buildings")
local ItemConstants = require("constants.item-constants")
local Time = require("constants.time")

local Entity = Entity
local Gui = Gui
local Inventories = Inventories
local get_building_details = Buildings.get
local floor = math.floor
local format = string.format
local round_to_step = Tirislib.Utils.round_to_step
local Datalist = Gui.Elements.Datalist

local function create_composting_catalogue(container)
    local tabbed_pane = Gui.DetailsView.get_or_create_tabbed_pane(container)
    local tab = Gui.Elements.Tabs.create(tabbed_pane, "compostables", {"sosciencity.compostables"}, "sosciencity_details_tab")

    local composting_list = Datalist.create(tab, "compostables")
    composting_list.style.column_alignments[2] = "right"

    -- header
    Datalist.add_kv_pair(
        composting_list,
        "head",
        {"sosciencity.item"},
        {"sosciencity.humus"},
        "default-bold",
        "default-bold"
    )
    composting_list["key-head"].style.width = 220

    local item_prototypes = prototypes.item

    for item, value in pairs(ItemConstants.compost_values) do
        local item_representation = {"", format("[item=%s]  ", item), item_prototypes[item].localised_name}
        Datalist.add_operand_entry(composting_list, item, item_representation, tostring(value))
    end
end

local function update_composter_details(container, entry, player_id)
    Gui.DetailsView.update_general(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local building_data = Gui.Elements.Tabs.get_content(tabbed_pane, "general").building

    local humus = entry[EK.humus]
    Datalist.set_kv_pair_value(building_data, "humus", {"sosciencity.humus-count", round_to_step(humus / 100, 1)})

    local inventory = Inventories.get_chest_inventory(entry)
    local progress_factor = Entity.Composter.analyze_inventory(Inventories.get_contents(inventory))
    -- display the composting speed as zero when the composter is full
    if humus >= get_building_details(entry).capacity then
        progress_factor = 0
    end
    Datalist.set_kv_pair_value(
        building_data,
        "composting-speed",
        {
            "sosciencity.fraction",
            round_to_step(Time.minute * progress_factor, 0.1),
            {"sosciencity.minute"}
        }
    )
end

local function create_composter_details(container, entry, player_id)
    local tabbed_pane = Gui.DetailsView.create_general(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "humus", {"sosciencity.humus"})
    Datalist.add_kv_pair(
        building_data,
        "capacity",
        {"sosciencity.capacity"},
        {"sosciencity.show-compost-capacity", get_building_details(entry).capacity}
    )
    Datalist.add_kv_pair(building_data, "composting-speed", {"sosciencity.composting-speed"})
    Datalist.add_kv_pair(building_data, "explain-composting-speed", nil, {"sosciencity.explain-composting-speed"})

    update_composter_details(container, entry)
    create_composting_catalogue(container)
end

Gui.DetailsView.register_type(Type.composter, {creater = create_composter_details, updater = update_composter_details})

Gui.BuildingOverview.register_type("composters", {
    types = {Type.composter},
    layout = "list",
    stats_creator = Gui.BuildingOverview.generic_stats_creator
})
