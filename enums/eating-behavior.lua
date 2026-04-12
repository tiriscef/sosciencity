--- Enum for the diet construction personality of a caste.
--- Controls which foods are included in the diet and in what order.
--- @enum EatingBehavior
local EatingBehavior = {}

EatingBehavior.minimalist = 1 -- picks only foods needed to cover nutrition tags
EatingBehavior.mixed = 2 -- includes all favored-taste foods, then fills missing tags and minimum_food_count by quality
EatingBehavior.foodie = 3 -- includes all favored and neutral foods; never eats disliked foods

return EatingBehavior
