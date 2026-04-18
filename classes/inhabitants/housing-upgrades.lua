local EK = require("enums.entry-key")
local Housing = require("constants.housing")

local display_item_stack = Tirislib.Locales.display_item_stack

local function get_cost(entry, level)
    return Housing.get_upgrade_cost(Housing.get(entry), level)
end

local function get_inventory(entry)
    return entry[EK.entity].get_inventory(defines.inventory.chest)
end

local function create_upgrade_proxy(entry, level)
    local cost = get_cost(entry, level)
    if not cost then return end
    local entity = entry[EK.entity]
    local inventory = entity.get_inventory(defines.inventory.chest)

    local needed = {}
    for _, item in pairs(cost) do
        local shortfall = item.count - inventory.get_item_count(item.name)
        if shortfall > 0 then
            needed[#needed + 1] = {name = item.name, count = shortfall}
        end
    end

    if #needed > 0 then
        ItemRequests.create(entity, inventory, needed, entry, EK.upgrade_slots)
    end
end

local function cancel_upgrade_proxy(entry)
    local entity = entry[EK.entity]
    ItemRequests.cancel(entity, entity.get_inventory(defines.inventory.chest), entry, EK.upgrade_slots)
end

--- Returns per-item progress for GUI display: array of {name, required, in_chest}.
--- @param entry Entry
--- @return table?
function Inhabitants.get_upgrade_progress(entry)
    local current = entry[EK.current_comfort] or 0
    local cost = get_cost(entry, current + 1)
    if not cost then return nil end

    local inventory = get_inventory(entry)
    local result = {}
    for _, item in pairs(cost) do
        result[#result + 1] = {
            name = item.name,
            required = item.count,
            in_chest = inventory.get_item_count(item.name)
        }
    end
    return result
end

--- Attempts a manual comfort upgrade using items from the player and chest inventories.
--- Returns a localised missing-items message if items are lacking, nil otherwise.
--- @param entry Entry
--- @param player LuaPlayer
--- @return LocalisedString?
function Inhabitants.try_manual_upgrade(entry, player)
    local house_details = Housing.get(entry)
    local max_comfort = house_details.max_comfort
    local current_comfort = entry[EK.current_comfort] or 0
    if current_comfort >= max_comfort then return end

    local next_level = current_comfort + 1
    local cost = Housing.get_upgrade_cost(house_details, next_level)
    if not cost then
        cancel_upgrade_proxy(entry)
        entry[EK.current_comfort] = next_level
        entry[EK.target_comfort] = math.min(math.max(entry[EK.target_comfort] or 0, next_level), max_comfort)
        Communication.create_temporary_text(entry, {"sosciencity.upgrade-comfort-done", next_level})
        return
    end

    local chest_inv = get_inventory(entry)
    local player_inv = player.get_main_inventory()

    local from_chest = {}
    local from_player = {}
    local missing = {}

    for _, item in pairs(cost) do
        local in_chest = chest_inv.get_item_count(item.name)
        local take_chest = math.min(in_chest, item.count)
        local need_player = item.count - take_chest

        if take_chest > 0 then
            from_chest[#from_chest + 1] = {name = item.name, count = take_chest}
        end
        if need_player > 0 then
            local in_player = player_inv.get_item_count(item.name)
            if in_player < need_player then
                missing[#missing + 1] = display_item_stack(item.name, need_player - in_player)
            else
                from_player[#from_player + 1] = {name = item.name, count = need_player}
            end
        end
    end

    if #missing > 0 then
        local missing_str = {""}
        for i, m in pairs(missing) do
            if i > 1 then missing_str[#missing_str + 1] = ", " end
            missing_str[#missing_str + 1] = m
        end
        return {"sosciencity.upgrade-comfort-missing", missing_str}
    end

    cancel_upgrade_proxy(entry)

    for _, item in pairs(from_chest) do
        chest_inv.remove({name = item.name, count = item.count})
    end
    for _, item in pairs(from_player) do
        player_inv.remove({name = item.name, count = item.count})
    end

    entry[EK.current_comfort] = next_level
    entry[EK.target_comfort] = math.min(math.max(entry[EK.target_comfort] or 0, next_level), max_comfort)
    Communication.create_temporary_text(entry, {"sosciencity.upgrade-comfort-done", next_level})
end

--- Checks chest inventory for required upgrade items and applies the upgrade if present.
--- Creates or maintains the item-request-proxy when items are still needed.
--- @param entry Entry
function Inhabitants.try_auto_upgrade(entry)
    local current = entry[EK.current_comfort] or 0
    local target = math.min(entry[EK.target_comfort] or 0, Housing.get(entry).max_comfort)

    if current >= target then
        cancel_upgrade_proxy(entry)
        return
    end

    local next_level = current + 1
    local cost = get_cost(entry, next_level)

    if not cost then
        entry[EK.current_comfort] = next_level
        return
    end

    local entity = entry[EK.entity]
    local inventory = entity.get_inventory(defines.inventory.chest)

    if ItemRequests.fulfilled(inventory, cost) then
        for _, item in pairs(cost) do
            inventory.remove({name = item.name, count = item.count})
        end
        ItemRequests.cancel(entity, inventory, entry, EK.upgrade_slots)
        entry[EK.current_comfort] = next_level
        Communication.create_temporary_text(entry, {"sosciencity.upgrade-comfort-done", next_level})
        if next_level < target then
            create_upgrade_proxy(entry, next_level + 1)
        end
    elseif not entity.item_request_proxy then
        create_upgrade_proxy(entry, next_level)
    end
end
