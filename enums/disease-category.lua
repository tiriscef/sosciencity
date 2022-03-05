--- Enum table for disease categories
local DiseaseCategory = {}

--- consequences of bad healthiness
DiseaseCategory.health = 1
--- consequences of bad sanity
DiseaseCategory.sanity = 2
--- consequences of work related accidents
DiseaseCategory.accident = 3
--- consequences of genetic dispositions or complications during upbringing
DiseaseCategory.birth_defect = 4
--- infectious diseases steming from sick animals
DiseaseCategory.zoonosis = 5

return DiseaseCategory
