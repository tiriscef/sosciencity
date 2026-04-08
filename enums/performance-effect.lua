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

return PE
