--- Static class that handles the behaviour of the people.
Inhabitants = {}

--[[
    Data this class stores in global
    --------------------------------
    global.population: table
        [caste_id]: int (inhabitants count)

    global.effective_population: table
        [caste_id]: float (total caste bonus points)

    global.caste_bonuses: table
        [caste_id]: float (caste bonus value)

    global.immigration: table
        [caste_id]: float (number of immigrants in the next wave)

    global.houses_with_free_capacity: table
        [caste_id]: table
            [unit_number]: truthy (lookup)

    global.next_houses: table
        [caste_id]: shuffled array of unit_numbers

    global.fear: float (fear level)

    global.last_fear_event: tick

    global.homeless: table
        [caste_id]: InhabitantGroup
]]
-- local often used functions for enormous performance gains
local global
local population
local effective_population
local caste_bonuses
local immigration
local homeless
local houses_with_free_capacity
local next_houses

local Register = Register
local try_get = Register.try_get

local get_building_details = Buildings.get

local castes = Castes.values
local emigration_coefficient = Castes.emigration_coefficient
local garbage_coefficient = Castes.garbage_coefficient

local evaluate_diet = Consumption.evaluate_diet
local evaluate_water = Consumption.evaluate_water

local produce_garbage = Inventories.produce_garbage
local get_garbage_value = Inventories.get_garbage_value

local get_housing_details = Housing.get
local get_free_capacity = Housing.get_free_capacity

local set_power_usage = Subentities.set_power_usage
local has_power = Subentities.has_power

local set_binary_techs = Technologies.set_binary_techs

local floor = math.floor
local ceil = math.ceil
local round = Tirislib_Utils.round
local sqrt = math.sqrt
local max = math.max
local min = math.min
local array_sum = Tirislib_Tables.array_sum
local array_product = Tirislib_Tables.array_product
local copy = Tirislib_Tables.copy
local shallow_equal = Tirislib_Tables.shallow_equal
local shuffle = Tirislib_Tables.shuffle
local weighted_average = Tirislib_Utils.weighted_average

local function set_locals()
    global = _ENV.global
    population = global.population
    effective_population = global.effective_population
    caste_bonuses = global.caste_bonuses
    immigration = global.immigration
    homeless = global.homeless
    houses_with_free_capacity = global.houses_with_free_capacity
    next_houses = global.next_houses
end

local function new_caste_table()
    return {
        [Type.clockwork] = 0,
        [Type.orchid] = 0,
        [Type.gunfire] = 0,
        [Type.ember] = 0,
        [Type.foundry] = 0,
        [Type.gleam] = 0,
        [Type.aurora] = 0,
        [Type.plasma] = 0
    }
end

--- Initialize the inhabitants related contents of global.
function Inhabitants.init()
    global = _ENV.global

    global.fear = 0
    global.population = new_caste_table()
    global.effective_population = new_caste_table()
    global.caste_bonuses = new_caste_table()
    global.immigration = new_caste_table()
    global.houses_with_free_capacity = Tirislib_Tables.new_array_of_arrays(#TypeGroup.all_castes)
    global.next_houses = Tirislib_Tables.new_array_of_arrays(#TypeGroup.all_castes)
    global.homeless = {}

    set_locals()

    for _, caste_id in pairs(TypeGroup.all_castes) do
        homeless[caste_id] = InhabitantGroup.new(caste_id)
    end
end

--- Sets local references during on_load
function Inhabitants.load()
    set_locals()
end

---------------------------------------------------------------------------------------------------
-- << diseases >>
--- Object class for holding the diseases of a group of inhabitants.
IllnessGroup = {}

local HEALTHY = {}
IllnessGroup.healthy_entry = 1
IllnessGroup.diseases = 1
IllnessGroup.count = 2

function IllnessGroup.new(count)
    return {{{}, count}}
end
local new_illness_group = IllnessGroup.new

function IllnessGroup.add_persons(group, count, diseases)
    diseases = diseases or HEALTHY

    for i = 1, #group do
        local entry = group[i]
        if shallow_equal(entry[IllnessGroup.diseases], diseases) then
            entry[IllnessGroup.count] = entry[IllnessGroup.count] + count
            return
        end
    end

    group[#group + 1] = {diseases, count}
end
local add_persons = IllnessGroup.add_persons

local function remove_empty_disease_entries(group)
    for i = #group, 2, -1 do
        if group[i][IllnessGroup.count] == 0 then
            group[i] = group[#group]
            group[#group] = nil
        end
    end
end

function IllnessGroup.remove_persons(group, count, diseases)
    diseases = diseases or HEALTHY
    for i = 1, #group do
        local entry = group[i]
        if shallow_equal(entry[IllnessGroup.diseases], diseases) then
            local new_count = entry[IllnessGroup.count] - count
            if new_count > 0 then
                entry[IllnessGroup.count] = new_count
            else
                if i ~= IllnessGroup.healthy_entry then
                    group[i] = group[#group]
                    group[#group] = nil
                end
            end
        end
    end
end

function IllnessGroup.merge(lh, rh, keep_rh)
    for i = 1, #rh do
        local entry = rh[i]
        add_persons(lh, entry[IllnessGroup.count], entry[IllnessGroup.diseases])

        if not keep_rh then
            IllnessGroup.remove_persons(rh, entry[IllnessGroup.count], entry[IllnessGroup.diseases])
        end
    end
end

function IllnessGroup.take(group, count, total_count)
    if not total_count then
        total_count = 0
        for i = 1, #group do
            total_count = total_count + group[i][IllnessGroup.count]
        end
    end

    local ret = new_illness_group(0)
    local percentage = count / total_count
    local taken = 0

    for i = 1, #group do
        local entry = group[i]
        local current_count = entry[IllnessGroup.count]

        local to_take
        if count - taken < total_count - taken then
            to_take = round(current_count * percentage)
        else
            to_take = current_count
        end

        entry[IllnessGroup.count] = current_count - to_take
        add_persons(ret, to_take, entry[IllnessGroup.diseases])
    end
    remove_empty_disease_entries(group)

    return ret
end

---------------------------------------------------------------------------------------------------
-- << inhabitant groups >>
--- Object class for holding groups of inhabitants.
InhabitantGroup = {}

local DEFAULT_HAPPINESS = 10
local DEFAULT_HEALTH = 10
local DEFAULT_SANITY = 10

--- Constructs a new InhabitantGroup object.
function InhabitantGroup.new(caste, count, happiness, health, sanity, illnesses)
    return {
        [EK.type] = caste,
        [EK.inhabitants] = count or 0,
        [EK.happiness] = happiness or DEFAULT_HAPPINESS,
        [EK.health] = health or DEFAULT_HEALTH,
        [EK.sanity] = sanity or DEFAULT_SANITY,
        [EK.illnesses] = illnesses or new_illness_group(count or 0)
    }
end
local new_group = InhabitantGroup.new

--- Adds the necessary data so this house can also work as an InhabitantGroup.
function InhabitantGroup.new_house(house)
    house[EK.inhabitants] = 0
    house[EK.happiness] = 0
    house[EK.health] = 0
    house[EK.sanity] = 0
    house[EK.illnesses] = new_illness_group(0)
end

function InhabitantGroup.empty(group)
    group[EK.inhabitants] = 0
    group[EK.happiness] = 0
    group[EK.health] = 0
    group[EK.sanity] = 0
    group[EK.illnesses] = new_illness_group(0)
end

function InhabitantGroup.can_be_merged(lh, rh)
    return lh[EK.type] == rh[EK.type]
end
local groups_can_merge = InhabitantGroup.can_be_merged

function InhabitantGroup.merge(lh, rh, keep_rh)
    if not groups_can_merge(lh, rh) then
        error("Sosciencity tried to merge two incompatible InhabitantGroup objects.")
    end

    local count_left = lh[EK.inhabitants]
    local count_right = rh[EK.inhabitants]

    lh[EK.inhabitants] = count_left + count_right

    lh[EK.happiness] = weighted_average(lh[EK.happiness], count_left, rh[EK.happiness], count_right)
    lh[EK.health] = weighted_average(lh[EK.health], count_left, rh[EK.health], count_right)
    lh[EK.sanity] = weighted_average(lh[EK.sanity], count_left, rh[EK.sanity], count_right)

    IllnessGroup.merge(lh[EK.illnesses], rh[EK.illnesses], keep_rh)

    if not keep_rh then
        InhabitantGroup.empty(rh)
    end
end

function InhabitantGroup.take(group, count)
    local existing_count = group[EK.inhabitants]
    local taken_count = min(existing_count, count)

    group[EK.inhabitants] = existing_count - taken_count

    local taken_illnesses = IllnessGroup.take(group[EK.illnesses], taken_count)

    local ret = copy(group)
    ret[EK.inhabitants] = taken_count
    ret[EK.illnesses] = taken_illnesses
    return ret
end

function InhabitantGroup.merge_partially(lh, rh, count)
    InhabitantGroup.merge(lh, InhabitantGroup.take(rh, count))
end

--- Reduces the difference between nominal and current happiness by roughly 3% per second. (~98% after 2 minutes.)
local function update_happiness(group, target, delta_ticks)
    local current = group[EK.happiness]
    group[EK.happiness] = current + (target - current) * (1 - 0.9995 ^ delta_ticks)
end

--- Reduces the difference between nominal and current health. (~98% after 10 minutes.)
local function update_health(group, target, delta_ticks)
    local current = group[EK.health]
    group[EK.health] = current + (target - current) * (1 - 0.9999 ^ delta_ticks)
end

--- Reduces the difference between nominal and current sanity. (~98% after 20 minutes.)
local function update_sanity(group, target, delta_ticks)
    local current = group[EK.sanity]
    group[EK.sanity] = current + (target - current) * (1 - 0.99995 ^ delta_ticks)
end

local function get_effective_population_multiplier(happiness)
    return happiness * 0.1
end

function InhabitantGroup.get_power_usage(group)
    return group[EK.inhabitants] * castes[EK.type].power_demand
end
local get_power_usage = InhabitantGroup.get_power_usage

---------------------------------------------------------------------------------------------------
-- << castes >>

--- Checks if the given caste has been researched by the player.
--- @param caste_id Type
function Inhabitants.caste_is_researched(caste_id)
    return global.technologies[castes[caste_id].tech_name]
end
local is_researched = Inhabitants.caste_is_researched

--- Returns the total number of inhabitants.
function Inhabitants.get_population_count()
    return array_sum(population)
end
local get_population_count = Inhabitants.get_population_count

local function clockwork_bonus_no_penalty(effective_pop)
    effective_pop = effective_pop or effective_population[Type.clockwork]

    return floor(10 * sqrt(effective_pop / max(Register.get_machine_count(), 1)))
end

local function clockwork_bonus_with_penalty()
    local effective_pop = effective_population[Type.clockwork]
    local startup_costs = max(Register.get_machine_count(), 1) * 3

    return min(effective_pop / startup_costs, 1) * 80 +
        clockwork_bonus_no_penalty(max(effective_pop - startup_costs, 0))
end

--- Gets the current Clockwork caste bonus.
local function get_clockwork_bonus()
    if global.use_penalty then
        return clockwork_bonus_with_penalty()
    else
        return clockwork_bonus_no_penalty()
    end
end

--- Gets the current Orchid caste bonus.
local function get_orchid_bonus()
    return floor(sqrt(effective_population[Type.orchid]))
end

--- Gets the current Gunfire caste bonus.
local function get_gunfire_bonus()
    return floor(effective_population[Type.gunfire] * 10 / max(Register.get_type_count(Type.turret), 1)) -- TODO balancing
end

--- Gets the current Ember caste bonus.
local function get_ember_bonus()
    return floor(10 * sqrt(effective_population[Type.ember] / max(1, get_population_count())))
end

--- Gets the current Foundry caste bonus.
local function get_foundry_bonus()
    return floor(sqrt(effective_population[Type.foundry] * 5))
end

--- Gets the current Gleam caste bonus.
local function get_gleam_bonus()
    return floor(sqrt(effective_population[Type.gleam]))
end

--- Gets the current Aurora caste bonus.
local function get_aurora_bonus()
    return floor(sqrt(effective_population[Type.aurora]))
end

local function get_plasma_bonus()
    return floor(10 * sqrt(effective_population[Type.plasma] / max(1, get_population_count())))
end

-- Assumes value is an integer
local function set_gunfire_bonus(value)
    set_binary_techs(value, "-gunfire-caste")
    caste_bonuses[Type.gunfire] = value
end

-- Assumes value is an integer
local function set_foundry_bonus(value)
    set_binary_techs(value, "-foundry-caste")
    caste_bonuses[Type.foundry] = value
end

-- Assumes value is an integer
local function set_gleam_bonus(value)
    set_binary_techs(value, "-gleam-caste")
    caste_bonuses[Type.gleam] = value
end

--- Updates all the caste bonuses and sets the ones that are applied global instead of per-entity. At the moment these are Gunfire, Gleam and Foundry.
local function update_caste_bonuses()
    caste_bonuses[Type.clockwork] = get_clockwork_bonus()
    caste_bonuses[Type.orchid] = get_orchid_bonus()
    caste_bonuses[Type.ember] = get_ember_bonus()
    caste_bonuses[Type.aurora] = get_aurora_bonus()
    caste_bonuses[Type.plasma] = get_plasma_bonus()

    -- hidden technology based bonuses
    -- We check if the bonuses have actually changed to avoid unnecessary api calls
    local current_gunfire_bonus = get_gunfire_bonus()
    if caste_bonuses[Type.gunfire] ~= current_gunfire_bonus then
        set_gunfire_bonus(current_gunfire_bonus)
    end

    local current_foundry_bonus = get_foundry_bonus()
    if caste_bonuses[Type.foundry] ~= current_foundry_bonus then
        set_foundry_bonus(current_foundry_bonus)
    end

    local current_gleam_bonus = get_gleam_bonus()
    if caste_bonuses[Type.gleam] ~= current_gleam_bonus then
        set_gleam_bonus(current_gleam_bonus)
    end
end

---------------------------------------------------------------------------------------------------
-- << workforce >>
-- Manufactories need inhabitants as workers.
-- The employment is saved by having a 'workers' table with (housing, count) pairs on the manufactory side.
-- On the housing side there is a table with the occupations of the inhabitants.
-- If they work at a manufactory, then the occupation is a (manufactory, count) pair.

--- Returns the number of employable inhabitants living in the housing entry.
function Inhabitants.get_employable_count(entry)
    return entry[EK.inhabitants] - entry[EK.employed] - entry[EK.ill]
end
local get_employable_count = Inhabitants.get_employable_count

--- Tries to employ the given number of people from the house for the manufactory and
--- returns the number of actually employed workers.
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

local function look_for_workers(manufactory, castes, count)
    local workers_found = 0

    for i = 1, #castes do
        for _, house in Neighborhood.all_of_type(manufactory, castes[i]) do
            workers_found = workers_found + try_employ(manufactory, house, count - workers_found)

            if workers_found == count then
                return
            end
        end
    end
end

--- Fires all the workers working in this building.
--- Must be called if a building with workforce gets deconstructed.
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

--- Tries to free the given number of inhabitants from their employment.
--- Returns the number of fired inhabitants.
local function unemploy_inhabitants(house, count)
    count = min(count, house[EK.employed])
    local to_fire = count
    local employments = house[EK.employments]
    local house_number = house[EK.unit_number]

    for unit_number, employed_count in pairs(employments) do
        local fired = min(employed_count, to_fire)
        to_fire = to_fire - fired

        -- set to nil if all employees got fired to delete the link
        local new_employment_count = (fired == employed_count) and nil or (employed_count - fired)

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

--- Ends the employment of all employed inhabitants of this house.
--- Must be called if a house gets deconstructed.
local function unemploy_all_inhabitants(house)
    unemploy_inhabitants(house, house[EK.employed])
end

--- Looks for employees if this entry needs then.
function Inhabitants.update_workforce(manufactory)
    local workforce = get_building_details(manufactory).workforce

    if not workforce then
        return
    end

    local nominal_count = workforce.count
    local current_workers = manufactory[EK.worker_count]

    if current_workers < nominal_count then
        look_for_workers(manufactory, workforce.castes, nominal_count - current_workers)
    end
end

--- Returns a percentage on how satisfied the given buildings need for workers is.
function Inhabitants.evaluate_workforce(manufactory)
    local workforce = get_building_details(manufactory).workforce

    if not workforce then
        return 1
    end

    local current_workers = manufactory[EK.worker_count]

    -- TODO let happiness and or health affect performance
    return current_workers / workforce.count
end

---------------------------------------------------------------------------------------------------
-- << inhabitant functions >>
local function get_nominal_value(influences, factors)
    return max(0, array_sum(influences) * array_product(factors))
end

function Inhabitants.get_nominal_happiness(entry)
    return get_nominal_value(entry[EK.happiness_summands], entry[EK.happiness_factors])
end

function Inhabitants.get_nominal_health(entry)
    return get_nominal_value(entry[EK.health_summands], entry[EK.health_factors])
end

function Inhabitants.get_nominal_sanity(entry)
    return get_nominal_value(entry[EK.sanity_summands], entry[EK.sanity_factors])
end

local function update_free_space_status(entry)
    if entry[EK.is_improvised] then
        return
    end

    local caste_id = entry[EK.type]
    local unit_number = entry[EK.unit_number]

    if get_free_capacity(entry) > 0 then
        houses_with_free_capacity[caste_id][unit_number] = nil
    else
        houses_with_free_capacity[caste_id][unit_number] = unit_number
    end
end

local function get_next_free_house(caste_id)
    local next_houses_table = next_houses[caste_id]

    if #next_houses_table == 0 then
        -- create the next free houses queue
        Tirislib_Tables.merge(next_houses_table, houses_with_free_capacity[caste_id])
        shuffle(next_houses_table)

        -- check if there are any free houses at all
        if #next_houses_table == 0 then
            return nil
        end
    end

    local unit_number = next_houses_table[#next_houses_table]
    next_houses_table[#next_houses_table] = nil

    local entry = Register.try_get(unit_number)
    if entry and entry[EK.type] == caste_id then
        return entry
    else
        -- remove it from the list of free houses
        houses_with_free_capacity[caste_id][unit_number] = nil
        -- skip this outdated house
        return get_next_free_house(caste_id)
    end
end

--- Tries to add the specified amount of inhabitants to the house-entry.
--- Returns the number of inhabitants that were added.
--- @param entry Entry
--- @param group InhabitantGroup
function Inhabitants.try_add_to_house(entry, group)
    local count_moving_in = min(group[EK.inhabitants], get_free_capacity(entry))

    if count_moving_in == 0 then
        return 0
    end

    InhabitantGroup.merge_partially(entry, group, count_moving_in)
    update_free_space_status(entry)

    return count_moving_in
end
local try_add_to_house = Inhabitants.try_add_to_house

--- Tries to distribute the specified inhabitants to houses with free capacity.
--- Returns the number of inhabitants that were distributed.
--- @param group InhabitantGroup
function Inhabitants.distribute_inhabitants(group)
    local count_before = group[EK.inhabitants]
    local caste_id = group[EK.type]
    local next_house = get_next_free_house(caste_id)

    local to_distribute = count_before
    while to_distribute > 0 and next_house do
        to_distribute = to_distribute - try_add_to_house(next_house, group)

        next_house = get_next_free_house(caste_id)
    end

    return count_before - to_distribute
end
local distribute_inhabitants = Inhabitants.distribute_inhabitants

---------------------------------------------------------------------------------------------------
-- << housing update >>
-- it's so complex, it got his own section

local function get_garbage_influence(entry)
    return max(get_garbage_value(entry) - 20, 0) * (-0.1)
end

--- Evaluates the effect of the housing on its inhabitants.
--- @param entry Entry
local function evaluate_housing(entry, happiness_summands, sanity_summands, caste)
    local housing = get_housing_details(entry)
    happiness_summands[HappinessSummand.housing] = housing.comfort
    sanity_summands[SanitySummand.housing] = housing.comfort

    happiness_summands[HappinessSummand.suitable_housing] =
        (entry[EK.type] == housing.caste) and housing.caste_bonus or 0

    happiness_summands[HappinessSummand.garbage] = get_garbage_influence(entry)

    if has_power(entry) then
        happiness_summands[HappinessSummand.power] = caste.power_bonus
        happiness_summands[HappinessSummand.no_power] = 0
    else
        happiness_summands[HappinessSummand.power] = 0
        happiness_summands[HappinessSummand.no_power] = caste.no_power_malus
    end
end

local function evaluate_sosciety(happiness_summands, health_summands, sanity_summands, caste)
    happiness_summands[HappinessSummand.ember] = caste_bonuses[Type.ember]
    health_summands[HealthSummand.plasma] = caste_bonuses[Type.plasma]

    local fear_malus = global.fear * caste.fear_multiplier
    happiness_summands[HappinessSummand.fear] = fear_malus
    if fear_malus > 5 then
        health_summands[HealthSummand.fear] = fear_malus / 2
        sanity_summands[SanitySummand.fear] = fear_malus / 2
    else
        health_summands[HealthSummand.fear] = 0
        sanity_summands[SanitySummand.fear] = 0
    end
end

--- Gets the trend toward the next inhabitant that moves out.
function Inhabitants.get_emigration_trend(nominal_happiness, caste, delta_ticks)
    local threshold_diff = nominal_happiness - caste.immigration_threshold

    if threshold_diff > 0 then
        return caste.immigration_coefficient * delta_ticks * (1 + threshold_diff / 4)
    else
        return emigration_coefficient * delta_ticks * (1 - threshold_diff / 4)
    end
end
local get_emigration_trend = Inhabitants.get_emigration_trend

local function update_emigration(entry, nominal_happiness, caste_id, delta_ticks)
    local trend = entry[EK.emigration_trend]
    trend = trend + get_emigration_trend(nominal_happiness, castes[caste_id], delta_ticks)
    if trend > 1 then
        -- buffer caps at one
        trend = 1
    elseif trend <= -1 then
        -- let people move out
        local emigrating = -ceil(trend)
        trend = trend + emigrating

        local emigrants = InhabitantGroup.take(entry, emigrating)
        Communication.log_emigration(emigrants, EmigrationCause.unhappy)
    end
    entry[EK.emigration_trend] = trend
end

function Inhabitants.get_garbage_progress(inhabitants, delta_ticks)
    return garbage_coefficient * inhabitants * delta_ticks
end
local get_garbage_progress = Inhabitants.get_garbage_progress

local function update_garbage_output(entry, delta_ticks)
    local garbage = entry[EK.garbage_progress] + get_garbage_progress(entry[EK.inhabitants], delta_ticks)
    if garbage >= 1 then
        local produced_garbage = floor(garbage)
        produce_garbage(entry, "garbage", produced_garbage)
        garbage = garbage - produced_garbage
    end
    entry[EK.garbage_progress] = garbage
end

local function update_housing_census(entry, caste_id)
    local inhabitants = entry[EK.inhabitants]
    local official_inhabitants = entry[EK.official_inhabitants]

    -- inhabitant count
    if inhabitants ~= official_inhabitants then
        population[caste_id] = population[caste_id] - official_inhabitants + inhabitants
        entry[EK.official_inhabitants] = inhabitants

        update_free_space_status(entry)

        set_power_usage(entry, get_power_usage(entry))
    end

    -- caste bonus points
    local points = get_employable_count(entry) * get_effective_population_multiplier(entry[EK.happiness])
    effective_population[caste_id] = effective_population[caste_id] - entry[EK.points] + points
    entry[EK.points] = points
end

local function remove_housing_census(entry)
    local caste_id = entry[EK.type]

    population[caste_id] = population[caste_id] - entry[EK.official_inhabitants]
    effective_population[caste_id] = effective_population[caste_id] - entry[EK.points]
end

--- Updates the given housing entry.
--- @param entry Entry
--- @param delta_ticks integer
local function update_house(entry, delta_ticks)
    local caste_id = entry[EK.type]
    local caste = castes[caste_id]

    local happiness_summands = entry[EK.happiness_summands]
    local happiness_factors = entry[EK.happiness_factors]

    local health_summands = entry[EK.health_summands]
    local health_factors = entry[EK.health_factors]

    local sanity_summands = entry[EK.sanity_summands]
    local sanity_factors = entry[EK.sanity_factors]

    local inhabitants = entry[EK.inhabitants]

    -- collect all the influences
    evaluate_diet(entry, delta_ticks)
    evaluate_housing(entry, happiness_summands, sanity_summands, caste)
    evaluate_water(entry, delta_ticks, happiness_factors, health_factors, sanity_factors)
    evaluate_sosciety(happiness_summands, health_summands, sanity_summands, caste)

    -- update health
    local nominal_health = get_nominal_value(health_summands, health_factors)
    update_health(entry, nominal_health, delta_ticks)

    happiness_factors[HappinessFactor.health] = (inhabitants > 0) and (entry[EK.health] - 10) / 20. + 1 or 1

    -- update sanity
    local nominal_sanity = get_nominal_value(sanity_summands, sanity_factors)
    update_sanity(entry, nominal_sanity, delta_ticks)

    happiness_factors[HappinessFactor.sanity] = (inhabitants > 0) and (entry[EK.sanity] - 10) / 15. + 1 or 1

    -- update happiness
    local nominal_happiness = get_nominal_value(happiness_summands, happiness_factors)
    update_happiness(entry, nominal_happiness, delta_ticks)

    -- TODO diseases

    update_emigration(entry, nominal_happiness, caste_id, delta_ticks)

    update_housing_census(entry, caste_id)

    update_garbage_output(entry, delta_ticks)
end

---------------------------------------------------------------------------------------------------
-- << immigration >>
function Inhabitants.get_immigration_trend(delta_ticks, caste_id)
    local pop = population[caste_id]

    if pop > 0 then
        -- TODO this method to get the average happiness doesn't work anymore because the meaning of effective population changed
        local average_happiness = effective_population[caste_id] / population[caste_id]
        return castes[caste_id].immigration_coefficient * delta_ticks * average_happiness
    else
        return castes[caste_id].immigration_coefficient * delta_ticks
    end
end
local get_immigration_trend = Inhabitants.get_immigration_trend

local function update_immigration(delta_ticks)
    for caste = 1, #immigration do
        if is_researched(caste) then
            immigration[caste] = immigration[caste] + get_immigration_trend(delta_ticks, caste)
        end
    end
end

function Inhabitants.migration_wave(immigration_port_details)
    local capacity = immigration_port_details.capacity
    local order = Tirislib_Tables.sequence(1, #immigration)
    shuffle(order)

    for i = 1, #immigration do
        local caste = order[i]
        local count_immigrated = min(floor(immigration[caste]), capacity)

        capacity = capacity - count_immigrated
        immigration[caste] = immigration[caste] - count_immigrated

        local immigrants = new_group(caste, count_immigrated)

        Inhabitants.add_to_homeless_pool(immigrants)
    end
end

---------------------------------------------------------------------------------------------------
-- << fear >>
--- Lowers the population's fear over time. Assumes an update rate of 10 ticks.
--- The fear level decreases after 2 minutes without a tragic event and the rate is affected by the time since the event.
--- A fear level of 10 will decrease to 0 after 12.5 minutes.
function Inhabitants.ease_fear(current_tick)
    local coefficient = 1e-7
    local time_since_last_event = current_tick - (global.last_fear_event or 0)

    if time_since_last_event > 7200 then -- 2 minutes
        global.fear = max(0, global.fear - time_since_last_event * coefficient)
    end
end

--- Adds fear after a civil building got destroyed.
function Inhabitants.add_fear()
    global.last_fear_event = game.tick
    global.fear = global.fear + 0.25
end

--- Adds fear after an inhabited house was destroyed.
function Inhabitants.add_casualty_fear(destroyed_house)
    Inhabitants.add_fear()

    local casualties = destroyed_house[EK.inhabitants]
    global.fear = global.fear + 0.05 + casualties
    Communication.log_casualties(destroyed_house)
end

---------------------------------------------------------------------------------------------------
-- << homeless inhabitants >>
local hut_details = Housing.values["improvised-hut"]
local hut_variations = copy(hut_details.alternatives)
hut_variations[#hut_variations+1] = "improvised-hut"
local function create_improvised_huts(group)
    local caste_id = group[EK.type]

    for _, market in Register.all_of_type(Type.market) do
        local entity = market[EK.entity]
        local position = entity.position
        local surface = entity.surface
        local range = get_building_details(market).range

        local bounding_box = Tirislib_Utils.get_range_bounding_box(position, range)

        while group[EK.inhabitants] > 0 do
            local possible_position =
                surface.find_non_colliding_position_in_box("improvised-hut", bounding_box, 2, true)
            if not possible_position then
                break
            end

            local new_hut =
                surface.create_entity {
                name = hut_variations[math.random(#hut_variations)],
                position = possible_position,
                force = "player"
            }
            local entry = Register.add(new_hut, caste_id)

            local count_moving_in = min(group[EK.inhabitants], hut_details.room_count)
            InhabitantGroup.merge_partially(entry, group, count_moving_in)
        end
    end
end

local function try_house_homeless()
    for _, group in pairs(homeless) do
        distribute_inhabitants(group)
    end
end

--- Adds people without a home to the global homeless pool.
function Inhabitants.add_to_homeless_pool(group)
    local caste_id = group[EK.type]
    InhabitantGroup.merge(homeless[caste_id], group)

    if global.technologies["resettlement"] then
        try_house_homeless()
    end
end

local function update_homelessness()
    local resettlement = global.technologies["resettlement"]

    for _, homeless_group in pairs(homeless) do
        update_happiness(homeless_group, 0, 1800)
        update_health(homeless_group, 0, 1800)
        update_sanity(homeless_group, 0, 1800)
        -- TODO diseases

        local count = homeless_group[EK.inhabitants]
        local emigrating = floor(count * (resettlement and 0.1 or 0.3))
        local emigrated = InhabitantGroup.take(homeless_group, emigrating)
        Communication.log_emigration(emigrated, EmigrationCause.homeless)

        distribute_inhabitants(homeless_group)
        create_improvised_huts(homeless_group)
    end
end

---------------------------------------------------------------------------------------------------
-- << general update >>
function Inhabitants.update(current_tick)
    update_caste_bonuses()
    update_immigration(10)

    if current_tick % 3600 == 0 then
        update_homelessness()
    end
end

---------------------------------------------------------------------------------------------------
-- << housing life cycle and event handlers >>

--- Changes the type of the entry to the given caste if it makes sense. Returns true if it did so.
--- @param entry Entry
--- @param caste_id integer
--- @param loud boolean
function Inhabitants.try_allow_for_caste(entry, caste_id, loud)
    if
        entry[EK.type] == Type.empty_house and is_researched(caste_id) and
            Housing.allowes_caste(get_housing_details(entry), caste_id)
     then
        Register.change_type(entry, caste_id)

        if loud then
            Communication.caste_allowed_in(entry, caste_id)
        end
        return true
    else
        return false
    end
end

--- Initializes the given entry so it can work as an housing entry.
--- @param entry Entry
function Inhabitants.create_house(entry)
    InhabitantGroup.new_house(entry)
    entry[EK.official_inhabitants] = 0
    entry[EK.points] = 0

    entry[EK.is_improvised] = (get_housing_details(entry).main_entity == "improvised-hut")

    entry[EK.happiness_summands] = Tirislib_Tables.new_array(Tirislib_Tables.count(HappinessSummand), 0.)
    entry[EK.happiness_factors] = Tirislib_Tables.new_array(Tirislib_Tables.count(HappinessFactor), 1.)

    entry[EK.health_summands] = Tirislib_Tables.new_array(Tirislib_Tables.count(HealthSummand), 0.)
    entry[EK.health_factors] = Tirislib_Tables.new_array(Tirislib_Tables.count(HealthFactor), 1.)

    entry[EK.sanity_summands] = Tirislib_Tables.new_array(Tirislib_Tables.count(SanitySummand), 0.)
    entry[EK.sanity_factors] = Tirislib_Tables.new_array(Tirislib_Tables.count(SanityFactor), 1.)

    entry[EK.emigration_trend] = 0
    entry[EK.garbage_progress] = 0

    entry[EK.employed] = 0
    entry[EK.employments] = {}
    entry[EK.ill] = 0

    update_free_space_status(entry)
end

function Inhabitants.copy_house(source, destination)
    try_add_to_house(destination, source)
end

--- Removes all the inhabitants living in the house. Must be called when a housing entity stops existing.
--- @param entry Entry
function Inhabitants.remove_house(entry, cause)
    unemploy_all_inhabitants(entry)
    remove_housing_census(entry)

    local unit_number = entry[EK.unit_number]
    houses_with_free_capacity[entry[EK.type]][unit_number] = nil
    Tirislib_Tables.remove_all(next_houses, unit_number)

    if cause == DestructionCause.destroyed then
        Inhabitants.add_casualty_fear(entry)
    else
        Inhabitants.add_to_homeless_pool(entry)
    end
end

-- Set event handlers for the housing entities.
for _, caste in pairs(TypeGroup.all_castes) do
    Register.set_entity_creation_handler(caste, Inhabitants.create_house)
    Register.set_entity_copy_handler(caste, Inhabitants.copy_house)
    Register.set_entity_updater(caste, update_house)
    Register.set_entity_destruction_handler(caste, Inhabitants.remove_house)
end

return Inhabitants
