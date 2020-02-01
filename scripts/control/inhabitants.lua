Inhabitants = {}

-- local often used functions for enormous performance gains
local global
local population
local effective_population
local caste_bonuses
local immigration
local houses_with_free_capacity
local Register = Register

local castes = Caste.values
local emigration_coefficient = Caste.emigration_coefficient
local garbage_coefficient = Caste.garbage_coefficient

local evaluate_diet = Consumption.evaluate_diet
local evaluate_water = Consumption.evaluate_water

local try_output_ideas = Inventories.try_output_ideas
local produce_garbage = Inventories.produce_garbage

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
end

---------------------------------------------------------------------------------------------------
-- << caste bonus functions >>
--- Returns the total number of inhabitants.
function Inhabitants.get_population_count()
    return array_sum(population)
end
local get_population_count = Inhabitants.get_population_count

local function clockwork_bonus_no_penalty(effective_pop)
    effective_pop = effective_pop or effective_population[TYPE_CLOCKWORK]

    return floor(10 * sqrt(effective_pop / max(Register.get_machine_count(), 1)))
end

local function clockwork_bonus_with_penalty()
    local effective_pop = effective_population[TYPE_CLOCKWORK]
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
    return floor(sqrt(effective_population[TYPE_ORCHID]))
end

--- Gets the current Gunfire caste bonus.
local function get_gunfire_bonus()
    return floor(effective_population[TYPE_GUNFIRE] * 10 / max(Register.get_type_count(TYPE_TURRET), 1)) -- TODO balancing
end

--- Gets the current Ember caste bonus.
local function get_ember_bonus()
    return floor(10 * sqrt(effective_population[TYPE_EMBER] / max(1, get_population_count())))
end

--- Gets the current Foundry caste bonus.
local function get_foundry_bonus()
    return floor(sqrt(effective_population[TYPE_FOUNDRY] * 5))
end

--- Gets the current Gleam caste bonus.
local function get_gleam_bonus()
    return floor(sqrt(effective_population[TYPE_GLEAM]))
end

--- Gets the current Aurora caste bonus.
local function get_aurora_bonus()
    return floor(sqrt(effective_population[TYPE_AURORA]))
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
    caste_bonuses[TYPE_GUNFIRE] = value
end

-- Assumes value is an integer
local function set_foundry_bonus(value)
    set_binary_techs(value, "-foundry-caste")
    caste_bonuses[TYPE_FOUNDRY] = value
end

-- Assumes value is an integer
local function set_gleam_bonus(value)
    set_binary_techs(value, "-gleam-caste")
    caste_bonuses[TYPE_GLEAM] = value
end

--- Updates the caste bonuses that are applied global instead of per-entity. At the moment these are Gunfire, Gleam and Foundry.
function Inhabitants.update_caste_bonuses()
    caste_bonuses[TYPE_CLOCKWORK] = get_clockwork_bonus()
    caste_bonuses[TYPE_ORCHID] = get_orchid_bonus()
    caste_bonuses[TYPE_EMBER] = get_ember_bonus()
    caste_bonuses[TYPE_AURORA] = get_aurora_bonus()

    -- tech-bonus castes
    -- We check if the bonuses have actually changed to avoid unnecessary api calls
    local current_gunfire_bonus = get_gunfire_bonus()
    if caste_bonuses[TYPE_GUNFIRE] ~= current_gunfire_bonus then
        set_gunfire_bonus(current_gunfire_bonus)
    end

    local current_foundry_bonus = get_foundry_bonus()
    if caste_bonuses[TYPE_FOUNDRY] ~= current_foundry_bonus then
        set_foundry_bonus(current_foundry_bonus)
    end

    local current_gleam_bonus = get_gleam_bonus()
    if caste_bonuses[TYPE_GLEAM] ~= current_gleam_bonus then
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
    return entry[INHABITANTS] * get_effective_population_multiplier(entry[HAPPINESS])
end

function Inhabitants.get_power_usage(entry)
    local caste = castes[entry[TYPE]]
    return caste.power_demand * entry[INHABITANTS]
end
local get_power_usage = Inhabitants.get_power_usage

--- Changes the type of the entry to the given caste if it makes sense. Returns true if it did so.
--- @param entry Entry
--- @param caste_id integer
--- @param loud boolean
function Inhabitants.try_allow_for_caste(entry, caste_id, loud)
    if
        entry[TYPE] == TYPE_EMPTY_HOUSE and Housing.allowes_caste(get_housing(entry), caste_id) and
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

    local caste_id = entry[TYPE]
    local inhabitants = entry[INHABITANTS]

    effective_population[caste_id] =
        effective_population[caste_id] - inhabitants * get_effective_population_multiplier(entry[HAPPINESS])

    happiness = happiness or DEFAULT_HAPPINESS
    health = health or DEFAULT_HEALTH
    sanity = sanity or DEFAULT_SANITY

    entry[HAPPINESS] = weighted_average(entry[HAPPINESS], inhabitants, happiness, count_moving_in)
    entry[HEALTH] = weighted_average(entry[HEALTH], inhabitants, health, count_moving_in)
    entry[SANITY] = weighted_average(entry[SANITY], inhabitants, sanity, count_moving_in)
    entry[INHABITANTS] = inhabitants + count_moving_in

    population[caste_id] = population[caste_id] + count_moving_in
    effective_population[caste_id] =
        effective_population[caste_id] +
        (inhabitants + count_moving_in) * get_effective_population_multiplier(entry[HAPPINESS])

    set_power_usage(entry, get_power_usage(entry))

    if get_free_capacity(entry) == 0 then
        local unit_number = entry[ENTITY].unit_number
        houses_with_free_capacity[caste_id][unit_number] = nil
    end

    return count_moving_in
end
local try_add_to_house = Inhabitants.try_add_to_house

local function get_next_free_house(caste_id)

end

function Inhabitants.distribute_inhabitants(caste_id, count, happiness, health, sanity)
    local to_distribute = count
    local next_house = get_next_free_house(caste_id)

    while to_distribute > 0 and next_house do


        next_house = get_next_free_house(caste_id)
    end
end

function Inhabitants.clone_inhabitants(source, destination)
    try_add_to_house(destination, source[INHABITANTS], source[HAPPINESS], source[HEALTH], source[SANITY])
end

--- Tries to remove the specified amount of inhabitants from the house-entry.
--- Returns the number of inhabitants that were removed.
--- @param entry Entry
--- @param count integer
function Inhabitants.remove_from_house(entry, count)
    local count_moving_out = min(entry[INHABITANTS], count)

    if count_moving_out == 0 then
        return 0
    end

    local caste_id = entry[TYPE]

    effective_population[caste_id] =
        effective_population[caste_id] - count_moving_out * get_effective_population_multiplier(entry[HAPPINESS])
    population[caste_id] = population[caste_id] - count_moving_out
    entry[INHABITANTS] = entry[INHABITANTS] - count_moving_out

    set_power_usage(entry, get_power_usage(entry))

    if get_free_capacity(entry) > 0 then
        local unit_number = entry[ENTITY].unit_number
        houses_with_free_capacity[caste_id][unit_number] = unit_number
    end

    return count_moving_out
end
local remove_from_house = Inhabitants.remove_from_house

--- Removes all the inhabitants living in the house.
--- @param entry Entry
function Inhabitants.remove_house(entry)
    remove_from_house(entry, entry[INHABITANTS])
end

--- Gets the trend toward the next inhabitant that moves in or out.
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

--- Updates the given housing entry.
--- @param entry Entry
--- @param delta_ticks integer
function Inhabitants.update_house(entry, delta_ticks)
    local caste_id = entry[TYPE]
    local caste_values = castes[caste_id]

    local old_happiness = entry[HAPPINESS]
    local happiness_summands = entry[HAPPINESS_SUMMANDS]
    local happiness_factors = entry[HAPPINESS_FACTORS]

    local health_summands = entry[HEALTH_SUMMANDS]
    local health_factors = entry[HEALTH_FACTORS]

    local sanity_summands = entry[SANITY_SUMMANDS]
    local sanity_factors = entry[SANITY_FACTORS]

    local inhabitants = entry[INHABITANTS]

    -- collect all the influences
    evaluate_diet(entry, delta_ticks)
    evaluate_housing(entry, happiness_summands, sanity_summands)
    evaluate_water(entry, delta_ticks, happiness_factors, health_factors, sanity_factors)

    if has_power(entry) then
        happiness_summands[HAPPINESS_POWER] = caste_values.power_bonus
        happiness_summands[HAPPINESS_NO_POWER] = 0
    else
        happiness_summands[HAPPINESS_POWER] = 0
        happiness_summands[HAPPINESS_NO_POWER] = caste_values.no_power_malus
    end

    happiness_summands[HAPPINESS_EMBER] = caste_bonuses[TYPE_EMBER]

    local fear_malus = global.fear * caste_values.fear_multiplier
    happiness_summands[HAPPINESS_FEAR] = fear_malus
    if fear_malus > 5 then
        health_summands[HEALTH_FEAR] = fear_malus / 2
        sanity_summands[SANITY_FEAR] = fear_malus / 2
    else
        health_summands[HEALTH_FEAR] = 0
        sanity_summands[SANITY_FEAR] = 0
    end

    -- update health
    local nominal_health = get_nominal_value(health_summands, health_factors)
    local new_health = update_health(nominal_health, entry[HEALTH], delta_ticks)
    entry[HEALTH] = new_health

    happiness_factors[HAPPINESS_HEALTH] = (inhabitants > 0) and (new_health - 10) / 20. + 1 or 1

    -- update sanity
    local nominal_sanity = get_nominal_value(sanity_summands, sanity_factors)
    local new_sanity = update_sanity(nominal_sanity, entry[SANITY], delta_ticks)
    entry[SANITY] = new_sanity

    happiness_factors[HAPPINESS_SANITY] = (inhabitants > 0) and (new_sanity - 10) / 15. + 1 or 1

    -- update happiness
    local nominal_happiness = get_nominal_value(happiness_summands, happiness_factors)
    local new_happiness = update_happiness(nominal_happiness, entry[HAPPINESS], delta_ticks)
    entry[HAPPINESS] = new_happiness

    -- update effective population because the happiness has changed (most likely)
    effective_population[caste_id] =
        effective_population[caste_id] - (inhabitants * get_effective_population_multiplier(old_happiness)) +
        (inhabitants * get_effective_population_multiplier(new_happiness))
    -- TODO diseases

    -- check if the caste actually produces ideas
    if caste_values.idea_item then
        local ideas = entry[IDEAS] + get_idea_progress(new_happiness, inhabitants, caste_values, delta_ticks)
        if ideas >= 1 then
            local produced_ideas = floor(ideas)
            try_output_ideas(entry, caste_values.idea_item, produced_ideas)
            ideas = ideas - produced_ideas
        end
        entry[IDEAS] = ideas
    end

    local garbage = entry[GARBAGE] + get_garbage_progress(inhabitants, delta_ticks)
    if garbage >= 1 then
        local produced_garbage = floor(garbage)
        produce_garbage(entry, "garbage", produced_garbage)
        garbage = garbage - produced_garbage
    end
    entry[GARBAGE] = garbage

    local trend = entry[EMIGRATION_TREND]
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
    entry[EMIGRATION_TREND] = trend
end

function Inhabitants.get_nominal_happiness(entry)
    return get_nominal_value(entry[HAPPINESS_SUMMANDS], entry[HAPPINESS_FACTORS])
end

function Inhabitants.get_nominal_health(entry)
    return get_nominal_value(entry[HEALTH_SUMMANDS], entry[HEALTH_FACTORS])
end

function Inhabitants.get_nominal_sanity(entry)
    return get_nominal_value(entry[SANITY_SUMMANDS], entry[SANITY_FACTORS])
end

function Inhabitants.immigration(delta_ticks)
    for caste = 1, #immigration do
        if is_researched(caste) then
            local immigration_trend = immigration[caste]
            local pop = population[caste]

            if pop > 0 then
                local average_happiness = effective_population[caste] / population[caste]
                immigration_trend =
                    immigration_trend + castes[caste].immigration_coefficient * delta_ticks * average_happiness
            else
                immigration_trend = immigration_trend + castes[caste].immigration_coefficient * delta_ticks
            end

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

    local to_resettle = entry[INHABITANTS]
    for current_unit_number, current_entry in Register.all_of_type(entry[TYPE]) do
        if current_unit_number ~= unit_number then
            to_resettle =
                to_resettle -
                try_add_to_house(current_entry, to_resettle, entry[HAPPINESS], entry[HEALTH], entry[SANITY])

            if to_resettle == 0 then
                break
            end
        end
    end

    local resettled = entry[INHABITANTS] - to_resettle

    if resettled > 0 then
        Communication.people_resettled(entry, resettled)
    end

    return resettled
end
---------------------------------------------------------------------------------------------------
-- << fear >>
--- Lowers the population's fear over time.
function Inhabitants.ease_fear()
    local delta_ticks = game.tick - global.last_update

    -- TODO
end

--- Adds fear after a civil building got destroyed.
function Inhabitants.add_fear()
    global.last_fear_event = game.tick
    global.fear = global.fear + 1 -- TODO balancing
end

---------------------------------------------------------------------------------------------------
-- << general >>

--- Initializes the given entry so it can work as an housing entry.
--- @param entry Entry
function Inhabitants.establish_house(caste_id, entry, unit_number)
    entry[HAPPINESS] = 0
    entry[HAPPINESS_SUMMANDS] = Tirislib_Tables.new_array(Types.happiness_summands_count, 0.)
    entry[HAPPINESS_FACTORS] = Tirislib_Tables.new_array(Types.happiness_factors_count, 1.)

    entry[HEALTH] = 0
    entry[HEALTH_SUMMANDS] = Tirislib_Tables.new_array(Types.health_summands_count, 0.)
    entry[HEALTH_FACTORS] = Tirislib_Tables.new_array(Types.health_factors_count, 1.)

    entry[SANITY] = 0
    entry[SANITY_SUMMANDS] = Tirislib_Tables.new_array(Types.sanity_summands_count, 0.)
    entry[SANITY_FACTORS] = Tirislib_Tables.new_array(Types.sanity_factors_count, 1.)

    entry[INHABITANTS] = 0
    entry[EMIGRATION_TREND] = 0
    entry[IDEAS] = 0
    entry[GARBAGE] = 0

    local free_houses = houses_with_free_capacity[caste_id]
    free_houses[unit_number] = unit_number
end

local function new_caste_table()
    return {
        [TYPE_CLOCKWORK] = 0,
        [TYPE_ORCHID] = 0,
        [TYPE_GUNFIRE] = 0,
        [TYPE_EMBER] = 0,
        [TYPE_FOUNDRY] = 0,
        [TYPE_GLEAM] = 0,
        [TYPE_AURORA] = 0,
        [TYPE_PLASMA] = 0
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

    set_locals()
end

--- Sets local references during on_load
function Inhabitants.load()
    set_locals()
end

return Inhabitants
