local EK = require("enums.entry-key")

local Color = require("constants.color")
local Types = require("constants.types")
local Housing = require("constants.housing")

--- Static class for all the functions that visualise the mod's concepts.
Visualisation = {}

--[[
    Data this class stores in storage
    --------------------------------
    storage.mouseover_highlights: table
        [player_index]: table of render_ids

    storage.placement_highlights: table
        [player_index]: table of render objects, shown while the player holds a building with a site report
]]
-- local often used globals for ridiculous performance gains

local try_get = Register.try_get
local types = Types.definitions
local Buildings = require("constants.buildings")
local get_building_details = Buildings.get

local max = math.max
local get_box_size = Tirislib.Utils.get_box_size
local round_to_step = Tirislib.Utils.round_to_step

local highlights

---------------------------------------------------------------------------------------------------
-- << lua state lifecycle stuff >>

local function set_locals()
    highlights = storage.mouseover_highlights
end

function Visualisation.init()
    storage.mouseover_highlights = {}
    storage.placement_highlights = {}

    set_locals()
end

function Visualisation.load()
    set_locals()
end

---------------------------------------------------------------------------------------------------
-- << mouseover visualisations >>

local function premultiply_with_alpha(color, a)
    return {
        r = color.r * a,
        g = color.g * a,
        b = color.b * a,
        a = color.a * a
    }
end

local range_highlight_colors = {}
local range_border_highlight_colors = {}

for _type, definition in pairs(types) do
    local color = definition.signature_color or Color.grey
    range_highlight_colors[_type] = premultiply_with_alpha(color, 0.15)
    range_border_highlight_colors[_type] = premultiply_with_alpha(color, 0.35)
end

local function highlight_range(player_id, entry, building_details, created_highlights)
    local range = building_details.range

    if range == "global" then
        return
    end

    local entity = entry[EK.entity]
    local surface = entity.surface
    local position = entity.position
    local x = position.x
    local y = position.y

    -- on ground
    created_highlights[#created_highlights + 1] =
        rendering.draw_rectangle {
        color = range_highlight_colors[entry[EK.type]],
        filled = true,
        left_top = {x - range, y - range},
        right_bottom = {x + range, y + range},
        surface = surface,
        players = {player_id},
        draw_on_ground = true
    }

    -- border
    -- width / 64: compensate for line width drawn inward (64 pixels per world unit)
    local width = range > 30 and 16 or 8
    local inset = width / 64
    created_highlights[#created_highlights + 1] =
        rendering.draw_rectangle {
        color = range_border_highlight_colors[entry[EK.type]],
        width = width,
        filled = false,
        left_top = {x - range + inset, y - range + inset},
        right_bottom = {x + range - inset, y + range - inset},
        surface = surface,
        players = {player_id}
    }
end

local function highlight_workforce(player_id, entry, building_details, created_highlights)
    local entity = entry[EK.entity]
    created_highlights[#created_highlights + 1] =
        rendering.draw_sprite {
        sprite = "sosciencity-people",
        target = {entity = entity, offset = {-0.75, 0}},
        x_scale = 0.375,
        y_scale = 0.375,
        surface = entity.surface,
        players = {player_id},
        only_in_alt_mode = true
    }
    created_highlights[#created_highlights + 1] =
        rendering.draw_text {
        text = {"sosciencity.fraction", entry[EK.worker_count], building_details.workforce.count},
        target = {entity = entity, offset = {-0.25, 0}},
        surface = entity.surface,
        players = {player_id},
        color = Color.white,
        vertical_alignment = "middle",
        only_in_alt_mode = true,
        scale = 2
    }

    local workers = entry[EK.workers]

    if not workers then
        return
    end

    for unit_number, worker_count in pairs(workers) do
        local worker_home = try_get(unit_number)

        if worker_home then
            local home_entity = worker_home[EK.entity]

            created_highlights[#created_highlights + 1] =
                rendering.draw_text {
                text = {"sosciencity.show-employed-count", worker_count},
                target = home_entity,
                surface = home_entity.surface,
                players = {player_id},
                alignment = "center",
                color = Color.white,
                only_in_alt_mode = true,
                scale = 2
            }
        end
    end
end

local building_details_visualization_lookup = {
    range = highlight_range,
    workforce = highlight_workforce
}

local function visualize_building_details(player_id, entry, created_highlights)
    local building_details = get_building_details(entry)

    for key in pairs(building_details) do
        local fn = building_details_visualization_lookup[key]

        if fn then
            fn(player_id, entry, building_details, created_highlights)
        end
    end
end

local function create_neighbor_highlights(players, entry, created_highlights)
    local type_details = Types.get(entry)
    local tint = type_details.signature_color

    local entity = entry[EK.entity]
    local bounding_box = entity.selection_box
    local left_top = bounding_box.left_top
    local right_bottom = bounding_box.right_bottom

    local size = max(get_box_size(bounding_box))
    local big = size > 3

    local surface = entity.surface

    created_highlights[#created_highlights + 1] =
        rendering.draw_sprite {
        sprite = big and "highlight-left-top-big" or "highlight-left-top",
        tint = tint,
        surface = surface,
        players = players,
        target = left_top
    }
    created_highlights[#created_highlights + 1] =
        rendering.draw_sprite {
        sprite = big and "highlight-right-bottom-big" or "highlight-right-bottom",
        tint = tint,
        surface = surface,
        players = players,
        target = right_bottom
    }

    -- swap y coordinates to get left_bottom and right_top
    local left_bottom = {x = left_top.x, y = right_bottom.y}
    local right_top = {x = right_bottom.x, y = left_top.y}

    created_highlights[#created_highlights + 1] =
        rendering.draw_sprite {
        sprite = big and "highlight-left-bottom-big" or "highlight-left-bottom",
        tint = tint,
        surface = surface,
        players = players,
        target = left_bottom
    }
    created_highlights[#created_highlights + 1] =
        rendering.draw_sprite {
        sprite = big and "highlight-right-top-big" or "highlight-right-top",
        tint = tint,
        surface = surface,
        players = players,
        target = right_top
    }
end

local function highlight_neighbors(player_id, entry, created_highlights)
    local neighbors = entry[EK.neighbors]
    if not neighbors then
        return
    end

    local players = {player_id}
    for _, neighbor_entry in Neighborhood.iterate_all(entry) do
        create_neighbor_highlights(players, neighbor_entry, created_highlights)
    end
end

local function show_inhabitants(player_id, entry, created_highlights)
    local inhabitants = entry[EK.inhabitants]
    local capacity = Inhabitants.HousingCore.get_capacity(entry)
    local entity = entry[EK.entity]
    local players = {player_id}

    local scale = 0.375

    -- inhabitant count
    created_highlights[#created_highlights + 1] =
        rendering.draw_sprite {
        sprite = "sosciencity-people",
        target = {entity = entity, offset = {-1.75, -1}},
        x_scale = scale,
        y_scale = scale,
        surface = entity.surface,
        players = players,
        only_in_alt_mode = true
    }
    created_highlights[#created_highlights + 1] =
        rendering.draw_text {
        text = {"sosciencity.fraction", inhabitants, capacity},
        target = {entity = entity, offset = {-1.25, -1}},
        surface = entity.surface,
        players = players,
        color = Color.white,
        vertical_alignment = "middle",
        only_in_alt_mode = true,
        scale = 1.5
    }

    -- happiness
    created_highlights[#created_highlights + 1] =
        rendering.draw_sprite {
        sprite = "sosciencity-happiness",
        target = {entity = entity, offset = {0.75, -1}},
        x_scale = scale,
        y_scale = scale,
        surface = entity.surface,
        players = players,
        only_in_alt_mode = true
    }
    created_highlights[#created_highlights + 1] =
        rendering.draw_text {
        text = inhabitants > 0 and round_to_step(entry[EK.happiness], 0.1) or "/",
        target = {entity = entity, offset = {1.25, -1}},
        surface = entity.surface,
        players = players,
        color = Color.white,
        vertical_alignment = "middle",
        only_in_alt_mode = true,
        scale = 1.5
    }

    -- health
    created_highlights[#created_highlights + 1] =
        rendering.draw_sprite {
        sprite = "sosciencity-health",
        target = {entity = entity, offset = {-1.75, 1}},
        surface = entity.surface,
        players = players,
        x_scale = scale,
        y_scale = scale,
        only_in_alt_mode = true
    }
    created_highlights[#created_highlights + 1] =
        rendering.draw_text {
        text = inhabitants > 0 and round_to_step(entry[EK.health], 0.1) or "/",
        target = {entity = entity, offset = {-1.25, 1}},
        surface = entity.surface,
        players = players,
        color = Color.white,
        vertical_alignment = "middle",
        only_in_alt_mode = true,
        scale = 1.5
    }

    -- sanity
    created_highlights[#created_highlights + 1] =
        rendering.draw_sprite {
        sprite = "sosciencity-sanity",
        target = {entity = entity, offset = {0.75, 1}},
        surface = entity.surface,
        players = players,
        x_scale = scale,
        y_scale = scale,
        only_in_alt_mode = true
    }
    created_highlights[#created_highlights + 1] =
        rendering.draw_text {
        text = inhabitants > 0 and round_to_step(entry[EK.sanity], 0.1) or "/",
        target = {entity = entity, offset = {1.25, 1}},
        surface = entity.surface,
        players = players,
        color = Color.white,
        vertical_alignment = "middle",
        only_in_alt_mode = true,
        scale = 1.5
    }

    -- strike
    local strike_level = entry[EK.strike_level]
    if strike_level > 0 then
        local text, color
        if strike_level >= 1 then
            text = {"sosciencity.on-full-strike"}
            color = Color.red
        else
            text = {"sosciencity.strike-level", math.floor(strike_level * 100)}
            color = Color.orange
        end
        created_highlights[#created_highlights + 1] =
            rendering.draw_text {
            text = text,
            target = {entity = entity, offset = {0, 2.5}},
            surface = entity.surface,
            players = players,
            color = color,
            alignment = "center",
            vertical_alignment = "middle",
            only_in_alt_mode = true,
            scale = 2
        }
    end
end

function Visualisation.create_mouseover_highlights(player_id, entity)
    local entry = try_get(entity.unit_number)
    if entry then
        local created_highlights = {}
        highlight_neighbors(player_id, entry, created_highlights)

        if types[entry[EK.type]].is_inhabited then
            show_inhabitants(player_id, entry, created_highlights)
        end

        visualize_building_details(player_id, entry, created_highlights)

        if #created_highlights > 0 then
            highlights[player_id] = created_highlights
        end
    end
end

function Visualisation.remove_mouseover_highlights(player_id)
    local renders = highlights[player_id]

    if not renders then
        return
    end

    for i = 1, #renders do
        local render = renders[i]
        -- DELETEME temp fix for old render-ids
        if type(render) == "number" then
            render = rendering.get_object_by_id(render)
            renders[i] = render
        end
        if render.valid then
            render.destroy()
        end
    end

    highlights[player_id] = nil
end

---------------------------------------------------------------------------------------------------
-- << placement visualisations >>

local site_report_ok_color = {r = 0.7, g = 1, b = 0.7}
local site_report_bad_color = {r = 1, g = 0.6, b = 0.3}
local site_report_line_height = 0.6
local site_report_time_to_live = 10 * 60

--- Draws the site report on top of the entity for the given player.
--- Reports on ghosts stay until the ghost is gone, reports on real buildings fade after a few seconds.
--- @param player LuaPlayer
--- @param entity LuaEntity
--- @param lines table array of {caption = LocalisedString, ok = boolean}
function Visualisation.show_site_report(player, entity, lines)
    local time_to_live = entity.type ~= "entity-ghost" and site_report_time_to_live or nil
    local top = -0.5 * site_report_line_height * (#lines - 1)

    for i, line in pairs(lines) do
        rendering.draw_text {
            text = line.caption,
            target = {entity = entity, offset = {0, top + (i - 1) * site_report_line_height}},
            surface = entity.surface,
            players = {player.index},
            color = line.ok and site_report_ok_color or site_report_bad_color,
            alignment = "center",
            vertical_alignment = "middle",
            scale = 1.25,
            time_to_live = time_to_live
        }
    end
end

-- only buildings this close to the player get highlighted, so a big city doesn't draw thousands of objects
local placement_highlight_distance = 200

local function is_near(entity, surface_index, position)
    if entity.surface.index ~= surface_index then
        return false
    end
    local entity_position = entity.position
    return math.abs(entity_position.x - position.x) < placement_highlight_distance and
        math.abs(entity_position.y - position.y) < placement_highlight_distance
end

local function highlight_free_workers(player, house, created_highlights)
    local entity = house[EK.entity]
    local free = Inhabitants.get_employable_count(house)

    created_highlights[#created_highlights + 1] =
        rendering.draw_text {
        text = {"sosciencity.site-free-workers", free},
        target = entity,
        surface = entity.surface,
        players = {player.index},
        color = free > 0 and site_report_ok_color or Color.grey,
        alignment = "center",
        vertical_alignment = "middle",
        scale = 1.5
    }
end

--- Removes the placement highlights of the given player.
--- @param player_index integer
function Visualisation.remove_placement_highlights(player_index)
    local all_highlights = storage.placement_highlights
    local renders = all_highlights and all_highlights[player_index]
    if not renders then
        return
    end

    for _, render in pairs(renders) do
        if render.valid then
            render.destroy()
        end
    end
    all_highlights[player_index] = nil
end

--- Shows what matters for placing the given building while the player holds it: the ranges of the buildings
--- of the same type, which it would compete with, and the free workers of the houses that could staff it.
--- Removes the previous placement highlights first. Does nothing else for buildings without a site report.
--- @param player LuaPlayer
--- @param entity_name string? name of the held building, nil if the player holds none
function Visualisation.update_placement_highlights(player, entity_name)
    local player_index = player.index
    Visualisation.remove_placement_highlights(player_index)

    if not entity_name then
        return
    end
    local building_details = Buildings.get_by_name(entity_name)
    local _type = building_details.type
    if not _type or not Entity.has_site_report_builder(_type) then
        return
    end

    local created_highlights = {}
    local surface_index = player.surface.index
    local position = player.position

    for _, entry in Register.iterate_type(_type) do
        local entity = entry[EK.entity]
        if entity.valid and is_near(entity, surface_index, position) then
            highlight_range(player_index, entry, get_building_details(entry), created_highlights)
        end
    end

    local workforce = building_details.workforce
    if workforce then
        for _, caste in pairs(workforce.castes) do
            for _, house in Register.iterate_type(caste) do
                local entity = house[EK.entity]
                if entity.valid and is_near(entity, surface_index, position) then
                    highlight_free_workers(player, house, created_highlights)
                end
            end
        end
    end

    if #created_highlights > 0 then
        storage.placement_highlights = storage.placement_highlights or {}
        storage.placement_highlights[player_index] = created_highlights
    end
end

return Visualisation
