local EK = require("enums.entry-key")

local Castes = require("constants.castes")
local Diseases = require("constants.diseases")
local InhabitantsConstants = require("constants.inhabitants")

local AgeGroup = require("classes.groups.age-group")
local DiseaseGroup = require("classes.groups.disease-group")
local GenderGroup = require("classes.groups.gender-group")
local ImmunityGroup = require("classes.groups.immunity-group")

local castes = Castes.values
local Tables = Tirislib.Tables
local max = math.max
local min = math.min
local weighted_average = Tirislib.Utils.weighted_average
local coin_flips = Tirislib.Utils.coin_flips
local occurrence_probability = Tirislib.Utils.occurrence_probability
--- Object class for holding groups of inhabitants.
--- @class InhabitantGroup
local InhabitantGroup = {}

local HEALTHY = DiseaseGroup.HEALTHY
local new_disease_group = DiseaseGroup.new
local make_sick = DiseaseGroup.make_sick
local sicken_randomly = DiseaseGroup.sicken_randomly
local new_immunity_group = ImmunityGroup.new

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
--- @param immunities ImmunityGroup?
--- @return InhabitantGroup
function InhabitantGroup.new(caste, count, happiness, health, sanity, diseases, genders, ages, immunities)
    count = count or 0

    return {
        [EK.type] = caste,
        [EK.inhabitants] = count,
        [EK.happiness] = happiness or DEFAULT_HAPPINESS,
        [EK.health] = health or DEFAULT_HEALTH,
        [EK.sanity] = sanity or DEFAULT_SANITY,
        [EK.diseases] = diseases or new_disease_group(count),
        [EK.genders] = genders or GenderGroup.new_immigrants(count, caste),
        [EK.ages] = ages or AgeGroup.new(count),
        [EK.immunities] = immunities or new_immunity_group()
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
        [EK.ages] = AgeGroup.new_immigrants(count),
        [EK.immunities] = new_immunity_group()
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
    group[EK.immunities] = new_immunity_group()
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
    ImmunityGroup.merge(lh[EK.immunities], rh[EK.immunities], keep_rh)

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
        AgeGroup.take(group[EK.ages], taken_count, existing_count),
        ImmunityGroup.take(group[EK.immunities], taken_count, existing_count)
    )
end

--- Like InhabitantGroup.take, but allowes to specify the diseases, genders or ages to take.
--- @param group InhabitantGroup
--- @param count integer
--- @param diseases DiseaseGroup? DiseaseGroup of the taken inhabitants.
--- @param genders GenderGroup? GenderGroup of the taken inhabitants.
--- @param ages AgeGroup? AgeGroup of the taken Inhabitants.
--- @param immunities ImmunityGroup? ImmunityGroup of the taken Inhabitants.
--- @return InhabitantGroup
function InhabitantGroup.take_specific(group, count, diseases, genders, ages, immunities)
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
    elseif diseases then
        ages = AgeGroup.take_for_diseases(group[EK.ages], diseases, taken_count, existing_count)
    end
    if immunities then
        ImmunityGroup.subtract(group[EK.immunities], immunities)
    end

    return new_group(
        group[EK.type],
        taken_count,
        group[EK.happiness],
        group[EK.health],
        group[EK.sanity],
        diseases or DiseaseGroup.take(group[EK.diseases], taken_count, existing_count),
        genders or GenderGroup.take(group[EK.genders], taken_count, existing_count),
        ages or AgeGroup.take(group[EK.ages], taken_count, existing_count),
        immunities or ImmunityGroup.take(group[EK.immunities], taken_count, existing_count)
    )
end

--- Returns the age in nauvis days at which the frailty of the given group's inhabitants is 1. Good health and
--- sanity delay it.
--- @param group InhabitantGroup
--- @return number
function InhabitantGroup.get_frailty_onset(group)
    local C = InhabitantsConstants
    local neutral = C.frailty_neutral_value
    local cap = C.frailty_shift_cap

    return C.frailty_onset + C.frailty_health_shift * (min(group[EK.health], cap) - neutral) +
        C.frailty_sanity_shift * (min(group[EK.sanity], cap) - neutral)
end

--- Rolls which of the given count of inhabitants with the given disease don't survive it and takes them out of
--- the group. They have to be bookkept as healthy already, like after InhabitantGroup.cure. The lethality rises
--- with their frailty. Their ages depend on the disease's age link: the oldest or youngest for linked diseases,
--- random ones otherwise. Returns the number of dead.
--- @param group InhabitantGroup
--- @param count integer
--- @param disease_id DiseaseID
--- @param lethality number death chance of a case at a frailty of 1 or less
--- @return integer
function InhabitantGroup.take_deceased(group, count, disease_id, lethality)
    local link = Diseases.values[disease_id].age_link
    -- the ages of the cases are only chosen on a copy, because take_specific subtracts the ages of the dead
    local ages = Tables.copy(group[EK.ages])
    local case_ages
    if link then
        case_ages = AgeGroup.take_extreme(ages, count, link)
    else
        case_ages = AgeGroup.take_random(ages, count, group[EK.inhabitants])
    end

    local today = AgeGroup.current_day()
    local onset = InhabitantGroup.get_frailty_onset(group)
    local dead_ages = {}
    local dead_count = 0
    for hatch_day, case_count in pairs(case_ages) do
        local frailty = AgeGroup.get_frailty(hatch_day, today, onset)
        local dead = coin_flips(min(1, lethality * max(1, frailty)), case_count)
        if dead > 0 then
            dead_ages[hatch_day] = dead
            dead_count = dead_count + dead
        end
    end

    if dead_count > 0 then
        InhabitantGroup.take_specific(group, dead_count, {[HEALTHY] = dead_count}, nil, dead_ages)
    end

    return dead_count
end

--- Returns the summed frailty of the group's inhabitants, which scales everything that comes with old age.
--- @param group InhabitantGroup
--- @return number
function InhabitantGroup.get_frailty_sum(group)
    local today = AgeGroup.current_day()
    local onset = InhabitantGroup.get_frailty_onset(group)
    local ret = 0

    for hatch_day, count in pairs(group[EK.ages]) do
        ret = ret + count * AgeGroup.get_frailty(hatch_day, today, onset)
    end

    return ret
end

--- Rolls which inhabitants of the group die a natural death during the given ticks and takes them out of the
--- group. The chance follows their frailty, so it is negligible for young inhabitants. Returns the number of dead.
--- @param group InhabitantGroup
--- @param delta_ticks integer
--- @return integer
function InhabitantGroup.take_natural_deaths(group, delta_ticks)
    local today = AgeGroup.current_day()
    local onset = InhabitantGroup.get_frailty_onset(group)
    local rate = InhabitantsConstants.natural_death_rate
    local dead_ages = {}
    local dead_count = 0

    for hatch_day, count in pairs(group[EK.ages]) do
        local rate_per_tick = min(1, rate * AgeGroup.get_frailty(hatch_day, today, onset))
        local dead = coin_flips(occurrence_probability(rate_per_tick, delta_ticks), count)
        if dead > 0 then
            dead_ages[hatch_day] = dead
            dead_count = dead_count + dead
        end
    end

    if dead_count > 0 then
        InhabitantGroup.take_specific(group, dead_count, nil, nil, dead_ages)
    end

    return dead_count
end

--- Tries to make the given number of people sick with the given disease, respecting their immunities.
--- Every case hits an immune person with the probability of the immune share of the healthy people.
--- Returns the number of people that were actually sickened.
--- @param group InhabitantGroup
--- @param disease_id DiseaseID
--- @param count integer
--- @return integer
function InhabitantGroup.make_sick(group, disease_id, count)
    local diseases = group[EK.diseases]
    local healthy = diseases[HEALTHY]
    if healthy == 0 then
        return 0
    end

    local immune = ImmunityGroup.get_immune(group[EK.immunities], disease_id, group[EK.inhabitants])
    if immune > 0 then
        local susceptible = max(0, healthy - immune)
        count = min(susceptible, coin_flips(susceptible / healthy, count, 5))
    end

    return make_sick(diseases, disease_id, count)
end
local make_group_sick = InhabitantGroup.make_sick

--- Tries to make the given number of people sick with random diseases of the given category, respecting their immunities.
--- @param group InhabitantGroup
--- @param disease_category DiseaseCategory
--- @param count integer
--- @param actual_count integer?
--- @param suppress_logging boolean?
function InhabitantGroup.make_sick_randomly(group, disease_category, count, actual_count, suppress_logging)
    sicken_randomly(make_group_sick, group, disease_category, count, actual_count, suppress_logging)
end

--- Returns the number of healthy people that are not immune to the given disease.
--- @param group InhabitantGroup
--- @param disease_id DiseaseID
--- @return integer
local function get_susceptible(group, disease_id)
    local immune = ImmunityGroup.get_immune(group[EK.immunities], disease_id, group[EK.inhabitants])
    return max(0, group[EK.diseases][HEALTHY] - immune)
end

--- Returns the number of healthy people that a vaccine against the given diseases would still protect.<br>
--- Assumes the susceptible people of the different diseases overlap as much as possible (people that were
--- vaccinated together are immune together), so it is the most people susceptible to one of the diseases.
--- @param group InhabitantGroup
--- @param disease_ids DiseaseID[]
--- @return integer
function InhabitantGroup.get_vaccinable(group, disease_ids)
    local vaccinable = 0
    for _, disease_id in pairs(disease_ids) do
        vaccinable = max(vaccinable, get_susceptible(group, disease_id))
    end
    return vaccinable
end

--- Gives one healthy person a vaccine dose against the given diseases.<br>
--- With the same overlap assumption as get_vaccinable, the dose goes to someone susceptible to every covered
--- disease that anybody is still susceptible to, so it makes them immune to all of those.
--- Returns false if nobody could use the dose.
--- @param group InhabitantGroup
--- @param disease_ids DiseaseID[]
--- @return boolean vaccinated
function InhabitantGroup.vaccinate(group, disease_ids)
    local inhabitants = group[EK.inhabitants]
    local immunities = group[EK.immunities]
    local vaccinated = false

    for _, disease_id in pairs(disease_ids) do
        if get_susceptible(group, disease_id) > 0 then
            ImmunityGroup.grant(immunities, "vaccinated", disease_id, 1, inhabitants)
            vaccinated = true
        end
    end

    return vaccinated
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

return InhabitantGroup
