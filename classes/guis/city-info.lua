--- The gui that is always on the top left corner and provides quick information about populations and caste bonuses.
Gui.CityInfo = {}

-- enums
local Type = require("enums.type")

-- constants
local Castes = require("constants.castes")
local Color = require("constants.color")
local WeatherLocales = require("constants.weather-locales")

-- local often used globals for microscopic performance gains
local castes = Castes.values
local Gui = Gui
local Register = Register
local Inhabitants = Inhabitants
local max = math.max
local round_to_step = Tirislib.Utils.round_to_step

local Table = Tirislib.Tables

local climate_locales = WeatherLocales.climate
local humidity_locales = WeatherLocales.humidity
local weather_locales = WeatherLocales.weather

local CITY_INFO_NAME = "sosciencity-city-info"

local function update_population_flow(container)
    local datalist = container.general.flow.datalist

    datalist.population.caption = Table.array_sum(global.population)

    local machine_count = Register.get_machine_count()
    local machine_count_label = datalist.machine_count
    machine_count_label.caption = machine_count
    machine_count_label.tooltip = {
        "sosciencity.tooltip-machines",
        machine_count
    }

    datalist.turret_count.caption = Register.get_type_count(Type.turret)

    local climate = global.current_climate
    local humidity = global.current_humidity
    datalist.weather.caption = weather_locales[humidity][climate]
    datalist.weather.tooltip = {
        "sosciencity.explain-weather",
        climate_locales[climate],
        humidity_locales[humidity]
    }
    datalist["key-weather"].tooltip = {
        "sosciencity.explain-weather",
        climate_locales[climate],
        humidity_locales[humidity]
    }
end

local function add_city_info_entry(data_list, key, key_caption, caption_color)
    local key_label =
        data_list.add {
        type = "label",
        name = "key-" .. key,
        caption = key_caption
    }
    local key_style = key_label.style
    key_style.font = "default-semibold"
    key_style.font_color = Color.tooltip_orange

    local value_label =
        data_list.add {
        type = "label",
        name = key
    }
    local style = value_label.style
    style.horizontal_align = "right"
    style.minimal_width = 40
    style.font_color = caption_color
end

local function create_population_flow(container)
    local frame =
        container.add {
        type = "frame",
        name = "general",
        direction = "horizontal"
    }
    frame.style.padding = 2

    local flow =
        frame.add {
        type = "flow",
        name = "flow",
        direction = "vertical"
    }

    local button =
        flow.add {
        type = "button",
        name = "sosciencity-open-city-view",
        caption = {"sosciencity.city"},
        tags = {sosciencity_gui_event = "toggle-city-view-opened"}
    }
    button.style.height = 24

    local datalist =
        flow.add {
        type = "table",
        name = "datalist",
        column_count = 2
    }
    local style = datalist.style
    style.right_cell_padding = 0
    style.left_cell_padding = 0
    style.column_alignments[2] = "right"

    add_city_info_entry(datalist, "population", {"sosciencity.population"})
    add_city_info_entry(datalist, "machine_count", {"sosciencity.machines"})
    add_city_info_entry(datalist, "turret_count", {"sosciencity.turrets"})
    add_city_info_entry(datalist, "weather", {"sosciencity.weather"}, Color.yellowish_green)

    update_population_flow(container)
end

local tooltip_fns = {
    [Type.clockwork] = function()
        local housing = global.housing_capacity[Type.clockwork]
        local housing_improvised = housing[true]
        local points = round_to_step(global.caste_points[Type.clockwork], 0.1)
        local machines = Register.get_machine_count()
        local maintenance_cost = machines

        local points_locale = points
        if global.maintenance_enabled and maintenance_cost > 0 then
            local remaining_points = points - max(0, maintenance_cost - global.starting_clockwork_points)
            points_locale = {
                "sosciencity.tooltip-maintenance-calc",
                remaining_points,
                points,
                global.starting_clockwork_points,
                maintenance_cost
            }
            points = remaining_points
        end

        local ret = {
            "",
            {
                "sosciencity.tooltip-caste-general",
                global.population[Type.clockwork],
                housing[false] + housing_improvised,
                housing_improvised,
                points_locale
            }
        }

        if points >= 0 then
            ret[#ret + 1] = {
                "sosciencity.tooltip-clockwork-bonus",
                machines,
                round_to_step(points / max(1, machines), 0.1),
                global.caste_bonuses[Type.clockwork]
            }
        else
            ret[#ret + 1] = {"sosciencity.tooltip-insufficient-maintenance", global.caste_bonuses[Type.clockwork]}
        end

        return ret
    end,
    [Type.orchid] = function()
        local housing = global.housing_capacity[Type.orchid]
        local housing_improvised = housing[true]
        local points = round_to_step(global.caste_points[Type.orchid], 0.1)
        return {
            "",
            {
                "sosciencity.tooltip-caste-general",
                global.population[Type.orchid],
                housing[false] + housing_improvised,
                housing_improvised,
                points
            },
            {
                "sosciencity.tooltip-orchid-bonus",
                global.caste_bonuses[Type.orchid]
            }
        }
    end,
    [Type.gunfire] = function()
        local housing = global.housing_capacity[Type.gunfire]
        local housing_improvised = housing[true]
        local points = round_to_step(global.caste_points[Type.gunfire], 0.1)
        local turrets = Register.get_type_count(Type.turret)
        return {
            "",
            {
                "sosciencity.tooltip-caste-general",
                global.population[Type.gunfire],
                housing[false] + housing_improvised,
                housing_improvised,
                points
            },
            {
                "sosciencity.tooltip-gunfire-bonus",
                turrets,
                round_to_step(points / max(1, turrets), 0.1),
                global.caste_bonuses[Type.gunfire]
            }
        }
    end,
    [Type.ember] = function()
        local housing = global.housing_capacity[Type.ember]
        local housing_improvised = housing[true]
        local points = round_to_step(global.caste_points[Type.ember], 0.1)
        local non_ember_pop = Table.array_sum(global.population) - global.population[Type.ember]
        return {
            "",
            {
                "sosciencity.tooltip-caste-general",
                global.population[Type.ember],
                housing[false] + housing_improvised,
                housing_improvised,
                points
            },
            {
                "sosciencity.tooltip-ember-bonus",
                non_ember_pop,
                round_to_step(points / max(1, non_ember_pop), 0.01),
                global.caste_bonuses[Type.ember]
            }
        }
    end,
    [Type.foundry] = function()
        local housing = global.housing_capacity[Type.foundry]
        local housing_improvised = housing[true]
        local points = round_to_step(global.caste_points[Type.foundry], 0.1)
        return {
            "",
            {
                "sosciencity.tooltip-caste-general",
                global.population[Type.foundry],
                housing[false] + housing_improvised,
                housing_improvised,
                points
            },
            {
                "sosciencity.tooltip-foundry-bonus",
                global.caste_bonuses[Type.foundry]
            }
        }
    end,
    [Type.gleam] = function()
        local housing = global.housing_capacity[Type.gleam]
        local housing_improvised = housing[true]
        local points = round_to_step(global.caste_points[Type.gleam], 0.1)
        return {
            "",
            {
                "sosciencity.tooltip-caste-general",
                global.population[Type.gleam],
                housing[false] + housing_improvised,
                housing_improvised,
                points
            },
            {
                "sosciencity.tooltip-gleam-bonus",
                global.caste_bonuses[Type.gleam]
            }
        }
    end,
    [Type.aurora] = function()
        local housing = global.housing_capacity[Type.aurora]
        local housing_improvised = housing[true]
        local points = round_to_step(global.caste_points[Type.aurora], 0.1)
        return {
            "",
            {
                "sosciencity.tooltip-caste-general",
                global.population[Type.aurora],
                housing[false] + housing_improvised,
                housing_improvised,
                points
            },
            {
                "sosciencity.tooltip-aurora-bonus",
                global.caste_bonuses[Type.aurora]
            }
        }
    end,
    [Type.plasma] = function()
        local housing = global.housing_capacity[Type.plasma]
        local housing_improvised = housing[true]
        local points = round_to_step(global.caste_points[Type.plasma], 0.1)
        local non_plasma_pop = Table.array_sum(global.population) - global.population[Type.plasma]
        return {
            "",
            {
                "sosciencity.tooltip-caste-general",
                global.population[Type.plasma],
                housing[false] + housing_improvised,
                housing_improvised,
                points
            },
            {
                "sosciencity.tooltip-plasma-bonus",
                non_plasma_pop,
                round_to_step(points / max(1, non_plasma_pop), 0.01),
                global.caste_bonuses[Type.plasma]
            }
        }
    end
}

local function update_caste_flow(container, caste_id, caste_tooltips)
    local caste_frame = container["caste-" .. caste_id]

    -- Always show the clockwork caste, so the player has a chance to understand the maintenance mechanic.
    local visibility = (caste_id == Type.clockwork) or Inhabitants.caste_is_researched(caste_id)
    caste_frame.visible = visibility

    if visibility then
        local flow = caste_frame.flow

        local population_label = flow["caste-population"]
        population_label.caption = global.population[caste_id]

        local bonus_value = global.caste_bonuses[caste_id]
        local caste_bonus_label = flow["caste-bonus"]
        caste_bonus_label.caption = {
            "caste-bonus.show-" .. castes[caste_id].name,
            bonus_value
        }
        caste_bonus_label.style.font_color =
            ((bonus_value > 0) and Color.green) or ((bonus_value < 0) and Color.red) or Color.white

        local tooltip = caste_tooltips[caste_id]
        caste_frame.tooltip = tooltip
        flow.tooltip = tooltip
        flow["caste-sprite"].tooltip = tooltip
        population_label.tooltip = tooltip
        caste_bonus_label.tooltip = tooltip
    end
end

local function create_caste_flow(container, caste_id, caste_tooltips)
    local frame =
        container.add {
        type = "frame",
        name = "caste-" .. caste_id,
        direction = "vertical"
    }
    local frame_style = frame.style
    frame_style.padding = 0
    frame_style.left_margin = 4

    local flow =
        frame.add {
        type = "flow",
        name = "flow",
        direction = "vertical"
    }
    flow.style.vertical_spacing = 0
    flow.style.horizontal_align = "center"

    local sprite = Gui.Elements.Sprite.create_caste_sprite(flow, caste_id, 48)
    sprite.style.horizontal_align = "center"

    flow.add {
        type = "label",
        name = "caste-population"
    }

    flow.add {
        type = "label",
        name = "caste-bonus"
    }

    update_caste_flow(container, caste_id, caste_tooltips or {})
end

function Gui.CityInfo.create(player, caste_tooltips)
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

    create_population_flow(frame)

    for id in pairs(castes) do
        create_caste_flow(frame, id, caste_tooltips)
    end
end

--- Updates the city info gui for all existing players.
function Gui.CityInfo.update()
    local caste_tooltips = {}
    for id in pairs(castes) do
        caste_tooltips[id] = tooltip_fns[id]()
    end

    for _, player in pairs(game.connected_players) do
        local city_info_gui = player.gui.top[CITY_INFO_NAME]

        -- we check if the gui still exists, as other mods can delete them
        if city_info_gui ~= nil and city_info_gui.valid then
            update_population_flow(city_info_gui)

            for id in pairs(castes) do
                update_caste_flow(city_info_gui, id, caste_tooltips)
            end
        else
            Gui.CityInfo.create(player, caste_tooltips)
        end
    end
end

--- Destroys the city info gui.
--- @param player Player
function Gui.CityInfo.destroy(player)
    local city_info_gui = player.gui.top[CITY_INFO_NAME]

    if city_info_gui ~= nil and city_info_gui.valid then
        city_info_gui.destroy()
    end
end
