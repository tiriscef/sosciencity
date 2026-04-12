--- Enum for nutritional role tags on food items.
--- A food can have multiple tags. Each covered tag contributes to health.
--- @enum NutritionTag
local NutritionTag = {}

NutritionTag.protein_rich = 1
NutritionTag.fat_rich = 2
NutritionTag.carb_rich = 3

return NutritionTag
