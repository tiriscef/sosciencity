local Castes = require("constants.castes")

local castes = Castes.values
local Tables = Tirislib.Tables
local ceil = math.ceil
local min = math.min
local dice_rolls = Tirislib.Utils.dice_rolls
--- Object class for holding the Genders of an InhabitantGroup
--- @class GenderGroup
local GenderGroup = {}

--- Creates a new GenderGroup.
--- @param agender integer?
--- @param fale integer?
--- @param pachin integer?
--- @param ga integer?
--- @return GenderGroup
function GenderGroup.new(agender, fale, pachin, ga)
    return {agender or 0, fale or 0, pachin or 0, ga or 0}
end

--- Returns a new GenderGroup with randomly distributed immigrant genders for the given caste.
--- @param count integer
--- @param caste_id Type
--- @return GenderGroup
function GenderGroup.new_immigrants(count, caste_id)
    return dice_rolls(castes[caste_id].immigration_genders, count, 20)
end

--- Merges the right hand group into the left hand group. If keep_rh is falsy, the right hand group gets zeroed out.
--- @param lh GenderGroup
--- @param rh GenderGroup
--- @param keep_rh boolean?
function GenderGroup.merge(lh, rh, keep_rh)
    for gender, count in pairs(rh) do
        lh[gender] = lh[gender] + count

        if not keep_rh then
            rh[gender] = 0
        end
    end
end

--- Takes the given count of people from the given gender group and returns the gender group of the taken people.
--- @param group GenderGroup
--- @param to_take integer
--- @param total_count integer?
--- @return GenderGroup
function GenderGroup.take(group, to_take, total_count)
    total_count = total_count or Tables.sum(group)
    to_take = min(to_take, total_count)

    local ret = GenderGroup.new()

    while to_take > 0 do
        local made_progress = false
        for gender = 1, #group do
            local current_count = group[gender]
            local percentage_to_take = to_take / total_count
            local current_take = min(current_count, to_take, ceil(percentage_to_take * current_count))

            if current_take > 0 then
                made_progress = true
            end

            ret[gender] = ret[gender] + current_take
            group[gender] = group[gender] - current_take

            total_count = total_count - current_take
            to_take = to_take - current_take

            if to_take == 0 then
                return ret
            end
        end
        if not made_progress then break end
    end

    return ret
end

--- Subtracts the gender counts in rh from lh. Errors if lh has fewer of any gender than rh.
--- @param lh GenderGroup
--- @param rh GenderGroup
function GenderGroup.subtract(lh, rh)
    for gender, count in pairs(rh) do
        lh[gender] = lh[gender] - count
        if lh[gender] < 0 then
            error("Sosciencity tried to subtract two incompatible GenderGroup objects.")
        end
    end
end

return GenderGroup
