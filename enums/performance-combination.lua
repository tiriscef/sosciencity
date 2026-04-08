--- Enum table for the combination mode of a performance effect.
--- @enum PerformanceCombination
local PerformanceCombination = {}

--- only the lowest value in the group limits the result
PerformanceCombination.bottleneck = 1
--- values multiply together
PerformanceCombination.multiplier = 2
--- values are summed
PerformanceCombination.flat = 3

return PerformanceCombination
