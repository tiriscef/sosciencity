local Dim = require("enums.performance-dimension")
local PE = require("enums.performance-effect")

--- Static lookup tables for performance effect labels and descriptions.
--- The GUI uses these to resolve the enum keys stored in performance reports.
local PerformanceEffects = {}

PerformanceEffects.labels = {
    [PE.workforce] = {"sosciencity.workforce"},
    [PE.nearby_population] = {"sosciencity.nearby-population"},
    [PE.observatory_competition] = {"sosciencity.observatory-competition"},
    [PE.caste_diversity] = {"sosciencity.caste-diversity"},
    [PE.waterwell_competition] = {"sosciencity.competition"},
    [PE.maintenance] = {"sosciencity.maintenance"},
    [PE.water_tiles] = {"sosciencity.water"},
    [PE.fishing_competition] = {"sosciencity.competition"}
}

PerformanceEffects.descriptions = {
    [PE.workforce] = {"sosciencity.describe-workforce"},
    [PE.nearby_population] = {"sosciencity.describe-nearby-population"},
    [PE.observatory_competition] = {"sosciencity.describe-observatory-competition"},
    [PE.caste_diversity] = {"sosciencity.describe-caste-diversity"},
    [PE.waterwell_competition] = {"sosciencity.describe-waterwell-competition"},
    [PE.maintenance] = {"sosciencity.describe-maintenance"},
    [PE.water_tiles] = {"sosciencity.describe-water-tiles"},
    [PE.fishing_competition] = {"sosciencity.describe-fishing-competition"}
}

PerformanceEffects.dimension_labels = {
    [Dim.speed] = {"sosciencity.performance-report-speed"},
    [Dim.productivity] = {"sosciencity.performance-report-productivity"}
}

return PerformanceEffects
