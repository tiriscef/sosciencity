local Assert = Tirislib.Testing.Assert

---------------------------------------------------------------------------------------------------
-- << helpers >>

local saved_history
local saved_population

local function setup_fresh_history()
    saved_history = storage.population_history
    saved_population = storage.population

    storage.population_history = {}
    for _, tier in pairs(Statistics.population_history_tiers) do
        storage.population_history[tier.name] = {
            data = {},
            index = 1,
            size = tier.size
        }
    end
    storage.population = storage.population or {}
    Statistics.load()
end

local function restore_history()
    storage.population_history = saved_history
    storage.population = saved_population
    Statistics.load()
end

local function save_history()
    saved_history = storage.population_history
    saved_population = storage.population
end

local function find_tier(name)
    for _, tier in pairs(Statistics.population_history_tiers) do
        if tier.name == name then return tier end
    end
end

---------------------------------------------------------------------------------------------------
-- << init structure >>

Tirislib.Testing.add_test_case(
    "Statistics.init creates all three population history tiers with correct sizes",
    "statistics",
    function()
        for _, tier in pairs(Statistics.population_history_tiers) do
            local buffer = storage.population_history[tier.name]
            Assert.not_nil(buffer, "tier '" .. tier.name .. "' should exist")
            Assert.equals(buffer.size, tier.size, "tier '" .. tier.name .. "' size")
            Assert.not_nil(buffer.data, "tier '" .. tier.name .. "' data should be initialized")
            Assert.not_nil(buffer.index, "tier '" .. tier.name .. "' index should be initialized")
        end
    end
)

---------------------------------------------------------------------------------------------------
-- << get_population_snapshot read math >>

Tirislib.Testing.add_test_case(
    "get_population_snapshot returns nil when buffer has no data",
    "statistics",
    function()
        Assert.is_nil(Statistics.get_population_snapshot("fine", 1))
    end,
    setup_fresh_history,
    restore_history
)

Tirislib.Testing.add_test_case(
    "get_population_snapshot returns nil for unknown tier",
    "statistics",
    function()
        Assert.is_nil(Statistics.get_population_snapshot("nonexistent", 1))
    end
)

Tirislib.Testing.add_test_case(
    "get_population_snapshot n=1 returns the most recent snapshot",
    "statistics",
    function()
        local snap_a = {[1] = 5, [2] = 3}
        local snap_b = {[1] = 10, [2] = 7}
        local snap_c = {[1] = 15, [2] = 1}

        -- data[1]=snap_a, data[2]=snap_b, data[3]=snap_c; index=4 means snap_c was last written
        storage.population_history = {
            fine = {data = {snap_a, snap_b, snap_c}, index = 4, size = 120}
        }
        Statistics.load()

        Assert.equals(Statistics.get_population_snapshot("fine", 1), snap_c, "n=1 should be most recent")
        Assert.equals(Statistics.get_population_snapshot("fine", 2), snap_b)
        Assert.equals(Statistics.get_population_snapshot("fine", 3), snap_a)
        Assert.is_nil(Statistics.get_population_snapshot("fine", 4), "n=4 should be nil - no data at pos 120")
    end,
    save_history,
    restore_history
)

Tirislib.Testing.add_test_case(
    "get_population_snapshot reads correctly across the wrap boundary",
    "statistics",
    function()
        -- 7 writes into a size-5 buffer: positions were written in order 3,4,5,1,2
        -- index is now 3 again, pointing at the oldest surviving entry
        local snap_oldest = {[1] = 1}  -- 3rd write, at pos 3 (next to be overwritten)
        local snap_4th    = {[1] = 2}  -- 4th write, at pos 4
        local snap_5th    = {[1] = 3}  -- 5th write, at pos 5
        local snap_6th    = {[1] = 4}  -- 6th write (wrapped), at pos 1
        local snap_latest = {[1] = 5}  -- 7th write (most recent), at pos 2

        storage.population_history = {
            fine = {
                data = {snap_6th, snap_latest, snap_oldest, snap_4th, snap_5th},
                index = 3,  -- next write goes to pos 3
                size = 5
            }
        }
        Statistics.load()

        Assert.equals(Statistics.get_population_snapshot("fine", 1), snap_latest)
        Assert.equals(Statistics.get_population_snapshot("fine", 2), snap_6th)
        Assert.equals(Statistics.get_population_snapshot("fine", 3), snap_5th)  -- across the wrap
        Assert.equals(Statistics.get_population_snapshot("fine", 4), snap_4th)
        Assert.equals(Statistics.get_population_snapshot("fine", 5), snap_oldest)
    end,
    save_history,
    restore_history
)

---------------------------------------------------------------------------------------------------
-- << circular buffer write behavior >>

Tirislib.Testing.add_test_case(
    "buffer index wraps back to 1 after buffer_size writes",
    "statistics",
    function()
        local fine = find_tier("fine")

        for i = 1, fine.size do
            Statistics.update(fine.interval * i)
        end

        Assert.equals(storage.population_history["fine"].index, 1, "index should wrap to 1 after size writes")
    end,
    setup_fresh_history,
    restore_history
)

Tirislib.Testing.add_test_case(
    "write after wrap overwrites oldest entry and advances index to 2",
    "statistics",
    function()
        local fine = find_tier("fine")

        for i = 1, fine.size + 1 do
            Statistics.update(fine.interval * i)
        end

        Assert.equals(storage.population_history["fine"].index, 2)
        Assert.not_nil(Statistics.get_population_snapshot("fine", 1))
    end,
    setup_fresh_history,
    restore_history
)

Tirislib.Testing.add_test_case(
    "each tier only samples at its own interval",
    "statistics",
    function()
        local fine_interval = find_tier("fine").interval  -- 3600; not a multiple of medium (36000) or coarse (216000)

        local before_fine   = storage.population_history["fine"].index
        local before_medium = storage.population_history["medium"].index
        local before_coarse = storage.population_history["coarse"].index

        Statistics.update(fine_interval)

        Assert.equals(storage.population_history["fine"].index,   before_fine + 1, "fine should advance")
        Assert.equals(storage.population_history["medium"].index, before_medium,    "medium should not advance")
        Assert.equals(storage.population_history["coarse"].index, before_coarse,    "coarse should not advance")
    end,
    setup_fresh_history,
    restore_history
)
