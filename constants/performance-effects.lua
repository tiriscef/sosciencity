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
    [PE.fishing_competition] = {"sosciencity.competition"},
    [PE.worker_happiness] = {"sosciencity.worker-happiness"},
    [PE.trees] = {"sosciencity.trees"},
    [PE.hunting_competition] = {"sosciencity.competition"},
    [PE.mining_productivity] = {"sosciencity.mining-productivity"},
    [PE.humus_fertilization] = {"sosciencity.humus-fertilization"},
    [PE.growth_variance] = {"sosciencity.growth-variance"},
    [PE.required_module] = {"sosciencity.required-module"},
    [PE.orchid_caste_bonus] = {"sosciencity.orchid-caste-bonus"},
    [PE.pruning] = {"sosciencity.pruning"},
    [PE.biomass] = {"sosciencity.biomass"}
}

PerformanceEffects.descriptions = {
    [PE.workforce] = {"sosciencity.describe-workforce"},
    [PE.nearby_population] = {"sosciencity.describe-nearby-population"},
    [PE.observatory_competition] = {"sosciencity.describe-observatory-competition"},
    [PE.caste_diversity] = {"sosciencity.describe-caste-diversity"},
    [PE.waterwell_competition] = {"sosciencity.describe-waterwell-competition"},
    [PE.maintenance] = {"sosciencity.describe-maintenance"},
    [PE.water_tiles] = {"sosciencity.describe-water-tiles"},
    [PE.fishing_competition] = {"sosciencity.describe-fishing-competition"},
    [PE.worker_happiness] = {"sosciencity.describe-worker-happiness"},
    [PE.trees] = {"sosciencity.describe-trees"},
    [PE.hunting_competition] = {"sosciencity.describe-hunting-competition"},
    [PE.mining_productivity] = {"sosciencity.describe-mining-productivity"},
    [PE.humus_fertilization] = {"sosciencity.describe-humus-fertilization"},
    [PE.growth_variance] = {"sosciencity.describe-growth-variance"},
    [PE.required_module] = {"sosciencity.describe-required-module"},
    [PE.orchid_caste_bonus] = {"sosciencity.describe-orchid-caste-bonus"},
    [PE.pruning] = {"sosciencity.describe-pruning"},
    [PE.biomass] = {"sosciencity.describe-biomass"}
}

PerformanceEffects.dimension_labels = {
    [Dim.speed] = {"sosciencity.performance-report-speed"},
    [Dim.productivity] = {"sosciencity.performance-report-productivity"}
}

return PerformanceEffects
