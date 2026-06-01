--- Details view for the dumpster.

-- enums
local EK = require("enums.entry-key")
local Type = require("enums.type")

-- constants
local Castes = require("constants.castes")
local Food = require("constants.food")
local InhabitantsConstants = require("constants.inhabitants")
local Time = require("constants.time")

local Gui = Gui
local Neighborhood = Neighborhood
local round_to_step = Tirislib.Utils.round_to_step
local display_item_stack = Tirislib.Locales.display_item_stack
local Table = Tirislib.Tables
local Luaq_from = Tirislib.Luaq.from
local Datalist = Gui.Elements.Datalist

local average_calories = Luaq_from(Food.values):select_key("calories"):call(Table.average)

local function analyse_garbage_output(entry)
    local inhabitant_count = 0
    local garbage = 0
    local calorific_demand = 0

    for _, caste in pairs(Castes.all) do
        local caste_inhabitants = 0
        for _, house in Neighborhood.iterate_type(entry, caste.type) do
            caste_inhabitants = caste_inhabitants + house[EK.inhabitants]
        end
        inhabitant_count = inhabitant_count + caste_inhabitants

        garbage = garbage + caste_inhabitants * caste.garbage_coefficient
        calorific_demand = calorific_demand + caste_inhabitants * caste.calorific_demand
    end

    return inhabitant_count, garbage, InhabitantsConstants.food_leftovers_chance * calorific_demand / average_calories
end

local function update_dumpster(container, entry, player_id)
    Gui.DetailsView.update_general(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local building_data = Gui.Elements.Tabs.get_content(tabbed_pane, "general").building

    local inhabitants, garbage, food_leftovers = analyse_garbage_output(entry)
    Datalist.set_kv_pair_value(
        building_data,
        "dependants",
        {
            "sosciencity.value-with-unit",
            inhabitants,
            {"sosciencity.inhabitants"}
        }
    )
    Datalist.set_kv_pair_value(
        building_data,
        "garbage",
        {
            "sosciencity.fraction",
            display_item_stack("garbage", round_to_step(garbage * Time.minute, 0.1)),
            {"sosciencity.minute"}
        }
    )
    Datalist.set_kv_pair_value(
        building_data,
        "food_leftovers",
        {
            "sosciencity.fraction",
            display_item_stack("food-leftovers", round_to_step(food_leftovers * Time.minute, 0.1)),
            {"sosciencity.minute"}
        }
    )
end

local function create_dumpster(container, entry, player_id)
    local tabbed_pane = Gui.DetailsView.create_general(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "dependants", {"sosciencity.dependants"})
    Datalist.add_kv_pair(building_data, "garbage", {"item-name.garbage"})
    Datalist.add_kv_pair(building_data, "food_leftovers")

    update_dumpster(container, entry)
end

Gui.DetailsView.register_type(Type.dumpster, {creater = create_dumpster, updater = update_dumpster})

Gui.BuildingOverview.register_type("dumpsters", {
    types = {Type.dumpster},
    layout = "list",
    stats_creator = Gui.BuildingOverview.generic_stats_creator
})
