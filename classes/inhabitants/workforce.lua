local EK = require("enums.entry-key")
local RenderingType = require("enums.rendering-type")
local WarningType = require("enums.warning-type")

local Buildings = require("constants.buildings")

local get_building_details = Buildings.get
local try_get = Register.try_get
local add_common_sprite = Subentities.add_common_sprite
local remove_common_sprite = Subentities.remove_common_sprite
local Utils = Tirislib.Utils
local min = math.min
local HEALTHY = DiseaseGroup.HEALTHY

---------------------------------------------------------------------------------------------------
-- << workforce >>
-- Manufactories need inhabitants as workers.
-- The employment is saved by having a 'workers' table with (housing, count) pairs on the manufactory side.
-- On the housing side there is a table with the occupations of the inhabitants.
-- If they work at a manufactory, then the occupation is a (manufactory, count) pair.

--- Returns the number of employable inhabitants living in the housing entry.
--- @param entry Entry with inhabitants
--- @return integer
function Inhabitants.get_employable_count(entry)
    return entry[EK.diseases][HEALTHY] - entry[EK.employed]
end
local get_employable_count = Inhabitants.get_employable_count

--- Tries to employ the given number of people from the house for the manufactory and
--- returns the number of actually employed workers.
--- @param manufactory Entry with workforce
--- @param house Entry with inhabitants
--- @param count integer
--- @return integer
local function try_employ(manufactory, house, count)
    local employments = house[EK.employments]
    local unemployed_inhabitants = get_employable_count(house)

    if unemployed_inhabitants == 0 then
        return 0
    end

    -- establish the employment
    local employed = min(count, unemployed_inhabitants)

    local housing_number = house[EK.unit_number]
    local manufactory_number = manufactory[EK.unit_number]

    -- housing side
    house[EK.employed] = house[EK.employed] + employed
    employments[manufactory_number] = (employments[manufactory_number] or 0) + employed

    -- manufactory side
    local workers = manufactory[EK.workers]
    manufactory[EK.worker_count] = manufactory[EK.worker_count] + employed
    workers[housing_number] = (workers[housing_number] or 0) + employed

    return employed
end

--- Searches for workers among nearby houses of acceptable castes and employs them.
--- @param manufactory Entry with workforce
--- @param acceptable_castes Type[] array of caste types that can work here
--- @param count integer number of workers to find
local function look_for_workers(manufactory, acceptable_castes, count)
    local workers_found = 0

    for i = 1, #acceptable_castes do
        for _, house in Neighborhood.iterate_type(manufactory, acceptable_castes[i]) do
            workers_found = workers_found + try_employ(manufactory, house, count - workers_found)

            if workers_found == count then
                return
            end
        end
    end
end

--- Fires all the workers working in this building.
--- Must be called if a building with workforce gets deconstructed.
--- @param manufactory Entry with workforce
function Inhabitants.unemploy_all_workers(manufactory)
    local workers = manufactory[EK.workers]
    local manufactory_number = manufactory[EK.unit_number]

    for unit_number, count in pairs(workers) do
        local house = try_get(unit_number)
        if house then
            local employments = house[EK.employments]
            employments[manufactory_number] = nil
            house[EK.employed] = house[EK.employed] - count
        end
    end

    manufactory[EK.worker_count] = 0
    manufactory[EK.workers] = {}
end

--- Fires the given number of workers from the given manufactory. Returns the count of actually fired workers.
--- @param manufactory Entry with workforce
--- @param count integer
--- @return integer
local function unemploy_workers(manufactory, count)
    local workers = manufactory[EK.workers]
    local manufactory_worker_count = manufactory[EK.worker_count]
    count = min(count, manufactory_worker_count)
    local to_fire = count

    local manufactory_number = manufactory[EK.unit_number]

    for unit_number, worker_count in pairs(workers) do
        local fired

        local house = try_get(unit_number)
        if house then
            fired = min(worker_count, to_fire)

            -- housing side
            local employments = house[EK.employments]
            employments[manufactory_number] = (fired ~= worker_count) and (worker_count - fired) or nil
            house[EK.employed] = house[EK.employed] - fired
        else
            -- the house got lost without unemploying the inhabitants
            fired = worker_count
        end

        -- manufactory side
        to_fire = to_fire - fired
        workers[unit_number] = (fired ~= worker_count) and (worker_count - fired) or nil
    end

    local actually_fired = count - to_fire
    manufactory[EK.worker_count] = manufactory_worker_count - actually_fired
    return actually_fired
end

--- Tries to free the given number of inhabitants from their employment.
--- Returns the number of fired inhabitants.
--- @param house Entry with inhabitants
--- @param count integer
--- @return integer
local function unemploy_inhabitants(house, count)
    count = min(count, house[EK.employed])
    local to_fire = count
    local employments = house[EK.employments]
    local house_number = house[EK.unit_number]

    for unit_number, employed_count in pairs(employments) do
        local fired = min(employed_count, to_fire)
        to_fire = to_fire - fired

        -- set to nil if all employees got fired to delete the link
        local new_employment_count = (fired ~= employed_count) and (employed_count - fired) or nil

        -- housing side
        employments[unit_number] = new_employment_count

        local manufactory = try_get(unit_number)
        if manufactory then
            -- manufactory side
            manufactory[EK.workers][house_number] = new_employment_count
            manufactory[EK.worker_count] = manufactory[EK.worker_count] - fired
        else
            -- the manufactory got lost without unemploying the workers
        end
    end

    house[EK.employed] = house[EK.employed] - count

    return count
end
Inhabitants.unemploy_inhabitants = unemploy_inhabitants

--- Ends the employment of all employed inhabitants of this house.
--- Must be called if a house gets deconstructed.
--- @param house Entry with inhabitants
local function unemploy_all_inhabitants(house)
    unemploy_inhabitants(house, house[EK.employed])
end
Inhabitants.unemploy_all_inhabitants = unemploy_all_inhabitants

--- Update function for entries with workforce.
--- Looks for employees if this entry needs them, or fires them if there are too many.
--- @param manufactory Entry with workforce
--- @param workforce table workforce specification
function Inhabitants.update_workforce(manufactory, workforce)
    local nominal_count = manufactory[EK.target_worker_count] or workforce.count
    local current_workers = manufactory[EK.worker_count]

    if current_workers < nominal_count then
        look_for_workers(manufactory, workforce.castes, nominal_count - current_workers)
    elseif current_workers > nominal_count then
        unemploy_workers(manufactory, current_workers - nominal_count)
    end

    current_workers = manufactory[EK.worker_count]
    if nominal_count > current_workers and current_workers / workforce.count < 0.2 then
        Communication.warning(WarningType.insufficient_workers, manufactory)
        add_common_sprite(manufactory, RenderingType.no_workers)
    else
        remove_common_sprite(manufactory, RenderingType.no_workers)
    end
end

--- Returns a percentage on how satisfied the given building's need for workers is.
--- @param manufactory Entry
--- @return number ratio between 0 and 1+
function Inhabitants.evaluate_workforce(manufactory)
    local workforce = get_building_details(manufactory).workforce

    if not workforce then
        return 1
    end

    return manufactory[EK.worker_count] / workforce.count
end

--- Translates a happiness value to a working performance.
--- @param happiness number
--- @return number
local function get_work_coefficient(happiness)
    if happiness < 10 then
        return Utils.smootherstep(0.1 * happiness)
    else
        return (0.1 * happiness) ^ 0.7
    end
end

--- Returns a multiplier representing how worker happiness affects this building's performance.
--- The happiness_weight field on the WorkforceDefinition controls how much the building profits from happiness.
--- @param manufactory Entry
--- @return number multiplier around 1
function Inhabitants.evaluate_worker_happiness(manufactory)
    local workforce = get_building_details(manufactory).workforce
    if not workforce or not workforce.happiness_weight then
        return 1
    end

    local workers = manufactory[EK.workers]
    local total_workers = 0
    local weighted_coefficient = 0

    for unit_number, worker_count in pairs(workers) do
        local house = try_get(unit_number)
        if house then
            total_workers = total_workers + worker_count
            weighted_coefficient = weighted_coefficient + worker_count * get_work_coefficient(house[EK.happiness])
        end
    end

    if total_workers == 0 then
        return 1
    end

    local raw = weighted_coefficient / total_workers
    return 1 + (raw - 1) * workforce.happiness_weight
end

--- Returns the count of employed workers this building has.
--- @param manufactory Entry
--- @return integer
function Inhabitants.get_workforce_count(manufactory)
    local workers = 0

    for unit_number, worker_count in pairs(manufactory[EK.workers]) do
        local house = try_get(unit_number)

        if house then
            workers = workers + worker_count
        end
    end

    return workers
end
