local EK = require("enums.entry-key")
local MoveCause = require("enums.move-cause")

local Castes = require("constants.castes")
local Housing = require("constants.housing")

local get_free_capacity = Housing.get_free_capacity
local floor = math.floor
local min = math.min
local HEALTHY = DiseaseGroup.HEALTHY

local take_from_house
local add_to_house

function Inhabitants.load_housing_redistribution()
    take_from_house = Inhabitants.take_from_house
    add_to_house = Inhabitants.add_to_house
end

--- Redistributes healthy inhabitants from lower-priority houses to fill vacancies in
--- higher-priority houses. Runs globally across all castes, capped by a per-run budget
--- derived from the redistribution efficiency research level.
function Inhabitants.passive_redistribution_pass()
    if not storage.passive_redistribution_enabled then return end
    if not storage.technologies["passive-redistribution"] then return end

    local total_population = Tirislib.Tables.sum(storage.population)
    local budget = floor(total_population * Technologies.get_redistribution_budget_fraction())
    if budget == 0 then return end

    for _, caste in pairs(Castes.all) do
        if budget == 0 then break end
        local caste_id = caste.type

        local houses = {}
        for _, house in Register.iterate_type(caste_id) do
            if not house[EK.is_sanatorium] then
                houses[#houses + 1] = house
            end
        end

        if #houses < 2 then goto next_caste end

        -- sort descending by priority
        table.sort(houses, function(a, b)
            return a[EK.housing_priority] > b[EK.housing_priority]
        end)

        local fill_idx = 1
        local take_idx = #houses

        while fill_idx < take_idx and budget > 0 do
            local fill_house = houses[fill_idx]
            local take_house = houses[take_idx]

            -- no benefit moving between equal-priority houses
            if fill_house[EK.housing_priority] <= take_house[EK.housing_priority] then break end

            local vacancy = get_free_capacity(fill_house)
            if vacancy == 0 then
                fill_idx = fill_idx + 1
            elseif take_house[EK.diseases][HEALTHY] == 0 then
                take_idx = take_idx - 1
            else
                local to_move = min(vacancy, take_house[EK.diseases][HEALTHY], budget)
                local taken = take_from_house(take_house, to_move, {[HEALTHY] = to_move})
                local added = add_to_house(fill_house, taken, MoveCause.passive_redistribution, true)
                budget = budget - added

                if get_free_capacity(fill_house) == 0 then fill_idx = fill_idx + 1 end
                if take_house[EK.diseases][HEALTHY] == 0 then take_idx = take_idx - 1 end
            end
        end

        ::next_caste::
    end
end
