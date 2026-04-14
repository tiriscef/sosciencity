--- Details view for supply buildings (market, water distributer, waterwell, kitchen for all).

-- enums
local EK = require("enums.entry-key")
local Type = require("enums.type")

-- constants
local Castes = require("constants.castes")
local DrinkingWater = require("constants.drinking-water")
local Time = require("constants.time")

local Gui = Gui
local Inventories = Inventories
local Neighborhood = Neighborhood
local Locale = Locale
local floor = math.floor
local round = Tirislib.Utils.round
local round_to_step = Tirislib.Utils.round_to_step
local display_fluid_stack = Tirislib.Locales.display_fluid_stack
local display_item_stack = Tirislib.Locales.display_item_stack
local display_time = Tirislib.Locales.display_time
local Datalist = Gui.Elements.Datalist

---------------------------------------------------------------------------------------------------
-- << water well >>

local function update_waterwell_details(container, entry, player_id)
    Gui.DetailsView.update_general(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local building_data = Gui.Elements.Tabs.get_content(tabbed_pane, "general").building

    Datalist.set_kv_pair_visibility(building_data, "module", not entry[EK.active])
end

local function create_waterwell_details(container, entry, player_id)
    local tabbed_pane = Gui.DetailsView.create_general(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(
        building_data,
        "module",
        nil,
        {"sosciencity.module-missing", display_item_stack("water-filter", 1)}
    )

    update_waterwell_details(container, entry)
end

Gui.DetailsView.register_type(Type.waterwell, {creater = create_waterwell_details, updater = update_waterwell_details})

---------------------------------------------------------------------------------------------------
-- << market >>

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

    local amount = Inventories.count_calories(Inventories.get_chest_inventory(entry))

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

---------------------------------------------------------------------------------------------------
-- << water distributer >>

local function create_water_catalogue(container)
    local tabbed_pane = Gui.DetailsView.get_or_create_tabbed_pane(container)
    local tab = Gui.Elements.Tabs.create(tabbed_pane, "waters", {"sosciencity.drinking-water"})

    local data_list = Datalist.create(tab, "waters", 2)
    data_list.style.column_alignments[2] = "right"

    -- header
    Datalist.add_kv_pair(
        data_list,
        "head",
        {"sosciencity.drinking-water"},
        {"sosciencity.health"},
        "default-bold",
        "default-bold"
    )
    data_list["key-head"].style.width = 220

    local fluid_prototypes = prototypes.fluid

    for water, data in pairs(DrinkingWater.values) do
        local water_representation = {"", string.format("[fluid=%s]  ", water), fluid_prototypes[water].localised_name}
        Datalist.add_operand_entry(data_list, water, water_representation, Locale.integer_summand(data.healthiness))
    end
end

local function update_water_distributer(container, entry, player_id)
    Gui.DetailsView.update_general(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local building_data = Gui.Elements.Tabs.get_content(tabbed_pane, "general").building

    local water = entry[EK.water_name]
    local amount

    if water then
        amount = entry[EK.entity].get_fluid_count(water)
        Datalist.set_kv_pair_value(building_data, "content", display_fluid_stack(water, floor(amount)))
    else
        amount = 0
        Datalist.set_kv_pair_value(building_data, "content", "-")
    end

    local inhabitants, consumption = analyse_dependants(entry, "water_demand")
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
        {"sosciencity.show-water-demand", round_to_step(consumption * Time.minute, 0.1)}
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

local function create_water_distributer(container, entry, player_id)
    local tabbed_pane = Gui.DetailsView.create_general(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "content", {"sosciencity.content"})
    Datalist.add_kv_pair(building_data, "dependants", {"sosciencity.dependants"})
    Datalist.add_kv_pair(building_data, "dependants-demand")
    Datalist.add_kv_pair(building_data, "supply", {"sosciencity.supply"})

    update_water_distributer(container, entry)

    create_water_catalogue(container)
end

Gui.DetailsView.register_type(
    Type.water_distributer,
    {creater = create_water_distributer, updater = update_water_distributer}
)

---------------------------------------------------------------------------------------------------
-- << kitchen for all >>

local function update_kitchen_for_all(container, entry, player_id)
    Gui.DetailsView.update_general(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local building_data = Gui.Elements.Tabs.get_content(tabbed_pane, "general").building

    Datalist.set_kv_pair_value(building_data, "inhabitants", entry[EK.participating_inhabitants])
end

local function create_kitchen_for_all(container, entry, player_id)
    local tabbed_pane = Gui.DetailsView.create_general(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "inhabitants", {"sosciencity.inhabitants"})

    update_kitchen_for_all(container, entry, player_id)
end

Gui.DetailsView.register_type(Type.kitchen_for_all, {creater = create_kitchen_for_all, updater = update_kitchen_for_all})
