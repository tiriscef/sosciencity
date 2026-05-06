local TechEffects = {}

-- Downtime multiplier at each moving-efficiency level (0 = no research).
TechEffects.moving_efficiency_factors = {[0] = 1.0, [1] = 0.9, [2] = 0.7, [3] = 0.4}

-- Fraction of total city population redistributed per passive redistribution pass.
-- Level 0 = base rate (passive-redistribution researched, no efficiency techs).
TechEffects.redistribution_budget_fractions = {[0] = 0.02, [1] = 0.04, [2] = 0.06}

return TechEffects
