-- Static class for all the functions that tell the player something through various means.
-- Communication is very important in a relationship.
Communication = {}

-- local often used functions for smallish performance gains
local global

local fluid_statistics
local fluid_consumption
local fluid_production
local item_statistics
local item_consumption
local item_production

local highlights
local castes = Caste.values

local speakers = Speakers
local speaker_schedule
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

local function set_locals()
    highlights = global.mouseover_highlights

    fluid_consumption = global.fluid_consumption
    fluid_production = global.fluid_production
    item_consumption = global.item_consumption
    item_production = global.item_production

    speaker_schedule = global.speaker_schedule

    generate_speakers_list()
end

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
            {"caste-name." .. caste.name}
        }
    )
end

function Communication.people_resettled(entry, count)
    create_flying_text(entry, {"flying-text.resettled", count})
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

local function log_population(current_tick)
end

local function say(speaker, locale_key)
    game.print {"", {speaker .. "prefix"}, {speaker .. locale_key}}
end

local function tell(player, speaker, locale_key)
    player.print {"", {speaker .. "prefix"}, {speaker .. locale_key}}
end

function Communication.say_welcome(player)
    tell(player, "tiriscef.", "welcome")

    if global.profanity then
        tell(player, "profanity.", "welcome")
    end
end

local function schedule_say(speaker, locale_key, time)
    if not speaker_schedule[time] then
        speaker_schedule[time] = {}
    end
    speaker_schedule[time][#speaker_schedule[time] + 1] = {speaker = speaker, line = locale_key}
end

local function finish_schedule(current_tick)
    for time, schedule in pairs(speaker_schedule) do
        if time <= current_tick then
            for i = 1, #schedule do
                local thing_to_say = schedule[i]
                say(thing_to_say.speaker, thing_to_say.line)
            end
            speaker_schedule[time] = nil
        end
    end
end

function Communication.useless_banter()
    if #allowed_speakers == 0 then
        game.print {"", {"tiriscef.prefix"}, {"muted-tiriscef." .. random(10)}}
        return
    end

    -- pick a speaker, the more they have to say the higher is the probability to pick them
    local weights = {}
    for index, name in pairs(allowed_speakers) do
        weights[index] = speakers[name].useless_banter_count
    end

    -- pick a random speaker and line until we found a line that wasn't used recently
    local speaker_name, speaker, line, line_index
    repeat
        speaker_name = allowed_speakers[Tirislib_Tables.weighted_random(weights)]
        speaker = speakers[speaker_name]
        line = random(speaker.useless_banter_count)
        line_index = line + speaker.index
    until not Tirislib_Tables.contains(global.past_banter, line_index)

    -- log the chosen banter
    local index = global.past_banter_index
    global.past_banter[index] = line_index
    global.past_banter_index = (index < 8) and (index + 1) or 1

    if speaker.lines_with_followup[line] then
        -- schedule the followup in a second (60 ticks)
        schedule_say(speaker_name, line .. "f", game.tick + 60)
    end

    say(speaker_name, line)
end
local useless_banter = Communication.useless_banter

function Communication.log_emigration(caste, emigrated)

end

function Communication.log_immigration(caste, immigrated)

end

function Communication.update(current_tick)
    flush_logs()
    log_population(current_tick)
    finish_schedule(current_tick)

    if current_tick % 25200 == 7200 then -- every 7 minutes, first time after 2 minutes
        useless_banter()
    end
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

    global.speaker_schedule = {}

    set_locals()
end

function Communication.load()
    global = _ENV.global
    set_locals()
end

return Communication
