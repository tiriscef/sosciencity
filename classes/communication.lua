--- Static class for all the functions that tell the player something through various means.
--- Communication is very important in a relationship.
Communication = {}

--[[
    Data this class stores in global
    --------------------------------
    global.(fluid/item)_(consumption/production): table
        [name]: amount consumed/produced

    global.past_banter: array of recent lines said (up to 8)

    global.past_banter_index: int

    global.(tiriscef/profanity): bool (if they are enabled)

    global.logs: table
]]
-- local often used globals for smallish performance gains

local global

local fluid_statistics
local fluid_consumption
local fluid_production
local item_statistics
local item_consumption
local item_production

local logs

local castes = Castes.values

local Scheduler = Scheduler
local Tirislib_Tables = Tirislib_Tables

local speakers = Speakers
local allowed_speakers

local floor = math.floor
local random = math.random
local pick_random_subtable_weighted_by_key = Tirislib_Tables.pick_random_subtable_weighted_by_key

---------------------------------------------------------------------------------------------------
-- << lua state lifecycle stuff >>

local function generate_speakers_list()
    allowed_speakers = {}
    if global.tiriscef then
        allowed_speakers[#allowed_speakers + 1] = "tiriscef."
    end
    if global.profanity then
        allowed_speakers[#allowed_speakers + 1] = "profanity."
    end
end

local function set_locals()
    fluid_consumption = global.fluid_consumption
    fluid_production = global.fluid_production
    item_consumption = global.item_consumption
    item_production = global.item_production

    logs = global.logs

    generate_speakers_list()
end

function Communication.init()
    global = _ENV.global

    global.fluid_consumption = {}
    global.fluid_production = {}
    global.item_consumption = {}
    global.item_production = {}

    global.logs = {
        emigration = {},
        immigration = {},
        casualty = {},
        recovery = {},
        treatment = {},
        disease_death = {},
        infection = {}
    }

    global.past_banter = {}
    global.past_banter_index = 1

    set_locals()
end

function Communication.load()
    global = _ENV.global
    set_locals()
end

function Communication.settings_update()
    global = _ENV.global
    generate_speakers_list()
end

---------------------------------------------------------------------------------------------------
-- << flying texts >>

function Communication.create_flying_text(entry, text)
    local entity = entry[EK.entity]

    entity.surface.create_entity {
        name = "flying-text",
        position = entity.position,
        text = text
    }
end
local create_flying_text = Communication.create_flying_text

---------------------------------------------------------------------------------------------------
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

            local new_amount = amount - amount_to_log
            if new_amount == 0 then
                list[name] = nil
            else
                list[name] = new_amount
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
-- << speakers >>

local FOLLOWUP_DELAY = 2 * Time.second

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
        speaker_name, speaker = pick_random_subtable_weighted_by_key(speakers, "useless_banter_count")
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
-- interface functions to inform this class of things going on

function Communication.caste_allowed_in(entry, caste_id)
    local caste = castes[caste_id]

    create_flying_text(
        entry,
        {
            "sosciencity.set-caste",
            "[img=technology/" .. caste.tech_name .. "]",
            {"caste-name." .. caste.name}
        }
    )
end

function Communication.caste_not_allowed_in(entry, caste_id)
    local caste = castes[caste_id]

    create_flying_text(
        entry,
        {
            "sosciencity.set-caste-denied",
            "[img=technology/" .. caste.tech_name .. "]",
            {"caste-name." .. caste.name}
        }
    )
end

function Communication.player_got_run_over()
    if #allowed_speakers == 0 then
        return
    end

    local speaker_name, speaker = pick_random_subtable_weighted_by_key(speakers, "roadkill_banter_count")
    local line = random(speaker.roadkill_banter_count)
    Scheduler.plan_event_in("say", FOLLOWUP_DELAY, speaker_name, "train-" .. line)
end

---------------------------------------------------------------------------------------------------
-- << logs >>

local function log_population(current_tick)
end

function Communication.log_emigration(group, cause)
end

function Communication.log_immigration(group)
end

function Communication.log_death(group, cause)
end

function Communication.log_diseased(disease_id, count, cause)

end

function Communication.log_recovery(disease_id, count)
end

function Communication.log_treatment(disease_id, count)
end

function Communication.log_disease_death(disease_id, count)
end

function Communication.log_infected(disease_id, count)
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

return Communication
