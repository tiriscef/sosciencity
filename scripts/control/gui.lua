Gui = {}

-- this should be added to every element which needs an event handler
-- because the event handler is called for every gui in existance
-- so I need to ensure that I'm not reacting to another mods gui
Gui.UNIQUE_PREFIX = "sosciencity-"
---------------------------------------------------------------------------------------------------
-- << formatting functions >>
local function get_bonus_string(caste_id)
    local bonus = Inhabitants.get_caste_bonus(caste_id)
    if caste_id == TYPE_CLOCKWORK and global.use_penalty then
        bonus = bonus - 80
    end
    return string.format("%+d", bonus)
end

local function get_reasonable_number(number)
    return string.format("%.01d", number)
end

local function get_comfort_localised_string(comfort)
    return {"", comfort .. "  -  ", {"comfort-scale." .. comfort}}
end

local function get_caste_localised_string(caste_id)
    return {"caste-name." .. Caste(caste_id).name}
end

local function get_convergence_localised_string(current, target)
    return {"sosciencity-gui.convergenting-value", get_reasonable_number(current), get_reasonable_number(target)}
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

local function add_kv_pair(data_list, key, key_caption, value_caption)
    local key_label =
        data_list.add {
        type = "label",
        name = "key-" .. key,
        caption = key_caption
    }
    key_label.style.font = "default-bold"

    local value_label =
        data_list.add {
        type = "label",
        name = key,
        caption = value_caption
    }
    value_label.style.horizontally_stretchable = true
    value_label.style.single_line = false
end

local function get_kv_pair(data_list, key)
    return data_list["key-" .. key], data_list[key]
end

local function set_key(data_list, key, key_caption)
    data_list["key-" .. key].caption = key_caption
end

local function set_datalist_value(data_list, key, value_caption)
    data_list[key].caption = value_caption
end

local function set_datalist_value_tooltip(datalist, key, tooltip)
    datalist[key].tooltip = tooltip
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
    local caste_name = Caste(caste_id).name

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

---------------------------------------------------------------------------------------------------
-- << city info gui >>
local CITY_INFO_NAME = "sosciencity-city-info"
local CITY_INFO_SPRITE_SIZE = 48

local function add_population_flow(container)
    local population_count = Inhabitants.get_population_count()

    local frame =
        container.add {
        type = "frame",
        name = "population",
        direction = "vertical"
    }
    frame.style.padding = 0

    local head =
        frame.add {
        type = "label",
        name = "population-head",
        caption = {"sosciencity-gui.population"}
    }
    head.style.horizontal_align = "center"

    local count =
        frame.add {
        type = "label",
        name = "population-count",
        caption = population_count
    }
    count.style.horizontal_align = "center"
end

local function update_population_flow(frame)
    local population_flow = frame["population"]
    local population_count = Inhabitants.get_population_count()

    population_flow["population-count"].caption = population_count
end

local function add_caste_flow(container, caste_id)
    local caste_name = Caste(caste_id).name

    local frame =
        container.add {
        type = "frame",
        name = "caste-" .. caste_id,
        direction = "vertical"
    }
    frame.style.padding = 0
    frame.style.left_margin = 4

    local sprite = create_caste_sprite(frame, caste_id, CITY_INFO_SPRITE_SIZE)
    sprite.style.height = CITY_INFO_SPRITE_SIZE
    sprite.style.width = CITY_INFO_SPRITE_SIZE
    sprite.style.stretch_image_to_widget_size = true
    sprite.style.horizontal_align = "center"

    local population_label =
        frame.add {
        type = "label",
        name = "caste-population",
        caption = global.population[caste_id],
        tooltip = "population count"
    }
    population_label.style.minimal_width = CITY_INFO_SPRITE_SIZE
    population_label.style.horizontal_align = "center"

    local bonus_label =
        frame.add {
        type = "label",
        name = "caste-bonus",
        caption = {"caste-bonus.display-" .. caste_name, get_bonus_string(caste_id)},
        tooltip = {"caste-bonus." .. caste_name}
    }
    bonus_label.style.minimal_width = CITY_INFO_SPRITE_SIZE
    bonus_label.style.horizontal_align = "center"
end

function Gui.create_city_info_for_player(player)
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

    add_population_flow(frame)

    for id, _ in pairs(Caste.values) do
        if Inhabitants.caste_is_researched(id) then
            add_caste_flow(frame, id)
        end
    end
end

local function update_caste_flow(container, caste_id)
    local caste_frame = container["caste-" .. caste_id]

    -- the frame may not yet exist
    if caste_frame == nil then
        add_caste_flow(container, caste_id)
        return
    end

    caste_frame["caste-population"].caption = global.population[caste_id]
    caste_frame["caste-bonus"].caption = {
        "caste-bonus.display-" .. Caste(caste_id).name,
        get_bonus_string(caste_id)
    }
end

local function update_city_info(frame)
    update_population_flow(frame)

    for id, _ in pairs(Caste.values) do
        if Inhabitants.caste_is_researched(id) then
            update_caste_flow(frame, id)
        end
    end

    frame.visible = (Inhabitants.get_population_count() ~= 0)
end

function Gui.update_city_info()
    for _, player in pairs(game.players) do
        local city_info_gui = player.gui.top[CITY_INFO_NAME]

        -- we check if the gui still exists, as other mods can delete them
        if city_info_gui ~= nil and city_info_gui.valid then
            update_city_info(city_info_gui)
        else
            Gui.create_city_info_for_player(player)
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << entity details view >>
local DETAILS_VIEW_NAME = "sosciencity-details"

local function set_details_view_title(container, caption)
    container.parent.caption = caption
end

-- << empty housing details view >>
local function add_caste_chooser_tab(tabbed_pane, details)
    local flow = create_tab(tabbed_pane, "caste-chooser", {"sosciencity-gui.caste"})

    flow.style.horizontal_align = "center"
    flow.style.vertical_align = "center"
    flow.style.vertical_spacing = 6

    local at_least_one = false
    for caste_id, caste in pairs(Caste.values) do
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
            elseif Caste(caste_id).required_room_count > details.room_count then
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

local function add_empty_house_info_tab(tabbed_pane, details)
    local flow = create_tab(tabbed_pane, "house-info", {"sosciencity-gui.building-info"})

    local data_list = create_data_list(flow, "house-infos")
    add_kv_pair(data_list, "room_count", {"sosciencity-gui.room-count"}, details.room_count)
    add_kv_pair(data_list, "comfort", {"sosciencity-gui.comfort"}, get_comfort_localised_string(details.comfort))
end

local function create_empty_housing_details(container, entry)
    set_details_view_title(container, entry[ENTITY].localised_name)

    local tab_pane =
        container.add {
        type = "tabbed-pane",
        name = "tabpane"
    }

    local house_details = Housing.get(entry)
    add_caste_chooser_tab(tab_pane, house_details)
    add_empty_house_info_tab(tab_pane, house_details)
end

-- << housing details view >>
local function update_housing_general_info_tab(tabbed_pane, entry)
    local general_list = get_tab_contents(tabbed_pane, "general")["general-infos"]
    local inhabitants = entry[INHABITANTS]

    set_datalist_value(
        general_list,
        "capacity",
        {"sosciencity-gui.display-capacity", inhabitants, Housing.get_capacity(entry)}
    )
    set_datalist_value_tooltip(
        general_list,
        "capacity",
        (entry[TREND] > 0) and {"sosciencity-gui.positive-trend"} or {"sosciencity-gui.negative-trend"}
    )

    set_datalist_value(
        general_list,
        "happiness",
        get_convergence_localised_string((inhabitants > 0) and entry[HAPPINESS] or 0, Inhabitants.get_nominal_happiness(entry))
    )
    set_datalist_value(
        general_list,
        "healthiness",
        get_convergence_localised_string((inhabitants > 0) and entry[HEALTH] or 0, Inhabitants.get_nominal_health(entry))
    )
    set_datalist_value(
        general_list,
        "mental-healthiness",
        get_convergence_localised_string((inhabitants > 0) and entry[MENTAL_HEALTH] or 0, Inhabitants.get_nominal_mental_health(entry))
    )
end

local function add_housing_general_info_tab(tabbed_pane, entry)
    local flow = create_tab(tabbed_pane, "general", {"sosciencity-gui.general"})

    flow.style.vertical_spacing = 6
    flow.style.horizontal_align = "right"

    local data_list = create_data_list(flow, "general-infos")
    add_kv_pair(data_list, "caste", {"sosciencity-gui.caste"}, get_caste_localised_string(entry[TYPE]))

    add_kv_pair(data_list, "capacity", {"sosciencity-gui.capacity"})
    add_kv_pair(data_list, "happiness", {"sosciencity-gui.happiness"})
    add_kv_pair(data_list, "healthiness", {"sosciencity-gui.healthiness"})
    add_kv_pair(data_list, "mental-healthiness", {"sosciencity-gui.mental-healthiness"})

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

local function add_caste_info_tab(tabbed_pane, caste_id)
    local caste = Caste(caste_id)

    local flow = create_tab(tabbed_pane, "caste", {"caste-short." .. caste.name})
    flow.style.vertical_spacing = 6
    flow.style.horizontal_align = "center"

    create_caste_sprite(flow, caste_id, 128)

    local caste_general = create_data_list(flow, "caste-infos")
    add_kv_pair(caste_general, "caste-name", {"sosciencity-gui.name"}, {"caste-name." .. caste.name})
    add_kv_pair(caste_general, "description", "", {"technology-description." .. caste.name .. "-caste"})

    local caste_food = create_data_list(flow, "food-infos")
    add_kv_pair(
        caste_food,
        "fav-taste",
        {"sosciencity-gui.fav-taste"},
        {"taste-category." .. Types.taste_names[caste.favored_taste]}
    )
    add_kv_pair(
        caste_food,
        "lfav-taste",
        {"sosciencity-gui.lfav-taste"},
        {"taste-category." .. Types.taste_names[caste.least_favored_taste]}
    )
    add_kv_pair(
        caste_food,
        "food-count",
        {"sosciencity-gui.food-count"},
        {"sosciencity-gui.display-food-count", caste.minimum_food_count}
    )
    add_kv_pair(
        caste_food,
        "luxury",
        {"sosciencity-gui.luxury"},
        {"sosciencity-gui.display-luxury-needs", 100 * caste.desire_for_luxury, 100 * (1 - caste.desire_for_luxury)}
    )

    local housing_needs = create_data_list(flow, "housing")
    add_kv_pair(
        housing_needs,
        "room-count",
        {"sosciencity-gui.room-needs"},
        {"sosciencity-gui.display-room-needs", caste.required_room_count}
    )
    add_kv_pair(
        housing_needs,
        "comfort",
        {"sosciencity-gui.comfort"},
        {"sosciencity-gui.display-comfort-needs", caste.minimum_comfort}
    )
end

local function update_housing_details(container, entry)
    local tabbed_pane = container.tabpane
    update_housing_general_info_tab(tabbed_pane, entry)
end

local function create_housing_details(container, entry)
    local title = {"", entry[ENTITY].localised_name, "  -  ", get_caste_localised_string(entry[TYPE])}
    set_details_view_title(container, title)

    local tab_pane =
        container.add {
        type = "tabbed-pane",
        name = "tabpane"
    }
    make_stretchable(tab_pane)

    add_housing_general_info_tab(tab_pane, entry)
    add_caste_info_tab(tab_pane, entry[TYPE])
    -- general info: building, inhabitants, happiness, health, kicking people out
    -- happiness and its sources
    -- health and its sources
end

-- << general details view functions >>
function Gui.create_details_view_for_player(player)
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
    frame.style.minimal_height = 300
    frame.style.maximal_height = 600
    frame.style.horizontally_stretchable = true
    make_squashable(frame)
    set_padding(frame, 4)

    local nested =
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
        Gui.create_details_view_for_player(player)
        return get_details_view(player)
    end
end

-- table with (type, update-function) pairs
local content_updaters = {
    [TYPE_CLOCKWORK] = update_housing_details,
    [TYPE_EMBER] = update_housing_details,
    [TYPE_GUNFIRE] = update_housing_details,
    [TYPE_GLEAM] = update_housing_details,
    [TYPE_FOUNDRY] = update_housing_details,
    [TYPE_ORCHID] = update_housing_details,
    [TYPE_AURORA] = update_housing_details
}

function Gui.update_details_view()
    for player_id, unit_number in pairs(global.details_view) do
        local entry = Register.try_get(unit_number)

        -- check if the entity hasn't been unregistered in the meantime
        if not entry then
            Gui.close_details_view_for_player(game.players[player_id])
        else
            if content_updaters[entry[TYPE]] then
                content_updaters[entry[TYPE]](get_details_view(game.players[player_id]).nested, entry)
            end
        end
    end
end

-- table with (type, build-function) pairs
local detail_view_builders = {
    [TYPE_EMPTY_HOUSE] = create_empty_housing_details,
    [TYPE_CLOCKWORK] = create_housing_details,
    [TYPE_EMBER] = create_housing_details,
    [TYPE_GUNFIRE] = create_housing_details,
    [TYPE_GLEAM] = create_housing_details,
    [TYPE_FOUNDRY] = create_housing_details,
    [TYPE_ORCHID] = create_housing_details,
    [TYPE_AURORA] = create_housing_details
}

function Gui.open_details_view_for_player(player, unit_number)
    local details_view = get_details_view(player)
    local entry = Register.try_get(unit_number)
    if not entry then
        return
    end

    if detail_view_builders[entry[TYPE]] then
        details_view.nested.clear()
        detail_view_builders[entry[TYPE]](details_view.nested, entry)
        details_view.visible = true
        global.details_view[player.index] = unit_number
    end
end

function Gui.close_details_view_for_player(player)
    local details_view = get_details_view(player)
    details_view.visible = false
    global.details_view[player.index] = nil
    details_view.caption = nil
    details_view.nested.clear()
end

function Gui.rebuild_details_view_for_entry(entry)
    local unit_number = entry[ENTITY].unit_number

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
function Gui.handle_caste_button(player_index, caste_id)
    local entry = Register.try_get(global.details_view[player_index])
    if not entry then
        return
    end

    local changed = Inhabitants.try_allow_for_caste(entry, caste_id)
    if changed then
        Gui.rebuild_details_view_for_entry(entry)
    end
end

function Gui.handle_kickout_button(player_index, button)
    local entry = Register.try_get(global.details_view[player_index])
    if not entry then
        return
    end

    if is_confirmed(button) then
        Inhabitants.remove_house(entry)
        Register.change_type(entry, TYPE_EMPTY_HOUSE)
        Gui.rebuild_details_view_for_entry(entry)
        return
    end
end

---------------------------------------------------------------------------------------------------
-- << general >>
function Gui.create_guis_for_player(player)
    Gui.create_city_info_for_player(player)
    Gui.create_details_view_for_player(player)
end

function Gui.init()
    global.details_view = {}

    for _, player in pairs(game.players) do
        Gui.create_guis_for_player(player)
    end
end

return Gui
