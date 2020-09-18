require("lib.testing")
require("lib.utils")

local Assert = Tiristest.Assert
local Tbl = Tirislib_Tables

Tiristest.add_test_case(
    "AgeGroup.new",
    "inhabitants|age",
    function()
        local age_group = AgeGroup.new(5, 5)
        Assert.equals(age_group[5], 5)
        Assert.equals(Tbl.sum(age_group), 5)

        age_group = AgeGroup.new(5)
        Assert.equals(age_group[0], 5)
        Assert.equals(Tbl.sum(age_group), 5)

        age_group = AgeGroup.new(0)
        Assert.equals(age_group, {})
        Assert.equals(Tbl.sum(age_group), 0)
    end
)

Tiristest.add_test_case(
    "AgeGroup.random_new",
    "inhabitants|age",
    function()
        local age_group =
            AgeGroup.random_new(
            5,
            function()
                return 5
            end
        )
        Assert.equals(age_group[5], 5)

        age_group =
            AgeGroup.random_new(
            35,
            function()
                return math.random(1, 100)
            end
        )
        Assert.equals(Tbl.sum(age_group), 35)
    end
)

Tiristest.add_test_case(
    "AgeGroup.merge",
    "inhabitants|age",
    function()
        local age_group = AgeGroup.new(10, 10)
        local other_age_group = AgeGroup.new(20, 20)
        AgeGroup.merge(age_group, other_age_group)

        Assert.equals(age_group[10], 10)
        Assert.equals(age_group[20], 20)
        Assert.equals(Tbl.sum(age_group), 30)
        Assert.equals(Tbl.sum(other_age_group), 0)

        age_group = AgeGroup.new(10, 10)
        other_age_group = AgeGroup.new(20, 20)
        AgeGroup.merge(age_group, other_age_group, true)

        Assert.equals(Tbl.sum(other_age_group), 20)
    end
)

Tiristest.add_test_case(
    "AgeGroup.take",
    "inhabitants|age",
    function()
        local age_group =
            AgeGroup.random_new(
            50,
            function()
                return math.random(1, 100)
            end
        )
        local copy = Tbl.copy(age_group)

        local taken = AgeGroup.take(age_group, 10)

        Assert.equals(Tbl.sum(taken), 10)

        AgeGroup.merge(age_group, taken)
        Assert.equals(copy, age_group)

        taken = AgeGroup.take(age_group, 0)
        Assert.equals(Tbl.sum(taken), 0)

        taken = AgeGroup.take(age_group, 100)
        Assert.equals(Tbl.sum(taken), 50)
    end
)

local function DiseaseGroup_count_people(group)
    local ret = 0

    for _, entry in pairs(group) do
        ret = ret + entry[DiseaseGroup.count]
    end

    return ret
end

local function DiseaseGroup_construct_random_group()
    local group = DiseaseGroup.new(math.random(0, 5))

    for i = 1, math.random(2, 7) do
        DiseaseGroup.add_persons(group, math.random(5, 15), {i})
    end
end

Tiristest.add_test_case(
    "DiseaseGroup.new",
    "inhabitants|disease",
    function()
        local age_group = DiseaseGroup.new(5)
        Assert.equals(DiseaseGroup_count_people(age_group), 5)

        age_group = DiseaseGroup.new(0)
        Assert.equals(DiseaseGroup_count_people(age_group), 0)

        age_group = DiseaseGroup.new(10, {"disease"})
        Assert.equals(DiseaseGroup_count_people(age_group), 10)
        Assert.equals(DiseaseGroup[DiseaseGroup.healthy_entry][DiseaseGroup.count], 0)
    end
)

Tiristest.add_test_case(
    "DiseaseGroup.merge",
    "inhabitants|disease",
    function()
        local group = DiseaseGroup.new(10)
        local other_group = DiseaseGroup.new(20, {"disease"})
        DiseaseGroup.merge(group, other_group)

        Assert.equals(DiseaseGroup_count_people(group), 30)
        Assert.equals(DiseaseGroup_count_people(other_group), 0)

        group = DiseaseGroup.new(10)
        other_group = DiseaseGroup.new(20)
        DiseaseGroup.merge(group, other_group, true)

        Assert.equals(DiseaseGroup_count_people(other_group), 20)
    end
)

Tiristest.add_test_case(
    "DiseaseGroup.take",
    "inhabitants|disease",
    function()
        local group = DiseaseGroup_construct_random_group()
        local copy = Tbl.copy(group)

        local taken = DiseaseGroup.take(group, 10)
        Assert.equals(DiseaseGroup_count_people(taken), 10)

        DiseaseGroup.merge(group, taken)
        Assert.equals(group, copy)

        taken = DiseaseGroup.take(group, 0)
        Assert.equals(DiseaseGroup_count_people(taken), 0)

        local count = DiseaseGroup_count_people(group)
        taken = DiseaseGroup.take(group, count + 350)
        Assert.equals(DiseaseGroup_count_people(taken), count)
    end
)

Tiristest.add_test_case(
    "GenderGroup.new",
    "inhabitants|gender",
    function()
        for _, caste_id in pairs(TypeGroup.all_castes) do
            local gender_group = GenderGroup.new(10, caste_id)
            Assert.equals(Tbl.sum(gender_group), 10)

            gender_group = GenderGroup.new(3, caste_id)
            Assert.equals(Tbl.sum(gender_group), 3)

            gender_group = GenderGroup.new(0, caste_id)
            Assert.equals(Tbl.sum(gender_group), 0)

            Assert.not_nil(gender_group[Gender.fale])
            Assert.not_nil(gender_group[Gender.ga])
            Assert.not_nil(gender_group[Gender.neutral])
            Assert.not_nil(gender_group[Gender.pachin])
        end
    end
)

Tiristest.add_test_case(
    "GenderGroup.merge",
    "inhabitants|gender",
    function()
        local gender_group = GenderGroup.new(10, Type.clockwork)
        local other_gender_group = GenderGroup.new(20, Type.clockwork)
        GenderGroup.merge(gender_group, other_gender_group)

        Assert.equals(Tbl.sum(gender_group), 30)
        Assert.equals(Tbl.sum(other_gender_group), 0)

        Assert.not_nil(other_gender_group[Gender.fale])
        Assert.not_nil(other_gender_group[Gender.ga])
        Assert.not_nil(other_gender_group[Gender.neutral])
        Assert.not_nil(other_gender_group[Gender.pachin])

        gender_group = GenderGroup.new(10, Type.clockwork)
        other_gender_group = GenderGroup.new(20, Type.clockwork)
        GenderGroup.merge(gender_group, other_gender_group, true)

        Assert.equals(Tbl.sum(other_gender_group), 20)
    end
)

Tiristest.add_test_case(
    "GenderGroup.take",
    "inhabitants|gender",
    function()
        local gender_group = GenderGroup.new(50, Type.clockwork)
        local copy = Tbl.copy(gender_group)

        local taken = GenderGroup.take(gender_group, 10)

        Assert.equals(Tbl.sum(taken), 10)

        GenderGroup.merge(gender_group, taken)
        Assert.equals(copy, gender_group)

        taken = GenderGroup.take(gender_group, 0)
        Assert.equals(Tbl.sum(taken), 0)
        Assert.not_nil(taken[Gender.fale])
        Assert.not_nil(taken[Gender.ga])
        Assert.not_nil(taken[Gender.neutral])
        Assert.not_nil(taken[Gender.pachin])

        taken = GenderGroup.take(gender_group, 100)
        Assert.equals(Tbl.sum(taken), 50)
    end
)
