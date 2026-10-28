local Assert = Tirislib.Testing.Assert
local AgeLink = require("enums.age-link")
local EK = require("enums.entry-key")
local Gender = require("enums.gender")
local Type = require("enums.type")

local InhabitantsConstants = require("constants.inhabitants")
local Time = require("constants.time")

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
        local group = DiseaseGroup.new(10)
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
        Assert.equals(group[AgeGroup.current_day() - 30], 5)
    end
)

Tirislib.Testing.add_test_case(
    "AgeGroup.new defaults to age 0",
    "inhabitants",
    function()
        local group = AgeGroup.new(3)
        Assert.equals(group[AgeGroup.current_day()], 3)
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
        local lh = {[20] = 3}
        local rh = {[20] = 2, [30] = 1}

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
        local lh = {[20] = 3}
        local rh = {[30] = 2}

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
    "AgeGroup.current_day counts nauvis days since the start of the game",
    "inhabitants",
    function()
        Assert.equals(AgeGroup.current_day(), math.floor(game.tick / Time.nauvis_day))
    end
)

Tirislib.Testing.add_test_case(
    "AgeGroup.get_age is the difference between today and the hatch day",
    "inhabitants",
    function()
        Assert.equals(AgeGroup.get_age(80, 100), 20)
        Assert.equals(AgeGroup.get_age(AgeGroup.current_day() - 7), 7)
    end
)

-- test-disease-oldest / test-disease-youngest, see the test diseases in constants/diseases.lua
local OLDEST_DISEASE = 99007
local YOUNGEST_DISEASE = 99008

Tirislib.Testing.add_test_case(
    "AgeGroup.take_extreme takes the oldest first",
    "inhabitants",
    function()
        local group = {[30] = 2, [10] = 1, [20] = 4}
        local taken = AgeGroup.take_extreme(group, 4, AgeLink.oldest)

        Assert.equals(taken[10], 1)
        Assert.equals(taken[20], 3)
        Assert.is_nil(taken[30])
        Assert.is_nil(group[10])
        Assert.equals(group[20], 1)
        Assert.equals(group[30], 2)
    end
)

Tirislib.Testing.add_test_case(
    "AgeGroup.take_extreme takes the youngest first",
    "inhabitants",
    function()
        local group = {[30] = 2, [10] = 1, [20] = 4}
        local taken = AgeGroup.take_extreme(group, 3, AgeLink.youngest)

        Assert.equals(taken[30], 2)
        Assert.equals(taken[20], 1)
        Assert.equals(group[20], 3)
        Assert.equals(group[10], 1)
    end
)

Tirislib.Testing.add_test_case(
    "AgeGroup.take_extreme takes at most everyone",
    "inhabitants",
    function()
        local group = {[30] = 2, [10] = 1}
        local taken = AgeGroup.take_extreme(group, 10, AgeLink.oldest)

        Assert.equals(Table.sum(taken), 3)
        Assert.equals(Table.sum(group), 0)
    end
)

Tirislib.Testing.add_test_case(
    "AgeGroup.take_for_diseases takes linked diseases from their end and the rest proportionally",
    "inhabitants",
    function()
        local group = {[10] = 2, [20] = 6, [30] = 2}
        local diseases = {[HEALTHY] = 2, [OLDEST_DISEASE] = 2, [YOUNGEST_DISEASE] = 1}
        local taken = AgeGroup.take_for_diseases(group, diseases, 5, 10)

        Assert.equals(Table.sum(taken), 5)
        Assert.equals(Table.sum(taken) + Table.sum(group), 10)
        Assert.equals(taken[10], 2, "the two oldest should be taken for the oldest-linked disease")
        Assert.greater_than(taken[30] or 0, 0, "the youngest should be taken for the youngest-linked disease")
    end
)

Tirislib.Testing.add_test_case(
    "AgeGroup.take_for_diseases without linked diseases is proportional",
    "inhabitants",
    function()
        local group = {[10] = 5, [20] = 5}
        local taken = AgeGroup.take_for_diseases(group, {[HEALTHY] = 4}, 4, 10)

        Assert.equals(taken[10], 2)
        Assert.equals(taken[20], 2)
    end
)

Tirislib.Testing.add_test_case(
    "InhabitantGroup.take_specific takes the ages of age-linked diseases",
    "inhabitants",
    function()
        local group = InhabitantGroup.new(Type.clockwork, 10)
        group[EK.ages] = {[10] = 3, [20] = 4, [30] = 3}
        DiseaseGroup.make_sick(group[EK.diseases], YOUNGEST_DISEASE, 3)

        local taken = InhabitantGroup.take_specific(group, 3, {[YOUNGEST_DISEASE] = 3})

        Assert.equals(taken[EK.ages][30], 3, "the youngest should leave with the disease")
        Assert.is_nil(group[EK.ages][30])
        Assert.equals(Table.sum(group[EK.ages]), 7)
    end
)

Tirislib.Testing.add_test_case(
    "InhabitantGroup.take_deceased takes the ages of the disease's age link",
    "inhabitants",
    function()
        local group = InhabitantGroup.new(Type.clockwork, 10)
        group[EK.ages] = {[10] = 3, [20] = 4, [30] = 3}

        local dead = InhabitantGroup.take_deceased(group, 2, OLDEST_DISEASE)

        Assert.equals(dead[EK.ages][10], 2, "the oldest should die of an oldest-linked disease")
        Assert.equals(group[EK.ages][10], 1)
        Assert.equals(group[EK.inhabitants], 8)
        Assert.equals(Table.sum(group[EK.ages]), 8, "ages should be subtracted only once")
    end
)

Tirislib.Testing.add_test_case(
    "InhabitantGroup.take_deceased takes proportional ages for unlinked diseases",
    "inhabitants",
    function()
        local group = InhabitantGroup.new(Type.clockwork, 10)
        group[EK.ages] = {[10] = 5, [20] = 5}

        local dead = InhabitantGroup.take_deceased(group, 4, 1)

        Assert.equals(dead[EK.ages][10], 2)
        Assert.equals(dead[EK.ages][20], 2)
        Assert.equals(Table.sum(group[EK.ages]), 6)
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

Tirislib.Testing.add_test_case(
    "AgeGroup.random_new keys the rolled ages by hatch day",
    "inhabitants",
    function()
        local group = AgeGroup.random_new(10, function() return 25 end)
        Assert.equals(group[AgeGroup.current_day() - 25], 10)
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

---------------------------------------------------------------------------------------------------
-- << ImmunityGroup tests >>

-- test-disease-immunity: short immunity after recovery, lifelong immunity from the vaccine
local IMMUNITY_DISEASE = 99005

--- Returns an ImmunityGroup with the given recovered and vaccinated counts for IMMUNITY_DISEASE.
local function immunity_group(recovered, vaccinated)
    local group = ImmunityGroup.new()
    group.recovered[IMMUNITY_DISEASE] = recovered
    group.vaccinated[IMMUNITY_DISEASE] = vaccinated
    return group
end

Tirislib.Testing.add_test_case(
    "ImmunityGroup.merge combines both kinds and empties rh",
    "inhabitants",
    function()
        local lh = immunity_group(2, nil)
        local rh = immunity_group(3, 4)

        ImmunityGroup.merge(lh, rh)

        Assert.equals(lh.recovered[IMMUNITY_DISEASE], 5)
        Assert.equals(lh.vaccinated[IMMUNITY_DISEASE], 4)
        Assert.is_table_empty(rh.recovered, "rh should be emptied")
        Assert.is_table_empty(rh.vaccinated, "rh should be emptied")
    end
)

Tirislib.Testing.add_test_case(
    "ImmunityGroup.merge with keep_rh preserves rh",
    "inhabitants",
    function()
        local lh = ImmunityGroup.new()
        local rh = immunity_group(3, 4)

        ImmunityGroup.merge(lh, rh, true)

        Assert.equals(lh.recovered[IMMUNITY_DISEASE], 3)
        Assert.equals(rh.recovered[IMMUNITY_DISEASE], 3)
        Assert.equals(rh.vaccinated[IMMUNITY_DISEASE], 4)
    end
)

Tirislib.Testing.add_test_case(
    "ImmunityGroup.take takes the proportional share",
    "inhabitants",
    function()
        local group = immunity_group(10, 4)

        local taken = ImmunityGroup.take(group, 10, 20)

        Assert.equals(taken.recovered[IMMUNITY_DISEASE], 5)
        Assert.equals(taken.vaccinated[IMMUNITY_DISEASE], 2)
        Assert.equals(group.recovered[IMMUNITY_DISEASE], 5)
        Assert.equals(group.vaccinated[IMMUNITY_DISEASE], 2)
    end
)

Tirislib.Testing.add_test_case(
    "ImmunityGroup.take never takes more than exists and conserves the total",
    "inhabitants",
    function()
        for _ = 1, 50 do
            local group = immunity_group(3, nil)
            local taken = ImmunityGroup.take(group, 7, 10)

            local taken_count = taken.recovered[IMMUNITY_DISEASE] or 0
            local remaining = group.recovered[IMMUNITY_DISEASE] or 0
            Assert.equals(taken_count + remaining, 3, "immune people should neither appear nor vanish")
            Assert.less_than(taken_count, 4, "should not take more than exists")
        end
    end
)

Tirislib.Testing.add_test_case(
    "ImmunityGroup.take of everyone takes all immunities",
    "inhabitants",
    function()
        local group = immunity_group(3, 2)

        local taken = ImmunityGroup.take(group, 15, 10)

        Assert.equals(taken.recovered[IMMUNITY_DISEASE], 3)
        Assert.equals(taken.vaccinated[IMMUNITY_DISEASE], 2)
        Assert.is_table_empty(group.recovered)
        Assert.is_table_empty(group.vaccinated)
    end
)

Tirislib.Testing.add_test_case(
    "ImmunityGroup.subtract errors on incompatible groups",
    "inhabitants",
    function()
        local lh = immunity_group(2, nil)
        local rh = immunity_group(3, nil)

        Assert.throws(function()
            ImmunityGroup.subtract(lh, rh)
        end)
    end
)

Tirislib.Testing.add_test_case(
    "ImmunityGroup.get_immune sums both kinds and caps at the group size",
    "inhabitants",
    function()
        local group = immunity_group(6, 3)

        Assert.equals(ImmunityGroup.get_immune(group, IMMUNITY_DISEASE, 20), 9)
        Assert.equals(ImmunityGroup.get_immune(group, IMMUNITY_DISEASE, 5), 5)
        Assert.equals(ImmunityGroup.get_immune(group, 1, 20), 0)
    end
)

Tirislib.Testing.add_test_case(
    "ImmunityGroup.grant caps at the group size",
    "inhabitants",
    function()
        local group = immunity_group(4, nil)

        ImmunityGroup.grant(group, "recovered", IMMUNITY_DISEASE, 10, 8)

        Assert.equals(group.recovered[IMMUNITY_DISEASE], 8)
    end
)

Tirislib.Testing.add_test_case(
    "ImmunityGroup.wane removes temporary immunity but keeps lifelong immunity",
    "inhabitants",
    function()
        local group = immunity_group(10, 10)

        ImmunityGroup.wane(group, 100000)

        Assert.is_nil(group.recovered[IMMUNITY_DISEASE], "temporary immunity should wane")
        Assert.equals(group.vaccinated[IMMUNITY_DISEASE], 10, "lifelong immunity should never wane")
    end
)

Tirislib.Testing.add_test_case(
    "ImmunityGroup.wane drops immunities to diseases that grant none",
    "inhabitants",
    function()
        local group = ImmunityGroup.new()
        group.recovered[1] = 5

        ImmunityGroup.wane(group, 1)

        Assert.is_nil(group.recovered[1])
    end
)

---------------------------------------------------------------------------------------------------
-- << InhabitantGroup immunity tests >>

Tirislib.Testing.add_test_case(
    "InhabitantGroup.make_sick sickens nobody when every healthy inhabitant is immune",
    "inhabitants",
    function()
        local group = InhabitantGroup.new(TEST_CASTE, 10)
        ImmunityGroup.grant(group[EK.immunities], "recovered", IMMUNITY_DISEASE, 10, 10)

        local sickened = InhabitantGroup.make_sick(group, IMMUNITY_DISEASE, 5)

        Assert.equals(sickened, 0)
        Assert.equals(group[EK.diseases][HEALTHY], 10)
    end
)

Tirislib.Testing.add_test_case(
    "InhabitantGroup.make_sick without immunities sickens like DiseaseGroup.make_sick",
    "inhabitants",
    function()
        local group = InhabitantGroup.new(TEST_CASTE, 10)

        local sickened = InhabitantGroup.make_sick(group, IMMUNITY_DISEASE, 3)

        Assert.equals(sickened, 3)
        Assert.equals(group[EK.diseases][IMMUNITY_DISEASE], 3)
    end
)

Tirislib.Testing.add_test_case(
    "InhabitantGroup.make_sick never sickens more than the susceptible inhabitants",
    "inhabitants",
    function()
        for _ = 1, 20 do
            local group = InhabitantGroup.new(TEST_CASTE, 10)
            ImmunityGroup.grant(group[EK.immunities], "vaccinated", IMMUNITY_DISEASE, 8, 10)

            local sickened = InhabitantGroup.make_sick(group, IMMUNITY_DISEASE, 10)

            Assert.less_than(sickened, 3, "only 2 inhabitants are susceptible")
        end
    end
)

Tirislib.Testing.add_test_case(
    "InhabitantGroup.merge and take carry the immunities",
    "inhabitants",
    function()
        local lh = InhabitantGroup.new(TEST_CASTE, 10)
        local rh = InhabitantGroup.new(TEST_CASTE, 10)
        ImmunityGroup.grant(rh[EK.immunities], "recovered", IMMUNITY_DISEASE, 10, 10)

        InhabitantGroup.merge(lh, rh)
        Assert.equals(lh[EK.immunities].recovered[IMMUNITY_DISEASE], 10)
        Assert.is_table_empty(rh[EK.immunities].recovered)

        local taken = InhabitantGroup.take(lh, 10)
        Assert.equals(taken[EK.immunities].recovered[IMMUNITY_DISEASE], 5)
        Assert.equals(lh[EK.immunities].recovered[IMMUNITY_DISEASE], 5)
    end
)

Tirislib.Testing.add_test_case(
    "InhabitantGroup.take_specific subtracts the given immunities",
    "inhabitants",
    function()
        local group = InhabitantGroup.new(TEST_CASTE, 10)
        ImmunityGroup.grant(group[EK.immunities], "recovered", IMMUNITY_DISEASE, 6, 10)

        local taken = InhabitantGroup.take_specific(group, 2, nil, nil, nil, immunity_group(2, nil))

        Assert.equals(taken[EK.immunities].recovered[IMMUNITY_DISEASE], 2)
        Assert.equals(group[EK.immunities].recovered[IMMUNITY_DISEASE], 4)
    end
)

---------------------------------------------------------------------------------------------------
-- << reproduction constants >>

Tirislib.Testing.add_test_case(
    "The meeting coefficient gives the reference meeting rate in the reference environment",
    "inhabitants",
    function()
        local C = InhabitantsConstants
        local rate = C.meeting_coefficient * C.reference_social_value ^ C.meeting_exponent

        Assert.is_number_close(rate, C.reference_meeting_rate, 1e-12)
    end
)

Tirislib.Testing.add_test_case(
    "The conception rate reaches the birth rate for naturally conceived eggs in the reference environment",
    "inhabitants",
    function()
        local C = InhabitantsConstants
        local genders = C.egg_data[C.egg_fertile].genders
        local ga = genders[Gender.ga]
        local eligible_share = ga * math.min(genders[Gender.fale] / ga, genders[Gender.pachin] / ga, 1)

        local meetings_per_cycle = C.reference_meeting_rate * C.ga_reproduction_cycle
        local chance_per_cycle = 1 - (1 - C.conception_rate) ^ meetings_per_cycle
        local births_per_tick = eligible_share * chance_per_cycle / C.ga_reproduction_cycle

        Assert.is_number_close(births_per_tick / C.birth_rate, 1, 1e-9)
    end
)

---------------------------------------------------------------------------------------------------
-- << vaccination >>

-- test-disease-immunity-2: like test-disease-immunity, for vaccines against two diseases
local IMMUNITY_DISEASE_2 = 99006

Tirislib.Testing.add_test_case(
    "InhabitantGroup.get_vaccinable counts the healthy inhabitants susceptible to one of the diseases",
    "inhabitants",
    function()
        local group = InhabitantGroup.new(TEST_CASTE, 10)
        DiseaseGroup.make_sick(group[EK.diseases], 1, 2)
        ImmunityGroup.grant(group[EK.immunities], "recovered", IMMUNITY_DISEASE, 6, 10)
        ImmunityGroup.grant(group[EK.immunities], "recovered", IMMUNITY_DISEASE_2, 3, 10)

        Assert.equals(InhabitantGroup.get_vaccinable(group, {IMMUNITY_DISEASE}), 2)
        Assert.equals(InhabitantGroup.get_vaccinable(group, {IMMUNITY_DISEASE, IMMUNITY_DISEASE_2}), 5)
    end
)

Tirislib.Testing.add_test_case(
    "InhabitantGroup.vaccinate grants one vaccinated immunity per dose",
    "inhabitants",
    function()
        local group = InhabitantGroup.new(TEST_CASTE, 10)

        Assert.is_true(InhabitantGroup.vaccinate(group, {IMMUNITY_DISEASE}))
        Assert.equals(group[EK.immunities].vaccinated[IMMUNITY_DISEASE], 1)
        Assert.is_nil(group[EK.immunities].recovered[IMMUNITY_DISEASE])
    end
)

Tirislib.Testing.add_test_case(
    "InhabitantGroup.vaccinate refuses when nobody can use the dose",
    "inhabitants",
    function()
        local group = InhabitantGroup.new(TEST_CASTE, 10)
        ImmunityGroup.grant(group[EK.immunities], "recovered", IMMUNITY_DISEASE, 10, 10)

        Assert.is_false(InhabitantGroup.vaccinate(group, {IMMUNITY_DISEASE}))
        Assert.is_nil(group[EK.immunities].vaccinated[IMMUNITY_DISEASE])
    end
)

Tirislib.Testing.add_test_case(
    "InhabitantGroup.vaccinate against two diseases makes a non-immune huwan immune to both",
    "inhabitants",
    function()
        local group = InhabitantGroup.new(TEST_CASTE, 10)

        InhabitantGroup.vaccinate(group, {IMMUNITY_DISEASE, IMMUNITY_DISEASE_2})

        Assert.equals(group[EK.immunities].vaccinated[IMMUNITY_DISEASE], 1)
        Assert.equals(group[EK.immunities].vaccinated[IMMUNITY_DISEASE_2], 1)
    end
)

Tirislib.Testing.add_test_case(
    "InhabitantGroup.vaccinate against two diseases still helps when one of them is covered",
    "inhabitants",
    function()
        local group = InhabitantGroup.new(TEST_CASTE, 10)
        ImmunityGroup.grant(group[EK.immunities], "recovered", IMMUNITY_DISEASE, 10, 10)

        Assert.is_true(InhabitantGroup.vaccinate(group, {IMMUNITY_DISEASE, IMMUNITY_DISEASE_2}))
        Assert.equals(group[EK.immunities].vaccinated[IMMUNITY_DISEASE_2], 1)
        Assert.is_nil(group[EK.immunities].vaccinated[IMMUNITY_DISEASE], "nobody is susceptible to the covered disease")
    end
)
