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
]]
-- local often used globals for ridiculous performance gains

local try_get = Register.try_get
local types = Types.definitions
local get_building_details = require("constants.buildings").get

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
    local width = range > 30 and 16 or 8
    created_highlights[#created_highlights + 1] =
        rendering.draw_rectangle {
        color = range_border_highlight_colors[entry[EK.type]],
        width = width,
        filled = false,
        left_top = {x - range + width / 64, y - range + width / 64},
        right_bottom = {x + range - width / 64, y + range - width / 64},
        surface = surface,
        players = {player_id}
    }
end

local function highlight_workforce(player_id, entry, building_details, created_highlights)
    local entity = entry[EK.entity]
    created_highlights[#created_highlights + 1] =
        rendering.draw_sprite {
        sprite = "sosciencity-people",
        target = entity,
        target_offset = {-0.75, 0},
        x_scale = 0.375,
        y_scale = 0.375,
        surface = entity.surface,
        players = {player_id},
        only_in_alt_mode = true
    }
    created_highlights[#created_highlights + 1] =
        rendering.draw_text {
        text = {"sosciencity.fraction", entry[EK.worker_count], building_details.workforce.count},
        target = entity,
        target_offset = {-0.25, 0},
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

    local surface = entity.surface

    created_highlights[#created_highlights + 1] =
        rendering.draw_sprite {
        sprite = size > 3 and "highlight-left-top-big" or "highlight-left-top",
        tint = tint,
        surface = surface,
        players = players,
        target = left_top
    }
    created_highlights[#created_highlights + 1] =
        rendering.draw_sprite {
        sprite = size > 3 and "highlight-right-bottom-big" or "highlight-right-bottom",
        tint = tint,
        surface = surface,
        players = players,
        target = right_bottom
    }

    -- convert left_top to left_bottom and right_bottom to right_top
    left_top.y, right_bottom.y = right_bottom.y, left_top.y

    created_highlights[#created_highlights + 1] =
        rendering.draw_sprite {
        sprite = size > 3 and "highlight-left-bottom-big" or "highlight-left-bottom",
        tint = tint,
        surface = surface,
        players = players,
        target = left_top
    }
    created_highlights[#created_highlights + 1] =
        rendering.draw_sprite {
        sprite = size > 3 and "highlight-right-top-big" or "highlight-right-top",
        tint = tint,
        surface = surface,
        players = players,
        target = right_bottom
    }
end

local function highlight_neighbors(player_id, entry, created_highlights)
    local neighbors = entry[EK.neighbors]
    if not neighbors then
        return
    end

    local players = {player_id}
    for _, neighbor_entry in Neighborhood.all(entry) do
        create_neighbor_highlights(players, neighbor_entry, created_highlights)
    end
end

local function show_inhabitants(player_id, entry, created_highlights)
    local inhabitants = entry[EK.inhabitants]
    local capacity = Housing.get_capacity(entry)
    local entity = entry[EK.entity]
    local players = {player_id}

    local scale = 0.375

    -- inhabitant count
    created_highlights[#created_highlights + 1] =
        rendering.draw_sprite {
        sprite = "sosciencity-people",
        target = entity,
        target_offset = {-1.75, -1},
        x_scale = scale,
        y_scale = scale,
        surface = entity.surface,
        players = players,
        only_in_alt_mode = true
    }
    created_highlights[#created_highlights + 1] =
        rendering.draw_text {
        text = {"sosciencity.fraction", inhabitants, capacity},
        target = entity,
        target_offset = {-1.25, -1},
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
        target = entity,
        target_offset = {0.75, -1},
        x_scale = scale,
        y_scale = scale,
        surface = entity.surface,
        players = players,
        only_in_alt_mode = true
    }
    created_highlights[#created_highlights + 1] =
        rendering.draw_text {
        text = inhabitants > 0 and round_to_step(entry[EK.happiness], 0.1) or "/",
        target = entity,
        target_offset = {1.25, -1},
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
        target = entity,
        surface = entity.surface,
        players = players,
        target_offset = {-1.75, 1},
        x_scale = scale,
        y_scale = scale,
        only_in_alt_mode = true
    }
    created_highlights[#created_highlights + 1] =
        rendering.draw_text {
        text = inhabitants > 0 and round_to_step(entry[EK.health], 0.1) or "/",
        target = entity,
        target_offset = {-1.25, 1},
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
        target = entity,
        surface = entity.surface,
        players = players,
        target_offset = {0.75, 1},
        x_scale = scale,
        y_scale = scale,
        only_in_alt_mode = true
    }
    created_highlights[#created_highlights + 1] =
        rendering.draw_text {
        text = inhabitants > 0 and round_to_step(entry[EK.sanity], 0.1) or "/",
        target = entity,
        target_offset = {1.25, 1},
        surface = entity.surface,
        players = players,
        color = Color.white,
        vertical_alignment = "middle",
        only_in_alt_mode = true,
        scale = 1.5
    }
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
        local id = renders[i]
        if rendering.is_valid(id) then
            rendering.destroy(id)
        end
    end

    highlights[player_id] = nil
end
