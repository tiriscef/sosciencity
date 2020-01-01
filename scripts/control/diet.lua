Diet = {}

local food_values = Food.values
---------------------------------------------------------------------------------------------------
-- << diet functions >>

local chest = defines.inventory.chest
--- Returns a list of all inventories whose food is relevant to the diet.
--- Markets act like additional food inventories.
local function get_food_inventories(entry)
    local inventories = {entry[ENTITY].get_inventory(chest)}
    local i = 2

    for _, market_entry in Neighborhood.all_of_type(entry, TYPE_MARKET) do
        inventories[i] = market_entry[ENTITY].get_inventory(chest)
        i = i + 1
    end

    return inventories
end

--- Returns a table with every available food item type as keys.
local function get_diet(inventories)
    local diet = {}
    local count = 0

    for i = 1, #inventories do
        local content = inventories[i].get_contents()

        for item_name, _ in pairs(content) do
            if food_values[item_name] then
                diet[item_name] = item_name
                count = count + 1
            end
        end
    end

    return diet, count
end

--- Table with a healthiness value every 2.5%. Values between that will be interpolated linearly.
local protein_ratio_healthiness_lookup = {
    [00] = 0, -- 0%
    [01] = 0.5,
    [02] = 1,
    [03] = 1.5,
    [04] = 2, -- 10%
    [05] = 3,
    [06] = 4,
    [07] = 5,
    [08] = 6, -- 20% optimum
    [09] = 6,
    [10] = 5,
    [11] = 5,
    [12] = 4, -- 30%
    [13] = 4,
    [14] = 4,
    [15] = 3.5,
    [16] = 3.5, -- 40%
    [17] = 3,
    [18] = 3,
    [19] = 2.5,
    [20] = 2.5, -- 50%
    [21] = 2,
    [22] = 1.5,
    [23] = 1,
    [24] = 0.75, -- 60%
    [25] = 0.5,
    [26] = 0.25,
    [27] = 0,
    [28] = 0, -- 70%
    [29] = 0,
    [30] = 0,
    [31] = 0,
    [32] = 0, -- 80%
    [33] = 0,
    [34] = 0,
    [35] = 0,
    [36] = 0, -- 90%
    [37] = 0,
    [38] = 0,
    [39] = 0,
    [40] = 0 -- 100%
}
--- Returns a numerical healthiness value in the range 0 to 6 for the given protein ratio.
local function get_protein_healthiness(ratio)
    local index = math.floor(ratio * 40)
    local percentage_lower_value = (ratio - 0.025 * index) * 40
    return percentage_lower_value * protein_ratio_healthiness_lookup[index] +
        (1 - percentage_lower_value) * protein_ratio_healthiness_lookup[index + 1]
end

--- Table with a healthiness value every 2.5%. Values between that will be interpolated linearly.
local fat_ratio_healthiness_lookup = {
    [00] = 0, -- 0%
    [01] = 0,
    [02] = 0,
    [03] = 0.5,
    [04] = 1, -- 10%
    [05] = 1,
    [06] = 1,
    [07] = 1.5,
    [08] = 2, -- 20%
    [09] = 2.5,
    [10] = 3,
    [11] = 3,
    [12] = 3.5, -- 30%
    [13] = 3.5,
    [14] = 4,
    [15] = 4, -- optimum
    [16] = 4, -- 40%
    [17] = 4,
    [18] = 3.5,
    [19] = 3.5,
    [20] = 3, -- 50%
    [21] = 3,
    [22] = 2.5,
    [23] = 2.5,
    [24] = 2, -- 60%
    [25] = 2,
    [26] = 1.5,
    [27] = 1.5,
    [28] = 1, -- 70%
    [29] = 1,
    [30] = 0.75,
    [31] = 0.5,
    [32] = 0.25, -- 80%
    [33] = 0,
    [34] = 0,
    [35] = 0,
    [36] = 0, -- 90%
    [37] = 0,
    [38] = 0,
    [39] = 0,
    [40] = 0 -- 100%
}
--- Returns a numerical healthiness value in the range 0 to 4 for the given fat ratio.
local function get_fat_ratio_healthiness(ratio)
    local index = math.floor(ratio * 40)
    local percentage_lower_value = (ratio - 0.025 * index) * 40
    return percentage_lower_value * fat_ratio_healthiness_lookup[index] +
        (1 - percentage_lower_value) * fat_ratio_healthiness_lookup[index + 1]
end

--- Returns a numerical healthiness value in the range 0 to 10 for the given nutrient combination.
local function get_nutrient_healthiness(fat, carbohydrates, proteins)
    -- optimal diet consists of 30% fat, 50% carbohydrates and 20% proteins
    -- we focus on a reasonable amount of protein
    local protein_percentage = proteins / (fat + carbohydrates + proteins)

    -- and the fat to carbohydrates ratio (optimum is 0.375)
    local fat_to_carbohydrates_ratio = fat / (fat + carbohydrates)

    return get_fat_ratio_healthiness(fat_to_carbohydrates_ratio) + get_protein_healthiness(protein_percentage)
end

--- Consumes calories of the given food type in the given inventories. Returns the amount of consumed calories.
local function consume_specific_food(inventories, amount, item_name)
    local to_consume = amount

    for _, inventory in pairs(inventories) do
        for i = 1, #inventory do
            local slot = inventory[i]
            if slot.valid_for_read then -- check if the slot has an item in it
                if slot.name == item_name then
                    to_consume = to_consume - slot.drain_durability(to_consume)
                    if to_consume < 0.001 then
                        return amount -- everything was consumed
                    end
                end
            end
        end
    end

    return amount - to_consume
end

--- Tries to consume the given amount of calories. Returns the percentage of the amount that was consumed.
local function consume_food(inventories, amount, diet, count)
    local items = Tirislib_Tables.get_keyset(diet)
    local to_consume = amount
    Tirislib_Tables.shuffle(items)

    for i = 1, count do
        to_consume = to_consume - consume_specific_food(inventories, to_consume, items[i])
        if to_consume < 0.001 then
            return 1 -- 100% was consumed
        end
    end

    return (amount - to_consume) / amount
end

local function add_diet_effects(entry, diet, caste, count, hunger_satisfaction)
    local happiness = entry[HAPPINESS_FACTORS]
    local health = entry[HEALTH_FACTORS]
    local mental_health = entry[MENTAL_HEALTH_FACTORS]

    if hunger_satisfaction < 0.5 then
        happiness[HAPPINESS_HUNGER] = -10
        health[HEALTH_HUNGER] = -10
        mental_health[MENTAL_HEALTH_HUNGER] = -5
    end

    -- handle the annoying edge case of no food at all
    if count == 0 then
        return
    end

    -- calculate features
    local intrinsic_healthiness = 0
    local fat = 0
    local carbohydrates = 0
    local proteins = 0
    local taste_quality = 0
    local taste_counts = {
        [TASTE_BITTER] = 0,
        [TASTE_NEUTRAL] = 0,
        [TASTE_SALTY] = 0,
        [TASTE_SOUR] = 0,
        [TASTE_SPICY] = 0,
        [TASTE_SWEET] = 0,
        [TASTE_UMAMI] = 0
    }
    local luxury = 0
    local favorite_taste = caste.favorite_taste
    local least_favored_taste = caste.least_favored_taste

    for item_name, _ in pairs(diet) do
        local food = food_values[item_name]
        local taste = food.taste_category

        fat = fat + food.fat
        carbohydrates = carbohydrates + food.carbohydrates
        proteins = proteins + food.proteins

        intrinsic_healthiness = intrinsic_healthiness + food.healthiness
        taste_counts[taste] = taste_counts[taste] + 1

        if taste == favorite_taste then
            luxury = luxury + food.luxury * 1.33
            taste_quality = taste_quality + food.taste_quality * 1.33
        elseif taste == least_favored_taste then
            luxury = luxury + food.luxury * 0.66
            taste_quality = taste_quality + food.taste_quality * 0.66
        else
            luxury = luxury + food.luxury
            taste_quality = taste_quality + food.taste_quality
        end
    end

    -- means
    intrinsic_healthiness = intrinsic_healthiness / count
    taste_quality = taste_quality / count
    luxury = luxury / count

    -- determine dominant taste
    local dominant_taste = TASTE_BITTER
    for current_taste_category, current_count in pairs(taste_counts) do
        if current_count > taste_counts[dominant_taste] then
            dominant_taste = current_taste_category
        end
    end

    -- add calculation summands
    happiness[HAPPINESS_TASTE] = (1 - caste.desire_for_luxury) * taste_quality * hunger_satisfaction
    happiness[HAPPINESS_FOOD_LUXURY] = caste.desire_for_luxury * luxury * hunger_satisfaction

    health[HEALTH_NUTRIENTS] = get_nutrient_healthiness(fat, carbohydrates, proteins) * hunger_satisfaction
    health[HEALTH_FOOD] = intrinsic_healthiness * hunger_satisfaction

    mental_health[MENTAL_HEALTH_TASTE] = taste_quality * hunger_satisfaction * 0.5
    if dominant_taste == favorite_taste then
        mental_health[MENTAL_HEALTH_FAV_TASTE] = 4
    end
    if dominant_taste == least_favored_taste then
        mental_health[MENTAL_HEALTH_LEAST_FAV_TASTE] = -4
    end
    if count == 1 then
        mental_health[MENTAL_HEALTH_SINGLE_FOOD] = -3
    end
    if taste_counts[dominant_taste] == count then
        mental_health[MENTAL_HEALTH_NO_VARIETY] = -3
    end
    if dominant_taste == TASTE_NEUTRAL then
        mental_health[MENTAL_HEALTH_JUST_NEUTRAL] = -3
    end
end

local castes = Caste.values

--- Evaluates the available diet for the given housing entry and consumes the needed calories.
function Diet.evaluate(entry, delta_ticks)
    local caste = castes[entry[TYPE]]
    local inventories = get_food_inventories(entry)
    local diet, food_count = get_diet(inventories)

    local hunger_satisfaction = 0
    if food_count > 0 then
        local to_consume = caste.calorific_demand * delta_ticks * entry[INHABITANTS]
        hunger_satisfaction = consume_food(inventories, to_consume, diet, food_count)
    end

    add_diet_effects(entry, diet, caste, food_count, hunger_satisfaction)
end

return Diet
