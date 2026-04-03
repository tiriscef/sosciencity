local Assert = Tirislib.Testing.Assert
local Arrays = Tirislib.Arrays

---------------------------------------------------------------------------------------------------
-- << remove_all >>

Tirislib.Testing.add_test_case(
    "remove_all removes every occurrence of the given value",
    "lib.arrays",
    function()
        local arr = {1, 2, 3, 2, 4, 2}
        Arrays.remove_all(arr, 2)
        Assert.equals(#arr, 3)
        Assert.is_false(Arrays.contains(arr, 2))
    end
)

Tirislib.Testing.add_test_case(
    "remove_all does nothing when the value is not present",
    "lib.arrays",
    function()
        local arr = {1, 2, 3}
        Arrays.remove_all(arr, 9)
        Assert.equals(#arr, 3)
    end
)

Tirislib.Testing.add_test_case(
    "remove_all preserves all other values",
    "lib.arrays",
    function()
        local arr = {1, 2, 3}
        Arrays.remove_all(arr, 2)
        Assert.contains(arr, 1)
        Assert.contains(arr, 3)
    end
)

---------------------------------------------------------------------------------------------------
-- << to_lookup >>

Tirislib.Testing.add_test_case(
    "to_lookup maps each element to true",
    "lib.arrays",
    function()
        local result = Arrays.to_lookup({"a", "b", "c"})
        Assert.is_true(result["a"])
        Assert.is_true(result["b"])
        Assert.is_true(result["c"])
        Assert.is_nil(result["d"])
    end
)

Tirislib.Testing.add_test_case(
    "to_lookup returns an empty table for an empty array",
    "lib.arrays",
    function()
        Assert.equals(Arrays.to_lookup({}), {})
    end
)

---------------------------------------------------------------------------------------------------
-- << shuffle >>

Tirislib.Testing.add_test_case(
    "shuffle returns the same array instance",
    "lib.arrays",
    function()
        local arr = {1, 2, 3, 4, 5}
        Assert.equals(Arrays.shuffle(arr), arr)
    end
)

Tirislib.Testing.add_test_case(
    "shuffle preserves all elements",
    "lib.arrays",
    function()
        local arr = {1, 2, 3, 4, 5}
        Arrays.shuffle(arr)
        Assert.equals(#arr, 5)
        Assert.contains(arr, 1)
        Assert.contains(arr, 5)
    end
)

---------------------------------------------------------------------------------------------------
-- << merge >>

Tirislib.Testing.add_test_case(
    "merge appends rh elements to lh in order",
    "lib.arrays",
    function()
        local lh = {1, 2}
        Arrays.merge(lh, {3, 4, 5})
        Assert.equals(lh, {1, 2, 3, 4, 5})
    end
)

Tirislib.Testing.add_test_case(
    "merge returns the lh array",
    "lib.arrays",
    function()
        local lh = {1}
        Assert.equals(Arrays.merge(lh, {2}), lh)
    end
)

---------------------------------------------------------------------------------------------------
-- << sum / product >>

Tirislib.Testing.add_test_case(
    "sum returns the sum of all elements",
    "lib.arrays",
    function()
        Assert.equals(Arrays.sum({1, 2, 3, 4}), 10)
        Assert.equals(Arrays.sum({}), 0)
    end
)

Tirislib.Testing.add_test_case(
    "product returns the product of all elements",
    "lib.arrays",
    function()
        Assert.equals(Arrays.product({2, 3, 4}), 24)
        Assert.equals(Arrays.product({}), 1)
    end
)

---------------------------------------------------------------------------------------------------
-- << new >>

Tirislib.Testing.add_test_case(
    "new creates an array of the given size filled with the given value",
    "lib.arrays",
    function()
        local arr = Arrays.new(4, 0)
        Assert.equals(arr, {0, 0, 0, 0})
    end
)

Tirislib.Testing.add_test_case(
    "new with size 0 returns an empty array",
    "lib.arrays",
    function()
        Assert.equals(Arrays.new(0, 99), {})
    end
)

---------------------------------------------------------------------------------------------------
-- << contains >>

Tirislib.Testing.add_test_case(
    "contains returns true when the value is present",
    "lib.arrays",
    function()
        Assert.is_true(Arrays.contains({10, 20, 30}, 20))
        Assert.is_true(Arrays.contains({"a", "b"}, "a"))
    end
)

Tirislib.Testing.add_test_case(
    "contains returns false when the value is absent",
    "lib.arrays",
    function()
        Assert.is_false(Arrays.contains({1, 2, 3}, 9))
        Assert.is_false(Arrays.contains({}, 1))
    end
)

---------------------------------------------------------------------------------------------------
-- << index_of >>

Tirislib.Testing.add_test_case(
    "index_of returns the index of the first occurrence",
    "lib.arrays",
    function()
        Assert.equals(Arrays.index_of({10, 20, 30}, 20), 2)
        Assert.equals(Arrays.index_of({"a", "b", "c"}, "a"), 1)
    end
)

Tirislib.Testing.add_test_case(
    "index_of returns the first index when there are duplicates",
    "lib.arrays",
    function()
        Assert.equals(Arrays.index_of({5, 5, 5}, 5), 1)
    end
)

Tirislib.Testing.add_test_case(
    "index_of returns nil when the value is not found",
    "lib.arrays",
    function()
        Assert.is_nil(Arrays.index_of({1, 2, 3}, 9))
        Assert.is_nil(Arrays.index_of({}, 1))
    end
)

---------------------------------------------------------------------------------------------------
-- << min / max >>

Tirislib.Testing.add_test_case(
    "min returns the smallest value",
    "lib.arrays",
    function()
        Assert.equals(Arrays.min({3, 1, 4, 1, 5, 9}), 1)
        Assert.equals(Arrays.min({7}), 7)
        Assert.equals(Arrays.min({-3, -1, -5}), -5)
    end
)

Tirislib.Testing.add_test_case(
    "min returns nil for an empty array",
    "lib.arrays",
    function()
        Assert.is_nil(Arrays.min({}))
    end
)

Tirislib.Testing.add_test_case(
    "max returns the largest value",
    "lib.arrays",
    function()
        Assert.equals(Arrays.max({3, 1, 4, 1, 5, 9}), 9)
        Assert.equals(Arrays.max({7}), 7)
        Assert.equals(Arrays.max({-3, -1, -5}), -1)
    end
)

Tirislib.Testing.add_test_case(
    "max returns nil for an empty array",
    "lib.arrays",
    function()
        Assert.is_nil(Arrays.max({}))
    end
)

---------------------------------------------------------------------------------------------------
-- << reverse >>

Tirislib.Testing.add_test_case(
    "reverse reverses the array in-place",
    "lib.arrays",
    function()
        local arr = {1, 2, 3, 4, 5}
        Arrays.reverse(arr)
        Assert.equals(arr, {5, 4, 3, 2, 1})
    end
)

Tirislib.Testing.add_test_case(
    "reverse handles arrays of even and odd length",
    "lib.arrays",
    function()
        local even = {1, 2, 3, 4}
        Arrays.reverse(even)
        Assert.equals(even, {4, 3, 2, 1})

        local odd = {1, 2, 3}
        Arrays.reverse(odd)
        Assert.equals(odd, {3, 2, 1})
    end
)

Tirislib.Testing.add_test_case(
    "reverse returns the same array instance",
    "lib.arrays",
    function()
        local arr = {1, 2, 3}
        Assert.equals(Arrays.reverse(arr), arr)
    end
)

---------------------------------------------------------------------------------------------------
-- << sequence >>

Tirislib.Testing.add_test_case(
    "sequence generates an ascending integer sequence",
    "lib.arrays",
    function()
        Assert.equals(Arrays.sequence(1, 5), {1, 2, 3, 4, 5})
        Assert.equals(Arrays.sequence(3, 3), {3})
    end
)

Tirislib.Testing.add_test_case(
    "sequence respects a custom step size",
    "lib.arrays",
    function()
        Assert.equals(Arrays.sequence(0, 10, 2), {0, 2, 4, 6, 8, 10})
        Assert.equals(Arrays.sequence(1, 10, 3), {1, 4, 7, 10})
    end
)

Tirislib.Testing.add_test_case(
    "sequence generates a descending sequence when finish is less than start",
    "lib.arrays",
    function()
        Assert.equals(Arrays.sequence(5, 1), {5, 4, 3, 2, 1})
        Assert.equals(Arrays.sequence(10, 1, 3), {10, 7, 4, 1})
    end
)
