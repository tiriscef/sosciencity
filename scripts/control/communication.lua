-- Static class for all the functions that tell the player something through various means.
-- Communication is very important in a relationship.
Communication = {}

local global
local item_statistics
local fluid_statistics
local highlights
local castes = Caste.values

function Communication.create_flying_text(entry, text)
    local entity = entry[ENTITY]

    entity.surface.create_entity {
        name = "flying-text",
        position = entity.position,
        text = text
    }
end
local create_flying_text = Communication.create_flying_text

function Communication.caste_allowed_in(entry, caste_id)
    local caste = castes[caste_id]

    create_flying_text(
        entry,
        {
            "flying-text.set-caste",
            "[img=technology/" .. caste.tech_name .. "]",
            {"technology-name." .. caste.name .. "-caste"}
        }
    )
end

function Communication.people_resettled(entry, count)
    create_flying_text(entry, {"flying-text.resettled", count})
end

function Communication.log_item(item, amount)
    if item_statistics == nil then
        item_statistics = game.forces.player.item_production_statistics
    end

    item_statistics.on_flow(item, amount)
end

function Communication.log_fluid(fluid, amount)
    if fluid_statistics == nil then
        fluid_statistics = game.forces.player.fluid_production_statistics
    end

    fluid_statistics.on_flow(fluid, amount)
end

local highlight_alpha = 0.2
local highlight_colors = {
    [TYPE_HOSPITAL] = {r = 0.8, g = 0.1, b = 0.1, a = 1},
    [TYPE_WATER_DISTRIBUTER] = {r = 0, g = 0.8, b = 1, a = 1},
    [TYPE_MARKET] = {r = 1, g = 0.45, b = 0, a = 1},
    [TYPE_DUMPSTER] = {r = 0.8, g = 0.8, b = 0.8, a = 1}
}

local function premultiply_with_alpha(color, a)
    color.r = color.r * a
    color.g = color.g * a
    color.b = color.b * a
    color.a = color.a * a
end

for _, color in pairs(highlight_colors) do
    premultiply_with_alpha(color, highlight_alpha)
end

local function highlight_range(player_id, entity, building_details)
    local range = building_details.range

    local surface = entity.surface
    local position = entity.position
    local x = position.x
    local y = position.y

    local id =
        rendering.draw_rectangle {
        color = highlight_colors[building_details.type],
        filled = true,
        left_top = {x - range, y - range},
        right_bottom = {x + range, y + range},
        surface = surface,
        players = {player_id}
    }

    highlights[player_id] = {id}
end

local function highlight_neighbors(player_id, entry)
    local neighbors = entry[NEIGHBORHOOD]
    if not neighbors then
        return
    end

    local highlight_list = highlights[player_id]
    if not highlight_list then
        highlights[player_id] = {}
        highlight_list = highlights[player_id]
    end

    local players = {player_id}
    for _, neighbor_entry in Neighborhood.all(entry) do
        local entity = neighbor_entry[ENTITY]
        local bounding_box = entity.selection_box
        local color =
            highlight_colors[neighbor_entry[TYPE]] or
            {r = highlight_alpha, g = highlight_alpha, b = highlight_alpha, a = highlight_alpha}

        local id =
            rendering.draw_rectangle {
            color = color,
            filled = true,
            left_top = bounding_box.left_top,
            right_bottom = bounding_box.right_bottom,
            surface = entity.surface,
            players = players,
            draw_on_ground = true
        }

        highlight_list[#highlight_list + 1] = id
    end
end

function Communication.create_mouseover_highlights(player_id, entity)
    local name = entity.name

    local building_details = Buildings[name]
    if building_details then
        highlight_range(player_id, entity, building_details)
    end

    local entry = Register.try_get(entity.unit_number)
    if entry then
        highlight_neighbors(player_id, entry)
    end
end

function Communication.remove_mouseover_highlights(player_id)
    local renders = global.mouseover_highlights[player_id]

    if not renders then
        return
    end

    for i = 1, #renders do
        if rendering.is_valid(renders[i]) then
            rendering.destroy(renders[i])
        end
    end

    global.mouseover_highlights[player_id] = nil
end

local function set_locals()
    highlights = global.mouseover_highlights
end

function Communication.init()
    global = _ENV.global
    global.mouseover_highlights = {}
    set_locals()
end

function Communication.load()
    global = _ENV.global
    set_locals()
end

return Communication
