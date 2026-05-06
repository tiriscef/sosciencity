local TechEffects = {}

-- Downtime multiplier at each moving-efficiency level (0 = no research).
TechEffects.moving_efficiency_factors = {[0] = 1.0, [1] = 0.9, [2] = 0.7, [3] = 0.4}

-- Fraction of total city population redistributed per passive redistribution pass.
-- Level 0 = base rate (passive-redistribution researched, no efficiency techs).
TechEffects.redistribution_budget_fractions = {[0] = 0.02, [1] = 0.04, [2] = 0.06}

-- Multiplier applied per level of improved-reproductive-healthcare. Multiply birth-defect
-- probabilities by this value raised to the research level.
TechEffects.reproductive_healthcare_level_factor = 0.8

-- Multiplier applied per level of caste efficiency techs to caste point output.
TechEffects.caste_efficiency_points_per_level = 0.1

return TechEffects
