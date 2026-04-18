--- Static class for managing item-request-proxies with inventory filter lifecycle.
ItemRequests = {}

--- Finds free (unfiltered) slots for each item, sets filters, creates an item-request-proxy,
--- and stores the used slot indices in entry[slot_key].
--- items: array of {name, count}
--- Note: Factorio allows only one item-request-proxy per entity, so only one active request
--- per entity is possible at a time. Cancel any existing request before creating a new one.
--- Returns false if the inventory has no room for all requested items (nothing is modified).
--- @param entity LuaEntity
--- @param inventory LuaInventory
--- @param items table
--- @param entry Entry
--- @param slot_key integer
--- @return boolean
function ItemRequests.create(entity, inventory, items, entry, slot_key)
    local assignments = {} -- {name, slot, count}
    local used = {}
    local inv_size = #inventory

    for _, item in pairs(items) do
        local proto = prototypes.item[item.name]
        local stack_size = proto and proto.stack_size or 100
        local remaining = item.count
        local i = 1

        while remaining > 0 do
            if i > inv_size then return false end
            if inventory.get_filter(i) == nil and not used[i] then
                used[i] = true
                local batch = math.min(remaining, stack_size)
                assignments[#assignments + 1] = {name = item.name, slot = i, count = batch}
                remaining = remaining - batch
            end
            i = i + 1
        end
    end

    local slot_indices = {}
    local modules = {}
    for _, a in pairs(assignments) do
        inventory.set_filter(a.slot, a.name)
        slot_indices[#slot_indices + 1] = a.slot
        modules[#modules + 1] = {
            id = {name = a.name},
            items = {
                in_inventory = {{
                    inventory = defines.inventory.chest,
                    stack = a.slot - 1, -- 0-based
                    count = a.count
                }}
            }
        }
    end

    inventory.set_bar()
    entry[slot_key] = slot_indices

    entity.surface.create_entity {
        name = "item-request-proxy",
        position = entity.position,
        force = entity.force,
        target = entity,
        modules = modules
    }

    return true
end

--- Destroys the item-request-proxy (if any) and clears the inventory filters
--- that were set by a prior ItemRequests.create call for the same slot_key.
--- @param entity LuaEntity
--- @param inventory LuaInventory
--- @param entry Entry
--- @param slot_key integer
function ItemRequests.cancel(entity, inventory, entry, slot_key)
    local proxy = entity.item_request_proxy
    if proxy and proxy.valid then proxy.destroy() end

    local slots = entry[slot_key]
    if slots then
        for _, slot in pairs(slots) do
            inventory.set_filter(slot, nil)
        end
        entry[slot_key] = nil
    end
end

--- Returns true if all items are present in the inventory in the required amounts.
--- items: array of {name, count}
--- @param inventory LuaInventory
--- @param items table
--- @return boolean
function ItemRequests.fulfilled(inventory, items)
    for _, item in pairs(items) do
        if inventory.get_item_count(item.name) < item.count then
            return false
        end
    end
    return true
end

return ItemRequests
