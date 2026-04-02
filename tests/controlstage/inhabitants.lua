local Assert = Tirislib.Testing.Assert
local EK = require("enums.entry-key")

local Table = Tirislib.Tables

local HEALTHY = DiseaseGroup.HEALTHY

---------------------------------------------------------------------------------------------------
-- << DiseaseGroup tests >>

Tirislib.Testing.add_test_case(
    "DiseaseGroup.new creates a group with the given healthy count",
    "inhabitants",
    function()
        local group = DiseaseGroup.new(10)
        Assert.equals(group[HEALTHY], 10)
    end
)

Tirislib.Testing.add_test_case(
    "DiseaseGroup.make_sick moves people from healthy to sick",
    "inhabitants",
    function()
        local group = DiseaseGroup.new(10)
        local sickened = DiseaseGroup.make_sick(group, 1, 3)

        Assert.equals(sickened, 3)
        Assert.equals(group[HEALTHY], 7)
        Assert.equals(group[1], 3)
    end
)

Tirislib.Testing.add_test_case(
    "DiseaseGroup.make_sick caps at healthy count",
    "inhabitants",
    function()
        local group = DiseaseGroup.new(2)
        local sickened = DiseaseGroup.make_sick(group, 1, 5)

        Assert.equals(sickened, 2)
        Assert.equals(group[HEALTHY], 0)
        Assert.equals(group[1], 2)
    end
)

Tirislib.Testing.add_test_case(
    "DiseaseGroup.cure moves people from sick to healthy",
    "inhabitants",
    function()
        local group = DiseaseGroup.new(10)
        DiseaseGroup.make_sick(group, 1, 5)

        local cured = DiseaseGroup.cure(group, 1, 3)

        Assert.equals(cured, 3)
        Assert.equals(group[HEALTHY], 8)
        Assert.equals(group[1], 2)
    end
)

Tirislib.Testing.add_test_case(
    "DiseaseGroup.cure removes disease key when all are cured",
    "inhabitants",
    function()
        local group = DiseaseGroup.new(10)
        DiseaseGroup.make_sick(group, 1, 3)
        DiseaseGroup.cure(group, 1, 3)

        Assert.equals(group[HEALTHY], 10)
        Assert.is_nil(group[1])
    end
)

Tirislib.Testing.add_test_case(
    "DiseaseGroup.merge combines two groups",
    "inhabitants",
    function()
        local lh = DiseaseGroup.new(5)
        DiseaseGroup.make_sick(lh, 1, 2)

        local rh = DiseaseGroup.new(3)
        DiseaseGroup.make_sick(rh, 1, 1)
        DiseaseGroup.make_sick(rh, 2, 1)

        DiseaseGroup.merge(lh, rh)

        Assert.equals(lh[HEALTHY], 4)
        Assert.equals(lh[1], 3)
        Assert.equals(lh[2], 1)

        -- rh should be emptied
        Assert.equals(rh[HEALTHY], 0)
    end
)

Tirislib.Testing.add_test_case(
    "DiseaseGroup.merge with keep_rh preserves rh",
    "inhabitants",
    function()
        local lh = DiseaseGroup.new(5)
        local rh = DiseaseGroup.new(3)

        DiseaseGroup.merge(lh, rh, true)

        Assert.equals(lh[HEALTHY], 8)
        Assert.equals(rh[HEALTHY], 3, "rh should be preserved")
    end
)

Tirislib.Testing.add_test_case(
    "DiseaseGroup.take extracts proportional sample",
    "inhabitants",
    function()
        local group = DiseaseGroup.new(8)
        DiseaseGroup.make_sick(group, 1, 2)
        -- total: 8 healthy + 2 sick = 10

        local taken = DiseaseGroup.take(group, 5, 10)

        -- taken + remaining should equal the original total
        local taken_total = Table.sum(taken)
        local remaining_total = Table.sum(group)
        Assert.equals(taken_total + remaining_total, 10)
        Assert.equals(taken_total, 5)
    end
)

Tirislib.Testing.add_test_case(
    "DiseaseGroup.take with to_take exceeding total takes everything",
    "inhabitants",
    function()
        local group = DiseaseGroup.new(3)
        local taken = DiseaseGroup.take(group, 10)

        Assert.equals(Table.sum(taken), 3)
        Assert.equals(group[HEALTHY], 0)
    end
)

Tirislib.Testing.add_test_case(
    "DiseaseGroup.subtract removes counts correctly",
    "inhabitants",
    function()
        local lh = DiseaseGroup.new(10)
        DiseaseGroup.make_sick(lh, 1, 5)

        local rh = {[HEALTHY] = 3, [1] = 2}
        DiseaseGroup.subtract(lh, rh)

        Assert.equals(lh[HEALTHY], 2)
        Assert.equals(lh[1], 3)
    end
)

Tirislib.Testing.add_test_case(
    "DiseaseGroup.subtract removes disease key when count reaches zero",
    "inhabitants",
    function()
        local lh = DiseaseGroup.new(5)
        DiseaseGroup.make_sick(lh, 1, 3)

        local rh = {[1] = 3}
        DiseaseGroup.subtract(lh, rh)

        Assert.is_nil(lh[1])
    end
)

Tirislib.Testing.add_test_case(
    "DiseaseGroup.subtract errors on incompatible groups",
    "inhabitants",
    function()
        local lh = DiseaseGroup.new(5)
        local rh = {[HEALTHY] = 10}

        Assert.throws(function()
            DiseaseGroup.subtract(lh, rh)
        end)
    end
)

Tirislib.Testing.add_test_case(
    "DiseaseGroup.not_healthy returns false for HEALTHY, true otherwise",
    "inhabitants",
    function()
        Assert.is_false(DiseaseGroup.not_healthy(HEALTHY))
        Assert.is_true(DiseaseGroup.not_healthy(1))
        Assert.is_true(DiseaseGroup.not_healthy(999))
    end
)

---------------------------------------------------------------------------------------------------
-- << AgeGroup tests >>

Tirislib.Testing.add_test_case(
    "AgeGroup.new creates a group with given count at given age",
    "inhabitants",
    function()
        local group = AgeGroup.new(5, 30)
        Assert.equals(group[30], 5)
    end
)

Tirislib.Testing.add_test_case(
    "AgeGroup.new defaults to age 0",
    "inhabitants",
    function()
        local group = AgeGroup.new(3)
        Assert.equals(group[0], 3)
    end
)

Tirislib.Testing.add_test_case(
    "AgeGroup.new with 0 count creates empty group",
    "inhabitants",
    function()
        local group = AgeGroup.new(0)
        Assert.equals(Table.sum(group), 0)
    end
)

Tirislib.Testing.add_test_case(
    "AgeGroup.merge combines two groups",
    "inhabitants",
    function()
        local lh = AgeGroup.new(3, 20)
        local rh = AgeGroup.new(2, 20)
        rh[30] = 1

        AgeGroup.merge(lh, rh)

        Assert.equals(lh[20], 5)
        Assert.equals(lh[30], 1)

        -- rh should be emptied
        Assert.equals(Table.sum(rh), 0)
    end
)

Tirislib.Testing.add_test_case(
    "AgeGroup.merge with keep_rh preserves rh",
    "inhabitants",
    function()
        local lh = AgeGroup.new(3, 20)
        local rh = AgeGroup.new(2, 30)

        AgeGroup.merge(lh, rh, true)

        Assert.equals(lh[20], 3)
        Assert.equals(lh[30], 2)
        Assert.equals(rh[30], 2, "rh should be preserved")
    end
)

Tirislib.Testing.add_test_case(
    "AgeGroup.take conserves total population",
    "inhabitants",
    function()
        local group = {[20] = 5, [30] = 3, [40] = 2}
        local taken = AgeGroup.take(group, 4)

        Assert.equals(Table.sum(taken) + Table.sum(group), 10)
        Assert.equals(Table.sum(taken), 4)
    end
)

Tirislib.Testing.add_test_case(
    "AgeGroup.take removes nil entries for zero-count ages",
    "inhabitants",
    function()
        local group = {[20] = 1}
        local taken = AgeGroup.take(group, 1)

        Assert.is_nil(group[20])
        Assert.equals(taken[20], 1)
    end
)

Tirislib.Testing.add_test_case(
    "AgeGroup.subtract removes counts correctly",
    "inhabitants",
    function()
        local lh = {[20] = 5, [30] = 3}
        local rh = {[20] = 2, [30] = 1}

        AgeGroup.subtract(lh, rh)

        Assert.equals(lh[20], 3)
        Assert.equals(lh[30], 2)
    end
)

Tirislib.Testing.add_test_case(
    "AgeGroup.subtract errors on incompatible groups",
    "inhabitants",
    function()
        local lh = {[20] = 1}
        local rh = {[20] = 5}

        Assert.throws(function()
            AgeGroup.subtract(lh, rh)
        end)
    end
)

Tirislib.Testing.add_test_case(
    "AgeGroup.shift advances all ages",
    "inhabitants",
    function()
        local group = {[20] = 3, [30] = 2}
        AgeGroup.shift(group, 5)

        Assert.is_nil(group[20])
        Assert.is_nil(group[30])
        Assert.equals(group[25], 3)
        Assert.equals(group[35], 2)
    end
)

Tirislib.Testing.add_test_case(
    "AgeGroup.random_new produces the correct total count",
    "inhabitants",
    function()
        local group = AgeGroup.random_new(50, function() return 25 end)
        Assert.equals(Table.sum(group), 50)
    end
)

---------------------------------------------------------------------------------------------------
-- << GenderGroup tests >>

Tirislib.Testing.add_test_case(
    "GenderGroup.new creates a group with specified counts",
    "inhabitants",
    function()
        local group = GenderGroup.new(1, 2, 3, 4)
        Assert.equals(group, {1, 2, 3, 4})
    end
)

Tirislib.Testing.add_test_case(
    "GenderGroup.new defaults to all zeros",
    "inhabitants",
    function()
        local group = GenderGroup.new()
        Assert.equals(group, {0, 0, 0, 0})
    end
)

Tirislib.Testing.add_test_case(
    "GenderGroup.merge combines two groups",
    "inhabitants",
    function()
        local lh = GenderGroup.new(1, 2, 3, 4)
        local rh = GenderGroup.new(4, 3, 2, 1)

        GenderGroup.merge(lh, rh)

        Assert.equals(lh, {5, 5, 5, 5})
        -- rh should be zeroed
        Assert.equals(rh, {0, 0, 0, 0})
    end
)

Tirislib.Testing.add_test_case(
    "GenderGroup.merge with keep_rh preserves rh",
    "inhabitants",
    function()
        local lh = GenderGroup.new(1, 2, 3, 4)
        local rh = GenderGroup.new(4, 3, 2, 1)

        GenderGroup.merge(lh, rh, true)

        Assert.equals(lh, {5, 5, 5, 5})
        Assert.equals(rh, {4, 3, 2, 1}, "rh should be preserved")
    end
)

Tirislib.Testing.add_test_case(
    "GenderGroup.take conserves total population",
    "inhabitants",
    function()
        local group = GenderGroup.new(5, 5, 5, 5)
        local taken = GenderGroup.take(group, 8)

        local taken_total = Table.sum(taken)
        local remaining_total = Table.sum(group)
        Assert.equals(taken_total + remaining_total, 20)
        Assert.equals(taken_total, 8)
    end
)

Tirislib.Testing.add_test_case(
    "GenderGroup.take with more than total takes everything",
    "inhabitants",
    function()
        local group = GenderGroup.new(1, 1, 1, 1)
        local taken = GenderGroup.take(group, 100)

        Assert.equals(Table.sum(taken), 4)
        Assert.equals(Table.sum(group), 0)
    end
)

Tirislib.Testing.add_test_case(
    "GenderGroup.subtract removes counts correctly",
    "inhabitants",
    function()
        local lh = GenderGroup.new(5, 5, 5, 5)
        local rh = GenderGroup.new(2, 1, 3, 0)

        GenderGroup.subtract(lh, rh)

        Assert.equals(lh, {3, 4, 2, 5})
    end
)

Tirislib.Testing.add_test_case(
    "GenderGroup.subtract errors on incompatible groups",
    "inhabitants",
    function()
        local lh = GenderGroup.new(1, 1, 1, 1)
        local rh = GenderGroup.new(2, 0, 0, 0)

        Assert.throws(function()
            GenderGroup.subtract(lh, rh)
        end)
    end
)

---------------------------------------------------------------------------------------------------
-- << InhabitantGroup tests >>

-- Use clockwork (type 1) as a stand-in caste for tests.
local TEST_CASTE = 1

Tirislib.Testing.add_test_case(
    "InhabitantGroup.new creates a group with correct defaults",
    "inhabitants",
    function()
        local group = InhabitantGroup.new(TEST_CASTE, 5)

        Assert.equals(group[EK.type], TEST_CASTE)
        Assert.equals(group[EK.inhabitants], 5)
        Assert.equals(group[EK.happiness], 10)
        Assert.equals(group[EK.health], 10)
        Assert.equals(group[EK.sanity], 10)
        Assert.equals(group[EK.diseases][HEALTHY], 5)
    end
)

Tirislib.Testing.add_test_case(
    "InhabitantGroup.new with 0 count",
    "inhabitants",
    function()
        local group = InhabitantGroup.new(TEST_CASTE)

        Assert.equals(group[EK.inhabitants], 0)
        Assert.equals(group[EK.diseases][HEALTHY], 0)
    end
)

Tirislib.Testing.add_test_case(
    "InhabitantGroup.empty zeroes everything",
    "inhabitants",
    function()
        local group = InhabitantGroup.new(TEST_CASTE, 10, 15, 12, 8)
        InhabitantGroup.empty(group)

        Assert.equals(group[EK.inhabitants], 0)
        Assert.equals(group[EK.happiness], 0)
        Assert.equals(group[EK.health], 0)
        Assert.equals(group[EK.sanity], 0)
        Assert.equals(group[EK.diseases][HEALTHY], 0)
        Assert.equals(group[EK.type], TEST_CASTE, "type should be preserved")
    end
)

Tirislib.Testing.add_test_case(
    "InhabitantGroup.can_be_merged checks caste match",
    "inhabitants",
    function()
        local a = InhabitantGroup.new(TEST_CASTE, 5)
        local b = InhabitantGroup.new(TEST_CASTE, 3)
        local c = InhabitantGroup.new(2, 3)

        Assert.is_true(InhabitantGroup.can_be_merged(a, b))
        Assert.is_false(InhabitantGroup.can_be_merged(a, c))
    end
)

Tirislib.Testing.add_test_case(
    "InhabitantGroup.merge combines populations with weighted average stats",
    "inhabitants",
    function()
        local lh = InhabitantGroup.new(TEST_CASTE, 6, 12, 10, 10)
        local rh = InhabitantGroup.new(TEST_CASTE, 4, 8, 10, 10)

        InhabitantGroup.merge(lh, rh)

        Assert.equals(lh[EK.inhabitants], 10)
        -- weighted average: (6*12 + 4*8) / 10 = 10.4
        Assert.greater_than(lh[EK.happiness], 10)
        Assert.less_than(lh[EK.happiness], 12)

        -- rh should be emptied
        Assert.equals(rh[EK.inhabitants], 0)
    end
)

Tirislib.Testing.add_test_case(
    "InhabitantGroup.merge errors on caste mismatch",
    "inhabitants",
    function()
        local lh = InhabitantGroup.new(TEST_CASTE, 5)
        local rh = InhabitantGroup.new(2, 3)

        Assert.throws(function()
            InhabitantGroup.merge(lh, rh)
        end)
    end
)

Tirislib.Testing.add_test_case(
    "InhabitantGroup.merge with allow_caste_mismatch skips the check",
    "inhabitants",
    function()
        local lh = InhabitantGroup.new(TEST_CASTE, 5)
        local rh = InhabitantGroup.new(2, 3)

        -- should not error
        InhabitantGroup.merge(lh, rh, false, true)

        Assert.equals(lh[EK.inhabitants], 8)
    end
)

Tirislib.Testing.add_test_case(
    "InhabitantGroup.take conserves population and preserves stats",
    "inhabitants",
    function()
        local group = InhabitantGroup.new(TEST_CASTE, 10, 15, 12, 8)
        local taken = InhabitantGroup.take(group, 4)

        Assert.equals(group[EK.inhabitants] + taken[EK.inhabitants], 10)
        Assert.equals(taken[EK.inhabitants], 4)
        Assert.equals(group[EK.inhabitants], 6)

        -- happiness/health/sanity should be copied, not split
        Assert.equals(taken[EK.happiness], 15)
        Assert.equals(taken[EK.health], 12)
        Assert.equals(taken[EK.sanity], 8)
    end
)

Tirislib.Testing.add_test_case(
    "InhabitantGroup.take caps at available count",
    "inhabitants",
    function()
        local group = InhabitantGroup.new(TEST_CASTE, 3)
        local taken = InhabitantGroup.take(group, 100)

        Assert.equals(taken[EK.inhabitants], 3)
        Assert.equals(group[EK.inhabitants], 0)
    end
)

Tirislib.Testing.add_test_case(
    "InhabitantGroup.merge_partially takes and merges in one step",
    "inhabitants",
    function()
        local lh = InhabitantGroup.new(TEST_CASTE, 5, 10, 10, 10)
        local rh = InhabitantGroup.new(TEST_CASTE, 10, 10, 10, 10)

        InhabitantGroup.merge_partially(lh, rh, 3)

        Assert.equals(lh[EK.inhabitants], 8)
        Assert.equals(rh[EK.inhabitants], 7)
    end
)

---------------------------------------------------------------------------------------------------
-- << take with zero-count entries (infinite loop guard) >>

Tirislib.Testing.add_test_case(
    "DiseaseGroup.take does not infinite loop on zero-count entries",
    "inhabitants",
    function()
        -- Simulate a corrupted state where total_count doesn't match actual counts
        local group = {[HEALTHY] = 0, [1] = 0}
        local taken = DiseaseGroup.take(group, 5, 5)

        -- Should return without hanging, having taken nothing
        Assert.equals(Table.sum(taken), 0)
    end
)

Tirislib.Testing.add_test_case(
    "AgeGroup.take does not infinite loop on zero-count entries",
    "inhabitants",
    function()
        local group = {[20] = 0, [30] = 0}
        local taken = AgeGroup.take(group, 5, 5)

        Assert.equals(Table.sum(taken), 0)
    end
)

Tirislib.Testing.add_test_case(
    "GenderGroup.take does not infinite loop on zero-count entries",
    "inhabitants",
    function()
        local group = {0, 0, 0, 0}
        local taken = GenderGroup.take(group, 5, 5)

        Assert.equals(Table.sum(taken), 0)
    end
)
