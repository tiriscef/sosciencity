local EK = require("enums.entry-key")
local Housing = require("constants.housing")

-- Things about upgrading homes.
Inhabitants.HousingUpgrades = {}
local HousingUpgrades = Inhabitants.HousingUpgrades

--- @param level integer
--- @return boolean
function HousingUpgrades.is_level_unlocked(level)
    local tech = Housing.required_tech[level]
    return tech == nil or storage.technologies[tech]
end

--- @return integer
function HousingUpgrades.get_max_unlocked_level()
    for level = Housing.max_level, 1, -1 do
        if HousingUpgrades.is_level_unlocked(level) then
            return level
        end
    end
    return 0
end

--- @param tag integer
--- @return boolean
function HousingUpgrades.is_tag_unlocked(tag)
    local tech = Housing.tag_required_tech[tag]
    return tech == nil or storage.technologies[tech]
end

--- @param house HouseDefinition
--- @param level integer
--- @return table?
function HousingUpgrades.get_upgrade_cost(house, level)
    local per_room = Housing.furniture_costs[level]
    if not per_room then return nil end
    local room_count = house.room_count
    local result = {}
    for _, entry in pairs(per_room) do
        result[#result + 1] = {name = entry.name, count = math.ceil(entry.amount * room_count)}
    end
    return result
end

--- @param house HouseDefinition
--- @param current_comfort integer
--- @return table
function HousingUpgrades.get_total_refund(house, current_comfort)
    local totals = {}
    for level = 1, current_comfort do
        local cost = HousingUpgrades.get_upgrade_cost(house, level)
        if cost then
            for _, item in pairs(cost) do
                totals[item.name] = (totals[item.name] or 0) + item.count
            end
        end
    end
    local result = {}
    for name, count in pairs(totals) do
        result[#result + 1] = {name = name, count = count}
    end
    return result
end

--- @param house HouseDefinition
--- @param tag integer
--- @return table?
function HousingUpgrades.get_tag_cost(house, tag)
    local per_room = Housing.tag_costs[tag]
    if not per_room then return nil end
    local room_count = house.room_count
    local result = {}
    for _, entry in pairs(per_room) do
        result[#result + 1] = {name = entry.name, count = math.ceil(entry.amount * room_count)}
    end
    return result
end

--- @param house HouseDefinition
--- @param active_tags table
--- @return table
function HousingUpgrades.get_tag_refund(house, active_tags)
    local totals = {}
    for tag in pairs(active_tags) do
        local cost = HousingUpgrades.get_tag_cost(house, tag)
        if cost then
            for _, item in pairs(cost) do
                totals[item.name] = (totals[item.name] or 0) + item.count
            end
        end
    end
    local result = {}
    for name, count in pairs(totals) do
        result[#result + 1] = {name = name, count = count}
    end
    return result
end

local display_item_stack = Tirislib.Locales.display_item_stack

local function get_inventory(entry)
    return entry[EK.entity].get_inventory(defines.inventory.chest)
end

--- Returns per-item progress for GUI display: array of {name, required, in_chest}.
--- @param entry Entry
--- @return table?
function Inhabitants.get_upgrade_progress(entry)
    local current = entry[EK.current_comfort] or 0
    local cost = HousingUpgrades.get_upgrade_cost(Inhabitants.HousingCore.get(entry), current + 1)
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
    local house_details = Inhabitants.HousingCore.get(entry)
    local max_comfort = house_details.max_comfort
    local current_comfort = entry[EK.current_comfort] or 0
    if current_comfort >= max_comfort then return end

    local next_level = current_comfort + 1
    if not HousingUpgrades.is_level_unlocked(next_level) then
        return {"sosciencity.upgrade-comfort-locked", Locale.prototype_name(Housing.required_tech[next_level], "technology")}
    end

    local cost = HousingUpgrades.get_upgrade_cost(house_details, next_level)
    if not cost then
        ItemRequests.set_request(entry[EK.entity], get_inventory(entry), entry, "comfort", nil)
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

    ItemRequests.set_request(entry[EK.entity], chest_inv, entry, "comfort", nil)

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

--- Returns per-item progress for a quality tag for GUI display: array of {name, required, in_chest}.
--- @param entry Entry
--- @param tag integer HousingTrait enum value
--- @return table?
function Inhabitants.get_tag_progress(entry, tag)
    local cost = HousingUpgrades.get_tag_cost(Inhabitants.HousingCore.get(entry), tag)
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

--- Attempts to add a quality tag using items from the player and chest inventories.
--- Returns a localised error message if blocked, nil on success.
--- @param entry Entry
--- @param player LuaPlayer
--- @param tag integer HousingTrait enum value
--- @return LocalisedString?
function Inhabitants.try_manual_add_tag(entry, player, tag)
    local active_tags = entry[EK.trait_upgrades] or {}
    if active_tags[tag] then return end

    if not HousingUpgrades.is_tag_unlocked(tag) then
        return {"sosciencity.add-tag-locked", Locale.prototype_name(Housing.tag_required_tech[tag], "technology")}
    end

    local house_details = Inhabitants.HousingCore.get(entry)
    local cost = HousingUpgrades.get_tag_cost(house_details, tag)

    if not cost then
        active_tags[tag] = true
        entry[EK.trait_upgrades] = active_tags
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
        return {"sosciencity.add-tag-missing", missing_str}
    end

    ItemRequests.set_request(entry[EK.entity], chest_inv, entry, tag, nil)

    for _, item in pairs(from_chest) do
        chest_inv.remove({name = item.name, count = item.count})
    end
    for _, item in pairs(from_player) do
        player_inv.remove({name = item.name, count = item.count})
    end

    active_tags[tag] = true
    entry[EK.trait_upgrades] = active_tags

    local target_tags = entry[EK.target_tags]
    if target_tags then
        target_tags[tag] = nil
        if not next(target_tags) then entry[EK.target_tags] = nil end
    end

    Communication.create_temporary_text(entry, {"sosciencity.add-tag-done"})
end

--- Adds a quality tag to the logistics target list, requesting it via the logistics network.
--- @param entry Entry
--- @param tag integer HousingTrait enum value
function Inhabitants.try_request_tag(entry, tag)
    local active_tags = entry[EK.trait_upgrades] or {}
    if active_tags[tag] then return end
    if not HousingUpgrades.is_tag_unlocked(tag) then return end

    local target_tags = entry[EK.target_tags] or {}
    if target_tags[tag] then return end
    target_tags[tag] = true
    entry[EK.target_tags] = target_tags

    local entity = entry[EK.entity]
    local cost = HousingUpgrades.get_tag_cost(Inhabitants.HousingCore.get(entry), tag)
    if cost then
        ItemRequests.set_request(entity, get_inventory(entry), entry, tag, cost)
    end
end

--- Removes a quality tag from the logistics target list.
--- @param entry Entry
--- @param tag integer HousingTrait enum value
function Inhabitants.cancel_target_tag(entry, tag)
    local target_tags = entry[EK.target_tags]
    if not target_tags or not target_tags[tag] then return end
    target_tags[tag] = nil
    if not next(target_tags) then entry[EK.target_tags] = nil end

    local entity = entry[EK.entity]
    ItemRequests.set_request(entity, get_inventory(entry), entry, tag, nil)
end

--- Checks chest inventory for fulfilled upgrades and applies them.
--- @param entry Entry
function Inhabitants.try_auto_upgrades(entry)
    local house_details = Inhabitants.HousingCore.get(entry)
    local entity = entry[EK.entity]
    local inventory = entity.get_inventory(defines.inventory.chest)

    -- Comfort upgrade
    local current = entry[EK.current_comfort] or 0
    local target = math.min(entry[EK.target_comfort] or 0, house_details.max_comfort)
    if current < target then
        local next_level = current + 1
        if HousingUpgrades.is_level_unlocked(next_level) then
            local cost = HousingUpgrades.get_upgrade_cost(house_details, next_level)
            if not cost or ItemRequests.fulfilled(inventory, cost) then
                if cost then
                    for _, item in pairs(cost) do
                        inventory.remove({name = item.name, count = item.count})
                    end
                end
                entry[EK.current_comfort] = next_level
                entry[EK.target_comfort] = math.min(math.max(entry[EK.target_comfort] or 0, next_level), house_details.max_comfort)
                Communication.create_temporary_text(entry, {"sosciencity.upgrade-comfort-done", next_level})
            end
        end
    end
    local new_current = entry[EK.current_comfort] or 0
    local new_target = math.min(entry[EK.target_comfort] or 0, house_details.max_comfort)
    local comfort_request = nil
    if new_current < new_target then
        local nxt = new_current + 1
        if HousingUpgrades.is_level_unlocked(nxt) then
            comfort_request = HousingUpgrades.get_upgrade_cost(house_details, nxt)
        end
    end
    ItemRequests.set_request(entity, inventory, entry, "comfort", comfort_request)

    -- Tag upgrades
    local target_tags = entry[EK.target_tags]
    if target_tags then
        local trait_upgrades = entry[EK.trait_upgrades] or {}
        for tag in pairs(target_tags) do
            if not trait_upgrades[tag] and HousingUpgrades.is_tag_unlocked(tag) then
                local cost = HousingUpgrades.get_tag_cost(house_details, tag)
                if not cost or ItemRequests.fulfilled(inventory, cost) then
                    if cost then
                        for _, item in pairs(cost) do
                            inventory.remove({name = item.name, count = item.count})
                        end
                    end
                    trait_upgrades[tag] = true
                    entry[EK.trait_upgrades] = trait_upgrades
                    Communication.create_temporary_text(entry, {"sosciencity.add-tag-done"})
                    cost = nil
                end
                ItemRequests.set_request(entity, inventory, entry, tag, cost)
            end
        end
    end
end
