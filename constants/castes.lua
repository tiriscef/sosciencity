local EatingBehavior = require("enums.eating-behavior")
local Gender = require("enums.gender")
local HousingTrait = require("enums.housing-trait")
local Taste = require("enums.taste")
local Type = require("enums.type")

local Time = require("constants.time")

--- Things that define different kinds of people.<br>
--- Use Castes.values to get the data of a caste by its type id.<br>
--- Use Castes.all for iterating all enabled castes.
local Castes = {}

--- @class CasteDefinition
--- @field name string internal name
--- @field localised_name LocalisedString
--- @field localised_name_short LocalisedString
--- @field enabled boolean whether this caste is active in the game
--- @field order integer display order
--- @field breedable boolean can reproduce naturally via upbringing stations
--- @field tech_name string technology required to unlock this caste
--- @field efficiency_tech string technology that improves this caste's efficiency bonus
--- @field fear_susceptibility number multiplier on fear sanity malus (0 = immune, 1 = full effect)
--- @field calorific_demand number kcal per day (converted to kcal/tick in postprocessing)
--- @field power_demand number kW (converted to J/tick in postprocessing)
--- @field power_bonus number happiness summand when power is sufficient
--- @field no_power_malus number happiness summand when power is insufficient (negative)
--- @field garbage_coefficient number garbage items produced per inhabitant per tick
--- @field water_demand number fluid units consumed per inhabitant per tick
--- @field eating_behavior EatingBehavior diet construction personality (minimalist/mixed/foodie)
--- @field favored_taste Taste preferred taste (one of the 4 designable tastes: fruity, salty, umami, spicy)
--- @field least_favored_taste Taste disliked taste (one of the 4 designable tastes: fruity, salty, umami, spicy)
--- @field minimum_food_count integer minimum distinct food groups needed to avoid variety penalty
--- @field happiness_per_favored_food number happiness summand per favored food in the diet (0 for minimalists, who don't select by taste)
--- @field happiness_per_disliked_food number happiness summand per forced disliked food (negative; 0 for foodies who never eat disliked)
--- @field happiness_per_nutrition_tag number happiness summand per required nutrition tag that is covered (primarily for minimalists)
--- @field happiness_per_missing_food number happiness malus per food group below minimum_food_count (negative; multiplied by the shortage count)
--- @field food_distress_factor number happiness factor applied when the caste is forced to eat outside their normal diet behavior (0–1)
--- @field required_room_count number room requirement for housing comfort calculation
--- @field minimum_comfort number minimum housing comfort level before a penalty applies
--- @field social_coefficient number multiplier on social environment happiness contribution
--- @field innate_sanity number baseline sanity summand independent of other factors
--- @field strike_begin_threshold number happiness below this level starts a strike
--- @field full_strike_threshold number happiness below this causes a full strike
--- @field full_strike_point_multiplier number caste point multiplier at full strike (see get_caste_bonus_multiplier)
--- @field full_strike_worker_fraction number minimum fraction of workers willing to work even at full strike
--- @field immigration_genders table<Gender, number> gender weight distribution for arriving immigrants
--- @field housing_preferences table<HousingTrait, number> preference modifiers keyed by housing trait
--- @field accident_disease_resilience number multiplier reducing accident disease probability
--- @field health_disease_resilience number multiplier reducing health disease probability
--- @field sanity_disease_resilience number multiplier reducing sanity disease probability
--- @field type Type set in postprocessing from the table key

-- TODO: Balancing of new diet fields

Castes.values = {
    [Type.clockwork] = {
        name = "clockwork",
        localised_name = {"caste-name.clockwork"},
        localised_name_short = {"caste-short.clockwork"},
        enabled = true,
        order = 3,
        breedable = true,
        tech_name = "upbringing",
        efficiency_tech = "clockwork-caste-efficiency",
        fear_susceptibility = 0.7,
        calorific_demand = 3200, -- in kcal per day
        power_demand = 12, -- in kW
        power_bonus = 2,
        no_power_malus = -2,
        garbage_coefficient = 0.1 / Time.minute, -- garbage produced per inhabitant per tick
        water_demand = 4 / Time.minute,
        eating_behavior = EatingBehavior.minimalist,
        favored_taste = Taste.umami,
        least_favored_taste = Taste.spicy,
        minimum_food_count = 1,
        happiness_per_favored_food = 0,
        happiness_per_disliked_food = -1,
        happiness_per_nutrition_tag = 2,
        happiness_per_missing_food = -1,
        food_distress_factor = 0.80, -- minimalist, early game
        required_room_count = 1,
        minimum_comfort = 0,
        social_coefficient = 1,
        innate_sanity = 10,
        strike_begin_threshold = 5,
        full_strike_threshold = 2,
        full_strike_point_multiplier = 0.5,
        full_strike_worker_fraction = 0.1,
        immigration_genders = {
            [Gender.agender] = 50,
            [Gender.fale] = 25,
            [Gender.pachin] = 5,
            [Gender.ga] = 20
        },
        housing_preferences = {
            [HousingTrait.sheltered] = 1,
            [HousingTrait.technical] = 3,
            [HousingTrait.compact] = 1,
            [HousingTrait.simple] = 2,
            [HousingTrait.cheap] = 2,
            [HousingTrait.decorated] = -1,
            [HousingTrait.green] = -1,
            [HousingTrait.pompous] = -1
        },
        accident_disease_resilience = 0.7,
        health_disease_resilience = 0.65,
        sanity_disease_resilience = 0.35
    },
    [Type.orchid] = {
        name = "orchid",
        localised_name = {"caste-name.orchid"},
        localised_name_short = {"caste-short.orchid"},
        enabled = true,
        order = 2,
        breedable = true,
        tech_name = "upbringing",
        efficiency_tech = "orchid-caste-efficiency",
        fear_susceptibility = 1,
        calorific_demand = 2800,
        power_demand = 10,
        power_bonus = 2,
        no_power_malus = -1,
        garbage_coefficient = 0.05 / Time.minute,
        water_demand = 6 / Time.minute,
        eating_behavior = EatingBehavior.foodie,
        favored_taste = Taste.fruity,
        least_favored_taste = Taste.salty,
        minimum_food_count = 5,
        happiness_per_favored_food = 3,
        happiness_per_disliked_food = 0,
        happiness_per_nutrition_tag = 0,
        happiness_per_missing_food = -3,
        food_distress_factor = 0.70, -- foodie, early game
        required_room_count = 1,
        minimum_comfort = 0,
        social_coefficient = 1,
        innate_sanity = 10,
        strike_begin_threshold = 3,
        full_strike_threshold = 1,
        full_strike_point_multiplier = 0.5,
        full_strike_worker_fraction = 0.2,
        immigration_genders = {
            [Gender.agender] = 15,
            [Gender.fale] = 5,
            [Gender.pachin] = 60,
            [Gender.ga] = 20
        },
        housing_preferences = {
            [HousingTrait.green] = 3,
            [HousingTrait.spacey] = 3,
            [HousingTrait.low] = 2,
            [HousingTrait.sheltered] = -1,
            [HousingTrait.technical] = -3,
            [HousingTrait.compact] = -1
        },
        accident_disease_resilience = 0.35,
        health_disease_resilience = 0.2,
        sanity_disease_resilience = 0.65
    },
    [Type.gunfire] = {
        name = "gunfire",
        localised_name = {"caste-name.gunfire"},
        localised_name_short = {"caste-short.gunfire"},
        enabled = true,
        order = 5,
        breedable = false,
        tech_name = "gunfire-caste",
        efficiency_tech = "gunfire-caste-efficiency",
        fear_susceptibility = 0.4,
        calorific_demand = 3680,
        power_demand = 2,
        power_bonus = 2,
        no_power_malus = -1,
        garbage_coefficient = 0.04 / Time.minute,
        water_demand = 3 / Time.minute,
        eating_behavior = EatingBehavior.minimalist,
        favored_taste = Taste.umami,
        least_favored_taste = Taste.fruity,
        minimum_food_count = 1,
        happiness_per_favored_food = 0,
        happiness_per_disliked_food = -1,
        happiness_per_nutrition_tag = 2,
        happiness_per_missing_food = -1,
        food_distress_factor = 0.75, -- minimalist, mid game
        required_room_count = 0.5,
        minimum_comfort = 0,
        social_coefficient = 0.5,
        innate_sanity = 10,
        strike_begin_threshold = 5,
        full_strike_threshold = 2,
        full_strike_point_multiplier = 0.5,
        full_strike_worker_fraction = 0,
        immigration_genders = {
            [Gender.agender] = 91,
            [Gender.fale] = 3,
            [Gender.pachin] = 3,
            [Gender.ga] = 3
        },
        housing_preferences = {
            [HousingTrait.sheltered] = 2.5,
            [HousingTrait.compact] = 1,
            [HousingTrait.simple] = 1,
            [HousingTrait.copy_paste] = 1,
            [HousingTrait.cheap] = 1,
            [HousingTrait.low] = 1,
            [HousingTrait.spacey] = -1,
            [HousingTrait.individualistic] = -2,
            [HousingTrait.pompous] = -1,
            [HousingTrait.tall] = -1
        },
        accident_disease_resilience = 1,
        health_disease_resilience = 0.2,
        sanity_disease_resilience = 1
    },
    [Type.ember] = {
        name = "ember",
        localised_name = {"caste-name.ember"},
        localised_name_short = {"caste-short.ember"},
        enabled = true,
        order = 1,
        breedable = true,
        tech_name = "upbringing",
        efficiency_tech = "ember-caste-efficiency",
        fear_susceptibility = 1,
        calorific_demand = 2000,
        power_demand = 10,
        power_bonus = 2,
        no_power_malus = -1,
        garbage_coefficient = 0.1 / Time.minute,
        water_demand = 4.5 / Time.minute,
        eating_behavior = EatingBehavior.mixed,
        favored_taste = Taste.fruity,
        least_favored_taste = Taste.salty,
        minimum_food_count = 3,
        happiness_per_favored_food = 2,
        happiness_per_disliked_food = -2,
        happiness_per_nutrition_tag = 0,
        happiness_per_missing_food = -2,
        food_distress_factor = 0.75, -- mixed, early game
        required_room_count = 1,
        minimum_comfort = 0,
        social_coefficient = 2,
        innate_sanity = 10,
        strike_begin_threshold = 5,
        full_strike_threshold = 2,
        full_strike_point_multiplier = 0.0,
        full_strike_worker_fraction = 0,
        immigration_genders = {
            [Gender.agender] = 5,
            [Gender.fale] = 35,
            [Gender.pachin] = 15,
            [Gender.ga] = 45
        },
        housing_preferences = {
            [HousingTrait.decorated] = 2.5,
            [HousingTrait.tall] = 3,
            [HousingTrait.simple] = -2
        },
        accident_disease_resilience = 0.1,
        health_disease_resilience = 0.8,
        sanity_disease_resilience = 0.6
    },
    [Type.foundry] = {
        name = "foundry",
        localised_name = {"caste-name.foundry"},
        localised_name_short = {"caste-short.foundry"},
        enabled = true,
        order = 6,
        breedable = false,
        tech_name = "foundry-caste",
        efficiency_tech = "foundry-caste-efficiency",
        fear_susceptibility = 1,
        calorific_demand = 2240,
        power_demand = 10,
        power_bonus = 2,
        no_power_malus = -8,
        garbage_coefficient = 0.15 / Time.minute,
        water_demand = 15 / Time.minute,
        eating_behavior = EatingBehavior.mixed,
        favored_taste = Taste.spicy,
        least_favored_taste = Taste.umami,
        minimum_food_count = 6,
        happiness_per_favored_food = 2,
        happiness_per_disliked_food = -2,
        happiness_per_nutrition_tag = 0,
        happiness_per_missing_food = -2,
        food_distress_factor = 0.65, -- mixed, late game
        required_room_count = 4,
        minimum_comfort = 6,
        social_coefficient = 0.8,
        innate_sanity = 10,
        strike_begin_threshold = 8,
        full_strike_threshold = 4,
        full_strike_point_multiplier = 0,
        full_strike_worker_fraction = 0,
        immigration_genders = {
            [Gender.agender] = 10,
            [Gender.fale] = 30,
            [Gender.pachin] = 30,
            [Gender.ga] = 30
        },
        housing_preferences = {
            [HousingTrait.technical] = 2,
            [HousingTrait.spacey] = 1,
            [HousingTrait.simple] = 1,
            [HousingTrait.copy_paste] = 1,
            [HousingTrait.green] = -2,
            [HousingTrait.individualistic] = -1,
            [HousingTrait.low] = -2
        },
        accident_disease_resilience = 0.5,
        health_disease_resilience = 1,
        sanity_disease_resilience = 1
    },
    [Type.gleam] = {
        name = "gleam",
        localised_name = {"caste-name.gleam"},
        localised_name_short = {"caste-short.gleam"},
        enabled = true,
        order = 7,
        breedable = false,
        tech_name = "gleam-caste",
        efficiency_tech = "gleam-caste-efficiency",
        fear_susceptibility = 1,
        calorific_demand = 2160,
        power_demand = 10,
        power_bonus = 2,
        no_power_malus = -8,
        garbage_coefficient = 0.25 / Time.minute,
        water_demand = 12 / Time.minute,
        eating_behavior = EatingBehavior.foodie,
        favored_taste = Taste.spicy,
        least_favored_taste = Taste.umami,
        minimum_food_count = 7,
        happiness_per_favored_food = 3,
        happiness_per_disliked_food = 0,
        happiness_per_nutrition_tag = 0,
        happiness_per_missing_food = -3,
        food_distress_factor = 0.60, -- foodie, late game
        required_room_count = 4,
        minimum_comfort = 7,
        social_coefficient = 1.5,
        innate_sanity = 10,
        strike_begin_threshold = 9,
        full_strike_threshold = 4,
        full_strike_point_multiplier = 0,
        full_strike_worker_fraction = 0,
        immigration_genders = {
            [Gender.agender] = 10,
            [Gender.fale] = 30,
            [Gender.pachin] = 30,
            [Gender.ga] = 30
        },
        housing_preferences = {
            [HousingTrait.spacey] = 1,
            [HousingTrait.individualistic] = 1,
            [HousingTrait.pompous] = 3,
            [HousingTrait.technical] = -2,
            [HousingTrait.cheap] = -3
        },
        accident_disease_resilience = 0.2,
        health_disease_resilience = 2,
        sanity_disease_resilience = 2
    },
    [Type.aurora] = {
        name = "aurora",
        localised_name = {"caste-name.aurora"},
        localised_name_short = {"caste-short.aurora"},
        enabled = false,
        order = 8,
        breedable = false,
        tech_name = "aurora-caste",
        efficiency_tech = "aurora-caste-efficiency",
        fear_susceptibility = 1,
        calorific_demand = 2000,
        power_demand = 35,
        power_bonus = 2,
        no_power_malus = -10,
        garbage_coefficient = 1 / Time.minute,
        water_demand = 25 / Time.minute,
        eating_behavior = EatingBehavior.foodie,
        favored_taste = Taste.fruity,
        least_favored_taste = Taste.salty,
        minimum_food_count = 9,
        happiness_per_favored_food = 3,
        happiness_per_disliked_food = 0,
        happiness_per_nutrition_tag = 0,
        happiness_per_missing_food = -3,
        food_distress_factor = 0.55, -- foodie, very late game
        required_room_count = 10,
        minimum_comfort = 9,
        social_coefficient = 5,
        innate_sanity = 10,
        strike_begin_threshold = 10,
        full_strike_threshold = 5,
        full_strike_point_multiplier = 0,
        full_strike_worker_fraction = 0,
        immigration_genders = {
            [Gender.agender] = 25,
            [Gender.fale] = 25,
            [Gender.pachin] = 25,
            [Gender.ga] = 25
        },
        housing_preferences = {
            [HousingTrait.green] = 1,
            [HousingTrait.spacey] = 1,
            [HousingTrait.decorated] = 1,
            [HousingTrait.individualistic] = 1,
            [HousingTrait.pompous] = 1,
            [HousingTrait.sheltered] = -2,
            [HousingTrait.technical] = -2,
            [HousingTrait.compact] = -2,
            [HousingTrait.simple] = -2,
            [HousingTrait.copy_paste] = -2,
            [HousingTrait.cheap] = -5
        },
        accident_disease_resilience = 0.2,
        health_disease_resilience = 1.5,
        sanity_disease_resilience = 1
    },
    [Type.plasma] = {
        name = "plasma",
        localised_name = {"caste-name.plasma"},
        localised_name_short = {"caste-short.plasma"},
        enabled = true,
        order = 4,
        breedable = false,
        tech_name = "plasma-caste",
        efficiency_tech = "plasma-caste-efficiency",
        fear_susceptibility = 0.4,
        calorific_demand = 2400,
        power_demand = 6,
        power_bonus = 2,
        no_power_malus = -3,
        garbage_coefficient = 0.2 / Time.minute,
        water_demand = 7 / Time.minute,
        eating_behavior = EatingBehavior.mixed,
        favored_taste = Taste.salty,
        least_favored_taste = Taste.fruity,
        minimum_food_count = 4,
        happiness_per_favored_food = 2,
        happiness_per_disliked_food = -2,
        happiness_per_nutrition_tag = 0,
        happiness_per_missing_food = -2,
        food_distress_factor = 0.70, -- mixed, mid game
        required_room_count = 3,
        minimum_comfort = 3,
        social_coefficient = 1.2,
        innate_sanity = 10,
        strike_begin_threshold = 6,
        full_strike_threshold = 3,
        full_strike_point_multiplier = 0,
        full_strike_worker_fraction = 0.2,
        immigration_genders = {
            [Gender.agender] = 10,
            [Gender.fale] = 40,
            [Gender.pachin] = 20,
            [Gender.ga] = 30
        },
        housing_preferences = {
            [HousingTrait.green] = 1,
            [HousingTrait.compact] = 1,
            [HousingTrait.decorated] = 2,
            [HousingTrait.individualistic] = 2,
            [HousingTrait.sheltered] = -1,
            [HousingTrait.simple] = -1,
            [HousingTrait.cheap] = -3
        },
        accident_disease_resilience = 0.2,
        health_disease_resilience = 0.2,
        sanity_disease_resilience = 1.5
    }
}

-- postprocessing
for type, caste in pairs(Castes.values) do
    caste.type = type

    -- convert calorific demand to kcal per tick
    caste.calorific_demand = caste.calorific_demand / Time.nauvis_day

    -- convert power demand to J / tick: https://wiki.factorio.com/Types/Energy
    caste.power_demand = caste.power_demand * 1000 / Time.second
end

Castes.all =
    Tirislib.LazyLuaq.from(Castes.values)
    :where_key("enabled"):order_by(
        function(caste)
            return caste.order
        end
    )
    :to_array()

return Castes
