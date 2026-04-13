local EatingBehavior = require("enums.eating-behavior")
local EK = require("enums.entry-key")
local HappinessFactor = require("enums.happiness-factor")
local HappinessSummand = require("enums.happiness-summand")
local HealthFactor = require("enums.health-factor")
local HealthSummand = require("enums.health-summand")
local RenderingType = require("enums.rendering-type")
local SanitySummand = require("enums.sanity-summand")
local Type = require("enums.type")
local WarningType = require("enums.warning-type")

local Biology = require("constants.biology")
local Castes = require("constants.castes")
local Food = require("constants.food")

local castes = Castes.values
local food_values = Food.values
local required_nutrition_tags = Food.required_nutrition_tags
local nutrition_tag_effects = Food.nutrition_tag_effects
local log_fluid = Statistics.log_fluid
local assembling_machine_output = defines.inventory.crafter_output

---------------------------------------------------------------------------------------------------
-- << diet >>

--- Returns a list of inventories relevant to the diet: house chest + active neighboring markets
--- + output inventories of active neighboring kitchens.
local function get_food_providers(entry)
    local inventories = {Inventories.get_chest_inventory(entry)}

    for _, market_entry in Neighborhood.iterate_type(entry, Type.market) do
        if Entity.is_active(market_entry) then
            inventories[#inventories + 1] = Inventories.get_chest_inventory(market_entry)
        end
    end

    for _, kitchen_entry in Neighborhood.iterate_type(entry, Type.kitchen_for_all) do
        if Entity.is_active(kitchen_entry) then
            inventories[#inventories + 1] = kitchen_entry[EK.entity].get_inventory(assembling_machine_output)
        end
    end

    return inventories
end

--- Returns a list of food item names available in the given inventories.
local function get_available_foods(inventories)
    local combined = Inventories.get_combined_contents(inventories)
    local foods = {}

    for item_name in pairs(combined) do
        if food_values[item_name] then
            foods[#foods + 1] = item_name
        end
    end

    return foods
end

--- Classifies available food names into three lists by taste relation to the caste.
--- @return string[] favored, string[] neutral, string[] disliked
local function classify_by_taste(available_foods, caste)
    local favored = {}
    local neutral = {}
    local disliked = {}
    local favored_taste = caste.favored_taste
    local least_favored_taste = caste.least_favored_taste

    for _, item_name in pairs(available_foods) do
        local taste = food_values[item_name].taste_category
        if taste == favored_taste then
            favored[#favored + 1] = item_name
        elseif taste == least_favored_taste then
            disliked[#disliked + 1] = item_name
        else
            neutral[#neutral + 1] = item_name
        end
    end

    return favored, neutral, disliked
end

--- Updates covered_tags in place based on the nutrition_tags of all foods in the diet.
local function update_covered_tags(diet, covered_tags)
    for _, item_name in pairs(diet) do
        for tag in pairs(food_values[item_name].nutrition_tags) do
            covered_tags[tag] = true
        end
    end
end

--- Returns true if all required nutrition tags are covered.
local function all_tags_covered(covered_tags)
    for _, tag in pairs(required_nutrition_tags) do
        if not covered_tags[tag] then return false end
    end

    return true
end

--- Iterates food_list and adds each food to diet if it covers at least one uncovered tag.
--- Updates covered_tags in place. Returns the number of foods added.
local function add_tag_covering_foods(food_list, diet, covered_tags)
    local added = 0
    for _, item_name in pairs(food_list) do
        if all_tags_covered(covered_tags) then break end
        local food = food_values[item_name]
        for tag in pairs(food.nutrition_tags) do
            if not covered_tags[tag] then
                diet[#diet + 1] = item_name
                -- mark all of this food's tags as covered
                for t in pairs(food.nutrition_tags) do
                    covered_tags[t] = true
                end
                added = added + 1
                break
            end
        end
    end
    return added
end

--- Minimalist: covers nutrition tags using favored foods first, then neutral, then disliked as a
--- last resort. No fill step — eating only what is nutritionally necessary.
--- @return string[] diet, integer disliked_count, table covered_tags
local function build_diet_minimalist(favored, neutral, disliked)
    local diet = {}
    local covered_tags = {}

    add_tag_covering_foods(favored, diet, covered_tags)
    add_tag_covering_foods(neutral, diet, covered_tags)
    local disliked_count = add_tag_covering_foods(disliked, diet, covered_tags)

    return diet, disliked_count, covered_tags
end

--- Mixed: includes all favored foods, covers missing tags from neutral then disliked,
--- then fills to minimum_food_count with the most appealing neutral foods not yet in the diet.
--- @return string[] diet, integer disliked_count, table covered_tags
local function build_diet_mixed(favored, neutral, disliked, minimum_food_count)
    local diet = {}
    local covered_tags = {}

    for _, item_name in pairs(favored) do
        diet[#diet + 1] = item_name
    end
    update_covered_tags(diet, covered_tags)

    add_tag_covering_foods(neutral, diet, covered_tags)
    local disliked_count = add_tag_covering_foods(disliked, diet, covered_tags)

    if #diet < minimum_food_count then
        local diet_set = Tirislib.Tables.to_lookup(diet)
        local candidates = {}
        for _, item_name in pairs(neutral) do
            if not diet_set[item_name] then
                candidates[#candidates + 1] = item_name
            end
        end
        table.sort(candidates, function(a, b)
            return food_values[a].appeal > food_values[b].appeal
        end)
        for _, item_name in pairs(candidates) do
            if #diet >= minimum_food_count then break end
            diet[#diet + 1] = item_name
        end
    end

    return diet, disliked_count, covered_tags
end

--- Foodie: includes all favored and neutral foods unconditionally; never includes disliked.
--- @return string[] diet, integer disliked_count, table covered_tags
local function build_diet_foodie(favored, neutral)
    local diet = {}
    local covered_tags = {}

    for _, item_name in pairs(favored) do
        diet[#diet + 1] = item_name
    end
    for _, item_name in pairs(neutral) do
        diet[#diet + 1] = item_name
    end
    update_covered_tags(diet, covered_tags)

    return diet, 0, covered_tags
end

--- Constructs the diet for the given eating behavior.
--- @param behavior EatingBehavior
--- @param favored string[] foods with favored taste
--- @param neutral string[] foods with neutral taste
--- @param disliked string[] foods with disliked taste
--- @param minimum_food_count integer
--- @return string[] diet, integer disliked_count, table covered_tags
local function build_diet(behavior, favored, neutral, disliked, minimum_food_count)
    if behavior == EatingBehavior.minimalist then
        return build_diet_minimalist(favored, neutral, disliked)
    elseif behavior == EatingBehavior.mixed then
        return build_diet_mixed(favored, neutral, disliked, minimum_food_count)
    elseif behavior == EatingBehavior.foodie then
        return build_diet_foodie(favored, neutral)
    else
        error("Unknown EatingBehavior specified")
    end
end

---------------------------------------------------------------------------------------------------
-- << fallback diet (food distress) >>

--- Fallback for minimalists: steps through taste tiers and returns the first non-empty one.
local function build_fallback_diet_minimalist(favored, neutral, disliked)
    if #favored > 0 then return favored end
    if #neutral > 0 then return neutral end
    return disliked
end

--- Fallback for mixed eaters: picks disliked foods up to minimum_food_count, by descending appeal.
local function build_fallback_diet_mixed(disliked, minimum_food_count)
    local sorted = {}
    for _, item_name in pairs(disliked) do
        sorted[#sorted + 1] = item_name
    end
    table.sort(sorted, function(a, b)
        return food_values[a].appeal > food_values[b].appeal
    end)
    local diet = {}
    for _, item_name in pairs(sorted) do
        if #diet >= minimum_food_count then break end
        diet[#diet + 1] = item_name
    end
    return diet
end

--- Fallback for foodies: includes all disliked foods.
local function build_fallback_diet_foodie(disliked)
    return disliked
end

--- Builds a fallback diet when the primary behavior produced an empty result but food is available.
--- @return string[] diet
local function build_fallback_diet(behavior, favored, neutral, disliked, minimum_food_count)
    if behavior == EatingBehavior.minimalist then
        return build_fallback_diet_minimalist(favored, neutral, disliked)
    elseif behavior == EatingBehavior.mixed then
        return build_fallback_diet_mixed(disliked, minimum_food_count)
    elseif behavior == EatingBehavior.foodie then
        return build_fallback_diet_foodie(disliked)
    else
        error("Unknown EatingBehavior specified")
    end
end

--- Applies happiness, health, and sanity effects from the diet to the entry's summand tables.
--- When is_distress is true, per-food taste effects and variety/nutrition_tags bonuses are
--- suppressed; only the distress factor, appeal, and health effects apply.
local function add_diet_effects(entry, diet, caste, disliked_count, covered_tags, is_distress)
    local happiness = entry[EK.happiness_summands]
    local happiness_factors = entry[EK.happiness_factors]
    local health = entry[EK.health_summands]
    local health_factors = entry[EK.health_factors]
    local sanity = entry[EK.sanity_summands]

    if #diet == 0 then
        happiness_factors[HappinessFactor.hunger] = Biology.starvation.happiness_factor
        health_factors[HealthFactor.hunger] = Biology.starvation.health_factor
        if entry[EK.inhabitants] > 0 then
            Communication.warning(WarningType.no_food, entry)
        end
        return
    end

    local favored_taste = caste.favored_taste
    local least_favored_taste = caste.least_favored_taste
    local intrinsic_healthiness = 0
    local favored_food_count = 0
    local taste_counts = {}
    local appeals = {}
    local groups = {}

    for _, item_name in pairs(diet) do
        local food = food_values[item_name]
        intrinsic_healthiness = intrinsic_healthiness + food.healthiness
        local taste = food.taste_category
        taste_counts[taste] = (taste_counts[taste] or 0) + 1
        appeals[#appeals + 1] = food.appeal
        groups[food.group] = true
        if taste == favored_taste then
            favored_food_count = favored_food_count + 1
        end
    end

    intrinsic_healthiness = intrinsic_healthiness / #diet

    -- top-3 appeal average
    table.sort(appeals, function(a, b) return a > b end)
    local top_appeal_sum = 0
    local top_count = math.min(3, #appeals)
    for i = 1, top_count do
        top_appeal_sum = top_appeal_sum + appeals[i]
    end
    local top_appeal = top_appeal_sum / top_count

    -- dominant taste
    local dominant_taste, dominant_count = nil, 0
    for taste, count in pairs(taste_counts) do
        if count > dominant_count then
            dominant_taste = taste
            dominant_count = count
        end
    end

    -- variety relative to minimum_food_count
    local variety = Tirislib.Tables.count(groups) - caste.minimum_food_count

    -- happiness
    happiness[HappinessSummand.food_appeal] = top_appeal
    if is_distress then
        happiness_factors[HappinessFactor.food_distress] = caste.food_distress_factor
        Communication.warning(WarningType.food_distress, entry)
    else
        if favored_food_count > 0 and caste.happiness_per_favored_food ~= 0 then
            happiness[HappinessSummand.taste] = favored_food_count * caste.happiness_per_favored_food
        end
        if disliked_count > 0 and caste.happiness_per_disliked_food ~= 0 then
            happiness[HappinessSummand.disliked_food] = disliked_count * caste.happiness_per_disliked_food
        end
        if variety > 0 then
            happiness[HappinessSummand.food_variety] = variety * 0.5
        elseif variety < 0 then
            happiness[HappinessSummand.food_variety] = (-variety) * caste.happiness_per_missing_food
        end
        if caste.happiness_per_nutrition_tag ~= 0 then
            local nutrition_happiness = 0
            for _, tag in pairs(required_nutrition_tags) do
                if covered_tags[tag] then
                    nutrition_happiness = nutrition_happiness + caste.happiness_per_nutrition_tag
                end
            end
            if nutrition_happiness ~= 0 then
                happiness[HappinessSummand.nutrition_tags] = nutrition_happiness
            end
        end
    end

    -- health
    local nutrients_health = 0
    for _, tag in pairs(required_nutrition_tags) do
        local effect = nutrition_tag_effects[tag]
        if covered_tags[tag] then
            nutrients_health = nutrients_health + effect.bonus
        elseif effect.malus ~= 0 then
            nutrients_health = nutrients_health + effect.malus
        end
    end
    if nutrients_health ~= 0 then
        health[HealthSummand.nutrients] = nutrients_health
    end
    health[HealthSummand.food] = intrinsic_healthiness

    -- sanity
    sanity[SanitySummand.taste] = top_appeal * 0.5
    if favored_food_count > 0 then
        sanity[SanitySummand.favorite_taste] = 4
    end
    if dominant_taste == least_favored_taste then
        sanity[SanitySummand.disliked_taste] = -4
    end
end

--- Returns diet info for the given entry for GUI display. No side effects on the entry.
--- @param entry Entry
--- @return table {diet, is_distress, no_food, covered_tags, favored_set, disliked_set}
function Inhabitants.get_diet_info(entry)
    local caste = castes[entry[EK.type]]
    local inventories = get_food_providers(entry)
    local available_foods = get_available_foods(inventories)
    local favored, neutral, disliked = classify_by_taste(available_foods, caste)

    local diet, _, covered_tags = build_diet(
        caste.eating_behavior, favored, neutral, disliked, caste.minimum_food_count)

    local is_distress = false
    if #diet == 0 and #available_foods > 0 then
        diet = build_fallback_diet(caste.eating_behavior, favored, neutral, disliked, caste.minimum_food_count)
        covered_tags = {}
        update_covered_tags(diet, covered_tags)
        is_distress = true
    end

    local favored_set = {}
    for _, item_name in pairs(favored) do favored_set[item_name] = true end
    local disliked_set = {}
    for _, item_name in pairs(disliked) do disliked_set[item_name] = true end

    return {
        diet = diet,
        is_distress = is_distress,
        no_food = (#diet == 0),
        covered_tags = covered_tags,
        favored_set = favored_set,
        disliked_set = disliked_set,
    }
end

--- Evaluates the available diet for the given housing entry, constructs the diet based on
--- the caste's eating behavior, consumes the needed calories, and applies all food effects.
--- @param entry Entry
--- @param delta_ticks integer
function Inhabitants.evaluate_diet(entry, delta_ticks)
    local caste = castes[entry[EK.type]]
    local inventories = get_food_providers(entry)
    local available_foods = get_available_foods(inventories)
    local favored, neutral, disliked = classify_by_taste(available_foods, caste)

    local diet, disliked_count, covered_tags = build_diet(
        caste.eating_behavior, favored, neutral, disliked, caste.minimum_food_count)

    local is_distress = false
    if #diet == 0 and #available_foods > 0 then
        diet = build_fallback_diet(caste.eating_behavior, favored, neutral, disliked, caste.minimum_food_count)
        covered_tags = {}
        update_covered_tags(diet, covered_tags)
        disliked_count = 0
        is_distress = true
    end

    if #diet > 0 then
        local to_consume = caste.calorific_demand * delta_ticks * entry[EK.inhabitants]
        local satisfaction = Inventories.consume_food(entry, inventories, to_consume, diet)

        Subentities.remove_common_sprite(entry, RenderingType.food_warning)
        entry[EK.has_food] = satisfaction >= 0.9
    else
        Subentities.add_common_sprite(entry, RenderingType.food_warning)
        entry[EK.has_food] = false
    end

    add_diet_effects(entry, diet, caste, disliked_count, covered_tags, is_distress)
end

---------------------------------------------------------------------------------------------------
-- << water >>

--- Consumes the given amount of drinking water from the given distributer entities. Assumes the distributers do have water.
--- @param distributers Entry[]
--- @param amount number
--- @return number satisfaction a factor from 0 to 1 how much of the given amound was actually consumed
--- @return number quality the average quality of the consumes drinking water
local function consume_water(distributers, amount)
    local to_consume = amount
    local quality = 0

    for _, distributer in pairs(distributers) do
        local water_name = distributer[EK.water_name]

        local consumed = distributer[EK.entity].remove_fluid {name = water_name, amount = to_consume}
        log_fluid(water_name, -consumed)
        quality = quality + consumed * distributer[EK.water_quality]
        to_consume = to_consume - consumed

        if to_consume < 0.0001 then
            break
        end
    end

    return (amount - to_consume) / amount, quality / amount
end

--- Evaluates if the house has access to drinking water, consumes it, and evaluates the effects.
--- @param entry Entry
--- @param delta_ticks number
--- @param happiness_factors table
--- @param health_factors table
--- @param health_summands table
function Inhabitants.evaluate_water(entry, delta_ticks, happiness_factors, health_factors, health_summands)
    local distributers = {}

    -- find the available water distributers, filter out the empty ones
    for _, distributer in Neighborhood.iterate_type(entry, Type.water_distributer) do
        if distributer[EK.water_name] ~= nil then
            distributers[#distributers + 1] = distributer
        end
    end

    table.sort(distributers, function(a, b) return a[EK.water_quality] > b[EK.water_quality] end)

    local water_to_consume = castes[entry[EK.type]].water_demand * entry[EK.inhabitants] * delta_ticks
    local satisfaction, quality

    if water_to_consume > 0 then
        satisfaction, quality = consume_water(distributers, water_to_consume)

        if satisfaction < 0.1 then
            Subentities.add_common_sprite(entry, RenderingType.water_warning)
            Communication.warning(WarningType.no_water, entry)
        else
            Subentities.remove_common_sprite(entry, RenderingType.water_warning)
        end
    else
        -- annoying edge case of no inhabitants
        -- test if there is at least one distributer with water
        local probe = distributers[1]
        if probe and probe[EK.water_name] then
            satisfaction = 1
            quality = probe[EK.water_quality]

            Subentities.remove_common_sprite(entry, RenderingType.water_warning)
        else
            satisfaction = 0
            quality = 0

            Subentities.add_common_sprite(entry, RenderingType.water_warning)
        end
    end

    local has_water = satisfaction > 0
    if not has_water then
        happiness_factors[HappinessFactor.thirst] = Biology.dehydration.happiness_factor
        health_factors[HealthFactor.thirst] = Biology.dehydration.health_factor
    end
    if quality ~= 0 then
        health_summands[HealthSummand.water] = quality
    end

    entry[EK.has_water] = satisfaction >= 0.9
end
