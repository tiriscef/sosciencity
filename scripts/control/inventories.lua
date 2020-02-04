-- Static class for most of the generic functions that manipulate inventories and or items.
Inventories = {}

local garbage_values = Garbage.values

local log_item = Communication.log_item

local has_power = Subentities.has_power

local chest = defines.inventory.chest

--- Returns the chest inventory associated with this entry. Assumes that there is any.
--- @param entry Entry
function Inventories.get_chest_inventory(entry)
    return entry[ENTITY].get_inventory(chest)
end
local get_chest_inventory = Inventories.get_chest_inventory

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

function Inventories.spill_items(entry, item, amount)
    local entity = entry[ENTITY]
    entity.surface.spill_item_stack(entity.position, {name = item, count = amount})

    log_item(item, amount)
end
local spill_items = Inventories.spill_items

function Inventories.try_output_ideas(entry, item, amount)
    local housing_inventory = get_chest_inventory(entry)

    local done = try_insert(housing_inventory, item, amount)
    -- TODO other entities which accept idea items
    return done
end

function Inventories.produce_garbage(entry, item, amount)
    local produced_amount = 0

    -- try to put the garbage into a dumpster
    for _, disposal_entry in Neighborhood.all_of_type(entry, TYPE_DUMPSTER) do
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

return Inventories
