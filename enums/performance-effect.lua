--- Enum table for named performance effects.
--- Maps to labels and descriptions in constants/performance-effects.lua.
--- @enum PerformanceEffect
local PE = {}

--- workforce staffing level
PE.workforce = 1
--- nearby population count
PE.nearby_population = 2
--- competition from nearby observatories
PE.observatory_competition = 3
--- caste diversity bonus
PE.caste_diversity = 4
--- competition from nearby waterwells
PE.waterwell_competition = 5
--- clockwork caste maintenance bonus
PE.maintenance = 6
--- water tile availability
PE.water_tiles = 7
--- competition from nearby fisheries
PE.fishing_competition = 8
--- worker happiness multiplier
PE.worker_happiness = 9
--- tree availability for hunting
PE.trees = 10
--- competition from nearby hunting huts
PE.hunting_competition = 11
--- mining drill productivity research bonus
PE.mining_productivity = 12

return PE
