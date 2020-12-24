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
local Register = Register
local Inhabitants = Inhabitants
local Buildings = Buildings

local ceil = math.ceil
local floor = math.floor
local format = string.format
local tostring = tostring

local function set_locals()
    global = _ENV.global
    immigration = global.immigration
    population = global.population
    caste_points = global.caste_points
end

--- This should be added to every gui element which needs an event handler,
--- because the click event is fired for every gui in existance.
--- So I need to ensure that I'm not reacting to another mods gui.
Gui.UNIQUE_PREFIX = "sosciencity-"
---------------------------------------------------------------------------------------------------
-- << formatting functions >>
local function get_caste_bonus(caste_id)
    local bonus = global.caste_bonuses[caste_id]
    if caste_id == Type.clockwork and global.use_penalty then
        bonus = bonus - 80
    end
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

local function get_summand_string(number)
    if number > 0 then
        return format("[color=0,1,0]%+.1f[/color]", number)
    elseif number < 0 then
        return format("[color=1,0,0]%+.1f[/color]", number)
    else -- number equals 0
        return "[color=0.8,0.8,0.8]0.0[/color]"
    end
end

local function get_factor_string(number)
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

local function display_caste(caste_id)
    return {"caste-name." .. castes[caste_id].name}
end

local function get_migration_string(number)
    return format("%+.1f", number)
end

local function get_entry_representation(entry)
    local entity = entry[EK.entity]
    local position = entity.position
    return {"sosciencity-gui.entry-representation", entity.localised_name, position.x, position.y}
end

local function display_percentage(percentage)
    return {"sosciencity-gui.percentage", ceil(percentage * 100)}
end

local function display_fraction(numerator, denominator, localised_name)
    return {"sosciencity-gui.fraction", numerator, denominator, localised_name}
end

local function display_convergence(current, target)
    return {"sosciencity-gui.convergenting-value", get_reasonable_number(current), get_reasonable_number(target)}
end

local mult = " × "
local function display_materials(materials)
    local ret = {""}
    local first = true

    for material, count in pairs(materials) do
        local entry = {""}

        if not first then
            entry[#entry + 1] = "\n"
        end
        first = false

        entry[#entry + 1] = count
        entry[#entry + 1] = mult

        entry[#entry + 1] = format("[item=%s] ", material)

        local item_prototype = game.item_prototypes[material]
        entry[#entry + 1] = item_prototype.localised_name

        ret[#ret + 1] = entry
    end

    return ret
end

local function display_time(ticks)
    local seconds = ceil(ticks / 60)
    local minutes = floor(seconds / 60)
    seconds = seconds % 60
    local hours = floor(minutes / 60)
    minutes = minutes % 60

    return {"sosciencity-gui.time", hours, minutes, seconds}
end

---------------------------------------------------------------------------------------------------
-- << style functions >>
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
-- << gui elements >>
local DATA_LIST_DEFAULT_NAME = "datalist"
local function create_data_list(container, name)
    local datatable =
        container.add {
        type = "table",
        name = name or DATA_LIST_DEFAULT_NAME,
        column_count = 2,
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

local function add_kv_flow(data_list, key, key_caption, key_font)
    add_key_label(data_list, key, key_caption, key_font)

    local value_flow =
        data_list.add {
        type = "flow",
        name = key,
        direction = "vertical"
    }

    return value_flow
end

local function get_kv_pair(data_list, key)
    return data_list["key-" .. key], data_list[key]
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

local function add_operand_entry(data_list, key, key_caption, value_caption)
    local key_label =
        data_list.add {
        type = "label",
        name = "key-" .. key,
        caption = key_caption
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

local function add_summand_entries(data_list, caption_group, count)
    for i = 1, count do
        add_operand_entry(data_list, tostring(i), {caption_group .. i})
    end
end

local function add_factor_entries(data_list, caption_group, count)
    for i = 1, count do
        add_operand_entry(data_list, "*" .. i, {caption_group .. i})
    end
end

local function create_operand_entries(data_list, caption, summand_caption, summand_count, factor_caption, factor_count)
    add_final_value_entry(data_list, caption)
    add_summand_entries(data_list, summand_caption, summand_count)
    add_factor_entries(data_list, factor_caption, factor_count)
end

local function update_operand_entries(data_list, final_value, summand_entries, factor_entries)
    data_list["sum"].caption = get_summand_string(final_value)

    for i = 1, #summand_entries do
        local value = summand_entries[i]
        local key = tostring(i)

        if value ~= 0 then
            set_kv_pair_value(data_list, key, get_summand_string(value))
            set_kv_pair_visibility(data_list, key, true)
        else
            set_kv_pair_visibility(data_list, key, false)
        end
    end

    for i = 1, #factor_entries do
        local value = factor_entries[i]
        local key = "*" .. i

        if value ~= 1. then
            set_kv_pair_value(data_list, key, get_factor_string(value))
            set_kv_pair_visibility(data_list, key, true)
        else
            set_kv_pair_visibility(data_list, key, false)
        end
    end
end

local function is_confirmed(button)
    local caption = button.caption[1]
    if caption == "sosciencity-gui.confirm" then
        return true
    else
        button.caption = {"sosciencity-gui.confirm"}
        button.tooltip = {"sosciencity-gui.confirm-tooltip"}
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
local CITY_INFO_NAME = "sosciencity-city-info"
local CITY_INFO_SPRITE_SIZE = 48

local function update_population_flow(frame)
    local population_flow = frame["general"]

    local population_count = Inhabitants.get_population_count()
    population_flow["population"].caption = {"sosciencity-gui.population", population_count}

    population_flow["machine-count"].caption = {"sosciencity-gui.machines", Register.get_machine_count()}

    population_flow["turret-count"].caption = {"sosciencity-gui.turrets", Register.get_type_count(Type.turret)}
end

local function add_population_flow(container)
    local frame =
        container.add {
        type = "frame",
        name = "general",
        direction = "vertical"
    }
    set_padding(frame, 2)

    local population_label =
        frame.add {
        type = "label",
        name = "population"
    }
    population_label.style.bottom_margin = 4

    local machine_label =
        frame.add {
        type = "label",
        name = "machine-count"
    }
    machine_label.style.bottom_margin = 4

    frame.add {
        type = "label",
        name = "turret-count"
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
    make_stretchable(frame)
    frame.style.padding = 0
    frame.style.left_margin = 4

    frame.visible = Inhabitants.caste_is_researched(caste_id)

    local flow =
        frame.add {
        type = "flow",
        name = "flow",
        direction = "vertical"
    }
    make_stretchable(flow)
    flow.style.vertical_spacing = 0
    flow.style.horizontal_align = "center"

    local sprite = create_caste_sprite(flow, caste_id, CITY_INFO_SPRITE_SIZE)
    sprite.style.height = CITY_INFO_SPRITE_SIZE
    sprite.style.width = CITY_INFO_SPRITE_SIZE
    sprite.style.stretch_image_to_widget_size = true
    sprite.style.horizontal_align = "center"

    flow.add {
        type = "label",
        name = "caste-population",
        caption = global.population[caste_id],
        tooltip = {"sosciencity-gui.caste-points", get_reasonable_number(caste_points[caste_id])}
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
    caste_frame.visible = Inhabitants.caste_is_researched(caste_id)

    -- the frame may not yet exist
    if caste_frame == nil then
        add_caste_flow(container, caste_id)
        return
    end

    local flow = caste_frame.flow

    local population_label = flow["caste-population"]
    population_label.caption = population[caste_id]
    population_label.tooltip = {
        "sosciencity-gui.caste-points",
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

    for id, _ in pairs(Castes.values) do
        add_caste_flow(frame, id)
    end
end

local function update_city_info(frame)
    update_population_flow(frame)

    for id, _ in pairs(Castes.values) do
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
local DETAILS_VIEW_NAME = "sosciencity-details"

local function set_details_view_title(container, caption)
    container.parent.caption = caption
end

local function create_tabbed_pane(container)
    return container.add {
        type = "tabbed-pane",
        name = "tabpane"
    }
end

-- << empty housing details view >>
local function add_caste_chooser_tab(tabbed_pane, details)
    local flow = create_tab(tabbed_pane, "caste-chooser", {"sosciencity-gui.caste"})

    flow.style.horizontal_align = "center"
    flow.style.vertical_align = "center"
    flow.style.vertical_spacing = 6

    local at_least_one = false
    for caste_id, caste in pairs(Castes.values) do
        if Inhabitants.caste_is_researched(caste_id) then
            local caste_name = caste.name

            local button =
                flow.add {
                type = "button",
                name = Gui.UNIQUE_PREFIX .. caste_name,
                caption = {"caste-name." .. caste_name},
                tooltip = {"sosciencity-gui.move-in", caste_name},
                mouse_button_filter = {"left"}
            }
            button.style.width = 150

            if Housing.allowes_caste(details, caste_id) then
                button.tooltip = {"sosciencity-gui.move-in", caste_name}
            elseif castes[caste_id].required_room_count > details.room_count then
                button.tooltip = {"sosciencity-gui.not-enough-room"}
            else
                button.tooltip = {"sosciencity-gui.not-enough-comfort"}
            end
            button.enabled = Housing.allowes_caste(details, caste_id)
            at_least_one = true
        end
    end

    if not at_least_one then
        flow.add {
            type = "label",
            name = "no-castes-researched-label",
            caption = {"sosciencity-gui.no-castes-researched"}
        }
    end
end

local function add_empty_house_info_tab(tabbed_pane, house_details)
    local flow = create_tab(tabbed_pane, "house-info", {"sosciencity-gui.building-info"})

    local data_list = create_data_list(flow, "house-infos")
    add_kv_pair(data_list, "room_count", {"sosciencity-gui.room-count"}, house_details.room_count)
    add_kv_pair(data_list, "comfort", {"sosciencity-gui.comfort"}, display_comfort(house_details.comfort))

    local qualities_flow = add_kv_flow(data_list, "qualities", {"sosciencity-gui.qualities"})
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

    local tabbed_pane = create_tabbed_pane(container)

    local house_details = Housing.get(entry)
    add_caste_chooser_tab(tabbed_pane, house_details)
    add_empty_house_info_tab(tabbed_pane, house_details)
end

-- << housing details view >>
local function update_occupations_list(flow, entry)
    local occupations_list = flow.occupations

    occupations_list.clear()

    add_operand_entry(
        occupations_list,
        "unoccupied",
        {"sosciencity-gui.unemployed"},
        Inhabitants.get_employable_count(entry)
    )
    set_kv_pair_tooltip(occupations_list, "unoccupied", {"sosciencity-gui.explain-unemployed"})

    local employments = entry[EK.employments]
    for building_number, count in pairs(employments) do
        local building = Register.try_get(building_number)
        if building then
            add_operand_entry(
                occupations_list,
                building_number,
                {"sosciencity-gui.employed", get_entry_representation(building)},
                count
            )
        end
    end

    local disease_group = entry[EK.diseases]
    for disease_id, count in pairs(disease_group) do
        if disease_id ~= DiseaseGroup.HEALTHY then
            local disease = diseases[disease_id]
            local key = format("disease-%d", disease_id)
            add_operand_entry(occupations_list, key, {"sosciencity-gui.ill", disease.localised_name}, count)
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
        add_operand_entry(ages_list, age, {"sosciencity-gui.show-age", age}, count)
    end

    local visible = (entry[EK.inhabitants] > 0)
    ages_list.visible = visible
    flow["header-ages"].visible = visible
end

local function update_genders_list(flow, entry)
    local genders_list = flow.genders

    genders_list.clear()
    for gender, count in pairs(entry[EK.genders]) do
        add_operand_entry(genders_list, gender, {"sosciencity-gui.gender-" .. gender}, count)
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
            {"sosciencity-gui.show-inhabitants", inhabitants, capacity},
            display_emigration and {"sosciencity-gui.migration", get_migration_string(emigration)} or ""
        }
    )
    set_datalist_value_tooltip(
        general_list,
        "inhabitants",
        (entry[EK.emigration_trend] > 0) and {"sosciencity-gui.positive-trend"} or {"sosciencity-gui.negative-trend"}
    )

    set_kv_pair_value(
        general_list,
        "happiness",
        (inhabitants > 0) and display_convergence(entry[EK.happiness], Inhabitants.get_nominal_happiness(entry)) or "-"
    )
    set_kv_pair_value(
        general_list,
        "health",
        (inhabitants > 0) and display_convergence(entry[EK.health], Inhabitants.get_nominal_health(entry)) or "-"
    )
    set_kv_pair_value(
        general_list,
        "sanity",
        (inhabitants > 0) and display_convergence(entry[EK.sanity], Inhabitants.get_nominal_sanity(entry)) or "-"
    )
    set_kv_pair_value(
        general_list,
        "bonus",
        (inhabitants > 0) and
            {
                "sosciencity-gui.show-bonus",
                get_reasonable_number(entry[EK.caste_points])
            } or
            "-"
    )
    set_kv_pair_value(
        general_list,
        "calorific-demand",
        {
            "sosciencity-gui.show-calorific-demand",
            get_reasonable_number(caste.calorific_demand * Time.minute * inhabitants)
        }
    )
    set_kv_pair_value(
        general_list,
        "water-demand",
        {"sosciencity-gui.show-water-demand", caste.water_demand * Time.minute * inhabitants}
    )
    set_kv_pair_value(
        general_list,
        "power-demand",
        {"sosciencity-gui.current-power-demand", caste.power_demand / 1000 * Time.second * inhabitants}
    )

    update_occupations_list(flow, entry)
    update_ages_list(flow, entry)
    update_genders_list(flow, entry)
end

local function add_housing_general_info_tab(tabbed_pane, entry, caste_id)
    local flow = create_tab(tabbed_pane, "general", {"sosciencity-gui.general"})

    flow.style.vertical_spacing = 6
    flow.style.horizontal_align = "right"

    local data_list = create_data_list(flow, "general-infos")
    add_kv_pair(data_list, "caste", {"sosciencity-gui.caste"}, display_caste(entry[EK.type]))

    add_kv_pair(data_list, "inhabitants", {"sosciencity-gui.inhabitants"})
    add_kv_pair(data_list, "happiness", {"sosciencity-gui.happiness"})
    add_kv_pair(data_list, "health", {"sosciencity-gui.health"})
    add_kv_pair(data_list, "sanity", {"sosciencity-gui.sanity"})
    add_kv_pair(data_list, "bonus", {"sosciencity-gui.bonus"})
    add_kv_pair(data_list, "calorific-demand", {"sosciencity-gui.calorific-demand"})
    add_kv_pair(data_list, "water-demand", {"sosciencity-gui.water-demand"})
    add_kv_pair(data_list, "power-demand", {"sosciencity-gui.power-demand"})

    local caste = castes[caste_id]
    local housing_details = Housing.get(entry)

    local qualities_flow = add_kv_flow(data_list, "qualities", {"sosciencity-gui.qualities"})
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
            quality_text.style.font_color = assessment > 0 and Colors.green or Colors.red
        end
    end

    create_separator_line(flow)

    add_header_label(flow, "header-occupations", {"sosciencity-gui.occupations"})
    create_data_list(flow, "occupations")

    create_separator_line(flow)

    add_header_label(flow, "header-ages", {"sosciencity-gui.ages"})
    create_data_list(flow, "ages")

    create_separator_line(flow)

    add_header_label(flow, "header-genders", {"sosciencity-gui.gender-distribution"})
    create_data_list(flow, "genders")

    create_separator_line(flow)

    local kickout_button =
        flow.add {
        type = "button",
        name = Gui.UNIQUE_PREFIX .. "kickout",
        caption = {"sosciencity-gui.kickout"},
        tooltip = global.technologies.resettlement and {"sosciencity-gui.with-resettlement"} or
            {"sosciencity-gui.no-resettlement"},
        mouse_button_filter = {"left"}
    }
    kickout_button.style.right_margin = 4

    -- call the update function to set the values
    update_housing_general_info_tab(tabbed_pane, entry)
end

local function update_housing_factor_tab(tabbed_pane, entry)
    local content_flow = get_tab_contents(tabbed_pane, "details")

    local happiness_list = content_flow["happiness"]
    update_operand_entries(
        happiness_list,
        Inhabitants.get_nominal_happiness(entry),
        entry[EK.happiness_summands],
        entry[EK.happiness_factors]
    )

    local health_list = content_flow["health"]
    update_operand_entries(
        health_list,
        Inhabitants.get_nominal_health(entry),
        entry[EK.health_summands],
        entry[EK.health_factors]
    )

    local sanity_list = content_flow["sanity"]
    update_operand_entries(
        sanity_list,
        Inhabitants.get_nominal_sanity(entry),
        entry[EK.sanity_summands],
        entry[EK.sanity_factors]
    )
end

local function add_housing_factor_tab(tabbed_pane, entry)
    local flow = create_tab(tabbed_pane, "details", {"sosciencity-gui.details"})

    local happiness_list = create_data_list(flow, "happiness")
    create_operand_entries(
        happiness_list,
        {"sosciencity-gui.happiness"},
        "happiness-summand.",
        Tirislib_Tables.count(HappinessSummand),
        "happiness-factor.",
        Tirislib_Tables.count(HappinessFactor)
    )

    create_separator_line(flow)

    local health_list = create_data_list(flow, "health")
    create_operand_entries(
        health_list,
        {"sosciencity-gui.health"},
        "health-summand.",
        Tirislib_Tables.count(HealthSummand),
        "health-factor.",
        Tirislib_Tables.count(HealthFactor)
    )

    create_separator_line(flow, "line2")

    local sanity_list = create_data_list(flow, "sanity")
    create_operand_entries(
        sanity_list,
        {"sosciencity-gui.sanity"},
        "sanity-summand.",
        Tirislib_Tables.count(SanitySummand),
        "sanity-factor.",
        Tirislib_Tables.count(SanityFactor)
    )

    -- call the update function to set the values
    update_housing_factor_tab(tabbed_pane, entry)
end

local function add_caste_info_tab(tabbed_pane, caste_id)
    local caste = castes[caste_id]

    local flow = create_tab(tabbed_pane, "caste", {"caste-short." .. caste.name})
    flow.style.vertical_spacing = 6
    flow.style.horizontal_align = "center"

    create_caste_sprite(flow, caste_id, 128)

    local caste_data = create_data_list(flow, "caste-infos")
    add_kv_pair(caste_data, "caste-name", {"sosciencity-gui.name"}, {"caste-name." .. caste.name})
    add_kv_pair(caste_data, "description", "", {"technology-description." .. caste.name .. "-caste"})
    add_kv_pair(
        caste_data,
        "taste",
        {"sosciencity-gui.taste"},
        {
            "sosciencity-gui.show-taste",
            Food.taste_names[caste.favored_taste],
            Food.taste_names[caste.least_favored_taste]
        }
    )
    add_kv_pair(
        caste_data,
        "food-count",
        {"sosciencity-gui.food-count"},
        {"sosciencity-gui.show-food-count", caste.minimum_food_count}
    )
    add_kv_pair(
        caste_data,
        "luxury",
        {"sosciencity-gui.luxury"},
        {"sosciencity-gui.show-luxury-needs", 100 * caste.desire_for_luxury, 100 * (1 - caste.desire_for_luxury)}
    )
    add_kv_pair(
        caste_data,
        "room-count",
        {"sosciencity-gui.room-needs"},
        {"sosciencity-gui.show-room-needs", caste.required_room_count}
    )
    add_kv_pair(
        caste_data,
        "comfort",
        {"sosciencity-gui.comfort"},
        {"sosciencity-gui.show-comfort-needs", caste.minimum_comfort}
    )
    add_kv_pair(
        caste_data,
        "power-demand",
        {"sosciencity-gui.power-demand"},
        {"sosciencity-gui.show-power-demand", caste.power_demand / 1000 * Time.second} -- convert from J / tick to kW
    )

    local prefered_flow = add_kv_flow(caste_data, "prefered-qualities", {"sosciencity-gui.prefered-qualities"})
    local disliked_flow = add_kv_flow(caste_data, "disliked-qualities", {"sosciencity-gui.disliked-qualities"})
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
    update_housing_factor_tab(tabbed_pane, entry)
end

local function create_housing_details(container, entry)
    local title = {"", entry[EK.entity].localised_name, "  -  ", display_caste(entry[EK.type])}
    set_details_view_title(container, title)

    local tabbed_pane = create_tabbed_pane(container)
    make_stretchable(tabbed_pane)

    local caste_id = entry[EK.type]
    add_housing_general_info_tab(tabbed_pane, entry, caste_id)
    add_housing_factor_tab(tabbed_pane, entry)
    add_caste_info_tab(tabbed_pane, caste_id)
end

-- << buildings details views >>
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
        add_operand_entry(list, "no-one", {"sosciencity-gui.no-employees"}, "-")
    end
end

local function update_general_building_details(container, entry)
    local tabbed_pane = container.tabpane
    local tab = get_tab_contents(tabbed_pane, "general")
    local building_data = tab.building

    local worker_specification = Buildings.get(entry).workforce
    if worker_specification then
        local count_needed = worker_specification.count
        set_kv_pair_value(building_data, "staff", {"sosciencity-gui.show-staff", entry[EK.worker_count], count_needed})
        local staff_performance = Inhabitants.evaluate_workforce(entry)
        set_kv_pair_value(
            building_data,
            "staff-performance",
            staff_performance >= 0.2 and {"sosciencity-gui.staff-performance", ceil(staff_performance * 100)} or
                {"sosciencity-gui.not-enough-staff", ceil(0.2 * count_needed)}
        )

        local worker_data = tab.workers
        update_worker_list(worker_data, entry)
    end

    local performance = entry[EK.performance]
    if performance then
        set_kv_pair_value(
            building_data,
            "general-performance",
            performance >= 0.2 and {"sosciencity-gui.percentage", ceil(performance * 100)} or
                {"sosciencity-gui.not-working"}
        )
    end

    local type_details = Types.definitions[entry[EK.type]]
    if type_details.affected_by_clockwork then
        local clockwork_value = get_caste_bonus(Type.clockwork)
        set_kv_pair_value(
            building_data,
            "maintenance",
            clockwork_value >= 0 and {"sosciencity-gui.display-good-maintenance", clockwork_value} or
                {"sosciencity-gui.display-bad-maintenance", clockwork_value}
        )
    end
end

local function create_general_building_details(container, entry)
    local entity = entry[EK.entity]
    set_details_view_title(container, entity.localised_name)

    local building_details = Buildings.get(entry)
    local type_details = Types.definitions[entry[EK.type]]

    local tabbed_pane = create_tabbed_pane(container)
    local tab = create_tab(tabbed_pane, "general", {"sosciencity-gui.general"})

    local building_data = create_data_list(tab, "building")

    add_kv_pair(building_data, "building-type", {"sosciencity-gui.type"}, type_details.localised_name)
    add_kv_pair(building_data, "description", "", type_details.localised_description)

    if building_details.range then
        local range = building_details.range
        add_kv_pair(
            building_data,
            "range",
            {"sosciencity-gui.range"},
            (range ~= "global" and {"sosciencity-gui.show-range", building_details.range * 2}) or
                {"sosciencity-gui.global-range"}
        )
    end

    if building_details.power_usage then
        -- convert to kW
        local power = get_reasonable_number(building_details.power_usage * Time.second / 1000)
        add_kv_pair(
            building_data,
            "power",
            {"sosciencity-gui.power-demand"},
            {"sosciencity-gui.current-power-demand", power}
        )
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
        add_kv_pair(building_data, "general-performance", {"sosciencity-gui.general-performance"})
    end

    local worker_specification = building_details.workforce
    if worker_specification then
        add_kv_pair(building_data, "staff", {"sosciencity-gui.staff"})
        add_kv_pair(building_data, "staff-performance")

        add_header_label(tab, "worker-header", {"sosciencity-gui.worker-header"})
        create_data_list(tab, "workers")
    end

    if type_details.affected_by_clockwork then
        add_kv_pair(building_data, "maintenance", {"sosciencity-gui.maintenance"})
    end

    update_general_building_details(container, entry)

    return tabbed_pane
end

local function update_waterwell_details(container, entry)
    update_general_building_details(container, entry)

    local tabbed_pane = container.tabpane
    local building_data = get_tab_contents(tabbed_pane, "general").building

    local near_count = Neighborhood.get_neighbor_count(entry, Type.waterwell)
    local competition_performance = Entity.get_waterwell_competition_performance(entry)
    set_kv_pair_value(
        building_data,
        "competition",
        {"sosciencity-gui.show-waterwell-competition", near_count, display_percentage(competition_performance)}
    )
end

local function create_waterwell_details(container, entry)
    local tabbed_pane = create_general_building_details(container, entry)

    local general = get_tab_contents(tabbed_pane, "general")
    local building_data = general.building

    add_kv_pair(building_data, "competition", {"sosciencity-gui.competition"})

    update_waterwell_details(container, entry)
end

local function update_fishery_details(container, entry)
    update_general_building_details(container, entry)

    local tabbed_pane = container.tabpane
    local building_data = get_tab_contents(tabbed_pane, "general").building

    local building_details = Buildings.get(entry)
    set_kv_pair_value(
        building_data,
        "water-tiles",
        {"sosciencity-gui.fraction", entry[EK.water_tiles], building_details.water_tiles, {"sosciencity-gui.tiles"}}
    )
end

local function create_fishery_details(container, entry)
    local tabbed_pane = create_general_building_details(container, entry)

    local general = get_tab_contents(tabbed_pane, "general")
    local building_data = general.building

    add_kv_pair(building_data, "water-tiles", {"sosciencity-gui.water-tiles"})

    update_fishery_details(container, entry)
end

local function update_hunting_hut_details(container, entry)
    update_general_building_details(container, entry)

    local tabbed_pane = container.tabpane
    local building_data = get_tab_contents(tabbed_pane, "general").building

    local building_details = Buildings.get(entry)
    set_kv_pair_value(
        building_data,
        "tree-count",
        {"sosciencity-gui.fraction", entry[EK.tree_count], building_details.tree_count, ""}
    )
end

local function create_hunting_hut_details(container, entry)
    local tabbed_pane = create_general_building_details(container, entry)

    local general = get_tab_contents(tabbed_pane, "general")
    local building_data = general.building

    add_kv_pair(building_data, "tree-count", {"sosciencity-gui.tree-count"})

    update_hunting_hut_details(container, entry)
end

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
                {"sosciencity-gui.migration", get_migration_string(castes[caste].immigration_coefficient * Time.minute)}
            }
        )
        set_kv_pair_visibility(immigrants_list, key, Inhabitants.caste_is_researched(caste))
    end
end

local function create_immigration_port_details(container, entry)
    local tabbed_pane = create_general_building_details(container, entry)

    local general = get_tab_contents(tabbed_pane, "general")
    local building_data = general.building
    local building_details = Buildings.get(entry)

    add_kv_pair(building_data, "next-wave", {"sosciencity-gui.next-wave"})
    add_kv_pair(
        building_data,
        "materials",
        {"sosciencity-gui.materials"},
        display_materials(building_details.materials)
    )
    add_kv_pair(
        building_data,
        "capacity",
        {"sosciencity-gui.capacity"},
        {"sosciencity-gui.show-port-capacity", building_details.capacity}
    )

    create_separator_line(general)

    add_header_label(general, "header-immigration", {"sosciencity-gui.estimated-immigrants"})
    local immigrants_list = create_data_list(general, "immigration")

    for caste in pairs(immigration) do
        add_kv_pair(immigrants_list, tostring(caste), Types.definitions[caste].localised_name)
    end

    update_immigration_port_details(container, entry)
end

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
    [Type.dumpster] = {
        creater = create_general_building_details,
        updater = update_general_building_details
    },
    [Type.empty_house] = {
        creater = create_empty_housing_details
    },
    [Type.fishery] = {
        creater = create_fishery_details,
        updater = update_fishery_details
    },
    [Type.hospital] = {
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
        creater = create_general_building_details,
        updater = update_general_building_details
    },
    [Type.water_distributer] = {
        creater = create_general_building_details,
        updater = update_general_building_details
    },
    [Type.waterwell] = {
        creater = create_waterwell_details,
        updater = update_waterwell_details
    }
}

-- add the caste specifications
for caste_id in pairs(Castes.values) do
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

---------------------------------------------------------------------------------------------------
-- << handlers >>
--- Event handler function for clicks on caste assign buttons.
function Gui.handle_caste_button(player_index, caste_id)
    local entry = Register.try_get(global.details_view[player_index])
    if not entry then
        return
    end

    Inhabitants.try_allow_for_caste(entry, caste_id, true)
end

--- Event handler function for clicks on the kickout button.
function Gui.handle_kickout_button(player_index, button)
    local entry = Register.try_get(global.details_view[player_index])
    if not entry then
        return
    end

    if is_confirmed(button) then
        Register.change_type(entry, Type.empty_house)
        Gui.rebuild_details_view_for_entry(entry)
        return
    end
end

---------------------------------------------------------------------------------------------------
-- << general >>
--- Initializes the guis for the given player. Gets called after a new player gets created.
--- @param player Player
function Gui.create_guis_for_player(player)
    create_city_info_for_player(player)
    create_details_view_for_player(player)
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

return Gui
