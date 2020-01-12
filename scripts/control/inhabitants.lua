Inhabitants = {}

-- local often used functions for enormous performance gains
local global
local population
local effective_population
local Register = Register

local castes = Caste.values
local evaluate_diet = Diet.evaluate

local get_housing = Housing.get
local evaluate_housing = Housing.evaluate
local get_free_capacity = Housing.get_free_capacity
local set_power_usage = Subentities.set_power_usage
local has_power = Subentities.has_power

local floor = math.floor
local ceil = math.ceil
local sqrt = math.sqrt
local max = Tirislib_Utils.max
local min = Tirislib_Utils.min
local sgn = Tirislib_Utils.sgn
local sum = Tirislib_Tables.sum
local weighted_average = Tirislib_Utils.weighted_average

local caste_tech_names = {
    [TYPE_CLOCKWORK] = "clockwork-caste",
    [TYPE_EMBER] = "ember-caste",
    [TYPE_GUNFIRE] = "gunfire-caste",
    [TYPE_GLEAM] = "gleam-caste",
    [TYPE_FOUNDRY] = "foundry-caste",
    [TYPE_ORCHID] = "orchid-caste",
    [TYPE_AURORA] = "aurora-caste"
}

---------------------------------------------------------------------------------------------------
-- << caste bonus functions >>
--- Returns the total number of inhabitants.
function Inhabitants.get_population_count()
    local population_count = 0

    for caste_id, _ in pairs(castes) do
        population_count = population_count + population[caste_id]
    end

    return population_count
end
local get_population_count = Inhabitants.get_population_count

--- Gets the current Clockwork caste bonus.
function Inhabitants.get_clockwork_bonus()
    return floor(effective_population[TYPE_CLOCKWORK] * 40 / max(global.machine_count, 1))
end

--- Gets the current Orchid caste bonus.
function Inhabitants.get_orchid_bonus()
    return floor(sqrt(effective_population[TYPE_ORCHID]))
end

--- Gets the current Gunfire caste bonus.
function Inhabitants.get_gunfire_bonus()
    return floor(effective_population[TYPE_GUNFIRE] * 10 / max(global.turret_count, 1)) -- TODO balancing
end
local get_gunfire_bonus = Inhabitants.get_gunfire_bonus

--- Gets the current Ember caste bonus.
function Inhabitants.get_ember_bonus()
    return floor(sqrt(effective_population[TYPE_EMBER] / get_population_count()))
end
local get_ember_bonus = Inhabitants.get_ember_bonus

--- Gets the current Foundry caste bonus.
function Inhabitants.get_foundry_bonus()
    return floor(effective_population[TYPE_FOUNDRY] * 5)
end
local get_foundry_bonus = Inhabitants.get_foundry_bonus

--- Gets the current Gleam caste bonus.
function Inhabitants.get_gleam_bonus()
    return floor(sqrt(effective_population[TYPE_GLEAM]))
end
local get_gleam_bonus = Inhabitants.get_gleam_bonus

--- Gets the current Aurora caste bonus.
function Inhabitants.get_aurora_bonus()
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
    global.gunfire_bonus = value
end

-- Assumes value is an integer
local function set_gleam_bonus(value)
    set_binary_techs(value, "-gleam-caste")
    global.gleam_bonus = value
end

-- Assumes value is an integer
local function set_foundry_bonus(value)
    set_binary_techs(value, "-foundry-caste")
    global.foundry_bonus = value
end

--- Updates the caste bonuses that are applied global instead of per-entity. At the moment these are Gunfire, Gleam and Foundry.
function Inhabitants.update_caste_bonuses()
    -- We check if the bonuses have actually changed to avoid unnecessary api calls
    local current_gunfire_bonus = get_gunfire_bonus()
    if global.gunfire_bonus ~= current_gunfire_bonus then
        set_gunfire_bonus(current_gunfire_bonus)
    end

    local current_gleam_bonus = get_gleam_bonus()
    if global.gleam_bonus ~= current_gleam_bonus then
        set_gleam_bonus(current_gleam_bonus)
    end

    local current_foundry_bonus = get_foundry_bonus()
    if global.foundry_bonus ~= current_foundry_bonus then
        set_foundry_bonus(current_foundry_bonus)
    end
end

local bonus_function_lookup = {
    [TYPE_CLOCKWORK] = Inhabitants.get_clockwork_bonus,
    [TYPE_ORCHID] = Inhabitants.get_orchid_bonus,
    [TYPE_GUNFIRE] = Inhabitants.get_gunfire_bonus,
    [TYPE_EMBER] = Inhabitants.get_ember_bonus,
    [TYPE_FOUNDRY] = Inhabitants.get_foundry_bonus,
    [TYPE_GLEAM] = Inhabitants.get_gleam_bonus,
    [TYPE_AURORA] = Inhabitants.get_aurora_bonus
}

--- Gets the current bonus of the given caste.
--- @param caste Type
function Inhabitants.get_caste_bonus(caste)
    return bonus_function_lookup[caste]()
end

---------------------------------------------------------------------------------------------------
-- << inhabitant functions >>
local function get_effective_population_multiplier(happiness)
    return max(0.2, happiness * 0.1)
end

--- Changes the type of the entry to the given caste if it makes sense. Returns true if it did so.
--- @param entry Entry
--- @param caste_id integer
--- @param loud boolean
function Inhabitants.try_allow_for_caste(entry, caste_id, loud)
    if
        entry[TYPE] == TYPE_EMPTY_HOUSE and Housing.allowes_caste(get_housing(entry), caste_id) and
            Inhabitants.caste_is_researched(caste_id)
     then
        Register.change_type(entry, caste_id)

        if loud then
            Communication.create_flying_text(
                entry,
                {
                    "flying-text.set-caste",
                    "[img=technology/" .. caste_tech_names[caste_id] .. "]",
                    {"caste-name." .. castes[caste_id].name}
                }
            )
        end
        return true
    else
        return false
    end
end

local DEFAULT_HAPPINESS = 10
local DEFAULT_HEALTH = 10
local DEFAULT_MENTAL_HEALTH = 10

--- Tries to add the specified amount of inhabitants to the house-entry.
--- Returns the number of inhabitants that were added.
--- @param entry Entry
--- @param count integer
--- @param happiness number
--- @param health number
--- @param mental_health number
function Inhabitants.try_add_to_house(entry, count, happiness, health, mental_health)
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
    mental_health = mental_health or DEFAULT_MENTAL_HEALTH

    entry[HAPPINESS] = weighted_average(entry[HAPPINESS], inhabitants, happiness, count_moving_in)
    entry[HEALTH] = weighted_average(entry[HEALTH], inhabitants, health, count_moving_in)
    entry[MENTAL_HEALTH] = weighted_average(entry[MENTAL_HEALTH], inhabitants, mental_health, count_moving_in)
    entry[INHABITANTS] = inhabitants + count_moving_in

    population[caste_id] = population[caste_id] + count_moving_in
    effective_population[caste_id] =
        effective_population[caste_id] +
        (inhabitants + count_moving_in) * get_effective_population_multiplier(entry[HAPPINESS])

    set_power_usage(entry)

    return count_moving_in
end
local try_add_to_house = Inhabitants.try_add_to_house

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

    set_power_usage(entry)

    return count_moving_out
end
local remove_from_house = Inhabitants.remove_from_house

--- Removes all the inhabitants living in the house.
--- @param entry Entry
function Inhabitants.remove_house(entry)
    remove_from_house(entry, entry[INHABITANTS])
end

--- Gets the trend toward the next inhabitant that moves in or out.
function Inhabitants.get_trend(nominal_happiness, caste, delta_ticks)
    return caste.influx_coefficient * delta_ticks * (sgn(nominal_happiness) + nominal_happiness - caste.influx_threshold)
end
local get_trend = Inhabitants.get_trend

--- Reduce the difference between nominal and current happiness by roughly 3% per second. (~98% after 2 minutes.)
local function update_happiness(target, current, delta_ticks)
    return current + (target - current) * (1 - 0.9995 ^ delta_ticks)
end

--- Reduce the difference between nominal and current health. (~98% after 10 minutes.)
local function update_health(target, current, delta_ticks)
    return current + (target - current) * (1 - 0.9999 ^ delta_ticks)
end

--- Reduce the difference between nominal and current mental health. (~98% after 20 minutes.)
local function update_mental_health(target, current, delta_ticks)
    return current + (target - current) * (1 - 0.99995 ^ delta_ticks)
end

--- Updates the given housing entry.
--- @param entry Entry
--- @param delta_ticks integer
function Inhabitants.update_house(entry, delta_ticks)
    local caste_id = entry[TYPE]
    local caste_values = castes[caste_id]

    local happiness_factors = {}
    entry[HAPPINESS_FACTORS] = happiness_factors
    local health_factors = {}
    entry[HEALTH_FACTORS] = health_factors
    local mental_health_factors = {}
    entry[MENTAL_HEALTH_FACTORS] = mental_health_factors

    evaluate_diet(entry, delta_ticks)
    evaluate_housing(entry)

    if has_power(entry) then
        happiness_factors[HAPPINESS_POWER] = caste_values.power_bonus
    else
        happiness_factors[HAPPINESS_NO_POWER] = caste_values.no_power_malus
    end

    local ember_bonus = get_ember_bonus()
    if ember_bonus > 0 then
        happiness_factors[HAPPINESS_EMBER] = ember_bonus
    end

    local fear_malus = global.fear * caste_values.fear_multiplier
    if fear_malus > 0 then
        happiness_factors[HAPPINESS_FEAR] = fear_malus

        if fear_malus > 5 then
            health_factors[HEALTH_FEAR] = fear_malus / 2
            mental_health_factors[MENTAL_HEALTH_FEAR] = fear_malus / 2
        end
    end

    -- update happiness
    local nominal_happiness = sum(happiness_factors)
    local old_happiness = entry[HAPPINESS]
    local new_happiness = update_happiness(nominal_happiness, entry[HAPPINESS], delta_ticks)
    entry[HAPPINESS] = new_happiness

    -- update effective population because the happiness has changed (most likely)
    local inhabitants = entry[INHABITANTS]
    effective_population[caste_id] =
        effective_population[caste_id] - (inhabitants * get_effective_population_multiplier(old_happiness)) +
        (inhabitants * get_effective_population_multiplier(new_happiness))

    -- update health
    local nominal_health = sum(health_factors)
    entry[HEALTH] = update_health(nominal_health, entry[HEALTH], delta_ticks)

    -- update mental health
    local nominal_mental_health = sum(mental_health_factors)
    entry[MENTAL_HEALTH] = update_mental_health(nominal_mental_health, entry[MENTAL_HEALTH], delta_ticks)
    -- TODO diseases, ideas, tralala

    local trend = entry[TREND]
    trend = trend + get_trend(nominal_happiness, caste_values, delta_ticks)
    if trend >= 1 then
        -- let people move in
        try_add_to_house(entry, floor(trend))
        trend = trend - floor(trend)
    elseif trend <= -1 then
        -- let people move out
        remove_from_house(entry, -ceil(trend))
        trend = trend - ceil(trend)
    end
    entry[TREND] = trend
end

function Inhabitants.get_nominal_happiness(entry)
    return sum(entry[HAPPINESS_FACTORS])
end

function Inhabitants.get_nominal_health(entry)
    return sum(entry[HEALTH_FACTORS])
end

function Inhabitants.get_nominal_mental_health(entry)
    return sum(entry[MENTAL_HEALTH_FACTORS])
end

---------------------------------------------------------------------------------------------------
-- << resettlement >>
--- Looks for housings to move the inhabitants of this entry to.
--- Returns the number of resettled inhabitants.
--- @param entry Entry
function Inhabitants.try_resettle(entry)
    if not global.technologies["resettlement"] or not Types.is_inhabited(entry[TYPE]) then
        return 0
    end

    local to_resettle = entry[INHABITANTS]
    for _, current_entry in Register.all_of_type(entry[TYPE]) do
        local resettled_count =
            try_add_to_house(current_entry, to_resettle, entry[HAPPINESS], entry[HEALTH], entry[MENTAL_HEALTH])
        to_resettle = to_resettle - resettled_count

        if to_resettle == 0 then
            break
        end
    end

    return entry[INHABITANTS] - to_resettle
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

--- Checks if the given caste has been researched by the player.
--- @param caste_id Type
function Inhabitants.caste_is_researched(caste_id)
    return global.technologies[caste_tech_names[caste_id]]
end

--- Initializes the given entry so it can work as an housing entry.
--- @param entry Entry
function Inhabitants.add_inhabitants_data(entry)
    entry[HAPPINESS] = 0
    entry[HAPPINESS_FACTORS] = {}

    entry[HEALTH] = 0
    entry[HEALTH_FACTORS] = {}

    entry[MENTAL_HEALTH] = 0
    entry[MENTAL_HEALTH_FACTORS] = {}

    entry[INHABITANTS] = 0
    entry[TREND] = 0
    entry[IDEAS] = 0
end

local function set_locals()
    global = _ENV.global
    population = global.population
    effective_population = global.effective_population
end

local function new_caste_table()
    return {
        [TYPE_CLOCKWORK] = 0,
        [TYPE_EMBER] = 0,
        [TYPE_GUNFIRE] = 0,
        [TYPE_GLEAM] = 0,
        [TYPE_FOUNDRY] = 0,
        [TYPE_ORCHID] = 0,
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

    set_locals()
end

--- Sets local references during on_load
function Inhabitants.load()
    set_locals()
end

return Inhabitants
