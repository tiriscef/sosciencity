--- Static class for all the functions that tell the player something through various means.
--- Communication is very important in a relationship.
Communication = {}

--[[
    Data this class stores in global
    --------------------------------
    global.mouseover_highlights: table
        [player_index]: table of render_ids

    global.(fluid/item)_(consumption/production): table
        [name]: amount consumed/produced

    global.past_banter: array of recent lines said (up to 8)

    global.past_banter_index: int

    global.(tiriscef/profanity): bool (if they are enabled)
]]
-- local often used globals for smallish performance gains
local global

local fluid_statistics
local fluid_consumption
local fluid_production
local item_statistics
local item_consumption
local item_production

local highlights
local castes = Castes.values

local Scheduler = Scheduler
local Tirislib_Tables = Tirislib_Tables

local speakers = Speakers
local allowed_speakers
local function generate_speakers_list()
    allowed_speakers = {}
    if global.tiriscef then
        allowed_speakers[#allowed_speakers + 1] = "tiriscef."
    end
    if global.profanity then
        allowed_speakers[#allowed_speakers + 1] = "profanity."
    end
end

local floor = math.floor
local random = math.random
local weighted_random = Tirislib_Utils.weighted_random

local buildings = Buildings.values
local get_type = Types.get
local try_get = Register.try_get

local function set_locals()
    highlights = global.mouseover_highlights

    fluid_consumption = global.fluid_consumption
    fluid_production = global.fluid_production
    item_consumption = global.item_consumption
    item_production = global.item_production

    generate_speakers_list()
end

function Communication.init()
    global = _ENV.global
    global.mouseover_highlights = {}

    global.fluid_consumption = {}
    global.fluid_production = {}
    global.item_consumption = {}
    global.item_production = {}

    global.past_banter = {}
    global.past_banter_index = 1

    set_locals()
end

function Communication.load()
    global = _ENV.global
    set_locals()
end

function Communication.create_flying_text(entry, text)
    local entity = entry[EK.entity]

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
            {"caste-name." .. caste.name}
        }
    )
end

-- << production and consumption statistics >>
-- we collect all the produced/consumed stuff and log them collectively
-- this reduces the amount of API calls and avoids the problem that the statistics log only integer numbers
function Communication.log_item(item, amount)
    if amount > 0 then
        item_production[item] = (item_production[item] or 0) + amount
    else
        item_consumption[item] = (item_consumption[item] or 0) - amount
    end
end

function Communication.log_fluid(fluid, amount)
    if amount > 0 then
        fluid_production[fluid] = (fluid_production[fluid] or 0) + amount
    else
        fluid_consumption[fluid] = (fluid_consumption[fluid] or 0) - amount
    end
end

local function flush_log(list, statistic, multiplier)
    for name, amount in pairs(list) do
        local amount_to_log = floor(amount)

        if amount_to_log > 0 then
            statistic.on_flow(name, amount_to_log * multiplier)
            list[name] = list[name] - amount_to_log

            if list[name] == 0 then
                list[name] = nil
            end
        end
    end
end

local function flush_logs()
    if item_statistics == nil then
        item_statistics = game.forces.player.item_production_statistics
        fluid_statistics = game.forces.player.fluid_production_statistics
    end

    flush_log(item_consumption, item_statistics, -1)
    flush_log(item_production, item_statistics, 1)
    flush_log(fluid_consumption, fluid_statistics, -1)
    flush_log(fluid_production, fluid_statistics, 1)
end

---------------------------------------------------------------------------------------------------
-- << mouseover visualisations >>
local function premultiply_with_alpha(color, a)
    color.r = color.r * a
    color.g = color.g * a
    color.b = color.b * a
    color.a = color.a * a
end

local range_highlight_alpha = 0.15
local range_highlight_colors = {}

for _type, definition in pairs(Types.definitions) do
    local color = Tirislib_Tables.copy(definition.signature_color or Colors.white)
    premultiply_with_alpha(color, range_highlight_alpha)
    range_highlight_colors[_type] = color
end

local function highlight_range(player_id, entity, building_details, created_highlights)
    local range = building_details.range

    if range == "global" then
        -- TODO highlight that somehow
        return
    end

    local surface = entity.surface
    local position = entity.position
    local x = position.x
    local y = position.y

    created_highlights[#created_highlights + 1] =
        rendering.draw_rectangle {
        color = range_highlight_colors[building_details.type],
        filled = true,
        left_top = {x - range, y - range},
        right_bottom = {x + range, y + range},
        surface = surface,
        players = {player_id},
        draw_on_ground = true
    }
end

local building_details_visualization_lookup = {
    range = highlight_range
}

local function visualize_building_details(player_id, entity, building_details, created_highlights)
    for key in pairs(building_details) do
        local fn = building_details_visualization_lookup[key]

        if fn then
            fn(player_id, entity, building_details, created_highlights)
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

    local surface = entity.surface

    created_highlights[#created_highlights + 1] =
        rendering.draw_sprite {
        sprite = "highlight-left-top",
        tint = tint,
        surface = surface,
        players = players,
        target = left_top
    }
    created_highlights[#created_highlights + 1] =
        rendering.draw_sprite {
        sprite = "highlight-right-bottom",
        tint = tint,
        surface = surface,
        players = players,
        target = right_bottom
    }

    -- convert left_top to left_bottom and right_bottom to right_top
    left_top.y, right_bottom.y = right_bottom.y, left_top.y

    created_highlights[#created_highlights + 1] =
        rendering.draw_sprite {
        sprite = "highlight-left-bottom",
        tint = tint,
        surface = surface,
        players = players,
        target = left_top
    }
    created_highlights[#created_highlights + 1] =
        rendering.draw_sprite {
        sprite = "highlight-right-top",
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

    created_highlights[#created_highlights + 1] =
        rendering.draw_text {
        text = {"sosciencity-gui.fraction", inhabitants, capacity, ""},
        target = entity,
        surface = entity.surface,
        players = {player_id},
        alignment = "center",
        color = Colors.white
    }
end

function Communication.create_mouseover_highlights(player_id, entity)
    local name = entity.name
    local created_highlights = {}

    local building_details = buildings[name]
    if building_details then
        visualize_building_details(player_id, entity, building_details, created_highlights)
    end

    local entry = try_get(entity.unit_number)
    if entry then
        highlight_neighbors(player_id, entry, created_highlights)

        if get_type(entry).is_inhabited then
            show_inhabitants(player_id, entry, created_highlights)
        end
    end

    if #created_highlights > 0 then
        highlights[player_id] = created_highlights
    end
end

function Communication.remove_mouseover_highlights(player_id)
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

local function log_population(current_tick)
end

---------------------------------------------------------------------------------------------------
-- << speakers >>
local FOLLOWUP_DELAY = 2 * Time.second

local function pick_speaker(weight_key)
    local weights = {}
    for index, name in pairs(allowed_speakers) do
        weights[index] = speakers[name][weight_key]
    end

    local speaker_name = allowed_speakers[weighted_random(weights)]
    return speaker_name, speakers[speaker_name]
end

local function say(speaker, line)
    game.print {"", {speaker .. "prefix"}, {speaker .. line}}

    if speakers[speaker].lines_with_followup[line] then
        Scheduler.plan_event_in("say", FOLLOWUP_DELAY, speaker, line .. "f")
    end
end
Scheduler.set_event("say", say)

local function tell(player, speaker, line)
    player.print {"", {speaker .. "prefix"}, {speaker .. line}}

    if speakers[speaker].lines_with_followup[line] then
        Scheduler.plan_event_in("tell", FOLLOWUP_DELAY, player, speaker, line .. "f")
    end
end
Scheduler.set_event("tell", tell)

function Communication.say_welcome(player)
    tell(player, "tiriscef.", "welcome")

    if global.profanity then
        tell(player, "profanity.", "welcome")
    end
end

function Communication.useless_banter()
    if #allowed_speakers == 0 then
        game.print {"", {"tiriscef.prefix"}, {"muted-tiriscef." .. random(10)}}
        return
    end

    -- pick a random speaker and line until we found a line that wasn't used recently
    local speaker_name, speaker, line, line_index
    repeat
        speaker_name, speaker = pick_speaker("useless_banter_count")
        line = random(speaker.useless_banter_count)
        line_index = line + speaker.index
    until not Tirislib_Tables.contains(global.past_banter, line_index)

    -- log the chosen banter
    local index = global.past_banter_index
    global.past_banter[index] = line_index
    global.past_banter_index = (index < 8) and (index + 1) or 1

    say(speaker_name, line)
end
local useless_banter = Communication.useless_banter

---------------------------------------------------------------------------------------------------
-- << events >>
-- functions that can be called to inform this class of things going on
function Communication.log_emigration(group, cause)
end

function Communication.log_immigration(group)
end

function Communication.log_casualties(group)
end

function Communication.player_got_run_over()
    if #allowed_speakers == 0 then
        return
    end

    local speaker_name, speaker = pick_speaker("roadkill_banter_count")
    local line = random(speaker.roadkill_banter_count)
    Scheduler.plan_event_in("say", FOLLOWUP_DELAY, speaker_name, "train-" .. line)
end

---------------------------------------------------------------------------------------------------
-- << general >>
function Communication.update(current_tick)
    flush_logs()
    log_population(current_tick)

    if current_tick % (7 * Time.minute) == (2 * Time.minute) then -- every 7 minutes, first time after 2 minutes
        useless_banter()
    end
end

function Communication.settings_update()
    global = _ENV.global
    generate_speakers_list()
end

return Communication
