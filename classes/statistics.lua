--- Static class for various statistic related functions.
Statistics = {}

--[[
    Data this class stores in storage
    --------------------------------
    storage.(fluid/item)_(consumption/production): table
        [name]: amount consumed/produced
]]

-- local often used globals for smallish performance gains

local storage

local fluid_statistics
local fluid_consumption
local fluid_production
local item_statistics
local item_consumption
local item_production

local floor = math.floor

---------------------------------------------------------------------------------------------------
-- << lua state lifecycle stuff >>

local function set_locals()
    fluid_consumption = storage.fluid_consumption
    fluid_production = storage.fluid_production
    item_consumption = storage.item_consumption
    item_production = storage.item_production
end

function Statistics.init()
    storage = _ENV.storage

    storage.fluid_consumption = {}
    storage.fluid_production = {}
    storage.item_consumption = {}
    storage.item_production = {}

    set_locals()
end

function Statistics.load()
    storage = _ENV.storage
    set_locals()
end

---------------------------------------------------------------------------------------------------
-- << production and consumption statistics >>
-- we collect all the produced/consumed stuff and log them collectively
-- this reduces the amount of API calls and avoids the problem that the statistics log only integer numbers

--- Adds the given item to the production or consumption statistics.
--- @param item string
--- @param amount number
function Statistics.log_item(item, amount)
    if amount > 0 then
        item_production[item] = (item_production[item] or 0) + amount
    else
        item_consumption[item] = (item_consumption[item] or 0) - amount
    end
end

--- Adds the given items to the production or consumption statistics.
--- @param items table
function Statistics.log_items(items)
    for item, amount in pairs(items) do
        if amount > 0 then
            item_production[item] = (item_production[item] or 0) + amount
        else
            item_consumption[item] = (item_consumption[item] or 0) - amount
        end
    end
end

--- Adds the given fluid to the production or consumption statistics.
--- @param fluid string
--- @param amount number
function Statistics.log_fluid(fluid, amount)
    if amount > 0 then
        fluid_production[fluid] = (fluid_production[fluid] or 0) + amount
    else
        fluid_consumption[fluid] = (fluid_consumption[fluid] or 0) - amount
    end
end

--- Adds the given fluids to the production or consumption statistics.
--- @param fluids table
function Statistics.log_fluids(fluids)
    for fluid, amount in pairs(fluids) do
        if amount > 0 then
            fluid_production[fluid] = (fluid_production[fluid] or 0) + amount
        else
            fluid_consumption[fluid] = (fluid_consumption[fluid] or 0) - amount
        end
    end
end

local function flush_log(list, statistic, multiplier)
    for name, amount in pairs(list) do
        local amount_to_log = floor(amount)

        if amount_to_log > 0 then
            statistic.on_flow(name, amount_to_log * multiplier)

            local new_amount = amount - amount_to_log
            if new_amount == 0 then
                list[name] = nil
            else
                list[name] = new_amount
            end
        end
    end
end

function Statistics.update()
    if item_statistics == nil then
        item_statistics = game.forces.player.get_item_production_statistics("nauvis")
        fluid_statistics = game.forces.player.get_fluid_production_statistics("nauvis")
    end

    flush_log(item_consumption, item_statistics, -1)
    flush_log(item_production, item_statistics, 1)
    flush_log(fluid_consumption, fluid_statistics, -1)
    flush_log(fluid_production, fluid_statistics, 1)
end

return Statistics
