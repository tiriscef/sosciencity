local EK = require("enums.entry-key")
local HappinessSummand = require("enums.happiness-summand")
local HappinessFactor = require("enums.happiness-factor")
local WarningType = require("enums.warning-type")

local Castes = require("constants.castes")
local Diseases = require("constants.diseases")
local Housing = require("constants.housing")
local Time = require("constants.time")

local castes = Castes.values
local disease_values = Diseases.values
local Utils = Tirislib.Utils
local Tables = Tirislib.Tables
local map_range = Utils.map_range
local set_power_usage = Subentities.set_power_usage
local HEALTHY = DiseaseGroup.HEALTHY
local floor = math.floor
local max = math.max

local evaluate_diet

-- cross-submodule references, set during load
local evaluate_housing
local evaluate_water
local evaluate_sosciety
local evaluate_neighborhood
local evaluate_social_environment
local update_diseases
local update_blood_donations
local update_free_space_status
local unemploy_inhabitants
local get_caste_bonus_multiplier

function Inhabitants.load_housing_update()
    evaluate_diet = Inhabitants.evaluate_diet
    evaluate_housing = Inhabitants.evaluate_housing
    evaluate_water = Inhabitants.evaluate_water
    evaluate_sosciety = Inhabitants.evaluate_sosciety
    evaluate_neighborhood = Inhabitants.evaluate_neighborhood
    evaluate_social_environment = Inhabitants.evaluate_social_environment
    update_diseases = Inhabitants.update_diseases
    update_blood_donations = Inhabitants.update_blood_donations
    update_free_space_status = Inhabitants.update_free_space_status
    unemploy_inhabitants = Inhabitants.unemploy_inhabitants
    get_caste_bonus_multiplier = Inhabitants.get_caste_bonus_multiplier
end

---------------------------------------------------------------------------------------------------
-- << convergence functions >>

--- Reduces the difference between nominal and current happiness by roughly 3% per second. (~98% after 2 minutes.)
--- @param group Entry
--- @param target number nominal happiness to converge toward
--- @param delta_ticks number ticks since last update
local function update_happiness(group, target, delta_ticks)
    local current = group[EK.happiness]
    group[EK.happiness] = current + (target - current) * (1 - 0.9995 ^ delta_ticks)
end
Inhabitants.update_happiness = update_happiness

--- Reduces the difference between nominal and current health. (~98% after 10 minutes.)
--- @param group Entry
--- @param target number nominal health to converge toward
--- @param delta_ticks number ticks since last update
local function update_health(group, target, delta_ticks)
    local current = group[EK.health]
    group[EK.health] = current + (target - current) * (1 - 0.9999 ^ delta_ticks)
end
Inhabitants.update_health = update_health

--- Reduces the difference between nominal and current sanity. (~98% after 20 minutes.)
--- @param group Entry
--- @param target number nominal sanity to converge toward
--- @param delta_ticks number ticks since last update
local function update_sanity(group, target, delta_ticks)
    local current = group[EK.sanity]
    group[EK.sanity] = current + (target - current) * (1 - 0.99995 ^ delta_ticks)
end
Inhabitants.update_sanity = update_sanity

---------------------------------------------------------------------------------------------------
-- << nominal value >>

--- Computes the nominal value from summands and multiplicative factors.
--- @param influences number[] array of additive summands
--- @param factors number[] array of multiplicative factors (1.0 = neutral)
--- @return number nominal value, clamped to >= 0
local function get_nominal_value(influences, factors)
    return max(0, Tables.sum(influences) * Tables.product(factors))
end
Inhabitants.get_nominal_value = get_nominal_value

--- Returns the nominal happiness for a housing entry based on its current summands and factors.
--- @param entry Entry
--- @return number
function Inhabitants.get_nominal_happiness(entry)
    return get_nominal_value(entry[EK.happiness_summands], entry[EK.happiness_factors])
end

--- Returns the nominal health for a housing entry based on its current summands and factors.
--- @param entry Entry
--- @return number
function Inhabitants.get_nominal_health(entry)
    return get_nominal_value(entry[EK.health_summands], entry[EK.health_factors])
end

--- Returns the nominal sanity for a housing entry based on its current summands and factors.
--- @param entry Entry
--- @return number
function Inhabitants.get_nominal_sanity(entry)
    return get_nominal_value(entry[EK.sanity_summands], entry[EK.sanity_factors])
end

---------------------------------------------------------------------------------------------------
-- << ages >>

--- Advances the age groups of the inhabitants based on elapsed in-game weeks.
--- @param entry Entry
local function update_ages(entry)
    local last_shift = entry[EK.last_age_shift]
    local shift = floor((game.tick - last_shift) / Time.nauvis_week)

    if shift > 0 then
        AgeGroup.shift(entry[EK.ages], shift)
        entry[EK.last_age_shift] = last_shift + shift * Time.nauvis_week
    end
end
Inhabitants.update_ages = update_ages

---------------------------------------------------------------------------------------------------
-- << strike >>

--- Computes and stores the current strike level for a housing entry, and fires workers who are no longer willing.
--- Strike level 0 means no strike, 1 means full strike.
--- @param entry Entry
--- @param happiness number current happiness
--- @param caste table caste definition from Castes.values
local function update_strike_level(entry, happiness, caste)
    local new_level
    if happiness >= caste.strike_begin_threshold then
        new_level = 0
    elseif happiness <= caste.full_strike_threshold then
        new_level = 1
    else
        new_level = map_range(happiness, caste.strike_begin_threshold, caste.full_strike_threshold, 0, 1)
    end
    entry[EK.strike_level] = new_level

    if new_level > 0 then
        Communication.warning(WarningType.on_strike, entry[EK.type])
        local willing = floor(entry[EK.diseases][HEALTHY] * (1 - new_level * (1 - caste.full_strike_worker_fraction)))
        local excess = entry[EK.employed] - willing
        if excess > 0 then
            unemploy_inhabitants(entry, excess)
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << garbage >>

--- Returns the garbage production progress for this tick, based on caste and inhabitant count.
--- @param entry Entry
--- @param delta_ticks integer
--- @return number progress increment
function Inhabitants.get_garbage_progress(entry, delta_ticks)
    return castes[entry[EK.type]].garbage_coefficient * entry[EK.inhabitants] * delta_ticks
end
local get_garbage_progress = Inhabitants.get_garbage_progress

--- Accumulates garbage progress and produces garbage items when it reaches whole numbers.
--- @param entry Entry
--- @param delta_ticks integer
local function update_garbage_output(entry, delta_ticks)
    local garbage = Utils.update_progress(entry, EK.garbage_progress, get_garbage_progress(entry, delta_ticks))
    if garbage > 0 then
        Inventories.produce_garbage(entry, "garbage", garbage)
    end
end
Inhabitants.update_garbage_output = update_garbage_output

---------------------------------------------------------------------------------------------------
-- << housing census >>

--- Syncs the population count and caste bonus points for a housing entry.
--- @param entry Entry
local function update_housing_census(entry)
    local caste_id = entry[EK.type]
    local inhabitants = entry[EK.inhabitants]
    local official_inhabitants = entry[EK.official_inhabitants]

    if inhabitants ~= official_inhabitants then
        storage.population[caste_id] = storage.population[caste_id] - official_inhabitants + inhabitants
        entry[EK.official_inhabitants] = inhabitants

        update_free_space_status(entry)

        set_power_usage(entry, InhabitantGroup.get_power_usage(entry))
    end

    local caste = castes[caste_id]
    local efficiency = 1 + 0.1 * storage.technologies[caste.efficiency_tech]
    local manpower = entry[EK.diseases][HEALTHY]
    for disease, count in pairs(entry[EK.diseases]) do
        if disease ~= HEALTHY then
            manpower = manpower + count * disease_values[disease].work_effectivity
        end
    end

    local points = manpower * get_caste_bonus_multiplier(entry[EK.happiness], entry[EK.strike_level], caste) * efficiency
    storage.caste_points[caste_id] = storage.caste_points[caste_id] - entry[EK.caste_points] + points
    entry[EK.caste_points] = points
end
Inhabitants.update_housing_census = update_housing_census

--- Removes a housing entry from the census (on house destruction).
--- @param entry Entry
local function remove_housing_census(entry)
    local caste_id = entry[EK.type]

    storage.population[caste_id] = storage.population[caste_id] - entry[EK.official_inhabitants]
    storage.caste_points[caste_id] = storage.caste_points[caste_id] - entry[EK.caste_points]
end
Inhabitants.remove_housing_census = remove_housing_census

--- Sets the entity's custom status display (diode color and inhabitant info).
--- @param entry Entry
local function set_custom_status(entry)
    local inhabitants = entry[EK.inhabitants]
    local capacity = Housing.get_capacity(entry)
    local strike_level = entry[EK.strike_level]

    local diode, locale_key
    if inhabitants == 0 then
        diode = defines.entity_status_diode.red
        locale_key = "sosciencity-custom-status.empty-house"
    elseif inhabitants == capacity then
        diode = defines.entity_status_diode.green
        locale_key = "sosciencity-custom-status.full-house"
    else
        diode = defines.entity_status_diode.yellow
        locale_key = "sosciencity-custom-status.inhabited-house"
    end

    local label = {
        locale_key,
        inhabitants,
        capacity,
        Utils.round_to_step(entry[EK.happiness], 0.1),
        Utils.round_to_step(entry[EK.health], 0.1),
        Utils.round_to_step(entry[EK.sanity], 0.1)
    }

    if strike_level >= 1 then
        Tirislib.Locales.append(label, {"sosciencity-custom-status.on-full-strike"})
    elseif strike_level > 0 then
        Tirislib.Locales.append(label, {"sosciencity-custom-status.on-strike", floor(strike_level * 100)})
    end

    entry[EK.entity].custom_status = {
        diode = diode,
        label = label
    }
end
Inhabitants.set_custom_status = set_custom_status

---------------------------------------------------------------------------------------------------
-- << housing update orchestrator >>

--- Updates the given housing entry.
--- @param entry Entry
--- @param delta_ticks integer
local function update_house(entry, delta_ticks)
    local caste_id = entry[EK.type]
    local caste = castes[caste_id]

    local happiness_summands = {}
    local happiness_factors = {}
    local health_summands = {}
    local health_factors = {}
    local sanity_summands = {}
    local sanity_factors = {}

    entry[EK.happiness_summands] = happiness_summands
    entry[EK.happiness_factors] = happiness_factors
    entry[EK.health_summands] = health_summands
    entry[EK.health_factors] = health_factors
    entry[EK.sanity_summands] = sanity_summands
    entry[EK.sanity_factors] = sanity_factors

    local inhabitants = entry[EK.inhabitants]

    -- collect all the influences
    evaluate_diet(entry, delta_ticks)
    evaluate_housing(entry, happiness_summands, sanity_summands, caste)
    evaluate_water(entry, delta_ticks, happiness_factors, health_factors, health_summands)
    evaluate_sosciety(happiness_summands, health_summands, sanity_summands, caste)
    evaluate_neighborhood(entry, happiness_summands, health_summands)
    evaluate_social_environment(entry, sanity_summands, delta_ticks)

    -- update health
    local nominal_health = get_nominal_value(health_summands, health_factors)
    update_health(entry, nominal_health, delta_ticks)

    local new_health = entry[EK.health]
    if inhabitants > 0 then
        if new_health > 10 then
            happiness_summands[HappinessSummand.health] = (new_health - 10) ^ 0.5
        elseif new_health < 10 then
            happiness_factors[HappinessFactor.bad_health] = map_range(new_health, 0, 10, 0, 1) ^ 0.5
        end
    end

    -- update sanity
    local nominal_sanity = get_nominal_value(sanity_summands, sanity_factors)
    update_sanity(entry, nominal_sanity, delta_ticks)

    local new_sanity = entry[EK.sanity]
    if inhabitants > 0 then
        if new_sanity > 10 then
            happiness_summands[HappinessSummand.sanity] = (new_sanity - 10) ^ 0.5
        elseif new_sanity < 10 then
            happiness_factors[HappinessFactor.bad_sanity] = map_range(new_sanity, 0, 10, 0, 1) ^ 0.5
        end
    end

    -- update happiness
    local nominal_happiness = get_nominal_value(happiness_summands, happiness_factors)
    update_happiness(entry, nominal_happiness, delta_ticks)

    update_ages(entry)
    update_strike_level(entry, entry[EK.happiness], caste)
    update_housing_census(entry)
    update_garbage_output(entry, delta_ticks)
    update_diseases(entry, delta_ticks)
    update_blood_donations(entry, delta_ticks)

    set_custom_status(entry)
end
Inhabitants.update_house = update_house
