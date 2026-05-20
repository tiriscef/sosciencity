local EK = require("enums.entry-key")

--- Static class for the manipulation of inventories, items and fluids.
Inventories = {}

--[[
    Data this class stores in storage
    --------------------------------
    nothing
]]
-- local often used globals for great performance gains

local Table = Tirislib.Tables

local log_item = Statistics.log_item
local log_items = Statistics.log_items

local chest = defines.inventory.chest
local crafter_modules = defines.inventory.crafter_modules

local table_add = Table.add

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
    entry[EK.inventory_contents] = Inventories.get_contents(get_chest_inventory(entry))
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
    entity.surface.spill_item_stack {position = entity.position, stack = {name = item, count = amount}}

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
            surface.spill_item_stack {position = position, stack = {name = item, count = count}}
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

return Inventories
