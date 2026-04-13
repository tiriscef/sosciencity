local EK = require("enums.entry-key")
local HappinessFactor = require("enums.happiness-factor")
local HappinessSummand = require("enums.happiness-summand")
local HealthSummand = require("enums.health-summand")
local NutritionTag = require("enums.nutrition-tag")
local Type = require("enums.type")

local Castes = require("constants.castes")
local Food = require("constants.food")
local Time = require("constants.time")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

-- Tests for kitchen_for_all contributing food to neighboring houses.
-- Kitchens are assembling machines; their output inventory should be
-- visible to the diet system just like market chests.
--
-- Test setup: Ember (mixed eater), fruity=favored, salty=disliked.
-- We use the same test food items as the main diet tests.

local test_surface

local function setup()
    test_surface = Helpers.create_test_surface()
    storage.technologies["upbringing"] = 1
end

local function teardown()
    Helpers.clean_up()
end

local function run_evaluate_diet(house, delta_ticks)
    house[EK.happiness_summands] = {}
    house[EK.happiness_factors] = {}
    house[EK.health_summands] = {}
    house[EK.health_factors] = {}
    house[EK.sanity_summands] = {}
    house[EK.sanity_factors] = {}
    Inhabitants.evaluate_diet(house, delta_ticks)
    return house[EK.happiness_summands], house[EK.happiness_factors],
           house[EK.health_summands], house[EK.health_factors],
           house[EK.sanity_summands]
end

local assembling_machine_output = defines.inventory.crafter_output

local tag_effects = Food.nutrition_tag_effects
local carb_bonus = tag_effects[NutritionTag.carb_rich].bonus
local protein_bonus = tag_effects[NutritionTag.protein_rich].bonus
local fat_bonus = tag_effects[NutritionTag.fat_rich].bonus
local protein_malus = tag_effects[NutritionTag.protein_rich].malus
local fat_malus = tag_effects[NutritionTag.fat_rich].malus
local full_tag_bonus = carb_bonus + protein_bonus + fat_bonus

local ember = Castes.values[Type.ember]

---------------------------------------------------------------------------------------------------
-- << kitchen food is included in diet >>

Tirislib.Testing.add_test_case(
    "evaluate_diet includes food from neighboring kitchen output inventory",
    "integration|integration.inhabitants|integration.diet-kitchen",
    function()
        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.ember, 5)
        local kitchen = Helpers.create_and_register(test_surface, "test-kitchen-for-all", {5, 0})
        kitchen[EK.active] = true

        -- put food only in the kitchen output, not in the house chest
        local output = kitchen[EK.entity].get_inventory(assembling_machine_output)
        output.insert {name = "test-food-fruity-carb", count = 100}

        local hs, hf, ths, _, _ = run_evaluate_diet(house, Time.minute)

        Assert.is_nil(hf[HappinessFactor.hunger],
            "house should not starve when food is available in neighboring kitchen")
        Assert.equals(hs[HappinessSummand.taste], ember.happiness_per_favored_food,
            "favored food from kitchen should give taste happiness")
        Assert.equals(ths[HealthSummand.nutrients], carb_bonus + protein_malus + fat_malus,
            "nutrition tags from kitchen food should be evaluated")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << kitchen + house food combine >>

Tirislib.Testing.add_test_case(
    "evaluate_diet combines house chest and kitchen output for full tag coverage",
    "integration|integration.inhabitants|integration.diet-kitchen",
    function()
        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.ember, 5)
        local kitchen = Helpers.create_and_register(test_surface, "test-kitchen-for-all", {5, 0})
        kitchen[EK.active] = true

        -- carb in house, protein+fat in kitchen → all tags covered together
        Inventories.get_chest_inventory(house).insert {name = "test-food-fruity-carb", count = 100}
        local output = kitchen[EK.entity].get_inventory(assembling_machine_output)
        output.insert {name = "test-food-neutral-protein-fat", count = 100}

        local _, _, ths, _, _ = run_evaluate_diet(house, Time.minute)

        Assert.equals(ths[HealthSummand.nutrients], full_tag_bonus,
            "combining house and kitchen food should cover all nutrition tags")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << inactive kitchen is ignored >>

Tirislib.Testing.add_test_case(
    "evaluate_diet ignores food in inactive kitchen",
    "integration|integration.inhabitants|integration.diet-kitchen",
    function()
        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.ember, 5)
        local kitchen = Helpers.create_and_register(test_surface, "test-kitchen-for-all", {5, 0})
        kitchen[EK.active] = false

        local output = kitchen[EK.entity].get_inventory(assembling_machine_output)
        output.insert {name = "test-food-fruity-carb", count = 100}

        local _, hf, _, _, _ = run_evaluate_diet(house, Time.minute)

        Assert.equals(hf[HappinessFactor.hunger], require("constants.biology").starvation.happiness_factor,
            "inactive kitchen food should not prevent starvation")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << kitchen food is consumed >>

Tirislib.Testing.add_test_case(
    "evaluate_diet consumes food from kitchen output inventory",
    "integration|integration.inhabitants|integration.diet-kitchen",
    function()
        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.ember, 5)
        local kitchen = Helpers.create_and_register(test_surface, "test-kitchen-for-all", {5, 0})
        kitchen[EK.active] = true

        local output = kitchen[EK.entity].get_inventory(assembling_machine_output)
        output.insert {name = "test-food-fruity-carb", count = 100}

        local count_before = output.get_item_count("test-food-fruity-carb")
        run_evaluate_diet(house, Time.minute)
        local count_after = output.get_item_count("test-food-fruity-carb")

        Assert.less_than(count_after, count_before,
            "food should be consumed from kitchen output inventory")
    end,
    setup,
    teardown
)
