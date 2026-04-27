local Gender = require("enums.gender")
local NutritionTag = require("enums.nutrition-tag")

local Time = require("constants.time")

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

--- The set of nutrition tags that contribute to health when covered by the diet.
--- Order determines display and iteration order.
InhabitantsConstants.required_nutrition_tags = {NutritionTag.protein_rich, NutritionTag.fat_rich, NutritionTag.carb_rich}

--- Health effect per nutrition tag. bonus applies when the tag is covered by the diet, malus when it is missing.
--- @type table<NutritionTag, {bonus: number, malus: number}>
InhabitantsConstants.nutrition_tag_effects = {
    [NutritionTag.protein_rich] = {bonus = 1, malus = -2},
    [NutritionTag.fat_rich]     = {bonus = 1, malus = -2},
    [NutritionTag.carb_rich]    = {bonus = 1, malus = -2},
}

--- Probability per consumed food item that it produces a food-leftovers item.
InhabitantsConstants.food_leftovers_chance = 0.125

--- Operations needed to complete one blood donation.
InhabitantsConstants.blood_donation_workload = 10
--- Item produced by a successful blood donation.
InhabitantsConstants.blood_donation_item = "blood-bag"
--- Medical-instruments consumed per blood donation.
InhabitantsConstants.blood_donation_medical_instruments_cost = 1

--- Calorific cost an inhabitant pays to lay one fertile egg.
InhabitantsConstants.egg_calories = 2000

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
            [Gender.agender] = 0.6,
            [Gender.fale] = 0.15,
            [Gender.pachin] = 0.15,
            [Gender.ga] = 0.1
        },
        birth_defect_probability = 0.1
    },
    ["huwan-egg-ovosynthesis"] = {
        genders = {
            [Gender.agender] = 0.2,
            [Gender.fale] = 0.1,
            [Gender.pachin] = 0.4,
            [Gender.ga] = 0.3
        },
        birth_defect_probability = 0.25
    }
}

return InhabitantsConstants
