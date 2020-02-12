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
        [caste_id]: float (progress toward the next immigrant)

    global.houses_with_free_capacity: table
        [caste_id]: table
            [unit_number]: truthy (lookup)

    global.next_houses: table
        [caste_id]: shuffled array of unit_numbers

    global.fear: float (fear level)

    global.last_fear_event: tick
]]
-- local often used functions for enormous performance gains
local global
local population
local effective_population
local caste_bonuses
local immigration
local houses_with_free_capacity
local next_houses
local Register = Register

local castes = Castes.values
local emigration_coefficient = Castes.emigration_coefficient
local garbage_coefficient = Castes.garbage_coefficient

local evaluate_diet = Consumption.evaluate_diet
local evaluate_water = Consumption.evaluate_water

local try_output_ideas = Inventories.try_output_ideas
local produce_garbage = Inventories.produce_garbage
local get_garbage_value = Inventories.get_garbage_value

local get_housing = Housing.get
local evaluate_housing = Housing.evaluate
local get_free_capacity = Housing.get_free_capacity

local set_power_usage = Subentities.set_power_usage
local has_power = Subentities.has_power

local floor = math.floor
local ceil = math.ceil
local sqrt = math.sqrt
local max = math.max
local min = math.min
local array_sum = Tirislib_Tables.array_sum
local array_product = Tirislib_Tables.array_product
local weighted_average = Tirislib_Utils.weighted_average

local function set_locals()
    global = _ENV.global
    population = global.population
    effective_population = global.effective_population
    caste_bonuses = global.caste_bonuses
    immigration = global.immigration
    houses_with_free_capacity = global.houses_with_free_capacity
    next_houses = global.next_houses
end

---------------------------------------------------------------------------------------------------
-- << caste bonus functions >>
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

-- sets the hidden caste-technologies so they encode the given value
local function set_binary_techs(value, name)
    local new_value = value
    local techs = game.forces.player.technologies

    for strength = 0, 20 do
        new_value = floor(value / 2)

        -- if new_value times two doesn't equal value, then the remainder was one
        -- which means that the current binary digit is one and that the corresponding tech should be researched
        techs[strength .. name].researched = (new_value * 2 ~= value)

        strength = strength + 1
        value = new_value
    end
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
function Inhabitants.update_caste_bonuses()
    caste_bonuses[Type.clockwork] = get_clockwork_bonus()
    caste_bonuses[Type.orchid] = get_orchid_bonus()
    caste_bonuses[Type.ember] = get_ember_bonus()
    caste_bonuses[Type.aurora] = get_aurora_bonus()
    caste_bonuses[Type.plasma] = get_plasma_bonus()

    -- tech-bonus castes
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

--- Gets the current bonus of the given caste.
--- @param caste_id Type
function Inhabitants.get_caste_bonus(caste_id)
    return caste_bonuses[caste_id]
end

---------------------------------------------------------------------------------------------------
-- << inhabitant functions >>

--- Checks if the given caste has been researched by the player.
--- @param caste_id Type
function Inhabitants.caste_is_researched(caste_id)
    return global.technologies[castes[caste_id].tech_name]
end
local is_researched = Inhabitants.caste_is_researched

local function get_effective_population_multiplier(happiness)
    return happiness * 0.1
end

function Inhabitants.get_effective_population(entry)
    return entry[EntryKey.inhabitants] * get_effective_population_multiplier(entry[EntryKey.happiness])
end

function Inhabitants.get_power_usage(entry)
    local caste = castes[entry[EntryKey.type]]
    return caste.power_demand * entry[EntryKey.inhabitants]
end
local get_power_usage = Inhabitants.get_power_usage

--- Changes the type of the entry to the given caste if it makes sense. Returns true if it did so.
--- @param entry Entry
--- @param caste_id integer
--- @param loud boolean
function Inhabitants.try_allow_for_caste(entry, caste_id, loud)
    if
        entry[EntryKey.type] == Type.empty_house and Housing.allowes_caste(get_housing(entry), caste_id) and
            is_researched(caste_id)
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

local DEFAULT_HAPPINESS = 10
local DEFAULT_HEALTH = 10
local DEFAULT_SANITY = 10

--- Tries to add the specified amount of inhabitants to the house-entry.
--- Returns the number of inhabitants that were added.
--- @param entry Entry
--- @param count integer
--- @param happiness number
--- @param health number
--- @param sanity number
function Inhabitants.try_add_to_house(entry, count, happiness, health, sanity)
    local count_moving_in = min(count, get_free_capacity(entry))

    if count_moving_in == 0 then
        return 0
    end

    local caste_id = entry[EntryKey.type]
    local inhabitants = entry[EntryKey.inhabitants]

    effective_population[caste_id] =
        effective_population[caste_id] - inhabitants * get_effective_population_multiplier(entry[EntryKey.happiness])

    happiness = happiness or DEFAULT_HAPPINESS
    health = health or DEFAULT_HEALTH
    sanity = sanity or DEFAULT_SANITY

    entry[EntryKey.happiness] = weighted_average(entry[EntryKey.happiness], inhabitants, happiness, count_moving_in)
    entry[EntryKey.health] = weighted_average(entry[EntryKey.health], inhabitants, health, count_moving_in)
    entry[EntryKey.sanity] = weighted_average(entry[EntryKey.sanity], inhabitants, sanity, count_moving_in)
    entry[EntryKey.inhabitants] = inhabitants + count_moving_in

    population[caste_id] = population[caste_id] + count_moving_in
    effective_population[caste_id] =
        effective_population[caste_id] +
        (inhabitants + count_moving_in) * get_effective_population_multiplier(entry[EntryKey.happiness])

    set_power_usage(entry, get_power_usage(entry))

    if get_free_capacity(entry) == 0 then
        local unit_number = entry[EntryKey.entity].unit_number
        houses_with_free_capacity[caste_id][unit_number] = nil
    end

    return count_moving_in
end
local try_add_to_house = Inhabitants.try_add_to_house

local function get_next_free_house(caste_id)
    local next_houses_table = next_houses[caste_id]

    if #next_houses_table == 0 then
        -- create the next free houses queue
        Tirislib_Tables.merge(next_houses_table, houses_with_free_capacity[caste_id])
        Tirislib_Tables.shuffle(next_houses_table)

        -- check if there are any free houses at all
        if #next_houses_table == 0 then
            return nil
        end
    end

    local unit_number = next_houses_table[#next_houses_table]
    next_houses_table[#next_houses_table] = nil

    local entry = Register.try_get(unit_number)
    if entry and entry[EntryKey.type] == caste_id then
        return entry
    else
        -- remove it from the list of free houses
        houses_with_free_capacity[caste_id][unit_number] = nil
        -- skip this outdated house
        return get_next_free_house(caste_id)
    end
end

--- Tries to distribute the specified inhabitants to houses with free capacity.
--- Returns the number of inhabitants that were distributed.
--- @param caste_id Type
--- @param count integer
--- @param happiness number
--- @param health number
--- @param sanity number
function Inhabitants.distribute_inhabitants(caste_id, count, happiness, health, sanity)
    local to_distribute = count
    local next_house = get_next_free_house(caste_id)

    while to_distribute > 0 and next_house do
        to_distribute = to_distribute - try_add_to_house(next_house, min(to_distribute, 5), happiness, health, sanity)

        next_house = get_next_free_house(caste_id)
    end

    return count - to_distribute
end
local distribute_inhabitants = Inhabitants.distribute_inhabitants

function Inhabitants.clone_inhabitants(source, destination)
    try_add_to_house(
        destination,
        source[EntryKey.inhabitants],
        source[EntryKey.happiness],
        source[EntryKey.health],
        source[EntryKey.sanity]
    )
end

--- Tries to remove the specified amount of inhabitants from the house-entry.
--- Returns the number of inhabitants that were removed.
--- @param entry Entry
--- @param count integer
function Inhabitants.remove_from_house(entry, count)
    local count_moving_out = min(entry[EntryKey.inhabitants], count)

    if count_moving_out == 0 then
        return 0
    end

    local caste_id = entry[EntryKey.type]

    effective_population[caste_id] =
        effective_population[caste_id] -
        count_moving_out * get_effective_population_multiplier(entry[EntryKey.happiness])
    population[caste_id] = population[caste_id] - count_moving_out
    entry[EntryKey.inhabitants] = entry[EntryKey.inhabitants] - count_moving_out

    set_power_usage(entry, get_power_usage(entry))

    if get_free_capacity(entry) > 0 then
        local unit_number = entry[EntryKey.entity].unit_number
        houses_with_free_capacity[caste_id][unit_number] = unit_number
    end

    return count_moving_out
end
local remove_from_house = Inhabitants.remove_from_house

--- Removes all the inhabitants living in the house. Must be called when a housing entity stops existing.
--- @param entry Entry
function Inhabitants.remove_house(entry, unit_number)
    houses_with_free_capacity[entry[EntryKey.type]][unit_number] = nil
    remove_from_house(entry, entry[EntryKey.inhabitants])
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

function Inhabitants.get_idea_progress(happiness, inhabitants, caste, delta_ticks)
    return max(0, happiness - caste.idea_threshold) * delta_ticks * inhabitants * caste.idea_coefficient
end
local get_idea_progress = Inhabitants.get_idea_progress

function Inhabitants.get_garbage_progress(inhabitants, delta_ticks)
    return garbage_coefficient * inhabitants * delta_ticks
end
local get_garbage_progress = Inhabitants.get_garbage_progress

--- Reduce the difference between nominal and current happiness by roughly 3% per second. (~98% after 2 minutes.)
local function update_happiness(target, current, delta_ticks)
    return current + (target - current) * (1 - 0.9995 ^ delta_ticks)
end

--- Reduce the difference between nominal and current health. (~98% after 10 minutes.)
local function update_health(target, current, delta_ticks)
    return current + (target - current) * (1 - 0.9999 ^ delta_ticks)
end

--- Reduce the difference between nominal and current sanity. (~98% after 20 minutes.)
local function update_sanity(target, current, delta_ticks)
    return current + (target - current) * (1 - 0.99995 ^ delta_ticks)
end

local function get_nominal_value(influences, factors)
    return max(0, array_sum(influences) * array_product(factors))
end

local function get_garbage_influence(entry)
    return max(get_garbage_value(entry) - 20, 0) * (-0.1)
end

--- Updates the given housing entry.
--- @param entry Entry
--- @param delta_ticks integer
function Inhabitants.update_house(entry, delta_ticks)
    local caste_id = entry[EntryKey.type]
    local caste_values = castes[caste_id]

    local old_happiness = entry[EntryKey.happiness]
    local happiness_summands = entry[EntryKey.happiness_summands]
    local happiness_factors = entry[EntryKey.happiness_factors]

    local health_summands = entry[EntryKey.health_summands]
    local health_factors = entry[EntryKey.health_factors]

    local sanity_summands = entry[EntryKey.sanity_summands]
    local sanity_factors = entry[EntryKey.sanity_factors]

    local inhabitants = entry[EntryKey.inhabitants]

    -- collect all the influences
    evaluate_diet(entry, delta_ticks)
    evaluate_housing(entry, happiness_summands, sanity_summands)
    evaluate_water(entry, delta_ticks, happiness_factors, health_factors, sanity_factors)

    happiness_summands[HappinessSummand.garbage] = get_garbage_influence(entry)

    if has_power(entry) then
        happiness_summands[HappinessSummand.power] = caste_values.power_bonus
        happiness_summands[HappinessSummand.no_power] = 0
    else
        happiness_summands[HappinessSummand.power] = 0
        happiness_summands[HappinessSummand.no_power] = caste_values.no_power_malus
    end

    happiness_summands[HappinessSummand.ember] = caste_bonuses[Type.ember]
    health_summands[HealthSummand.plasma] = caste_bonuses[Type.plasma]

    local fear_malus = global.fear * caste_values.fear_multiplier
    happiness_summands[HappinessSummand.fear] = fear_malus
    if fear_malus > 5 then
        health_summands[HealthSummand.fear] = fear_malus / 2
        sanity_summands[SanitySummand.fear] = fear_malus / 2
    else
        health_summands[HealthSummand.fear] = 0
        sanity_summands[SanitySummand.fear] = 0
    end

    -- update health
    local nominal_health = get_nominal_value(health_summands, health_factors)
    local new_health = update_health(nominal_health, entry[EntryKey.health], delta_ticks)
    entry[EntryKey.health] = new_health

    happiness_factors[HappinessFactor.health] = (inhabitants > 0) and (new_health - 10) / 20. + 1 or 1

    -- update sanity
    local nominal_sanity = get_nominal_value(sanity_summands, sanity_factors)
    local new_sanity = update_sanity(nominal_sanity, entry[EntryKey.sanity], delta_ticks)
    entry[EntryKey.sanity] = new_sanity

    happiness_factors[HappinessFactor.sanity] = (inhabitants > 0) and (new_sanity - 10) / 15. + 1 or 1

    -- update happiness
    local nominal_happiness = get_nominal_value(happiness_summands, happiness_factors)
    local new_happiness = update_happiness(nominal_happiness, entry[EntryKey.happiness], delta_ticks)
    entry[EntryKey.happiness] = new_happiness

    -- update effective population because the happiness has changed (most likely)
    effective_population[caste_id] =
        effective_population[caste_id] - (inhabitants * get_effective_population_multiplier(old_happiness)) +
        (inhabitants * get_effective_population_multiplier(new_happiness))
    -- TODO diseases

    -- check if the caste actually produces ideas
    if caste_values.idea_item then
        local ideas =
            entry[EntryKey.idea_progress] + get_idea_progress(new_happiness, inhabitants, caste_values, delta_ticks)
        if ideas >= 1 then
            local produced_ideas = floor(ideas)
            try_output_ideas(entry, caste_values.idea_item, produced_ideas)
            ideas = ideas - produced_ideas
        end
        entry[EntryKey.idea_progress] = ideas
    end

    local garbage = entry[EntryKey.garbage_progress] + get_garbage_progress(inhabitants, delta_ticks)
    if garbage >= 1 then
        local produced_garbage = floor(garbage)
        produce_garbage(entry, "garbage", produced_garbage)
        garbage = garbage - produced_garbage
    end
    entry[EntryKey.garbage_progress] = garbage

    local trend = entry[EntryKey.emigration_trend]
    trend = trend + get_emigration_trend(nominal_happiness, caste_values, delta_ticks)
    if trend > 1 then
        -- buffer caps at one
        trend = 1
    elseif trend <= -1 then
        -- let people move out
        local emigrating = -ceil(trend)
        local emigrated = remove_from_house(entry, emigrating)
        trend = trend + emigrating
        Communication.log_emigration(caste_id, emigrated)
    end
    entry[EntryKey.emigration_trend] = trend
end

function Inhabitants.get_nominal_happiness(entry)
    return get_nominal_value(entry[EntryKey.happiness_summands], entry[EntryKey.happiness_factors])
end

function Inhabitants.get_nominal_health(entry)
    return get_nominal_value(entry[EntryKey.health_summands], entry[EntryKey.health_factors])
end

function Inhabitants.get_nominal_sanity(entry)
    return get_nominal_value(entry[EntryKey.sanity_summands], entry[EntryKey.sanity_factors])
end

function Inhabitants.get_immigration_trend(delta_ticks, caste_id)
    local pop = population[caste_id]

    if pop > 0 then
        local average_happiness = effective_population[caste_id] / population[caste_id]
        return castes[caste_id].immigration_coefficient * delta_ticks * average_happiness
    else
        return castes[caste_id].immigration_coefficient * delta_ticks
    end
end
local get_immigration_trend = Inhabitants.get_immigration_trend

function Inhabitants.immigration(delta_ticks)
    for caste = 1, #immigration do
        if is_researched(caste) then
            local immigration_trend = immigration[caste]
            immigration_trend = immigration_trend + get_immigration_trend(delta_ticks, caste)

            if immigration_trend > 1 then
                local immigrating = floor(immigration_trend)
                local immigrated = Inhabitants.distribute_inhabitants(caste, immigrating)
                immigration_trend = immigration_trend - immigrating
                Communication.log_immigration(caste, immigrated)
            end

            immigration[caste] = immigration_trend
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << resettlement >>
--- Looks for housings to move the inhabitants of this entry to.
--- Returns the number of resettled inhabitants.
--- @param entry Entry
function Inhabitants.try_resettle(entry, unit_number)
    if not global.technologies["resettlement"] then
        return 0
    end

    local caste = entry[EntryKey.type]

    -- remove the entry from the next_houses-table so they don't try to move into the house they're already living in
    houses_with_free_capacity[caste][unit_number] = nil
    Tirislib_Tables.remove_all(next_houses[caste], unit_number)
    local resettled =
        distribute_inhabitants(
        caste,
        entry[EntryKey.inhabitants],
        entry[EntryKey.happiness],
        entry[EntryKey.health],
        entry[EntryKey.sanity]
    )

    if resettled > 0 then
        Communication.people_resettled(entry, resettled)
    end

    return resettled
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

    local casualties = destroyed_house[EntryKey.inhabitants]
    global.fear = global.fear + 0.05 + casualties
    Communication.people_died_tragic(casualties)
end

---------------------------------------------------------------------------------------------------
-- << general >>

--- Initializes the given entry so it can work as an housing entry.
--- @param entry Entry
function Inhabitants.establish_house(caste_id, entry, unit_number)
    entry[EntryKey.happiness] = 0
    entry[EntryKey.happiness_summands] = Tirislib_Tables.new_array(Tirislib_Tables.count(HappinessSummand), 0.)
    entry[EntryKey.happiness_factors] = Tirislib_Tables.new_array(Tirislib_Tables.count(HappinessFactor), 1.)

    entry[EntryKey.health] = 0
    entry[EntryKey.health_summands] = Tirislib_Tables.new_array(Tirislib_Tables.count(HealthSummand), 0.)
    entry[EntryKey.health_factors] = Tirislib_Tables.new_array(Tirislib_Tables.count(HealthFactor), 1.)

    entry[EntryKey.sanity] = 0
    entry[EntryKey.sanity_summands] = Tirislib_Tables.new_array(Tirislib_Tables.count(SanitySummand), 0.)
    entry[EntryKey.sanity_factors] = Tirislib_Tables.new_array(Tirislib_Tables.count(SanityFactor), 1.)

    entry[EntryKey.inhabitants] = 0
    entry[EntryKey.emigration_trend] = 0
    entry[EntryKey.idea_progress] = 0
    entry[EntryKey.garbage_progress] = 0

    local free_houses = houses_with_free_capacity[caste_id]
    free_houses[unit_number] = unit_number
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
    global.houses_with_free_capacity = Tirislib_Tables.new_array_of_arrays(8)
    global.next_houses = Tirislib_Tables.new_array_of_arrays(8)

    set_locals()
end

--- Sets local references during on_load
function Inhabitants.load()
    set_locals()
end

return Inhabitants
