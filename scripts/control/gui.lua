Gui = {}

Gui.CITY_INFO_SPRITE_SIZE = 48

local function add_population_flow(frame)
    local population_count = Inhabitants.get_population_count()

    local flow =
        frame.add {
        type = "flow",
        name = "population",
        direction = "vertical"
    }

    local head = flow.add {
        type = "label",
        name = "population-head",
        caption = {"sos-gui.population"}
    }
    head.style.minimal_width = Gui.CITY_INFO_SPRITE_SIZE
    head.style.horizontal_align = "center"
    head.style.height = Gui.CITY_INFO_SPRITE_SIZE
    head.style.vertical_align = "bottom"

    local count = flow.add {
        type = "label",
        name = "population-count",
        caption = population_count
    }
    count.style.minimal_width = Gui.CITY_INFO_SPRITE_SIZE
    count.style.horizontal_align = "center"
end

local function update_population_flow(frame)
    local population_flow = frame["population"]
    local population_count = Inhabitants.get_population_count()

    population_flow["population-count"].caption = population_count
end

local function add_caste_flow(frame, caste_id)
    local caste = Types.caste_names[caste_id]

    local flow =
        frame.add {
        type = "flow",
        name = "caste-" .. caste_id,
        direction = "vertical"
    }

    local sprite = flow.add {
        type = "sprite",
        name = "caste-sprite",
        sprite = "technology/" .. caste .. "-caste",
        tooltip = {"caste-name." .. caste}
    }
    sprite.style.height = Gui.CITY_INFO_SPRITE_SIZE
    sprite.style.width = Gui.CITY_INFO_SPRITE_SIZE
    sprite.style.stretch_image_to_widget_size = true
    sprite.style.horizontal_align = "center"

    local population_label = flow.add {
        type = "label",
        name = "caste-population",
        caption = global.population[caste_id],
        tooltip = "population count"
    }
    population_label.style.minimal_width = Gui.CITY_INFO_SPRITE_SIZE
    population_label.style.horizontal_align = "center"
end

local function update_caste_flow(frame, caste_id)
    local caste_flow = frame["caste-" .. caste_id]

    -- the frame may not yet exist
    if caste_flow == nil then
        add_caste_flow(frame, caste_id)
        return
    end

    caste_flow["caste-population"].caption = global.population[caste_id]
end

function Gui.create_city_info_for(player)
    local frame =
        player.gui.top.add {
        type = "flow",
        name = "sos-city-info",
        direction = "horizontal"
    }

    add_population_flow(frame)

    for id, _ in pairs(Types.caste_names) do
        if Inhabitants.caste_is_researched(id) then
            add_caste_flow(frame, id)
        end
    end
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
        local city_info_gui = player.gui.top["sos-city-info"]

        -- we check if the gui still exists, as other mods can delete them
        if city_info_gui ~= nil and city_info_gui.valid then
            update_city_info(city_info_gui)
        else
            Gui.create_city_info_for(player)
        end
    end
end

return Gui
