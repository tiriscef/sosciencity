--- Details view for the farm.

-- enums
local EK = require("enums.entry-key")
local Type = require("enums.type")

-- constants
local Biology = require("constants.biology")
local Buildings = require("constants.buildings")
local Time = require("constants.time")

local Entity = Entity
local Gui = Gui
local Inventories = Inventories
local Register = Register
local Farm = Entity.Farm
local Fertilization = Entity.Fertilization
local Pruning = Entity.Pruning
local get_building_details = Buildings.get
local floor = math.floor
local format = string.format
local display_item_stack = Tirislib.Locales.display_item_stack
local Datalist = Gui.Elements.Datalist

local function update_farm(container, entry, player_id)
    Gui.DetailsView.update_general(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local building_data = Gui.Elements.Tabs.get_content(tabbed_pane, "general").building

    local building_details = get_building_details(entry)

    local flora_details = Biology.flora[entry[EK.species]]
    if flora_details then
        Datalist.set_kv_pair_visibility(building_data, "biomass", flora_details.persistent)
        local biomass = entry[EK.biomass]
        if biomass ~= nil then
            Datalist.set_kv_pair_value(
                building_data,
                "biomass",
                {"sosciencity.display-biomass", floor(biomass), Farm.biomass_to_productivity(biomass)}
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

        local pruning_checkbox = Datalist.get_checkbox(building_data, "pruning-mode")
        pruning_checkbox.state = entry[EK.pruning_mode]
    end
end

local function create_farm(container, entry, player_id)
    local tabbed_pane = Gui.DetailsView.create_general(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

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
                Fertilization.workhours * Time.minute,
                Fertilization.consumption * Time.minute,
                Fertilization.speed_bonus
            }
        )

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
            {"sosciencity.explain-pruning", Pruning.productivity}
        )
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

Gui.BuildingOverview.register_type("farms", {
    types = {Type.farm},
    layout = "grid",
    stats_creator = function(flow, entry)
        Gui.BuildingOverview.generic_stats_creator(flow, entry)
        local recipe = entry[EK.entity].get_recipe()
        if recipe then
            flow.add {type = "label", caption = recipe.localised_name}
        end
    end
})
