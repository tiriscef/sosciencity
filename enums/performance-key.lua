--- Enum table for the fields of a performance report entry.
--- @enum PerformanceKey
local PK = {}

--- the named effect identifier (maps to labels/descriptions)
PK.effect = 1
--- the numeric value of this effect
PK.value = 2
--- the performance dimension (speed, productivity, ...)
PK.dimension = 3
--- how this effect combines with others (bottleneck, multiplier, flat)
PK.combination = 4
--- optional group number for staged calculations
PK.group = 5
--- optional detail locale for contextual information
PK.detail = 6
--- the effects array in a performance report
PK.effects = 7
--- the results table in a performance report
PK.results = 8

return PK
