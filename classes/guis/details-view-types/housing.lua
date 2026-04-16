--- Details view for housing.

-- enums
local EK = require("enums.entry-key")
local Type = require("enums.type")
local DiseaseCategory = require("enums.disease-category")
local HappinessSummand = require("enums.happiness-summand")
local HappinessFactor = require("enums.happiness-factor")
local HealthSummand = require("enums.health-summand")
local HealthFactor = require("enums.health-factor")
local SanitySummand = require("enums.sanity-summand")
local SanityFactor = require("enums.sanity-factor")

-- constants
local Castes = require("constants.castes")
local Color = require("constants.color")
local Diseases = require("constants.diseases")
local Food = require("constants.food")
local Housing = require("constants.housing")
local Time = require("constants.time")

local castes = Castes.values
local diseases = Diseases.values
local food_values = Food.values
local required_nutrition_tags = Food.required_nutrition_tags
local Gui = Gui
local Inhabitants = Inhabitants
local Locale = Locale
local Register = Register
local ceil = math.ceil
local floor = math.floor
local format = string.format
local round_to_step = Tirislib.Utils.round_to_step
local display_item_stack = Tirislib.Locales.display_item_stack
local display_time = Tirislib.Locales.display_time
local Datalist = Gui.Elements.Datalist

---------------------------------------------------------------------------------------------------
-- << empty houses >>

local function add_caste_chooser_tab(tabbed_pane, house_details)
    local flow = Gui.Elements.Tabs.create(tabbed_pane, "caste-chooser", {"sosciencity.caste"})

    flow.style.horizontal_align = "center"
    flow.style.vertical_align = "center"
    flow.style.vertical_spacing = 6

    local at_least_one = false
    for _, caste in pairs(Castes.all) do
        if not Inhabitants.caste_is_researched(caste.type) then
            goto continue
        end

        local caste_name = caste.name

        local button =
            flow.add {
                type = "button",
                name = format(Gui.unique_prefix_builder, "assign-caste", caste_name),
                caption = {"caste-name." .. caste_name},
                mouse_button_filter = {"left"},
                tags = {sosciencity_gui_event = "assign_caste", caste_id = caste.type}
            }
        button.style.width = 150

        local has_room = house_details.room_count >= caste.required_room_count
        local has_comfort = house_details.comfort >= caste.minimum_comfort

        if not has_room then
            button.tooltip = {"sosciencity.not-enough-room"}
        elseif not has_comfort then
            button.style.font_color = Color.orange
            button.tooltip = {"sosciencity.comfort-warning", house_details.comfort, caste.minimum_comfort}
        else
            button.tooltip = {
                "sosciencity.move-in",
                Locale.integer_summand(
                    Inhabitants.evaluate_housing_qualities(house_details, caste) + house_details.comfort
                )
            }
        end
        button.enabled = has_room
        at_least_one = true

        ::continue::
    end
    if not at_least_one then
        flow.add {
            type = "label",
            name = "no-castes-researched-label",
            caption = {"sosciencity.no-castes-researched"}
        }
    end
end

Gui.set_click_handler(
    "assign_caste",
    function(event)
        local entry = Register.try_get(storage.details_view[event.player_index])
        Inhabitants.try_allow_for_caste(entry, event.element.tags.caste_id, true)
    end
)

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
    Gui.DetailsView.set_title(container, entry[EK.entity].localised_name)

    local tabbed_pane = Gui.DetailsView.get_or_create_tabbed_pane(container)

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

    local strike_level = entry[EK.strike_level]
    if strike_level > 0 then
        local healthy = entry[EK.diseases][DiseaseGroup.HEALTHY]
        local caste = castes[entry[EK.type]]
        local willing = floor(healthy * (1 - strike_level * (1 - caste.full_strike_worker_fraction)))
        local striking = healthy - willing
        if striking > 0 then
            Datalist.add_operand_entry(occupations_list, "striking", {"sosciencity.striking"}, striking)
            Datalist.set_kv_pair_tooltip(occupations_list, "striking", {"sosciencity.explain-striking"})
        end
    end

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
    Datalist.set_kv_pair_value(
        general_list,
        "inhabitants",
        {"sosciencity.show-inhabitants", inhabitants, capacity}
    )
    Datalist.set_datalist_value_tooltip(
        general_list,
        "inhabitants",
        (entry[EK.strike_level] > 0) and {"sosciencity.on-strike"} or ""
    )

    -- the annoying edge case of no inhabitants inside the house
    if inhabitants == 0 then
        Datalist.set_kv_pair_value(general_list, "happiness", "-")
        Datalist.set_kv_pair_visibility(general_list, "strike", false)
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
    local strike_level = entry[EK.strike_level]
    if strike_level >= 1 then
        Datalist.set_kv_pair_value(general_list, "strike", {"sosciencity.show-strike-full"})
        Datalist.set_kv_pair_visibility(general_list, "strike", true)
    elseif strike_level > 0 then
        Datalist.set_kv_pair_value(general_list, "strike", {"sosciencity.show-strike-partial", floor(strike_level * 100)})
        Datalist.set_kv_pair_visibility(general_list, "strike", true)
    else
        Datalist.set_kv_pair_visibility(general_list, "strike", false)
    end
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

    Datalist.set_kv_pair_visibility(general_list, "disease-rate", DEBUG)
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

local priority_presets = {
    ["low"] = {value = -10, locale = {"sosciencity.priority-low"}},
    ["mid"] = {value = 0, locale = {"sosciencity.priority-mid"}},
    ["high"] = {value = 10, locale = {"sosciencity.priority-high"}},
    ["very-high"] = {value = 20, locale = {"sosciencity.priority-very-high"}}
}

Gui.set_click_handler(
    "set_housing_priority_with_preset",
    function(event)
        local tags = event.element.tags

        local entry = Register.try_get(tags.unit_number)
        if not entry then
            return
        end

        entry[EK.housing_priority] = tags.priority_value

        local value_text = tostring(tags.priority_value)
        for _, element in pairs(Gui.get_elements(tags.unit_number, "priority_textfield")) do
            if element.valid then
                element.text = value_text
            end
        end
    end
)

Gui.set_gui_confirmed_handler(
    "set_housing_priority",
    function(event)
        local tags = event.element.tags

        local entry = Register.try_get(tags.unit_number)
        if not entry then
            return
        end

        entry[EK.housing_priority] = tonumber(event.element.text)
    end
)

local function add_housing_general_info_tab(tabbed_pane, entry, caste_id, player_id)
    local flow = Gui.Elements.Tabs.create(tabbed_pane, "general", {"sosciencity.general"})

    flow.style.vertical_spacing = 6
    flow.style.horizontal_align = "right"

    local general_list = Datalist.create(flow, "general-infos")
    Datalist.add_kv_pair(general_list, "caste", {"sosciencity.caste"}, Locale.caste(entry[EK.type]))

    Datalist.add_kv_pair(general_list, "inhabitants", {"sosciencity.inhabitants"})
    Datalist.add_kv_pair(general_list, "happiness", {"sosciencity.happiness"})
    Datalist.add_kv_pair(general_list, "strike", {"sosciencity.strike"})
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

    local priority_flow = Gui.Elements.Flow.horizontal_right(flow, "priority_flow")
    priority_flow.style.vertical_align = "center"
    priority_flow.add {
        type = "label",
        caption = {"sosciencity.priority"},
        tooltip = {"sosciencity.explain-housing-priority"}
    }
    local textfield =
        priority_flow.add {
        type = "textfield",
        name = "priority",
        numeric = true,
        tooltip = {"sosciencity.explain-housing-priority"},
        tags = {
            sosciencity_gui_event = "set_housing_priority",
            unit_number = entry[EK.unit_number]
        }
    }
    textfield.text = tostring(entry[EK.housing_priority])
    Gui.register_element(textfield, entry[EK.unit_number], "priority_textfield", player_id)

    local priority_buttons_flow = Gui.Elements.Flow.horizontal_right(flow)
    for _, priority_preset in pairs(priority_presets) do
        priority_buttons_flow.add {
            type = "button",
            caption = priority_preset.locale,
            tags = {
                sosciencity_gui_event = "set_housing_priority_with_preset",
                unit_number = entry[EK.unit_number],
                priority_value = priority_preset.value
            },
            style = "sosciencity_sortable_list_head",
            tooltip = {"sosciencity.tooltip-priority-button", priority_preset.value}
        }
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
            mouse_button_filter = {"left"},
            tags = {sosciencity_gui_event = "kickout"}
        }
        kickout_button.style.right_margin = 4
    end

    -- call the update function to set the values
    update_housing_general_info_tab(tabbed_pane, entry)
end

Gui.set_click_handler(
    "kickout",
    function(event)
        local button = event.element
        local entry = Register.try_get(storage.details_view[event.player_index])
        if Gui.Elements.Utils.is_confirmed(button) then
            Register.change_type(entry, Type.empty_house)
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

local function update_housing_diet_tab(tabbed_pane, entry)
    local flow = Gui.Elements.Tabs.get_content(tabbed_pane, "diet")
    local info = Inhabitants.get_diet_info(entry)

    -- status label
    local status = flow["diet-status"]
    if info.no_food then
        status.caption = {"sosciencity.diet-no-food"}
        status.style.font_color = Color.red
        status.visible = true
    elseif info.is_distress then
        status.caption = {"sosciencity.diet-distress"}
        status.style.font_color = Color.orange
        status.visible = true
    else
        status.visible = false
    end

    -- current diet list
    local diet_items = flow["diet-items"]
    diet_items.clear()
    for _, item_name in pairs(info.diet) do
        local label = diet_items.add {
            type = "label",
            caption = {"", format("[item=%s] ", item_name), food_values[item_name].localised_name},
            elem_tooltip = {type = "item", name = item_name}
        }
        if info.favored_set[item_name] then
            label.style.font_color = Color.green
        elseif info.disliked_set[item_name] then
            label.style.font_color = Color.red
        end
    end

    -- nutrition tag coverage
    local nutrition_flow = flow["diet-nutrition"]
    for _, tag in pairs(required_nutrition_tags) do
        local label = nutrition_flow[tostring(tag)]
        local covered = info.covered_tags[tag]
        label.caption = {"", covered and "✓ " or "✗ ", Locale.nutrition_tag(tag)}
        label.style.font_color = covered and Color.green or Color.red
    end
end

local function add_housing_diet_tab(tabbed_pane, entry, caste_id)
    local flow = Gui.Elements.Tabs.create(tabbed_pane, "diet", {"sosciencity.diet"})

    local caste = castes[caste_id]

    -- static: eating style info
    local info_list = Datalist.create(flow, "diet-caste-info")
    Datalist.add_kv_pair(info_list, "eating-behavior", {"sosciencity.eating-behavior"}, Locale.eating_behavior(caste.eating_behavior))
    Datalist.add_kv_pair(info_list, "favored-taste", {"sosciencity.diet-favored-taste"}, Locale.taste_category(caste.favored_taste))
    Datalist.get_kv_value_element(info_list, "favored-taste").style.font_color = Color.green
    Datalist.add_kv_pair(info_list, "disliked-taste", {"sosciencity.diet-disliked-taste"}, Locale.taste_category(caste.least_favored_taste))
    Datalist.get_kv_value_element(info_list, "disliked-taste").style.font_color = Color.red

    Gui.Elements.Utils.separator_line(flow)

    -- dynamic: status warning
    local status = flow.add {type = "label", name = "diet-status"}
    status.style.single_line = false
    status.visible = false

    -- dynamic: current diet
    Gui.Elements.Label.header_label(flow, "diet-current-header", {"sosciencity.diet-current"})
    flow.add {type = "flow", name = "diet-items", direction = "vertical"}

    Gui.Elements.Utils.separator_line(flow)

    -- dynamic: nutrition tag coverage
    Gui.Elements.Label.header_label(flow, "diet-nutrition-header", {"sosciencity.diet-nutrition"})
    local nutrition_flow = flow.add {type = "flow", name = "diet-nutrition", direction = "vertical"}
    for _, tag in pairs(required_nutrition_tags) do
        nutrition_flow.add {type = "label", name = tostring(tag)}
    end

    update_housing_diet_tab(tabbed_pane, entry)
end

local function update_housing_details(container, entry)
    local tabbed_pane = container.tabpane
    update_housing_general_info_tab(tabbed_pane, entry)
    update_housing_detailed_info_tab(tabbed_pane, entry)
    update_housing_diet_tab(tabbed_pane, entry)
end

local function create_housing_details(container, entry, player_id)
    local title = {"", entry[EK.entity].localised_name, "  -  ", Locale.caste(entry[EK.type])}
    Gui.DetailsView.set_title(container, title)

    local tabbed_pane = Gui.DetailsView.get_or_create_tabbed_pane(container)

    local caste_id = entry[EK.type]
    add_housing_general_info_tab(tabbed_pane, entry, caste_id, player_id)
    add_housing_detailed_info_tab(tabbed_pane, entry)
    add_housing_diet_tab(tabbed_pane, entry, caste_id)
end

Gui.DetailsView.register_type(Type.empty_house, {
    creater = create_empty_housing_details
})
for _, caste in pairs(Castes.all) do
    Gui.DetailsView.register_type(caste.type, {
        creater = create_housing_details,
        updater = update_housing_details
    })
end
