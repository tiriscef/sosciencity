local Time = require("constants.time")

local Tables = Tirislib.Tables

--- Static class for various statistic related functions.
Statistics = {}

--[[
    Data this class stores in storage
    --------------------------------
    storage.(fluid/item)_(consumption/production): table
        [name]: amount consumed/produced

    storage.population_history: table
        [tier_name]: table
            data: array of population snapshots ({[caste_id] = count})
            index: int (current write position, 1-based, wraps around)
            size: int (buffer capacity)
]]

-- local often used globals for smallish performance gains

local storage

local fluid_statistics
local fluid_consumption
local fluid_production
local item_statistics
local item_consumption
local item_production

local population_history

local floor = math.floor

---------------------------------------------------------------------------------------------------
-- << population history >>
-- independent circular buffers at different resolutions, each sampling on their own interval

local population_history_tiers = {
    {name = "fine", interval = 1 * Time.minute, size = 60}, -- every 1 min, ~1 hour
    {name = "medium", interval = 10 * Time.minute, size = 144}, -- every 10 min, ~1 day
    {name = "coarse", interval = 1 * Time.hour, size = 168} -- every 1 hour, ~1 week
}

local function init_population_history()
    storage.population_history = {}
    for _, tier in pairs(population_history_tiers) do
        storage.population_history[tier.name] = {
            data = {},
            index = 1,
            size = tier.size
        }
    end
end

local function sample_population()
    return Tables.copy(storage.population)
end

---------------------------------------------------------------------------------------------------
-- << lua state lifecycle stuff >>

local function set_locals()
    fluid_consumption = storage.fluid_consumption
    fluid_production = storage.fluid_production
    item_consumption = storage.item_consumption
    item_production = storage.item_production

    population_history = storage.population_history
end

function Statistics.init()
    storage = _ENV.storage

    storage.fluid_consumption = {}
    storage.fluid_production = {}
    storage.item_consumption = {}
    storage.item_production = {}

    init_population_history()

    set_locals()

    -- take an immediate first sample so the GUI has data right away
    local snapshot = sample_population()
    for _, tier in pairs(population_history_tiers) do
        local buffer = population_history[tier.name]
        buffer.data[1] = snapshot
        buffer.index = 2
    end
end

function Statistics.load()
    storage = _ENV.storage

    if not storage.population_history then
        init_population_history()

        -- seed all tiers with current population
        local snapshot = sample_population()
        for _, tier in pairs(population_history_tiers) do
            local buffer = storage.population_history[tier.name]
            buffer.data[1] = snapshot
            buffer.index = 2
        end
    end

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

local function flush_statistics()
    if item_statistics == nil then
        item_statistics = game.forces.player.get_item_production_statistics("nauvis")
        fluid_statistics = game.forces.player.get_fluid_production_statistics("nauvis")
    end

    flush_log(item_consumption, item_statistics, -1)
    flush_log(item_production, item_statistics, 1)
    flush_log(fluid_consumption, fluid_statistics, -1)
    flush_log(fluid_production, fluid_statistics, 1)
end

local function record_population(current_tick)
    for _, tier in pairs(population_history_tiers) do
        if current_tick % tier.interval == 0 then
            local buffer = population_history[tier.name]
            buffer.data[buffer.index] = sample_population()
            buffer.index = (buffer.index % buffer.size) + 1
        end
    end
end

--- Returns the population snapshot from n intervals ago for the given tier.
--- Returns nil if no data exists at that position.
--- @param tier_name string "fine", "medium", or "coarse"
--- @param n integer how many intervals ago (1 = most recent snapshot)
--- @return table? snapshot {[caste_id] = count}
function Statistics.get_population_snapshot(tier_name, n)
    local buffer = population_history[tier_name]
    if not buffer then return nil end

    -- index points to the next write position, so the most recent entry is at index - 1
    local pos = ((buffer.index - 1 - n) % buffer.size) + 1
    return buffer.data[pos]
end

---------------------------------------------------------------------------------------------------
-- << general >>

function Statistics.update(current_tick)
    flush_statistics()
    record_population(current_tick)
end

return Statistics
