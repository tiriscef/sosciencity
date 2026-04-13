local EK = require("enums.entry-key")
local Type = require("enums.type")

local Biology = require("constants.biology")
local Food = require("constants.food")
local ItemConstants = require("constants.item-constants")

--- Static class for the manipulation of inventories, items and fluids.
Inventories = {}

--[[
    Data this class stores in storage
    --------------------------------
    nothing
]]
-- local often used globals for great performance gains

local Table = Tirislib.Tables
local Utils = Tirislib.Utils

local garbage_values = ItemConstants.garbage_values

local log_item = Statistics.log_item
local log_items = Statistics.log_items

local all_neighbors_of_type = Neighborhood.iterate_type
local get_neighbors_of_type = Neighborhood.get_by_type

local chest = defines.inventory.chest
local crafter_modules = defines.inventory.crafter_modules

local table_add = Table.add

local food_values = Food.values

local min = math.min

local is_active

---------------------------------------------------------------------------------------------------
-- << lua state lifecycle stuff >>

local function set_locals()
    is_active = Entity.is_active
end

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
--- @return LuaInventory
function Inventories.get_chest_inventory(entry)
    return entry[EK.entity].get_inventory(chest)
end
local get_chest_inventory = Inventories.get_chest_inventory

--- Checks if the given assembler entry has the given module.
function Inventories.assembler_has_module(entity, module_name)
    local inventory = entity.get_inventory(crafter_modules)

    return inventory.get_item_count(module_name) > 0
end

--- Replicates the behavior of the old 'LuaInventory.get_contents'-method from Factorio 1.1
--- @param inventory LuaInventory
function Inventories.get_contents(inventory)
    local ret = {}

    for _, item in pairs(inventory.get_contents()) do
        ret[item.name] = item.count
    end

    return ret
end

--- Returns a table with the (item, amount)-pairs of the combined contents of the given Inventories.
--- @param inventories table
--- @return table
function Inventories.get_combined_contents(inventories)
    local ret = {}

    for _, inventory in pairs(inventories) do
        table_add(ret, Inventories.get_contents(inventory))
    end

    return ret
end
local get_combined_contents = Inventories.get_combined_contents

--- Saves the contents of this entry's entity.
--- @param entry Entry
function Inventories.cache_contents(entry)
    entry[EK.inventory_contents] = get_chest_inventory(entry).get_contents()
end

--- Tries to insert the given count of the given item into the inventory and adds the inserted items to the production statistics.
--- Returns the count that was actually inserted.
--- @param inventory LuaInventory
--- @param item string
--- @param count number
--- @param suppress_logging boolean?
--- @return integer
function Inventories.try_insert(inventory, item, count, suppress_logging)
    if count <= 0 then
        return 0
    end

    local inserted_count =
        inventory.insert {
        name = item,
        count = count
    }

    if not suppress_logging then
        log_item(item, inserted_count)
    end

    return inserted_count
end
local try_insert = Inventories.try_insert

--- Tries to insert the given count of the given item into the given inventories and adds the inserted items to the production statistics.<br>
--- Returns the count that was actually inserted.
--- @param inventories LuaInventory[]
--- @param item string
--- @param count integer
--- @param suppress_logging boolean?
--- @return integer
function Inventories.try_insert_into_inventory_range(inventories, item, count, suppress_logging)
    if count <= 0 then
        return 0
    end

    local inserted_count = 0
    for _, inventory in pairs(inventories) do
        inserted_count = inserted_count + try_insert(inventory, item, count - inserted_count, suppress_logging)
        if inserted_count == count then
            break
        end
    end

    return inserted_count
end

--- Tries to remove the given amount of the given item from the inventory and adds the removed items to the production statistics.
--- Returns the amount that was actually removed.
--- @param inventory LuaInventory
--- @param item string
--- @param amount integer
--- @param suppress_logging boolean|nil
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
--- @param suppress_logging boolean|nil
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
--- @param suppress_logging boolean|nil
--- @return boolean
function Inventories.try_remove_item_range(entry, items, suppress_logging)
    local inventory = get_chest_inventory(entry)
    local contents = Inventories.get_contents(inventory)

    for name, desired_amount in pairs(items) do
        local available_amount = contents[name] or 0
        if desired_amount > available_amount then
            return false
        end
    end

    for name, desired_amount in pairs(items) do
        inventory.remove {name = name, count = desired_amount}
    end
    if not suppress_logging then
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

--- Tries to move the specified amount of items from the source inventory to the destination inventory. Assumes this amount of items actually exists in the source inventory.
--- @param item string
--- @param count integer
--- @param source_inventory LuaInventory
--- @param destination_inventory LuaInventory
--- @return integer
function Inventories.try_move(item, count, source_inventory, destination_inventory)
    local inserted = destination_inventory.insert {name = item, count = count}

    if inserted > 0 then
        source_inventory.remove {name = item, count = inserted}
    end

    return inserted
end
local try_move = Inventories.try_move

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
function Inventories.get_garbage_value(entry)
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

--- Removes eggs from the given entry's inventory.
--- @param entry Entry
--- @param max_count integer
--- @return table eggs with (item_name, count)-pairs
function Inventories.remove_eggs(entry, max_count)
    local eggs = Table.get_keyset(Biology.egg_data)
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
                log_item(item_name, -items_consumed)

                local food_leftovers = Utils.coin_flips(Food.food_leftovers_chance, items_consumed, 5)

                if food_leftovers > 0 then
                    produce_garbage(entry, "food-leftovers", food_leftovers)
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
--- @return number satisfaction fraction of calories actually consumed (0–1)
local function consume_food(entry, inventories, amount, diet)
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
Inventories.consume_food = consume_food

return Inventories
