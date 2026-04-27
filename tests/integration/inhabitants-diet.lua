local EK = require("enums.entry-key")
local HappinessFactor = require("enums.happiness-factor")
local HappinessSummand = require("enums.happiness-summand")
local HealthFactor = require("enums.health-factor")
local HealthSummand = require("enums.health-summand")
local NutritionTag = require("enums.nutrition-tag")
local SanitySummand = require("enums.sanity-summand")
local Type = require("enums.type")

local Castes = require("constants.castes")
local InhabitantsConstants = require("constants.inhabitants")
local Time = require("constants.time")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

-- All tests use dedicated test food items (defined in constants/food.lua, prototyped under
-- sosciencity-debug) so that balancing changes to real food values don't break behavior tests.
--
-- Test castes and their relevant taste preferences:
--   Clockwork  minimalist  umami=favored   spicy=disliked
--   Ember      mixed       fruity=favored  salty=disliked
--   Orchid     foodie      fruity=favored  salty=disliked
--
-- Test food items:
--   test-food-fruity-carb         fruity   carb                    appeal 6
--   test-food-fruity-fat          fruity   fat                     appeal 6
--   test-food-neutral-protein-fat neutral  protein+fat             appeal 7
--   test-food-neutral-carb        neutral  carb                    appeal 5
--   test-food-salty-protein       salty    protein                 appeal 6
--   test-food-spicy-alltags       spicy    protein+fat+carb        appeal 8
--   test-food-umami-carb          umami    carb                    appeal 5
--   test-food-umami-notag         umami    (none)                  appeal 5

local test_surface

local function setup()
    test_surface = Helpers.create_test_surface()
    storage.technologies["upbringing"] = 1
end

local function teardown()
    Helpers.clean_up()
end

--- Initialises summand/factor tables on the entry and runs evaluate_diet.
--- Returns happiness_summands, happiness_factors, health_summands, health_factors, sanity_summands.
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

local tag_effects = InhabitantsConstants.nutrition_tag_effects
local carb_bonus = tag_effects[NutritionTag.carb_rich].bonus
local protein_bonus = tag_effects[NutritionTag.protein_rich].bonus
local fat_bonus = tag_effects[NutritionTag.fat_rich].bonus
local protein_malus = tag_effects[NutritionTag.protein_rich].malus
local fat_malus = tag_effects[NutritionTag.fat_rich].malus
local carb_malus = tag_effects[NutritionTag.carb_rich].malus
local full_tag_bonus = carb_bonus + protein_bonus + fat_bonus

local clockwork = Castes.values[Type.clockwork]
local ember = Castes.values[Type.ember]
local orchid = Castes.values[Type.orchid]

---------------------------------------------------------------------------------------------------
-- << no food >>

Tirislib.Testing.add_test_case(
    "evaluate_diet applies starvation factors when no food is available",
    "integration|integration.inhabitants",
    function()
        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.ember, 5)

        local _, hf, _, thf, _ = run_evaluate_diet(house, Time.minute)

        Assert.equals(hf[HappinessFactor.hunger], InhabitantsConstants.starvation.happiness_factor,
            "hunger happiness factor should be applied with no food")
        Assert.equals(thf[HealthFactor.hunger], InhabitantsConstants.starvation.health_factor,
            "hunger health factor should be applied with no food")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << partial tag coverage >>

-- Ember mixed + test-food-fruity-carb (fruity/carb) only.
-- Diet: [test-food-fruity-carb]. Carb covered, protein and fat not.

Tirislib.Testing.add_test_case(
    "evaluate_diet gives partial nutrition health when only one tag is covered",
    "integration|integration.inhabitants",
    function()
        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.ember, 5)
        Inventories.get_chest_inventory(house).insert {name = "test-food-fruity-carb", count = 100}

        local _, _, ths, _, _ = run_evaluate_diet(house, Time.minute)

        Assert.equals(ths[HealthSummand.nutrients], carb_bonus + protein_malus + fat_malus,
            "nutrients health should equal carb bonus plus maluses for uncovered tags")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "evaluate_diet gives favored food happiness bonus to mixed eater",
    "integration|integration.inhabitants",
    function()
        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.ember, 5)
        Inventories.get_chest_inventory(house).insert {name = "test-food-fruity-carb", count = 100}

        local hs, _, _, _, _ = run_evaluate_diet(house, Time.minute)

        Assert.equals(hs[HappinessSummand.taste], ember.happiness_per_favored_food,
            "one favored food should give happiness_per_favored_food happiness")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << full tag coverage >>

-- Ember mixed + test-food-fruity-carb (fruity/carb) + test-food-neutral-protein-fat (neutral/protein+fat).
-- Diet: [fruity-carb, neutral-protein-fat]. All 3 tags covered.

Tirislib.Testing.add_test_case(
    "evaluate_diet gives full nutrition health when all tags are covered",
    "integration|integration.inhabitants",
    function()
        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.ember, 5)
        local inventory = Inventories.get_chest_inventory(house)
        inventory.insert {name = "test-food-fruity-carb", count = 100}
        inventory.insert {name = "test-food-neutral-protein-fat", count = 100}

        local _, _, ths, _, _ = run_evaluate_diet(house, Time.minute)

        Assert.equals(ths[HealthSummand.nutrients], full_tag_bonus,
            "nutrients health should equal the sum of all tag bonuses when all three tags are covered")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << minimalist behavior >>

-- Clockwork minimalist + test-food-neutral-carb (neutral for Clockwork, carb).
-- Minimalist covers carb tag with the only available food.

Tirislib.Testing.add_test_case(
    "evaluate_diet gives minimalist a nutrition tag happiness bonus per covered tag",
    "integration|integration.inhabitants",
    function()
        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 5)
        Inventories.get_chest_inventory(house).insert {name = "test-food-neutral-carb", count = 100}

        local hs, _, _, _, _ = run_evaluate_diet(house, Time.minute)

        Assert.equals(hs[HappinessSummand.nutrition_tags], clockwork.happiness_per_nutrition_tag,
            "minimalist should get happiness_per_nutrition_tag per covered required tag")
        Assert.is_nil(hs[HappinessSummand.taste],
            "minimalist should not receive a favored-food happiness bonus (test-food-neutral-carb is not umami)")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "evaluate_diet includes favored-taste food in minimalist diet when it covers a tag",
    "integration|integration.inhabitants",
    function()
        -- test-food-umami-carb: umami = favored for Clockwork, carb_rich.
        -- Minimalist picks favored-taste foods first for tag coverage.
        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 5)
        Inventories.get_chest_inventory(house).insert {name = "test-food-umami-carb", count = 100}

        local hs, hf, ths, _, _ = run_evaluate_diet(house, Time.minute)

        Assert.is_nil(hf[HappinessFactor.hunger],
            "minimalist should eat test-food-umami-carb and not starve")
        Assert.equals(ths[HealthSummand.nutrients], carb_bonus + protein_malus + fat_malus,
            "carb tag should be covered by test-food-umami-carb, protein and fat tags apply malus")
        Assert.equals(hs[HappinessSummand.nutrition_tags], clockwork.happiness_per_nutrition_tag,
            "minimalist should get nutrition tag happiness for the covered carb tag")
        Assert.is_nil(hs[HappinessSummand.taste],
            "minimalist should not receive a favored-food happiness bonus")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "evaluate_diet forces minimalist to eat disliked food when it is the only way to cover tags",
    "integration|integration.inhabitants",
    function()
        -- test-food-spicy-alltags: spicy = disliked for Clockwork, covers all 3 tags.
        -- No neutral/favored foods available; minimalist must use disliked.
        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 5)
        Inventories.get_chest_inventory(house).insert {name = "test-food-spicy-alltags", count = 100}

        local hs, _, ths, _, _ = run_evaluate_diet(house, Time.minute)

        Assert.equals(hs[HappinessSummand.disliked_food], clockwork.happiness_per_disliked_food,
            "eating one disliked food should apply happiness_per_disliked_food penalty")
        Assert.equals(ths[HealthSummand.nutrients], full_tag_bonus,
            "all tags should be covered when test-food-spicy-alltags is in the diet")
        Assert.equals(hs[HappinessSummand.nutrition_tags], 3 * clockwork.happiness_per_nutrition_tag,
            "all three tags covered should give 3x nutrition tag happiness")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << foodie behavior >>

-- Orchid foodie: favors fruity, dislikes salty.
-- test-food-spicy-alltags: spicy = neutral for Orchid.
-- test-food-salty-protein: salty = disliked for Orchid.

Tirislib.Testing.add_test_case(
    "evaluate_diet never includes disliked food for foodie even when it would cover a missing tag",
    "integration|integration.inhabitants",
    function()
        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.orchid, 5)
        local inventory = Inventories.get_chest_inventory(house)
        inventory.insert {name = "test-food-spicy-alltags", count = 100}  -- neutral for Orchid
        inventory.insert {name = "test-food-salty-protein", count = 100}  -- disliked for Orchid

        local hs, _, _, _, _ = run_evaluate_diet(house, Time.minute)

        Assert.is_nil(hs[HappinessSummand.disliked_food],
            "foodie should never eat disliked food")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "evaluate_diet includes all favored foods for foodie",
    "integration|integration.inhabitants",
    function()
        -- test-food-fruity-carb and test-food-fruity-fat: both fruity = favored for Orchid.
        -- Foodie includes all favored foods; diet has 2 favored items.
        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.orchid, 5)
        local inventory = Inventories.get_chest_inventory(house)
        inventory.insert {name = "test-food-fruity-carb", count = 100}
        inventory.insert {name = "test-food-fruity-fat", count = 100}

        local hs, _, _, _, _ = run_evaluate_diet(house, Time.minute)

        Assert.equals(hs[HappinessSummand.taste], 2 * orchid.happiness_per_favored_food,
            "foodie should get happiness_per_favored_food for each favored food in diet")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << sanity: taste >>

-- Ember mixed + test-food-fruity-carb (favored) + 2 neutral foods.
-- favored_food_count = 1 > 0 → +4 sanity.
-- Neutral plurality (2 > 1) so dominant ≠ salty → disliked_taste nil.

Tirislib.Testing.add_test_case(
    "evaluate_diet gives +4 sanity when at least one favored food is in the diet",
    "integration|integration.inhabitants",
    function()
        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.ember, 5)
        local inventory = Inventories.get_chest_inventory(house)
        inventory.insert {name = "test-food-fruity-carb", count = 100}        -- fruity = favored for Ember
        inventory.insert {name = "test-food-neutral-protein-fat", count = 100} -- neutral
        inventory.insert {name = "test-food-neutral-carb", count = 100}        -- neutral

        local _, _, _, _, ss = run_evaluate_diet(house, Time.minute)

        Assert.equals(ss[SanitySummand.favorite_taste], 4,
            "having any favored food in the diet should give +4 sanity")
        Assert.is_nil(ss[SanitySummand.disliked_taste],
            "disliked taste sanity should not be set when no disliked food dominates")
    end,
    setup,
    teardown
)

-- Clockwork minimalist + test-food-spicy-alltags only.
-- Only food is spicy = disliked for Clockwork → dominant = disliked → -4 sanity.
-- No favored food in diet → favorite_taste not set.

Tirislib.Testing.add_test_case(
    "evaluate_diet gives -4 sanity when disliked taste is dominant",
    "integration|integration.inhabitants",
    function()
        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 5)
        Inventories.get_chest_inventory(house).insert {name = "test-food-spicy-alltags", count = 100}

        local _, _, _, _, ss = run_evaluate_diet(house, Time.minute)

        Assert.equals(ss[SanitySummand.disliked_taste], -4,
            "dominant taste being disliked should give -4 sanity")
        Assert.is_nil(ss[SanitySummand.favorite_taste],
            "favorite taste sanity should not be set when no favored food is in the diet")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << mixed fill step >>

-- Ember mixed, minimum_food_count = 3.
-- test-food-fruity-carb (fruity/carb) + test-food-neutral-protein-fat (neutral/protein+fat) → 2 foods, all tags covered.
-- test-food-neutral-carb (neutral/carb, different group) available as fill candidate.
-- Fill step adds test-food-neutral-carb → 3 groups = minimum_food_count → variety = 0.

Tirislib.Testing.add_test_case(
    "evaluate_diet fill step brings mixed eater to minimum_food_count",
    "integration|integration.inhabitants",
    function()
        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.ember, 5)
        local inventory = Inventories.get_chest_inventory(house)
        inventory.insert {name = "test-food-fruity-carb", count = 100}        -- favored, group test-food-a
        inventory.insert {name = "test-food-neutral-protein-fat", count = 100} -- neutral, group test-food-c
        inventory.insert {name = "test-food-neutral-carb", count = 100}        -- neutral, group test-food-d

        local hs, _, _, _, _ = run_evaluate_diet(house, Time.minute)

        Assert.is_nil(hs[HappinessSummand.food_variety],
            "fill step should bring diet to minimum_food_count, leaving variety summand unset")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "evaluate_diet applies flat happiness malus per food group below minimum_food_count",
    "integration|integration.inhabitants",
    function()
        -- Ember mixed, minimum_food_count = 3. Only test-food-fruity-carb (1 group) available.
        -- variety = 1 - 3 = -2; malus = 2 * ember.happiness_per_missing_food.
        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.ember, 5)
        Inventories.get_chest_inventory(house).insert {name = "test-food-fruity-carb", count = 100}

        local hs, _, _, _, _ = run_evaluate_diet(house, Time.minute)

        Assert.equals(hs[HappinessSummand.food_variety], 2 * ember.happiness_per_missing_food,
            "variety malus should be (minimum_food_count - groups) * happiness_per_missing_food")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << food distress fallback >>

-- Clockwork minimalist + test-food-umami-notag (umami = favored, no tags).
-- Primary diet is empty (no tag-covering food). Food is available → distress fallback fires.
-- Fallback: eat all favored → [test-food-umami-notag]. is_distress = true.

Tirislib.Testing.add_test_case(
    "evaluate_diet applies food_distress factor when minimalist can only find no-tag food",
    "integration|integration.inhabitants",
    function()
        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.clockwork, 5)
        Inventories.get_chest_inventory(house).insert {name = "test-food-umami-notag", count = 100}

        local hs, hf, _, _, _ = run_evaluate_diet(house, Time.minute)

        Assert.equals(hf[HappinessFactor.food_distress], clockwork.food_distress_factor,
            "food_distress factor should be applied when fallback diet is used")
        Assert.is_nil(hs[HappinessSummand.nutrition_tags],
            "nutrition_tags happiness should be suppressed in distress state")
        Assert.is_nil(hs[HappinessSummand.taste],
            "taste happiness should be suppressed in distress state")
        Assert.is_nil(hf[HappinessFactor.hunger],
            "hunger factor should not fire when fallback diet provides food")
    end,
    setup,
    teardown
)

-- Orchid foodie + test-food-salty-protein (salty = disliked for Orchid). No favored or neutral food.
-- Primary diet is empty. Fallback foodie: eat all disliked → [test-food-salty-protein]. is_distress = true.

Tirislib.Testing.add_test_case(
    "evaluate_diet applies food_distress factor when foodie can only find disliked food",
    "integration|integration.inhabitants",
    function()
        local house = Helpers.create_inhabited_house(test_surface, {0, 0}, Type.orchid, 5)
        Inventories.get_chest_inventory(house).insert {name = "test-food-salty-protein", count = 100}

        local hs, hf, _, _, _ = run_evaluate_diet(house, Time.minute)

        Assert.equals(hf[HappinessFactor.food_distress], orchid.food_distress_factor,
            "food_distress factor should be applied for foodie in fallback")
        Assert.is_nil(hs[HappinessSummand.disliked_food],
            "disliked_food happiness summand should be suppressed in distress state")
        Assert.is_nil(hf[HappinessFactor.hunger],
            "hunger factor should not fire when fallback provides food")
    end,
    setup,
    teardown
)
