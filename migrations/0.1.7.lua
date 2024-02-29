local Gender = require("enums.gender")
local TypeGroup = require("constants.type-groups")
local EK = require("enums.entry-key")

require("classes.register")
Register.load()
require("classes.inhabitants")
Inhabitants.load()

-- attempt to repair broken InhabitantGroups

local function repair(group)
    local count = group[EK.inhabitants]

    local disease_count = Tirislib.Tables.sum(group[EK.diseases])
    if disease_count > count then
        DiseaseGroup.take(group[EK.diseases], disease_count - count)
    end
    if disease_count < count then
        DiseaseGroup.merge(group[EK.diseases], DiseaseGroup.new(count - disease_count), true)
    end

    local gender_count = Tirislib.Tables.sum(group[EK.genders])
    if gender_count > count then
        GenderGroup.take(group[EK.genders], gender_count - count)
    end
    if gender_count < count then
        group[EK.genders][Gender.agender] = group[EK.genders][Gender.agender] + count - gender_count
    end

    local age_count = Tirislib.Tables.sum(group[EK.ages])
    if age_count > count then
        AgeGroup.take(group[EK.ages], age_count - count)
    end
    if age_count < count then
        AgeGroup.merge(group[EK.ages], AgeGroup.new(count - disease_count), true)
    end
end

for _, caste in pairs(TypeGroup.all_castes) do
    for _, house in Register.all_of_type(caste) do
        repair(house)
    end

    for _, group in pairs(global.homeless) do
        repair(group)
    end
end