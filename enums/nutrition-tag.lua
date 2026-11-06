--- Enum for nutritional role tags on food items.
--- A food can have multiple tags. Their effects are defined in InhabitantsConstants.nutrition_tag_effects.
--- @enum NutritionTag
local NutritionTag = {}

NutritionTag.protein_rich = 1
NutritionTag.fat_rich = 2
NutritionTag.carb_rich = 3
NutritionTag.vitamin_rich = 4
NutritionTag.fiber_rich = 5
NutritionTag.mineral_rich = 6
-- huwan-specific nutrients
NutritionTag.lucidin_rich = 7
NutritionTag.purpurin_rich = 8
NutritionTag.ovolin_rich = 9

return NutritionTag
