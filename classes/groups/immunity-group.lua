local Diseases = require("constants.diseases")

local Tables = Tirislib.Tables
local floor = math.floor
local min = math.min
local random = math.random
local coin_flips = Tirislib.Utils.coin_flips
local occurrence_probability = Tirislib.Utils.occurrence_probability
--- Object class for holding the immunities of an InhabitantGroup.<br>
--- Holds one count table per immunity kind: (disease_id, count of immune people)-pairs.
--- Each count is a subset of the group, so the counts of different diseases overlap.
--- @class ImmunityGroup
local ImmunityGroup = {}

--- Kinds of immunity, mapped to the disease field with their waning rate per tick.
ImmunityGroup.kinds = {
    recovered = "immunity_waning_rate",
    vaccinated = "vaccine_immunity_waning_rate"
}
local immunity_kinds = ImmunityGroup.kinds

--- Returns a new ImmunityGroup without any immune people.
--- @return ImmunityGroup
function ImmunityGroup.new()
    return {recovered = {}, vaccinated = {}}
end
local new_immunity_group = ImmunityGroup.new

--- Merges the right hand group into the left hand group. If keep_rh is falsy, the right hand group gets emptied.
--- @param lh ImmunityGroup
--- @param rh ImmunityGroup
--- @param keep_rh boolean?
function ImmunityGroup.merge(lh, rh, keep_rh)
    for kind in pairs(immunity_kinds) do
        local lh_counts = lh[kind]
        local rh_counts = rh[kind]

        for disease_id, count in pairs(rh_counts) do
            lh_counts[disease_id] = (lh_counts[disease_id] or 0) + count
        end

        if not keep_rh then
            Tables.empty(rh_counts)
        end
    end
end

--- Takes the immunities of the given count of people out of the given group and returns them as a new group.
--- Every count loses its proportional share, rounded randomly so that the expected value is exact.
--- @param group ImmunityGroup
--- @param to_take integer
--- @param total_count integer number of people in the InhabitantGroup
--- @return ImmunityGroup
function ImmunityGroup.take(group, to_take, total_count)
    local ret = new_immunity_group()
    if total_count <= 0 or to_take <= 0 then
        return ret
    end
    local share = min(1, to_take / total_count)

    for kind in pairs(immunity_kinds) do
        local counts = group[kind]
        local taken_counts = ret[kind]

        for disease_id, count in pairs(counts) do
            local exact = count * share
            local taken = floor(exact)
            if random() < exact - taken then
                taken = taken + 1
            end
            taken = min(taken, count)

            if taken > 0 then
                taken_counts[disease_id] = taken
                counts[disease_id] = (count ~= taken) and count - taken or nil
            end
        end
    end

    return ret
end

--- Subtracts the immunity counts in rh from lh. Errors if lh has fewer immune people than rh.
--- @param lh ImmunityGroup
--- @param rh ImmunityGroup
function ImmunityGroup.subtract(lh, rh)
    for kind in pairs(immunity_kinds) do
        local lh_counts = lh[kind]

        for disease_id, count in pairs(rh[kind]) do
            local new_count = (lh_counts[disease_id] or 0) - count

            if new_count < 0 then
                error("Sosciencity tried to subtract two incompatible ImmunityGroup objects.")
            end

            lh_counts[disease_id] = (new_count > 0) and new_count or nil
        end
    end
end

--- Returns the number of people that are immune to the given disease.
--- @param group ImmunityGroup
--- @param disease_id DiseaseID
--- @param inhabitants integer number of people in the InhabitantGroup
--- @return integer
function ImmunityGroup.get_immune(group, disease_id, inhabitants)
    return min(inhabitants, (group.recovered[disease_id] or 0) + (group.vaccinated[disease_id] or 0))
end

--- Makes the given number of people immune to the given disease.
--- @param group ImmunityGroup
--- @param kind string key of ImmunityGroup.kinds
--- @param disease_id DiseaseID
--- @param count integer
--- @param inhabitants integer number of people in the InhabitantGroup
function ImmunityGroup.grant(group, kind, disease_id, count, inhabitants)
    local counts = group[kind]
    local new_count = min(inhabitants, (counts[disease_id] or 0) + count)
    counts[disease_id] = (new_count > 0) and new_count or nil
end

--- Lets the immunities wane over the given time.
--- @param group ImmunityGroup
--- @param delta_ticks integer
function ImmunityGroup.wane(group, delta_ticks)
    for kind, rate_field in pairs(immunity_kinds) do
        local counts = group[kind]

        for disease_id, count in pairs(counts) do
            local disease = Diseases.values[disease_id]
            local rate = disease and disease[rate_field]

            if not rate then
                -- the disease no longer grants this kind of immunity
                counts[disease_id] = nil
            elseif rate > 0 then
                local lost = coin_flips(occurrence_probability(rate, delta_ticks), count, 5)
                counts[disease_id] = (count ~= lost) and count - lost or nil
            end
        end
    end
end

return ImmunityGroup
