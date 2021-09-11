local EK = require("enums.entry-key")
local Taste = require("enums.taste")
local Type = require("enums.type")

local HappinessSummand = require("enums.happiness-summand")
local HappinessFactor = require("enums.happiness-factor")
local HealthSummand = require("enums.health-summand")
local HealthFactor = require("enums.health-factor")
local SanitySummand = require("enums.sanity-summand")
local SanityFactor = require("enums.sanity-factor")

--- Static class for the manipulation of inventories, items and fluids.
Inventories = {}

--[[
    Data this class stores in global
    --------------------------------
    nothing
]]
-- local often used globals for great performance gains

local sort_by_key = Tirislib_Tables.insertion_sort_by_key

local castes = Castes.values
local garbage_values = ItemConstants.garbage_values

local log_item = Communication.log_item
local log_items = Communication.log_items
local log_fluid = Communication.log_fluid

local all_neighbors_of_type = Neighborhood.all_of_type
local get_neighbors_of_type = Neighborhood.get_by_type

local chest = defines.inventory.chest
local assembler_modules = defines.inventory.assembling_machine_modules

local table_add = Tirislib_Tables.add

local food_values = Food.values

local min = math.min

local is_active

---------------------------------------------------------------------------------------------------
-- << lua state lifecycle stuff >>

local function set_locals()
    is_active = Entity.is_active
end

--- Initialize the register related contents of global.
function Inventories.init()
    set_locals()
end

--- Sets local references during on_load
function Inventories.load()
    set_locals()
end

---------------------------------------------------------------------------------------------------
-- << inventory manipulation >>

--- Returns the chest inventory associated with this entry. Assumes that there is any.
--- @param entry Entry
--- @return Inventory
function Inventories.get_chest_inventory(entry)
    return entry[EK.entity].get_inventory(chest)
end
local get_chest_inventory = Inventories.get_chest_inventory

--- Checks if the given assembler entry has the given module.
function Inventories.assembler_has_module(entity, module_name)
    local inventory = entity.get_inventory(assembler_modules)

    return inventory.get_item_count(module_name) > 0
end

--- Returns a table with the (item, amount)-pairs of the combined contents of the given Inventories.
--- @param inventories table
--- @return table
function Inventories.get_combined_contents(inventories)
    local ret = {}

    for _, inventory in pairs(inventories) do
        table_add(ret, inventory.get_contents())
    end

    return ret
end

--- Saves the contents of this entry's entity.
--- @param entry Entry
function Inventories.cache_contents(entry)
    entry[EK.inventory_contents] = get_chest_inventory(entry).get_contents()
end

--- Tries to insert the given amount of the given item into the inventory and adds the inserted items to the production statistics.
--- Returns the amount that was actually inserted.
--- @param inventory Inventory
--- @param item string
--- @param amount number
--- @param suppress_logging boolean
--- @return integer
function Inventories.try_insert(inventory, item, amount, suppress_logging)
    if amount <= 0 then
        return 0
    end

    local inserted_amount =
        inventory.insert {
        name = item,
        count = amount
    }

    if not suppress_logging then
        log_item(item, inserted_amount)
    end

    return inserted_amount
end
local try_insert = Inventories.try_insert

--- Tries to remove the given amount of the given item from the inventory and adds the removed items to the production statistics.
--- Returns the amount that was actually removed.
--- @param inventory Inventory
--- @param item string
--- @param amount integer
--- @param suppress_logging boolean
--- @return integer
function Inventories.try_remove(inventory, item, amount, suppress_logging)
    if amount <= 0 then
        return 0
    end

    local removed_amount =
        inventory.remove {
        name = item,
        count = amount
    }

    if not suppress_logging then
        log_item(item, -removed_amount)
    end

    return removed_amount
end
local try_remove = Inventories.try_remove

--- Spills the given items around the given entry.
--- @param entry Entry
--- @param item string
--- @param amount integer
--- @param suppress_logging boolean
function Inventories.spill_items(entry, item, amount, suppress_logging)
    if amount <= 0 then
        return
    end

    local entity = entry[EK.entity]
    entity.surface.spill_item_stack(entity.position, {name = item, count = amount})

    if not suppress_logging then
        log_item(item, amount)
    end
end
local spill_items = Inventories.spill_items

--- Spills the given table of items around the given entry.
--- @param entry Entry
--- @param items table
--- @param suppress_logging boolean
function Inventories.spill_item_range(entry, items, suppress_logging)
    local entity = entry[EK.entity]

    local surface = entity.surface
    local position = entity.position

    for item, count in pairs(items) do
        if count > 0 then
            surface.spill_item_stack(position, {name = item, count = count})
        end
    end

    if not suppress_logging then
        log_items(items)
    end
end

--- Tries to remove the given list of items if a full set is available in the inventory.
--- Returns true if it removed the items.
--- @param entry Entry
--- @param items table
--- @param silent boolean
--- @return boolean
function Inventories.try_remove_item_range(entry, items, silent)
    local inventory = get_chest_inventory(entry)
    local contents = inventory.get_contents()

    for name, desired_amount in pairs(items) do
        local available_amount = contents[name] or 0
        if desired_amount > available_amount then
            return false
        end
    end

    for name, desired_amount in pairs(items) do
        inventory.remove {name = name, count = desired_amount}
    end
    if not silent then
        log_items(items)
    end

    return true
end

--- Removes the given items all in all from the given inventories.
--- The items parameter needs to be a table with (item_name, count)-pairs.
--- @param inventories table
--- @param items table
function Inventories.remove_item_range_from_inventory_range(inventories, items)
    for item, count in pairs(items) do
        for _, inventory in pairs(inventories) do
            if count == 0 then
                break
            end

            count = count - inventory.remove {name = item, count = count}
        end
    end
end

---------------------------------------------------------------------------------------------------
-- << Sosciencity specific concepts >>
---------------------------------------------------------------------------------------------------

function Inventories.produce_garbage(entry, item, amount)
    local produced_amount = 0

    -- try to put the garbage into a dumpster
    for _, disposal_entry in all_neighbors_of_type(entry, Type.dumpster) do
        if is_active(disposal_entry) then
            local inventory = get_chest_inventory(disposal_entry)
            produced_amount = produced_amount + try_insert(inventory, item, amount - produced_amount)

            if produced_amount == amount then
                return
            end
        end
    end

    -- try to put the garbage into the house
    local housing_inventory = get_chest_inventory(entry)
    produced_amount = produced_amount + try_insert(housing_inventory, item, amount - produced_amount)

    if produced_amount == amount then
        return
    end

    -- spill the rest
    spill_items(entry, item, amount - produced_amount)
end
local produce_garbage = Inventories.produce_garbage

function Inventories.get_garbage_value(entry)
    local value = 0
    local items = get_chest_inventory(entry).get_contents()

    for name, count in pairs(items) do
        local garbage_multiplier = garbage_values[name]

        if garbage_multiplier then
            value = value + garbage_multiplier * count
        end
    end

    return value
end

function Inventories.output_eggs(entry, count)
    local inserted = 0

    for _, egg_collector in all_neighbors_of_type(entry, Type.egg_collector) do
        if is_active(egg_collector) then
            local inventory = get_chest_inventory(egg_collector)
            inserted = inserted - try_insert(inventory, Biology.egg_fertile, count - inserted)

            if count - inserted < 0.001 then
                return inserted
            end
        end
    end

    local house_inventory = get_chest_inventory(entry)
    local already_inside = house_inventory.get_item_count(Biology.egg_fertile)
    return try_insert(house_inventory, Biology.egg_fertile, min(20 - already_inside, count))
end

local egg_values = Biology.egg_values

function Inventories.hatch_eggs(entry, max_count)
    local eggs = Tirislib_Tables.get_keyset(egg_values)
    Tirislib_Tables.shuffle(eggs)

    local genders = GenderGroup.new()
    local count = 0
    local inventory = get_chest_inventory(entry)

    for _, egg in pairs(eggs) do
        if max_count - count == 0 then
            break
        end
        local consumed = try_remove(inventory, egg, max_count - count)

        count = count + consumed
        GenderGroup.merge(genders, Tirislib_Utils.dice_rolls(egg_values[egg], consumed, 5), true)
    end

    return count, genders
end

function Inventories.count_calories(inventory)
    local ret = 0

    for i = 1, #inventory do
        local stack = inventory[i]
        if stack.valid_for_read then
            local name = stack.name
            local food_details = food_values[name]
            if food_details then
                -- .durability returns the calories of the item at the top of the stack
                -- the rest of the stack is at maximum calories
                ret = ret + (stack.count - 1) * food_details.calories + stack.durability
            end
        end
    end

    return ret
end

function Inventories.consume_calories(inventory, calories)
    local actually_consumed = 0

    for i = 1, #inventory do
        local slot = inventory[i]
        if slot.valid_for_read then
            local name = slot.name
            local food_details = food_values[name]
            if food_details then
                local count_before = slot.count
                actually_consumed = actually_consumed + slot.drain_durability(calories - actually_consumed)

                local items_consumed = slot.valid_for_read and count_before - slot.count or count_before

                if items_consumed > 0 then
                    log_item(name, -items_consumed)
                end

                if calories - actually_consumed < 0.001 then
                    return calories
                end
            end
        end
    end

    return actually_consumed
end

---------------------------------------------------------------------------------------------------
-- << diet functions >>

--- Returns a list of all entries whose inventory contents are relevant to the diet.
--- Markets act like additional food inventories.
local function get_food_providers(entry)
    local inventories = {get_chest_inventory(entry)}

    for _, market_entry in all_neighbors_of_type(entry, Type.market) do
        if is_active(market_entry) then
            inventories[#inventories + 1] = get_chest_inventory(market_entry)
        end
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
local function consume_specific_food(entry, inventories, amount, item_name)
    local to_consume = amount

    for _, inventory in pairs(inventories) do
        local slot = inventory.find_item_stack(item_name)

        while slot do -- find_item_stack returns nil if no stack was found
            local count_before = slot.count
            to_consume = to_consume - slot.drain_durability(to_consume)

            local items_consumed
            -- if the last item of the stack got consumed the slot becomes invalid to read
            if slot.valid_for_read then
                items_consumed = count_before - slot.count
            else
                items_consumed = count_before
            end

            if items_consumed > 0 then
                produce_garbage(entry, "food-leftovers", items_consumed)
                log_item(item_name, -items_consumed)
            end

            if to_consume < 0.001 then
                return amount -- everything was consumed
            end

            slot = inventory.find_item_stack(item_name)
        end
    end

    return amount - to_consume
end

--- Tries to consume the given amount of calories. Returns the percentage of the amount that was consumed.
local function consume_food(entry, inventories, amount, diet, count)
    local items = Tirislib_Tables.get_keyset(diet)
    local to_consume = amount
    Tirislib_Tables.shuffle(items)

    for i = 1, count do
        to_consume = to_consume - consume_specific_food(entry, inventories, to_consume, items[i])
        if to_consume < 0.001 then
            return 1 -- 100% was consumed
        end
    end

    return (amount - to_consume) / amount
end

local taste_category_count = Tirislib_Tables.count(Taste)

local function add_diet_effects(entry, diet, caste, count, hunger_satisfaction)
    local happiness = entry[EK.happiness_summands]
    local happiness_factors = entry[EK.happiness_factors]
    local health = entry[EK.health_summands]
    local health_factors = entry[EK.health_factors]
    local sanity = entry[EK.sanity_summands]

    if hunger_satisfaction < 0.5 then
        happiness_factors[HappinessFactor.hunger] = 0.
        health_factors[HealthFactor.hunger] = 0.
    else
        happiness_factors[HappinessFactor.hunger] = 1.
        health_factors[HealthFactor.hunger] = 1.
    end

    -- handle the annoying edge case of no food at all
    if count == 0 then
        happiness[HappinessSummand.taste] = 0.
        happiness[HappinessSummand.food_luxury] = 0.
        happiness[HappinessSummand.food_variety] = 0.
        happiness_factors[HappinessFactor.not_enough_food_variety] = 1.

        health[HealthSummand.nutrients] = 0
        health[HealthSummand.food] = 0

        sanity[SanitySummand.taste] = 0
        sanity[SanitySummand.favorite_taste] = 0
        sanity[SanitySummand.disliked_taste] = 0
        sanity[SanitySummand.single_food] = 0
        sanity[SanitySummand.no_variety] = 0
        sanity[SanitySummand.just_neutral] = 0
        return
    end

    -- calculate features
    local intrinsic_healthiness = 0
    local fat = 0
    local carbohydrates = 0
    local proteins = 0
    local taste_quality = 0
    local taste_counts = Tirislib_Tables.new_array(taste_category_count, 0)
    local luxury = 0
    local favorite_taste = caste.favorite_taste
    local least_favored_taste = caste.least_favored_taste
    local groups = {}

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

        groups[food.group] = true
    end

    -- calculate means
    intrinsic_healthiness = intrinsic_healthiness / count
    taste_quality = taste_quality / count
    luxury = luxury / count

    -- determine dominant taste
    local dominant_taste = 1
    for current_taste_category, current_count in pairs(taste_counts) do
        if current_count > taste_counts[dominant_taste] then
            dominant_taste = current_taste_category
        end
    end

    -- add calculation summands
    happiness[HappinessSummand.taste] = (1 - caste.desire_for_luxury) * taste_quality * hunger_satisfaction
    happiness[HappinessSummand.food_luxury] = caste.desire_for_luxury * luxury * hunger_satisfaction

    local variety = table_size(groups) - caste.minimum_food_count
    happiness[HappinessSummand.food_variety] = (variety > 0) and (variety * 0.5) or 0

    happiness_factors[HappinessFactor.not_enough_food_variety] = (variety < 0) and 0.6 or 1.

    health[HealthSummand.nutrients] = get_nutrient_healthiness(fat, carbohydrates, proteins) * hunger_satisfaction
    health[HealthSummand.food] = intrinsic_healthiness * hunger_satisfaction

    sanity[SanitySummand.taste] = taste_quality * hunger_satisfaction * 0.5
    sanity[SanitySummand.favorite_taste] = (dominant_taste == favorite_taste) and 4 or 0
    sanity[SanitySummand.disliked_taste] = (dominant_taste == least_favored_taste) and -4 or 0
    sanity[SanitySummand.single_food] = (count == 1) and -3 or 0
    sanity[SanitySummand.no_variety] = (taste_counts[dominant_taste] == count) and -3 or 0
    sanity[SanitySummand.just_neutral] = (taste_counts[Taste.neutral] == count) and -3 or 0
end

--- Evaluates the available diet for the given housing entry and consumes the needed calories.
function Inventories.evaluate_diet(entry, delta_ticks)
    local caste = castes[entry[EK.type]]
    local inventories = get_food_providers(entry)
    local diet, food_count = get_diet(inventories)

    local hunger_satisfaction = 0
    if food_count > 0 then
        local to_consume = caste.calorific_demand * delta_ticks * entry[EK.inhabitants]
        hunger_satisfaction = consume_food(entry, inventories, to_consume, diet, food_count)
    end

    add_diet_effects(entry, diet, caste, food_count, hunger_satisfaction)
end

local function consume_water(distributers, amount)
    local to_consume = amount
    local quality = 0

    local i = 1
    local distributer_count = #distributers

    while to_consume > 0.000001 and i <= distributer_count do
        local distributer = distributers[i]
        local water_name = distributer[EK.water_name]

        -- check if the distributer has water
        if not water_name then
            -- the distributers are sorted, so all the coming distributers won't have any water either
            break
        end

        local consumed = distributer[EK.entity].remove_fluid {name = water_name, amount = to_consume}
        log_fluid(water_name, -consumed)
        quality = quality + consumed * distributer[EK.water_quality]
        to_consume = to_consume - consumed
    end

    return (amount - to_consume) / amount, quality / amount
end

function Inventories.evaluate_water(entry, delta_ticks, happiness_factors, health_factors, health_summands)
    local distributers = get_neighbors_of_type(entry, Type.water_distributer)
    sort_by_key(distributers, EK.water_quality)

    local water_to_consume = castes[entry[EK.type]].water_demand * entry[EK.inhabitants] * delta_ticks
    local satisfaction, quality

    if water_to_consume > 0 then
        satisfaction, quality = consume_water(distributers, water_to_consume)
    else
        -- annoying edge case of no inhabitants
        -- test if there is at least one distributer with water
        local probe = distributers[1]
        if probe and probe[EK.water_name] then
            satisfaction = 1
            quality = probe[EK.water_quality]
        else
            satisfaction = 0
            quality = 0
        end
    end

    happiness_factors[HappinessFactor.thirst] = satisfaction
    health_factors[HealthFactor.thirst] = satisfaction
    health_summands[HealthSummand.water] = quality
end

return Inventories
