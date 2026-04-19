local DiseasedCause = require("enums.diseased-cause")
local EK = require("enums.entry-key")
local Gender = require("enums.gender")
local HappinessFactor = require("enums.happiness-factor")
local HappinessSummand = require("enums.happiness-summand")
local HealthSummand = require("enums.health-summand")
local SanitySummand = require("enums.sanity-summand")
local Type = require("enums.type")
local WarningType = require("enums.warning-type")

local Castes = require("constants.castes")
local Diseases = require("constants.diseases")
local Housing = require("constants.housing")
local Time = require("constants.time")
local TypeGroup = require("constants.type-groups")

local castes = Castes.values
local disease_values = Diseases.values
local get_housing_details = Housing.get
local get_garbage_value = Inventories.get_garbage_value
local has_power = Subentities.has_power
local try_get = Register.try_get
local Tables = Tirislib.Tables
local Utils = Tirislib.Utils
local coin_flips = Utils.coin_flips
local make_sick = DiseaseGroup.make_sick
local HEALTHY = DiseaseGroup.HEALTHY
local floor = math.floor
local max = math.max
local min = math.min
local random = math.random

---------------------------------------------------------------------------------------------------
-- << lifecycle >>

function Inhabitants.init_housing_environment()
    storage.last_social_change = game.tick
end

---------------------------------------------------------------------------------------------------
-- << housing evaluation >>

local function get_garbage_influence(entry)
    return max(get_garbage_value(entry) - 20, 0) * (-0.1)
end

local function evaluate_housing_traits(house_details, caste_details)
    local trait_assessment = 0
    local preferences = caste_details.housing_preferences
    for _, trait in pairs(house_details.traits) do
        trait_assessment = trait_assessment + (preferences[trait] or 0)
    end
    return trait_assessment
end
Inhabitants.evaluate_housing_traits = evaluate_housing_traits

--- Evaluates the effect of the housing on its inhabitants.
--- @param entry Entry
local function evaluate_housing(entry, happiness_summands, sanity_summands, happiness_factors, caste)
    local housing = get_housing_details(entry)
    local current_comfort = entry[EK.current_comfort] or 0
    happiness_summands[HappinessSummand.housing] = current_comfort
    sanity_summands[SanitySummand.housing] = current_comfort

    local minimum_comfort = caste.minimum_comfort
    if minimum_comfort > 0 and current_comfort < minimum_comfort then
        happiness_factors[HappinessFactor.comfort_malus] = current_comfort / minimum_comfort
    end

    happiness_summands[HappinessSummand.suitable_housing] = evaluate_housing_traits(housing, caste)

    local garbage_influence = get_garbage_influence(entry)
    happiness_summands[HappinessSummand.garbage] = garbage_influence
    if garbage_influence < 0 then
        Communication.warning(WarningType.garbage, entry)
    end

    if has_power(entry) then
        happiness_summands[HappinessSummand.power] = caste.power_bonus
    else
        happiness_summands[HappinessSummand.no_power] = caste.no_power_malus
    end
end
Inhabitants.evaluate_housing = evaluate_housing

---------------------------------------------------------------------------------------------------
-- << society evaluation >>

local function evaluate_sosciety(happiness_summands, health_summands, sanity_summands, caste)
    local ember_bonus = storage.caste_bonuses[Type.ember]
    if ember_bonus ~= 0 then
        happiness_summands[HappinessSummand.ember] = ember_bonus
    end

    local plasma_bonus = storage.caste_bonuses[Type.plasma]
    if plasma_bonus ~= 0 then
        health_summands[HealthSummand.plasma] = plasma_bonus
    end

    local fear_malus = -storage.fear * caste.fear_susceptibility
    if fear_malus ~= 0 then
        sanity_summands[SanitySummand.fear] = fear_malus
    end

    sanity_summands[SanitySummand.innate] = caste.innate_sanity
end
Inhabitants.evaluate_sosciety = evaluate_sosciety

---------------------------------------------------------------------------------------------------
-- << neighborhood evaluation >>

local function evaluate_neighborhood(entry, happiness_summands, health_summands)
    local nightclub_bonus = 0
    for _, nightclub in Neighborhood.iterate_type(entry, Type.nightclub) do
        nightclub_bonus = max(nightclub_bonus, nightclub[EK.performance])
    end
    if nightclub_bonus ~= 0 then
        happiness_summands[HappinessSummand.nightclub] = nightclub_bonus
    end

    local animal_farm_count = 0
    for _, animal_farm in Neighborhood.iterate_type(entry, Type.animal_farm) do
        if animal_farm[EK.houses_animals] then
            animal_farm_count = animal_farm_count + 1
        end
    end
    if animal_farm_count > 0 then
        happiness_summands[HappinessSummand.gross_industry] = -1 * animal_farm_count ^ 0.5
        health_summands[HealthSummand.gross_industry] = -2 * animal_farm_count ^ 0.7
    end
end
Inhabitants.evaluate_neighborhood = evaluate_neighborhood

---------------------------------------------------------------------------------------------------
-- << social environment >>

--- Needs to be called when there is a potential change in neighborhood connections that affects the social environment.
function Inhabitants.social_environment_change()
    storage.last_social_change = game.tick
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
        for _, building in Neighborhood.iterate_type(entry, _type) do
            for _, caste in pairs(Castes.all) do
                for _, house in Neighborhood.iterate_type(building, caste.type) do
                    local unit_number = house[EK.unit_number]
                    in_reach[unit_number] = unit_number
                end
            end
        end
    end

    entry[EK.social_environment] = Tables.get_keyset(in_reach)
end
Inhabitants.build_social_environment = build_social_environment

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

    if entry[EK.last_update] < storage.last_social_change then
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
Inhabitants.evaluate_social_environment = evaluate_social_environment
