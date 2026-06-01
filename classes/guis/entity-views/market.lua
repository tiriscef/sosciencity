--- Details view for the market.

-- enums
local EK = require("enums.entry-key")
local Type = require("enums.type")

-- constants
local Castes = require("constants.castes")
local Time = require("constants.time")

local Gui = Gui
local Inventories = Inventories
local Neighborhood = Neighborhood
local floor = math.floor
local round = Tirislib.Utils.round
local display_time = Tirislib.Locales.display_time
local Datalist = Gui.Elements.Datalist

local function analyse_dependants(entry, consumption_key)
    local inhabitant_count = 0
    local consumption = 0

    for _, caste in pairs(Castes.all) do
        local caste_inhabitants = 0
        for _, house in Neighborhood.iterate_type(entry, caste.type) do
            caste_inhabitants = caste_inhabitants + house[EK.inhabitants]
        end

        inhabitant_count = inhabitant_count + caste_inhabitants
        consumption = consumption + caste_inhabitants * caste[consumption_key]
    end

    return inhabitant_count, consumption
end

local function update_market(container, entry, player_id)
    Gui.DetailsView.update_general(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local building_data = Gui.Elements.Tabs.get_content(tabbed_pane, "general").building

    local amount = Consumption.count_calories(Inventories.get_chest_inventory(entry))

    Datalist.set_kv_pair_value(
        building_data,
        "content",
        {"sosciencity.value-with-unit", round(amount), {"sosciencity.kcal"}}
    )

    local inhabitants, consumption = analyse_dependants(entry, "calorific_demand")
    Datalist.set_kv_pair_value(
        building_data,
        "dependants",
        {
            "sosciencity.display-dependants",
            inhabitants
        }
    )
    Datalist.set_kv_pair_value(
        building_data,
        "dependants-demand",
        {"sosciencity.show-calorific-demand", round(consumption * Time.minute)}
    )

    if consumption > 0 then
        Datalist.set_kv_pair_value(
            building_data,
            "supply",
            {"sosciencity.display-supply", display_time(floor(amount / consumption))}
        )
    else
        Datalist.set_kv_pair_value(building_data, "supply", "-")
    end
end

local function create_market(container, entry, player_id)
    local tabbed_pane = Gui.DetailsView.create_general(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "content", {"sosciencity.content"})
    Datalist.add_kv_pair(building_data, "dependants", {"sosciencity.dependants"})
    Datalist.add_kv_pair(building_data, "dependants-demand")
    Datalist.add_kv_pair(building_data, "supply", {"sosciencity.supply"})

    update_market(container, entry)
end

Gui.DetailsView.register_type(Type.market, {creater = create_market, updater = update_market})

Gui.BuildingOverview.register_type("markets", {
    types = {Type.market},
    layout = "list",
    stats_creator = function(flow, entry)
        local kcal = round(Consumption.count_calories(Inventories.get_chest_inventory(entry)))
        flow.add {
            type = "label",
            caption = {"sosciencity.value-with-unit", kcal, {"sosciencity.kcal"}}
        }
    end
})
