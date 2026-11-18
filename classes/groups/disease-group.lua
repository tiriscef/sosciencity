local Diseases = require("constants.diseases")

local Communication = require("classes.communication")

local Tables = Tirislib.Tables
local ceil = math.ceil
local min = math.min
local dice_rolls = Tirislib.Utils.dice_rolls
--- Object class for holding the diseases of a group of inhabitants.
--- @class DiseaseGroup
local DiseaseGroup = {}

DiseaseGroup.HEALTHY = 0
local HEALTHY = DiseaseGroup.HEALTHY

--- Returns a new DiseaseGroup with the given count of healthy people.
--- @param count integer
function DiseaseGroup.new(count)
    return {[HEALTHY] = count}
end
local new_disease_group = DiseaseGroup.new

local function empty_disease_group(group)
    Tables.empty(group)
    group[HEALTHY] = 0
end

--- Merges the right hand group into the left hand group. If keep_rh is falsy, then the right hand disease group object gets emptied.
--- @param lh DiseaseGroup
--- @param rh DiseaseGroup
--- @param keep_rh boolean?
function DiseaseGroup.merge(lh, rh, keep_rh)
    for disease, count in pairs(rh) do
        lh[disease] = (lh[disease] or 0) + count
    end

    if not keep_rh then
        empty_disease_group(rh)
    end
end

--- Takes the given count of people from the given disease group and returns the disease group of the taken people.
--- @param group DiseaseGroup
--- @param to_take integer
--- @param total_count integer?
function DiseaseGroup.take(group, to_take, total_count)
    total_count = total_count or Tables.sum(group)
    to_take = min(to_take, total_count)

    local ret = new_disease_group(0)

    while to_take > 0 do
        local made_progress = false
        for disease, current_count in pairs(group) do
            local percentage_to_take = to_take / total_count
            local current_take = min(current_count, to_take, ceil(percentage_to_take * current_count))

            if current_take > 0 then
                made_progress = true
            end

            total_count = total_count - current_take
            to_take = to_take - current_take

            ret[disease] = (ret[disease] or 0) + current_take
            group[disease] = current_count - current_take
            if disease ~= HEALTHY and group[disease] == 0 then
                group[disease] = nil
            end

            if to_take == 0 then
                return ret
            end
        end
        if not made_progress then break end
    end

    return ret
end

--- Subtracts the disease counts in rh from lh. Errors if lh has fewer of any disease than rh.
--- @param lh DiseaseGroup
--- @param rh DiseaseGroup
function DiseaseGroup.subtract(lh, rh)
    for disease, count in pairs(rh) do
        local new_count = lh[disease] - count

        if new_count < 0 then
            error("Sosciencity tried to subtract two incompatible DiseaseGroup objects.")
        end

        if disease == HEALTHY then
            lh[disease] = new_count
        else
            lh[disease] = (new_count > 0) and new_count or nil
        end
    end
end

--- Tries to makes the given number of people sick with the given disease. Returns the number of people that were actually sickened.
--- Ignores immunities - use InhabitantGroup.make_sick for inhabitants that can be immune.
--- @param group DiseaseGroup
--- @param disease_id DiseaseID
--- @param count integer
function DiseaseGroup.make_sick(group, disease_id, count)
    local healthy_count = group[HEALTHY]
    local actually_sickened = min(count, healthy_count)

    group[HEALTHY] = healthy_count - actually_sickened
    group[disease_id] = (group[disease_id] or 0) + actually_sickened

    return actually_sickened
end
local make_sick = DiseaseGroup.make_sick

--- Rolls random diseases of the given category and applies them with the given sicken function.
--- @param sicken function (target, disease_id, count) -> number of people actually sickened
--- @param target DiseaseGroup|InhabitantGroup
--- @param disease_category DiseaseCategory
--- @param count integer
--- @param actual_count integer?
--- @param suppress_logging boolean?
local function sicken_randomly(sicken, target, disease_category, count, actual_count, suppress_logging)
    actual_count = min(count, actual_count or 20)

    local rolled_diseases = dice_rolls(Diseases.categories[disease_category], count, actual_count, true)

    for disease_id, rolled_count in pairs(rolled_diseases) do
        local sickened = sicken(target, disease_id, rolled_count)

        if not suppress_logging and sickened > 0 then
            Communication.report_diseased(disease_id, sickened, Diseases.disease_causes[disease_category])
        end
    end
end
DiseaseGroup.sicken_randomly = sicken_randomly

--- Tries to make the given number of people sick with random diseases of the given category.
--- Ignores immunities - use InhabitantGroup.make_sick_randomly for inhabitants that can be immune.
--- @param group DiseaseGroup
--- @param disease_category DiseaseCategory
--- @param count integer
--- @param actual_count integer?
--- @param suppress_logging boolean?
function DiseaseGroup.make_sick_randomly(group, disease_category, count, actual_count, suppress_logging)
    sicken_randomly(make_sick, group, disease_category, count, actual_count, suppress_logging)
end

--- Tries to cure the given number of people of the given disease. Returns the number of people that were actually cured.
--- @param group DiseaseGroup
--- @param disease_id DiseaseID
--- @param count integer
function DiseaseGroup.cure(group, disease_id, count)
    local healthy_count = group[HEALTHY]
    local sick_count = group[disease_id]
    local actually_cured = min(count, sick_count)

    group[HEALTHY] = healthy_count + actually_cured
    group[disease_id] = (actually_cured < sick_count) and sick_count - actually_cured or nil

    return actually_cured
end

--- Checks if the given id corresponds to a disease.
--- @param id DiseaseID
function DiseaseGroup.not_healthy(id)
    return id ~= HEALTHY
end

return DiseaseGroup
