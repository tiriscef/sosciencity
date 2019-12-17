Gui = {}

---------------------------------------------------------------------------------------------------
-- << formatting functions >>
local function get_bonus_string(caste_id)
    local bonus = Inhabitants.get_caste_bonus(caste_id)
    if caste_id == TYPE_CLOCKWORK and global.use_penalty then
        bonus = bonus - 80
    end
    return string.format("%+d", bonus)
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
    local caste = Types.caste_names[caste_id]

    local frame =
        container.add {
        type = "frame",
        name = "caste-" .. caste_id,
        direction = "vertical"
    }
    frame.style.padding = 0
    frame.style.left_margin = 4

    local sprite =
        frame.add {
        type = "sprite",
        name = "caste-sprite",
        sprite = "technology/" .. caste .. "-caste",
        tooltip = {"caste-name." .. caste}
    }
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
        caption = {"caste-bonus.display-" .. caste, get_bonus_string(caste_id)},
        tooltip = {"caste-bonus." .. caste}
    }
    bonus_label.style.minimal_width = CITY_INFO_SPRITE_SIZE
    bonus_label.style.horizontal_align = "center"
end

function Gui.create_city_info_for(player)
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

    for id, _ in pairs(Types.caste_names) do
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
        "caste-bonus.display-" .. Types.get_caste_name(caste_id),
        get_bonus_string(caste_id)
    }
end

local function update_city_info(frame)
    update_population_flow(frame)

    for id, _ in pairs(Types.caste_names) do
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
            Gui.create_city_info_for(player)
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << entity details view >>
local DETAILS_VIEW_NAME = "sosciencity-details"

-- << empty housing details view >>
local function add_caste_chooser_tab(tabbed_pane, details)
    local tab =
        tabbed_pane.add {
        type = "tab",
        name = "caste",
        caption = {"sosciencity-gui.caste-choose-title"}
    }
    local flow =
        tabbed_pane.add {
        type = "flow",
        name = "button-flow",
        direction = "vertical"
    }

    for _, name in pairs(Types.caste_names) do
        local caste_name = {"caste-name." .. name}
        flow.add {
            type = "button",
            name = name,
            caption = caste_name,
            tooltip = {"sosciencity-gui.move-in", caste_name},
            mouse_button_filter = {"left"}
        }
    end

    tabbed_pane.add_tab(tab, flow)
end

local function add_house_info_tab(tabbed_pane, details)
    local tab =
        tabbed_pane.add {
        type = "tab",
        name = "house",
        caption = {"sosciencity-gui.building-info"}
    }
    local flow =
        tabbed_pane.add {
        type = "flow",
        name = "pairs",
        direction = "horizontal"
    }

    tabbed_pane.add_tab(tab, flow)
end

local function create_empty_housing_details(container, entry)
    local details = Housing(entry)

    container.caption = entry.entity.localised_name

    local tab_pane =
        container.add {
        type = "tabbed-pane",
        name = "tabpane"
    }
    add_caste_chooser_tab(tab_pane, details)
    add_house_info_tab(tab_pane, details)
end

-- << housing details view >>
local function create_housing_details(container, entry)
    -- general info: building, inhabitants, happiness, health, kicking people out
    -- happiness and its sources
    -- health and its sources
end

-- << general details view functions >>
function Gui.create_details_view_for(player)
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
    frame.visible = false
end

local function get_details_view(player)
    local details_view = player.gui.screen[DETAILS_VIEW_NAME]

    -- we check if the gui still exists, as other mods can delete them
    if details_view ~= nil and details_view.valid then
        return details_view
    else
        Gui.create_details_view_for(player)
        return get_details_view(player)
    end
end

-- table with (type, update-function) pairs
local content_updaters = {}

function Gui.update_details_view()
    for player_id, unit_number in pairs(global.details_view) do
        local entry = global.register[unit_number]

        -- check if the entity hasn't been unregistered in the meantime
        if not entry then
            Gui.close_details_view_for(game.players[player_id])
        else
            if content_updaters[entry.type] then
                content_updaters[entry.type](get_details_view(game.players[player_id]), entry)
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

function Gui.open_details_view_for(player, entity)
    local details_view = get_details_view(player)
    local entry = global.register[entity.unit_number]
    if not entry then
        return
    end

    if detail_view_builders[entry.type] then
        details_view.clear()
        detail_view_builders[entry.type](details_view, entry)
        details_view.visible = true
        global.details_view[player.index] = entity.unit_number
    end
end

function Gui.close_details_view_for(player)
    local details_view = get_details_view(player)
    details_view.visible = false
    global.details_view[player.index] = nil
    details_view.caption = nil
    details_view.clear()
end

---------------------------------------------------------------------------------------------------
-- << general >>
function Gui.create_guis_for(player)
    Gui.create_city_info_for(player)
    Gui.create_details_view_for(player)
end

function Gui.init()
    global.details_view = {}

    for _, player in pairs(game.players) do
        Gui.create_guis_for(player)
    end
end

return Gui
