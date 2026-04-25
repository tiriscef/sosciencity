local DeathCause = require("enums.death-cause")
local EK = require("enums.entry-key")
local Type = require("enums.type")

local Castes = require("constants.castes")
local Diseases = require("constants.diseases")
local Housing = require("constants.housing")
local Time = require("constants.time")

--- Static class that handles the behaviour of the people.
Inhabitants = {}

--[[
    Data this class stores in storage
    --------------------------------
    storage.population: table
        [caste_id]: int (inhabitants count)

    storage.housing_capacity: table
        [caste_id]: table
            [bool (improvised)]: integer (capacity of all houses)

    storage.caste_points: table
        [caste_id]: float (total caste bonus points)

    storage.caste_bonuses: table
        [Type.clockwork]: integer (machine speed bonus in %)
        [Type.orchid]: integer (farm productivity bonus in %)
        [Type.gunfire]: integer (turret damage bonus in %)
        [Type.ember]: float (happiness bonus)
        [Type.plasma]: float (health bonus)
        [Type.foundry]: integer (mining productivity bonus in %)
        [Type.gleam]: integer (laboratory productivity bonus in %)
        [Type.aurora]: integer (rocket silo productivity bonus in %)

    storage.immigration: table
        [caste_id]: float (number of immigrants in the next wave)

    storage.free_houses: table
        [bool (improvised)]: table
            [caste_id]: table
                [unit_number]: truthy (lookup)

    storage.fear: float (fear level)

    storage.last_fear_event: tick

    storage.homeless: table
        [caste_id]: InhabitantGroup

    storage.last_social_change: tick

    storage.starting_clockwork_points: number
]]
-- local often used globals for enormous performance gains

local immigration

local castes = Castes.values

local get_housing_details = Housing.get

local Tables = Tirislib.Tables
local Utils = Tirislib.Utils

local floor = math.floor
local ceil = math.ceil
local round = Utils.round
local max = math.max
local min = math.min
local dice_rolls = Utils.dice_rolls
local shuffle = Tirislib.Arrays.shuffle
local weighted_average = Utils.weighted_average
local random = math.random

---------------------------------------------------------------------------------------------------
-- << lua state lifecycle stuff >>

local function set_locals()
    storage = _ENV.storage
    caste_bonuses = storage.caste_bonuses
    immigration = storage.immigration
    free_houses = storage.free_houses
    technologies = storage.technologies
end

local function new_caste_table()
    return Tirislib.LazyLuaq.from(Castes.all)
        :select(
            function(caste)
                return 0, caste.type
            end
        )
        :to_table()
end

--- Initialize the inhabitants related contents of storage.
function Inhabitants.init()
    storage = _ENV.storage

    storage.fear = 0
    storage.population = new_caste_table()
    storage.housing_capacity = {}
    storage.caste_points = new_caste_table()
    storage.caste_bonuses = new_caste_table()
    storage.immigration = new_caste_table()

    for _, caste in pairs(Castes.all) do
        storage.housing_capacity[caste.type] = {[true] = 0, [false] = 0}
    end

    -- submodule init
    Inhabitants.init_housing_management()
    Inhabitants.init_homelessness()
    Inhabitants.init_housing_environment()

    set_locals()
end

--- Sets local references during on_load
function Inhabitants.load()
    set_locals()

    -- submodule load
    Inhabitants.load_homelessness()
    Inhabitants.load_healthcare()
    Inhabitants.load_housing_update()
    Inhabitants.load_housing_lifecycle()
end

---------------------------------------------------------------------------------------------------
-- << inhabitant diseases >>

--- Object class for holding the diseases of a group of inhabitants.
--- @class DiseaseGroup
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

--- Tries to make the given number of people sick with random diseases of the given category.
--- @param group DiseaseGroup
--- @param disease_category DiseaseCategory
--- @param count integer
--- @param actual_count integer?
--- @param suppress_logging boolean?
function DiseaseGroup.make_sick_randomly(group, disease_category, count, actual_count, suppress_logging)
    actual_count = min(count, actual_count or 20)

    local rolled_diseases = dice_rolls(Diseases.categories[disease_category], count, actual_count, true)

    for disease_id, rolled_count in pairs(rolled_diseases) do
        local sickened = make_sick(group, disease_id, rolled_count)

        if not suppress_logging and sickened > 0 then
            Communication.report_diseased(disease_id, sickened, Diseases.disease_causes[disease_category])
        end
    end
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

---------------------------------------------------------------------------------------------------
-- << inhabitant ages >>

--- Object class for holding the Ages of an InhabitantGroup
--- @class AgeGroup
AgeGroup = {}

--- Returns a new AgeGroup table with fixed ages.
--- @param count integer
--- @param age integer?
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

--- Returns a new AgeGroup with randomly distributed immigrant ages.
--- @param count integer
--- @return AgeGroup
function AgeGroup.new_immigrants(count)
    return AgeGroup.random_new(count, get_immigrant_age)
end

--- Merges the right hand group into the left hand group. If keep_rh is falsy, the right hand group gets emptied.
--- @param lh AgeGroup
--- @param rh AgeGroup
--- @param keep_rh boolean?
function AgeGroup.merge(lh, rh, keep_rh)
    for age, count in pairs(rh) do
        lh[age] = (lh[age] or 0) + count
    end

    if not keep_rh then
        Tables.empty(rh)
    end
end

--- Takes the given count of people from the given age group and returns the age group of the taken people.
--- @param group AgeGroup
--- @param to_take integer
--- @param total_count integer?
--- @return AgeGroup
function AgeGroup.take(group, to_take, total_count)
    total_count = total_count or Tables.sum(group)
    to_take = min(to_take, total_count)

    local ret = {}

    while to_take > 0 do
        local made_progress = false
        for age, current_count in pairs(group) do
            local percentage_to_take = to_take / total_count
            local current_take = min(current_count, to_take, ceil(percentage_to_take * current_count))

            if current_take > 0 then
                made_progress = true
            end

            total_count = total_count - current_take
            to_take = to_take - current_take

            ret[age] = (ret[age] or 0) + current_take
            group[age] = (current_count ~= current_take) and current_count - current_take or nil

            if to_take == 0 then
                return ret
            end
        end
        if not made_progress then break end
    end

    return ret
end

--- Subtracts the age counts in rh from lh. Errors if lh has fewer people of any age than rh.
--- @param lh AgeGroup
--- @param rh AgeGroup
function AgeGroup.subtract(lh, rh)
    for age, count in pairs(rh) do
        local new_count = lh[age] - count

        if new_count < 0 then
            error("Sosciencity tried to subtract two incompatible AgeGroup objects.")
        end

        lh[age] = (new_count > 0) and new_count or nil
    end
end

--- Shifts all ages in the group forward by the given time increment.
--- @param group AgeGroup
--- @param time integer
function AgeGroup.shift(group, time)
    local copy = Tables.copy(group)
    Tables.empty(group)

    for age, count in pairs(copy) do
        group[age + time] = count
    end
end

---------------------------------------------------------------------------------------------------
-- << inhabitant genders >>

--- Object class for holding the Genders of an InhabitantGroup
--- @class GenderGroup
GenderGroup = {}

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

---------------------------------------------------------------------------------------------------
-- << inhabitant groups >>

--- Object class for holding groups of inhabitants.
--- @class InhabitantGroup
InhabitantGroup = {}

local DEFAULT_HAPPINESS = 10
local DEFAULT_HEALTH = 10
local DEFAULT_SANITY = 10

--- Constructs a new InhabitantGroup object.
--- @param caste Type
--- @param count integer?
--- @param happiness number?
--- @param health number?
--- @param sanity number?
--- @param diseases DiseaseGroup?
--- @param genders GenderGroup?
--- @param ages AgeGroup?
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

--- Throws all inhabitants of the given InhabitantGroup in a shredder.<br>
--- Can also be used to initialize a table where the EK.type is already set as a InhabitantGroup
--- @param group InhabitantGroup
function InhabitantGroup.empty(group)
    group[EK.inhabitants] = 0
    group[EK.happiness] = 0
    group[EK.health] = 0
    group[EK.sanity] = 0
    group[EK.diseases] = new_disease_group(0)
    group[EK.genders] = GenderGroup.new()
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
--- @param keep_rh boolean?
--- @param allow_caste_mismatch boolean? If the check that both groups are of the same type should be ommitted.
function InhabitantGroup.merge(lh, rh, keep_rh, allow_caste_mismatch)
    if not allow_caste_mismatch and not groups_can_merge(lh, rh) then
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

--- Like InhabitantGroup.take, but allowes to specify the diseases, genders or ages to take.
--- @param group InhabitantGroup
--- @param count integer
--- @param diseases DiseaseGroup? DiseaseGroup of the taken inhabitants.
--- @param genders GenderGroup? GenderGroup of the taken inhabitants.
--- @param ages AgeGroup? AgeGroup of the taken Inhabitants.
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

--- Merges the given number of inhabitants from the right InhabitantGroup in to the left one.
--- @param lh InhabitantGroup
--- @param rh InhabitantGroup
--- @param count integer
function InhabitantGroup.merge_partially(lh, rh, count)
    InhabitantGroup.merge(lh, InhabitantGroup.take(rh, count))
end

--- Returns the total power demand of the given InhabitantGroup.
--- @param group InhabitantGroup
--- @return number
function InhabitantGroup.get_power_usage(group)
    return group[EK.inhabitants] * castes[group[EK.type]].power_demand
end

-- caste research, bonus calculations, and update_caste_bonuses
-- moved to classes/inhabitants/castes.lua
local is_researched -- set after castes.lua is loaded
local update_caste_bonuses -- set after castes.lua is loaded

-- nominal value functions moved to classes/inhabitants/housing-update.lua

local add_to_homeless_pool
local update_homelessness

---------------------------------------------------------------------------------------------------
-- << immigration >>

--- Processes one immigration wave from the given port, distributing immigrants into free housing.
--- @param immigration_port_details Entry
function Inhabitants.migration_wave(immigration_port_details)
    local capacity = immigration_port_details.capacity
    local order = Tables.get_keyset(immigration)
    shuffle(order)

    for i = 1, #order do
        local caste = order[i]
        local count_immigrated = min(floor(immigration[caste]), capacity)

        capacity = capacity - count_immigrated
        immigration[caste] = immigration[caste] - count_immigrated

        local immigrants = InhabitantGroup.new_immigrant_group(caste, count_immigrated)

        Inhabitants.add_to_city(immigrants)
    end
end

---------------------------------------------------------------------------------------------------
-- << fear >>

local FEAR_CAP = 10

--- Lowers the population's fear over time. Assumes an update rate of 10 ticks.
--- Fear decreases after 2 minutes without a tragic event; the rate is proportional to the time since the last event.
--- A fear level of 10 will decrease to 0 after roughly 15 minutes.
function Inhabitants.ease_fear(current_tick)
    local coefficient = 8e-8
    local time_since_last_event = current_tick - (storage.last_fear_event or 0)

    if time_since_last_event > Time.nauvis_day then -- 2 minutes
        storage.fear = max(0, storage.fear - time_since_last_event * coefficient)
    end
end

--- Adds fear after a civil building got destroyed.
--- Fear approaches the cap of 10 with diminishing returns: each event closes 10% of the remaining gap.
function Inhabitants.add_fear()
    storage.last_fear_event = game.tick
    storage.fear = FEAR_CAP - (FEAR_CAP - storage.fear) * 0.9
end

--- Adds fear after an inhabited house was destroyed.
--- Closes 15% of the remaining gap to the cap (larger shock than a generic building).
function Inhabitants.add_casualty_fear(destroyed_house)
    storage.last_fear_event = game.tick
    storage.fear = FEAR_CAP - (FEAR_CAP - storage.fear) * 0.85
    Communication.report_death(destroyed_house[EK.inhabitants], DeathCause.killed)
end

---------------------------------------------------------------------------------------------------
-- << general update >>

--- Periodic update: recalculates caste bonuses and handles homelessness once per minute.
--- @param current_tick integer
function Inhabitants.update(current_tick)
    update_caste_bonuses()

    if current_tick % Time.minute == 0 then
        update_homelessness()
    end
end

---------------------------------------------------------------------------------------------------
-- << public housing API >>

--- Changes the type of the entry to the given caste if it makes sense. Returns true if it did so.
--- @param entry Entry
--- @param caste_id integer
--- @param loud boolean
function Inhabitants.try_allow_for_caste(entry, caste_id, loud)
    if
        entry[EK.type] == Type.empty_house and is_researched(caste_id) and
            Housing.allowes_caste(get_housing_details(entry), caste_id)
     then
        local saved_comfort = entry[EK.current_comfort]
        local saved_target = entry[EK.target_comfort]
        local saved_tags = entry[EK.trait_upgrades]
        local saved_target_tags = entry[EK.target_tags]
        local entity = entry[EK.entity]
        ItemRequests.cancel(entity, entity.get_inventory(defines.inventory.chest), entry)
        local new_entry = Register.change_type(entry, caste_id)
        new_entry[EK.current_comfort] = saved_comfort
        new_entry[EK.target_comfort] = saved_target
        new_entry[EK.trait_upgrades] = saved_tags
        new_entry[EK.target_tags] = saved_target_tags

        if loud then
            Communication.caste_allowed_in(new_entry, caste_id)
        end
        return new_entry
    else
        if loud then
            Communication.caste_not_allowed_in(entry, caste_id)
        end
        return nil
    end
end

--- Adds new inhabitants to the city. First tries to distribute to free houses, then adds the rest to the homeless pool.
--- @param group InhabitantGroup
function Inhabitants.add_to_city(group)
    Inhabitants.distribute(group, false)
    add_to_homeless_pool(group)
end

---------------------------------------------------------------------------------------------------
-- << outsourced subsystems >>

require("classes.inhabitants.castes")
require("classes.inhabitants.workforce")
require("classes.inhabitants.housing-environment")
require("classes.inhabitants.housing-needs")
require("classes.inhabitants.healthcare")
require("classes.inhabitants.housing-management")
require("classes.inhabitants.homelessness")
require("classes.inhabitants.housing-update")
require("classes.inhabitants.housing-lifecycle")
require("classes.inhabitants.housing-upgrades")
require("classes.inhabitants.empty-housing")

is_researched = Inhabitants.caste_is_researched
update_caste_bonuses = Inhabitants.update_caste_bonuses
build_social_environment = Inhabitants.build_social_environment
add_to_homeless_pool = Inhabitants.add_to_homeless_pool
update_homelessness = Inhabitants.update_homelessness

return Inhabitants
