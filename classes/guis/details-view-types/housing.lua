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

local upgradeable_tags = Tirislib.Tables.get_keyset(Housing.tag_costs)

---------------------------------------------------------------------------------------------------
-- << empty houses >>

local function fill_caste_chooser(flow, entry, house_details)
    flow.clear()

    local current_comfort = entry[EK.current_comfort] or 0
    local trait_upgrades = entry[EK.trait_upgrades]

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
        local has_comfort = current_comfort >= caste.minimum_comfort
        local can_reach_comfort = house_details.max_comfort >= caste.minimum_comfort

        if not has_room then
            button.tooltip = {"sosciencity.not-enough-room"}
        elseif not has_comfort and not can_reach_comfort then
            button.style.font_color = Color.red
            button.tooltip = {"sosciencity.comfort-max-warning", house_details.max_comfort, caste.minimum_comfort}
        elseif not has_comfort then
            button.style.font_color = Color.orange
            button.tooltip = {"sosciencity.comfort-warning", current_comfort, caste.minimum_comfort}
        else
            button.tooltip = {
                "sosciencity.move-in",
                Locale.integer_summand(
                    Inhabitants.evaluate_housing_traits(house_details, caste, trait_upgrades) + current_comfort
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

local function add_caste_chooser_tab(tabbed_pane, entry, house_details)
    local flow = Gui.Elements.Tabs.create(tabbed_pane, "caste-chooser", {"sosciencity.caste"})
    flow.style.horizontal_align = "center"
    flow.style.vertical_align = "center"
    flow.style.vertical_spacing = 6
    fill_caste_chooser(flow, entry, house_details)
end

Gui.set_click_handler(
    "assign_caste",
    function(event)
        local entry = Register.try_get(storage.details_view[event.player_index])
        Inhabitants.try_allow_for_caste(entry, event.element.tags.caste_id, true)
    end
)

Gui.set_click_handler(
    "upgrade_house",
    function(event)
        local tags = event.element.tags
        local entry = Register.try_get(tags.unit_number)
        if not entry then
            return
        end

        local player = game.players[event.player_index]
        local missing = Inhabitants.try_manual_upgrade(entry, player)
        if missing then
            player.create_local_flying_text {text = missing, create_at_cursor = true}
            return
        end

        Gui.DetailsView.update_for_entry(entry)
    end
)

Gui.set_click_handler(
    "set_target_comfort",
    function(event)
        local tags = event.element.tags
        local entry = Register.try_get(tags.unit_number)
        if not entry then
            return
        end

        local house_details = Housing.get(entry)
        local current = entry[EK.current_comfort] or 0
        local target = entry[EK.target_comfort] or current
        local new_target = math.max(current, math.min(house_details.max_comfort, target + tags.delta))

        if new_target == target then
            return
        end

        entry[EK.target_comfort] = new_target

        Gui.DetailsView.update_for_entry(entry)
    end
)

Gui.set_click_handler(
    "add_trait_tag",
    function(event)
        local tags = event.element.tags
        local entry = Register.try_get(tags.unit_number)
        if not entry then return end

        local player = game.players[event.player_index]
        local missing = Inhabitants.try_manual_add_tag(entry, player, tags.tag)
        if missing then
            player.create_local_flying_text {text = missing, create_at_cursor = true}
            return
        end

        Gui.DetailsView.update_for_entry(entry)
    end
)

Gui.set_click_handler(
    "toggle_request_trait_tag",
    function(event)
        local tags = event.element.tags
        local entry = Register.try_get(tags.unit_number)
        if not entry then return end

        local tag = tags.tag
        if (entry[EK.target_tags] or {})[tag] then
            Inhabitants.cancel_target_tag(entry, tag)
        else
            Inhabitants.try_request_tag(entry, tag)
        end
        Gui.DetailsView.update_for_entry(entry)
    end
)

local function update_tag_section(section_flow, entry, tag)
    local is_locked = not Housing.is_tag_unlocked(tag)

    if is_locked then
        section_flow.visible = false
        return
    end

    section_flow.visible = true

    local active_tags = entry[EK.trait_upgrades] or {}
    local is_applied = active_tags[tag] ~= nil
    local is_targeted = not is_applied and (entry[EK.target_tags] or {})[tag] ~= nil
    local btn = section_flow["tag-button"]
    local request_btn = section_flow["request-button"]
    local progress_flow = section_flow["item-progress-flow"]

    if is_applied then
        btn.caption = {"sosciencity.tag-applied", Locale.housing_trait(tag)}
        btn.enabled = false
        btn.tooltip = ""
        request_btn.visible = false
        progress_flow.visible = false
    else
        btn.caption = {"sosciencity.add-tag", Locale.housing_trait(tag)}
        btn.enabled = true
        btn.tooltip = ""
        request_btn.visible = true
        request_btn.caption = is_targeted
            and {"sosciencity.cancel-tag-request", Locale.housing_trait(tag)}
            or  {"sosciencity.request-tag", Locale.housing_trait(tag)}
        progress_flow.visible = true
        progress_flow.clear()
        local progress = Inhabitants.get_tag_progress(entry, tag)
        if progress then
            for _, p in pairs(progress) do
                progress_flow.add {
                    type = "label",
                    caption = {"sosciencity.upgrade-item-progress",
                        format("[item=%s]", p.name), p.in_chest, p.required},
                    elem_tooltip = {type = "item", name = p.name}
                }
            end
        end
    end
end

local function add_tag_section(parent_flow, entry, tag)
    local section_flow = parent_flow.add {
        type = "flow",
        name = "tag-section-" .. tag,
        direction = "vertical"
    }
    section_flow.style.vertical_spacing = 4

    local unit_number = entry[EK.unit_number]
    section_flow.add {
        type = "button",
        name = "tag-button",
        style = "sosciencity_heading_2_button",
        mouse_button_filter = {"left"},
        tags = {sosciencity_gui_event = "add_trait_tag", unit_number = unit_number, tag = tag}
    }
    section_flow.add {
        type = "button",
        name = "request-button",
        style = "sosciencity_heading_3_button",
        mouse_button_filter = {"left"},
        tags = {sosciencity_gui_event = "toggle_request_trait_tag", unit_number = unit_number, tag = tag}
    }
    section_flow.add {type = "flow", name = "item-progress-flow", direction = "horizontal"}

    update_tag_section(section_flow, entry, tag)
end

local function add_tag_sections(parent_flow, entry)
    for _, tag in pairs(upgradeable_tags) do
        add_tag_section(parent_flow, entry, tag)
    end
end

local function update_tag_sections(parent_flow, entry)
    for _, tag in pairs(upgradeable_tags) do
        local section = parent_flow["tag-section-" .. tag]
        if section then
            update_tag_section(section, entry, tag)
        end
    end
end

local function update_upgrade_section(flow, entry, house_details)
    local current = entry[EK.current_comfort] or 0
    local target = entry[EK.target_comfort] or current
    local max_comfort = house_details.max_comfort
    local at_max = current >= max_comfort

    flow["upgrade-button"].visible = not at_max
    flow["upgrade-maxed-label"].visible = at_max
    flow["item-progress-flow"].visible = not at_max
    flow["automation-flow"].visible = not at_max

    if at_max then
        return
    end

    local next_level = current + 1
    local is_locked = not Housing.is_level_unlocked(next_level)
    local upgrade_btn = flow["upgrade-button"]
    upgrade_btn.caption = {"sosciencity.upgrade-comfort", current, next_level}
    upgrade_btn.enabled = not is_locked
    upgrade_btn.tooltip = is_locked and {"sosciencity.upgrade-comfort-locked", Locale.prototype_name(Housing.required_tech[next_level], "technology")} or ""

    -- update per-item progress labels
    local progress_flow = flow["item-progress-flow"]
    progress_flow.clear()
    local progress = Inhabitants.get_upgrade_progress(entry)
    if progress then
        for _, p in pairs(progress) do
            progress_flow.add {
                type = "label",
                caption = {"sosciencity.upgrade-item-progress",
                    format("[item=%s]", p.name), p.in_chest, p.required},
                elem_tooltip = {type = "item", name = p.name}
            }
        end
    end

    -- update automation row
    Gui.Elements.IntStepper.update(flow["automation-flow"]["stepper"], target, current, max_comfort)
end

local function add_upgrade_section(flow, entry, house_details)
    local upgrade_flow = flow.add {type = "flow", name = "upgrade-section", direction = "vertical"}
    upgrade_flow.style.vertical_spacing = 4

    local unit_number = entry[EK.unit_number]

    upgrade_flow.add {
        type = "button",
        name = "upgrade-button",
        style = "sosciencity_heading_2_button",
        mouse_button_filter = {"left"},
        tags = {sosciencity_gui_event = "upgrade_house", unit_number = unit_number}
    }
    upgrade_flow.add {
        type = "label",
        name = "upgrade-maxed-label",
        caption = {"sosciencity.upgrade-comfort-maxed", house_details.max_comfort}
    }

    -- per-item delivery progress
    upgrade_flow.add {type = "flow", name = "item-progress-flow", direction = "horizontal"}

    -- automation target row
    local auto_flow = upgrade_flow.add {type = "flow", name = "automation-flow", direction = "horizontal"}
    auto_flow.style.vertical_align = "center"
    auto_flow.add {type = "label", caption = {"sosciencity.auto-deliver-target"}}
    Gui.Elements.IntStepper.create(auto_flow, "stepper", {
        event_tag = "set_target_comfort",
        extra_tags = {unit_number = unit_number},
        value = 0,
        min = 0,
        max = 0
    })

    update_upgrade_section(upgrade_flow, entry, house_details)
end

local function fill_traits_flow(traits_flow, housing_details, caste, trait_upgrades)
    traits_flow.clear()
    local preferences = caste and caste.housing_preferences
    for _, trait in pairs(housing_details.traits) do
        local assessment = preferences and preferences[trait]
        local caption = assessment and {"", Locale.housing_trait(trait), format(" (%+.1f)", assessment)} or Locale.housing_trait(trait)
        local label = traits_flow.add {
            type = "label",
            name = tostring(trait),
            caption = caption,
            tooltip = Locale.housing_trait_description(trait)
        }
        if assessment then
            label.style.font_color = assessment > 0 and Color.green or Color.red
        end
    end
    if trait_upgrades then
        for tag in pairs(trait_upgrades) do
            local assessment = preferences and preferences[tag]
            local caption = assessment and {"", Locale.housing_trait(tag), format(" (%+.1f)", assessment)} or Locale.housing_trait(tag)
            local label = traits_flow.add {
                type = "label",
                name = tostring(tag),
                caption = caption,
                tooltip = Locale.housing_trait_description(tag)
            }
            if assessment then
                label.style.font_color = assessment > 0 and Color.green or Color.red
            end
        end
    end
end

local function add_empty_house_info_tab(tabbed_pane, entry, house_details)
    local flow = Gui.Elements.Tabs.create(tabbed_pane, "house-info", {"sosciencity.building-info"})

    local data_list = Datalist.create(flow, "house-infos")
    Datalist.add_kv_pair(data_list, "room_count", {"sosciencity.room-count"}, house_details.room_count)
    Datalist.add_kv_pair(
        data_list,
        "comfort",
        {"sosciencity.comfort"},
        {"sosciencity.show-comfort", entry[EK.current_comfort] or 0, house_details.max_comfort}
    )

    local traits_flow = Datalist.add_kv_flow(data_list, "traits", {"sosciencity.traits"})
    fill_traits_flow(traits_flow, house_details, nil, entry[EK.trait_upgrades])

    Gui.Elements.Utils.separator_line(flow)
    add_upgrade_section(flow, entry, house_details)
    add_tag_sections(flow, entry)
end

local function update_empty_housing_details(container, entry)
    local tabbed_pane = container.tabpane
    local house_details = Housing.get(entry)

    local caste_chooser_flow = Gui.Elements.Tabs.get_content(tabbed_pane, "caste-chooser")
    fill_caste_chooser(caste_chooser_flow, entry, house_details)

    local info_flow = Gui.Elements.Tabs.get_content(tabbed_pane, "house-info")
    local data_list = info_flow["house-infos"]
    Datalist.set_kv_pair_value(
        data_list,
        "comfort",
        {"sosciencity.show-comfort", entry[EK.current_comfort] or 0, house_details.max_comfort}
    )
    fill_traits_flow(Datalist.get_kv_value_element(data_list, "traits"), house_details, nil, entry[EK.trait_upgrades])
    update_upgrade_section(info_flow["upgrade-section"], entry, house_details)
    update_tag_sections(info_flow, entry)
end

local function create_empty_housing_details(container, entry)
    Gui.DetailsView.set_title(container, entry[EK.entity].localised_name)

    local tabbed_pane = Gui.DetailsView.get_or_create_tabbed_pane(container)

    local house_details = Housing.get(entry)
    add_caste_chooser_tab(tabbed_pane, entry, house_details)
    add_empty_house_info_tab(tabbed_pane, entry, house_details)
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

    local housing_details = Housing.get(entry)
    Datalist.set_kv_pair_value(
        general_list,
        "comfort",
        {"sosciencity.show-comfort", entry[EK.current_comfort] or 0, housing_details.max_comfort}
    )
    fill_traits_flow(Datalist.get_kv_value_element(general_list, "traits"), housing_details, caste, entry[EK.trait_upgrades])
    update_upgrade_section(flow["upgrade-section"], entry, housing_details)
    update_tag_sections(flow, entry)

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

    Datalist.add_kv_pair(general_list, "comfort", {"sosciencity.comfort"})

    local traits_flow = Datalist.add_kv_flow(general_list, "traits", {"sosciencity.traits"})
    fill_traits_flow(traits_flow, housing_details, caste, entry[EK.trait_upgrades])

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
    add_upgrade_section(flow, entry, housing_details)
    add_tag_sections(flow, entry)
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
            local saved_comfort = entry[EK.current_comfort]
            local saved_target = entry[EK.target_comfort]
            local saved_tags = entry[EK.trait_upgrades]
            local new_entry = Register.change_type(entry, Type.empty_house)
            new_entry[EK.current_comfort] = saved_comfort
            new_entry[EK.target_comfort] = saved_target
            new_entry[EK.trait_upgrades] = saved_tags
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

local function add_housing_debug_tab(tabbed_pane, entry, player_id)
    local DebugWidgets = Gui.DebugWidgets
    local NumericTextField = Gui.Elements.NumericTextField
    local unit_number = entry[EK.unit_number]

    local tab = Gui.Elements.Tabs.create(tabbed_pane, "debug", {"city-view.debug-tab"})
    local content = tab.add {type = "flow", direction = "vertical"}

    -- Add inhabitants
    local add_row = DebugWidgets.labelled(content, "city-view.debug-housing-add")
    local add_count = NumericTextField.create(add_row)
    add_count.text = "1"
    Gui.register_element(add_count, unit_number, "debug_add_count", player_id)
    add_row.add {
        type = "button", style = "red_button",
        caption = {"city-view.debug-housing-add-go"},
        tooltip = {"city-view.debug-housing-add-tooltip"},
        tags = {sosciencity_gui_event = "housing_debug_add"}
    }

    -- Remove inhabitants
    local remove_row = DebugWidgets.labelled(content, "city-view.debug-housing-remove")
    local remove_count = NumericTextField.create(remove_row)
    remove_count.text = "1"
    Gui.register_element(remove_count, unit_number, "debug_remove_count", player_id)
    remove_row.add {
        type = "button", style = "red_button",
        caption = {"city-view.debug-housing-remove-go"},
        tooltip = {"city-view.debug-housing-remove-tooltip"},
        tags = {sosciencity_gui_event = "housing_debug_remove"}
    }

    -- Set HHS
    local hhs_row = DebugWidgets.labelled(content, "city-view.debug-housing-set-hhs")
    local happy = NumericTextField.create(hhs_row)
    happy.text = tostring(entry[EK.happiness])
    Gui.register_element(happy, unit_number, "debug_hhs_happiness", player_id)
    local health = NumericTextField.create(hhs_row)
    health.text = tostring(entry[EK.health])
    Gui.register_element(health, unit_number, "debug_hhs_health", player_id)
    local sanity = NumericTextField.create(hhs_row)
    sanity.text = tostring(entry[EK.sanity])
    Gui.register_element(sanity, unit_number, "debug_hhs_sanity", player_id)
    hhs_row.add {
        type = "button", style = "red_button",
        caption = {"city-view.debug-housing-set-hhs-go"},
        tooltip = {"city-view.debug-housing-set-hhs-tooltip"},
        tags = {sosciencity_gui_event = "housing_debug_set_hhs"}
    }

    -- Infect
    Gui.Elements.Utils.separator_line(content)
    local infect_section = content.add {type = "flow", direction = "vertical"}
    infect_section.add {type = "label", caption = {"city-view.debug-housing-infect"}, style = "sosciencity_heading_3"}
    local infect_scope_dd, infect_target_dd = DebugWidgets.build_scope_picker(infect_section, unit_number, "debug_infect_target")
    Gui.register_element(infect_scope_dd, unit_number, "debug_infect_scope", player_id)
    Gui.register_element(infect_target_dd, unit_number, "debug_infect_target", player_id)
    local infect_count_row = DebugWidgets.labelled(infect_section, "city-view.debug-infect-count")
    local infect_count = NumericTextField.create(infect_count_row)
    infect_count.text = "1"
    Gui.register_element(infect_count, unit_number, "debug_infect_count", player_id)
    infect_section.add {
        type = "button", style = "red_button",
        caption = {"city-view.debug-housing-infect-go"},
        tooltip = {"city-view.debug-housing-infect-tooltip"},
        tags = {sosciencity_gui_event = "housing_debug_infect"}
    }

    -- Cure
    Gui.Elements.Utils.separator_line(content)
    local cure_section = content.add {type = "flow", direction = "vertical"}
    cure_section.add {type = "label", caption = {"city-view.debug-housing-cure"}, style = "sosciencity_heading_3"}
    local cure_scope_dd, cure_target_dd = DebugWidgets.build_scope_picker(cure_section, unit_number, "debug_cure_target")
    Gui.register_element(cure_scope_dd, unit_number, "debug_cure_scope", player_id)
    Gui.register_element(cure_target_dd, unit_number, "debug_cure_target", player_id)
    local cure_count_row = DebugWidgets.labelled(cure_section, "city-view.debug-infect-count")
    local cure_count = NumericTextField.create(cure_count_row)
    cure_count.text = "1"
    Gui.register_element(cure_count, unit_number, "debug_cure_count", player_id)
    cure_section.add {
        type = "button", style = "red_button",
        caption = {"city-view.debug-housing-cure-go"},
        tooltip = {"city-view.debug-housing-cure-tooltip"},
        tags = {sosciencity_gui_event = "housing_debug_cure"}
    }

    -- Blood donation + garbage
    Gui.Elements.Utils.separator_line(content)
    content.add {
        type = "button", style = "red_button",
        caption = {"city-view.debug-housing-blood-donation-go"},
        tooltip = {"city-view.debug-housing-blood-donation-tooltip"},
        tags = {sosciencity_gui_event = "housing_debug_blood_donation"}
    }
    content.add {
        type = "button", style = "red_button",
        caption = {"city-view.debug-housing-garbage-go"},
        tooltip = {"city-view.debug-housing-garbage-tooltip"},
        tags = {sosciencity_gui_event = "housing_debug_garbage"}
    }
end

local function create_housing_details(container, entry, player_id)
    local title = {"", entry[EK.entity].localised_name, "  -  ", Locale.caste(entry[EK.type])}
    Gui.DetailsView.set_title(container, title)

    local tabbed_pane = Gui.DetailsView.get_or_create_tabbed_pane(container)

    local caste_id = entry[EK.type]
    add_housing_general_info_tab(tabbed_pane, entry, caste_id, player_id)
    add_housing_detailed_info_tab(tabbed_pane, entry)
    add_housing_diet_tab(tabbed_pane, entry, caste_id)

    if DEV_MODE then
        add_housing_debug_tab(tabbed_pane, entry, player_id)
    end
end

if DEV_MODE then
    local function read(entry, key, event)
        return tonumber(Gui.get_element(entry[EK.unit_number], key, event.player_index).text)
    end

    Gui.set_click_handler("housing_debug_add", function(event)
        local entry = Register.try_get(storage.details_view[event.player_index])
        if not entry then return end
        local count = read(entry, "debug_add_count", event)
        local player = game.players[event.player_index]
        if not count or count < 1 then
            player.print({"city-view.debug-invalid-count"})
            return
        end
        local group = InhabitantGroup.new(
            entry[EK.type], count,
            entry[EK.happiness], entry[EK.health], entry[EK.sanity]
        )
        local added = Inhabitants.try_add_to_house(entry, group, true)
        player.print({"city-view.debug-housing-add-done", added, count})
    end)

    Gui.set_click_handler("housing_debug_remove", function(event)
        local entry = Register.try_get(storage.details_view[event.player_index])
        if not entry then return end
        local count = read(entry, "debug_remove_count", event)
        local player = game.players[event.player_index]
        if not count or count < 1 then
            player.print({"city-view.debug-invalid-count"})
            return
        end
        local before = entry[EK.inhabitants]
        InhabitantGroup.take(entry, count)  -- discards taken group (vanish semantics)
        local removed = before - entry[EK.inhabitants]
        Inhabitants.update_free_space_status(entry)
        player.print({"city-view.debug-housing-remove-done", removed})
    end)

    Gui.set_click_handler("housing_debug_set_hhs", function(event)
        local entry = Register.try_get(storage.details_view[event.player_index])
        if not entry then return end
        local happiness = read(entry, "debug_hhs_happiness", event)
        local health = read(entry, "debug_hhs_health", event)
        local sanity = read(entry, "debug_hhs_sanity", event)
        local player = game.players[event.player_index]
        if not happiness or not health or not sanity then
            player.print({"city-view.debug-invalid-count"})
            return
        end
        entry[EK.happiness] = happiness
        entry[EK.health] = health
        entry[EK.sanity] = sanity
        player.print({"city-view.debug-housing-set-hhs-done"})
    end)

    Gui.set_click_handler("housing_debug_infect", function(event)
        local entry = Register.try_get(storage.details_view[event.player_index])
        if not entry then return end
        local player = game.players[event.player_index]
        local scope_idx = Gui.get_element(entry[EK.unit_number], "debug_infect_scope", event.player_index).selected_index
        local target_idx = Gui.get_element(entry[EK.unit_number], "debug_infect_target", event.player_index).selected_index
        local count = read(entry, "debug_infect_count", event)
        if not count or count < 1 then
            player.print({"city-view.debug-invalid-count"})
            return
        end
        local sickened = Gui.DebugWidgets.apply_infection_to_entry(entry[EK.diseases], count, scope_idx, target_idx)
        player.print({"city-view.debug-housing-infect-done", sickened, count})
    end)

    Gui.set_click_handler("housing_debug_cure", function(event)
        local entry = Register.try_get(storage.details_view[event.player_index])
        if not entry then return end
        local player = game.players[event.player_index]
        local scope_idx = Gui.get_element(entry[EK.unit_number], "debug_cure_scope", event.player_index).selected_index
        local target_idx = Gui.get_element(entry[EK.unit_number], "debug_cure_target", event.player_index).selected_index
        local count = read(entry, "debug_cure_count", event)
        if not count or count < 1 then
            player.print({"city-view.debug-invalid-count"})
            return
        end
        local cured = Gui.DebugWidgets.apply_cure_to_entry(entry, count, scope_idx, target_idx)
        player.print({"city-view.debug-housing-cure-done", cured, count})
    end)

    Gui.set_click_handler("housing_debug_blood_donation", function(event)
        local entry = Register.try_get(storage.details_view[event.player_index])
        if not entry then return end
        local player = game.players[event.player_index]
        local hospitals = Neighborhood.get_by_type(entry, Type.improvised_hospital)
        Tirislib.Arrays.merge(hospitals, Neighborhood.get_by_type(entry, Type.hospital))
        for _, hospital in pairs(hospitals) do
            if Entity.try_blood_donation(hospital, entry) then
                player.print({"city-view.debug-housing-blood-donation-done"})
                return
            end
        end
        player.print({"city-view.debug-housing-blood-donation-noop"})
    end)

    Gui.set_click_handler("housing_debug_garbage", function(event)
        local entry = Register.try_get(storage.details_view[event.player_index])
        if not entry then return end
        Inventories.produce_garbage(entry, "garbage", 1)
        game.players[event.player_index].print({"city-view.debug-housing-garbage-done"})
    end)
end

Gui.DetailsView.register_type(Type.empty_house, {
    creater = create_empty_housing_details,
    updater = update_empty_housing_details
})
for _, caste in pairs(Castes.all) do
    Gui.DetailsView.register_type(caste.type, {
        creater = create_housing_details,
        updater = update_housing_details
    })
end
