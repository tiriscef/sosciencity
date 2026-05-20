local EK = require("enums.entry-key")
local Type = require("enums.type")

local Food = require("constants.food")
local InhabitantsConstants = require("constants.inhabitants")
local ItemConstants = require("constants.item-constants")

--- Static class for food consumption and inhabitant byproduct output (eggs, garbage).
--- The class name captures the dominant use case. Naming is hard.
Consumption = {}

--[[
    Data this class stores in storage
    --------------------------------
    nothing
]]
local Table = Tirislib.Tables
local Utils = Tirislib.Utils

local garbage_values = ItemConstants.garbage_values
local food_values = Food.values

local log_item = Statistics.log_item

local all_neighbors_of_type = Neighborhood.iterate_type

local get_chest_inventory = Inventories.get_chest_inventory
local try_insert = Inventories.try_insert
local try_remove = Inventories.try_remove
local try_move = Inventories.try_move
local spill_items = Inventories.spill_items

local min = math.min

local is_active

---------------------------------------------------------------------------------------------------
-- << lua state lifecycle stuff >>

local function set_locals()
    is_active = Entity.is_active
end

function Consumption.init()
    set_locals()
end

function Consumption.load()
    set_locals()
end

---------------------------------------------------------------------------------------------------
-- << garbage >>

--- Produces garbage items, distributing to nearby active dumpsters first, then the house inventory, then spilling on the ground.
--- @param entry Entry housing entry
--- @param item string item name of the garbage
--- @param amount integer number of items to produce
function Consumption.produce_garbage(entry, item, amount)
    local produced_amount = 0

    for _, disposal_entry in all_neighbors_of_type(entry, Type.dumpster) do
        if is_active(disposal_entry) then
            local inventory = get_chest_inventory(disposal_entry)
            produced_amount = produced_amount + try_insert(inventory, item, amount - produced_amount)

            if produced_amount == amount then
                return
            end
        end
    end

    local housing_inventory = get_chest_inventory(entry)
    produced_amount = produced_amount + try_insert(housing_inventory, item, amount - produced_amount)

    if produced_amount == amount then
        return
    end

    spill_items(entry, item, amount - produced_amount)
end

--- Tries to move garbage items from the given inventory to nearby dumpster entities.
--- @param entry Entry housing entry (used to find neighbors)
--- @param inventory LuaInventory inventory to move items from
--- @param item string item name
--- @param count integer number of items to move
--- @return integer number of items successfully disposed
local function try_dispose_garbage(entry, inventory, item, count)
    local disposed = 0

    for _, dumpster in all_neighbors_of_type(entry, Type.dumpster) do
        local dumpster_inventory = get_chest_inventory(dumpster)

        disposed = disposed + try_move(item, count - disposed, inventory, dumpster_inventory)

        if disposed == count then
            break
        end
    end

    return disposed
end

--- Evaluates how much garbage there is in a populated house.
--- Also tries to move the garbage items to a dumpster entity.
--- @param entry Entry
--- @return integer
function Consumption.get_garbage_value(entry)
    local value = 0
    local inventory = get_chest_inventory(entry)
    local items = Inventories.get_contents(inventory)

    for name, count in pairs(items) do
        local garbage_multiplier = garbage_values[name]

        if garbage_multiplier then
            count = count - try_dispose_garbage(entry, inventory, name, count)
            value = value + garbage_multiplier * count
        end
    end

    return value
end

---------------------------------------------------------------------------------------------------
-- << eggs >>

--- Outputs fertile eggs to nearby active egg collectors, or to the house inventory up to a cap of 20.
--- @param entry Entry housing entry
--- @param count number number of eggs to output
--- @return integer number of eggs actually inserted
function Consumption.output_eggs(entry, count)
    local inserted = 0

    for _, egg_collector in all_neighbors_of_type(entry, Type.egg_collector) do
        if is_active(egg_collector) then
            local inventory = get_chest_inventory(egg_collector)
            inserted = inserted + try_insert(inventory, InhabitantsConstants.egg_fertile, count - inserted)

            if count - inserted < 0.001 then
                return inserted
            end
        end
    end

    local house_inventory = get_chest_inventory(entry)
    local already_inside = house_inventory.get_item_count(InhabitantsConstants.egg_fertile)
    return try_insert(house_inventory, InhabitantsConstants.egg_fertile, min(20 - already_inside, count - inserted))
end

--- Removes eggs from the given entry's inventory.
--- @param entry Entry
--- @param max_count integer
--- @return table eggs with (item_name, count)-pairs
function Consumption.remove_eggs(entry, max_count)
    local eggs = Table.get_keyset(InhabitantsConstants.egg_data)
    Tirislib.Arrays.shuffle(eggs)

    local count = 0
    local inventory = get_chest_inventory(entry)

    local ret = {}
    for _, egg in pairs(eggs) do
        if max_count - count == 0 then
            break
        end
        local consumed = try_remove(inventory, egg, max_count - count)

        count = count + consumed
        ret[egg] = consumed
    end

    return ret
end

---------------------------------------------------------------------------------------------------
-- << food calories >>

--- Returns the total calories contained in the given inventory, accounting for partial top-of-stack durability.
--- @param inventory LuaInventory
--- @return number
function Consumption.count_calories(inventory)
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

--- Consumes the given amount of calories from an inventory, logging each item consumed. Returns the amount actually consumed.
--- @param inventory LuaInventory
--- @param calories number calories to consume
--- @return number calories actually consumed
function Consumption.consume_calories(inventory, calories)
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

--- Consumes calories of the given food type across the given inventories. Returns the amount of calories actually consumed.
--- @param entry Entry housing entry (used for garbage production side-effect)
--- @param inventories table[] array of inventories to consume from
--- @param amount number calories to consume
--- @param item_name string food item name to consume
--- @return number calories actually consumed
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
                log_item(item_name, -items_consumed)

                local food_leftovers = Utils.coin_flips(InhabitantsConstants.food_leftovers_chance, items_consumed, 5)

                if food_leftovers > 0 then
                    Consumption.produce_garbage(entry, "food-leftovers", food_leftovers)
                end
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
--- One food is chosen at random, weighted by caloric density (kcal per 100g), and all needed calories
--- are drawn from it. If it runs out, another food is picked from those remaining, again weighted by
--- density. This averages to density-proportional consumption across updates while making only one
--- API call in the common case.
--- @param entry Entry housing entry (used for garbage production side-effect)
--- @param inventories table[] array of inventories to consume from
--- @param amount number calories to consume
--- @param diet string[] food item names available in the diet
--- @return number satisfaction fraction of calories actually consumed (0-1)
function Consumption.consume_food(entry, inventories, amount, diet)
    local diet_foods = {}
    for _, item_name in pairs(diet) do
        diet_foods[item_name] = food_values[item_name]
    end

    local remaining = amount

    while remaining > 0.001 and next(diet_foods) ~= nil do
        local item_name, food = Table.pick_random_subtable_weighted_by_key(diet_foods, "density")
        local to_request = remaining
        local consumed = consume_specific_food(entry, inventories, to_request, food.name)
        remaining = remaining - consumed

        if consumed < to_request - 0.001 then
            diet_foods[item_name] = nil
        end
    end

    return (amount - remaining) / amount
end

return Consumption
