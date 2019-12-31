Diet = {}

---------------------------------------------------------------------------------------------------
-- << diet functions >>

local chest = defines.inventory.chest
--- Returns a list of all inventories whose food is relevant to the diet.
--- Markets act like additional food inventories.
local function get_food_inventories(entry)
    local inventories = {entry.entity.get_inventory(chest)}
    local i = 2

    for _, market_entry in Neighborhood.all_of_type(entry, TYPE_MARKET) do
        inventories[i] = market_entry.entity.get_inventory(chest)
        i = i + 1
    end

    return inventories
end

--- Returns a table with every available food item type as keys.
local function get_diet(inventories)
    local diet = {}

    for i = 1, #inventories do
        local inventory = inventories[i]

        for j = 1, #inventory do
            local slot = inventory[j]
            if slot.valid_for_read then -- check if the slot has an item in it
                local item_name = slot.name
                if Food[item_name] and not diet[item_name] then
                    diet[item_name] = item_name
                end
            end
        end
    end

    return diet
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

--- Returns a numerical healthiness value in the range 0 to 10 for the given nutrient combination
--- and adds flags for extreme values.
local function get_nutrient_healthiness(fat, carbohydrates, proteins, flags)
    -- optimal diet consists of 30% fat, 50% carbohydrates and 20% proteins
    -- we focus on a reasonable amount of protein
    local protein_percentage = proteins / (fat + carbohydrates + proteins)
    if protein_percentage < 0.1 then
        table.insert(flags, {FLAG_LOW_PROTEIN, protein_percentage})
    elseif protein_percentage > 0.4 then
        table.insert(flags, {FLAG_HIGH_PROTEIN, protein_percentage})
    end

    -- and the fat to carbohydrates ratio (optimum is 0.375)
    local fat_to_carbohydrates_ratio = fat / (fat + carbohydrates)
    if fat_to_carbohydrates_ratio > 0.5 then
        table.insert(flags, {FLAG_HIGH_FAT, fat_to_carbohydrates_ratio})
    elseif fat_to_carbohydrates_ratio < 0.1 then
        table.insert(flags, {FLAG_HIGH_CARBOHYDRATES, fat_to_carbohydrates_ratio})
    end

    return get_fat_ratio_healthiness(fat_to_carbohydrates_ratio) + get_protein_healthiness(protein_percentage)
end

local NO_FOOD_EFFECT = {
    healthiness = 0,
    mental_healthiness = 5,
    satisfaction = 0,
    count = 0,
    flags = {}
}

local function get_diet_effects(diet, caste)
    -- calculate features
    local count = 0
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
    local flags = {}
    local favorite_taste = caste.favorite_taste
    local least_favored_taste = caste.least_favored_taste

    for item_name, _ in pairs(diet) do
        count = count + 1

        local food = Food.values[item_name]
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

    -- special case no food at all
    if count == 0 then
        return NO_FOOD_EFFECT
    end

    -- determine dominant taste
    local dominant_taste = TASTE_BITTER
    for current_taste_category, current_count in pairs(taste_counts) do
        if current_count > taste_counts[dominant_taste] then
            dominant_taste = current_taste_category
        end
    end

    intrinsic_healthiness = intrinsic_healthiness / count
    taste_quality = taste_quality / count
    luxury = luxury / count

    -- evaluate features
    local healthiness = 0.5 * (intrinsic_healthiness + get_nutrient_healthiness(fat, carbohydrates, proteins, flags))
    local satisfaction = (1 - caste.desire_for_luxury) * taste_quality + caste.desire_for_luxury * luxury

    local mental_healthiness = 0
    if dominant_taste == favorite_taste then
        mental_healthiness = 5
    end
    if
        count == 1 or taste_counts[dominant_taste] == count or dominant_taste == TASTE_NEUTRAL or
            dominant_taste == least_favored_taste
     then
        mental_healthiness = -5
    end

    return {
        healthiness = healthiness,
        mental_healthiness = mental_healthiness,
        satisfaction = satisfaction,
        count = count,
        flags = flags
    }
end

local function consume_specific_food(inventories, amount, item_name)
    local to_consume = amount

    for _, inventory in pairs(inventories) do
        local inventory_size = #inventory

        for i = 1, inventory_size do
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

--- Tries to consume the given amount of calories. Returns the percentage of the amount that
--- was consumed
local function consume_food(inventories, amount, diet, diet_effects)
    local count = diet_effects.count
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

local function apply_hunger_effects(percentage, diet_effects)
    diet_effects.satisfaction = diet_effects.satisfaction * percentage
    diet_effects.healthiness = diet_effects.healthiness * percentage

    if percentage < 0.5 then
        diet_effects.healthiness = 0

        table.insert(diet_effects.flags, {FLAG_HUNGER})
    end
end

local castes = Caste.values

--- Evaluates the available diet for the given housing entry and consumes the needed calories.
function Diet.evaluate(entry, delta_ticks)
    local caste = castes[entry.type]
    local inventories = get_food_inventories(entry)
    local diet = get_diet(inventories)

    local diet_effects = get_diet_effects(diet, caste)

    if diet_effects.count > 0 then
        local to_consume = caste.calorific_demand * delta_ticks * entry.inhabitants
        local hunger_satisfaction = consume_food(inventories, to_consume, diet, diet_effects)
        apply_hunger_effects(hunger_satisfaction, diet_effects)
    end

    return diet_effects
end

return Diet
