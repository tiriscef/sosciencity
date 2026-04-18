--- The gui that is always on the top left corner and provides quick information about populations and caste bonuses.
Gui.CityInfo = {}

--[[
    Data this class stores in storage
    --------------------------------
    storage.placement_settings: table
        [player_index]: table
            target_comfort: integer (0–10) — comfort target applied to newly placed houses
            auto_assign_caste: integer|nil — Type enum value of the caste to auto-assign, or nil for none
]]

-- enums
local Type = require("enums.type")

-- constants
local Castes = require("constants.castes")
local Color = require("constants.color")
local Housing = require("constants.housing")

-- local often used globals for microscopic performance gains
local castes = Castes.values
local Gui = Gui
local Register = Register
local Inhabitants = Inhabitants
local max = math.max
local min = math.min
local round_to_step = Tirislib.Utils.round_to_step

local Table = Tirislib.Tables

local CITY_INFO_NAME = "sosciencity-city-info"

--- Updates population, machine count, and turret count labels in the general frame.
--- @param container LuaGuiElement the top-level city info flow
local function update_population_flow(container)
    local datalist = container.general.flow.datalist

    datalist.population.caption = Table.sum(storage.population)

    local machine_count = Register.get_machine_count()
    local machine_count_label = datalist.machine_count
    machine_count_label.caption = machine_count
    machine_count_label.tooltip = {
        "sosciencity.tooltip-machines",
        storage.active_machine_count
    }

    datalist.turret_count.caption = Register.get_type_count(Type.turret)
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

--- Adds the hidden advanced placement section (comfort target controls) to the general frame's flow.
--- Starts hidden; shown via set_placement_mode when the player holds a house item.
--- @param flow LuaGuiElement the vertical flow inside the general frame
--- @param player_index integer
local function create_advanced_placement_section(flow, player_index)
    local settings = storage.placement_settings and storage.placement_settings[player_index]
    local comfort_value = settings and settings.target_comfort or 0

    local advanced_flow = flow.add {type = "flow", name = "advanced_placement", direction = "vertical", visible = false}
    advanced_flow.style.top_margin = 4

    Gui.Elements.Utils.separator_line(advanced_flow)

    advanced_flow.add {
        type = "label",
        caption = {"sosciencity.placement-new-house"},
        style = "bold_label"
    }

    advanced_flow.add {type = "label", caption = {"sosciencity.placement-target-comfort"}}

    local comfort_row = advanced_flow.add {
        type = "flow",
        name = "comfort_row",
        direction = "horizontal",
        style = "sosciencity_horizontal_center_flow"
    }

    local comfort_tooltip = {"sosciencity.placement-comfort-tooltip"}

    comfort_row.add {
        type = "button",
        name = "comfort_minus",
        caption = "◄",
        style = "sosciencity_small_button",
        mouse_button_filter = {"left"},
        tooltip = comfort_tooltip,
        tags = {sosciencity_gui_event = "placement_adjust_comfort", delta = -1}
    }

    local val_label = comfort_row.add {
        type = "label",
        name = "comfort_value",
        caption = comfort_value,
        tooltip = comfort_tooltip
    }
    val_label.style.minimal_width = 16
    val_label.style.horizontal_align = "center"

    comfort_row.add {
        type = "button",
        name = "comfort_plus",
        caption = "►",
        style = "sosciencity_small_button",
        mouse_button_filter = {"left"},
        tooltip = comfort_tooltip,
        tags = {sosciencity_gui_event = "placement_adjust_comfort", delta = 1}
    }

    Gui.register_element(val_label, "city-info-placement", "comfort-value", player_index)
end

--- Creates the general frame with city-wide stats and the advanced placement section.
--- @param container LuaGuiElement the top-level city info flow
--- @param player_index integer
local function create_population_flow(container, player_index)
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

    create_advanced_placement_section(flow, player_index)

    update_population_flow(container)
end

local tooltip_fns = {
    [Type.clockwork] = function()
        local housing = storage.housing_capacity[Type.clockwork]
        local housing_improvised = housing[true]
        local points = round_to_step(storage.caste_points[Type.clockwork], 0.1)
        local maintenance_cost = storage.active_machine_count

        local points_locale = points
        if storage.maintenance_enabled and maintenance_cost > 0 then
            local remaining_points = points - max(0, maintenance_cost - storage.starting_clockwork_points)
            points_locale = {
                "sosciencity.tooltip-maintenance-calc",
                remaining_points,
                points,
                storage.starting_clockwork_points,
                maintenance_cost
            }
            points = remaining_points
        end

        local ret = {
            "",
            {
                "sosciencity.tooltip-caste-general",
                storage.population[Type.clockwork],
                housing[false] + housing_improvised,
                housing_improvised,
                points_locale
            }
        }

        if points >= 0 then
            ret[#ret + 1] = {
                "sosciencity.tooltip-clockwork-bonus",
                maintenance_cost,
                round_to_step(points / max(1, maintenance_cost), 0.1),
                storage.caste_bonuses[Type.clockwork]
            }
        else
            ret[#ret + 1] = {"sosciencity.tooltip-insufficient-maintenance", storage.caste_bonuses[Type.clockwork]}
        end

        local total_machines = Register.get_machine_count()
        if storage.maintenance_enabled and total_machines ~= maintenance_cost then
            ret[#ret + 1] = {
                "sosciencity.tooltip-clockwork-theoretical",
                total_machines,
                Inhabitants.get_clockwork_bonus(nil, total_machines)
            }
        end

        return ret
    end,
    [Type.orchid] = function()
        local housing = storage.housing_capacity[Type.orchid]
        local housing_improvised = housing[true]
        local points = round_to_step(storage.caste_points[Type.orchid], 0.1)
        return {
            "",
            {
                "sosciencity.tooltip-caste-general",
                storage.population[Type.orchid],
                housing[false] + housing_improvised,
                housing_improvised,
                points
            },
            {
                "sosciencity.tooltip-orchid-bonus",
                storage.caste_bonuses[Type.orchid]
            }
        }
    end,
    [Type.gunfire] = function()
        local housing = storage.housing_capacity[Type.gunfire]
        local housing_improvised = housing[true]
        local points = round_to_step(storage.caste_points[Type.gunfire], 0.1)
        local turrets = Register.get_type_count(Type.turret)
        return {
            "",
            {
                "sosciencity.tooltip-caste-general",
                storage.population[Type.gunfire],
                housing[false] + housing_improvised,
                housing_improvised,
                points
            },
            {
                "sosciencity.tooltip-gunfire-bonus",
                turrets,
                round_to_step(points / max(1, turrets), 0.1),
                storage.caste_bonuses[Type.gunfire]
            }
        }
    end,
    [Type.ember] = function()
        local housing = storage.housing_capacity[Type.ember]
        local housing_improvised = housing[true]
        local points = round_to_step(storage.caste_points[Type.ember], 0.1)
        local non_ember_pop = Table.sum(storage.population) - storage.population[Type.ember]
        return {
            "",
            {
                "sosciencity.tooltip-caste-general",
                storage.population[Type.ember],
                housing[false] + housing_improvised,
                housing_improvised,
                points
            },
            {
                "sosciencity.tooltip-ember-bonus",
                non_ember_pop,
                round_to_step(points / max(1, non_ember_pop), 0.01),
                storage.caste_bonuses[Type.ember]
            }
        }
    end,
    [Type.foundry] = function()
        local housing = storage.housing_capacity[Type.foundry]
        local housing_improvised = housing[true]
        local points = round_to_step(storage.caste_points[Type.foundry], 0.1)
        return {
            "",
            {
                "sosciencity.tooltip-caste-general",
                storage.population[Type.foundry],
                housing[false] + housing_improvised,
                housing_improvised,
                points
            },
            {
                "sosciencity.tooltip-foundry-bonus",
                storage.caste_bonuses[Type.foundry]
            }
        }
    end,
    [Type.gleam] = function()
        local housing = storage.housing_capacity[Type.gleam]
        local housing_improvised = housing[true]
        local points = round_to_step(storage.caste_points[Type.gleam], 0.1)
        return {
            "",
            {
                "sosciencity.tooltip-caste-general",
                storage.population[Type.gleam],
                housing[false] + housing_improvised,
                housing_improvised,
                points
            },
            {
                "sosciencity.tooltip-gleam-bonus",
                storage.caste_bonuses[Type.gleam]
            }
        }
    end,
    [Type.aurora] = function()
        local housing = storage.housing_capacity[Type.aurora]
        local housing_improvised = housing[true]
        local points = round_to_step(storage.caste_points[Type.aurora], 0.1)
        return {
            "",
            {
                "sosciencity.tooltip-caste-general",
                storage.population[Type.aurora],
                housing[false] + housing_improvised,
                housing_improvised,
                points
            },
            {
                "sosciencity.tooltip-aurora-bonus",
                storage.caste_bonuses[Type.aurora]
            }
        }
    end,
    [Type.plasma] = function()
        local housing = storage.housing_capacity[Type.plasma]
        local housing_improvised = housing[true]
        local points = round_to_step(storage.caste_points[Type.plasma], 0.1)
        local non_plasma_pop = Table.sum(storage.population) - storage.population[Type.plasma]
        return {
            "",
            {
                "sosciencity.tooltip-caste-general",
                storage.population[Type.plasma],
                housing[false] + housing_improvised,
                housing_improvised,
                points
            },
            {
                "sosciencity.tooltip-plasma-bonus",
                non_plasma_pop,
                round_to_step(points / max(1, non_plasma_pop), 0.01),
                storage.caste_bonuses[Type.plasma]
            }
        }
    end
}

--- Updates population, bonus, and tooltip for one caste frame. Hides the frame if the caste is not yet researched.
--- @param container LuaGuiElement the top-level city info flow
--- @param caste_id integer
--- @param caste_tooltips table pre-built tooltip strings keyed by caste_id
local function update_caste_flow(container, caste_id, caste_tooltips)
    local caste_frame = container["caste-" .. caste_id]

    -- Always show the clockwork caste, so the player has a chance to understand the maintenance mechanic.
    local visibility = (caste_id == Type.clockwork) or Inhabitants.caste_is_researched(caste_id)
    caste_frame.visible = visibility

    if visibility then
        local flow = caste_frame.flow

        local population_label = flow["caste-population"]
        population_label.caption = storage.population[caste_id]

        local bonus_value = storage.caste_bonuses[caste_id]
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

--- Creates the frame for one caste (sprite, population, bonus, hidden placement checkbox).
--- @param container LuaGuiElement the top-level city info flow
--- @param caste_id integer
--- @param caste_tooltips table pre-built tooltip strings keyed by caste_id, or nil on first creation
--- @param player_index integer
local function create_caste_flow(container, caste_id, caste_tooltips, player_index)
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

    local settings = storage.placement_settings and storage.placement_settings[player_index]

    local placement_section = frame.add {type = "flow", name = "placement_section", direction = "vertical", visible = false}
    local placement_section_style = placement_section.style
    placement_section_style.top_margin = 2
    placement_section_style.horizontal_align = "center"

    placement_section.add {type = "line", direction = "horizontal"}

    local checkbox = placement_section.add {
        type = "checkbox",
        name = "placement_caste_checkbox",
        state = settings and (settings.auto_assign_caste == caste_id) or false,
        tooltip = {"sosciencity.placement-assign-caste-tooltip"},
        tags = {sosciencity_gui_event = "placement_caste_checkbox", caste_id = caste_id}
    }
    checkbox.style.bottom_margin = 5
    Gui.register_element(checkbox, "city-info-placement-caste", caste_id, player_index)

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

    local player_index = player.index
    create_population_flow(frame, player_index)

    for _, caste in pairs(Castes.all) do
        create_caste_flow(frame, caste.type, caste_tooltips, player_index)
    end

    -- Restore placement mode if player is currently holding a house
    local cursor = player.cursor_stack
    if cursor and cursor.valid_for_read and Housing.values[cursor.name] then
        Gui.CityInfo.set_placement_mode(player, true)
    end
end

--- Updates the city info gui for all existing players.
function Gui.CityInfo.update()
    local caste_tooltips = {}
    for _, caste in pairs(Castes.all) do
        caste_tooltips[caste.type] = tooltip_fns[caste.type]()
    end

    for _, player in pairs(game.connected_players) do
        local city_info_gui = player.gui.top[CITY_INFO_NAME]

        -- we check if the gui still exists, as other mods can delete them
        if city_info_gui ~= nil and city_info_gui.valid then
            update_population_flow(city_info_gui)

            for _, caste in pairs(Castes.all) do
                update_caste_flow(city_info_gui, caste.type, caste_tooltips)
            end
        else
            Gui.CityInfo.create(player, caste_tooltips)
        end
    end
end

--- Shows or hides the advanced placement section and syncs controls from storage.
--- @param player LuaPlayer
--- @param active boolean
function Gui.CityInfo.set_placement_mode(player, active)
    local city_info = player.gui.top[CITY_INFO_NAME]
    if not (city_info and city_info.valid) then
        return
    end

    city_info.general.flow.advanced_placement.visible = active

    local settings = storage.placement_settings[player.index]
    if active and settings then
        local val_label = Gui.get_element("city-info-placement", "comfort-value", player.index)
        if val_label and val_label.valid then
            val_label.caption = settings.target_comfort
        end
    end

    for _, caste in pairs(Castes.all) do
        local caste_frame = city_info["caste-" .. caste.type]
        if caste_frame and caste_frame.valid then
            local section = caste_frame.placement_section
            section.visible = active
            if active and settings then
                section.placement_caste_checkbox.state = (settings.auto_assign_caste == caste.type)
            end
        end
    end
end

--- Destroys the city info gui.
--- @param player LuaPlayer
function Gui.CityInfo.destroy(player)
    local city_info_gui = player.gui.top[CITY_INFO_NAME]

    if city_info_gui ~= nil and city_info_gui.valid then
        city_info_gui.destroy()
    end
end

---------------------------------------------------------------------------------------------------
-- << advanced placement event handlers >>

Gui.set_click_handler(
    "placement_adjust_comfort",
    function(event)
        local player_index = event.player_index
        local settings = storage.placement_settings[player_index]
        if not settings then
            return
        end
        settings.target_comfort = max(0, min(settings.target_comfort + event.element.tags.delta, 10))
        local label = Gui.get_element("city-info-placement", "comfort-value", player_index)
        if label and label.valid then
            label.caption = settings.target_comfort
        end
    end
)

Gui.set_checked_state_handler(
    "placement_caste_checkbox",
    function(event)
        local player_index = event.player_index
        local caste_id = event.element.tags.caste_id
        local checked = event.element.state
        local settings = storage.placement_settings[player_index]
        if not settings then
            return
        end

        settings.auto_assign_caste = checked and caste_id or nil

        for _, caste in pairs(Castes.all) do
            if caste.type ~= caste_id then
                local el = Gui.get_element("city-info-placement-caste", caste.type, player_index)
                if el and el.valid then
                    el.state = false
                end
            end
        end
    end
)
