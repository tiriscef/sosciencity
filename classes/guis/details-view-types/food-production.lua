--- Details view for food production buildings.

-- enums
local EK = require("enums.entry-key")
local Type = require("enums.type")

-- constants
local Biology = require("constants.biology")
local Buildings = require("constants.buildings")
local ItemConstants = require("constants.item-constants")
local Time = require("constants.time")

local Entity = Entity
local Gui = Gui
local Inventories = Inventories
local Register = Register
local get_building_details = Buildings.get
local ceil = math.ceil
local floor = math.floor
local format = string.format
local round_to_step = Tirislib.Utils.round_to_step
local display_percentage = Tirislib.Locales.display_percentage
local display_item_stack = Tirislib.Locales.display_item_stack
local Datalist = Gui.Elements.Datalist

---------------------------------------------------------------------------------------------------
-- << composter >>

local function create_composting_catalogue(container)
    local tabbed_pane = Gui.DetailsView.get_or_create_tabbed_pane(container)
    local tab = Gui.Elements.Tabs.create(tabbed_pane, "compostables", {"sosciencity.compostables"})

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
    local progress_factor = Entity.analyze_composter_inventory(Inventories.get_contents(inventory))
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

---------------------------------------------------------------------------------------------------
-- << farm >>

local function update_farm(container, entry, player_id)
    Gui.DetailsView.update_general(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local building_data = Gui.Elements.Tabs.get_content(tabbed_pane, "general").building

    local building_details = get_building_details(entry)

    Datalist.set_kv_pair_value(
        building_data,
        "orchid-bonus",
        {"sosciencity.percentage-bonus", storage.caste_bonuses[Type.orchid], {"sosciencity.productivity"}}
    )

    local flora_details = Biology.flora[entry[EK.species]]
    if flora_details then
        Datalist.set_kv_pair_visibility(building_data, "biomass", flora_details.persistent)
        local biomass = entry[EK.biomass]
        if biomass ~= nil then
            Datalist.set_kv_pair_value(
                building_data,
                "biomass",
                {"sosciencity.display-biomass", floor(biomass), Entity.biomass_to_productivity(biomass)}
            )
        end

        if
            flora_details.required_module and
                not Inventories.assembler_has_module(entry[EK.entity], flora_details.required_module)
         then
            Datalist.set_kv_pair_value(
                building_data,
                "module",
                {"sosciencity.module-missing", display_item_stack(flora_details.required_module, 1)}
            )
            Datalist.set_kv_pair_visibility(building_data, "module", true)
        else
            Datalist.set_kv_pair_visibility(building_data, "module", false)
        end
    else
        -- no recipe set
        Datalist.set_kv_pair_visibility(building_data, "biomass", false)
        Datalist.set_kv_pair_visibility(building_data, "module", false)
    end

    if building_details.accepts_plant_care then
        local humus_checkbox = Datalist.get_checkbox(building_data, "humus-mode")
        humus_checkbox.state = entry[EK.humus_mode]
        Datalist.set_kv_pair_visibility(building_data, "humus-bonus", entry[EK.humus_mode])
        if entry[EK.humus_bonus] then
            Datalist.set_kv_pair_value(
                building_data,
                "humus-bonus",
                {"sosciencity.percentage-bonus", ceil(entry[EK.humus_bonus]), {"sosciencity.speed"}}
            )
        end

        local pruning_checkbox = Datalist.get_checkbox(building_data, "pruning-mode")
        pruning_checkbox.state = entry[EK.pruning_mode]
        Datalist.set_kv_pair_visibility(building_data, "prune-bonus", entry[EK.humus_mode])
        if entry[EK.prune_bonus] then
            Datalist.set_kv_pair_value(
                building_data,
                "prune-bonus",
                {"sosciencity.percentage-bonus", ceil(entry[EK.prune_bonus]), {"sosciencity.productivity"}}
            )
        end
    end
end

local function create_farm(container, entry, player_id)
    local tabbed_pane = Gui.DetailsView.create_general(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "orchid-bonus", {"caste-short.orchid"})
    Datalist.add_kv_pair(building_data, "biomass", {"sosciencity.biomass"})

    if get_building_details(entry).accepts_plant_care then
        local humus_checkbox, _ =
            Datalist.add_kv_checkbox(
            building_data,
            "humus-mode",
            format(Gui.unique_prefix_builder, "humus-mode", "farm"),
            {"sosciencity.humus-fertilization"},
            {"sosciencity.active"}
        )
        humus_checkbox.tags = {sosciencity_gui_event = "humus_mode_checkbox"}

        Datalist.add_kv_pair(
            building_data,
            "explain-humus",
            "",
            {
                "sosciencity.explain-humus-fertilization",
                Entity.humus_fertilization_workhours * Time.minute,
                Entity.humus_fertilitation_consumption * Time.minute,
                Entity.humus_fertilization_speed
            }
        )
        Datalist.add_kv_pair(building_data, "humus-bonus")

        local pruning_checkbox, _ =
            Datalist.add_kv_checkbox(
            building_data,
            "pruning-mode",
            format(Gui.unique_prefix_builder, "pruning-mode", "farm"),
            {"sosciencity.pruning"},
            {"sosciencity.active"}
        )
        pruning_checkbox.tags = {sosciencity_gui_event = "pruning_mode_checkbox"}

        Datalist.add_kv_pair(
            building_data,
            "explain-pruning",
            "",
            {"sosciencity.explain-pruning", Entity.pruning_workhours * Time.minute, Entity.pruning_productivity}
        )
        Datalist.add_kv_pair(building_data, "prune-bonus")
    end

    Datalist.add_kv_pair(building_data, "module")

    update_farm(container, entry)
end

Gui.set_checked_state_handler(
    "humus_mode_checkbox",
    function(event)
        local entry = Register.try_get(storage.details_view[event.player_index])
        entry[EK.humus_mode] = event.element.state
    end
)

Gui.set_checked_state_handler(
    "pruning_mode_checkbox",
    function(event)
        local entry = Register.try_get(storage.details_view[event.player_index])
        entry[EK.pruning_mode] = event.element.state
    end
)

Gui.DetailsView.register_type(Type.farm, {creater = create_farm, updater = update_farm})
Gui.DetailsView.register_type(Type.automatic_farm, {creater = create_farm, updater = update_farm})

---------------------------------------------------------------------------------------------------
-- << fishing hut >>

local function update_fishery_details(container, entry, player_id)
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

    local competition_performance, near_count = Entity.get_fishing_competition(entry)
    Datalist.set_kv_pair_value(
        building_data,
        "competition",
        {"sosciencity.show-fishing-competition", near_count, display_percentage(competition_performance)}
    )
end

local function create_fishery_details(container, entry, player_id)
    local tabbed_pane = Gui.DetailsView.create_general(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "water-tiles", {"sosciencity.water"})
    Datalist.add_kv_pair(building_data, "competition", {"sosciencity.competition"})

    update_fishery_details(container, entry)
end

Gui.DetailsView.register_type(Type.fishery, {creater = create_fishery_details, updater = update_fishery_details})

---------------------------------------------------------------------------------------------------
-- << hunting hut >>

local function update_hunting_hut_details(container, entry, player_id)
    Gui.DetailsView.update_general(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local building_data = Gui.Elements.Tabs.get_content(tabbed_pane, "general").building

    local building_details = get_building_details(entry)
    Datalist.set_kv_pair_value(
        building_data,
        "tree-count",
        {"sosciencity.fraction", entry[EK.tree_count], building_details.tree_count}
    )

    local competition_performance, near_count = Entity.get_hunting_competition(entry)
    Datalist.set_kv_pair_value(
        building_data,
        "competition",
        {"sosciencity.show-hunting-competition", near_count, display_percentage(competition_performance)}
    )
end

local function create_hunting_hut_details(container, entry, player_id)
    local tabbed_pane = Gui.DetailsView.create_general(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "tree-count", {"sosciencity.tree-count"})
    Datalist.add_kv_pair(building_data, "competition", {"sosciencity.competition"})

    update_hunting_hut_details(container, entry)
end

Gui.DetailsView.register_type(Type.hunting_hut, {creater = create_hunting_hut_details, updater = update_hunting_hut_details})

---------------------------------------------------------------------------------------------------
-- << salt pond >>

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
