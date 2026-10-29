local Gender = require("enums.gender")
local MoveCause = require("enums.move-cause")
local NutritionTag = require("enums.nutrition-tag")

local Time = require("constants.time")
local Unit = require("constants.unit")

local InhabitantsConstants = {}

--- Ticks a treatable disease must go unclaimed before the house becomes transport-eligible.
InhabitantsConstants.transport_eligibility_threshold = 5 * Time.minute

--- Happiness/health factors applied while inhabitants are starving.
InhabitantsConstants.starvation = {
    happiness_factor = 0.5,
    health_factor = 0.5
}

--- Happiness/health factors applied while inhabitants are dehydrated.
InhabitantsConstants.dehydration = {
    happiness_factor = 0.5,
    health_factor = 0.5
}

--- @class NutritionTagEffect
--- @field health_bonus number health summand when the tag is covered by the diet
--- @field health_malus number health summand when the tag is one of the caste's essential_nutrition_tags and missing
--- @field sanity_bonus number sanity summand when the tag is covered by the diet
--- @field conception_rate_factor number multiplier on the conception rate when the tag is covered by the diet

--- Effects of each nutrition tag. Omitted fields fall back to nutrition_tag_effect_defaults.
--- @type table<NutritionTag, NutritionTagEffect>
InhabitantsConstants.nutrition_tag_effects = {
    [NutritionTag.protein_rich]  = {health_bonus = 1, health_malus = -2.5},
    [NutritionTag.fat_rich]      = {health_bonus = 1, health_malus = -2.5},
    [NutritionTag.carb_rich]     = {health_bonus = 1, health_malus = -2.5},
    [NutritionTag.vitamin_rich]  = {health_bonus = 1, health_malus = -2.5},
    [NutritionTag.fiber_rich]    = {health_bonus = 1, health_malus = -2.5},
    [NutritionTag.mineral_rich]  = {health_bonus = 1, health_malus = -2.5, conception_rate_factor = 1.25},
    [NutritionTag.lucidin_rich]  = {sanity_bonus = 3},
    [NutritionTag.purpurin_rich] = {health_bonus = 2},
    [NutritionTag.ovolin_rich]   = {conception_rate_factor = 1.5},
}

InhabitantsConstants.nutrition_tag_effect_defaults = {
    health_bonus = 0,
    health_malus = 0,
    sanity_bonus = 0,
    conception_rate_factor = 1,
}

-- postprocessing: every tag gets an effect table with all fields set
for _, tag in pairs(NutritionTag) do
    local effect = InhabitantsConstants.nutrition_tag_effects[tag] or {}
    for field, default in pairs(InhabitantsConstants.nutrition_tag_effect_defaults) do
        if effect[field] == nil then
            effect[field] = default
        end
    end
    InhabitantsConstants.nutrition_tag_effects[tag] = effect
end

--- Move causes that trigger the relocation penalty.
--- @type table<MoveCause, boolean>
InhabitantsConstants.relocation_penalty_causes = {
    [MoveCause.pull]                   = true,
    [MoveCause.push]                   = true,
    [MoveCause.passive_redistribution] = true,
}

--- What fraction of the moving efficiency tech reduction applies per move cause.
--- @type table<MoveCause, number>
InhabitantsConstants.moving_efficiency_applicability = {
    [MoveCause.pull]                   = 1.0,
    [MoveCause.push]                   = 1.0,
    [MoveCause.passive_redistribution] = 1.0,
    [MoveCause.caste_conversion]       = 1.0,
    [MoveCause.immigration]            = 0.5,
    [MoveCause.upbringing]             = 0.5,
    [MoveCause.sanatorium_eviction]    = 0.0,
    [MoveCause.house_destroyed]        = 0.0,
    [MoveCause.copy]                   = 0.0,
}

--- Moving downtime durations per cause. Tune values after playtesting.
--- Inhabitants with moving downtime count as residents but provide no workforce or caste points.
--- @type table<MoveCause, integer>
InhabitantsConstants.moving_downtime = {
    [MoveCause.immigration]            = 1 * Time.minute,
    [MoveCause.upbringing]             = 1 * Time.minute,
    [MoveCause.pull]                   = 3 * Time.minute,
    [MoveCause.push]                   = 3 * Time.minute,
    [MoveCause.caste_conversion]       = 3 * Time.minute,
    [MoveCause.passive_redistribution] = 6 * Time.minute,
    [MoveCause.sanatorium_eviction]    = 1 * Time.minute,
    [MoveCause.house_destroyed]        = 1 * Time.minute,
    [MoveCause.copy]                   = 0,
}

--- Disease cases per inhabitant, before the caste's susceptibility and the house's stats.
--- Health, sanity and accident rates are divided by (stat + 1), so these are the rates at a stat of 0
--- (e.g. 0.036 per minute at health 10: 0.036 / 11 = one case per inhabitant every ~5 hours).
InhabitantsConstants.health_disease_rate = 0.036 * Unit.per_minute
InhabitantsConstants.sanity_disease_rate = 0.009 * Unit.per_minute
InhabitantsConstants.accident_disease_rate = 0.036 * Unit.per_minute
--- Multiplied with the square root of the number of active animal farms.
InhabitantsConstants.zoonosis_disease_rate = 0.00072 * Unit.per_minute
--- Only while the house has no food / no water.
InhabitantsConstants.malnutrition_disease_rate = 0.036 * Unit.per_minute
InhabitantsConstants.dehydration_disease_rate = 0.036 * Unit.per_minute
--- Multiplied with the average poisoning risk of the house's diet.
InhabitantsConstants.food_poisoning_disease_rate = 0.003 * Unit.per_minute
--- Multiplied with the average contamination of the drunk water.
InhabitantsConstants.waterborne_disease_rate = 0.004 * Unit.per_minute

--- Probability per consumed food item that it produces a food-leftovers item.
InhabitantsConstants.food_leftovers_chance = 0.125

--- Operations needed to complete one blood donation.
InhabitantsConstants.blood_donation_workload = 1
--- Item produced by a successful blood donation.
InhabitantsConstants.blood_donation_item = "blood-bag"
--- Medical-instruments consumed per blood donation.
InhabitantsConstants.blood_donation_medical_instruments_cost = 1

--- Time a ga needs after a conception until they can conceive again.
InhabitantsConstants.ga_reproduction_cycle = Time.nauvis_day

--- Social value (inhabitants * caste social coefficient of a house's social environment) that the
--- meeting and birth rates below are balanced for.
InhabitantsConstants.reference_social_value = 200
--- Social meetings per tick of a house in the reference social environment.
InhabitantsConstants.reference_meeting_rate = 12 / Time.nauvis_day
--- How strongly the meeting rate grows with the social value: meetings ~ social value ^ meeting_exponent.
InhabitantsConstants.meeting_exponent = 0.2
--- Eggs conceived per inhabitant per tick by the gender mix of naturally conceived eggs in the reference social environment.
InhabitantsConstants.birth_rate = 0.01 / Time.nauvis_day

--- Age in nauvis days at which the frailty of a huwan in a house with neutral health and sanity reaches 1.
--- Frailty is 2 ^ ((age - onset) / doubling), so it is negligible for young huwans.
InhabitantsConstants.frailty_onset = 170
--- Nauvis days until the frailty doubles.
InhabitantsConstants.frailty_doubling = 45
--- Health and sanity at which the onset isn't shifted.
InhabitantsConstants.frailty_neutral_value = 10
--- Nauvis days the onset moves per health point above (or below) the neutral value.
InhabitantsConstants.frailty_health_shift = 3
--- Nauvis days the onset moves per sanity point above (or below) the neutral value.
InhabitantsConstants.frailty_sanity_shift = 1.5
--- Health and sanity above this value count as this value for the onset.
InhabitantsConstants.frailty_shift_cap = 40
--- Natural deaths per inhabitant per tick at a frailty of 1.
InhabitantsConstants.natural_death_rate = 0.001 / Time.nauvis_day

--- Operations a bed needs to give one vaccine dose (one operation is one minute of a bed at full performance).
InhabitantsConstants.vaccination_workload = 0.1

--- Calorific cost an inhabitant pays to lay one fertile egg.
InhabitantsConstants.egg_calories = 2000

--- Health points lost per spinal fluid extraction.
InhabitantsConstants.spinal_fluid_health_cost = 25
--- Chance that a spinal fluid extraction goes wrong.
InhabitantsConstants.spinal_fluid_oops_chance = 0.05
--- Health points lost per botched spinal fluid extraction.
InhabitantsConstants.spital_fluid_oops_health_cost = 110

--- Item name of the fertile huwan egg.
InhabitantsConstants.egg_fertile = "huwan-egg"

--- Per-egg-type gender distribution at hatching and probability of a birth defect.
InhabitantsConstants.egg_data = {
    ["huwan-egg"] = {
        genders = {
            [Gender.agender] = 0.3,
            [Gender.fale] = 0.2,
            [Gender.pachin] = 0.2,
            [Gender.ga] = 0.3
        },
        birth_defect_probability = 0.25
    },
    ["huwan-agender-egg"] = {
        genders = {
            [Gender.agender] = 1,
            [Gender.fale] = 0,
            [Gender.pachin] = 0,
            [Gender.ga] = 0
        },
        birth_defect_probability = 0.1
    },
    ["huwan-fale-egg"] = {
        genders = {
            [Gender.agender] = 0,
            [Gender.fale] = 1,
            [Gender.pachin] = 0,
            [Gender.ga] = 0
        },
        birth_defect_probability = 0.1
    },
    ["huwan-pachin-egg"] = {
        genders = {
            [Gender.agender] = 0,
            [Gender.fale] = 0,
            [Gender.pachin] = 1,
            [Gender.ga] = 0
        },
        birth_defect_probability = 0.1
    },
    ["huwan-ga-egg"] = {
        genders = {
            [Gender.agender] = 0,
            [Gender.fale] = 0,
            [Gender.pachin] = 0,
            [Gender.ga] = 1
        },
        birth_defect_probability = 0.1
    },
    ["huwan-egg-autoreproduction"] = {
        genders = {
            [Gender.agender] = 0.7,
            [Gender.fale] = 0.15,
            [Gender.pachin] = 0.1,
            [Gender.ga] = 0.05
        },
        birth_defect_probability = 0.1
    },
    ["huwan-egg-ovosynthesis"] = {
        genders = {
            [Gender.agender] = 0.3,
            [Gender.fale] = 0.1,
            [Gender.pachin] = 0.35,
            [Gender.ga] = 0.25
        },
        birth_defect_probability = 0.25
    }
}

-- postprocessing: derive the meeting coefficient and the conception chance per meeting from the targets
do
    local C = InhabitantsConstants

    --- Meetings per tick of a house per social value ^ meeting_exponent.
    C.meeting_coefficient = C.reference_meeting_rate / C.reference_social_value ^ C.meeting_exponent

    -- share of the inhabitants that are gas with a partner, for the gender mix of naturally conceived eggs
    local genders = C.egg_data[C.egg_fertile].genders
    local ga = genders[Gender.ga]
    local eligible_share = ga * math.min(genders[Gender.fale] / ga, genders[Gender.pachin] / ga, 1)

    local chance_per_cycle = C.birth_rate * C.ga_reproduction_cycle / eligible_share
    local meetings_per_cycle = C.reference_meeting_rate * C.ga_reproduction_cycle

    --- Chance that a ga with a partner conceives during one social meeting.
    C.conception_rate = 1 - (1 - chance_per_cycle) ^ (1 / meetings_per_cycle)
end

return InhabitantsConstants
