local DeathCause = require("enums.death-cause")
local DiseasedCause = require("enums.diseased-cause")
local EK = require("enums.entry-key")
local InformationType = require("enums.information-type")
local WarningType = require("enums.warning-type")

local Castes = require("constants.castes")
local Speakers = require("constants.speakers")
local Time = require("constants.time")

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

    global.reports: table
        [name]: table

    global.current_reports: table
        [name]: table

    global.report_ticks: table
        [name]: tick of creation

    global.information_params: table
        [InformationType]: table of params

    global.information_ticks: table
        [InformationType]: tick

    global.warning_params: table
        [WarningType]: table of params

    global.warning_ticks: table
        [WarningType]: tick

    global.notifications: table
        [unit_number]: table of subscribed players
]]
-- local often used globals for smallish performance gains

local global

local fluid_statistics
local fluid_consumption
local fluid_production
local item_statistics
local item_consumption
local item_production

--local logs
local reports
local current_reports
local report_ticks
local reported_event_counts

local information_params
local information_ticks
local warning_params
local warning_ticks

local notifications

local castes = Castes.values

local Table = Tirislib.Tables

local speakers
local allowed_speakers

local floor = math.floor
local random = math.random
local pick_random_subtable_weighted_by_key = Table.pick_random_subtable_weighted_by_key
local plan_event_in = Scheduler.plan_event_in
local get_subtbl = Table.get_subtbl
local sum = Table.sum

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

    speakers = {}
    for _, speaker_name in pairs(allowed_speakers) do
        speakers[speaker_name] = Speakers[speaker_name]
    end
end

local function set_locals()
    fluid_consumption = global.fluid_consumption
    fluid_production = global.fluid_production
    item_consumption = global.item_consumption
    item_production = global.item_production

    --logs = global.logs
    reports = global.reports
    current_reports = global.current_reports
    report_ticks = global.report_ticks
    reported_event_counts = global.reported_event_counts

    information_ticks = global.information_ticks
    information_params = global.information_params
    warning_ticks = global.warning_ticks
    warning_params = global.warning_params

    notifications = global.notifications

    generate_speakers_list()
end

function Communication.init()
    global = _ENV.global

    global.fluid_consumption = {}
    global.fluid_production = {}
    global.item_consumption = {}
    global.item_production = {}

    --[[global.logs = {
        population = {}
    }]]
    global.reports = {
        ["immigration"] = {},
        ["emigration"] = {},
        ["death"] = {},
        ["diseases"] = {},
        ["disease-cause"] = {},
        ["disease-recovery"] = {},
        ["disease-death"] = {}
    }
    global.current_reports = {}
    global.report_ticks = {
        census = game.tick,
        healthcare = game.tick
    }
    global.reported_event_counts = {
        census = 0,
        healthcare = 0
    }

    global.past_banter = {}
    global.past_banter_index = 1

    global.information_ticks = {}
    for _, information_type in pairs(InformationType) do
        global.information_ticks[information_type] = -Time.nauvis_month
    end
    global.information_params = {}

    global.warning_ticks = {}
    for _, warning_type in pairs(WarningType) do
        global.warning_ticks[warning_type] = -Time.nauvis_month
    end
    global.warning_params = {}

    global.notifications = {}

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

--- Adds the given item to the production or consumption statistics.
--- @param item string
--- @param amount number
function Communication.log_item(item, amount)
    if amount > 0 then
        item_production[item] = (item_production[item] or 0) + amount
    else
        item_consumption[item] = (item_consumption[item] or 0) - amount
    end
end

--- Adds the given items to the production or consumption statistics.
--- @param items table
function Communication.log_items(items)
    for item, amount in pairs(items) do
        if amount > 0 then
            item_production[item] = (item_production[item] or 0) + amount
        else
            item_consumption[item] = (item_consumption[item] or 0) - amount
        end
    end
end

--- Adds the given fluid to the production or consumption statistics.
--- @param fluid string
--- @param amount number
function Communication.log_fluid(fluid, amount)
    if amount > 0 then
        fluid_production[fluid] = (fluid_production[fluid] or 0) + amount
    else
        fluid_consumption[fluid] = (fluid_consumption[fluid] or 0) - amount
    end
end

--- Adds the given fluids to the production or consumption statistics.
--- @param fluids table
function Communication.log_fluids(fluids)
    for fluid, amount in pairs(fluids) do
        if amount > 0 then
            fluid_production[fluid] = (fluid_production[fluid] or 0) + amount
        else
            fluid_consumption[fluid] = (fluid_consumption[fluid] or 0) - amount
        end
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

local function pick_speaker(line)
    return pick_random_subtable_weighted_by_key(speakers, line)
end

--- Lets the given speaker say the given line. This means an output that mimics that of a speaking player will be produced to the chat.
--- @param speaker string Name of the speaker
--- @param line string Name of the line to say
local function say(speaker, line, ...)
    game.print {"", {speaker .. "prefix"}, {speaker .. line, ...}}

    local delay = Speakers[speaker].lines_with_followup[line]
    if delay then
        plan_event_in("say", delay, speaker, line .. "f")
    end
end
Scheduler.set_event("say", say)
Communication.say = say

--- Says a random variant of the given line by the given speaker. If no speaker is given, a random one will be picked.
--- @param line string Name of the line to say
--- @param speaker string|nil Name of the speaker
local function say_random_variant(line, speaker, ...)
    if not speaker then
        speaker = pick_speaker(line)
    end

    local variant = random(speakers[speaker][line])

    say(speaker, line .. variant, ...)
end
Scheduler.set_event("say_random_variant", say_random_variant)
Communication.say_random_variant = say_random_variant

--- Lets the given speaker say the given line, but only to the given player.
--- @param player Entity
--- @param speaker string
--- @param line string
local function tell(player, speaker, line, ...)
    player.print {"", {speaker .. "prefix"}, {speaker .. line, ...}}

    local delay = Speakers[speaker].lines_with_followup[line]
    if delay then
        plan_event_in("tell", delay, player, speaker, line .. "f")
    end
end
Scheduler.set_event("tell", tell)

function Communication.say_welcome(player)
    for _, speaker in pairs(allowed_speakers) do
        tell(player, speaker, "welcome")
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
        speaker_name, speaker = pick_random_subtable_weighted_by_key(speakers, "b")
        line = random(speaker.b)
        line_index = line + speaker.index
    until not Table.contains(global.past_banter, line_index)

    -- log the chosen banter
    local index = global.past_banter_index
    global.past_banter[index] = line_index
    global.past_banter_index = (index < 8) and (index + 1) or 1

    say(speaker_name, "b" .. line)
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
            "[img=technology/" .. caste.name .. "-caste]",
            caste.localised_name
        }
    )
end

function Communication.caste_not_allowed_in(entry, caste_id)
    local caste = castes[caste_id]

    create_flying_text(
        entry,
        {
            "sosciencity.set-caste-denied",
            "[img=technology/" .. caste.name .. "-caste]",
            caste.localised_name
        }
    )
end

function Communication.player_got_run_over()
    if #allowed_speakers == 0 then
        return
    end

    plan_event_in("say_random_variant", Time.second, "roadkill")
end

--[[
    Reports:
        immigration <- census
            [cause]: count

        emigration <- census
            [cause]: count

        death <- census
            [cause]: count

        diseases <- healthcare
            [disease_id]: count

        disease-cause <- healthcare
            [cause]: count

        disease-recovery <- healthcare
            [true]: treated diseases
                [disease_id]: count
            [false]: naturally recovered diseases
                [disease_id]: count

        disease-death <- healthcare
            [disease_id]: count
]]
--[[
    XXX
    The following report interface functions feature rather ugly code dublications. But I don't have a good idea how to simplify this code at the moment.
]]
function Communication.report_emigration(count, cause)
    local current_report = get_subtbl(reports, "emigration")
    current_report[cause] = (current_report[cause] or 0) + count

    reported_event_counts.census = reported_event_counts.census + 1
end

function Communication.report_immigration(count, cause)
    local current_report = get_subtbl(reports, "immigration")
    current_report[cause] = (current_report[cause] or 0) + count

    reported_event_counts.census = reported_event_counts.census + 1
end

function Communication.report_death(count, cause)
    local current_report = get_subtbl(reports, "death")
    current_report[cause] = (current_report[cause] or 0) + count

    reported_event_counts.census = reported_event_counts.census + 1
end

function Communication.report_diseased(disease_id, count, cause)
    local current_disease_report = get_subtbl(reports, "diseases")
    current_disease_report[disease_id] = (current_disease_report[disease_id] or 0) + count

    local current_disease_cause_report = get_subtbl(reports, "disease-cause")
    current_disease_cause_report[cause] = (current_disease_cause_report[cause] or 0) + count

    reported_event_counts.healthcare = reported_event_counts.healthcare + 1
end

function Communication.report_recovery(disease_id, count)
    local current_report = get_subtbl(reports, "disease-recovery")
    current_report = get_subtbl(current_report, true)

    current_report[disease_id] = (current_report[disease_id] or 0) + count

    reported_event_counts.healthcare = reported_event_counts.healthcare + 1
end

function Communication.report_treatment(disease_id, count)
    local current_report = get_subtbl(reports, "disease-recovery")
    current_report = get_subtbl(current_report, false)

    current_report[disease_id] = (current_report[disease_id] or 0) + count

    reported_event_counts.healthcare = reported_event_counts.healthcare + 1
end

function Communication.report_disease_death(count, disease_id)
    Communication.report_death(count, DeathCause.illness)

    local current_report = get_subtbl(reports, "disease-death")
    current_report[disease_id] = (current_report[disease_id] or 0) + count

    reported_event_counts.healthcare = reported_event_counts.healthcare + 1
end

local function publish_reports(...)
    for _, name in pairs {...} do
        current_reports[name] = reports[name]
        reports[name] = nil
    end
end

local function census_report()
    local speaker = pick_speaker("census-immigration")

    local emigration = sum(get_subtbl(reports, "emigration"))
    local death = sum(get_subtbl(reports, "death"))
    local pure_emigration = emigration - death

    say_random_variant("report-begin", speaker, {"report-name.census"})

    say_random_variant("census-immigration", speaker, sum(get_subtbl(reports, "immigration")))
    say_random_variant("census-emigration", speaker, emigration, death, pure_emigration)

    say_random_variant("report-end", speaker)

    publish_reports("immigration", "emigration", "death")
end

local function healthcare_report()
    local speaker = pick_speaker("healthcare")

    local diseases = sum(get_subtbl(reports, "diseases"))
    local recovery = get_subtbl(reports, "disease-recovery")
    local natural_recovered = sum(get_subtbl(recovery, true))
    local treated = sum(get_subtbl(recovery, false))
    local recoveries = natural_recovered + treated

    say_random_variant("report-begin", speaker, {"report-name.healthcare"})

    say_random_variant("healthcare", speaker, diseases, sum(get_subtbl(reports, "disease-death")))
    say_random_variant("healthcare-recovery", speaker, natural_recovered, treated, recoveries)

    local infections = get_subtbl(reports, "disease-cause")[DiseasedCause.infection] or 0
    if diseases > 10 and infections >= 0.5 * diseases then
        say_random_variant("healthcare-infection-warning", speaker)
    end

    say_random_variant("report-end", speaker)

    publish_reports("diseases", "disease-cause", "disease-recovery", "disease-death")
end

local report_lookup = {
    census = census_report,
    healthcare = healthcare_report
}

--- Looks for a type of report that makes sense to publish at the moment.
local function look_for_report(current_tick)
    for report_name, last_report_tick in pairs(report_ticks) do
        if current_tick - last_report_tick >= (20 * Time.minute) and reported_event_counts[report_name] > 20 then
            report_lookup[report_name]()
            report_ticks[report_name] = current_tick
            reported_event_counts[report_name] = 0
            return true
        end
    end

    return false
end

---------------------------------------------------------------------------------------------------
-- << warnings >>

local speaker_warnings = {
    [WarningType.insufficient_maintenance] = true,
    [WarningType.homelessness] = true,
    [WarningType.badly_insufficient_maintenance] = true
}

local function alert(entry, signal, message)
    local entity = entry[EK.entity]
    for _, player in pairs(game.connected_players) do
        player.add_custom_alert(entity, signal, message, true)
    end
end

local warn_fns = {
    [WarningType.no_food] = function(entry)
        alert(entry, {type = "virtual", name = "alert-no-food"}, {"alert.no-food"})
    end,
    [WarningType.no_water] = function(entry)
        alert(entry, {type = "virtual", name = "alert-no-water"}, {"alert.no-water"})
    end,
    [WarningType.garbage] = function(entry)
        alert(entry, {type = "virtual", name = "alert-garbage"}, {"alert.garbage"})
    end,
    [WarningType.insufficient_maintenance] = function()
        say_random_variant("warning-insufficient-maintenance")
    end,
    [WarningType.emigration] = function(entry)
        alert(entry, {type = "virtual", name = "alert-emigration"}, {"alert.emigration"})
    end,
    [WarningType.insufficient_food_variety] = function(entry)
        alert(entry, {type = "virtual", name = "alert-not-enough-foods"}, {"alert.not-enough-foods"})
    end,
    [WarningType.insufficient_workers] = function(entry)
        alert(entry, {type = "virtual", name = "alert-not-enough-workers"}, {"alert.not-enough-workers"})
    end,
    [WarningType.homelessness] = function(caste_id)
        local caste = castes[caste_id]
        say_random_variant("warning-homelessness", nil, caste.localised_name_short, caste.localised_name)
    end,
    [WarningType.badly_insufficient_maintenance] = function()
        say_random_variant("warning-badly-insufficient-maintenance")
    end
}

function Communication.warning(warning_type, ...)
    if speaker_warnings[warning_type] then
        if game.tick - warning_ticks[warning_type] >= 2 * Time.minute then
            warning_params[warning_type] = {...}
        end
    else
        -- vanilla alert type warning
        warn_fns[warning_type](...)
    end
end

local function send_speaker_warning(warning_type)
    warn_fns[warning_type](unpack(warning_params[warning_type]))

    warning_params[warning_type] = nil
    warning_ticks[warning_type] = game.tick
end

local function look_for_warning()
    for warning_type in pairs(warning_params) do
        send_speaker_warning(warning_type)
        return true
    end

    return false
end

---------------------------------------------------------------------------------------------------
-- << informations >>

local information_prepare_fns = {
    [InformationType.acquisition_unlock] = function(tech_name)
        local params = get_subtbl(information_params, InformationType.acquisition_unlock)
        params[#params + 1] = tech_name
    end,
    [InformationType.unlocked_gated_technology] = function(tech_name)
        local params = get_subtbl(information_params, InformationType.unlocked_gated_technology)
        params[#params + 1] = tech_name
    end
}

function Communication.inform(information_type, ...)
    information_prepare_fns[information_type](...)
end

local information_fns = {
    [InformationType.acquisition_unlock] = function(...)
        local enumeration = Tirislib.Locales.create_enumeration({...}, nil, {"sosciencity.and"})

        say_random_variant("acquisition-unlock", nil, enumeration)
    end,
    [InformationType.unlocked_gated_technology] = function(...)
        local enumeration = Tirislib.Locales.create_enumeration({...}, nil, {"sosciencity.and"})

        say_random_variant("unlocked-gated-technology", nil, enumeration)
    end
}

local function send_information(information_type)
    information_fns[information_type](unpack(information_params[information_type]))

    information_params[information_type] = nil
    information_ticks[information_type] = game.tick
end

local information_times = {
    [InformationType.acquisition_unlock] = 1 * Time.minute,
    [InformationType.unlocked_gated_technology] = 1 * Time.minute
}

local function look_for_information()
    for information_type in pairs(information_params) do
        if game.tick - information_ticks[information_type] >= information_times[information_type] then
            send_information(information_type)
            return true
        end
    end

    return false
end

---------------------------------------------------------------------------------------------------
-- << notifications >>

--- Removes all subscriptions to notifications about the given entry. Must be called if the entry gets removed.
--- @param entry Entry
function Communication.remove_notifications(entry)
    local unit_number = entry[EK.unit_number]
    notifications[unit_number] = nil
end

--- Subscribes or unsubscribes the given player for notifications of the given entry.
--- @param entry Entry
--- @param player_id integer
--- @param enabled boolean
function Communication.set_subscription(entry, player_id, enabled)
    local unit_number = entry[EK.unit_number]
    local subscriptions = get_subtbl(notifications, unit_number)

    if enabled then
        subscriptions[player_id] = true
    else
        subscriptions[player_id] = nil
    end
end

--- Checks if the given player is subscribed to the given entry.
--- @param entry Entry
--- @param player_id integer
--- @return boolean
function Communication.check_subscription(entry, player_id)
    local unit_number = entry[EK.unit_number]
    local subscriptions = notifications[unit_number]

    if subscriptions then
        return subscriptions[player_id] ~= nil
    else
        return false
    end
end

--- Sends a notification about the given entry to all subscribed players.
--- @param entry Entry
--- @param message locale
function Communication.send_notification(entry, message)
    local subscriptions = notifications[entry[EK.unit_number]]

    if subscriptions then
        for player_id in pairs(subscriptions) do
            game.players[player_id].print(message)
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << general >>

function Communication.update(current_tick)
    flush_logs()

    if current_tick % (20 * Time.minute) == (5 * Time.minute) then -- every 20 minutes, first time after 5 minutes
        useless_banter()
        return
    end

    if #allowed_speakers > 0 then
        local said_something = false

        if current_tick % Time.minute == (30 * Time.second) then
            said_something = look_for_report(current_tick)
        end

        -- a warning or information will be searched every 15 seconds if there was no report or random banter
        if not said_something and current_tick % (15 * Time.second) == 0 then
            said_something = look_for_warning()

            if not said_something then
                look_for_information()
            end
        end
    end
end

return Communication
