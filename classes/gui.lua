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

local Biology = require("constants.biology")
local Buildings = require("constants.buildings")
local Castes = require("constants.castes")
local Color = require("constants.color")
local Diseases = require("constants.diseases")
local Food = require("constants.food")
local Housing = require("constants.housing")
local ItemConstants = require("constants.item-constants")
local Time = require("constants.time")
local TypeGroup = require("constants.type-groups")
local Types = require("constants.types")
local WeatherLocales = require("constants.weather-locales")

--- Static class for all the gui stuff.
Gui = {}

--[[
    Data this class stores in global
    --------------------------------
    global.details_view: table
        [player_id]: unit_number (of the entity whose details are watched by the player)
]]
-- local often used globals for microscopic performance gains

local castes = Castes.values
local diseases = Diseases.values
local global
local immigration
local population
local caste_points
local Entity = Entity
local Register = Register
local Inhabitants = Inhabitants
local get_building_details = Buildings.get
local type_definitions = Types.definitions

local ceil = math.ceil
local floor = math.floor
local format = string.format
local round = Tirislib_Utils.round
local tostring = tostring

local Luaq_from = Tirislib_Luaq.from

local display_enumeration = Tirislib_Locales.create_enumeration
local display_percentage = Tirislib_Locales.display_percentage
local display_item_stack = Tirislib_Locales.display_item_stack
local display_time = Tirislib_Locales.display_time

local climate_locales = WeatherLocales.climate
local humidity_locales = WeatherLocales.humidity
local weather_locales = WeatherLocales.weather

---------------------------------------------------------------------------------------------------
-- << lua state lifecycle stuff >>

local function set_locals()
    global = _ENV.global
    immigration = global.immigration
    population = global.population
    caste_points = global.caste_points
end

--- Initialize the guis for all existing players.
function Gui.init()
    set_locals()
    global.details_view = {}

    for _, player in pairs(game.players) do
        Gui.create_guis_for_player(player)
    end
end

function Gui.load()
    set_locals()
end

---------------------------------------------------------------------------------------------------
-- << formatting functions >>
---------------------------------------------------------------------------------------------------

local function get_caste_bonus(caste_id)
    local bonus = global.caste_bonuses[caste_id]
    return floor(bonus)
end

local function get_reasonable_number(number)
    return format("%.1f", number)
end

local function display_integer_summand(number)
    if number > 0 then
        return format("[color=0,1,0]%+d[/color]", number)
    elseif number < 0 then
        return format("[color=1,0,0]%+d[/color]", number)
    else -- number equals 0
        return "[color=0.8,0.8,0.8]0[/color]"
    end
end

local function display_summand(number)
    if number > 0 then
        return format("[color=0,1,0]%+.1f[/color]", number)
    elseif number < 0 then
        return format("[color=1,0,0]%+.1f[/color]", number)
    else -- number equals 0
        return "[color=0.8,0.8,0.8]0.0[/color]"
    end
end

local function display_factor(number)
    if number > 1 then
        return format("[color=0,1,0]×%.1f[/color]", number)
    elseif number < 1 then
        return format("[color=1,0,0]×%.1f[/color]", number)
    else -- number equals 1
        return "[color=0.8,0.8,0.8]1.0[/color]"
    end
end

local function display_comfort(comfort)
    return {"", comfort, "  -  ", {"comfort-scale." .. comfort}}
end

local function display_caste(caste_id, short)
    if short then
        return {format("caste-short.%s", castes[caste_id].name)}
    else
        return {format("caste-name.%s", castes[caste_id].name)}
    end
end

local function get_migration_string(number)
    return format("%+.1f", number)
end

local function get_entry_representation(entry)
    local entity = entry[EK.entity]
    local position = entity.position
    return {"sosciencity.entry-representation", entity.localised_name, position.x, position.y}
end

local function display_convergence(current, target)
    return {"sosciencity.convergenting-value", get_reasonable_number(current), get_reasonable_number(target)}
end

local mult = " × "
local function display_materials(materials)
    local ret = {""}
    local first = true
    local item_prototypes = game.item_prototypes

    for material, count in pairs(materials) do
        local entry = {""}

        if not first then
            entry[#entry + 1] = "\n"
        end
        first = false

        entry[#entry + 1] = count
        entry[#entry + 1] = mult

        entry[#entry + 1] = format("[item=%s] ", material)
        entry[#entry + 1] = item_prototypes[material].localised_name

        ret[#ret + 1] = entry
    end

    return ret
end

---------------------------------------------------------------------------------------------------
-- << style functions >>
---------------------------------------------------------------------------------------------------

local function set_padding(element, padding)
    local style = element.style
    style.left_padding = padding
    style.right_padding = padding
    style.top_padding = padding
    style.bottom_padding = padding
end

local function make_stretchable(element)
    element.style.horizontally_stretchable = true
    element.style.vertically_stretchable = true
end

local function make_squashable(element)
    element.style.horizontally_squashable = true
    element.style.vertically_squashable = true
end

---------------------------------------------------------------------------------------------------
-- << handlers >>
---------------------------------------------------------------------------------------------------

--- Lookup for click event handlers.
--- [element name]: table
---     [1]: function
---     [2]: array of arguments
local click_lookup = {}

--- Sets the 'on_gui_click' event handler for a gui element with the given name. Additional arguments for the call can be specified.
--- @param name string
--- @param fn function
local function set_click_handler(name, fn, ...)
    Tirislib_Utils.desync_protection()
    click_lookup[name] = {fn, {...}}
end

local checkbox_click_lookup = {}

--- Sets the 'on_gui_checked_state_changed' event handler for a gui element with the given name. Additional arguments for the call can be specified.
--- @param name string
--- @param fn function
local function set_checked_state_handler(name, fn, ...)
    Tirislib_Utils.desync_protection()
    checkbox_click_lookup[name] = {fn, {...}}
end

--- This should be added to every gui element which needs an event handler,
--- because the gui event handlers get fired for every gui in existance.
--- So I need to ensure that I'm not reacting to another mods gui.
local unique_prefix_builder = "sosciencity-%s-%s"

--- Generic handler that verifies that the gui element belongs to my mod, looks for an event handler function and calls it.
local function look_for_event_handler(event, lookup)
    local gui_element = event.element
    local name = gui_element.name

    local handler = lookup[name]

    if handler then
        local player_id = event.player_index
        local entry = Register.try_get(global.details_view[player_id])

        handler[1](entry, gui_element, unpack(handler[2]))
    end
end

--- Event handler for Gui click events
function Gui.on_gui_click(event)
    look_for_event_handler(event, click_lookup)
end

--- Event handler for checkbox/radiobuttom click events
function Gui.on_gui_checked_state_changed(event)
    look_for_event_handler(event, checkbox_click_lookup)
end

local function generic_radiobutton_handler(entry, element, mode, key, updater)
    if mode then
        entry[key] = mode
        updater(entry, element.parent)
    end
end

local function generic_checkbox_handler(entry, element, key)
    entry[key] = element.state
end

---------------------------------------------------------------------------------------------------
-- << gui elements >>
---------------------------------------------------------------------------------------------------

local DATA_LIST_DEFAULT_NAME = "datalist"
local function create_data_list(container, name, columns)
    local datatable =
        container.add {
        type = "table",
        name = name or DATA_LIST_DEFAULT_NAME,
        column_count = columns or 2,
        style = "bordered_table"
    }
    local style = datatable.style
    style.horizontally_stretchable = true
    style.right_cell_padding = 6
    style.left_cell_padding = 6

    return datatable
end

local function add_key_label(data_list, key, key_caption, key_font)
    local key_label =
        data_list.add {
        type = "label",
        name = "key-" .. key,
        caption = key_caption
    }
    key_label.style.font = key_font or "default-bold"
end

local function add_kv_pair(data_list, key, key_caption, value_caption, key_font, value_font)
    add_key_label(data_list, key, key_caption, key_font)

    local value_label =
        data_list.add {
        type = "label",
        name = key,
        caption = value_caption
    }
    local style = value_label.style
    style.horizontally_stretchable = true
    style.single_line = false

    if value_font then
        style.font = value_font
    end
end

local function add_kv_flow(data_list, key, key_caption, key_font, direction)
    add_key_label(data_list, key, key_caption, key_font)

    local value_flow =
        data_list.add {
        type = "flow",
        name = key,
        direction = direction or "vertical"
    }

    return value_flow
end

local function add_kv_checkbox(data_list, key, checkbox_name, key_caption, checkbox_caption, key_font, checkbox_font)
    local flow = add_kv_flow(data_list, key, key_caption, key_font, "horizontal")

    local checkbox =
        flow.add {
        type = "checkbox",
        name = checkbox_name,
        state = true
    }

    local label =
        flow.add {
        type = "label",
        name = "label",
        caption = checkbox_caption
    }
    local style = label.style
    style.left_padding = 6
    style.horizontally_stretchable = true

    if checkbox_font then
        style.font = checkbox_font
    end

    return checkbox, label
end

local function get_checkbox(data_list, key)
    local children = data_list[key].children
    return children[1], children[2]
end

local function get_kv_pair(data_list, key)
    return data_list["key-" .. key], data_list[key]
end

local function get_kv_value_element(data_list, key)
    return data_list[key]
end

local function set_key(data_list, key, key_caption)
    data_list["key-" .. key].caption = key_caption
end

local function set_kv_pair_value(data_list, key, value_caption)
    data_list[key].caption = value_caption
end

local function set_datalist_value_tooltip(datalist, key, tooltip)
    datalist[key].tooltip = tooltip
end

local function set_kv_pair_tooltip(datalist, key, tooltip)
    local key_element, value_element = get_kv_pair(datalist, key)
    key_element.tooltip = tooltip
    value_element.tooltip = tooltip
end

local function set_kv_pair_visibility(datalist, key, visibility)
    datalist["key-" .. key].visible = visibility
    datalist[key].visible = visibility
end

local function add_final_value_entry(data_list, caption)
    local sum_key =
        data_list.add {
        type = "label",
        name = "key-sum",
        caption = caption
    }
    local style = sum_key.style
    style.font = "default-bold"
    style.horizontally_stretchable = true

    local sum_value =
        data_list.add {
        type = "label",
        name = "sum"
    }
    style = sum_value.style
    style.width = 50
    style.font = "default-bold"
    style.horizontal_align = "right"
end

local function add_operand_entry(data_list, key, key_caption, value_caption, description)
    local key_label =
        data_list.add {
        type = "label",
        name = "key-" .. key,
        caption = key_caption,
        tooltip = description
    }
    local key_style = key_label.style
    key_style.horizontally_stretchable = true
    key_style.single_line = false

    local value_label =
        data_list.add {
        type = "label",
        name = key,
        caption = value_caption
    }
    local value_style = value_label.style
    value_style.horizontal_align = "right"
    value_style.width = 50
end

local function add_entries(data_list, enum_table, names, descriptions)
    for name, id in pairs(enum_table) do
        add_operand_entry(data_list, name, names[id], nil, descriptions[id])
    end
end

local function create_operand_entries(
    data_list,
    final_caption,
    summands_enums,
    summand_localised,
    summand_descriptions,
    factor_enums,
    factor_localised,
    factor_descriptions)
    add_final_value_entry(data_list, final_caption)
    add_entries(data_list, summands_enums, summand_localised, summand_descriptions)
    add_entries(data_list, factor_enums, factor_localised, factor_descriptions)
end

local function update_operand_entries(data_list, final_value, summands, summand_enums, factors, factor_enums)
    data_list["sum"].caption = display_summand(final_value)

    for name, id in pairs(summand_enums) do
        local value = summands[id]

        if value ~= 0 then
            set_kv_pair_value(data_list, name, display_summand(value))
            set_kv_pair_visibility(data_list, name, true)
        else
            set_kv_pair_visibility(data_list, name, false)
        end
    end

    for name, id in pairs(factor_enums) do
        local value = factors[id]

        if value ~= 1. then
            set_kv_pair_value(data_list, name, display_factor(value))
            set_kv_pair_visibility(data_list, name, true)
        else
            set_kv_pair_visibility(data_list, name, false)
        end
    end
end

local function is_confirmed(button)
    local caption = button.caption[1]
    if caption == "sosciencity.confirm" then
        return true
    else
        button.caption = {"sosciencity.confirm"}
        button.tooltip = {"sosciencity.confirm-tooltip"}
        return false
    end
end

local function create_caste_sprite(container, caste_id, size)
    local caste_name = castes[caste_id].name

    local sprite =
        container.add {
        type = "sprite",
        name = "caste-sprite",
        sprite = "technology/" .. caste_name .. "-caste",
        tooltip = {"caste-name." .. caste_name}
    }
    local style = sprite.style
    style.height = size
    style.width = size
    style.stretch_image_to_widget_size = true

    return sprite
end

local function create_tab(tabbed_pane, name, caption)
    local tab =
        tabbed_pane.add {
        type = "tab",
        name = name .. "tab",
        caption = caption
    }
    local scrollpane =
        tabbed_pane.add {
        type = "scroll-pane",
        name = name
    }
    local flow =
        scrollpane.add {
        type = "flow",
        name = "flow",
        direction = "vertical"
    }
    make_stretchable(flow)

    tabbed_pane.add_tab(tab, scrollpane)

    return flow
end

local function get_tab_contents(tabbed_pane, name)
    return tabbed_pane[name].flow
end

local function get_unused_name(container, name)
    if not container[name] then
        return name
    end

    local i = 1
    while true do
        local possible_name = name .. i
        if not container[possible_name] then
            return possible_name
        end
        i = i + 1
    end
end

local function create_separator_line(container, name)
    return container.add {
        type = "line",
        name = get_unused_name(name or "line"),
        direction = "horizontal"
    }
end

local function add_header_label(container, name, caption)
    local flow =
        container.add {
        type = "flow",
        name = name,
        direction = "horizontal"
    }
    flow.style.horizontally_stretchable = true
    flow.style.horizontal_align = "center"

    local header =
        flow.add {
        type = "label",
        name = name,
        caption = caption
    }
    header.style.font = "default-bold"
end

---------------------------------------------------------------------------------------------------
-- << city info gui >>
---------------------------------------------------------------------------------------------------

local CITY_INFO_NAME = "sosciencity-city-info"
local CITY_INFO_SPRITE_SIZE = 48

local function update_population_flow(frame)
    local population_flow = frame["general"]

    population_flow["machine-count"].caption = {"sosciencity.machines", Register.get_machine_count()}

    population_flow["turret-count"].caption = {"sosciencity.turrets", Register.get_type_count(Type.turret)}

    local climate = global.current_climate
    local humidity = global.current_humidity
    local weather_label = population_flow.weather
    weather_label.caption = {"sosciencity.weather", weather_locales[humidity][climate]}
    weather_label.tooltip = {
        "sosciencity.explain-weather",
        climate_locales[climate],
        humidity_locales[humidity]
    }
end

local function add_population_flow(container)
    local frame =
        container.add {
        type = "frame",
        name = "general",
        direction = "vertical"
    }
    set_padding(frame, 2)

    local machines =
        frame.add {
        type = "label",
        name = "machine-count"
    }
    machines.style.bottom_margin = 4

    local turrets =
        frame.add {
        type = "label",
        name = "turret-count"
    }
    turrets.style.bottom_margin = 4

    frame.add {
        type = "label",
        name = "weather"
    }

    update_population_flow(container)
end

local function add_caste_flow(container, caste_id)
    local caste_name = castes[caste_id].name

    local frame =
        container.add {
        type = "frame",
        name = "caste-" .. caste_id,
        direction = "vertical"
    }
    --make_stretchable(frame)
    frame.style.padding = 0
    frame.style.left_margin = 4

    frame.visible = Inhabitants.caste_is_researched(caste_id)

    local flow =
        frame.add {
        type = "flow",
        name = "flow",
        direction = "vertical"
    }
    --make_stretchable(flow)
    flow.style.vertical_spacing = 0
    flow.style.horizontal_align = "center"

    local sprite = create_caste_sprite(flow, caste_id, CITY_INFO_SPRITE_SIZE)
    sprite.style.horizontal_align = "center"

    flow.add {
        type = "label",
        name = "caste-population",
        caption = global.population[caste_id],
        tooltip = {"sosciencity.caste-points", get_reasonable_number(caste_points[caste_id])}
    }

    local caste_bonus = get_caste_bonus(caste_id)
    flow.add {
        type = "label",
        name = "caste-bonus",
        caption = {"caste-bonus.show-" .. caste_name, display_integer_summand(caste_bonus)},
        tooltip = {"caste-bonus." .. caste_name}
    }
end

local function update_caste_flow(container, caste_id)
    local caste_frame = container["caste-" .. caste_id]

    -- Always show the clockwork caste, so the player has a chance to understand the maintenance mechanic.
    caste_frame.visible = (caste_id == Type.clockwork) or Inhabitants.caste_is_researched(caste_id)

    -- the frame may not yet exist
    if caste_frame == nil then
        add_caste_flow(container, caste_id)
        return
    end

    local flow = caste_frame.flow

    local population_label = flow["caste-population"]
    population_label.caption = population[caste_id]
    population_label.tooltip = {
        "sosciencity.caste-points",
        get_reasonable_number(caste_points[caste_id])
    }

    local caste_bonus = get_caste_bonus(caste_id)
    flow["caste-bonus"].caption = {
        "caste-bonus.show-" .. castes[caste_id].name,
        display_integer_summand(caste_bonus)
    }
end

local function create_city_info_for_player(player)
    local frame = player.gui.top[CITY_INFO_NAME]
    if frame and frame.valid then
        return -- the gui was already created and is still valid
    end

    frame =
        player.gui.top.add {
        type = "flow",
        name = CITY_INFO_NAME,
        direction = "horizontal"
    }
    make_stretchable(frame)

    add_population_flow(frame)

    for id, _ in pairs(castes) do
        add_caste_flow(frame, id)
    end
end

local function update_city_info(frame)
    update_population_flow(frame)

    for id, _ in pairs(castes) do
        update_caste_flow(frame, id)
    end
end

--- Updates the city info gui for all existing players.
function Gui.update_city_info()
    for _, player in pairs(game.players) do
        local city_info_gui = player.gui.top[CITY_INFO_NAME]

        -- we check if the gui still exists, as other mods can delete them
        if city_info_gui ~= nil and city_info_gui.valid then
            update_city_info(city_info_gui)
        else
            create_city_info_for_player(player)
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << entity details view >>
---------------------------------------------------------------------------------------------------

local DETAILS_VIEW_NAME = "sosciencity-details"

local function set_details_view_title(container, caption)
    container.parent.caption = caption
end

local function get_or_create_tabbed_pane(container)
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

---------------------------------------------------------------------------------------------------
-- << empty houses >>

local function add_caste_chooser_tab(tabbed_pane, details)
    local flow = create_tab(tabbed_pane, "caste-chooser", {"sosciencity.caste"})

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
                name = format(unique_prefix_builder, "assign-caste", caste_name),
                caption = {"caste-name." .. caste_name},
                tooltip = {"sosciencity.move-in", caste_name},
                mouse_button_filter = {"left"}
            }
            button.style.width = 150

            if Housing.allowes_caste(details, caste_id) then
                button.tooltip = {"sosciencity.move-in", caste_name}
            elseif castes[caste_id].required_room_count > details.room_count then
                button.tooltip = {"sosciencity.not-enough-room"}
            else
                button.tooltip = {"sosciencity.not-enough-comfort"}
            end
            button.enabled = Housing.allowes_caste(details, caste_id)
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
local function caste_assignment_button_handler(entry, element, caste_id)
    Inhabitants.try_allow_for_caste(entry, caste_id, true)
end

for id, caste in pairs(castes) do
    set_click_handler(format(unique_prefix_builder, "assign-caste", caste.name), caste_assignment_button_handler, id)
end

local function add_empty_house_info_tab(tabbed_pane, house_details)
    local flow = create_tab(tabbed_pane, "house-info", {"sosciencity.building-info"})

    local data_list = create_data_list(flow, "house-infos")
    add_kv_pair(data_list, "room_count", {"sosciencity.room-count"}, house_details.room_count)
    add_kv_pair(data_list, "comfort", {"sosciencity.comfort"}, display_comfort(house_details.comfort))

    local qualities_flow = add_kv_flow(data_list, "qualities", {"sosciencity.qualities"})
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

    add_operand_entry(
        occupations_list,
        "unoccupied",
        {"sosciencity.unemployed"},
        Inhabitants.get_employable_count(entry)
    )
    set_kv_pair_tooltip(occupations_list, "unoccupied", {"sosciencity.explain-unemployed"})

    local employments = entry[EK.employments]
    for building_number, count in pairs(employments) do
        local building = Register.try_get(building_number)
        if building then
            add_operand_entry(
                occupations_list,
                building_number,
                {"sosciencity.employed", get_entry_representation(building)},
                count
            )
        end
    end

    local disease_group = entry[EK.diseases]
    for disease_id, count in pairs(disease_group) do
        if disease_id ~= DiseaseGroup.HEALTHY then
            local disease = diseases[disease_id]
            local key = format("disease-%d", disease_id)
            add_operand_entry(occupations_list, key, {"sosciencity.ill", disease.localised_name}, count)
            set_kv_pair_tooltip(occupations_list, key, disease.localised_description)
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
        add_operand_entry(ages_list, age, {"sosciencity.show-age", age}, count)
    end

    local visible = (entry[EK.inhabitants] > 0)
    ages_list.visible = visible
    flow["header-ages"].visible = visible
end

local function update_genders_list(flow, entry)
    local genders_list = flow.genders

    genders_list.clear()
    for gender, count in pairs(entry[EK.genders]) do
        add_operand_entry(genders_list, gender, {"sosciencity.gender-" .. gender}, count)
    end

    local visible = (entry[EK.inhabitants] > 0)
    genders_list.visible = visible
    flow["header-genders"].visible = visible
end

local function update_housing_general_info_tab(tabbed_pane, entry)
    local flow = get_tab_contents(tabbed_pane, "general")
    local general_list = flow["general-infos"]

    local caste = castes[entry[EK.type]]
    local inhabitants = entry[EK.inhabitants]
    local nominal_happiness = Inhabitants.get_nominal_happiness(entry)

    local capacity = Housing.get_capacity(entry)
    local emigration = Inhabitants.get_emigration_trend(nominal_happiness, caste, Time.minute)
    local display_emigration = inhabitants > 0 and emigration < 0

    set_kv_pair_value(
        general_list,
        "inhabitants",
        {
            "",
            {"sosciencity.show-inhabitants", inhabitants, capacity},
            display_emigration and {"sosciencity.migration", get_migration_string(emigration)} or ""
        }
    )
    set_datalist_value_tooltip(
        general_list,
        "inhabitants",
        (entry[EK.emigration_trend] > 0) and {"sosciencity.positive-trend"} or {"sosciencity.negative-trend"}
    )

    -- the annoying edge case of no inhabitants inside the house
    if inhabitants == 0 then
        set_kv_pair_value(general_list, "happiness", "-")
        set_kv_pair_value(general_list, "health", "-")
        set_kv_pair_value(general_list, "sanity", "-")
        set_kv_pair_value(general_list, "calorific-demand", "-")
        set_kv_pair_value(general_list, "water-demand", "-")
        set_kv_pair_value(general_list, "power-demand", "-")
        set_kv_pair_value(general_list, "garbage", "-")
        set_kv_pair_value(general_list, "bonus", "-")
        set_kv_pair_value(general_list, "employed-count", "-")
        set_kv_pair_value(general_list, "diseased-count", "-")
        set_kv_pair_visibility(general_list, "disease-rate", false)
        return
    end

    set_kv_pair_value(
        general_list,
        "happiness",
        display_convergence(entry[EK.happiness], Inhabitants.get_nominal_happiness(entry))
    )
    set_kv_pair_value(
        general_list,
        "health",
        display_convergence(entry[EK.health], Inhabitants.get_nominal_health(entry))
    )
    set_kv_pair_value(
        general_list,
        "sanity",
        display_convergence(entry[EK.sanity], Inhabitants.get_nominal_sanity(entry))
    )
    set_kv_pair_value(
        general_list,
        "calorific-demand",
        {
            "sosciencity.show-calorific-demand",
            floor(caste.calorific_demand * Time.minute * inhabitants)
        }
    )
    set_kv_pair_value(
        general_list,
        "water-demand",
        {"sosciencity.show-water-demand", floor(caste.water_demand * Time.minute * inhabitants)}
    )
    set_kv_pair_value(
        general_list,
        "power-demand",
        {"sosciencity.current-power-demand", floor(caste.power_demand / 1000 * Time.second * inhabitants)}
    )
    set_kv_pair_value(
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
    set_kv_pair_value(
        general_list,
        "bonus",
        {
            "sosciencity.show-bonus",
            unemployed,
            get_reasonable_number(entry[EK.caste_points]),
            global.technologies[caste.effectivity_tech]
        }
    )
    local employed = entry[EK.employed]
    local diseased = inhabitants - unemployed - employed
    set_kv_pair_value(general_list, "employed-count", {"sosciencity.show-employed-count", employed})
    set_kv_pair_value(general_list, "diseased-count", {"sosciencity.show-diseased-count", diseased})

    set_kv_pair_visibility(general_list, "disease-rate", true)
    local disease_progress_flow = get_kv_value_element(general_list, "disease-rate")
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
    local flow = create_tab(tabbed_pane, "general", {"sosciencity.general"})

    flow.style.vertical_spacing = 6
    flow.style.horizontal_align = "right"

    local general_list = create_data_list(flow, "general-infos")
    add_kv_pair(general_list, "caste", {"sosciencity.caste"}, display_caste(entry[EK.type]))

    add_kv_pair(general_list, "inhabitants", {"sosciencity.inhabitants"})
    add_kv_pair(general_list, "happiness", {"sosciencity.happiness"})
    add_kv_pair(general_list, "health", {"sosciencity.health"})
    add_kv_pair(general_list, "sanity", {"sosciencity.sanity"})
    add_kv_pair(general_list, "calorific-demand", {"sosciencity.calorific-demand"})
    add_kv_pair(general_list, "water-demand", {"sosciencity.water-demand"})
    add_kv_pair(general_list, "power-demand", {"sosciencity.power-demand"})
    add_kv_pair(general_list, "garbage", {"sosciencity.garbage"})
    add_kv_pair(general_list, "bonus", {"sosciencity.bonus"})
    add_kv_pair(general_list, "employed-count", {"sosciencity.employed-count"})
    add_kv_pair(general_list, "diseased-count", {"sosciencity.diseased-count"})

    local disease_progress_flow = add_kv_flow(general_list, "disease-rate")
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

    local qualities_flow = add_kv_flow(general_list, "qualities", {"sosciencity.qualities"})
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

    create_separator_line(flow)

    local kickout_button =
        flow.add {
        type = "button",
        name = format(unique_prefix_builder, "kickout", ""),
        caption = {"sosciencity.kickout"},
        tooltip = {"sosciencity.with-resettlement"},
        mouse_button_filter = {"left"}
    }
    kickout_button.style.right_margin = 4

    -- call the update function to set the values
    update_housing_general_info_tab(tabbed_pane, entry)
end

-- Event handler function for clicks on the kickout button.
set_click_handler(
    format(unique_prefix_builder, "kickout", ""),
    function(entry, button)
        if is_confirmed(button) then
            Register.change_type(entry, Type.empty_house)
            Gui.rebuild_details_view_for_entry(entry)
            return
        end
    end
)

local function update_housing_detailed_info_tab(tabbed_pane, entry)
    local flow = get_tab_contents(tabbed_pane, "details")

    local happiness_list = flow["happiness"]
    update_operand_entries(
        happiness_list,
        Inhabitants.get_nominal_happiness(entry),
        entry[EK.happiness_summands],
        HappinessSummand,
        entry[EK.happiness_factors],
        HappinessFactor
    )

    local health_list = flow["health"]
    update_operand_entries(
        health_list,
        Inhabitants.get_nominal_health(entry),
        entry[EK.health_summands],
        HealthSummand,
        entry[EK.health_factors],
        HealthFactor
    )

    local sanity_list = flow["sanity"]
    update_operand_entries(
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
local localised_health_summand_descriptions = build_localised(HappinessSummand, "health-summand-description.%s")
local localised_health_factors = build_localised(HealthFactor, "health-factor.%s")
local localised_health_factor_descriptions = build_localised(HealthFactor, "health-factor-description.%s")
local localised_sanity_summands = build_localised(SanitySummand, "sanity-summand.%s")
local localised_sanity_summand_descriptions = build_localised(SanitySummand, "sanity-summand-description.%s")
local localised_sanity_factors = build_localised(SanityFactor, "sanity-factor.%s")
local localised_sanity_factor_descriptions = build_localised(SanityFactor, "sanity-factor-description.%s")

build_localised = nil

local function add_housing_detailed_info_tab(tabbed_pane, entry)
    local flow = create_tab(tabbed_pane, "details", {"sosciencity.details"})

    local happiness_list = create_data_list(flow, "happiness")
    create_operand_entries(
        happiness_list,
        {"sosciencity.happiness"},
        HappinessSummand,
        localised_happiness_summands,
        localised_happiness_summand_descriptions,
        HappinessFactor,
        localised_happiness_factors,
        localised_happiness_factor_descriptions
    )

    create_separator_line(flow)

    local health_list = create_data_list(flow, "health")
    create_operand_entries(
        health_list,
        {"sosciencity.health"},
        HealthSummand,
        localised_health_summands,
        localised_health_summand_descriptions,
        HealthFactor,
        localised_health_factors,
        localised_health_factor_descriptions
    )

    create_separator_line(flow, "line2")

    local sanity_list = create_data_list(flow, "sanity")
    create_operand_entries(
        sanity_list,
        {"sosciencity.sanity"},
        SanitySummand,
        localised_sanity_summands,
        localised_sanity_summand_descriptions,
        SanityFactor,
        localised_sanity_factors,
        localised_sanity_factor_descriptions
    )

    create_separator_line(flow)

    add_header_label(flow, "header-occupations", {"sosciencity.occupations"})
    create_data_list(flow, "occupations")

    create_separator_line(flow)

    add_header_label(flow, "header-ages", {"sosciencity.ages"})
    create_data_list(flow, "ages")

    create_separator_line(flow)

    add_header_label(flow, "header-genders", {"sosciencity.gender-distribution"})
    create_data_list(flow, "genders")

    -- call the update function to set the values
    update_housing_detailed_info_tab(tabbed_pane, entry)
end

local function add_caste_info_tab(tabbed_pane, caste_id)
    local caste = castes[caste_id]

    local flow = create_tab(tabbed_pane, "caste", {"caste-short." .. caste.name})
    flow.style.vertical_spacing = 6
    flow.style.horizontal_align = "center"

    create_caste_sprite(flow, caste_id, 128)

    local caste_data = create_data_list(flow, "caste-infos")
    add_kv_pair(caste_data, "caste-name", {"sosciencity.name"}, {"caste-name." .. caste.name})
    add_kv_pair(caste_data, "description", "", {"technology-description." .. caste.name .. "-caste"})
    add_kv_pair(
        caste_data,
        "taste",
        {"sosciencity.taste"},
        {
            "sosciencity.show-taste",
            Food.taste_names[caste.favored_taste],
            Food.taste_names[caste.least_favored_taste]
        }
    )
    add_kv_pair(
        caste_data,
        "food-count",
        {"sosciencity.food-count"},
        {"sosciencity.show-food-count", caste.minimum_food_count}
    )
    add_kv_pair(
        caste_data,
        "luxury",
        {"sosciencity.luxury"},
        {"sosciencity.show-luxury-needs", 100 * caste.desire_for_luxury, 100 * (1 - caste.desire_for_luxury)}
    )
    add_kv_pair(
        caste_data,
        "room-count",
        {"sosciencity.room-needs"},
        {"sosciencity.show-room-needs", caste.required_room_count}
    )
    add_kv_pair(
        caste_data,
        "comfort",
        {"sosciencity.comfort"},
        {"sosciencity.show-comfort-needs", caste.minimum_comfort}
    )
    add_kv_pair(
        caste_data,
        "power-demand",
        {"sosciencity.power-demand"},
        {"sosciencity.show-power-demand", caste.power_demand / 1000 * Time.second} -- convert from J / tick to kW
    )

    local prefered_flow = add_kv_flow(caste_data, "prefered-qualities", {"sosciencity.prefered-qualities"})
    local disliked_flow = add_kv_flow(caste_data, "disliked-qualities", {"sosciencity.disliked-qualities"})
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

local function update_housing_details(container, entry)
    local tabbed_pane = container.tabpane
    update_housing_general_info_tab(tabbed_pane, entry)
    update_housing_detailed_info_tab(tabbed_pane, entry)
end

local function create_housing_details(container, entry)
    local title = {"", entry[EK.entity].localised_name, "  -  ", display_caste(entry[EK.type])}
    set_details_view_title(container, title)

    local tabbed_pane = get_or_create_tabbed_pane(container)
    make_stretchable(tabbed_pane)

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
            add_operand_entry(list, unit_number, get_entry_representation(house), count)

            at_least_one = true
        end
    end

    if not at_least_one then
        add_operand_entry(list, "no-one", {"sosciencity.no-employees"}, "-")
    end
end

local function update_general_building_details(container, entry)
    local tabbed_pane = container.tabpane
    local tab = get_tab_contents(tabbed_pane, "general")
    local building_data = tab.building

    local active = entry[EK.active]
    if active ~= nil then
        set_kv_pair_value(building_data, "active", active and {"sosciencity.active"} or {"sosciencity.inactive"})
    end

    local worker_specification = get_building_details(entry).workforce
    if worker_specification then
        local count_needed = worker_specification.count
        set_kv_pair_value(building_data, "staff", {"sosciencity.show-staff", entry[EK.worker_count], count_needed})

        local staff_performance = Inhabitants.evaluate_workforce(entry)
        set_kv_pair_value(
            building_data,
            "staff-performance",
            staff_performance >= 0.2 and {"sosciencity.staff-performance", ceil(staff_performance * 100)} or
                {"sosciencity.not-enough-staff", ceil(0.2 * count_needed)}
        )

        local worker_data = tab.workers
        update_worker_list(worker_data, entry)
    end

    local performance = entry[EK.performance]
    if performance then
        set_kv_pair_value(
            building_data,
            "general-performance",
            performance >= 0.2 and {"sosciencity.percentage", ceil(performance * 100)} or {"sosciencity.not-working"}
        )
    end

    local type_details = type_definitions[entry[EK.type]]
    if type_details.affected_by_clockwork then
        local clockwork_value = get_caste_bonus(Type.clockwork)
        set_kv_pair_value(
            building_data,
            "maintenance",
            clockwork_value >= 0 and {"sosciencity.display-good-maintenance", clockwork_value} or
                {"sosciencity.display-bad-maintenance", clockwork_value}
        )
    end
end

local function create_general_building_details(container, entry)
    local entity = entry[EK.entity]
    set_details_view_title(container, entity.localised_name)

    local building_details = get_building_details(entry)
    local type_details = type_definitions[entry[EK.type]]

    local tabbed_pane = get_or_create_tabbed_pane(container)
    local tab = create_tab(tabbed_pane, "general", {"sosciencity.general"})

    local building_data = create_data_list(tab, "building")

    add_kv_pair(building_data, "building-type", {"sosciencity.type"}, type_details.localised_name)
    add_kv_pair(building_data, "description", "", type_details.localised_description)

    if entry[EK.active] ~= nil then
        add_kv_pair(building_data, "active", {"sosciencity.active"})
    end

    if building_details.range then
        local range = building_details.range
        add_kv_pair(
            building_data,
            "range",
            {"sosciencity.range"},
            (range ~= "global" and {"sosciencity.show-range", building_details.range * 2}) or
                {"sosciencity.global-range"}
        )
    end

    if building_details.power_usage then
        -- convert to kW
        local power = get_reasonable_number(building_details.power_usage * Time.second / 1000)
        add_kv_pair(building_data, "power", {"sosciencity.power-demand"}, {"sosciencity.current-power-demand", power})
    end

    if building_details.speed then
        -- convert to x / minute
        local speed = get_reasonable_number(building_details.speed * Time.minute)
        add_kv_pair(
            building_data,
            "speed",
            type_details.localised_speed_name,
            {type_details.localised_speed_key, speed}
        )
    end

    if entry[EK.performance] then
        add_kv_pair(building_data, "general-performance", {"sosciencity.general-performance"})
    end

    local worker_specification = building_details.workforce
    if worker_specification then
        add_kv_pair(building_data, "staff", {"sosciencity.staff"})
        add_kv_pair(building_data, "staff-performance")

        local castes_needed =
            Luaq_from(worker_specification.castes):select(display_caste, true):call(
            display_enumeration,
            nil,
            {"sosciencity.or"}
        )
        add_kv_pair(building_data, "castes", {"sosciencity.caste"}, castes_needed)

        add_header_label(tab, "worker-header", {"sosciencity.staff"})
        create_data_list(tab, "workers")
    end

    if type_details.affected_by_clockwork then
        add_kv_pair(building_data, "maintenance", {"sosciencity.maintenance"})
    end

    update_general_building_details(container, entry)

    return tabbed_pane
end

---------------------------------------------------------------------------------------------------
-- << composter >>

local function create_composting_values_tab(container)
    local tabbed_pane = get_or_create_tabbed_pane(container)
    local tab = create_tab(tabbed_pane, "compostables", {"sosciencity.compostables"})
    local composting_list = create_data_list(tab, "compostables")

    -- header
    add_kv_pair(composting_list, "head", {"sosciencity.item"}, {"sosciencity.humus"}, "default-bold", "default-bold")

    local item_prototypes = game.item_prototypes

    for item, value in pairs(ItemConstants.compost_values) do
        local item_representation = {"", format("[item=%s]  ", item), item_prototypes[item].localised_name}
        add_operand_entry(composting_list, item, item_representation, tostring(value))
    end
end

local function update_composter_details(container, entry)
    update_general_building_details(container, entry)

    local tabbed_pane = container.tabpane
    local building_data = get_tab_contents(tabbed_pane, "general").building

    local humus = entry[EK.humus]
    set_kv_pair_value(building_data, "humus", {"sosciencity.humus-count", round(humus / 100)})

    local inventory = Inventories.get_chest_inventory(entry)
    local progress_factor = Entity.analyze_composter_inventory(inventory.get_contents())
    -- display the composting speed as zero when the composter is full
    if humus >= get_building_details(entry).capacity then
        progress_factor = 0
    end
    set_kv_pair_value(
        building_data,
        "composting-speed",
        {
            "sosciencity.fraction",
            get_reasonable_number(Time.minute * progress_factor),
            {"sosciencity.minute"}
        }
    )
end

local function create_composter_details(container, entry)
    local tabbed_pane = create_general_building_details(container, entry)

    local general = get_tab_contents(tabbed_pane, "general")
    local building_data = general.building

    add_kv_pair(building_data, "humus", {"sosciencity.humus"})
    add_kv_pair(
        building_data,
        "capacity",
        {"sosciencity.capacity"},
        {"sosciencity.show-compost-capacity", get_building_details(entry).capacity}
    )
    add_kv_pair(building_data, "composting-speed", {"sosciencity.composting-speed"})

    update_composter_details(container, entry)
    create_composting_values_tab(container)
end

---------------------------------------------------------------------------------------------------
-- << water well >>

local function update_waterwell_details(container, entry)
    update_general_building_details(container, entry)

    local tabbed_pane = container.tabpane
    local building_data = get_tab_contents(tabbed_pane, "general").building

    local near_count = Neighborhood.get_neighbor_count(entry, Type.waterwell)
    local competition_performance = Entity.get_waterwell_competition_performance(entry)
    set_kv_pair_value(
        building_data,
        "competition",
        {"sosciencity.show-waterwell-competition", near_count, display_percentage(competition_performance)}
    )
end

local function create_waterwell_details(container, entry)
    local tabbed_pane = create_general_building_details(container, entry)

    local general = get_tab_contents(tabbed_pane, "general")
    local building_data = general.building

    add_kv_pair(building_data, "competition", {"sosciencity.competition"})

    update_waterwell_details(container, entry)
end

---------------------------------------------------------------------------------------------------
-- << farm >>

local function update_farm(container, entry)
    update_general_building_details(container, entry)

    local tabbed_pane = container.tabpane
    local building_data = get_tab_contents(tabbed_pane, "general").building

    set_kv_pair_value(
        building_data,
        "orchid-bonus",
        {"sosciencity.percentage-bonus", global.caste_bonuses[Type.orchid], {"sosciencity.productivity"}}
    )

    local flora_details = Biology.flora[entry[EK.species]]
    if flora_details then
        set_kv_pair_visibility(building_data, "biomass", flora_details.persistent)
        local biomass = entry[EK.biomass]
        if biomass ~= nil then
            set_kv_pair_value(
                building_data,
                "biomass",
                {"sosciencity.display-biomass", floor(biomass), Entity.biomass_to_productivity(biomass)}
            )
        end

        set_kv_pair_visibility(building_data, "climate", true)
        set_kv_pair_visibility(building_data, "humidity", true)

        if get_building_details(entry).open_environment then
            set_kv_pair_value(
                building_data,
                "climate",
                flora_details.preferred_climate == global.current_climate and
                    {
                        "sosciencity.right-climate",
                        climate_locales[flora_details.preferred_climate]
                    } or
                    {
                        "sosciencity.wrong-climate",
                        climate_locales[global.current_climate],
                        climate_locales[flora_details.preferred_climate],
                        {
                            "sosciencity.percentage-malus",
                            100 - flora_details.wrong_climate_coefficient * 100,
                            {"sosciencity.speed"}
                        }
                    }
            )
            set_kv_pair_value(
                building_data,
                "humidity",
                flora_details.preferred_humidity == global.current_humidity and
                    {
                        "sosciencity.right-humidity",
                        humidity_locales[flora_details.preferred_humidity]
                    } or
                    {
                        "sosciencity.wrong-humidity",
                        humidity_locales[global.current_humidity],
                        humidity_locales[flora_details.preferred_humidity],
                        {
                            "sosciencity.percentage-malus",
                            100 - flora_details.wrong_humidity_coefficient * 100,
                            {"sosciencity.speed"}
                        }
                    }
            )
        else
            set_kv_pair_value(
                building_data,
                "climate",
                {"sosciencity.closed-climate", climate_locales[flora_details.preferred_climate]}
            )
            set_kv_pair_value(
                building_data,
                "humidity",
                {"sosciencity.closed-humidity", humidity_locales[flora_details.preferred_humidity]}
            )
        end

        if
            flora_details.required_module and
                not Inventories.assembler_has_module(entry[EK.entity], flora_details.required_module)
         then
            set_kv_pair_value(
                building_data,
                "module",
                {"sosciencity.module-missing", display_item_stack(flora_details.required_module, 1)}
            )
            set_kv_pair_visibility(building_data, "module", true)
        else
            set_kv_pair_visibility(building_data, "module", false)
        end
    else
        -- no recipe set
        set_kv_pair_visibility(building_data, "biomass", false)
        set_kv_pair_visibility(building_data, "climate", false)
        set_kv_pair_visibility(building_data, "humidity", false)
        set_kv_pair_visibility(building_data, "module", false)
    end

    local humus_checkbox = get_checkbox(building_data, "humus-mode")
    humus_checkbox.state = entry[EK.humus_mode]
    set_kv_pair_visibility(building_data, "humus-bonus", entry[EK.humus_mode])
    if entry[EK.humus_bonus] then
        set_kv_pair_value(
            building_data,
            "humus-bonus",
            {"sosciencity.percentage-bonus", ceil(entry[EK.humus_bonus]), {"sosciencity.speed"}}
        )
    end

    local pruning_checkbox = get_checkbox(building_data, "pruning-mode")
    pruning_checkbox.state = entry[EK.pruning_mode]
    set_kv_pair_visibility(building_data, "prune-bonus", entry[EK.humus_mode])
    if entry[EK.prune_bonus] then
        set_kv_pair_value(
            building_data,
            "prune-bonus",
            {"sosciencity.percentage-bonus", ceil(entry[EK.prune_bonus]), {"sosciencity.productivity"}}
        )
    end
end

local function create_farm(container, entry)
    local tabbed_pane = create_general_building_details(container, entry)

    local general = get_tab_contents(tabbed_pane, "general")
    local building_data = general.building

    add_kv_pair(building_data, "orchid-bonus", {"caste-short.orchid"})
    add_kv_pair(building_data, "biomass", {"sosciencity.biomass"})
    add_kv_pair(building_data, "climate", {"sosciencity.climate"})
    add_kv_pair(building_data, "humidity", {"sosciencity.humidity"})

    add_kv_checkbox(
        building_data,
        "humus-mode",
        format(unique_prefix_builder, "humus-mode", "farm"),
        {"sosciencity.humus-fertilization"},
        {"sosciencity.active"}
    )
    add_kv_pair(
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
    add_kv_pair(building_data, "humus-bonus")

    add_kv_checkbox(
        building_data,
        "pruning-mode",
        format(unique_prefix_builder, "pruning-mode", "farm"),
        {"sosciencity.pruning"},
        {"sosciencity.active"}
    )
    add_kv_pair(
        building_data,
        "explain-pruning",
        "",
        {"sosciencity.explain-pruning", Entity.pruning_workhours * Time.minute, Entity.pruning_productivity}
    )
    add_kv_pair(building_data, "prune-bonus")

    add_kv_pair(building_data, "module")

    update_farm(container, entry)
end

set_checked_state_handler(format(unique_prefix_builder, "humus-mode", "farm"), generic_checkbox_handler, EK.humus_mode)

set_checked_state_handler(
    format(unique_prefix_builder, "pruning-mode", "farm"),
    generic_checkbox_handler,
    EK.pruning_mode
)

---------------------------------------------------------------------------------------------------
-- << fishing hut >>

local function update_fishery_details(container, entry)
    update_general_building_details(container, entry)

    local tabbed_pane = container.tabpane
    local building_data = get_tab_contents(tabbed_pane, "general").building

    local building_details = get_building_details(entry)
    set_kv_pair_value(
        building_data,
        "water-tiles",
        {
            "sosciencity.value-with-unit",
            {"sosciencity.fraction", entry[EK.water_tiles], building_details.water_tiles},
            {"sosciencity.tiles"}
        }
    )

    local competition_performance, near_count = Entity.get_fishing_competition(entry)
    set_kv_pair_value(
        building_data,
        "competition",
        {"sosciencity.show-fishing-competition", near_count, display_percentage(competition_performance)}
    )
end

local function create_fishery_details(container, entry)
    local tabbed_pane = create_general_building_details(container, entry)

    local general = get_tab_contents(tabbed_pane, "general")
    local building_data = general.building

    add_kv_pair(building_data, "water-tiles", {"sosciencity.water-tiles"})
    add_kv_pair(building_data, "competition", {"sosciencity.competition"})

    update_fishery_details(container, entry)
end

---------------------------------------------------------------------------------------------------
-- << hunting hut >>

local function update_hunting_hut_details(container, entry)
    update_general_building_details(container, entry)

    local tabbed_pane = container.tabpane
    local building_data = get_tab_contents(tabbed_pane, "general").building

    local building_details = get_building_details(entry)
    set_kv_pair_value(
        building_data,
        "tree-count",
        {"sosciencity.fraction", entry[EK.tree_count], building_details.tree_count}
    )

    local competition_performance, near_count = Entity.get_hunting_competition(entry)
    set_kv_pair_value(
        building_data,
        "competition",
        {"sosciencity.show-hunting-competition", near_count, display_percentage(competition_performance)}
    )
end

local function create_hunting_hut_details(container, entry)
    local tabbed_pane = create_general_building_details(container, entry)

    local general = get_tab_contents(tabbed_pane, "general")
    local building_data = general.building

    add_kv_pair(building_data, "tree-count", {"sosciencity.tree-count"})
    add_kv_pair(building_data, "competition", {"sosciencity.competition"})

    update_hunting_hut_details(container, entry)
end

---------------------------------------------------------------------------------------------------
-- << immigration port >>

local function update_immigration_port_details(container, entry)
    update_general_building_details(container, entry)

    local tabbed_pane = container.tabpane
    local general = get_tab_contents(tabbed_pane, "general")
    local building_data = general.building

    local ticks_to_next_wave = entry[EK.next_wave] - game.tick
    set_kv_pair_value(building_data, "next-wave", display_time(ticks_to_next_wave))

    local immigrants_list = general.immigration
    for caste, immigrants in pairs(immigration) do
        local key = tostring(caste)
        set_kv_pair_value(
            immigrants_list,
            key,
            {
                "",
                floor(immigrants),
                {"sosciencity.migration", get_migration_string(castes[caste].immigration_coefficient * Time.minute)}
            }
        )
        set_kv_pair_visibility(immigrants_list, key, Inhabitants.caste_is_researched(caste))
    end
end

local function create_immigration_port_details(container, entry)
    local tabbed_pane = create_general_building_details(container, entry)

    local general = get_tab_contents(tabbed_pane, "general")
    local building_data = general.building
    local building_details = get_building_details(entry)

    add_kv_pair(building_data, "next-wave", {"sosciencity.next-wave"})
    add_kv_pair(building_data, "materials", {"sosciencity.materials"}, display_materials(building_details.materials))
    add_kv_pair(
        building_data,
        "capacity",
        {"sosciencity.capacity"},
        {"sosciencity.show-port-capacity", building_details.capacity}
    )

    create_separator_line(general)

    add_header_label(general, "header-immigration", {"sosciencity.estimated-immigrants"})
    local immigrants_list = create_data_list(general, "immigration")

    for caste in pairs(immigration) do
        add_kv_pair(immigrants_list, tostring(caste), type_definitions[caste].localised_name)
    end

    update_immigration_port_details(container, entry)
end

---------------------------------------------------------------------------------------------------
-- << hospital >>

local function create_disease_catalogue(container)
    local tabbed_pane = get_or_create_tabbed_pane(container)
    local tab = create_tab(tabbed_pane, "diseases", {"sosciencity.diseases"})

    local data_list = create_data_list(tab, "diseases", 1)

    -- disease entries
    for id, disease in pairs(Diseases.values) do
        local entry =
            data_list.add {
            type = "label",
            name = tostring(id),
            caption = disease.localised_name,
            tooltip = disease.localised_description
        }
        local style = entry.style
        style.horizontally_stretchable = true
    end
end

local function update_hospital_details(container, entry)
    update_general_building_details(container, entry)

    local tabbed_pane = container.tabpane
    local building_data = get_tab_contents(tabbed_pane, "general").building

    set_kv_pair_value(building_data, "capacity", {"sosciencity.show-operations", floor(entry[EK.workhours])})

    local facility_flow = get_kv_value_element(building_data, "facilities")
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
end

local function create_hospital_details(container, entry)
    local tabbed_pane = create_general_building_details(container, entry)

    local general = get_tab_contents(tabbed_pane, "general")
    local building_data = general.building

    add_kv_pair(building_data, "capacity", {"sosciencity.capacity"})
    add_kv_flow(building_data, "facilities", {"sosciencity.facilities"})

    update_hospital_details(container, entry)

    create_disease_catalogue(container)
end

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
        local count = Tirislib_Tables.array_sum(class[2])
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

local function update_upbringing_station(container, entry)
    update_general_building_details(container, entry)

    local tabbed_pane = container.tabpane
    local building_data = get_tab_contents(tabbed_pane, "general").building

    local mode_flow = get_kv_value_element(building_data, "mode")
    update_upbringing_mode_radiobuttons(entry, mode_flow)

    local probability_flow = get_kv_value_element(building_data, "probabilities")
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
                {"caste-short." .. caste.name},
                display_percentage(probability)
            }
        end
        label.visible = (probability ~= nil)
    end

    probability_flow.no_castes.visible = not at_least_one

    update_classes_flow(entry, get_kv_value_element(building_data, "classes"))

    set_kv_pair_value(building_data, "graduates", entry[EK.graduates])
end

local function create_upbringing_station(container, entry)
    local tabbed_pane = create_general_building_details(container, entry)

    local general = get_tab_contents(tabbed_pane, "general")
    local building_data = general.building

    add_kv_pair(
        building_data,
        "capacity",
        {"sosciencity.capacity"},
        {"sosciencity.show-upbringing-capacity", get_building_details(entry).capacity}
    )

    -- Mode flow
    local mode_flow = add_kv_flow(building_data, "mode", {"sosciencity.mode"})

    for _, caste_id in pairs(TypeGroup.breedable_castes) do
        mode_flow.add {
            name = format(unique_prefix_builder, "education-mode", caste_id),
            type = "radiobutton",
            caption = type_definitions[caste_id].localised_name,
            state = true
        }
    end

    mode_flow.add {
        name = format(unique_prefix_builder, "education-mode", Type.null),
        type = "radiobutton",
        caption = {"sosciencity.no-mode"},
        state = true
    }

    -- expected castes flow
    local probabilities_flow = add_kv_flow(building_data, "probabilities", {"sosciencity.expected"})

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

    add_kv_flow(building_data, "classes", {"sosciencity.classes"})
    add_kv_pair(building_data, "graduates", {"sosciencity.graduates"})

    update_upbringing_station(container, entry)
end

for _, caste_id in pairs(Tirislib_Tables.union_array(TypeGroup.breedable_castes, {Type.null})) do
    set_checked_state_handler(
        format(unique_prefix_builder, "education-mode", caste_id),
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
        local radiobutton = mode_flow[format(unique_prefix_builder, "waste-dump-mode", mode_name)]
        radiobutton.state = (active_mode == mode_id)
    end
end

local function update_waste_dump(container, entry)
    update_general_building_details(container, entry)

    local tabbed_pane = container.tabpane
    local building_data = get_tab_contents(tabbed_pane, "general").building

    local stored_garbage = entry[EK.stored_garbage]
    local capacity = get_building_details(entry).capacity
    set_kv_pair_value(
        building_data,
        "capacity",
        {
            "sosciencity.value-with-unit",
            {"sosciencity.fraction", Tirislib_Tables.sum(stored_garbage), capacity},
            {"sosciencity.items"}
        }
    )

    set_kv_pair_value(
        building_data,
        "stored_garbage",
        Luaq_from(stored_garbage):select(display_item_stack):call(display_enumeration, "\n")
    )

    update_waste_dump_mode_radiobuttons(entry, get_kv_value_element(building_data, "mode"))

    local checkbox = get_checkbox(building_data, "press")
    checkbox.state = entry[EK.press_mode]
end

local function create_waste_dump(container, entry)
    local tabbed_pane = create_general_building_details(container, entry)

    local general = get_tab_contents(tabbed_pane, "general")
    local building_data = general.building

    add_kv_pair(building_data, "capacity", {"sosciencity.capacity"})
    add_kv_pair(building_data, "stored_garbage", {"sosciencity.content"})

    local mode_flow = add_kv_flow(building_data, "mode", {"sosciencity.mode"})
    for mode_name in pairs(WasteDumpOperationMode) do
        mode_flow.add {
            name = format(unique_prefix_builder, "waste-dump-mode", mode_name),
            type = "radiobutton",
            caption = {"sosciencity." .. mode_name},
            state = true
        }
    end

    add_kv_checkbox(
        building_data,
        "press",
        format(unique_prefix_builder, "waste-dump-press", ""),
        {"sosciencity.press"},
        {"sosciencity.active"}
    )

    update_waste_dump(container, entry)
end

for mode_name, mode_id in pairs(WasteDumpOperationMode) do
    set_checked_state_handler(
        format(unique_prefix_builder, "waste-dump-mode", mode_name),
        generic_radiobutton_handler,
        mode_id,
        EK.waste_dump_mode,
        update_waste_dump_mode_radiobuttons
    )
end

set_checked_state_handler(
    format(unique_prefix_builder, "waste-dump-press", ""),
    generic_checkbox_handler,
    EK.press_mode
)

---------------------------------------------------------------------------------------------------
-- << market >>

local function analyse_dependants(entry, consumption_key)
    local inhabitant_count = 0
    local consumption = 0

    for _, caste_id in pairs(TypeGroup.all_castes) do
        local multiplier = Castes.values[caste_id][consumption_key]
        for _, house in Neighborhood.all_of_type(entry, caste_id) do
            local inhabitants = house[EK.inhabitants]
            inhabitant_count = inhabitant_count + inhabitants
            consumption = consumption + inhabitants * multiplier
        end
    end

    return inhabitant_count, consumption
end

local function update_market(container, entry)
    update_general_building_details(container, entry)

    local tabbed_pane = container.tabpane
    local building_data = get_tab_contents(tabbed_pane, "general").building

    local amount = Inventories.count_calories(Inventories.get_chest_inventory(entry))

    set_kv_pair_value(building_data, "content", {"sosciencity.value-with-unit", amount, {"sosciencity.kcal"}})

    local inhabitants, consumption = analyse_dependants(entry, "calorific_demand")
    set_kv_pair_value(
        building_data,
        "dependants",
        {
            "sosciencity.display-dependants",
            inhabitants,
            {"sosciencity.show-calorific-demand", floor(consumption * Time.minute)}
        }
    )

    if consumption > 0 then
        set_kv_pair_value(
            building_data,
            "supply",
            {"sosciencity.display-supply", display_time(floor(amount / consumption))}
        )
    else
        set_kv_pair_value(building_data, "supply", "-")
    end
end

local function create_market(container, entry)
    local tabbed_pane = create_general_building_details(container, entry)

    local general = get_tab_contents(tabbed_pane, "general")
    local building_data = general.building

    add_kv_pair(building_data, "content", {"sosciencity.content"})
    add_kv_pair(building_data, "dependants", {"sosciencity.dependants"})
    add_kv_pair(building_data, "supply", {"sosciencity.supply"})

    update_market(container, entry)
end

---------------------------------------------------------------------------------------------------
-- << water distributer >>

local function update_water_distributer(container, entry)
    update_general_building_details(container, entry)

    local tabbed_pane = container.tabpane
    local building_data = get_tab_contents(tabbed_pane, "general").building

    local water = entry[EK.water_name]
    local amount

    if water then
        amount = entry[EK.entity].get_fluid_count(water)
        set_kv_pair_value(building_data, "content", Tirislib_Locales.display_fluid_stack(water, floor(amount)))
    else
        amount = 0
        set_kv_pair_value(building_data, "content", "-")
    end

    local inhabitants, consumption = analyse_dependants(entry, "water_demand")
    set_kv_pair_value(
        building_data,
        "dependants",
        {
            "sosciencity.display-dependants",
            inhabitants,
            {"sosciencity.show-water-demand", floor(consumption * Time.minute)}
        }
    )

    if consumption > 0 then
        set_kv_pair_value(
            building_data,
            "supply",
            {"sosciencity.display-supply", display_time(floor(amount / consumption))}
        )
    else
        set_kv_pair_value(building_data, "supply", "-")
    end
end

local function create_water_distributer(container, entry)
    local tabbed_pane = create_general_building_details(container, entry)

    local general = get_tab_contents(tabbed_pane, "general")
    local building_data = general.building

    add_kv_pair(building_data, "content", {"sosciencity.content"})
    add_kv_pair(building_data, "dependants", {"sosciencity.dependants"})
    add_kv_pair(building_data, "supply", {"sosciencity.supply"})

    update_water_distributer(container, entry)
end

---------------------------------------------------------------------------------------------------
-- << plant care station >>

local function update_plant_care_station(container, entry)
    update_general_building_details(container, entry)

    local tabbed_pane = container.tabpane
    local building_data = get_tab_contents(tabbed_pane, "general").building

    set_kv_pair_value(building_data, "workhours", {"sosciencity.display-workhours", floor(entry[EK.workhours])})
    set_kv_pair_value(building_data, "humus-stored", display_item_stack("humus", floor(entry[EK.humus_stored])))

    local humus_checkbox = get_checkbox(building_data, "humus-mode")
    humus_checkbox.state = entry[EK.humus_mode]

    local pruning_checkbox = get_checkbox(building_data, "pruning-mode")
    pruning_checkbox.state = entry[EK.pruning_mode]
end

local function create_plant_care_station(container, entry)
    local tabbed_pane = create_general_building_details(container, entry)

    local general = get_tab_contents(tabbed_pane, "general")
    local building_data = general.building

    add_kv_pair(building_data, "workhours", {"sosciencity.workhours"})
    add_kv_pair(building_data, "humus-stored", {"item-name.humus"})

    add_kv_checkbox(
        building_data,
        "humus-mode",
        format(unique_prefix_builder, "humus-mode", "plant-care"),
        {"sosciencity.humus-fertilization"},
        {"sosciencity.active"}
    )
    add_kv_pair(
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

    add_kv_checkbox(
        building_data,
        "pruning-mode",
        format(unique_prefix_builder, "pruning-mode", "plant-care"),
        {"sosciencity.pruning"},
        {"sosciencity.active"}
    )
    add_kv_pair(
        building_data,
        "explain-pruning",
        "",
        {"sosciencity.explain-pruning", Entity.pruning_workhours * Time.minute, Entity.pruning_productivity}
    )
end

set_checked_state_handler(
    format(unique_prefix_builder, "humus-mode", "plant-care"),
    generic_checkbox_handler,
    EK.humus_mode
)

set_checked_state_handler(
    format(unique_prefix_builder, "pruning-mode", "plant-care"),
    generic_checkbox_handler,
    EK.pruning_mode
)

---------------------------------------------------------------------------------------------------
-- << general details view functions >>

local function create_details_view_for_player(player)
    local frame = player.gui.screen[DETAILS_VIEW_NAME]
    if frame and frame.valid then
        return
    end

    frame =
        player.gui.screen.add {
        type = "frame",
        name = DETAILS_VIEW_NAME,
        direction = "horizontal"
    }
    frame.style.width = 350
    frame.style.height = 600
    frame.style.horizontally_stretchable = true
    make_squashable(frame)
    set_padding(frame, 4)
    frame.location = {x = 10, y = 100}

    frame.add {
        type = "frame",
        name = "nested",
        direction = "horizontal",
        style = "inside_deep_frame_for_tabs"
    }

    frame.visible = false
end

local function get_details_view(player)
    local details_view = player.gui.screen[DETAILS_VIEW_NAME]

    -- we check if the gui still exists, as other mods can delete them
    if details_view ~= nil and details_view.valid then
        return details_view
    else
        -- recreate it otherwise
        create_details_view_for_player(player)
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
        creater = create_general_building_details,
        updater = update_general_building_details
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
    [Type.fishery] = {
        creater = create_fishery_details,
        updater = update_fishery_details
    },
    [Type.pharmacy] = {
        creater = create_general_building_details,
        updater = update_general_building_details
    },
    [Type.hospital] = {
        creater = create_hospital_details,
        updater = update_hospital_details
    },
    [Type.plant_care_station] = {
        creater = create_plant_care_station,
        updater = update_plant_care_station
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
    [Type.upbringing_station] = {
        creater = create_upbringing_station,
        updater = update_upbringing_station
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
function Gui.update_details_view()
    local current_tick = game.tick

    for player_id, unit_number in pairs(global.details_view) do
        local entry = Register.try_get(unit_number)
        local player = game.players[player_id]

        -- check if the entity hasn't been unregistered in the meantime
        if not entry then
            Gui.close_details_view_for_player(player)
        else
            local gui_spec = type_gui_specifications[entry[EK.type]]
            local updater = gui_spec and gui_spec.updater

            if updater and (entry[EK.last_update] == current_tick or gui_spec.always_update) then
                updater(get_nested_details_view(player), entry)
            end
        end
    end
end

--- Builds a details gui for the given player and the given entity.
--- @param player Player
--- @param unit_number integer
function Gui.open_details_view_for_player(player, unit_number)
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
    local nested = details_view.nested

    nested.clear()
    creater(nested, entry)
    details_view.visible = true
    global.details_view[player.index] = unit_number
end

--- Closes the details view for the given player.
--- @param player Player
function Gui.close_details_view_for_player(player)
    local details_view = get_details_view(player)
    details_view.visible = false
    global.details_view[player.index] = nil
    details_view.caption = nil
    details_view.nested.clear()
end

--- Closes and reopens all the Guis related to the given entry.
--- @param entry Entry
function Gui.rebuild_details_view_for_entry(entry)
    local unit_number = entry[EK.entity].unit_number

    for player_index, viewed_unit_number in pairs(global.details_view) do
        if unit_number == viewed_unit_number then
            local player = game.players[player_index]
            Gui.close_details_view_for_player(player)
            Gui.open_details_view_for_player(player, unit_number)
        end
    end
end

--- Initializes the guis for the given player. Gets called after a new player gets created.
--- @param player Player
function Gui.create_guis_for_player(player)
    create_city_info_for_player(player)
    create_details_view_for_player(player)
end

return Gui
