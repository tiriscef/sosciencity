-- Static class for most of the generic functions that manipulate inventories and or items.
Inventories = {}

--[[
    Data this class stores in global
    --------------------------------
    nothing
]]
-- local often used globals for great performance gains
local garbage_values = ItemConstants.garbage_values

local log_item = Communication.log_item

local has_power = Subentities.has_power

local chest = defines.inventory.chest

local table_add = Tirislib_Tables.add

local min = math.min

--- Returns the chest inventory associated with this entry. Assumes that there is any.
--- @param entry Entry
function Inventories.get_chest_inventory(entry)
    return entry[EK.entity].get_inventory(chest)
end
local get_chest_inventory = Inventories.get_chest_inventory

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
function Inventories.try_insert(inventory, item, amount)
    local inserted_amount =
        inventory.insert {
        name = item,
        count = amount
    }

    log_item(item, inserted_amount)

    return inserted_amount
end
local try_insert = Inventories.try_insert

function Inventories.try_remove(inventory, item, amount)
    local removed_amount =
        inventory.remove {
        name = item,
        count = amount
    }

    log_item(item, -removed_amount)

    return removed_amount
end

function Inventories.spill_items(entry, item, amount)
    local entity = entry[EK.entity]
    entity.surface.spill_item_stack(entity.position, {name = item, count = amount})

    log_item(item, amount)
end
local spill_items = Inventories.spill_items

function Inventories.produce_garbage(entry, item, amount)
    local produced_amount = 0

    -- try to put the garbage into a dumpster
    for _, disposal_entry in Neighborhood.all_of_type(entry, Type.dumpster) do
        if has_power(disposal_entry) then
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

--- Tries to remove the given list of items if a full set is available in the inventory.
--- Returns true if it removed the items.
function Inventories.try_remove_item_range(entry, items)
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

    return true
end

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

function Inventories.output_eggs(entry, count)
    -- TODO output in some collection entity

    local house_inventory = get_chest_inventory(entry)
    local already_inside = house_inventory.get_item_count("egg")
    return try_insert(house_inventory, "egg", min(20 - already_inside, count))
end

return Inventories
