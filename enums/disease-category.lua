--- Enum table for disease categories
local DiseaseCategory = {}

--XXX: DiseaseCategory and DiseasedCause likely could be merged

--- consequences of bad health, distributed over time
DiseaseCategory.health = 1
--- consequences of bad sanity, distributed over time
DiseaseCategory.sanity = 2
--- consequences of work related accidents, distributed over time
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

return DiseaseCategory
