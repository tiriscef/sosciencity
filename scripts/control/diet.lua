Diet = {}

---------------------------------------------------------------------------------------------------
-- << diet functions >>
-- returns a list of all inventories whose food is relevant to the diet
-- markets act like additional food inventories
local function get_food_inventories(entry)
    local inventories = {entry.entity.get_inventory(defines.inventory.chest)}

    for _, market in pairs(Neighborhood.get_by_type(entry, TYPE_MARKET)) do
        table.insert(inventories, market.get_inventory(defines.inventory.chest))
    end

    return inventories
end

-- returns a table with every available food item type as keys
local function get_diet(inventories)
    local diet = {}

    for _, inventory in pairs(inventories) do
        local inventory_size = #inventory

        for i = 1, inventory_size do
            local slot = inventory[i]
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

local function get_protein_healthiness(percentage)
    -- this is a cubic spline through the following points:
    -- (0, -1), (0.1, -0.5), (0.2, 1), (0.3, 0), (0.5, -1)
    if percentage < 0.1 then
        return 447.67 * percentage ^ 3 + 0.5232 * percentage - 1
    elseif percentage < 0.2 then
        return -1238.37 * percentage ^ 3 + 505.81 * percentage ^ 2 - 50.05 * percentage + 0.69
    elseif percentage < 0.3 then
        return 1005.81 * percentage ^ 3 - 840.7 * percentage ^ 2 + 219.24 * percentage - 17.27
    elseif percentage < 0.5 then
        return -107.56 * percentage ^ 3 + 161.34 * percentage ^ 2 - 81.37 * percentage + 12.79
    else
        return -1
    end
end

local function get_fat_ratio_healthiness(ratio)
    -- this is a cubic spline through the following points:
    -- (0, -1), (0.375, 1), (0.75, -1)
    if ratio < 0.375 then
        return -18.96 * ratio ^ 3 + 8 * ratio - 1
    elseif ratio < 0.75 then
        return 18.96 * ratio ^ 3 - 42.67 * ratio ^ 2 + 24 * ratio - 3
    else
        return -1
    end
end

-- returns a numerical healthiness value in the range 0 to 1 for the given nutrient combination
-- and adds flags for extreme values.
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

    return 0.25 *
        (2 + get_fat_ratio_healthiness(fat_to_carbohydrates_ratio) + get_protein_healthiness(protein_percentage))
end

local function get_diet_effects(diet, caste_type)
    -- calculate features
    local count = 0
    local intrinsic_healthiness = 0
    local fat = 0
    local carbohydrates = 0
    local proteins = 0
    local taste_quality = 0
    local taste_category_counts = {
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
    local caste = Caste(caste_type)

    for item_name, _ in pairs(diet) do
        count = count + 1

        local values = Food.values[item_name]

        intrinsic_healthiness = intrinsic_healthiness + values.healthiness
        fat = fat + values.fat
        carbohydrates = carbohydrates + values.carbohydrates
        proteins = proteins + values.proteins
        taste_quality = taste_quality + values.taste_quality
        taste_category_counts[values.taste_category] = taste_category_counts[values.taste_category] + 1
        luxury = luxury + values.luxury
    end

    local dominant_taste = TASTE_BITTER
    for current_taste_category, current_count in pairs(taste_category_counts) do
        if current_count > taste_category_counts[dominant_taste] then
            dominant_taste = current_taste_category
        end
    end

    intrinsic_healthiness = intrinsic_healthiness / count
    taste_quality = taste_quality / count
    luxury = luxury / count

    -- evaluate features
    local mental_healthiness = 1
    -- TODO scale
    local healthiness =
        0.5 * (intrinsic_healthiness + get_nutrient_healthiness(fat, carbohydrates, proteins, flags))

    local satisfaction = (1 - 0.5 * caste.desire_for_luxury) * taste_quality + 0.5 * caste.desire_for_luxury * luxury

    if count == 1 or taste_category_counts[TASTE_NEUTRAL] == count or dominant_taste == caste.least_favored_taste then
        mental_healthiness = 0
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

-- Tries to consume the given amount of calories. Returns the percentage of the amount that
-- was consumed
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
    diet_effects.healthiness_dietary = diet_effects.healthiness_dietary * percentage

    if percentage < 0.5 then
        diet_effects.healthiness_dietary = 0

        table.insert(diet_effects.flags, {FLAG_HUNGER})
    end
end

-- Assumes the entity is a housing entity
function Diet.evaluate(entry, delta_ticks)
    local inventories = get_food_inventories(entry)
    local diet = get_diet(inventories)

    local diet_effects = get_diet_effects(diet, entry.type)

    local to_consume = Caste(entry.type).calorific_demand * delta_ticks * entry.inhabitants
    local hunger_satisfaction = consume_food(inventories, to_consume, diet, diet_effects)
    apply_hunger_effects(hunger_satisfaction, diet_effects)

    return diet_effects
end

return Diet
