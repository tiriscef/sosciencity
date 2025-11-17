--- Enum table for disease categories
--- @enum DiseaseCategory
local DiseaseCategory = {}

--- consequences of bad health, distributed over time
DiseaseCategory.health = 1
--- consequences of bad sanity, distributed over time
DiseaseCategory.sanity = 2
--- non-work-related accidents, distributed over time
DiseaseCategory.accident = 3
--- consequences of genetic dispositions or complications during upbringing, distributed on birth
DiseaseCategory.birth_defect = 4
--- diseases stemming from sick animals, distributed over time
DiseaseCategory.zoonosis = 5
--- diseases that spread on social events
DiseaseCategory.infection = 6
--- diseases that are a consequence of another untreated disease
DiseaseCategory.escalation = 7
--- diseases that are a consequence of another disease's treatment
DiseaseCategory.complication = 8
--- diseases that are a consequence of not providing enough food
DiseaseCategory.malnutrition = 9
--- diseases that are a consequence of not providing enough drinking water
DiseaseCategory.dehydration = 10
--- diseases that are a consequence of providing unsafe food
DiseaseCategory.food_poisoning = 11
--- diseases that are a consequence of not providing enough drinking water
DiseaseCategory.water_poisoning = 12

-- Categories for work-related diseases

--- Accidents/Diseases that occur in very demanding jobs
DiseaseCategory.hard_work = 20
--- Accidents/Diseases that occur in typical office jobs
DiseaseCategory.office_work = 21
--- Addidents/Diseases that occur in moderately demanding jobs
DiseaseCategory.moderate_work = 22
--- Accidents/Diseases that occur when working in the Fishing Hut
DiseaseCategory.fishing_hut = 30
--- Accidents/Diseases that occur when working in the Hunting/Gathering Hut
DiseaseCategory.hunting_hut = 31

return DiseaseCategory
