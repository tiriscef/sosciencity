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

-- Number of hidden binary technologies per caste bonus (gunfire, foundry, gleam). Tier i adds
-- 0.01 * 2^i, so they encode bonuses up to 2^n - 1 percent. 
-- Kept at 17 so that no single tier exceeds 1000: other mods tend to convert bonuses and some are capped at 1000.
-- So these won't run into a problem. And 2^17 is still way higher than anything a map should be able to achieve.
TechEffects.binary_tech_count = 17
TechEffects.binary_tech_max_value = 2 ^ TechEffects.binary_tech_count - 1

return TechEffects
