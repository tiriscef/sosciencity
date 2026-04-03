local Assert = Tirislib.Testing.Assert
local Tables = Tirislib.Tables

---------------------------------------------------------------------------------------------------
-- << equal >>

Tirislib.Testing.add_test_case(
    "equal returns true for the same table reference",
    "lib.tables",
    function()
        local t = {1, 2, 3}
        Assert.is_true(Tables.equal(t, t))
    end
)

Tirislib.Testing.add_test_case(
    "equal returns true for structurally identical tables",
    "lib.tables",
    function()
        Assert.is_true(Tables.equal({a = 1, b = 2}, {a = 1, b = 2}))
        Assert.is_true(Tables.equal({1, 2, 3}, {1, 2, 3}))
        Assert.is_true(Tables.equal({}, {}))
    end
)

Tirislib.Testing.add_test_case(
    "equal returns true for deeply nested equal tables",
    "lib.tables",
    function()
        Assert.is_true(Tables.equal({a = {b = {c = 1}}}, {a = {b = {c = 1}}}))
    end
)

Tirislib.Testing.add_test_case(
    "equal returns false for tables with different values",
    "lib.tables",
    function()
        Assert.is_false(Tables.equal({a = 1}, {a = 2}))
        Assert.is_false(Tables.equal({1, 2, 3}, {1, 2, 4}))
    end
)

Tirislib.Testing.add_test_case(
    "equal returns false when one table has extra keys",
    "lib.tables",
    function()
        Assert.is_false(Tables.equal({a = 1, b = 2}, {a = 1}))
        Assert.is_false(Tables.equal({a = 1}, {a = 1, b = 2}))
    end
)

Tirislib.Testing.add_test_case(
    "equal returns false when comparing a table to a non-table",
    "lib.tables",
    function()
        Assert.is_false(Tables.equal({}, nil))
        Assert.is_false(Tables.equal({}, 1))
    end
)

---------------------------------------------------------------------------------------------------
-- << shallow_equal >>

Tirislib.Testing.add_test_case(
    "shallow_equal returns true for equal flat tables",
    "lib.tables",
    function()
        Assert.is_true(Tables.shallow_equal({a = 1, b = 2}, {a = 1, b = 2}))
    end
)

Tirislib.Testing.add_test_case(
    "shallow_equal compares nested tables by reference, not structure",
    "lib.tables",
    function()
        local inner = {x = 1}
        Assert.is_true(Tables.shallow_equal({t = inner}, {t = inner}))
        Assert.is_false(Tables.shallow_equal({t = {x = 1}}, {t = {x = 1}}))
    end
)

---------------------------------------------------------------------------------------------------
-- << count >>

Tirislib.Testing.add_test_case(
    "count returns the number of entries including non-integer keys",
    "lib.tables",
    function()
        Assert.equals(Tables.count({}), 0)
        Assert.equals(Tables.count({1, 2, 3}), 3)
        Assert.equals(Tables.count({a = 1, b = 2, [3] = 3}), 3)
    end
)

---------------------------------------------------------------------------------------------------
-- << get_keyset >>

Tirislib.Testing.add_test_case(
    "get_keyset returns all keys as an array",
    "lib.tables",
    function()
        local result = Tables.get_keyset({a = 1, b = 2, c = 3})
        Assert.equals(#result, 3)
        Assert.contains(result, "a")
        Assert.contains(result, "b")
        Assert.contains(result, "c")
    end
)

Tirislib.Testing.add_test_case(
    "get_keyset returns an empty array for an empty table",
    "lib.tables",
    function()
        Assert.equals(Tables.get_keyset({}), {})
    end
)

---------------------------------------------------------------------------------------------------
-- << copy >>

Tirislib.Testing.add_test_case(
    "copy creates a new table with the same entries",
    "lib.tables",
    function()
        local original = {a = 1, b = 2}
        local copied = Tables.copy(original)
        Assert.is_true(Tables.shallow_equal(original, copied))
        Assert.is_true(original ~= copied)
    end
)

Tirislib.Testing.add_test_case(
    "copy references nested tables instead of cloning them",
    "lib.tables",
    function()
        local inner = {x = 1}
        local copied = Tables.copy({t = inner})
        Assert.equals(copied.t, inner)
    end
)

---------------------------------------------------------------------------------------------------
-- << recursive_copy >>

Tirislib.Testing.add_test_case(
    "recursive_copy deeply clones all nested tables",
    "lib.tables",
    function()
        local original = {a = {b = {c = 1}}}
        local copied = Tables.recursive_copy(original)
        Assert.is_true(Tables.equal(original, copied))
        Assert.is_true(original.a ~= copied.a)
        Assert.is_true(original.a.b ~= copied.a.b)
    end
)

Tirislib.Testing.add_test_case(
    "recursive_copy handles tables that reference the same subtable",
    "lib.tables",
    function()
        local inner = {x = 1}
        local original = {a = inner, b = inner}
        local copied = Tables.recursive_copy(original)
        -- the two keys should still reference the same (new) table in the copy
        Assert.equals(copied.a, copied.b)
    end
)

---------------------------------------------------------------------------------------------------
-- << contains / contains_key / any >>

Tirislib.Testing.add_test_case(
    "contains returns true when the value is present",
    "lib.tables",
    function()
        Assert.is_true(Tables.contains({a = 1, b = 2}, 2))
        Assert.is_true(Tables.contains({10, 20, 30}, 20))
    end
)

Tirislib.Testing.add_test_case(
    "contains returns false when the value is absent",
    "lib.tables",
    function()
        Assert.is_false(Tables.contains({a = 1}, 2))
        Assert.is_false(Tables.contains({}, 1))
    end
)

Tirislib.Testing.add_test_case(
    "contains_key returns true for present keys, false for absent",
    "lib.tables",
    function()
        Assert.is_true(Tables.contains_key({a = 1}, "a"))
        Assert.is_false(Tables.contains_key({a = 1}, "b"))
        Assert.is_false(Tables.contains_key({a = 1}, "a2"))
    end
)

Tirislib.Testing.add_test_case(
    "any returns true for non-empty tables and false for empty",
    "lib.tables",
    function()
        Assert.is_true(Tables.any({1}))
        Assert.is_true(Tables.any({a = 1}))
        Assert.is_false(Tables.any({}))
    end
)

---------------------------------------------------------------------------------------------------
-- << set_fields / set_fields_passively / copy_fields >>

Tirislib.Testing.add_test_case(
    "set_fields copies all fields onto the target table",
    "lib.tables",
    function()
        local target = {a = 1}
        Tables.set_fields(target, {b = 2, c = 3})
        Assert.equals(target, {a = 1, b = 2, c = 3})
    end
)

Tirislib.Testing.add_test_case(
    "set_fields overwrites existing fields",
    "lib.tables",
    function()
        local target = {a = 1}
        Tables.set_fields(target, {a = 99})
        Assert.equals(target.a, 99)
    end
)

Tirislib.Testing.add_test_case(
    "set_fields_passively does not overwrite existing fields",
    "lib.tables",
    function()
        local target = {a = 1}
        Tables.set_fields_passively(target, {a = 99, b = 2})
        Assert.equals(target.a, 1)
        Assert.equals(target.b, 2)
    end
)

Tirislib.Testing.add_test_case(
    "set_fields_passively does not overwrite fields set to false",
    "lib.tables",
    function()
        local target = {a = false}
        Tables.set_fields_passively(target, {a = true})
        Assert.is_false(target.a)
    end
)

Tirislib.Testing.add_test_case(
    "copy_fields clones nested tables instead of referencing them",
    "lib.tables",
    function()
        local inner = {x = 1}
        local target = {}
        Tables.copy_fields(target, {t = inner})
        Assert.is_true(Tables.equal(target.t, inner))
        Assert.is_true(target.t ~= inner)
    end
)

---------------------------------------------------------------------------------------------------
-- << merge >>

Tirislib.Testing.add_test_case(
    "merge appends all values of rh to lh",
    "lib.tables",
    function()
        local lh = {1, 2}
        Tables.merge(lh, {a = 3, b = 4})
        Assert.equals(Tables.count(lh), 4)
        Assert.contains(lh, 3)
        Assert.contains(lh, 4)
    end
)

---------------------------------------------------------------------------------------------------
-- << sum / product / average / normalize >>

Tirislib.Testing.add_test_case(
    "sum returns the sum of all values",
    "lib.tables",
    function()
        Assert.equals(Tables.sum({a = 1, b = 2, c = 3}), 6)
        Assert.equals(Tables.sum({}), 0)
    end
)

Tirislib.Testing.add_test_case(
    "product returns the product of all values",
    "lib.tables",
    function()
        Assert.equals(Tables.product({a = 2, b = 3, c = 4}), 24)
        Assert.equals(Tables.product({}), 1)
    end
)

Tirislib.Testing.add_test_case(
    "average returns the mean of all values",
    "lib.tables",
    function()
        Assert.equals(Tables.average({a = 1, b = 2, c = 3}), 2)
        Assert.equals(Tables.average({x = 10}), 10)
    end
)

Tirislib.Testing.add_test_case(
    "average returns 0 for an empty table",
    "lib.tables",
    function()
        Assert.equals(Tables.average({}), 0)
    end
)

Tirislib.Testing.add_test_case(
    "normalize scales values so they sum to 1",
    "lib.tables",
    function()
        local tbl = {a = 1, b = 3}
        Tables.normalize(tbl)
        Assert.equals(tbl.a, 0.25)
        Assert.equals(tbl.b, 0.75)
    end
)

Tirislib.Testing.add_test_case(
    "normalize does nothing when all values are zero",
    "lib.tables",
    function()
        local tbl = {a = 0, b = 0}
        Tables.normalize(tbl)
        Assert.equals(tbl.a, 0)
        Assert.equals(tbl.b, 0)
    end
)

---------------------------------------------------------------------------------------------------
-- << values / invert >>

Tirislib.Testing.add_test_case(
    "values returns all values as an array",
    "lib.tables",
    function()
        local result = Tables.values({a = 1, b = 2, c = 3})
        Assert.equals(#result, 3)
        Assert.contains(result, 1)
        Assert.contains(result, 2)
        Assert.contains(result, 3)
    end
)

Tirislib.Testing.add_test_case(
    "invert swaps keys and values",
    "lib.tables",
    function()
        Assert.equals(Tables.invert({a = 1, b = 2}), {[1] = "a", [2] = "b"})
    end
)

---------------------------------------------------------------------------------------------------
-- << empty >>

Tirislib.Testing.add_test_case(
    "empty removes all fields from the table",
    "lib.tables",
    function()
        local tbl = {a = 1, b = 2, 3, 4}
        Tables.empty(tbl)
        Assert.is_false(Tables.any(tbl))
    end
)

Tirislib.Testing.add_test_case(
    "empty preserves the table reference",
    "lib.tables",
    function()
        local tbl = {a = 1}
        local ref = tbl
        Tables.empty(tbl)
        Assert.equals(tbl, ref)
    end
)

---------------------------------------------------------------------------------------------------
-- << add / subtract / multiply >>

Tirislib.Testing.add_test_case(
    "add accumulates values from rh into lh",
    "lib.tables",
    function()
        local lh = {a = 10, b = 20}
        Tables.add(lh, {a = 5, c = 3})
        Assert.equals(lh.a, 15)
        Assert.equals(lh.b, 20)
        Assert.equals(lh.c, 3)
    end
)

Tirislib.Testing.add_test_case(
    "subtract decrements values of lh by rh",
    "lib.tables",
    function()
        local lh = {a = 10, b = 20}
        Tables.subtract(lh, {a = 3, c = 1})
        Assert.equals(lh.a, 7)
        Assert.equals(lh.b, 20)
        Assert.equals(lh.c, -1)
    end
)

Tirislib.Testing.add_test_case(
    "multiply scales all values by the multiplier",
    "lib.tables",
    function()
        local tbl = {a = 2, b = 5}
        Tables.multiply(tbl, 3)
        Assert.equals(tbl.a, 6)
        Assert.equals(tbl.b, 15)
    end
)

---------------------------------------------------------------------------------------------------
-- << get_subtbl / get_subtbl_recursive / get_subtbl_recursive_passive >>

Tirislib.Testing.add_test_case(
    "get_subtbl returns an existing subtable",
    "lib.tables",
    function()
        local inner = {x = 1}
        local tbl = {a = inner}
        Assert.equals(Tables.get_subtbl(tbl, "a"), inner)
    end
)

Tirislib.Testing.add_test_case(
    "get_subtbl creates and returns a new subtable if absent",
    "lib.tables",
    function()
        local tbl = {}
        local sub = Tables.get_subtbl(tbl, "a")
        Assert.not_nil(sub)
        Assert.equals(tbl.a, sub)
    end
)

Tirislib.Testing.add_test_case(
    "get_subtbl does not replace a stored false value",
    "lib.tables",
    function()
        local tbl = {a = false}
        Tables.get_subtbl(tbl, "a")
        Assert.is_false(tbl.a)
    end
)

Tirislib.Testing.add_test_case(
    "get_subtbl_recursive creates nested subtables along the path",
    "lib.tables",
    function()
        local tbl = {}
        local deep = Tables.get_subtbl_recursive(tbl, "a", "b", "c")
        Assert.not_nil(deep)
        Assert.not_nil(tbl.a)
        Assert.not_nil(tbl.a.b)
        Assert.equals(tbl.a.b.c, deep)
    end
)

Tirislib.Testing.add_test_case(
    "get_subtbl_recursive_passive returns nil when any key is missing",
    "lib.tables",
    function()
        local tbl = {a = {b = {}}}
        Assert.not_nil(Tables.get_subtbl_recursive_passive(tbl, "a", "b"))
        Assert.is_nil(Tables.get_subtbl_recursive_passive(tbl, "a", "x"))
        Assert.is_nil(Tables.get_subtbl_recursive_passive(nil, "a"))
    end
)

---------------------------------------------------------------------------------------------------
-- << group_by_key >>

Tirislib.Testing.add_test_case(
    "group_by_key groups entries by the value of the given key",
    "lib.tables",
    function()
        local a1 = {type = "a", n = 1}
        local a2 = {type = "a", n = 2}
        local b1 = {type = "b", n = 3}
        local result = Tables.group_by_key({a1, a2, b1}, "type")
        Assert.equals(#result["a"], 2)
        Assert.equals(#result["b"], 1)
        Assert.contains(result["a"], a1)
        Assert.contains(result["a"], a2)
        Assert.contains(result["b"], b1)
    end
)

Tirislib.Testing.add_test_case(
    "group_by_key puts entries without the key into the default group",
    "lib.tables",
    function()
        local a1 = {type = "a"}
        local unknown = {n = 99}
        local result = Tables.group_by_key({a1, unknown}, "type", "unknown")
        Assert.equals(#result["a"], 1)
        Assert.equals(#result["unknown"], 1)
        Assert.contains(result["unknown"], unknown)
    end
)

---------------------------------------------------------------------------------------------------
-- << union / intersection / complement >>

Tirislib.Testing.add_test_case(
    "union returns all unique values across the given tables",
    "lib.tables",
    function()
        local result = Tables.union({1, 2, 3}, {2, 3, 4})
        Assert.equals(#result, 4)
        Assert.contains(result, 1)
        Assert.contains(result, 4)
    end
)

Tirislib.Testing.add_test_case(
    "union deduplicates values that appear in multiple tables",
    "lib.tables",
    function()
        local result = Tables.union({1, 1, 2}, {2, 3})
        Assert.equals(#result, 3)
    end
)

Tirislib.Testing.add_test_case(
    "intersection returns only values present in all tables",
    "lib.tables",
    function()
        local result = Tables.intersection({1, 2, 3}, {2, 3, 4}, {3, 4, 5})
        Assert.equals(#result, 1)
        Assert.contains(result, 3)
    end
)

Tirislib.Testing.add_test_case(
    "intersection returns an empty array when there is no common value",
    "lib.tables",
    function()
        local result = Tables.intersection({1, 2}, {3, 4})
        Assert.equals(#result, 0)
    end
)

Tirislib.Testing.add_test_case(
    "complement returns values in the other tables that are not in set",
    "lib.tables",
    function()
        local result = Tables.complement({1, 2}, {1, 2, 3, 4})
        Assert.equals(#result, 2)
        Assert.contains(result, 3)
        Assert.contains(result, 4)
    end
)
