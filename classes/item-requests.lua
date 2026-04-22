local EK = require("enums.entry-key")

--- Static class managing item-request-proxies with named request groups.
--- Multiple independent request groups share a single proxy per entity.
--- Storage: entry[EK.item_requests] = {groups = {key → items}, slots = {slot_indices}}
ItemRequests = {}

local function rebuild(entity, inventory, entry)
    local proxy = entity.item_request_proxy
    if proxy and proxy.valid then proxy.destroy() end

    local data = entry[EK.item_requests]
    if data and data.slots then
        for _, slot in pairs(data.slots) do
            inventory.set_filter(slot, nil)
        end
        data.slots = nil
    end

    if not data or not next(data.groups) then return end

    local merged = {}
    for _, items in pairs(data.groups) do
        for _, item in pairs(items) do
            merged[item.name] = (merged[item.name] or 0) + item.count
        end
    end

    local needed = {}
    for name, count in pairs(merged) do
        local shortfall = count - inventory.get_item_count(name)
        if shortfall > 0 then
            needed[#needed + 1] = {name = name, count = shortfall}
        end
    end

    if #needed == 0 then return end

    -- Build slot assignments without touching inventory yet (rollback-safe)
    local assignments = {}
    local used = {}
    local inv_size = #inventory

    for _, item in pairs(needed) do
        local proto = prototypes.item[item.name]
        local stack_size = proto and proto.stack_size or 100
        local remaining = item.count
        local i = 1

        while remaining > 0 do
            if i > inv_size then return end
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
                    stack = a.slot - 1,
                    count = a.count
                }}
            }
        }
    end

    inventory.set_bar()
    data.slots = slot_indices

    entity.surface.create_entity {
        name = "item-request-proxy",
        position = entity.position,
        force = entity.force,
        target = entity,
        modules = modules
    }
end

--- Sets or clears a named request and rebuilds the proxy when needed.
--- Safe to call every update cycle: only rebuilds on nil↔non-nil transitions
--- for this key, or when the proxy was consumed and needs recreation.
--- @param entity LuaEntity
--- @param inventory LuaInventory
--- @param entry Entry
--- @param key any
--- @param items table?
function ItemRequests.set_request(entity, inventory, entry, key, items)
    local data = entry[EK.item_requests] or {groups = {}}
    local old = data.groups[key]
    data.groups[key] = items
    entry[EK.item_requests] = data
    if (old == nil) ~= (items == nil) or not entity.item_request_proxy then
        rebuild(entity, inventory, entry)
    end
    if not next(data.groups) then
        entry[EK.item_requests] = nil
    end
end

--- Destroys the proxy and clears all request data.
--- Call when an entity is removed to clean up its proxy and inventory filters.
--- @param entity LuaEntity
--- @param inventory LuaInventory
--- @param entry Entry
function ItemRequests.cancel(entity, inventory, entry)
    local proxy = entity.item_request_proxy
    if proxy and proxy.valid then proxy.destroy() end

    local data = entry[EK.item_requests]
    if data and data.slots then
        for _, slot in pairs(data.slots) do
            inventory.set_filter(slot, nil)
        end
    end
    entry[EK.item_requests] = nil
end

--- Returns true if all items are present in the inventory in the required amounts.
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
