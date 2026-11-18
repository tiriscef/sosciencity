local AgeLink = require("enums.age-link")

local Diseases = require("constants.diseases")
local InhabitantsConstants = require("constants.inhabitants")
local Time = require("constants.time")

local DiseaseGroup = require("classes.groups.disease-group")

local Tables = Tirislib.Tables
local floor = math.floor
local ceil = math.ceil
local round = Tirislib.Utils.round
local min = math.min
local random = math.random
--- Object class for holding the Ages of an InhabitantGroup.<br>
--- Keys are hatch days (nauvis days since the start of the game), values the count of inhabitants hatched on
--- that day. Keys are absolute, so groups can be merged without adjustment and never need to be shifted.
--- @class AgeGroup
local AgeGroup = {}

local HEALTHY = DiseaseGroup.HEALTHY

--- Returns the current day, in nauvis days since the start of the game.
--- @return integer
function AgeGroup.current_day()
    return floor(game.tick / Time.nauvis_day)
end

--- Returns the age in nauvis days of the inhabitants hatched on the given day.
--- @param hatch_day integer
--- @param today integer? the current day, to avoid recalculating it in loops
--- @return integer
function AgeGroup.get_age(hatch_day, today)
    return (today or AgeGroup.current_day()) - hatch_day
end

--- Returns the frailty of the inhabitants hatched on the given day. It is 1 at the onset age and doubles every
--- InhabitantsConstants.frailty_doubling days, so it is negligible for young inhabitants.
--- @param hatch_day integer
--- @param today integer
--- @param onset number age in nauvis days at which the frailty is 1, see InhabitantGroup.get_frailty_onset
--- @return number
function AgeGroup.get_frailty(hatch_day, today, onset)
    return 2 ^ ((today - hatch_day - onset) / InhabitantsConstants.frailty_doubling)
end

--- Returns a new AgeGroup table with fixed ages.
--- @param count integer
--- @param age integer? age in nauvis days, defaults to 0
function AgeGroup.new(count, age)
    local ret = {}

    if count > 0 then
        ret[AgeGroup.current_day() - (age or 0)] = count
    end

    return ret
end

-- immigration is disabled, so these ages aren't tuned to anything
local function get_immigrant_age()
    local r1 = random() ^ 2
    local r2 = (random() < 0.5) and 1 or -1

    return round(7 * (50 + r1 * r2 * 30))
end

--- Returns a new AgeGroup table with random ages.
--- @param count integer
--- @param age_function function returns an age in nauvis days
function AgeGroup.random_new(count, age_function)
    local ret = {}

    if count > 0 then
        local today = AgeGroup.current_day()
        local rolls = min(count, 10)
        local count_per_roll = floor(count / rolls)
        local modulo = count % rolls

        for i = 1, rolls do
            local hatch_day = today - age_function()
            ret[hatch_day] = (ret[hatch_day] or 0) + count_per_roll + (i <= modulo and 1 or 0)
        end
    end

    return ret
end

--- Returns a new AgeGroup with randomly distributed immigrant ages.
--- @param count integer
--- @return AgeGroup
function AgeGroup.new_immigrants(count)
    return AgeGroup.random_new(count, get_immigrant_age)
end

--- Merges the right hand group into the left hand group. If keep_rh is falsy, the right hand group gets emptied.
--- @param lh AgeGroup
--- @param rh AgeGroup
--- @param keep_rh boolean?
function AgeGroup.merge(lh, rh, keep_rh)
    for hatch_day, count in pairs(rh) do
        lh[hatch_day] = (lh[hatch_day] or 0) + count
    end

    if not keep_rh then
        Tables.empty(rh)
    end
end

--- Takes the given count of people from the given AgeGroup and returns the AgeGroup of the taken people.
--- @param group AgeGroup
--- @param to_take integer
--- @param total_count integer?
--- @return AgeGroup
function AgeGroup.take(group, to_take, total_count)
    total_count = total_count or Tables.sum(group)
    to_take = min(to_take, total_count)

    local ret = {}

    while to_take > 0 do
        local made_progress = false
        for hatch_day, current_count in pairs(group) do
            local percentage_to_take = to_take / total_count
            local current_take = min(current_count, to_take, ceil(percentage_to_take * current_count))

            if current_take > 0 then
                made_progress = true
            end

            total_count = total_count - current_take
            to_take = to_take - current_take

            ret[hatch_day] = (ret[hatch_day] or 0) + current_take
            group[hatch_day] = (current_count ~= current_take) and current_count - current_take or nil

            if to_take == 0 then
                return ret
            end
        end
        if not made_progress then break end
    end

    return ret
end

--- Takes the given count of people at random from the given AgeGroup and returns the AgeGroup of the taken people.
--- Unlike AgeGroup.take, every person has the same chance to be taken, even when only a few are taken.
--- @param group AgeGroup
--- @param to_take integer
--- @param total_count integer?
--- @return AgeGroup
function AgeGroup.take_random(group, to_take, total_count)
    total_count = total_count or Tables.sum(group)
    to_take = min(to_take, total_count)

    local ret = {}
    for _ = 1, to_take do
        local hatch_day = Tables.pick_random_key_weighted(group, total_count)
        local count = group[hatch_day]
        ret[hatch_day] = (ret[hatch_day] or 0) + 1
        group[hatch_day] = (count > 1) and count - 1 or nil
        total_count = total_count - 1
    end

    return ret
end

--- Takes the given count of people from the oldest or youngest end of the given AgeGroup and returns the
--- AgeGroup of the taken people.
--- @param group AgeGroup
--- @param to_take integer
--- @param link AgeLink which end to take from
--- @return AgeGroup
function AgeGroup.take_extreme(group, to_take, link)
    local hatch_days = Tables.get_keyset(group)
    if link == AgeLink.oldest then
        table.sort(hatch_days)
    else
        table.sort(hatch_days, function(a, b) return a > b end)
    end

    local ret = {}
    for _, hatch_day in pairs(hatch_days) do
        if to_take <= 0 then
            break
        end

        local current_count = group[hatch_day]
        local current_take = min(current_count, to_take)
        if current_take > 0 then
            ret[hatch_day] = current_take
            to_take = to_take - current_take
        end
        group[hatch_day] = (current_count ~= current_take) and current_count - current_take or nil
    end

    return ret
end

--- Takes the ages of people with the given diseases. People with an age-linked disease are taken from the
--- matching end of the AgeGroup, the rest proportionally. Returns the AgeGroup of the taken people.
--- @param group AgeGroup
--- @param diseases DiseaseGroup diseases of the taken people
--- @param to_take integer
--- @param total_count integer? count of people in the AgeGroup
--- @return AgeGroup
function AgeGroup.take_for_diseases(group, diseases, to_take, total_count)
    total_count = total_count or Tables.sum(group)

    local oldest = 0
    local youngest = 0
    for disease_id, count in pairs(diseases) do
        local link = disease_id ~= HEALTHY and Diseases.values[disease_id].age_link
        if link == AgeLink.oldest then
            oldest = oldest + count
        elseif link == AgeLink.youngest then
            youngest = youngest + count
        end
    end

    if oldest + youngest == 0 then
        return AgeGroup.take(group, to_take, total_count)
    end

    local ret = AgeGroup.take_extreme(group, min(oldest, to_take), AgeLink.oldest)
    AgeGroup.merge(ret, AgeGroup.take_extreme(group, min(youngest, to_take - Tables.sum(ret)), AgeLink.youngest))

    local linked_count = Tables.sum(ret)
    AgeGroup.merge(ret, AgeGroup.take(group, to_take - linked_count, total_count - linked_count))

    return ret
end

--- Subtracts the counts in rh from lh. Errors if lh has fewer people of any hatch day than rh.
--- @param lh AgeGroup
--- @param rh AgeGroup
function AgeGroup.subtract(lh, rh)
    for hatch_day, count in pairs(rh) do
        local new_count = lh[hatch_day] - count

        if new_count < 0 then
            error("Sosciencity tried to subtract two incompatible AgeGroup objects.")
        end

        lh[hatch_day] = (new_count > 0) and new_count or nil
    end
end

return AgeGroup
