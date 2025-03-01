--- The gui that pops up when the player opens a entity.
Gui.DetailsView = {}

local DETAILS_VIEW_NAME = "sosciencity-details"

-- enums

local DiseaseCategory = require("enums.disease-category")
local EK = require("enums.entry-key")
local Type = require("enums.type")
local WasteDumpOperationMode = require("enums.waste-dump-operation-mode")

local HappinessSummand = require("enums.happiness-summand")
local HappinessFactor = require("enums.happiness-factor")
local HealthSummand = require("enums.health-summand")
local HealthFactor = require("enums.health-factor")
local SanitySummand = require("enums.sanity-summand")
local SanityFactor = require("enums.sanity-factor")

-- constants

local Biology = require("constants.biology")
local Buildings = require("constants.buildings")
local Castes = require("constants.castes")
local Color = require("constants.color")
local Diseases = require("constants.diseases")
local DrinkingWater = require("constants.drinking-water")
local Food = require("constants.food")
local Housing = require("constants.housing")
local ItemConstants = require("constants.item-constants")
local Time = require("constants.time")
local TypeGroup = require("constants.type-groups")
local Types = require("constants.types")
local WeatherLocales = require("constants.weather-locales")

-- local often used globals for microscopic performance gains

local castes = Castes.values
local diseases = Diseases.values
local Entity = Entity
local Gui = Gui
local Locale = Locale
local Register = Register
local Inhabitants = Inhabitants
local get_building_details = Buildings.get
local type_definitions = Types.definitions

local ceil = math.ceil
local floor = math.floor
local format = string.format
local round = Tirislib.Utils.round
local round_to_step = Tirislib.Utils.round_to_step
local tostring = tostring

local Luaq_from = Tirislib.Luaq.from

local display_enumeration = Tirislib.Locales.create_enumeration
local display_fluid_stack = Tirislib.Locales.display_fluid_stack
local display_percentage = Tirislib.Locales.display_percentage
local display_item_stack = Tirislib.Locales.display_item_stack
local display_time = Tirislib.Locales.display_time

local Table = Tirislib.Tables

local climate_locales = WeatherLocales.climate
local humidity_locales = WeatherLocales.humidity

local Datalist = Gui.Elements.Datalist

local function set_details_view_title(container, caption)
    container.parent.caption = caption
end

local function get_or_create_tabbed_pane(container) -- TODO this doesn't belong to this file
    local tabpane = container.tabpane
    if container.tabpane then
        return tabpane
    else
        return container.add {
            type = "tabbed-pane",
            name = "tabpane"
        }
    end
end

local function generic_radiobutton_handler(entry, element, _, mode, key, updater)
    if mode then
        entry[key] = mode
        updater(entry, element.parent)
    end
end

local function generic_checkbox_handler(entry, element, _, ...)
    local keys = {...}
    local subtable = entry

    for i = 1, #keys - 1 do
        subtable = subtable[keys[i]]
    end
    subtable[keys[#keys]] = element.state
end

local function generic_slider_handler(entry, element, _, key)
    entry[key] = element.slider_value
end

local function generic_numeric_textfield_handler(entry, element, _, key)
    entry[key] = tonumber(element.text)
end

---------------------------------------------------------------------------------------------------
-- << empty houses >>

local function add_caste_chooser_tab(tabbed_pane, house_details)
    local flow = Gui.Elements.Tabs.create(tabbed_pane, "caste-chooser", {"sosciencity.caste"})

    flow.style.horizontal_align = "center"
    flow.style.vertical_align = "center"
    flow.style.vertical_spacing = 6

    local at_least_one = false
    for caste_id, caste in pairs(castes) do
        if Inhabitants.caste_is_researched(caste_id) then
            local caste_name = caste.name

            local button =
                flow.add {
                type = "button",
                name = format(Gui.unique_prefix_builder, "assign-caste", caste_name),
                caption = {"caste-name." .. caste_name},
                mouse_button_filter = {"left"}
            }
            button.style.width = 150

            if Housing.allowes_caste(house_details, caste_id) then
                button.tooltip = {
                    "sosciencity.move-in",
                    Locale.integer_summand(
                        Inhabitants.evaluate_housing_qualities(house_details, caste) + house_details.comfort
                    )
                }
            elseif castes[caste_id].required_room_count > house_details.room_count then
                button.tooltip = {"sosciencity.not-enough-room"}
            else
                button.tooltip = {"sosciencity.not-enough-comfort"}
            end
            button.enabled = Housing.allowes_caste(house_details, caste_id)
            at_least_one = true
        end
    end

    if not at_least_one then
        flow.add {
            type = "label",
            name = "no-castes-researched-label",
            caption = {"sosciencity.no-castes-researched"}
        }
    end
end

-- Event handler function for clicks on the caste assign buttons.
local function caste_assignment_button_handler(entry, _, _, caste_id)
    Inhabitants.try_allow_for_caste(entry, caste_id, true)
end

for id, caste in pairs(castes) do
    Gui.set_click_handler(
        format(Gui.unique_prefix_builder, "assign-caste", caste.name),
        caste_assignment_button_handler,
        id
    )
end

local function add_empty_house_info_tab(tabbed_pane, house_details)
    local flow = Gui.Elements.Tabs.create(tabbed_pane, "house-info", {"sosciencity.building-info"})

    local data_list = Datalist.create(flow, "house-infos")
    Datalist.add_kv_pair(data_list, "room_count", {"sosciencity.room-count"}, house_details.room_count)
    Datalist.add_kv_pair(data_list, "comfort", {"sosciencity.comfort"}, Locale.comfort(house_details.comfort))

    local qualities_flow = Datalist.add_kv_flow(data_list, "qualities", {"sosciencity.qualities"})
    for _, quality in pairs(house_details.qualities) do
        qualities_flow.add {
            type = "label",
            name = quality,
            caption = {"housing-quality." .. quality},
            tooltip = {"housing-quality-description." .. quality}
        }
    end
end

local function create_empty_housing_details(container, entry)
    set_details_view_title(container, entry[EK.entity].localised_name)

    local tabbed_pane = get_or_create_tabbed_pane(container)

    local house_details = Housing.get(entry)
    add_caste_chooser_tab(tabbed_pane, house_details)
    add_empty_house_info_tab(tabbed_pane, house_details)
end

---------------------------------------------------------------------------------------------------
-- << occupied housing >>

local function update_occupations_list(flow, entry)
    local occupations_list = flow.occupations

    occupations_list.clear()

    Datalist.add_operand_entry(
        occupations_list,
        "unoccupied",
        {"sosciencity.unemployed"},
        Inhabitants.get_employable_count(entry)
    )
    Datalist.set_kv_pair_tooltip(occupations_list, "unoccupied", {"sosciencity.explain-unemployed"})

    local employments = entry[EK.employments]
    for building_number, count in pairs(employments) do
        local building = Register.try_get(building_number)
        if building then
            Datalist.add_operand_entry(
                occupations_list,
                building_number,
                {"sosciencity.employed", Locale.entry(building)},
                count
            )
        end
    end

    local disease_group = entry[EK.diseases]
    for disease_id, count in pairs(disease_group) do
        if disease_id ~= DiseaseGroup.HEALTHY then
            local disease = diseases[disease_id]
            local key = format("disease-%d", disease_id)
            Datalist.add_operand_entry(occupations_list, key, {"sosciencity.ill", disease.localised_name}, count)
            Datalist.set_kv_pair_tooltip(occupations_list, key, disease.localised_description)
        end
    end

    local visible = (entry[EK.inhabitants] > 0)
    occupations_list.visible = visible
    flow["header-occupations"].visible = visible
end

local function update_ages_list(flow, entry)
    local ages_list = flow.ages

    ages_list.clear()
    for age, count in pairs(entry[EK.ages]) do
        Datalist.add_operand_entry(ages_list, age, {"sosciencity.show-age", age}, count)
    end

    local visible = (entry[EK.inhabitants] > 0)
    ages_list.visible = visible
    flow["header-ages"].visible = visible
end

local function update_genders_list(flow, entry)
    local genders_list = flow.genders

    genders_list.clear()
    for gender, count in pairs(entry[EK.genders]) do
        Datalist.add_operand_entry(genders_list, gender, {"sosciencity.gender-" .. gender}, count)
    end

    local visible = (entry[EK.inhabitants] > 0)
    genders_list.visible = visible
    flow["header-genders"].visible = visible
end

local function update_housing_general_info_tab(tabbed_pane, entry)
    local flow = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local general_list = flow["general-infos"]

    local caste = castes[entry[EK.type]]
    local inhabitants = entry[EK.inhabitants]
    local nominal_happiness = Inhabitants.get_nominal_happiness(entry)

    local capacity = Housing.get_capacity(entry)
    local emigration = Inhabitants.get_emigration_trend(nominal_happiness, caste, Time.minute)
    local display_emigration = inhabitants > 0 and emigration > 0

    Datalist.set_kv_pair_value(
        general_list,
        "inhabitants",
        {
            "",
            {"sosciencity.show-inhabitants", inhabitants, capacity},
            display_emigration and {"sosciencity.migration", Locale.migration(-emigration)} or ""
        }
    )
    Datalist.set_datalist_value_tooltip(
        general_list,
        "inhabitants",
        (entry[EK.emigration_trend] > 0) and {"sosciencity.negative-trend"} or ""
    )

    -- the annoying edge case of no inhabitants inside the house
    if inhabitants == 0 then
        Datalist.set_kv_pair_value(general_list, "happiness", "-")
        Datalist.set_kv_pair_value(general_list, "health", "-")
        Datalist.set_kv_pair_value(general_list, "sanity", "-")
        Datalist.set_kv_pair_value(general_list, "calorific-demand", "-")
        Datalist.set_kv_pair_value(general_list, "water-demand", "-")
        Datalist.set_kv_pair_value(general_list, "power-demand", "-")
        Datalist.set_kv_pair_value(general_list, "garbage", "-")
        Datalist.set_kv_pair_value(general_list, "bonus", "-")
        Datalist.set_kv_pair_value(general_list, "employed-count", "-")
        Datalist.set_kv_pair_value(general_list, "diseased-count", "-")
        Datalist.set_kv_pair_visibility(general_list, "disease-rate", false)
        return
    end

    Datalist.set_kv_pair_value(
        general_list,
        "happiness",
        Locale.convergence(entry[EK.happiness], Inhabitants.get_nominal_happiness(entry))
    )
    Datalist.set_kv_pair_value(
        general_list,
        "health",
        Locale.convergence(entry[EK.health], Inhabitants.get_nominal_health(entry))
    )
    Datalist.set_kv_pair_value(
        general_list,
        "sanity",
        Locale.convergence(entry[EK.sanity], Inhabitants.get_nominal_sanity(entry))
    )
    Datalist.set_kv_pair_value(
        general_list,
        "calorific-demand",
        {
            "sosciencity.show-calorific-demand",
            floor(caste.calorific_demand * Time.minute * inhabitants)
        }
    )
    Datalist.set_kv_pair_value(
        general_list,
        "water-demand",
        {"sosciencity.show-water-demand", floor(caste.water_demand * Time.minute * inhabitants)}
    )
    Datalist.set_kv_pair_value(
        general_list,
        "power-demand",
        {"sosciencity.current-power-demand", floor(caste.power_demand / 1000 * Time.second * inhabitants)}
    )
    Datalist.set_kv_pair_value(
        general_list,
        "garbage",
        {
            "sosciencity.fraction",
            display_item_stack("garbage", Inhabitants.get_garbage_progress(entry, Time.minute)),
            {"sosciencity.minute"}
        }
    )

    -- occupations
    local unemployed = Inhabitants.get_employable_count(entry)
    Datalist.set_kv_pair_value(
        general_list,
        "bonus",
        {
            "sosciencity.show-bonus",
            round_to_step(entry[EK.caste_points], 0.1)
        }
    )
    local employed = entry[EK.employed]
    local diseased = inhabitants - unemployed - employed
    Datalist.set_kv_pair_value(general_list, "employed-count", {"sosciencity.show-employed-count", employed})
    Datalist.set_kv_pair_value(general_list, "diseased-count", {"sosciencity.show-diseased-count", diseased})

    Datalist.set_kv_pair_visibility(general_list, "disease-rate", true)
    local disease_progress_flow = Datalist.get_kv_value_element(general_list, "disease-rate")
    for category_name, category_id in pairs(DiseaseCategory) do
        local updater = Inhabitants.disease_progress_updaters[category_id]
        if updater then
            local progress_per_tick = updater(entry, 1)
            local ticks_till_disease = ceil(1 / progress_per_tick)
            local label = disease_progress_flow[tostring(category_id)]
            label.caption = {
                "sosciencity.show-disease-rate",
                display_time(ticks_till_disease),
                {"disease-category-name." .. category_name}
            }
            label.visible = (progress_per_tick > 0)
        end
    end
end

local function add_housing_general_info_tab(tabbed_pane, entry, caste_id)
    local flow = Gui.Elements.Tabs.create(tabbed_pane, "general", {"sosciencity.general"})

    flow.style.vertical_spacing = 6
    flow.style.horizontal_align = "right"

    local general_list = Datalist.create(flow, "general-infos")
    Datalist.add_kv_pair(general_list, "caste", {"sosciencity.caste"}, Locale.caste(entry[EK.type]))

    Datalist.add_kv_pair(general_list, "inhabitants", {"sosciencity.inhabitants"})
    Datalist.add_kv_pair(general_list, "happiness", {"sosciencity.happiness"})
    Datalist.add_kv_pair(general_list, "health", {"sosciencity.health"})
    Datalist.add_kv_pair(general_list, "sanity", {"sosciencity.sanity"})
    Datalist.add_kv_pair(general_list, "calorific-demand", {"sosciencity.calorific-demand"})
    Datalist.add_kv_pair(general_list, "water-demand", {"sosciencity.water"})
    Datalist.add_kv_pair(general_list, "power-demand", {"sosciencity.power-demand"})
    Datalist.add_kv_pair(general_list, "garbage", {"sosciencity.garbage"})
    Datalist.add_kv_pair(general_list, "bonus", {"sosciencity.bonus"})
    Datalist.set_datalist_value_tooltip(general_list, "bonus", {"sosciencity.tooltip-bonus"})
    Datalist.add_kv_pair(general_list, "employed-count", {"sosciencity.employed-count"})
    Datalist.add_kv_pair(general_list, "diseased-count", {"sosciencity.diseased-count"})

    local disease_progress_flow = Datalist.add_kv_flow(general_list, "disease-rate")
    for category in pairs(Inhabitants.disease_progress_updaters) do
        local label =
            disease_progress_flow.add {
            type = "label",
            name = tostring(category)
        }
        label.style.single_line = false
    end

    local caste = castes[caste_id]
    local housing_details = Housing.get(entry)

    local qualities_flow = Datalist.add_kv_flow(general_list, "qualities", {"sosciencity.qualities"})
    for _, quality in pairs(housing_details.qualities) do
        local assessment = caste.housing_preferences[quality]

        local caption =
            assessment and {"", {"housing-quality." .. quality}, format(" (%+.1f)", assessment)} or
            {"housing-quality." .. quality}

        local quality_text =
            qualities_flow.add {
            type = "label",
            name = quality,
            caption = caption,
            tooltip = {"housing-quality-description." .. quality}
        }

        if assessment then
            quality_text.style.font_color = assessment > 0 and Color.green or Color.red
        end
    end

    Gui.Elements.Utils.separator_line(flow)

    -- the kickout_button only gets added if the house is built by the player
    -- this also avoids that the player can repurpose the hut
    if not housing_details.is_improvised then
        local kickout_button =
            flow.add {
            type = "button",
            name = format(Gui.unique_prefix_builder, "kickout", ""),
            caption = {"sosciencity.kickout"},
            tooltip = {"sosciencity.with-resettlement"},
            mouse_button_filter = {"left"}
        }
        kickout_button.style.right_margin = 4
    end

    -- call the update function to set the values
    update_housing_general_info_tab(tabbed_pane, entry)
end

-- Event handler function for clicks on the kickout button.
Gui.set_click_handler(
    format(Gui.unique_prefix_builder, "kickout", ""),
    function(entry, button)
        if Gui.Elements.Utils.is_confirmed(button) then
            Register.change_type(entry, Type.empty_house)
            return
        end
    end
)

local function update_housing_detailed_info_tab(tabbed_pane, entry)
    local flow = Gui.Elements.Tabs.get_content(tabbed_pane, "details")

    local happiness_list = flow["happiness"]
    Datalist.update_operand_entries(
        happiness_list,
        Inhabitants.get_nominal_happiness(entry),
        entry[EK.happiness_summands],
        HappinessSummand,
        entry[EK.happiness_factors],
        HappinessFactor
    )

    local health_list = flow["health"]
    Datalist.update_operand_entries(
        health_list,
        Inhabitants.get_nominal_health(entry),
        entry[EK.health_summands],
        HealthSummand,
        entry[EK.health_factors],
        HealthFactor
    )

    local sanity_list = flow["sanity"]
    Datalist.update_operand_entries(
        sanity_list,
        Inhabitants.get_nominal_sanity(entry),
        entry[EK.sanity_summands],
        SanitySummand,
        entry[EK.sanity_factors],
        SanityFactor
    )

    update_occupations_list(flow, entry)
    update_ages_list(flow, entry)
    update_genders_list(flow, entry)
end

local function build_localised(enum_table, format_string)
    local ret = {}

    for name, id in pairs(enum_table) do
        ret[id] = {format(format_string, name)}
    end

    return ret
end

local localised_happiness_summands = build_localised(HappinessSummand, "happiness-summand.%s")
local localised_happiness_summand_descriptions = build_localised(HappinessSummand, "happiness-summand-description.%s")
local localised_happiness_factors = build_localised(HappinessFactor, "happiness-factor.%s")
local localised_happiness_factor_descriptions = build_localised(HappinessFactor, "happiness-factor-description.%s")
local localised_health_summands = build_localised(HealthSummand, "health-summand.%s")
local localised_health_summand_descriptions = build_localised(HealthSummand, "health-summand-description.%s")
local localised_health_factors = build_localised(HealthFactor, "health-factor.%s")
local localised_health_factor_descriptions = build_localised(HealthFactor, "health-factor-description.%s")
local localised_sanity_summands = build_localised(SanitySummand, "sanity-summand.%s")
local localised_sanity_summand_descriptions = build_localised(SanitySummand, "sanity-summand-description.%s")
local localised_sanity_factors = build_localised(SanityFactor, "sanity-factor.%s")
local localised_sanity_factor_descriptions = build_localised(SanityFactor, "sanity-factor-description.%s")

build_localised = nil

local function add_housing_detailed_info_tab(tabbed_pane, entry)
    local flow = Gui.Elements.Tabs.create(tabbed_pane, "details", {"sosciencity.details"})

    local happiness_list = Datalist.create(flow, "happiness")
    Datalist.create_operand_entries(
        happiness_list,
        {"sosciencity.happiness"},
        HappinessSummand,
        localised_happiness_summands,
        localised_happiness_summand_descriptions,
        HappinessFactor,
        localised_happiness_factors,
        localised_happiness_factor_descriptions
    )

    Gui.Elements.Utils.separator_line(flow)

    local health_list = Datalist.create(flow, "health")
    Datalist.create_operand_entries(
        health_list,
        {"sosciencity.health"},
        HealthSummand,
        localised_health_summands,
        localised_health_summand_descriptions,
        HealthFactor,
        localised_health_factors,
        localised_health_factor_descriptions
    )

    Gui.Elements.Utils.separator_line(flow)

    local sanity_list = Datalist.create(flow, "sanity")
    Datalist.create_operand_entries(
        sanity_list,
        {"sosciencity.sanity"},
        SanitySummand,
        localised_sanity_summands,
        localised_sanity_summand_descriptions,
        SanityFactor,
        localised_sanity_factors,
        localised_sanity_factor_descriptions
    )

    Gui.Elements.Utils.separator_line(flow)

    Gui.Elements.Label.header_label(flow, "header-occupations", {"sosciencity.occupations"})
    Datalist.create(flow, "occupations")

    Gui.Elements.Utils.separator_line(flow)

    Gui.Elements.Label.header_label(flow, "header-ages", {"sosciencity.ages"})
    Datalist.create(flow, "ages")

    Gui.Elements.Utils.separator_line(flow)

    Gui.Elements.Label.header_label(flow, "header-genders", {"sosciencity.gender-distribution"})
    Datalist.create(flow, "genders")

    -- call the update function to set the values
    update_housing_detailed_info_tab(tabbed_pane, entry)
end

local function add_caste_infos(container, caste_id)
    local caste = castes[caste_id]

    Gui.Elements.Sprite.create_caste_sprite(container, caste_id, 128)

    local caste_data = Datalist.create(container, "caste-infos")
    Datalist.add_kv_pair(caste_data, "caste-name", {"sosciencity.name"}, caste.localised_name)
    Datalist.add_kv_pair(caste_data, "description", "", {"technology-description." .. caste.name .. "-caste"})
    Datalist.add_kv_pair(
        caste_data,
        "taste",
        {"sosciencity.taste"},
        {
            "sosciencity.show-taste",
            Food.taste_names[caste.favored_taste],
            Food.taste_names[caste.least_favored_taste]
        }
    )
    Datalist.add_kv_pair(
        caste_data,
        "food-count",
        {"sosciencity.food-count"},
        {"sosciencity.show-food-count", caste.minimum_food_count}
    )
    Datalist.add_kv_pair(
        caste_data,
        "luxury",
        {"sosciencity.luxury"},
        {"sosciencity.show-luxury-needs", 100 * caste.desire_for_luxury, 100 * (1 - caste.desire_for_luxury)}
    )
    Datalist.add_kv_pair(
        caste_data,
        "room-count",
        {"sosciencity.room-needs"},
        {"sosciencity.show-room-needs", caste.required_room_count}
    )
    Datalist.add_kv_pair(
        caste_data,
        "power-demand",
        {"sosciencity.power-demand"},
        {"sosciencity.show-power-demand", caste.power_demand / 1000 * Time.second} -- convert from J / tick to kW
    )
    Datalist.add_kv_pair(
        caste_data,
        "water-demand",
        {"sosciencity.water"},
        {"sosciencity.show-water-demand", caste.water_demand * Time.minute}
    )

    local housing_flow = Datalist.add_kv_flow(caste_data, "housing-qualities", {"sosciencity.housing"})
    housing_flow.add {
            type = "label",
            name = "comfort",
            caption = {"sosciencity.show-comfort-needs", caste.minimum_comfort}
        }.style.single_line = false

    local prefered_flow =
        housing_flow.add {
        type = "flow",
        name = "prefered-qualities",
        direction = "vertical"
    }
    Datalist.add_key_label(prefered_flow, "header-prefered", {"sosciencity.prefered-qualities"})
    local disliked_flow =
        housing_flow.add {
        type = "flow",
        name = "disliked-qualities",
        direction = "vertical"
    }
    Datalist.add_key_label(disliked_flow, "header-disliked", {"sosciencity.disliked-qualities"})

    for quality, assessment in pairs(caste.housing_preferences) do
        local quality_flow
        if assessment > 0 then
            quality_flow = prefered_flow
        else
            quality_flow = disliked_flow
        end

        quality_flow.add {
            type = "label",
            name = quality,
            caption = {"", {"housing-quality." .. quality}, format(" (%+.1f)", assessment)},
            tooltip = {"housing-quality-description." .. quality}
        }
    end
end

local function add_caste_info_tab(tabbed_pane, caste_id)
    local flow = Gui.Elements.Tabs.create(tabbed_pane, "caste", {"caste-short." .. castes[caste_id].name})
    flow.style.vertical_spacing = 6
    flow.style.horizontal_align = "center"

    add_caste_infos(flow, caste_id)
end

local function update_housing_details(container, entry)
    local tabbed_pane = container.tabpane
    update_housing_general_info_tab(tabbed_pane, entry)
    update_housing_detailed_info_tab(tabbed_pane, entry)
end

local function create_housing_details(container, entry)
    local title = {"", entry[EK.entity].localised_name, "  -  ", Locale.caste(entry[EK.type])}
    set_details_view_title(container, title)

    local tabbed_pane = get_or_create_tabbed_pane(container)

    local caste_id = entry[EK.type]
    add_housing_general_info_tab(tabbed_pane, entry, caste_id)
    add_housing_detailed_info_tab(tabbed_pane, entry)
    add_caste_info_tab(tabbed_pane, caste_id)
end

---------------------------------------------------------------------------------------------------
-- << general building details >>

local function update_worker_list(list, entry)
    local workers = entry[EK.workers]

    list.clear()

    local at_least_one = false
    for unit_number, count in pairs(workers) do
        local house = Register.try_get(unit_number)
        if house then
            Datalist.add_operand_entry(list, unit_number, Locale.entry(house), count)

            at_least_one = true
        end
    end

    if not at_least_one then
        Datalist.add_operand_entry(list, "no-one", {"sosciencity.no-employees"}, "-")
    end
end

local function update_general_building_details(container, entry, player_id)
    local tabbed_pane = container.tabpane
    local tab = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = tab.building

    local building_details = get_building_details(entry)
    local type_details = type_definitions[entry[EK.type]]

    local active = entry[EK.active]
    if active ~= nil then
        Datalist.set_kv_pair_value(
            building_data,
            "active",
            active and {"sosciencity.active"} or {"sosciencity.inactive"}
        )
        Datalist.set_kv_pair_visibility(building_data, "active", true)
    else
        Datalist.set_kv_pair_visibility(building_data, "active", false)
    end

    local worker_specification = get_building_details(entry).workforce
    if worker_specification then
        local target_count = entry[EK.target_worker_count]
        Datalist.set_kv_pair_value(
            building_data,
            "staff",
            {"sosciencity.show-staff", entry[EK.worker_count], target_count}
        )

        building_data[format(Gui.unique_prefix_builder, "general", "staff-target")].slider_value = target_count

        local staff_performance = Inhabitants.evaluate_workforce(entry)
        Datalist.set_kv_pair_value(
            building_data,
            "staff-performance",
            staff_performance >= 0.2 and {"sosciencity.staff-performance", ceil(staff_performance * 100)} or
                {"sosciencity.not-enough-staff", ceil(0.2 * worker_specification.count)}
        )

        local worker_data = tab.workers
        update_worker_list(worker_data, entry)
    end

    local performance = entry[EK.performance]
    if building_details.speed then
        -- convert to x / minute
        local speed = round(building_details.speed * Time.minute * (entry[EK.performance] or 1))
        Datalist.set_kv_pair_value(building_data, "speed", {type_details.localised_speed_key, speed})
    elseif performance then
        Datalist.set_kv_pair_value(
            building_data,
            "general-performance",
            performance > 0.19999 and {"sosciencity.percentage", ceil(performance * 100)} or {"sosciencity.not-working"}
        )
    end

    if type_details.affected_by_clockwork then
        local clockwork_value = storage.caste_bonuses[Type.clockwork]
        Datalist.set_kv_pair_value(
            building_data,
            "maintenance",
            clockwork_value >= 0 and {"sosciencity.display-good-maintenance", clockwork_value} or
                {"sosciencity.display-bad-maintenance", clockwork_value}
        )
    end
end

local function create_general_building_details(container, entry, player_id)
    local entity = entry[EK.entity]
    set_details_view_title(container, entity.localised_name)

    local building_details = get_building_details(entry)
    local type_details = type_definitions[entry[EK.type]]

    local tabbed_pane = get_or_create_tabbed_pane(container)
    local tab = Gui.Elements.Tabs.create(tabbed_pane, "general", {"sosciencity.general"})

    if type_details.has_subscriptions then
        local flow =
            tab.add {
            type = "flow",
            name = "notification-flow",
            direction = "horizontal"
        }
        local style = flow.style
        style.horizontal_align = "right"
        style.horizontally_stretchable = true
        style.vertical_align = "center"
        style.right_padding = 10

        local notify_button =
            flow.add {
            type = "label",
            name = "notification-label",
            caption = {"sosciencity.notify-me"},
            tooltip = {"sosciencity.explain-notify-me"}
        }
        notify_button.style.font = "default-bold"

        flow.add {
            type = "checkbox",
            name = format(Gui.unique_prefix_builder, "general", "notification"),
            state = Communication.check_subscription(entry, player_id),
            tooltip = {"sosciencity.explain-notify-me"}
        }
    end

    local building_data = Datalist.create(tab, "building")

    Datalist.add_kv_pair(building_data, "building-type", {"sosciencity.type"}, type_details.localised_name)
    Datalist.add_kv_pair(building_data, "description", "", type_details.localised_description)
    Datalist.add_kv_pair(building_data, "active", {"sosciencity.active"})

    if building_details.range then
        local range = building_details.range
        Datalist.add_kv_pair(
            building_data,
            "range",
            {"sosciencity.range"},
            (range ~= "global" and {"sosciencity.show-range", building_details.range * 2}) or
                {"sosciencity.global-range"}
        )
    end

    if building_details.power_usage then
        -- convert to kW
        local power = round_to_step(building_details.power_usage * Time.second / 1000, 0.1)
        Datalist.add_kv_pair(
            building_data,
            "power",
            {"sosciencity.power-demand"},
            {"sosciencity.current-power-demand", power}
        )
    end

    -- display for the main performance metric
    if building_details.speed then
        Datalist.add_kv_pair(building_data, "speed", type_details.localised_speed_name)
    elseif entry[EK.performance] then
        Datalist.add_kv_pair(building_data, "general-performance", {"sosciencity.general-performance"})
    end

    local worker_specification = building_details.workforce
    if worker_specification then
        Datalist.add_kv_pair(building_data, "staff", {"sosciencity.staff"})

        -- TODO: extract this as a function
        Datalist.add_key_label(building_data, "staff-target", "")
        building_data.add {
            type = "slider",
            name = format(Gui.unique_prefix_builder, "general", "staff-target"),
            minimum_value = 0,
            maximum_value = worker_specification.count,
            value = entry[EK.target_worker_count],
            value_step = 1
        }

        Datalist.add_kv_pair(building_data, "staff-performance")

        local castes_needed =
            Luaq_from(worker_specification.castes):select_element(Locale.caste, true):call(
            display_enumeration,
            nil,
            {"sosciencity.or"}
        )
        Datalist.add_kv_pair(building_data, "castes", {"sosciencity.caste"}, castes_needed)

        Gui.Elements.Label.header_label(tab, "worker-header", {"sosciencity.staff"})
        Datalist.create(tab, "workers")
    end

    if type_details.affected_by_clockwork then
        Datalist.add_kv_pair(building_data, "maintenance", {"sosciencity.maintenance"})
    end

    update_general_building_details(container, entry, player_id)

    return tabbed_pane
end

Gui.set_value_changed_handler(
    format(Gui.unique_prefix_builder, "general", "staff-target"),
    generic_slider_handler,
    EK.target_worker_count
)

Gui.set_checked_state_handler(
    format(Gui.unique_prefix_builder, "general", "notification"),
    function(entry, element, player_id)
        Communication.set_subscription(entry, player_id, element.state)
    end
)

---------------------------------------------------------------------------------------------------
-- << composter >>

local function create_composting_catalogue(container)
    local tabbed_pane = get_or_create_tabbed_pane(container)
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
    update_general_building_details(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local building_data = Gui.Elements.Tabs.get_content(tabbed_pane, "general").building

    local humus = entry[EK.humus]
    Datalist.set_kv_pair_value(building_data, "humus", {"sosciencity.humus-count", round(humus / 100)})

    local inventory = Inventories.get_chest_inventory(entry)
    local progress_factor = Entity.analyze_composter_inventory(Inventories.get_contents(inventory)())
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
    local tabbed_pane = create_general_building_details(container, entry, player_id)

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

---------------------------------------------------------------------------------------------------
-- << water well >>

local function update_waterwell_details(container, entry, player_id)
    update_general_building_details(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local building_data = Gui.Elements.Tabs.get_content(tabbed_pane, "general").building

    local near_count = Neighborhood.get_neighbor_count(entry, Type.waterwell)
    local competition_performance = Entity.get_waterwell_competition_performance(entry)
    Datalist.set_kv_pair_value(
        building_data,
        "competition",
        {"sosciencity.show-waterwell-competition", near_count, display_percentage(competition_performance)}
    )

    Datalist.set_kv_pair_visibility(building_data, "module", not entry[EK.active])
end

local function create_waterwell_details(container, entry, player_id)
    local tabbed_pane = create_general_building_details(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "competition", {"sosciencity.competition"})
    Datalist.add_kv_pair(
        building_data,
        "module",
        nil,
        {"sosciencity.module-missing", display_item_stack("water-filter", 1)}
    )

    update_waterwell_details(container, entry)
end

---------------------------------------------------------------------------------------------------
-- << farm >>

local function update_farm(container, entry, player_id)
    update_general_building_details(container, entry, player_id)

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

        Datalist.set_kv_pair_visibility(building_data, "climate", true)
        Datalist.set_kv_pair_visibility(building_data, "humidity", true)

        if building_details.open_environment then
            Datalist.set_kv_pair_value(
                building_data,
                "climate",
                flora_details.preferred_climate == storage.current_climate and
                    {
                        "sosciencity.right-climate",
                        climate_locales[flora_details.preferred_climate]
                    } or
                    {
                        "sosciencity.wrong-climate",
                        climate_locales[storage.current_climate],
                        climate_locales[flora_details.preferred_climate],
                        {
                            "sosciencity.percentage-malus",
                            100 - flora_details.wrong_climate_coefficient * 100,
                            {"sosciencity.speed"}
                        }
                    }
            )
            Datalist.set_kv_pair_value(
                building_data,
                "humidity",
                flora_details.preferred_humidity == storage.current_humidity and
                    {
                        "sosciencity.right-humidity",
                        humidity_locales[flora_details.preferred_humidity]
                    } or
                    {
                        "sosciencity.wrong-humidity",
                        humidity_locales[storage.current_humidity],
                        humidity_locales[flora_details.preferred_humidity],
                        {
                            "sosciencity.percentage-malus",
                            100 - flora_details.wrong_humidity_coefficient * 100,
                            {"sosciencity.speed"}
                        }
                    }
            )
        else
            Datalist.set_kv_pair_value(
                building_data,
                "climate",
                {"sosciencity.closed-climate", climate_locales[flora_details.preferred_climate]}
            )
            Datalist.set_kv_pair_value(
                building_data,
                "humidity",
                {"sosciencity.closed-humidity", humidity_locales[flora_details.preferred_humidity]}
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
        Datalist.set_kv_pair_visibility(building_data, "climate", false)
        Datalist.set_kv_pair_visibility(building_data, "humidity", false)
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
    local tabbed_pane = create_general_building_details(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "orchid-bonus", {"caste-short.orchid"})
    Datalist.add_kv_pair(building_data, "biomass", {"sosciencity.biomass"})
    Datalist.add_kv_pair(building_data, "climate", {"sosciencity.climate"})
    Datalist.add_kv_pair(building_data, "humidity", {"sosciencity.humidity"})

    if get_building_details(entry).accepts_plant_care then
        Datalist.add_kv_checkbox(
            building_data,
            "humus-mode",
            format(Gui.unique_prefix_builder, "humus-mode", "farm"),
            {"sosciencity.humus-fertilization"},
            {"sosciencity.active"}
        )
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

        Datalist.add_kv_checkbox(
            building_data,
            "pruning-mode",
            format(Gui.unique_prefix_builder, "pruning-mode", "farm"),
            {"sosciencity.pruning"},
            {"sosciencity.active"}
        )
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
    format(Gui.unique_prefix_builder, "humus-mode", "farm"),
    generic_checkbox_handler,
    EK.humus_mode
)

Gui.set_checked_state_handler(
    format(Gui.unique_prefix_builder, "pruning-mode", "farm"),
    generic_checkbox_handler,
    EK.pruning_mode
)

---------------------------------------------------------------------------------------------------
-- << fishing hut >>

local function update_fishery_details(container, entry, player_id)
    update_general_building_details(container, entry, player_id)

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
    local tabbed_pane = create_general_building_details(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "water-tiles", {"sosciencity.water"})
    Datalist.add_kv_pair(building_data, "competition", {"sosciencity.competition"})

    update_fishery_details(container, entry)
end

---------------------------------------------------------------------------------------------------
-- << hunting hut >>

local function update_hunting_hut_details(container, entry, player_id)
    update_general_building_details(container, entry, player_id)

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
    local tabbed_pane = create_general_building_details(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "tree-count", {"sosciencity.tree-count"})
    Datalist.add_kv_pair(building_data, "competition", {"sosciencity.competition"})

    update_hunting_hut_details(container, entry)
end

---------------------------------------------------------------------------------------------------
-- << salt pond >>

local function update_salt_pond(container, entry, player_id)
    update_general_building_details(container, entry, player_id)

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
    local tabbed_pane = create_general_building_details(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "water-tiles", {"sosciencity.water"})

    update_salt_pond(container, entry)
end

---------------------------------------------------------------------------------------------------
-- << immigration port >>

local function update_immigration_port_details(container, entry, player_id)
    update_general_building_details(container, entry, player_id)

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
    local tabbed_pane = create_general_building_details(container, entry, player_id)

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

---------------------------------------------------------------------------------------------------
-- << hospital >>

local function update_disease_catalogue(container, entry)
    local tabbed_pane = container.tabpane
    local data_list = Gui.Elements.Tabs.get_content(tabbed_pane, "diseases").diseases

    local statistics = entry[EK.treated]
    local permissions = entry[EK.treatment_permissions]

    for id in pairs(Diseases.values) do
        data_list[tostring(id)].caption = statistics[id] or 0

        data_list[format(Gui.unique_prefix_builder, "treatment-permission", tostring(id))].state =
            permissions[id] == nil and true or permissions[id]
    end
end

local function create_disease_catalogue(container)
    local tabbed_pane = get_or_create_tabbed_pane(container)
    local tab = Gui.Elements.Tabs.create(tabbed_pane, "diseases", {"sosciencity.diseases"})

    local data_list = Datalist.create(tab, "diseases", 3)
    data_list.style.column_alignments[2] = "right"

    -- build the header
    local head =
        data_list.add {
        type = "label",
        name = "head",
        caption = {"sosciencity.diseases"}
    }
    head.style.font = "default-bold"
    local head_count =
        data_list.add {
        type = "label",
        name = "head-count"
    }
    head_count.style.minimal_width = 30
    data_list.add {
        type = "label",
        name = "head-permission"
    }

    -- disease entries
    for id, disease in pairs(Diseases.values) do
        local key =
            data_list.add {
            type = "label",
            name = "key-" .. id,
            caption = disease.localised_name,
            tooltip = disease.localised_description
        }
        key.style.horizontally_stretchable = true

        data_list.add {
            type = "label",
            name = tostring(id)
        }

        data_list.add {
            type = "checkbox",
            name = format(Gui.unique_prefix_builder, "treatment-permission", tostring(id)),
            state = true,
            tooltip = {"sosciencity.treatment-permission"}
        }
    end
end

for id in pairs(Diseases.values) do
    Gui.set_checked_state_handler(
        format(Gui.unique_prefix_builder, "treatment-permission", tostring(id)),
        generic_checkbox_handler,
        EK.treatment_permissions,
        id
    )
end

local function find_all_neighborhood_diseases(entry)
    local ret = {}

    for _, caste_id in pairs(TypeGroup.all_castes) do
        for _, house in Neighborhood.all_of_type(entry, caste_id) do
            Table.add(ret, house[EK.diseases])
        end
    end

    return ret
end

local function update_hospital_details(container, entry, player_id)
    update_general_building_details(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.set_kv_pair_value(building_data, "capacity", {"sosciencity.show-operations", floor(entry[EK.workhours])})

    local facility_flow = Datalist.get_kv_value_element(building_data, "facilities")
    facility_flow.clear()
    for _, _type in pairs(TypeGroup.hospital_complements) do
        local has_one = false
        for _, facility in Neighborhood.all_of_type(entry, _type) do
            if Entity.is_active(facility) then
                has_one = true
                break
            end
        end

        if has_one then
            local type_details = type_definitions[_type]

            facility_flow.add {
                type = "label",
                name = tostring(_type),
                caption = type_details.localised_name,
                tooltip = type_details.localised_description
            }
        end
    end

    Datalist.set_kv_pair_value(building_data, "blood_donations", entry[EK.blood_donations])

    local patients = general.patients
    patients.clear()

    local patient_diseases = find_all_neighborhood_diseases(entry)
    for disease_id, count in pairs(patient_diseases) do
        if disease_id ~= DiseaseGroup.HEALTHY then
            local disease = diseases[disease_id]
            local key = format("disease-%d", disease_id)
            Datalist.add_operand_entry(patients, key, disease.localised_name, count)
            Datalist.set_kv_pair_tooltip(patients, key, disease.localised_description)
        end
    end

    update_disease_catalogue(container, entry)
end

local function create_hospital_details(container, entry, player_id)
    local tabbed_pane = create_general_building_details(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "capacity", {"sosciencity.capacity"})
    Datalist.add_kv_flow(building_data, "facilities", {"sosciencity.facilities"})
    if (entry[EK.type] == Type.improvised_hospital) then
        Datalist.set_kv_pair_visibility(building_data, "facilities", false)
    end

    Datalist.add_kv_pair(building_data, "blood_donations", {"sosciencity.blood-donations"})
    Datalist.set_kv_pair_visibility(building_data, "blood_donations", storage.technologies["transfusion-medicine"])

    local textfield =
        Datalist.add_kv_textfield(
        building_data,
        "blood-donation-threshold",
        format(Gui.unique_prefix_builder, "blood-donation-threshold", "hospital"),
        {numeric = true},
        {"sosciencity.threshold"}
    )
    textfield.text = tostring(entry[EK.blood_donation_threshold])
    textfield.tooltip = {"sosciencity.blood-donation-threshold"}
    building_data["key-blood-donation-threshold"].visible = storage.technologies["transfusion-medicine"]
    textfield.visible = storage.technologies["transfusion-medicine"]

    Gui.Elements.Label.header_label(general, "header-patients", {"sosciencity.patients"})
    Datalist.create(general, "patients")

    create_disease_catalogue(container)

    update_hospital_details(container, entry)
end

Gui.set_gui_confirmed_handler(
    format(Gui.unique_prefix_builder, "blood-donation-threshold", "hospital"),
    generic_numeric_textfield_handler,
    EK.blood_donation_threshold
)

---------------------------------------------------------------------------------------------------
-- << upbringing station >>

local function update_upbringing_mode_radiobuttons(entry, mode_flow)
    local mode = entry[EK.education_mode]

    for index, radiobutton in pairs(mode_flow.children) do
        local mode_id = TypeGroup.breedable_castes[index]

        if mode_id then
            radiobutton.visible = Inhabitants.caste_is_researched(mode_id)
            radiobutton.state = (mode == mode_id)
        else
            radiobutton.state = (mode == Type.null)
        end
    end
end

local function update_classes_flow(entry, classes_flow)
    classes_flow.clear()

    local current_tick = game.tick
    local classes = entry[EK.classes]
    local at_least_one = false

    for index, class in pairs(classes) do
        local percentage = (current_tick - class[1]) / Entity.upbringing_time
        local count = Table.array_sum(class[2])
        classes_flow.add {
            name = tostring(index),
            type = "label",
            caption = {"sosciencity.show-class", count, display_percentage(percentage)}
        }

        at_least_one = true
    end

    if not at_least_one then
        classes_flow.add {
            name = "no-classes",
            type = "label",
            caption = {"sosciencity.no-classes"}
        }
    end
end

local function update_upbringing_station(container, entry, player_id)
    update_general_building_details(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local building_data = Gui.Elements.Tabs.get_content(tabbed_pane, "general").building

    local mode_flow = Datalist.get_kv_value_element(building_data, "mode")
    update_upbringing_mode_radiobuttons(entry, mode_flow)

    local probability_flow = Datalist.get_kv_value_element(building_data, "probabilities")
    local probabilities = Entity.get_upbringing_expectations(entry[EK.education_mode])
    local at_least_one = false

    for _, caste_id in pairs(TypeGroup.breedable_castes) do
        local probability = probabilities[caste_id]
        local caste = castes[caste_id]

        local label = probability_flow[caste.name]
        if probability then
            at_least_one = true

            label.caption = {
                "sosciencity.caste-probability",
                caste.localised_name_short,
                display_percentage(probability)
            }
        end
        label.visible = (probability ~= nil)
    end

    probability_flow.no_castes.visible = not at_least_one

    update_classes_flow(entry, Datalist.get_kv_value_element(building_data, "classes"))

    Datalist.set_kv_pair_value(building_data, "graduates", entry[EK.graduates])
end

local function create_upbringing_station(container, entry, player_id)
    local tabbed_pane = create_general_building_details(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(
        building_data,
        "capacity",
        {"sosciencity.capacity"},
        {"sosciencity.show-upbringing-capacity", get_building_details(entry).capacity}
    )

    -- Mode flow
    local mode_flow = Datalist.add_kv_flow(building_data, "mode", {"sosciencity.mode"})

    for _, caste_id in pairs(TypeGroup.breedable_castes) do
        mode_flow.add {
            name = format(Gui.unique_prefix_builder, "education-mode", caste_id),
            type = "radiobutton",
            caption = type_definitions[caste_id].localised_name,
            state = true
        }
    end

    mode_flow.add {
        name = format(Gui.unique_prefix_builder, "education-mode", Type.null),
        type = "radiobutton",
        caption = {"sosciencity.no-mode"},
        state = true
    }

    -- expected castes flow
    local probabilities_flow = Datalist.add_kv_flow(building_data, "probabilities", {"sosciencity.expected"})

    probabilities_flow.add {
        name = "no_castes",
        type = "label",
        caption = {"sosciencity.no-castes"}
    }

    for _, caste_id in pairs(TypeGroup.breedable_castes) do
        local caste = castes[caste_id]
        probabilities_flow.add {
            name = caste.name,
            type = "label"
        }
    end

    Datalist.add_kv_flow(building_data, "classes", {"sosciencity.classes"})
    Datalist.add_kv_pair(building_data, "graduates", {"sosciencity.graduates"})

    update_upbringing_station(container, entry)
end

for _, caste_id in pairs(Table.union_array(TypeGroup.breedable_castes, {Type.null})) do
    Gui.set_checked_state_handler(
        format(Gui.unique_prefix_builder, "education-mode", caste_id),
        generic_radiobutton_handler,
        caste_id,
        EK.education_mode,
        update_upbringing_mode_radiobuttons
    )
end

---------------------------------------------------------------------------------------------------
-- << waste dump >>

local function update_waste_dump_mode_radiobuttons(entry, mode_flow)
    local active_mode = entry[EK.waste_dump_mode]
    for mode_name, mode_id in pairs(WasteDumpOperationMode) do
        local radiobutton = mode_flow[format(Gui.unique_prefix_builder, "waste-dump-mode", mode_name)]
        radiobutton.state = (active_mode == mode_id)
    end
end

local function update_waste_dump(container, entry, player_id)
    update_general_building_details(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local building_data = Gui.Elements.Tabs.get_content(tabbed_pane, "general").building

    local stored_garbage = entry[EK.stored_garbage]
    local capacity = get_building_details(entry).capacity
    Datalist.set_kv_pair_value(
        building_data,
        "capacity",
        {
            "sosciencity.value-with-unit",
            {"sosciencity.fraction", Table.sum(stored_garbage), capacity},
            {"sosciencity.items"}
        }
    )

    Datalist.set_kv_pair_value(
        building_data,
        "stored_garbage",
        Luaq_from(stored_garbage):select(display_item_stack):call(display_enumeration, "\n")
    )

    update_waste_dump_mode_radiobuttons(entry, Datalist.get_kv_value_element(building_data, "mode"))

    local checkbox = Datalist.get_checkbox(building_data, "press")
    checkbox.state = entry[EK.press_mode]
end

local function create_waste_dump(container, entry, player_id)
    local tabbed_pane = create_general_building_details(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "capacity", {"sosciencity.capacity"})
    Datalist.add_kv_pair(building_data, "stored_garbage", {"sosciencity.content"})

    local mode_flow = Datalist.add_kv_flow(building_data, "mode", {"sosciencity.mode"})
    for mode_name in pairs(WasteDumpOperationMode) do
        mode_flow.add {
            name = format(Gui.unique_prefix_builder, "waste-dump-mode", mode_name),
            type = "radiobutton",
            caption = {"sosciencity." .. mode_name},
            state = true
        }
    end

    Datalist.add_kv_checkbox(
        building_data,
        "press",
        format(Gui.unique_prefix_builder, "waste-dump-press", ""),
        {"sosciencity.press"},
        {"sosciencity.active"}
    )

    update_waste_dump(container, entry)
end

for mode_name, mode_id in pairs(WasteDumpOperationMode) do
    Gui.set_checked_state_handler(
        format(Gui.unique_prefix_builder, "waste-dump-mode", mode_name),
        generic_radiobutton_handler,
        mode_id,
        EK.waste_dump_mode,
        update_waste_dump_mode_radiobuttons
    )
end

Gui.set_checked_state_handler(
    format(Gui.unique_prefix_builder, "waste-dump-press", ""),
    generic_checkbox_handler,
    EK.press_mode
)

---------------------------------------------------------------------------------------------------
-- << market >>

local function analyse_dependants(entry, consumption_key)
    local inhabitant_count = 0
    local consumption = 0

    for _, caste_id in pairs(TypeGroup.all_castes) do
        local caste_inhabitants = 0
        for _, house in Neighborhood.all_of_type(entry, caste_id) do
            caste_inhabitants = caste_inhabitants + house[EK.inhabitants]
        end

        inhabitant_count = inhabitant_count + caste_inhabitants
        consumption = consumption + caste_inhabitants * Castes.values[caste_id][consumption_key]
    end

    return inhabitant_count, consumption
end

local function update_market(container, entry, player_id)
    update_general_building_details(container, entry, player_id)

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
    local tabbed_pane = create_general_building_details(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "content", {"sosciencity.content"})
    Datalist.add_kv_pair(building_data, "dependants", {"sosciencity.dependants"})
    Datalist.add_kv_pair(building_data, "dependants-demand")
    Datalist.add_kv_pair(building_data, "supply", {"sosciencity.supply"})

    update_market(container, entry)
end

---------------------------------------------------------------------------------------------------
-- << water distributer >>

local function create_water_catalogue(container)
    local tabbed_pane = get_or_create_tabbed_pane(container)
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

    for water, effect in pairs(DrinkingWater.values) do
        local water_representation = {"", format("[fluid=%s]  ", water), fluid_prototypes[water].localised_name}
        Datalist.add_operand_entry(data_list, water, water_representation, Locale.integer_summand(effect))
    end
end

local function update_water_distributer(container, entry, player_id)
    update_general_building_details(container, entry, player_id)

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
    local tabbed_pane = create_general_building_details(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "content", {"sosciencity.content"})
    Datalist.add_kv_pair(building_data, "dependants", {"sosciencity.dependants"})
    Datalist.add_kv_pair(building_data, "dependants-demand")
    Datalist.add_kv_pair(building_data, "supply", {"sosciencity.supply"})

    update_water_distributer(container, entry)

    create_water_catalogue(container)
end

---------------------------------------------------------------------------------------------------
-- << dumpster >>

local average_calories = Luaq_from(Food.values):select_key("calories"):call(Table.average)

local function analyse_garbage_output(entry)
    local inhabitant_count = 0
    local garbage = 0
    local calorific_demand = 0

    for _, caste_id in pairs(TypeGroup.all_castes) do
        local caste_inhabitants = 0
        for _, house in Neighborhood.all_of_type(entry, caste_id) do
            caste_inhabitants = caste_inhabitants + house[EK.inhabitants]
        end
        inhabitant_count = inhabitant_count + caste_inhabitants

        local caste = Castes.values[caste_id]
        garbage = garbage + caste_inhabitants * caste.garbage_coefficient
        calorific_demand = calorific_demand + caste_inhabitants * caste.calorific_demand
    end

    return inhabitant_count, garbage, Food.food_leftovers_chance * calorific_demand / average_calories
end

local function update_dumpster(container, entry, player_id)
    update_general_building_details(container, entry, player_id)

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
    local tabbed_pane = create_general_building_details(container, entry, player_id)

    local general = Gui.Elements.Tabs.get_content(tabbed_pane, "general")
    local building_data = general.building

    Datalist.add_kv_pair(building_data, "dependants", {"sosciencity.dependants"})
    Datalist.add_kv_pair(building_data, "garbage", {"item-name.garbage"})
    Datalist.add_kv_pair(building_data, "food_leftovers")

    update_dumpster(container, entry)
end

---------------------------------------------------------------------------------------------------
-- << fertilization station >>

local function update_fertilization_station(container, entry, player_id)
    update_general_building_details(container, entry, player_id)

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
    local tabbed_pane = create_general_building_details(container, entry, player_id)

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

---------------------------------------------------------------------------------------------------
-- << pruning station >>

local function update_pruning_station(container, entry, player_id)
    update_general_building_details(container, entry, player_id)

    local tabbed_pane = container.tabpane
    local building_data = Gui.Elements.Tabs.get_content(tabbed_pane, "general").building

    Datalist.set_kv_pair_value(
        building_data,
        "workhours",
        {"sosciencity.display-workhours", floor(entry[EK.workhours])}
    )
end

local function create_pruning_station(container, entry, player_id)
    local tabbed_pane = create_general_building_details(container, entry, player_id)

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

---------------------------------------------------------------------------------------------------
-- << general details view functions >>

function Gui.DetailsView.create(player)
    local frame = player.gui.screen[DETAILS_VIEW_NAME]
    if frame and frame.valid then
        return
    end

    frame =
        player.gui.screen.add {
        type = "frame",
        name = DETAILS_VIEW_NAME,
        direction = "horizontal",
        style = "sosciencity_details_view_frame"
    }
    frame.location = {x = 10, y = 120}

    frame.add {
        type = "frame",
        name = "nested",
        direction = "horizontal",
        style = "inside_deep_frame"
    }

    frame.visible = false
end

local function get_details_view(player)
    local details_view = player.gui.screen[DETAILS_VIEW_NAME]

    -- we check if the gui still exists, as other mods can delete it
    if details_view ~= nil and details_view.valid then
        return details_view
    else
        -- recreate it otherwise
        Gui.DetailsView.create(player)
        return get_details_view(player)
    end
end

local function get_nested_details_view(player)
    return get_details_view(player).nested
end

local type_gui_specifications = {
    [Type.mining_drill] = {
        creater = create_general_building_details,
        updater = update_general_building_details
    },
    [Type.assembling_machine] = {
        creater = create_general_building_details,
        updater = update_general_building_details
    },
    [Type.furnace] = {
        creater = create_general_building_details,
        updater = update_general_building_details
    },
    [Type.rocket_silo] = {
        creater = create_general_building_details,
        updater = update_general_building_details
    },
    [Type.composter] = {
        creater = create_composter_details,
        updater = update_composter_details
    },
    [Type.composter_output] = {
        creater = create_general_building_details,
        updater = update_general_building_details
    },
    [Type.dumpster] = {
        creater = create_dumpster,
        updater = update_dumpster
    },
    [Type.egg_collector] = {
        creater = create_general_building_details,
        updater = update_general_building_details
    },
    [Type.empty_house] = {
        creater = create_empty_housing_details
    },
    [Type.farm] = {
        creater = create_farm,
        updater = update_farm
    },
    [Type.automatic_farm] = {
        creater = create_farm,
        updater = update_farm
    },
    [Type.fishery] = {
        creater = create_fishery_details,
        updater = update_fishery_details
    },
    [Type.improvised_hospital] = {
        creater = create_hospital_details,
        updater = update_hospital_details
    },
    [Type.pharmacy] = {
        creater = create_general_building_details,
        updater = update_general_building_details
    },
    [Type.hospital] = {
        creater = create_hospital_details,
        updater = update_hospital_details
    },
    [Type.fertilization_station] = {
        creater = create_fertilization_station,
        updater = update_fertilization_station
    },
    [Type.pruning_station] = {
        creater = create_pruning_station,
        updater = update_pruning_station
    },
    [Type.psych_ward] = {
        creater = create_general_building_details,
        updater = update_general_building_details
    },
    [Type.hunting_hut] = {
        creater = create_hunting_hut_details,
        updater = update_hunting_hut_details
    },
    [Type.immigration_port] = {
        creater = create_immigration_port_details,
        updater = update_immigration_port_details,
        always_update = true
    },
    [Type.manufactory] = {
        creater = create_general_building_details,
        updater = update_general_building_details
    },
    [Type.market] = {
        creater = create_market,
        updater = update_market
    },
    [Type.nightclub] = {
        creater = create_general_building_details,
        updater = update_general_building_details
    },
    [Type.salt_pond] = {
        creater = create_salt_pond,
        updater = update_salt_pond
    },
    [Type.upbringing_station] = {
        creater = create_upbringing_station,
        updater = update_upbringing_station,
        always_update = true
    },
    [Type.waste_dump] = {
        creater = create_waste_dump,
        updater = update_waste_dump
    },
    [Type.water_distributer] = {
        creater = create_water_distributer,
        updater = update_water_distributer
    },
    [Type.waterwell] = {
        creater = create_waterwell_details,
        updater = update_waterwell_details
    }
}

-- add the caste specifications
for caste_id in pairs(castes) do
    type_gui_specifications[caste_id] = {
        creater = create_housing_details,
        updater = update_housing_details
    }
end

--- Updates the details guis for every player.
function Gui.DetailsView.update()
    local current_tick = game.tick

    for player_id, unit_number in pairs(storage.details_view) do
        local entry = Register.try_get(unit_number)
        local player = game.get_player(player_id)

        -- check if the entity hasn't been unregistered in the meantime
        if not entry then
            Gui.DetailsView.close(player)
        else
            local gui_spec = type_gui_specifications[entry[EK.type]]
            local updater = gui_spec and gui_spec.updater

            if updater and (entry[EK.last_update] == current_tick or gui_spec.always_update) then
                updater(get_nested_details_view(player), entry, player_id)
            end
        end
    end
end

--- Builds a details gui for the given player and the given entity.
--- @param player Player
--- @param unit_number integer
function Gui.DetailsView.open(player, unit_number)
    local entry = Register.try_get(unit_number)
    if not entry then
        return
    end

    local gui_spec = type_gui_specifications[entry[EK.type]]
    local creater = gui_spec and gui_spec.creater
    if not creater then
        return
    end

    local details_view = get_details_view(player)
    local player_id = player.index
    local nested = details_view.nested

    nested.clear()
    creater(nested, entry, player_id)
    details_view.visible = true
    storage.details_view[player_id] = unit_number
end

--- Closes the details view for the given player.
--- @param player Player
function Gui.DetailsView.close(player)
    local details_view = get_details_view(player)
    details_view.visible = false
    storage.details_view[player.index] = nil
    details_view.caption = nil
    details_view.nested.clear()
end

--- Closes and reopens all the Guis related to the given entry.
--- @param entry Entry
function Gui.DetailsView.rebuild_for_entry(entry)
    local unit_number = entry[EK.unit_number]

    for player_index, viewed_unit_number in pairs(storage.details_view) do
        if unit_number == viewed_unit_number then
            local player = game.get_player(player_index)
            Gui.DetailsView.close(player)
            Gui.DetailsView.open(player, unit_number)
        end
    end
end

--- Destroys the city info gui.
--- @param player Player
function Gui.DetailsView.destroy(player)
    local details_view_gui = player.gui.screen[DETAILS_VIEW_NAME]

    if details_view_gui ~= nil and details_view_gui.valid then
        details_view_gui.destroy()
    end
end

Gui.add_gui_opened_handler(
    function(player, event)
        if event.gui_type == defines.gui_type.entity then
            Gui.DetailsView.open(player, event.entity.unit_number)
        end
    end
)

Gui.add_gui_closed_handler(
    function(player, event)
        if event.gui_type == defines.gui_type.entity then
            Gui.DetailsView.close(player)
        end
    end
)
