local DeathCause = require("enums.death-cause")
local DeconstructionCause = require("enums.deconstruction-cause")
local DiseaseCategory = require("enums.disease-category")
local DiseasedCause = require("enums.diseased-cause")
local EK = require("enums.entry-key")
local EmigrationCause = require("enums.emigration-cause")
local Gender = require("enums.gender")
local RenderingType = require("enums.rendering-type")
local Type = require("enums.type")
local WarningType = require("enums.warning-type")

local HappinessSummand = require("enums.happiness-summand")
local HappinessFactor = require("enums.happiness-factor")
local HealthSummand = require("enums.health-summand")
local HealthFactor = require("enums.health-factor")
local SanitySummand = require("enums.sanity-summand")
local SanityFactor = require("enums.sanity-factor")

local Biology = require("constants.biology")
local Buildings = require("constants.buildings")
local Castes = require("constants.castes")
local Diseases = require("constants.diseases")
local Housing = require("constants.housing")
local Time = require("constants.time")
local TypeGroup = require("constants.type-groups")

--- Static class that handles the behaviour of the people.
Inhabitants = {}

--[[
    Data this class stores in global
    --------------------------------
    global.population: table
        [caste_id]: int (inhabitants count)

    global.housing_capacity: table
        [caste_id]: table
            [bool (improvised)]: integer (capacity of all houses)

    global.caste_points: table
        [caste_id]: float (total caste bonus points)

    global.caste_bonuses: table
        [Type.clockwork]: integer (machine speed bonus in %)
        [Type.orchid]: integer (farm productivity bonus in %)
        [Type.gunfire]: integer (turret damage bonus in %)
        [Type.ember]: float (happiness bonus)
        [Type.plasma]: float (health bonus)
        [Type.foundry]: integer (mining productivity bonus in %)
        [Type.gleam]: integer (laboratory productivity bonus in %)
        [Type.aurora]: integer (rocket silo productivity bonus in %)

    global.immigration: table
        [caste_id]: float (number of immigrants in the next wave)

    global.free_houses: table
        [bool (improvised)]: table
            [caste_id]: table
                [unit_number]: truthy (lookup)

    global.next_houses: table
        [bool (improvised)]: table
            [caste_id]: shuffled array of unit_numbers

    global.fear: float (fear level)

    global.last_fear_event: tick

    global.homeless: table
        [caste_id]: InhabitantGroup

    global.last_social_change: tick

    global.starting_clockwork_points: number
]]
-- local often used globals for enormous performance gains

local global
local population
local caste_points
local caste_bonuses
local immigration
local homeless
local free_houses
local next_free_houses
local technologies

local Register = Register
local try_get = Register.try_get

local get_building_details = Buildings.get

local castes = Castes.values

local evaluate_diet = Inventories.evaluate_diet
local evaluate_water = Inventories.evaluate_water

local disease_values = Diseases.values

local produce_garbage = Inventories.produce_garbage
local get_garbage_value = Inventories.get_garbage_value

local get_housing_details = Housing.get
local get_free_capacity = Housing.get_free_capacity
local get_capacity = Housing.get_capacity

local set_power_usage = Subentities.set_power_usage
local has_power = Subentities.has_power
local add_common_sprite = Subentities.add_common_sprite
local remove_common_sprite = Subentities.remove_common_sprite

local set_binary_techs = Technologies.set_binary_techs

local Table = Tirislib.Tables
local Utils = Tirislib.Utils

local floor = math.floor
local floor_to_step = Utils.floor_to_step
local ceil = math.ceil
local round = Utils.round
local max = math.max
local min = math.min
local map_range = Utils.map_range
local array_sum = Table.array_sum
local array_product = Table.array_product
local coin_flips = Utils.coin_flips
local dice_rolls = Utils.dice_rolls
local occurence_probability = Utils.occurence_probability
local shuffle = Table.shuffle
local weighted_average = Utils.weighted_average
local random = math.random
local update_progress = Utils.update_progress

local table_copy = Table.copy
local table_multiply = Table.multiply

local Luaq_from = Tirislib.Luaq.from

---------------------------------------------------------------------------------------------------
-- << lua state lifecycle stuff >>

local function set_locals()
    global = _ENV.global
    population = global.population
    caste_points = global.caste_points
    caste_bonuses = global.caste_bonuses
    immigration = global.immigration
    homeless = global.homeless
    free_houses = global.free_houses
    next_free_houses = global.next_free_houses
    technologies = global.technologies
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
    global.housing_capacity = {}
    global.caste_points = new_caste_table()
    global.caste_bonuses = new_caste_table()
    global.immigration = new_caste_table()
    global.free_houses = {
        [true] = Table.new_array_of_arrays(#TypeGroup.all_castes),
        [false] = Table.new_array_of_arrays(#TypeGroup.all_castes)
    }
    global.next_free_houses = {
        [true] = Table.new_array_of_arrays(#TypeGroup.all_castes),
        [false] = Table.new_array_of_arrays(#TypeGroup.all_castes)
    }
    global.homeless = {}

    set_locals()

    for _, caste_id in pairs(TypeGroup.all_castes) do
        global.housing_capacity[caste_id] = {[true] = 0, [false] = 0}
        homeless[caste_id] = InhabitantGroup.new(caste_id)
    end

    global.last_social_change = game.tick
end

--- Sets local references during on_load
function Inhabitants.load()
    set_locals()
end

---------------------------------------------------------------------------------------------------
-- << inhabitant diseases >>

--- Object class for holding the diseases of a group of inhabitants.
DiseaseGroup = {}

DiseaseGroup.HEALTHY = 0
local HEALTHY = DiseaseGroup.HEALTHY

--- Returns a new DiseaseGroup with the given count of healthy people.
--- @param count integer
function DiseaseGroup.new(count)
    return {[HEALTHY] = count}
end
local new_disease_group = DiseaseGroup.new

local function empty_disease_group(group)
    Table.empty(group)
    group[HEALTHY] = 0
end

--- Merges the right hand group into the left hand group. If keep_rh is falsy, then the right hand disease group object gets emptied.
--- @param lh DiseaseGroup
--- @param rh DiseaseGroup
--- @param keep_rh boolean
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
--- @param total_count integer|nil
function DiseaseGroup.take(group, to_take, total_count)
    total_count = total_count or Table.sum(group)
    to_take = min(to_take, total_count)

    local ret = new_disease_group(0)

    while to_take > 0 do
        for disease, current_count in pairs(group) do
            local percentage_to_take = to_take / total_count
            local current_take = min(current_count, to_take, ceil(percentage_to_take * current_count))

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
    end

    return ret
end

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

local frequency_keys = {}
for _, disease_category in pairs(DiseaseCategory) do
    frequency_keys[disease_category] = "frequency" .. disease_category
end

--- Tries to make the given number of people sick with random diseases of the given category.
--- @param group DiseaseGroup
--- @param disease_category DiseaseCategory
--- @param count integer
--- @param actual_count integer|nil
--- @param suppress_logging boolean|nil
function DiseaseGroup.make_sick_randomly(group, disease_category, count, actual_count, suppress_logging)
    actual_count = min(count, actual_count or 20)

    local count_per_pick = 1
    local modulo = 0
    if count > actual_count then
        count_per_pick = floor(count / actual_count)
        modulo = count % actual_count
    end

    for i = 1, actual_count do
        local disease_id =
            Table.pick_random_subtable_weighted_by_key(
            Diseases.by_category[disease_category],
            frequency_keys[disease_category],
            Diseases.frequency_sums[disease_category]
        )
        local sickened = make_sick(group, disease_id, count_per_pick + (i <= modulo and 1 or 0))

        if not suppress_logging and sickened > 0 then
            Communication.report_diseased(disease_id, sickened, Diseases.disease_causes[disease_category])
        end
    end
end
local make_sick_randomly = DiseaseGroup.make_sick_randomly

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
local cure = DiseaseGroup.cure

--- Checks if the given id corresponds to a disease.
--- @param id DiseaseID
function DiseaseGroup.not_healthy(id)
    return id ~= HEALTHY
end
local not_healthy = DiseaseGroup.not_healthy

---------------------------------------------------------------------------------------------------
-- << inhabitant ages >>

AgeGroup = {}

--- Returns a new AgeGroup table with fixed ages.
--- @param count integer
--- @param age integer|nil
function AgeGroup.new(count, age)
    local ret = {}

    if count > 0 then
        ret[age or 0] = count
    end

    return ret
end

local function get_immigrant_age()
    local r1 = random() ^ 2
    local r2 = (random() < 0.5) and 1 or -1

    return round(50 + r1 * r2 * 30)
end

--- Returns a new AgeGroup table with random ages.
--- @param count integer
--- @param age_function function
function AgeGroup.random_new(count, age_function)
    local ret = {}

    if count > 0 then
        local rolls = min(count, 10)
        local count_per_roll = floor(count / rolls)
        local modulo = count % rolls

        for i = 1, rolls do
            local rolled = age_function()
            ret[rolled] = (ret[rolled] or 0) + count_per_roll + (i <= modulo and 1 or 0)
        end
    end

    return ret
end

function AgeGroup.merge(lh, rh, keep_rh)
    for age, count in pairs(rh) do
        lh[age] = (lh[age] or 0) + count
    end

    if not keep_rh then
        Table.empty(rh)
    end
end

function AgeGroup.take(group, to_take, total_count)
    total_count = total_count or Table.sum(group)
    to_take = min(to_take, total_count)

    local ret = {}

    while to_take > 0 do
        for age, current_count in pairs(group) do
            local percentage_to_take = to_take / total_count
            local current_take = min(current_count, to_take, ceil(percentage_to_take * current_count))

            total_count = total_count - current_take
            to_take = to_take - current_take

            ret[age] = (ret[age] or 0) + current_take
            group[age] = (current_count ~= current_take) and current_count - current_take or nil

            if to_take == 0 then
                return ret
            end
        end
    end

    return ret
end

function AgeGroup.subtract(lh, rh)
    for age, count in pairs(rh) do
        local new_count = lh[age] - count

        if new_count < 0 then
            error("Sosciencity tried to subtract two incompatible AgeGroup objects.")
        end

        lh[age] = (new_count > 0) and new_count or nil
    end
end

function AgeGroup.shift(group, time)
    local copy = Table.copy(group)
    Table.empty(group)

    for age, count in pairs(copy) do
        group[age + time] = count
    end
end

---------------------------------------------------------------------------------------------------
-- << inhabitant genders >>

GenderGroup = {}

function GenderGroup.new(agender, fale, pachin, ga)
    return {agender or 0, fale or 0, pachin or 0, ga or 0}
end

function GenderGroup.new_immigrants(count, caste)
    return dice_rolls(castes[caste].immigration_genders, count, 20)
end

function GenderGroup.merge(lh, rh, keep_rh)
    for gender, count in pairs(rh) do
        lh[gender] = lh[gender] + count

        if not keep_rh then
            rh[gender] = 0
        end
    end
end

function GenderGroup.take(group, to_take, total_count)
    total_count = total_count or Table.sum(group)
    to_take = min(to_take, total_count)

    local ret = GenderGroup.new()

    while to_take > 0 do
        for gender = 1, #group do
            local current_count = group[gender]
            local percentage_to_take = to_take / total_count
            local current_take = min(current_count, to_take, ceil(percentage_to_take * current_count))

            ret[gender] = ret[gender] + current_take
            group[gender] = group[gender] - current_take

            total_count = total_count - current_take
            to_take = to_take - current_take

            if to_take == 0 then
                return ret
            end
        end
    end

    return ret
end

function GenderGroup.subtract(lh, rh)
    for gender, count in pairs(rh) do
        lh[gender] = lh[gender] - count
        if lh[gender] < 0 then
            error("Sosciencity tried to subtract two incompatible GenderGroup objects.")
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << inhabitant groups >>

--- Object class for holding groups of inhabitants.
InhabitantGroup = {}

local DEFAULT_HAPPINESS = 10
local DEFAULT_HEALTH = 10
local DEFAULT_SANITY = 10

--- Constructs a new InhabitantGroup object.
--- @param caste Type
--- @param count integer|nil
--- @param happiness number|nil
--- @param health number|nil
--- @param sanity number|nil
--- @param diseases DiseaseGroup|nil
--- @param genders GenderGroup|nil
--- @param ages AgeGroup|nil
--- @return InhabitantGroup
function InhabitantGroup.new(caste, count, happiness, health, sanity, diseases, genders, ages)
    count = count or 0

    return {
        [EK.type] = caste,
        [EK.inhabitants] = count,
        [EK.happiness] = happiness or DEFAULT_HAPPINESS,
        [EK.health] = health or DEFAULT_HEALTH,
        [EK.sanity] = sanity or DEFAULT_SANITY,
        [EK.diseases] = diseases or new_disease_group(count),
        [EK.genders] = genders or GenderGroup.new_immigrants(count, caste),
        [EK.ages] = ages or AgeGroup.new(count)
    }
end
local new_group = InhabitantGroup.new

--- Returns a new InhabitantGroup object filled with immigrants.
--- @param caste Type
--- @param count integer
--- @return InhabitantGroup
function InhabitantGroup.new_immigrant_group(caste, count)
    count = count or 0

    return {
        [EK.type] = caste,
        [EK.inhabitants] = count,
        [EK.happiness] = DEFAULT_HAPPINESS,
        [EK.health] = DEFAULT_HEALTH,
        [EK.sanity] = DEFAULT_SANITY,
        [EK.diseases] = new_disease_group(count),
        [EK.genders] = GenderGroup.new_immigrants(count, caste),
        [EK.ages] = AgeGroup.random_new(count, get_immigrant_age)
    }
end

--- Throws all inhabitants of the given InhabitantGroup in a shredder.
--- @param group InhabitantGroup
function InhabitantGroup.empty(group)
    group[EK.inhabitants] = 0
    group[EK.happiness] = 0
    group[EK.health] = 0
    group[EK.sanity] = 0
    group[EK.diseases] = new_disease_group(0)
    group[EK.genders] = GenderGroup.new_immigrants(0, group[EK.type])
    group[EK.ages] = AgeGroup.new(0)
end

--- Adds the necessary data so this house can also work as an InhabitantGroup.
--- @param house Entry
function InhabitantGroup.new_house(house)
    InhabitantGroup.empty(house)
end

--- Checks if the given InhabitantGroup objects can be merged.
--- @param lh InhabitantGroup
--- @param rh InhabitantGroup
--- @return boolean
function InhabitantGroup.can_be_merged(lh, rh)
    return lh[EK.type] == rh[EK.type]
end
local groups_can_merge = InhabitantGroup.can_be_merged

--- Merges the inhabitants of the right InhabitantGroup into the left one.
--- @param lh InhabitantGroup
--- @param rh InhabitantGroup
--- @param keep_rh boolean|nil
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

    DiseaseGroup.merge(lh[EK.diseases], rh[EK.diseases], keep_rh)
    AgeGroup.merge(lh[EK.ages], rh[EK.ages], keep_rh)
    GenderGroup.merge(lh[EK.genders], rh[EK.genders], keep_rh)

    if not keep_rh then
        InhabitantGroup.empty(rh)
    end
end

--- Takes the specified number of inhabitants out of the given InhabitantGroup.
--- Returns a new InhabitantGroup of the taken inhabitants.
--- @param group InhabitantGroup
--- @param count integer
--- @return InhabitantGroup
function InhabitantGroup.take(group, count)
    local existing_count = group[EK.inhabitants]
    local taken_count = min(existing_count, count)
    group[EK.inhabitants] = existing_count - taken_count

    return new_group(
        group[EK.type],
        taken_count,
        group[EK.happiness],
        group[EK.health],
        group[EK.sanity],
        DiseaseGroup.take(group[EK.diseases], taken_count, existing_count),
        GenderGroup.take(group[EK.genders], taken_count, existing_count),
        AgeGroup.take(group[EK.ages], taken_count, existing_count)
    )
end
local take_inhabitants = InhabitantGroup.take

--- Like InhabitantGroup.take, but allowes to specify the diseases, genders or ages to take.
--- @param group InhabitantGroup
--- @param count integer
--- @param diseases DiseaseGroup|nil DiseaseGroup of the taken inhabitants.
--- @param genders GenderGroup|nil GenderGroup of the taken inhabitants.
--- @param ages AgeGroup|nil AgeGroup of the taken Inhabitants.
--- @return InhabitantGroup
function InhabitantGroup.take_specific(group, count, diseases, genders, ages)
    local existing_count = group[EK.inhabitants]
    local taken_count = min(existing_count, count)
    group[EK.inhabitants] = existing_count - taken_count

    if diseases then
        DiseaseGroup.subtract(group[EK.diseases], diseases)
    end
    if genders then
        GenderGroup.subtract(group[EK.genders], genders)
    end
    if ages then
        AgeGroup.subtract(group[EK.ages], ages)
    end

    return new_group(
        group[EK.type],
        taken_count,
        group[EK.happiness],
        group[EK.health],
        group[EK.sanity],
        diseases or DiseaseGroup.take(group[EK.diseases], taken_count, existing_count),
        genders or GenderGroup.take(group[EK.genders], taken_count, existing_count),
        ages or AgeGroup.take(group[EK.ages], taken_count, existing_count)
    )
end
local take_specific_inhabitants = InhabitantGroup.take_specific

--- Merges the given number of inhabitants from the right InhabitantGroup in to the left one.
--- @param lh InhabitantGroup
--- @param rh InhabitantGroup
--- @param count integer
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

local function get_caste_bonus_multiplier(happiness)
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
--- @return boolean
function Inhabitants.caste_is_researched(caste_id)
    return technologies[castes[caste_id].tech_name]
end
local is_researched = Inhabitants.caste_is_researched

--- Returns the level of the efficiency technology for the given caste.
--- @param caste_id Type
function Inhabitants.get_caste_efficiency(caste_id)
    return technologies[castes[caste_id].efficiency_tech]
end

--- Returns the total number of inhabitants.
function Inhabitants.get_population_count()
    return array_sum(population)
end

--- Gets the current Clockwork caste bonus.
local function get_clockwork_bonus()
    local machine_count = Register.get_machine_count()
    local points = caste_points[Type.clockwork]

    if global.maintenance_enabled then
        local maintenance_points = points + global.starting_clockwork_points

        if machine_count > maintenance_points then
            return floor(map_range(machine_count, maintenance_points, max(1, 2 * maintenance_points), 0, -60))
        end

        points = points - max(0, machine_count - global.starting_clockwork_points)
    end

    return floor(5 * (max(0, points) / max(1, machine_count)) ^ 0.8)
end

--- Gets the current Orchid caste bonus.
local function get_orchid_bonus()
    return floor(max(0, caste_points[Type.orchid]) ^ 0.5)
end

--- Gets the current Gunfire caste bonus.
local function get_gunfire_bonus()
    -- 1 point per turret increases damage by 10%
    return floor(10 * max(0, caste_points[Type.gunfire]) / max(Register.get_type_count(Type.turret), 1))
end

--- Gets the current Ember caste bonus.
local function get_ember_bonus()
    local non_ember_population = array_sum(population) - population[Type.ember]
    if non_ember_population > 0 then
        return floor_to_step((3 * max(0, caste_points[Type.ember]) / non_ember_population) ^ 0.6, 0.1)
    else
        return 0
    end
end

--- Gets the current Foundry caste bonus.
local function get_foundry_bonus()
    return floor(max(0, caste_points[Type.foundry] * 5) ^ 0.5)
end

--- Gets the current Gleam caste bonus.
local function get_gleam_bonus()
    return floor(max(0, caste_points[Type.gleam]) ^ 0.5)
end

--- Gets the current Aurora caste bonus.
local function get_aurora_bonus()
    return floor(max(0, caste_points[Type.aurora]) ^ 0.5)
end

local function get_plasma_bonus()
    local non_plasma_population = array_sum(population) - population[Type.plasma]
    if non_plasma_population > 0 then
        return floor_to_step((max(0, caste_points[Type.plasma]) / non_plasma_population) ^ 0.5, 0.1)
    else
        return 0
    end
end

--- Updates all the caste bonuses and sets the ones that are applied global instead of per-entity. At the moment these are Gunfire, Gleam and Foundry.
local function update_caste_bonuses()
    local old_clockwork_bonus = caste_bonuses[Type.clockwork]
    local new_clockwork_bonus = get_clockwork_bonus()
    caste_bonuses[Type.clockwork] = get_clockwork_bonus()

    if old_clockwork_bonus >= 0 and new_clockwork_bonus < 0 then
        Communication.warning(WarningType.insufficient_maintenance)
    end
    if new_clockwork_bonus <= -40 then
        Communication.warning(WarningType.badly_insufficient_maintenance)
    end

    caste_bonuses[Type.orchid] = get_orchid_bonus()
    caste_bonuses[Type.ember] = get_ember_bonus()
    caste_bonuses[Type.aurora] = get_aurora_bonus()
    caste_bonuses[Type.plasma] = get_plasma_bonus()

    -- hidden technology based bonuses
    -- We check if the bonuses have actually changed to avoid unnecessary api calls
    local current_gunfire_bonus = get_gunfire_bonus()
    if caste_bonuses[Type.gunfire] ~= current_gunfire_bonus then
        set_binary_techs(current_gunfire_bonus, "-gunfire-caste")
        caste_bonuses[Type.gunfire] = current_gunfire_bonus
    end

    local current_foundry_bonus = get_foundry_bonus()
    if caste_bonuses[Type.foundry] ~= current_foundry_bonus then
        set_binary_techs(current_foundry_bonus, "-foundry-caste")
        caste_bonuses[Type.foundry] = current_foundry_bonus
    end

    local current_gleam_bonus = get_gleam_bonus()
    if caste_bonuses[Type.gleam] ~= current_gleam_bonus then
        set_binary_techs(current_gleam_bonus, "-gleam-caste")
        caste_bonuses[Type.gleam] = current_gleam_bonus
    end
end

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

local function look_for_workers(manufactory, acceptable_castes, count)
    local workers_found = 0

    for i = 1, #acceptable_castes do
        for _, house in Neighborhood.all_of_type(manufactory, acceptable_castes[i]) do
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
--- @param house Entry with workforce
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

--- Ends the employment of all employed inhabitants of this house.
--- Must be called if a house gets deconstructed.
--- @param house Entry with inhabitants
local function unemploy_all_inhabitants(house)
    unemploy_inhabitants(house, house[EK.employed])
end

--- Update function for entries with workforce.
--- Looks for employees if this entry needs then. Or fires them if there are too many.
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

--- Translates a happiness value to a working performance.
--- @param happiness number
--- @return number
local function get_work_coefficient(happiness)
    if happiness < 10 then
        return Tirislib.Utils.smootherstep(0.1 * happiness)
    else
        return (0.1 * happiness) ^ 0.7
    end
end

--- Returns a percentage on how satisfied the given buildings need for workers is.
--- @param manufactory Entry
--- @return number
function Inhabitants.evaluate_workforce(manufactory)
    local workforce = get_building_details(manufactory).workforce

    if not workforce then
        return 1
    end

    local worker_equivalents = 0

    for unit_number, worker_count in pairs(manufactory[EK.workers]) do
        local house = try_get(unit_number)

        if house then
            worker_equivalents = worker_equivalents + worker_count * get_work_coefficient(house[EK.happiness])
        end
    end

    return worker_equivalents / workforce.count
end

---------------------------------------------------------------------------------------------------
-- << inhabitant interface functions >>

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

---------------------------------------------------------------------------------------------------
-- << housing space management >>

local function update_free_space_status(entry)
    local caste_id = entry[EK.type]
    local unit_number = entry[EK.unit_number]
    local is_improvised = get_housing_details(entry).is_improvised

    if get_free_capacity(entry) > 0 then
        free_houses[is_improvised][caste_id][unit_number] = unit_number
    else
        free_houses[is_improvised][caste_id][unit_number] = nil
    end
end

local function get_next_free_house(caste_id, improvised)
    local next_houses_table = next_free_houses[improvised][caste_id]

    if #next_houses_table == 0 then
        -- create the next free houses queue
        Table.merge(next_houses_table, free_houses[improvised][caste_id])
        shuffle(next_houses_table)

        -- check if there are any free houses at all
        if #next_houses_table == 0 then
            return nil
        end
    end

    local unit_number = next_houses_table[#next_houses_table]
    next_houses_table[#next_houses_table] = nil

    local entry = try_get(unit_number)
    if entry and entry[EK.type] == caste_id and get_free_capacity(entry) > 0 then
        return entry
    else
        -- remove it from the list of free houses
        free_houses[caste_id][unit_number] = nil
        -- skip this outdated house
        return get_next_free_house(caste_id, improvised)
    end
end

--- Tries to add the specified amount of inhabitants to the house-entry.
--- Returns the number of inhabitants that were added.
--- @param entry Entry
--- @param group InhabitantGroup
--- @param silent boolean|nil
local function try_add_to_house(entry, group, silent)
    local count_moving_in = min(group[EK.inhabitants], get_free_capacity(entry))

    if count_moving_in == 0 then
        return 0
    end

    InhabitantGroup.merge_partially(entry, group, count_moving_in)
    update_free_space_status(entry)

    if not silent then
        Communication.create_flying_text(entry, {"sosciencity.inhabitants-moved-in", count_moving_in})
    end

    return count_moving_in
end

local function distribute(group, to_improvised)
    local count_before = group[EK.inhabitants]
    local caste_id = group[EK.type]
    local next_house = get_next_free_house(caste_id, to_improvised)

    local to_distribute = count_before
    while to_distribute > 0 and next_house do
        to_distribute = to_distribute - try_add_to_house(next_house, group)

        next_house = get_next_free_house(caste_id, to_improvised)
    end

    return count_before - to_distribute
end

--- Tries to distribute the specified inhabitants to official houses with free capacity.
--- Returns the number of inhabitants that were distributed.
--- @param group InhabitantGroup
local function distribute_inhabitants(group)
    return distribute(group, false)
end

---------------------------------------------------------------------------------------------------
-- << homeless inhabitants >>

local function try_house_homeless()
    for _, group in pairs(homeless) do
        distribute_inhabitants(group)
    end
end

local function try_occupy_empty_housing()
    for caste_id, group in pairs(homeless) do
        if group[EK.inhabitants] == 0 then
            goto continue
        end

        -- find and sort the empty houses
        local empty_houses = {}

        for _, empty_house in Register.all_of_type(Type.empty_house) do
            if empty_house[EK.is_liveable] and Housing.allowes_caste(get_housing_details(empty_house), caste_id) then
                empty_houses[#empty_houses + 1] = empty_house
            end
        end

        if #empty_houses == 0 then
            goto continue
        end

        table.sort(
            empty_houses,
            function(house1, house2)
                local housing_details1 = get_housing_details(house1)
                local housing_details2 = get_housing_details(house2)

                return Inhabitants.evaluate_housing_qualities(housing_details1, castes[caste_id]) + housing_details1.comfort >
                    Inhabitants.evaluate_housing_qualities(housing_details2, castes[caste_id]) + housing_details2.comfort
            end
        )

        -- try to distribute the inhabitants
        for _, current_house in pairs(empty_houses) do
            if Inhabitants.try_allow_for_caste(current_house, caste_id, false) then
                -- Inhabitants.try_allow_for_caste registeres the house with a new entry
                -- so we need to try_get the new one
                try_add_to_house(try_get(current_house[EK.unit_number]), group)
            end

            if group[EK.inhabitants] == 0 then
                break
            end
        end

        ::continue::
    end
end

local HUTS = {}
for name, house in pairs(Housing.values) do
    if house.is_improvised then
        HUTS[#HUTS + 1] = name
    end
end

local function create_improvised_huts()
    for caste_id, group in pairs(homeless) do
        for _, market in Register.all_of_type(Type.market) do
            if not Entity.market_has_food(market) then
                goto continue
            end

            local entity = market[EK.entity]
            local position = entity.position
            local surface = entity.surface
            local range = get_building_details(market).range

            local bounding_box = Utils.get_range_bounding_box(position, range)

            while group[EK.inhabitants] > 0 do
                -- improvised huts are 4x4 entities
                -- we look for positions of composting-silo, because it is a 6x6 entity, so there will be a
                -- 1 tile margin for a random offset
                local pos = surface.find_non_colliding_position_in_box("composting-silo", bounding_box, 1, true)
                if not pos then
                    break
                end
                Utils.add_random_offset(pos, 1)

                local hut_to_create = HUTS[random(#HUTS)]
                local new_hut =
                    surface.create_entity {
                    name = hut_to_create,
                    position = pos,
                    force = "player",
                    create_build_effect_smoke = false
                }
                local entry = Register.add(new_hut, caste_id)

                try_add_to_house(entry, group)
            end

            ::continue::
        end
    end
end

--- Adds the given InhabitantGroup to the global homeless pool.
local function add_to_homeless_pool(group)
    local caste_id = group[EK.type]
    InhabitantGroup.merge(homeless[caste_id], group)
    try_house_homeless()
end

local function update_homelessness()
    -- try to house the homeless people
    try_house_homeless()
    try_occupy_empty_housing()
    create_improvised_huts()

    -- apply effects to the remaining guys
    for caste_id, homeless_group in pairs(homeless) do
        local count = homeless_group[EK.inhabitants]

        if count > 0 then
            Communication.warning(WarningType.homelessness, caste_id)
        end

        update_happiness(homeless_group, 0, 1800)
        update_health(homeless_group, 0, 1800)
        update_sanity(homeless_group, 0, 1800)

        local emigrating = ceil(count * 0.05)
        if emigrating > 0 then
            local emigrated = take_inhabitants(homeless_group, emigrating)
            Communication.report_emigration(emigrated[EK.inhabitants], EmigrationCause.homeless)
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << city interface >>

function Inhabitants.add_to_city(group)
    distribute_inhabitants(group)
    add_to_homeless_pool(group)
end

---------------------------------------------------------------------------------------------------
-- << social interaction >>

--- Needs to be called when there is a change of any type that affects the social environment.
function Inhabitants.social_environment_change()
    global.last_social_change = game.tick
end

--- the time a ga reproduction cycle lasts
Inhabitants.ga_reproduction_cycle = Time.nauvis_day

local function get_ga_reproduction_cycle(tick)
    return floor(tick / Inhabitants.ga_reproduction_cycle)
end

local function build_social_environment(entry)
    local itself = entry[EK.unit_number]
    local in_reach = {[itself] = itself}

    for _, _type in pairs(TypeGroup.social_places) do
        for _, building in Neighborhood.all_of_type(entry, _type) do
            for _, caste in pairs(TypeGroup.all_castes) do
                for _, house in Neighborhood.all_of_type(building, caste) do
                    local unit_number = house[EK.unit_number]
                    in_reach[unit_number] = unit_number
                end
            end
        end
    end

    entry[EK.social_environment] = Table.get_keyset(in_reach)
end

local function get_social_value(environment)
    local value = 0

    for _, unit_number in pairs(environment) do
        local house = try_get(unit_number)

        if house then
            local caste = castes[house[EK.type]]
            value = value + house[EK.inhabitants] * caste.social_coefficient
        end
    end

    return value ^ 0.3
end

local function get_partner_rate(environment)
    local fale_count = 0
    local pachin_count = 0
    local ga_count = 0

    for _, unit_number in pairs(environment) do
        local house = try_get(unit_number)

        if house then
            local genders = house[EK.genders]
            fale_count = fale_count + genders[Gender.fale]
            pachin_count = pachin_count + genders[Gender.pachin]
            ga_count = ga_count + genders[Gender.ga]
        end
    end

    -- handle the edge case of no ga people
    if ga_count == 0 then
        ga_count = 1
    end

    return min(fale_count / ga_count, pachin_count / ga_count, 1)
end

Inhabitants.conception_rate = 0.3

local function social_meeting(entry, meeting_count)
    local ga_count = entry[EK.genders][Gender.ga]
    local past_conceptions = entry[EK.ga_conceptions]
    local environment = entry[EK.social_environment]

    -- reproduction
    if ga_count > past_conceptions then
        local available_partners = floor(get_partner_rate(environment) * ga_count)
        available_partners = available_partners - past_conceptions
        local fertile_ga_count = ga_count - past_conceptions
        local conceptions = coin_flips(Inhabitants.conception_rate, meeting_count, 5)

        local actual_conceptions = min(fertile_ga_count, available_partners, conceptions)
        if actual_conceptions > 0 then
            Inventories.output_eggs(entry, actual_conceptions)
            entry[EK.ga_conceptions] = past_conceptions + actual_conceptions
        end
    end

    -- infections
    for disease_id, count in pairs(entry[EK.diseases]) do
        if disease_id ~= HEALTHY then
            local contagiousness = disease_values[disease_id].contagiousness
            if contagiousness then
                local infections = coin_flips(contagiousness, count, 5)

                if infections > 0 then
                    local random_house = try_get(environment[random(#environment)])
                    if random_house then
                        local infected = make_sick(random_house[EK.diseases], disease_id, infections)
                        Communication.report_diseased(disease_id, infected, DiseasedCause.infection)
                    end
                end
            end
        end
    end
end

local social_coefficient = 1 / 10000 -- TODO balancing
local function evaluate_social_environment(entry, sanity_summands, delta_ticks)
    if get_ga_reproduction_cycle(entry[EK.last_update]) ~= get_ga_reproduction_cycle(game.tick) then
        -- a new ga cycle started, the gas are fertile again
        entry[EK.ga_conceptions] = 0
    end

    if entry[EK.last_update] < global.last_social_change then
        build_social_environment(entry)
    end

    local environment = entry[EK.social_environment]
    local social_value = get_social_value(environment)
    sanity_summands[SanitySummand.social_environment] = social_value

    local social_progress = entry[EK.social_progress] + social_value * delta_ticks * social_coefficient
    if social_progress >= 1 then
        local event_count = floor(social_progress)
        social_meeting(entry, event_count)
        social_progress = social_progress - event_count
    end
    entry[EK.social_progress] = social_progress
end

---------------------------------------------------------------------------------------------------
-- << healthcare >>

-- XXX: this part has magic numbers - but at the moment I don't know how to avoid them without overcomplicating stuff
local special_sideeffect_fns = {
    [4001] = function(entry, count, _)
        local gender_group = entry[EK.genders]

        for _ = 1, count do
            local gender_before = Utils.weighted_random(gender_group)
            local gender_after = Utils.random_different(1, 4, gender_before)

            gender_group[gender_before] = gender_group[gender_before] - 1
            gender_group[gender_after] = gender_group[gender_after] + 1
        end
    end
}

--- Determines the side effects of a cured disease.
---@param entry Entry
---@param disease_id DiseaseID
---@param count integer
---@param cured boolean
---@param new_diseases table Holds the escalation or complication diseases that are to be added.
local function cure_side_effects(entry, disease_id, count, cured, new_diseases)
    local disease = disease_values[disease_id]

    local lethal_probability = cured and disease.complication_lethality or disease.lethality
    local dead_count = 0
    if lethal_probability then
        dead_count = coin_flips(lethal_probability, count)
        if dead_count > 0 then
            take_specific_inhabitants(entry, dead_count, {[HEALTHY] = dead_count})
            Communication.report_disease_death(dead_count, disease_id)
        end
    end

    -- the following effects cannot occur when the persons died
    count = count - dead_count

    local escalation_disease = disease.escalation
    local escalation_count = 0
    if not cured and escalation_disease then
        escalation_count = coin_flips(disease.escalation_probability, count, 5)
        if escalation_count > 0 then
            new_diseases[escalation_disease] = (new_diseases[escalation_disease] or 0) + escalation_count
            Communication.report_diseased(escalation_disease, escalation_count, DiseasedCause.escalation)
        end
    end

    local complication_disease = disease.complication
    if complication_disease then
        local complication_count = coin_flips(disease.complication_probability, count - escalation_count, 5)
        if complication_count > 0 then
            new_diseases[complication_disease] = (new_diseases[complication_disease] or 0) + complication_count
            Communication.report_diseased(complication_disease, complication_count, DiseasedCause.complication)
        end
    end

    local fn = special_sideeffect_fns[disease_id]
    if fn then
        fn(entry, count, cured)
    end
end

function Inhabitants.get_birth_defect_probability()
    return 0.25 * 0.8 ^ technologies["improved-reproductive-healthcare"]
end

function Inhabitants.get_accident_disease_progress(entry, delta_ticks)
    return entry[EK.employed] * delta_ticks / 200000 * castes[entry[EK.type]].accident_disease_resilience
end

function Inhabitants.get_health_disease_progress(entry, delta_ticks)
    return entry[EK.inhabitants] * delta_ticks / 100000 / (entry[EK.health] + 1) *
        castes[entry[EK.type]].health_disease_resilience
end

function Inhabitants.get_sanity_disease_progress(entry, delta_ticks)
    return entry[EK.inhabitants] * delta_ticks / 100000 / (entry[EK.sanity] + 1) *
        castes[entry[EK.type]].sanity_disease_resilience
end

function Inhabitants.get_zoonosis_disease_progress(entry, delta_ticks)
    return entry[EK.inhabitants] * delta_ticks * (global.active_animal_farms ^ 0.5) / 5000000
end

Inhabitants.disease_progress_updaters = {
    [DiseaseCategory.accident] = Inhabitants.get_accident_disease_progress,
    [DiseaseCategory.health] = Inhabitants.get_health_disease_progress,
    [DiseaseCategory.sanity] = Inhabitants.get_sanity_disease_progress,
    [DiseaseCategory.zoonosis] = Inhabitants.get_zoonosis_disease_progress
}
local disease_progress_updaters = Inhabitants.disease_progress_updaters

local function create_disease_cases(entry, disease_group, delta_ticks)
    local progresses = entry[EK.disease_progress]

    for disease_category, updater in pairs(disease_progress_updaters) do
        local progress = progresses[disease_category] + updater(entry, delta_ticks)

        if progress >= 1 then
            local new_diseases = floor(progress)

            make_sick_randomly(disease_group, disease_category, new_diseases)

            progress = progress - new_diseases
        end

        progresses[disease_category] = progress
    end
end

local function is_recoverable(id)
    return disease_values[id].natural_recovery ~= nil
end

local function has_facility(hospital, facility_type)
    for _, facility in Neighborhood.all_of_type(hospital, facility_type) do
        if Entity.is_active(facility) then
            return true
        end
    end

    return false
end

local function try_treat_disease(hospital, hospital_contents, inventories, disease_group, disease_id, count)
    -- check if the player disallowed treating this disease
    if hospital[EK.treatment_permissions][disease_id] == false then
        return 0
    end

    local disease = disease_values[disease_id]
    local necessary_facility = disease.curing_facility

    if necessary_facility and not has_facility(hospital, necessary_facility) then
        return 0
    end

    local operations = hospital[EK.workhours]
    local workload_per_case = disease.curing_workload
    local items_per_case = disease.cure_items or {}

    -- determine the number of treated cases
    local to_treat = min(count, floor(operations / workload_per_case))

    for item_name, item_count in pairs(items_per_case) do
        to_treat = min(to_treat, floor((hospital_contents[item_name] or 0) / item_count))
    end

    if to_treat > 0 then
        to_treat = cure(disease_group, disease_id, to_treat)

        -- consume operations and items
        hospital[EK.workhours] = operations - to_treat * workload_per_case

        local items = table_copy(items_per_case)
        table_multiply(items, to_treat)
        Inventories.remove_item_range_from_inventory_range(inventories, items)
    end

    return to_treat
end

local function treat_diseases(entry, hospitals, diseases, disease_group, new_diseases)
    if not diseases then
        return
    end

    for disease_id, count in pairs(diseases) do
        for _, hospital in pairs(hospitals) do
            local inventories = Entity.get_hospital_inventories(hospital)
            local contents = Inventories.get_combined_contents(inventories)

            local treated = try_treat_disease(hospital, contents, inventories, disease_group, disease_id, count)

            if treated > 0 then
                cure_side_effects(entry, disease_id, treated, true, new_diseases)
                local statistics = hospital[EK.treated]
                statistics[disease_id] = (statistics[disease_id] or 0) + treated
                Communication.report_treatment(disease_id, treated)
            end

            count = count - treated
            if count == 0 then
                break
            end
        end
    end
end

local function update_disease_cases(entry, disease_group, delta_ticks)
    -- check if there are diseased people in the first place, because this function is moderately expensive
    if disease_group[HEALTHY] == entry[EK.inhabitants] then
        return
    end

    -- A table with all the diseases which happen as a side effect of the treatments/recoveries.
    -- They have to be added later to avoid problems with instantly treated-diseases and to avoid
    -- mixing removing and adding keys to the DiseaseGroup (which can break the pairs-loop).
    local new_diseases = {}

    -- treat disease cases in hospitals
    local hospitals = Neighborhood.get_by_type(entry, Type.hospital)
    Table.merge_arrays(hospitals, Neighborhood.get_by_type(entry, Type.improvised_hospital))

    local grouped = Luaq_from(disease_group):where(not_healthy):group(is_recoverable):to_table()
    treat_diseases(entry, hospitals, grouped[false], disease_group, new_diseases)
    treat_diseases(entry, hospitals, grouped[true], disease_group, new_diseases)

    for disease_id, count in pairs(disease_group) do
        if disease_id ~= HEALTHY then
            local natural_recovery = disease_values[disease_id].natural_recovery
            if natural_recovery then
                local recovered = coin_flips(occurence_probability(natural_recovery, delta_ticks), count, 5)
                recovered = cure(disease_group, disease_id, recovered)

                if recovered > 0 then
                    cure_side_effects(entry, disease_id, recovered, false, new_diseases)
                    Communication.report_recovery(disease_id, recovered)
                end
            end
        end
    end

    for disease_id, count in pairs(new_diseases) do
        make_sick(disease_group, disease_id, count)
    end
end

local function update_diseases(entry, delta_ticks)
    local disease_group = entry[EK.diseases]

    create_disease_cases(entry, disease_group, delta_ticks)
    update_disease_cases(entry, disease_group, delta_ticks)

    -- check employments
    local healthy_count = disease_group[HEALTHY]
    local employed_count = entry[EK.employed]

    if employed_count > healthy_count then
        unemploy_inhabitants(entry, employed_count - healthy_count)
    end
end

local function get_blood_donation_progress(entry, delta_ticks)
    return entry[EK.diseases][HEALTHY] * (entry[EK.health] ^ 0.5) * delta_ticks / 1000000
end
Inhabitants.get_blood_donation_progress = get_blood_donation_progress

local function update_blood_donations(entry, delta_ticks)
    if not technologies["transfusion-medicine"] then
        return
    end

    local donations =
        update_progress(entry, EK.blood_donation_progress, get_blood_donation_progress(entry, delta_ticks))

    if donations > 0 then
        local hospitals = Neighborhood.get_by_type(entry, Type.improvised_hospital)
        Table.merge_arrays(hospitals, Neighborhood.get_by_type(entry, Type.hospital))

        for _, hospital in pairs(hospitals) do
            if hospital[EK.workhours] >= hospital[EK.blood_donation_threshold] then
                local max_donations = min(donations, floor(hospital[EK.workhours] / Biology.blood_donation_workload))
                donations = donations - max_donations

                local actual_donations =
                    Inventories.try_insert(
                    Inventories.get_chest_inventory(hospital),
                    Biology.blood_donation_item,
                    max_donations
                )
                hospital[EK.blood_donations] = hospital[EK.blood_donations] + actual_donations
                hospital[EK.workhours] = hospital[EK.workhours] - actual_donations * Biology.blood_donation_workload

                if donations < 1 then
                    return
                end
            end
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << housing update >>
-- it's so complex, it got its own section

local function get_garbage_influence(entry)
    return max(get_garbage_value(entry) - 20, 0) * (-0.1)
end

local function evaluate_housing_qualities(house_details, caste_details)
    local quality_assessment = 0
    local preferences = caste_details.housing_preferences
    for _, quality in pairs(house_details.qualities) do
        quality_assessment = quality_assessment + (preferences[quality] or 0)
    end
    return quality_assessment
end
Inhabitants.evaluate_housing_qualities = evaluate_housing_qualities

--- Evaluates the effect of the housing on its inhabitants.
--- @param entry Entry
local function evaluate_housing(entry, happiness_summands, sanity_summands, caste)
    local housing = get_housing_details(entry)
    happiness_summands[HappinessSummand.housing] = housing.comfort
    sanity_summands[SanitySummand.housing] = housing.comfort

    happiness_summands[HappinessSummand.suitable_housing] = evaluate_housing_qualities(housing, caste)

    local garbage_influence = get_garbage_influence(entry)
    happiness_summands[HappinessSummand.garbage] = garbage_influence
    if garbage_influence < 0 then
        Communication.warning(WarningType.garbage, entry)
    end

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

    local fear_malus = global.fear * caste.fear_resilience
    happiness_summands[HappinessSummand.fear] = fear_malus
    if fear_malus > 5 then
        health_summands[HealthSummand.fear] = fear_malus / 2
        sanity_summands[SanitySummand.fear] = fear_malus / 2
    else
        health_summands[HealthSummand.fear] = 0
        sanity_summands[SanitySummand.fear] = 0
    end

    sanity_summands[SanitySummand.innate] = caste.innate_sanity
end

local function evaluate_neighborhood(entry, happiness_summands, health_summands)
    local nightclub_bonus = 0
    for _, nightclub in Neighborhood.all_of_type(entry, Type.nightclub) do
        nightclub_bonus = max(nightclub_bonus, nightclub[EK.performance])
    end
    happiness_summands[HappinessSummand.nightclub] = nightclub_bonus

    local animal_farm_count = 0
    for _, animal_farm in Neighborhood.all_of_type(entry, Type.animal_farm) do
        if animal_farm[EK.houses_animals] then
            animal_farm_count = animal_farm_count + 1
        end
    end
    happiness_summands[HappinessSummand.gross_industry] = -1 * animal_farm_count ^ 0.5
    health_summands[HealthSummand.gross_industry] = -2 * animal_farm_count ^ 0.7
end

local function update_ages(entry)
    local last_shift = entry[EK.last_age_shift]
    local shift = floor((game.tick - last_shift) / Time.nauvis_week)

    if shift > 0 then
        AgeGroup.shift(entry[EK.ages], shift)
        entry[EK.last_age_shift] = last_shift + shift * Time.nauvis_week
    end
end

--- Gets the trend toward the next inhabitant that moves out.
function Inhabitants.get_emigration_trend(nominal_happiness, caste, delta_ticks)
    return map_range(nominal_happiness, 0, caste.emigration_threshold, caste.emigration_coefficient, 0) * delta_ticks
end
local get_emigration_trend = Inhabitants.get_emigration_trend

local function update_emigration(entry, happiness, caste_id, delta_ticks)
    local emigration_trend = get_emigration_trend(happiness, castes[caste_id], delta_ticks)

    -- reset the trend value if the people are happy or if the house is empty
    if emigration_trend == 0 or entry[EK.inhabitants] == 0 then
        entry[EK.emigration_trend] = 0
        return
    end

    -- Testing disabling this WarningType for now. I have the feeling it's not as useful as the ones that directly point toward problems.
    --[[if emigration_trend > 0 then
        Communication.warning(WarningType.emigration, entry)
    end]]

    local trend = entry[EK.emigration_trend] + emigration_trend

    if trend > 1 then
        local emigrating = floor(trend)

        if emigrating > 0 then
            trend = trend - emigrating
            local emigrants = take_inhabitants(entry, emigrating)
            Communication.report_emigration(emigrants[EK.inhabitants], EmigrationCause.unhappy)
            Communication.create_flying_text(entry, {"sosciencity.inhabitants-emigrated", emigrating})
        end
    end

    entry[EK.emigration_trend] = trend
end

function Inhabitants.get_garbage_progress(entry, delta_ticks)
    return castes[entry[EK.type]].garbage_coefficient * entry[EK.inhabitants] * delta_ticks
end
local get_garbage_progress = Inhabitants.get_garbage_progress

local function update_garbage_output(entry, delta_ticks)
    local garbage = update_progress(entry, EK.garbage_progress, get_garbage_progress(entry, delta_ticks))
    if garbage > 0 then
        produce_garbage(entry, "garbage", garbage)
    end
end

local function update_housing_census(entry)
    local caste_id = entry[EK.type]
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
    local efficiency = 1 + 0.1 * global.technologies[castes[caste_id].efficiency_tech]
    local manpower = get_employable_count(entry) -- the number of healthy inhabitants that are not busy working at a manufactory
    for disease, count in pairs(entry[EK.diseases]) do
        if disease ~= HEALTHY then
            manpower = manpower + count * disease_values[disease].work_effectivity
        end
    end

    local points = manpower * get_caste_bonus_multiplier(entry[EK.happiness]) * efficiency
    caste_points[caste_id] = caste_points[caste_id] - entry[EK.caste_points] + points
    entry[EK.caste_points] = points
end

local function remove_housing_census(entry)
    local caste_id = entry[EK.type]

    population[caste_id] = population[caste_id] - entry[EK.official_inhabitants]
    caste_points[caste_id] = caste_points[caste_id] - entry[EK.caste_points]
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
    evaluate_water(entry, delta_ticks, happiness_factors, health_factors, health_summands)
    evaluate_sosciety(happiness_summands, health_summands, sanity_summands, caste)
    evaluate_neighborhood(entry, happiness_summands, health_summands)
    evaluate_social_environment(entry, sanity_summands, delta_ticks)

    -- update health
    local nominal_health = get_nominal_value(health_summands, health_factors)
    update_health(entry, nominal_health, delta_ticks)

    local new_health = entry[EK.health]
    happiness_summands[HappinessSummand.health] = (inhabitants > 0 and new_health > 10) and (new_health - 10) ^ 0.5 or 0
    happiness_factors[HappinessFactor.bad_health] = (inhabitants > 0) and map_range(new_health, 0, 10, 0, 1) ^ 0.5 or 1

    -- update sanity
    local nominal_sanity = get_nominal_value(sanity_summands, sanity_factors)
    update_sanity(entry, nominal_sanity, delta_ticks)

    local new_sanity = entry[EK.sanity]
    happiness_summands[HappinessSummand.sanity] = (inhabitants > 0 and new_sanity > 10) and (new_sanity - 10) ^ 0.5 or 0
    happiness_factors[HappinessFactor.bad_sanity] = (inhabitants > 0) and map_range(new_sanity, 0, 10, 0, 1) ^ 0.5 or 1

    -- update happiness
    local nominal_happiness = get_nominal_value(happiness_summands, happiness_factors)
    update_happiness(entry, nominal_happiness, delta_ticks)

    update_ages(entry)
    update_emigration(entry, entry[EK.happiness], caste_id, delta_ticks)
    update_housing_census(entry)
    update_garbage_output(entry, delta_ticks)
    update_diseases(entry, delta_ticks)
    update_blood_donations(entry, delta_ticks)
end

---------------------------------------------------------------------------------------------------
-- << immigration >>

function Inhabitants.migration_wave(immigration_port_details)
    local capacity = immigration_port_details.capacity
    local order = Table.sequence(1, #immigration)
    shuffle(order)

    for i = 1, #immigration do
        local caste = order[i]
        local count_immigrated = min(floor(immigration[caste]), capacity)

        capacity = capacity - count_immigrated
        immigration[caste] = immigration[caste] - count_immigrated

        local immigrants = InhabitantGroup.new_immigrant_group(caste, count_immigrated)

        distribute_inhabitants(immigrants)
        add_to_homeless_pool(immigrants)
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
    global.fear = global.fear + 0.05 * casualties
    Communication.report_death(destroyed_house[EK.inhabitants], DeathCause.killed)
end

---------------------------------------------------------------------------------------------------
-- << general update >>

function Inhabitants.update(current_tick)
    update_caste_bonuses()

    if current_tick % Time.minute == 0 then
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
        if loud then
            Communication.caste_not_allowed_in(entry, caste_id)
        end
        return false
    end
end

local function on_settings_paste(source, destination)
    Inhabitants.try_allow_for_caste(destination, source[EK.type], true)
end

--- Initializes the given entry so it can work as an housing entry.
--- @param entry Entry
function Inhabitants.create_house(entry)
    InhabitantGroup.new_house(entry)
    entry[EK.official_inhabitants] = 0
    entry[EK.caste_points] = 0

    entry[EK.last_age_shift] = game.tick

    entry[EK.happiness_summands] = Table.new_array(Table.count(HappinessSummand), 0.)
    entry[EK.happiness_factors] = Table.new_array(Table.count(HappinessFactor), 1.)

    entry[EK.health_summands] = Table.new_array(Table.count(HealthSummand), 0.)
    entry[EK.health_factors] = Table.new_array(Table.count(HealthFactor), 1.)

    entry[EK.sanity_summands] = Table.new_array(Table.count(SanitySummand), 0.)
    entry[EK.sanity_factors] = Table.new_array(Table.count(SanityFactor), 1.)

    entry[EK.emigration_trend] = 0
    entry[EK.garbage_progress] = 0

    local progresses = {}
    for disease_category in pairs(disease_progress_updaters) do
        progresses[disease_category] = 0.9 * random()
    end
    entry[EK.disease_progress] = progresses

    entry[EK.employed] = 0
    entry[EK.employments] = {}

    entry[EK.social_progress] = 0
    entry[EK.ga_conceptions] = 0

    entry[EK.blood_donation_progress] = 0.4 * random()

    update_free_space_status(entry)

    Inhabitants.social_environment_change()
    build_social_environment(entry)

    local housing_details = get_housing_details(entry)
    global.housing_capacity[entry[EK.type]][housing_details.is_improvised] =
        global.housing_capacity[entry[EK.type]][housing_details.is_improvised] + get_capacity(entry)
end

function Inhabitants.copy_house(source, destination)
    try_add_to_house(destination, source, true)
    destination[EK.last_age_shift] = source[EK.last_age_shift]
    destination[EK.disease_progress] = Table.copy(source[EK.disease_progress])
    update_housing_census(destination)
end

--- Removes all the inhabitants living in the house. Must be called when a housing entity stops existing.
--- @param entry Entry
function Inhabitants.remove_house(entry, cause)
    unemploy_all_inhabitants(entry)
    remove_housing_census(entry)

    local unit_number = entry[EK.unit_number]
    local caste_id = entry[EK.type]
    local improvised = get_housing_details(entry).is_improvised
    free_houses[improvised][caste_id][unit_number] = nil
    Table.remove_all(next_free_houses[improvised][caste_id], unit_number)

    if cause == DeconstructionCause.destroyed then
        Inhabitants.add_casualty_fear(entry)
    elseif cause == DeconstructionCause.mined then
        add_to_homeless_pool(entry)
    end

    Inhabitants.social_environment_change()

    local housing_details = get_housing_details(entry)
    global.housing_capacity[entry[EK.type]][housing_details.is_improvised] =
        global.housing_capacity[entry[EK.type]][housing_details.is_improvised] - get_capacity(entry)
end

-- Set event handlers for the housing entities.
for _, caste in pairs(TypeGroup.all_castes) do
    Register.set_entity_creation_handler(caste, Inhabitants.create_house)
    Register.set_entity_copy_handler(caste, Inhabitants.copy_house)
    Register.set_entity_updater(caste, update_house)
    Register.set_entity_destruction_handler(caste, Inhabitants.remove_house)
    Register.set_settings_paste_handler(caste, Type.empty_house, on_settings_paste)
end

---------------------------------------------------------------------------------------------------
-- << empty housing event handlers >>

local function update_empty_house(entry)
    local has_water = false
    for _, water_distributer in Neighborhood.all_of_type(entry, Type.water_distributer) do
        if water_distributer[EK.water_name] then
            has_water = true
            break
        end
    end

    if has_water then
        remove_common_sprite(entry, RenderingType.water_warning)
    else
        add_common_sprite(entry, RenderingType.water_warning)
    end

    local has_food = false
    for _, market in Neighborhood.all_of_type(entry, Type.market) do
        if Entity.market_has_food(market) then
            has_food = true
            break
        end
    end

    if has_food then
        remove_common_sprite(entry, RenderingType.food_warning)
    else
        add_common_sprite(entry, RenderingType.food_warning)
    end

    entry[EK.is_liveable] = has_water and has_food
end

Register.set_entity_updater(Type.empty_house, update_empty_house)

return Inhabitants
